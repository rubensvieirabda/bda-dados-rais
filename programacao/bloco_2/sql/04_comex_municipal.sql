-- =============================================================================
-- 04_comex_municipal.sql
-- =============================================================================
-- Objetivo : exportação, importação e saldo comercial por município, 2010–2024.
-- Fonte    : Base dos Dados — basedosdados.br_me_comex_stat
--              .municipio_exportacao
--              .municipio_importacao
-- Origem   : MDIC — Comex Stat
-- Granularidade de saída: 1 linha por ano × município
-- Unidade  : US$ FOB (valor), kg (peso líquido)
--
-- Dicionário validado em 17/11/2026 (ver ../dicionario_validado.csv).
--   ano, mes, id_sh4, id_pais, sigla_pais_iso3, sigla_uf, id_municipio,
--   peso_liquido_kg, valor_fob_dolar
--
-- PRECAUÇÕES QUE VÃO PARA A TELA
--   1. O município é o do ESTABELECIMENTO DECLARANTE, não a origem física da
--      mercadoria. Sede de trading e cidade portuária concentram valor que foi
--      produzido em outro lugar. Nunca leia "exportação de Santos" como
--      "produção de Santos".
--   2. A BD já converte os códigos 9300000 e 9999999 em NULL. A linha com
--      id_municipio NULL é o "não atribuído ao município": serve para fechar o
--      total nacional e NÃO entra em ranking municipal.
--   3. A BD atualiza o Comex com atraso. Antes de rodar, confira:
--         SELECT MAX(ano) FROM `basedosdados.br_me_comex_stat.municipio_exportacao`;
--
-- ALTERNATIVA (só se a BD estiver atrasada)
--   CSV oficial: https://balanca.economia.gov.br/balanca/bd/comexstat-bd/mun/EXP_{ano}_MUN.csv
--   Layout: CO_ANO;CO_MES;SH4;CO_PAIS;SG_UF_MUN;CO_MUN;KG_LIQUIDO;VL_FOB
--   ATENÇÃO: o certificado TLS de balanca.economia.gov.br está EXPIRADO
--   (verificado em 17/11/2026). Baixar com verificação desligada
--   (`curl -k`) e registrar isso no metadados.json.
--
-- Parâmetros: `config.yaml` → recorte e fontes.comex.
-- =============================================================================

WITH params AS (
  SELECT
    2010 AS ano_inicio,
    2024 AS ano_fim
),

movimentacao AS (
  SELECT
    ano,
    id_municipio,
    sigla_uf,
    valor_fob_dolar,
    peso_liquido_kg,
    'exportacao' AS fluxo
  FROM `basedosdados.br_me_comex_stat.municipio_exportacao`
  WHERE ano BETWEEN (SELECT ano_inicio FROM params) AND (SELECT ano_fim FROM params)

  UNION ALL

  SELECT
    ano,
    id_municipio,
    sigla_uf,
    valor_fob_dolar,
    peso_liquido_kg,
    'importacao' AS fluxo
  FROM `basedosdados.br_me_comex_stat.municipio_importacao`
  WHERE ano BETWEEN (SELECT ano_inicio FROM params) AND (SELECT ano_fim FROM params)
)

SELECT
  ano,
  id_municipio,
  id_municipio IS NOT NULL                                  AS tem_municipio,
  ANY_VALUE(sigla_uf)                                       AS sigla_uf,

  SUM(IF(fluxo = 'exportacao', valor_fob_dolar, 0))         AS exportacao_usd_fob,
  SUM(IF(fluxo = 'importacao', valor_fob_dolar, 0))         AS importacao_usd_fob,
  SUM(IF(fluxo = 'exportacao', valor_fob_dolar, -valor_fob_dolar))
                                                            AS saldo_comercial_usd_fob,

  SUM(IF(fluxo = 'exportacao', peso_liquido_kg, 0))         AS peso_exportado_kg,
  SUM(IF(fluxo = 'importacao', peso_liquido_kg, 0))         AS peso_importado_kg,

  -- Corrente de comércio = exportação + importação.
  SUM(valor_fob_dolar)                                      AS corrente_comercio_usd_fob,

  COUNTIF(valor_fob_dolar IS NULL)                          AS registros_sem_valor,

  'basedosdados.br_me_comex_stat'                           AS fonte_tabela,
  'MDIC — Comex Stat'                                       AS fonte_origem,
  CURRENT_DATE()                                            AS extraido_em

FROM movimentacao
GROUP BY ano, id_municipio
ORDER BY ano, saldo_comercial_usd_fob DESC;

-- -----------------------------------------------------------------------------
-- Testes:
--   1. UNIQUE(ano, id_municipio) — NULL conta como um grupo próprio.
--   2. exportacao_usd_fob >= 0 e importacao_usd_fob >= 0.
--   3. Soma das linhas com tem_municipio = true + linha NULL = total nacional
--      publicado pelo Comex Stat no ano (tolerância 0,5%).
--   4. Nenhum município do ranking com saldo absurdamente maior que o PIB
--      municipal: indício de sede de trading, não de produção local.
-- -----------------------------------------------------------------------------
