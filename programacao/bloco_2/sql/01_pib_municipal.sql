-- =============================================================================
-- 01_pib_municipal.sql
-- =============================================================================
-- Objetivo : extrair PIB e valor adicionado por município, 2010–2023.
-- Fonte    : Base dos Dados — basedosdados.br_ibge_pib.municipio
-- Origem   : IBGE, Produto Interno Bruto dos Municípios
-- Granularidade de saída: 1 linha por ano × município
--
-- Dicionário validado em 17/11/2026 (ver ../dicionario_validado.csv).
-- A staging da BD guarda os valores em MILHARES de reais; o modelo final
-- multiplica por 1000. Aqui os valores já vêm em REAIS.
--
-- ATENÇÃO — abertura setorial:
--   2022 e 2023 foram divulgados apenas com PIB e PIB per capita. As colunas
--   va_agropecuaria, va_industria, va_servicos e va_adespss não têm a mesma
--   cobertura nesses anos. A coluna `tem_abertura_setorial` marca isso para
--   que nenhum gráfico setorial use 2022–2023 por engano.
--
-- Parâmetros: espelham `config.yaml` → recorte e fontes.pib.
--   recorte.ano_inicio = 2010
--   fontes.pib.anos    = [2010, 2023]
-- =============================================================================

WITH params AS (
  SELECT
    2010 AS ano_inicio,
    2023 AS ano_fim,
    2021 AS abertura_setorial_ate
)

SELECT
  p.ano,
  p.id_municipio,
  m.sigla_uf,
  m.nome                                   AS nome_municipio,
  m.nome_regiao_metropolitana,
  m.nome_regiao,

  -- Produto e valor adicionado, em reais correntes.
  p.pib,
  p.va,
  p.impostos_liquidos,
  p.va_agropecuaria,
  p.va_industria,
  p.va_servicos,
  p.va_adespss,

  -- Composição do VAB (fração do valor adicionado total).
  SAFE_DIVIDE(p.va_agropecuaria, p.va)     AS share_va_agropecuaria,
  SAFE_DIVIDE(p.va_industria, p.va)        AS share_va_industria,
  SAFE_DIVIDE(p.va_servicos, p.va)         AS share_va_servicos,
  SAFE_DIVIDE(p.va_adespss, p.va)          AS share_va_adespss,

  -- Flag metodológica: false em 2022–2023 (sem abertura setorial publicada).
  p.ano <= (SELECT abertura_setorial_ate FROM params) AS tem_abertura_setorial,

  -- Rastreabilidade.
  'basedosdados.br_ibge_pib.municipio' AS fonte_tabela,
  'IBGE — PIB dos Municípios'          AS fonte_origem,
  CURRENT_DATE()                       AS extraido_em

FROM `basedosdados.br_ibge_pib.municipio` AS p
LEFT JOIN `basedosdados.br_bd_diretorios_brasil.municipio` AS m
  ON m.id_municipio = p.id_municipio
WHERE p.ano BETWEEN (SELECT ano_inicio FROM params) AND (SELECT ano_fim FROM params)
ORDER BY p.ano, p.id_municipio;

-- -----------------------------------------------------------------------------
-- Testes que este resultado precisa passar (scripts/validar.py):
--   1. UNIQUE(ano, id_municipio) — sem duplicata.
--   2. id_municipio tem 7 dígitos, como texto.
--   3. pib > 0 e va > 0.
--   4. |sum(va_*) - va| / va <= 0.01 nos anos com abertura setorial.
--   5. Nenhum ano > 2023 (a fonte não publica 2024–2026).
-- -----------------------------------------------------------------------------
