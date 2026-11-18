#!/usr/bin/env python3
"""Extrai os indicadores de emprego da PNAD Contínua via Base dos Dados (BigQuery).

Este arquivo é um esqueleto de referência: exige credenciais do Google Cloud.
Ajuste o projeto de faturamento e rode em ambiente com `basedosdados` instalado.

    pip install basedosdados
    python extrair_serie_pnadc.py --billing meu-projeto-gcp
"""

from __future__ import annotations

import argparse
import textwrap

SQL_TRIMESTRAL = textwrap.dedent(
    """
    SELECT
      ano,
      trimestre,
      sigla_uf,
      taxa_desocupacao,
      taxa_subutilizacao,
      nivel_ocupacao,
      taxa_participacao,
      taxa_informalidade,
      rendimento_medio_real
    FROM `basedosdados.br_ibge_pnadc.microdados`
    WHERE ano BETWEEN 2012 AND 2026
    """
).strip()

SQL_ANUAL = textwrap.dedent(
    """
    -- A PNAD Contínua anual usa a média dos trimestres ou o 4º trimestre,
    -- dependendo do indicador. Declare a escolha na metodologia.
    SELECT
      ano,
      sigla_uf,
      AVG(taxa_desocupacao)  AS desocupacao_media,
      AVG(taxa_subutilizacao) AS subutilizacao_media,
      AVG(nivel_ocupacao)     AS nivel_ocupacao_medio,
      AVG(taxa_informalidade) AS informalidade_media
    FROM `basedosdados.br_ibge_pnadc.microdados`
    WHERE ano BETWEEN 2012 AND 2026
    GROUP BY ano, sigla_uf
    ORDER BY ano, sigla_uf
    """
).strip()

SQL_RAIS = textwrap.dedent(
    """
    SELECT ano, id_municipio, COUNT(*) AS vinculos_ativos
    FROM `basedosdados.br_me_rais.microdados_vinculos`
    WHERE ano BETWEEN 2010 AND 2026
      AND vinculo_ativo_3112 = '1'
    GROUP BY ano, id_municipio
    """
).strip()

SQL_CAGED = textwrap.dedent(
    """
    -- Novo CAGED: fluxo mensal (admissões, desligamentos, saldo).
    SELECT ano, mes, sigla_uf, saldo
    FROM `basedosdados.br_me_caged.microdados`
    WHERE ano BETWEEN 2020 AND 2026
    """
).strip()

CONSULTAS = {
    "pnadc_trimestral": SQL_TRIMESTRAL,
    "pnadc_anual": SQL_ANUAL,
    "rais_estoque": SQL_RAIS,
    "caged_fluxo": SQL_CAGED,
}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--billing", required=False, help="ID do projeto de faturamento no GCP")
    ap.add_argument("--consulta", choices=sorted(CONSULTAS), default="pnadc_trimestral")
    ap.add_argument("--saida", default="pesquisa/03_dados/brutos")
    ap.add_argument("--imprimir", action="store_true")
    args = ap.parse_args()

    sql = CONSULTAS[args.consulta]
    if args.imprimir or not args.billing:
        print(sql)
        if not args.billing:
            print("\n(Defina --billing para executar a consulta.)")
        return 0

    try:
        import basedosdados as bd  # type: ignore
    except ImportError:
        print("Instale o pacote: pip install basedosdados")
        return 2

    bd.set_billing_project(args.billing)
    df = bd.read_sql(sql, billing_project_id=args.billing)
    from pathlib import Path

    destino = Path(args.saida) / f"{args.consulta}.csv"
    destino.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(destino, index=False)
    print(f"Salvo em {destino} ({len(df)} linhas)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
