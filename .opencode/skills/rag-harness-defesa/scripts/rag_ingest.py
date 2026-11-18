#!/usr/bin/env python3
"""Indexa o corpus local (./rag_corpus) para busca BM25, sem dependências externas.

Uso:
    python .opencode/skills/rag-harness-defesa/scripts/rag_ingest.py
    python .../rag_ingest.py --corpus rag_corpus --out rag_corpus/.indice

Formatos lidos: .md .txt .csv .json .yml .yaml .html .htm e .pdf (se pypdf estiver
instalado). Planilhas (.xls/.xlsx) entram apenas no manifesto, não no índice de texto.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

LEVELS = {
    "dicionarios": 1,
    "oficiais": 1,
    "academico": 2,
    "imprensa": 3,
}
TEXT_EXT = {".md", ".txt", ".csv", ".json", ".yml", ".yaml", ".html", ".htm"}
SKIP_DIRS = {".indice", ".git", "__pycache__", "node_modules"}

STOPWORDS = set(
    """a o as os um uma uns umas de do da dos das em no na nos nas por pelo pela
    para com sem sob sobre entre e ou mas que se como quando onde qual quais cujo
    cuja e é são foi foram ser estar está estão há tem têm ao aos à às mais menos
    já não sim também muito pouco seu sua seus suas este esta estes estas esse essa
    isso aquilo ele ela eles elas nós vós eu tu você vocês lhe lhes me te nos vos
    the of and to in for on with at by from is are was were be been this that these
    those it its as an or not""".split()
)

TOKEN_RE = re.compile(r"[^\W_]+", re.UNICODE)


def tokenizar(texto: str) -> list[str]:
    return [
        t
        for t in (m.group(0).lower() for m in TOKEN_RE.finditer(texto))
        if len(t) > 1 and t not in STOPWORDS
    ]


def limpar_html(html: str) -> str:
    html = re.sub(r"(?is)<(script|style).*?</\1>", " ", html)
    html = re.sub(r"(?s)<[^>]+>", " ", html)
    html = (
        html.replace("&nbsp;", " ")
        .replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", '"')
        .replace("&#39;", "'")
    )
    return re.sub(r"[ \t]+", " ", html)


def ler_pdf(caminho: Path) -> tuple[str, str]:
    import logging

    logging.getLogger("pypdf").setLevel(logging.ERROR)
    try:
        from pypdf import PdfReader  # type: ignore
    except ImportError:
        return "", "pypdf ausente (instale com: pip install pypdf)"
    leitor = PdfReader(str(caminho))
    paginas = []
    for pagina in leitor.pages:
        try:
            paginas.append(pagina.extract_text() or "")
        except Exception:
            continue
    return "\n\n".join(paginas), ""


def ler_arquivo(caminho: Path) -> tuple[str, str]:
    ext = caminho.suffix.lower()
    if ext == ".pdf":
        return ler_pdf(caminho)
    if ext in {".html", ".htm"}:
        bruto = caminho.read_text(encoding="utf-8", errors="ignore")
        return limpar_html(bruto), ""
    if ext in TEXT_EXT:
        return caminho.read_text(encoding="utf-8", errors="ignore"), ""
    return "", f"extensão não indexável: {ext}"


def titulo_do_texto(texto: str, caminho: Path) -> str:
    for linha in texto.splitlines():
        linha = linha.strip()
        if not linha:
            continue
        if linha.startswith("#"):
            return linha.lstrip("#").strip()[:140]
        return linha[:140]
    return caminho.stem


def data_do_nome(caminho: Path) -> str:
    m = re.search(r"(\d{4})-(\d{2})-(\d{2})", caminho.name)
    return m.group(0) if m else ""


def dividir_em_chunks(texto: str, tamanho: int = 1100, sobreposicao: int = 150) -> list[str]:
    paragrafos = [p.strip() for p in re.split(r"\n\s*\n", texto) if p.strip()]
    chunks: list[str] = []
    atual = ""
    for paragrafo in paragrafos:
        if len(paragrafo) > tamanho * 2:
            for frase in re.split(r"(?<=[.!?])\s+", paragrafo):
                if len(atual) + len(frase) + 1 <= tamanho:
                    atual = f"{atual} {frase}".strip()
                else:
                    if atual:
                        chunks.append(atual)
                    atual = (chunks[-1][-sobreposicao:] + " " + frase).strip() if chunks else frase
        elif len(atual) + len(paragrafo) + 2 <= tamanho:
            atual = f"{atual}\n\n{paragrafo}".strip()
        else:
            if atual:
                chunks.append(atual)
            atual = (atual[-sobreposicao:] + "\n\n" + paragrafo).strip() if atual else paragrafo
    if atual:
        chunks.append(atual)
    return chunks


def main() -> int:
    raiz = Path(__file__).resolve().parents[4]
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--corpus", default=str(raiz / "rag_corpus"))
    ap.add_argument("--out", default="")
    args = ap.parse_args()

    corpus = Path(args.corpus).resolve()
    saida = Path(args.out).resolve() if args.out else corpus / ".indice"
    if not corpus.exists():
        print(f"ERRO: corpus não encontrado: {corpus}", file=sys.stderr)
        return 2

    chunks: list[dict] = []
    manifesto: list[dict] = []
    problemas: list[str] = []

    for caminho in sorted(corpus.rglob("*")):
        if not caminho.is_file():
            continue
        rel = caminho.relative_to(corpus)
        if any(parte in SKIP_DIRS for parte in rel.parts):
            continue
        if caminho.name.startswith("."):
            continue

        area = rel.parts[0] if len(rel.parts) > 1 else "raiz"
        nivel = LEVELS.get(area, 1)
        texto, erro = ler_arquivo(caminho)
        digest = hashlib.sha256(caminho.read_bytes()).hexdigest()

        registro = {
            "path": rel.as_posix(),
            "area": area,
            "nivel": nivel,
            "bytes": caminho.stat().st_size,
            "sha256": digest,
            "chunks": 0,
        }

        if erro:
            registro["erro"] = erro
            manifesto.append(registro)
            if caminho.suffix.lower() == ".pdf":
                problemas.append(f"{rel}: {erro}")
            continue

        texto = re.sub(r"[ \t]+", " ", texto)
        texto = re.sub(r"\n{3,}", "\n\n", texto).strip()
        if len(texto) < 40:
            registro["erro"] = "texto insuficiente"
            manifesto.append(registro)
            problemas.append(f"{rel}: texto insuficiente (provável página de erro)")
            continue

        titulo = titulo_do_texto(texto, caminho)
        data = data_do_nome(caminho)
        for i, trecho in enumerate(dividir_em_chunks(texto)):
            chunks.append(
                {
                    "id": hashlib.sha1(f"{rel}:{i}".encode()).hexdigest()[:16],
                    "path": rel.as_posix(),
                    "area": area,
                    "nivel": nivel,
                    "title": titulo,
                    "date": data,
                    "text": trecho,
                }
            )
        registro["chunks"] = sum(1 for c in chunks if c["path"] == rel.as_posix())
        manifesto.append(registro)

    if not chunks:
        print("ERRO: nenhum chunk gerado. Verifique o corpus.", file=sys.stderr)
        return 1

    df: dict[str, int] = {}
    tokens_por_chunk: list[list[str]] = []
    for c in chunks:
        toks = tokenizar(c["text"])
        tokens_por_chunk.append(toks)
        for termo in set(toks):
            df[termo] = df.get(termo, 0) + 1

    indice = {
        "built_at": datetime.now(timezone.utc).isoformat(),
        "corpus": str(corpus),
        "n_chunks": len(chunks),
        "avgdl": sum(len(t) for t in tokens_por_chunk) / len(tokens_por_chunk),
        "df": df,
        "files": manifesto,
        "chunks": chunks,
    }

    saida.mkdir(parents=True, exist_ok=True)
    destino = saida / "index.json"
    destino.write_text(json.dumps(indice, ensure_ascii=False), encoding="utf-8")

    print(f"Índice: {destino}")
    print(f"Arquivos indexados: {len([f for f in manifesto if f['chunks'] > 0])}")
    print(f"Chunks: {len(chunks)} | Vocabulário: {len(df)}")
    for f in manifesto:
        if f.get("erro") and f["chunks"] == 0:
            print(f"  ! {f['path']}: {f['erro']}")
    if problemas:
        print(f"Avisos: {len(problemas)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
