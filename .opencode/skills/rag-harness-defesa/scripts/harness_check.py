#!/usr/bin/env python3
"""Audita um texto de pesquisa contra as regras do harness de defesa.

Verifica:
  1. Tags no formato [Fonte | Ano/Período | Nível 1|2|3].
  2. Tags malformadas (colchetes com "Nível" fora do padrão).
  3. Parágrafos com números/percentuais sem nenhuma tag de citação.
  4. Se as fontes citadas constam em fontes.csv (quando informado).

Uso:
    python .../harness_check.py pesquisa/01_blocos/BLOCO_1.md --fontes pesquisa/00_protocolo/fontes.csv
"""

from __future__ import annotations

import argparse
import csv
import re
import sys
from pathlib import Path

TAG_RE = re.compile(r"\[\s*([^\]|\n]{2,140}?)\s*\|\s*([^\]|\n]{1,80}?)\s*\|\s*N[íi]vel\s*([123])\s*\]")
MALFORMADA_RE = re.compile(r"\[[^\]\n]*N[íi]vel[^\]\n]*\]", re.IGNORECASE)
NUMERO_RE = re.compile(r"\d")


def normalizar(texto: str) -> str:
    return re.sub(r"\s+", " ", texto).strip().lower()


def carregar_fontes(caminho: Path) -> list[dict]:
    with caminho.open(encoding="utf-8", newline="") as f:
        return list(csv.DictReader(f))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("arquivo")
    ap.add_argument("--fontes", default="")
    ap.add_argument("--strict", action="store_true", help="falha se houver número sem citação")
    ap.add_argument("--out", default="")
    args = ap.parse_args()

    arquivo = Path(args.arquivo)
    if not arquivo.exists():
        print(f"ERRO: arquivo não encontrado: {arquivo}", file=sys.stderr)
        return 2

    texto = arquivo.read_text(encoding="utf-8")
    # Remove blocos e trechos de código: ali dentro, tags são exemplos, não citações.
    sem_codigo = re.sub(r"```.*?```", "", texto, flags=re.S)
    sem_codigo = re.sub(r"`[^`\n]*`", "", sem_codigo)

    tags = TAG_RE.findall(sem_codigo)
    tags_malformadas = [
        m.group(0) for m in MALFORMADA_RE.finditer(sem_codigo) if not TAG_RE.fullmatch(m.group(0))
    ]

    # Parágrafos com número e sem citação.
    paragrafos = [p.strip() for p in re.split(r"\n\s*\n", sem_codigo) if p.strip()]
    sem_citacao = []
    for p in paragrafos:
        if p.startswith(("#", ">", "|", "-", "*", "1.", "2.", "3.", "4.", "5.", "6.", "7.", "8.", "9.")):
            continue
        if "<" in p and ">" in p and "http" in p:
            continue
        if NUMERO_RE.search(p) and not TAG_RE.search(p) and len(p) > 60:
            sem_citacao.append(p)

    fontes_ok = None
    fontes_faltando: list[str] = []
    if args.fontes:
        fontes = carregar_fontes(Path(args.fontes))
        alvos = " ".join(
            normalizar(" ".join(str(v) for v in f.values() if v)) for f in fontes
        )
        usadas = {normalizar(t[0]) for t in tags}
        for usada in sorted(usadas):
            if usada and usada not in alvos:
                fontes_faltando.append(usada)
        fontes_ok = len(fontes_faltando) == 0

    linhas = [
        f"# Auditoria de harness — {arquivo.as_posix()}",
        "",
        f"- Tags válidas: **{len(tags)}**",
        f"- Tags malformadas: **{len(tags_malformadas)}**",
        f"- Parágrafos com números sem citação: **{len(sem_citacao)}**",
    ]
    if fontes_ok is not None:
        linhas.append(f"- Fontes citadas ausentes em fontes.csv: **{len(fontes_faltando)}**")

    if tags_malformadas:
        linhas += ["", "## Tags malformadas", ""] + [f"- `{t}`" for t in tags_malformadas[:20]]
    if sem_citacao:
        linhas += ["", "## Parágrafos numéricos sem citação (amostra)", ""]
        linhas += [f"- {p[:220]}" for p in sem_citacao[:10]]
    if fontes_faltando:
        linhas += ["", "## Fontes não registradas em fontes.csv", ""]
        linhas += [f"- {f}" for f in fontes_faltando[:20]]

    relatorio = "\n".join(linhas) + "\n"
    if args.out:
        Path(args.out).write_text(relatorio, encoding="utf-8")
        print(f"Relatório: {args.out}")
    else:
        print(relatorio)

    problemas = len(tags_malformadas) + (len(sem_citacao) if args.strict else 0)
    return 1 if problemas else 0


if __name__ == "__main__":
    raise SystemExit(main())
