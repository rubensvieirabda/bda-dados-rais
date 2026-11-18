#!/usr/bin/env python3
"""Consulta o índice BM25 gerado por rag_ingest.py.

Uso:
    python .../rag_query.py "choque de commodities 2014" -k 6
    python .../rag_query.py "PNAD Contínua desocupação" --level 1 --json
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from pathlib import Path

TOKEN_RE = re.compile(r"[^\W_]+", re.UNICODE)
STOPWORDS = set(
    """a o as os um uma uns umas de do da dos das em no na nos nas por pelo pela
    para com sem sob sobre entre e ou mas que se como quando onde qual quais cujo
    cuja e é são foi foram ser estar está estão há tem têm ao aos à às mais menos
    já não sim também muito pouco seu sua seus suas este esta estes estas esse essa
    isso aquilo ele ela eles elas nós vós eu tu você vocês lhe lhes me te nos vos
    the of and to in for on with at by from is are was were be been this that these
    those it its as an or not""".split()
)


def tokenizar(texto: str) -> list[str]:
    return [
        t
        for t in (m.group(0).lower() for m in TOKEN_RE.finditer(texto))
        if len(t) > 1 and t not in STOPWORDS
    ]


def carregar(caminho: Path) -> dict:
    if not caminho.exists():
        raise SystemExit(
            f"Índice não encontrado: {caminho}\n"
            "Rode: python .opencode/skills/rag-harness-defesa/scripts/rag_ingest.py"
        )
    return json.loads(caminho.read_text(encoding="utf-8"))


def trecho_relevante(texto: str, termos: list[str], limite: int = 420) -> str:
    minusculo = texto.lower()
    posicoes = [minusculo.find(t) for t in termos]
    posicoes = [p for p in posicoes if p >= 0]
    inicio = max(0, (min(posicoes) - 90)) if posicoes else 0
    trecho = texto[inicio : inicio + limite].replace("\n", " ")
    return re.sub(r"\s+", " ", trecho).strip()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("consulta", nargs="+")
    ap.add_argument("-k", type=int, default=8)
    ap.add_argument("--level", type=int, choices=[1, 2, 3])
    ap.add_argument("--area")
    ap.add_argument("--json", action="store_true")
    ap.add_argument("--index", default="")
    args = ap.parse_args()

    raiz = Path(__file__).resolve().parents[4]
    indice_path = Path(args.index) if args.index else raiz / "rag_corpus" / ".indice" / "index.json"
    indice = carregar(indice_path)

    termos = tokenizar(" ".join(args.consulta))
    if not termos:
        print("Consulta vazia após remover stopwords.", file=sys.stderr)
        return 2

    n = indice["n_chunks"]
    avgdl = indice["avgdl"] or 1.0
    df = indice["df"]
    k1, b = 1.5, 0.75

    resultados = []
    for chunk in indice["chunks"]:
        if args.level and chunk["nivel"] != args.level:
            continue
        if args.area and chunk["area"] != args.area:
            continue
        toks = tokenizar(chunk["text"])
        if not toks:
            continue
        tf: dict[str, int] = {}
        for t in toks:
            tf[t] = tf.get(t, 0) + 1
        dl = len(toks)
        score = 0.0
        for termo in termos:
            if termo not in tf:
                continue
            idf = math.log(1 + (n - df.get(termo, 0) + 0.5) / (df.get(termo, 0) + 0.5))
            freq = tf[termo]
            score += idf * (freq * (k1 + 1)) / (freq + k1 * (1 - b + b * dl / avgdl))
        if score > 0:
            resultados.append((score, chunk))

    resultados.sort(key=lambda x: x[0], reverse=True)
    resultados = resultados[: args.k]

    if args.json:
        print(
            json.dumps(
                [
                    {
                        "score": round(s, 4),
                        "path": c["path"],
                        "title": c["title"],
                        "level": c["nivel"],
                        "date": c["date"],
                        "snippet": trecho_relevante(c["text"], termos),
                    }
                    for s, c in resultados
                ],
                ensure_ascii=False,
                indent=2,
            )
        )
        return 0

    if not resultados:
        print("Nenhum trecho encontrado. Reformule ou amplie o corpus.")
        return 0

    for i, (score, c) in enumerate(resultados, 1):
        nivel = c["nivel"]
        data = f" · {c['date']}" if c["date"] else ""
        print(f"\n{i}. [Nível {nivel}] {c['path']}{data}")
        print(f"   {c['title']}")
        print(f"   {trecho_relevante(c['text'], termos)}")
        print(f"   (score {score:.2f})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
