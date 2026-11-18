#!/usr/bin/env python3
"""Esqueleto de extração e cálculo dos indicadores territoriais (Bloco 2).

Este script tem duas metades:

1. **SQL de referência** — consultas ao BigQuery via Base dos Dados, impressas por
   `--sql`. Os nomes de tabela DEVEM ser confirmados no dicionário antes de rodar
   (skill `basedosdados-dicionarios`). Nada aqui substitui essa checagem.
2. **Cálculo local** — lê CSVs já tratados em `pesquisa/03_dados/tratados/` e
   calcula produtividade, participação e ranking com critério declarado.

Uso:
    python extrair_territorio.py --sql
    python extrair_territorio.py --pib pesquisa/03_dados/tratados/pib_municipal.csv \
        --ocupados pesquisa/03_dados/tratados/rais_municipal.csv --top 20
"""

from __future__ import annotations

import argparse
import csv
import sys
import textwrap
from pathlib import Path

SQL_PIB_MUNICIPAL = textwrap.dedent(
    """
    -- CONFIRMAR nomes de tabela e colunas no dicionário da Base dos Dados
    -- antes de executar. Dataset esperado: br_ibge_pib
    SELECT
      ano,
      id_municipio,
      produto_interno_bruto,
      valor_adicionado_bruto_agropecuaria,
      valor_adicionado_bruto_industria,
      valor_adicionado_bruto_servicos
    FROM `basedosdados.br_ibge_pib.municipio`
    WHERE ano BETWEEN 2010 AND 2024
    """
).strip()

SQL_POPULACAO = textwrap.dedent(
    """
    -- População residente estimada por município (IBGE).
    -- CONFIRMAR dataset/tabela no dicionário.
    SELECT ano, id_municipio, populacao
    FROM `basedosdados.br_ibge_populacao.municipio`
    WHERE ano BETWEEN 2010 AND 2026
    """
).strip()

SQL_RAIS_MUNICIPAL = textwrap.dedent(
    """
    -- Estoque de vínculos ativos em 31/12 e remuneração média por município.
    SELECT
      ano,
      id_municipio,
      COUNT(*)                        AS vinculos_ativos,
      AVG(valor_remuneracao_media)    AS remuneracao_media
    FROM `basedosdados.br_me_rais.microdados_vinculos`
    WHERE ano BETWEEN 2010 AND 2024
      AND vinculo_ativo_3112 = '1'
    GROUP BY ano, id_municipio
    """
).strip()

SQL_COMEX = textwrap.dedent(
    """
    -- Comex Stat NÃO está no BigQuery da Base dos Dados.
    -- Baixe o CSV por município em https://comexstat.mdic.gov.br/pt/municipio
    -- e salve em pesquisa/03_dados/brutos/comex_municipio.csv
    -- Colunas esperadas: ano, id_municipio, fluxo, valor_usd, peso_kg
    """
).strip()

CONSULTAS = {
    "pib_municipal": SQL_PIB_MUNICIPAL,
    "populacao": SQL_POPULACAO,
    "rais_municipal": SQL_RAIS_MUNICIPAL,
    "comex": SQL_COMEX,
}


def ler_csv(caminho: Path) -> list[dict[str, str]]:
    with caminho.open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def numero(valor: str) -> float | None:
    if valor is None:
        return None
    valor = valor.strip().replace(".", "").replace(",", ".")
    if not valor or valor in {"-", "NA", "null", "None"}:
        return None
    try:
        return float(valor)
    except ValueError:
        return None


def indexar(linhas: list[dict[str, str]], chave: tuple[str, str]) -> dict[tuple[str, str], dict[str, str]]:
    saida = {}
    for linha in linhas:
        k = tuple(linha.get(c, "").strip() for c in chave)
        if all(k):
            saida[k] = linha
    return saida


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--sql", nargs="?", const="todas", choices=["todas", *CONSULTAS])
    ap.add_argument("--pib")
    ap.add_argument("--ocupados")
    ap.add_argument("--populacao")
    ap.add_argument("--top", type=int, default=20)
    ap.add_argument("--criterio", choices=["pib", "vinculos", "populacao", "produtividade"], default="pib")
    ap.add_argument("--saida", default="pesquisa/02_saidas/ranking_cidades.csv")
    args = ap.parse_args()

    if args.sql:
        alvos = CONSULTAS if args.sql == "todas" else {args.sql: CONSULTAS[args.sql]}
        for nome, sql in alvos.items():
            print(f"\n-- ===== {nome} =====\n{sql}")
        return 0

    if not args.pib or not args.ocupados:
        print("Informe --pib e --ocupados (CSVs tratados). Use --sql para ver as consultas.", file=sys.stderr)
        return 2

    pib = indexar(ler_csv(Path(args.pib)), ("ano", "id_municipio"))
    ocup = indexar(ler_csv(Path(args.ocupados)), ("ano", "id_municipio"))
    pop = indexar(ler_csv(Path(args.populacao)), ("ano", "id_municipio")) if args.populacao else {}

    linhas = []
    for chave, linha_pib in pib.items():
        if chave not in ocup:
            continue
        linha_ocup = ocup[chave]
        vab = numero(linha_pib.get("produto_interno_bruto", ""))
        ocupados = numero(linha_ocup.get("vinculos_ativos", ""))
        if not vab or not ocupados:
            continue
        populacao = numero(pop.get(chave, {}).get("populacao", "")) if pop else None
        linhas.append(
            {
                "ano": chave[0],
                "id_municipio": chave[1],
                "pib": vab,
                "vinculos_ativos": ocupados,
                "populacao": populacao,
                "pib_per_capita": (vab / populacao) if populacao else None,
                "produtividade_vab_por_vinculo": vab / ocupados,
                "remuneracao_media": numero(linha_ocup.get("remuneracao_media", "")),
            }
        )

    campo = {
        "pib": "pib",
        "vinculos": "vinculos_ativos",
        "populacao": "populacao",
        "produtividade": "produtividade_vab_por_vinculo",
    }[args.criterio]
    linhas = [l for l in linhas if l[campo] is not None]
    linhas.sort(key=lambda l: l[campo], reverse=True)
    linhas = linhas[: args.top]

    destino = Path(args.saida)
    destino.parent.mkdir(parents=True, exist_ok=True)
    campos = list(linhas[0].keys()) if linhas else []
    with destino.open("w", encoding="utf-8", newline="") as f:
        escritor = csv.DictWriter(f, fieldnames=campos)
        escritor.writeheader()
        escritor.writerows(linhas)

    print(f"Critério: {args.criterio} | linhas: {len(linhas)} | saída: {destino}")
    print("Lembre-se: ranking sem ano-base, unidade e fonte não pode ser publicado.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
