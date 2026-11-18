-- =============================================================================
-- 02_populacao_municipal.sql
-- =============================================================================
-- Objetivo : extrair população residente por município, 2010–2025.
-- Fonte    : Base dos Dados — basedosdados.br_ibge_populacao.municipio
-- Origem   : IBGE — Censo 2022 e Estimativas de População
-- Granularidade de saída: 1 linha por ano × município
--
-- Dicionário validado em 17/11/2026 (ver ../dicionario_validado.csv).
-- Colunas disponíveis: ano, sigla_uf, id_municipio, populacao.
--
-- ATENÇÃO — natureza do dado:
--   2022 é população residente do Censo 2022 (contagem direta).
--   Os demais anos são estimativas municipais. As duas coisas não são a mesma
--   medida e a coluna `origem_populacao` existe para deixar isso explícito em
--   toda tabela publicada.
--
-- Parâmetros: `config.yaml` → recorte e fontes.populacao.
--   fontes.populacao.anos = [2010, 2025]
-- =============================================================================

WITH params AS (
  SELECT
    2010 AS ano_inicio,
    2025 AS ano_fim,
    2022 AS ano_censo
)

SELECT
  pop.ano,
  pop.id_municipio,
  pop.sigla_uf,
  m.nome                                   AS nome_municipio,
  m.nome_regiao_metropolitana,
  pop.populacao,

  CASE
    WHEN pop.ano = (SELECT ano_censo FROM params) THEN 'censo_2022'
    ELSE 'estimativa_ibge'
  END                                      AS origem_populacao,

  -- Densidade só é calculável se a área do município estiver no diretório.
  -- Mantida fora desta consulta: depende de tabela de áreas territoriais
  -- do IBGE, que não está na Base dos Dados.

  'basedosdados.br_ibge_populacao.municipio' AS fonte_tabela,
  'IBGE — Censo 2022 e Estimativas de População' AS fonte_origem,
  CURRENT_DATE()                           AS extraido_em

FROM `basedosdados.br_ibge_populacao.municipio` AS pop
LEFT JOIN `basedosdados.br_bd_diretorios_brasil.municipio` AS m
  ON m.id_municipio = pop.id_municipio
WHERE pop.ano BETWEEN (SELECT ano_inicio FROM params) AND (SELECT ano_fim FROM params)
ORDER BY pop.ano, pop.id_municipio;

-- -----------------------------------------------------------------------------
-- Testes:
--   1. UNIQUE(ano, id_municipio).
--   2. populacao > 0.
--   3. Cobertura: os 20 municípios do ranking têm população no ano-base.
--   4. Queda ou salto abrupto de população entre anos consecutivos deve ser
--      investigado (revisão de estimativa ou erro de junção), nunca aceito
--      silenciosamente.
-- -----------------------------------------------------------------------------
