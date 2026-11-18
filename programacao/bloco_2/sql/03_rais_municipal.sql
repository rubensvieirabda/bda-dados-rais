-- =============================================================================
-- 03_rais_municipal.sql
-- =============================================================================
-- Objetivo : estoque de vínculos formais e remuneração por município, com
--            quebra opcional por seção CNAE 2.0.
-- Fonte    : Base dos Dados — basedosdados.br_me_rais.microdados_vinculos
-- Origem   : MTE — Relação Anual de Informações Sociais (RAIS)
-- Granularidade de saída:
--   1 linha por ano × município × seção CNAE (nivel_agregacao = 'secao_cnae')
--   1 linha por ano × município           (nivel_agregacao = 'municipio',
--                                          secao_cnae = 'TOTAL')
--
-- Dicionário validado em 17/11/2026 (ver ../dicionario_validado.csv).
--   ano                      int64    partição da tabela
--   id_municipio             string   7 dígitos (cluster)
--   sigla_uf                 string
--   vinculo_ativo_3112       string   '1' = ativo em 31/12
--   valor_remuneracao_media  float64  remuneração média mensal NOMINAL (R$)
--   cnae_2                   string   CNAE 2.0 — classe (5 dígitos)
--   indicador_vinculo_abandonado string  só existe a partir de 2023 (NULL antes)
--
-- POR QUE O FILTRO DE VÍNCULO ABANDONADO EXISTE
--   O próprio teste de consistência da Base dos Dados compara
--   sum(quantidade_vinculos_ativos) com
--   countif(vinculo_ativo_3112 = '1' and coalesce(indicador_vinculo_abandonado,'0') != '1').
--   Vínculo abandonado não entra no estoque, senão a contagem municipal não
--   fecha com o total publicado pelo MTE.
--
-- CUSTO
--   A tabela é particionada por `ano` e clusterizada por `sigla_uf, id_municipio`.
--   Rodar 2010–2023 de uma vez varre ~700 milhões de linhas. Se a cota do
--   BigQuery estiver apertada, rode UM ANO POR VEZ (troque o BETWEEN por
--   `ano = 2015`) e concatene os CSVs no destino.
--
-- SAÍDA NÃO É "PRODUTIVIDADE DO TRABALHO"
--   O denominador é vínculo formal, não pessoa ocupada. Municípios com muita
--   informalidade aparecem com produtividade artificialmente alta. O nome
--   correto do indicador derivado é "VAB por vínculo formal".
--
-- Parâmetros: `config.yaml` → recorte e fontes.rais.
-- =============================================================================

WITH params AS (
  SELECT
    2010 AS ano_inicio,
    2023 AS ano_fim
),

-- Dimensão de seção CNAE. O DISTINCT é obrigatório: o diretório tem uma linha
-- por subclasse e a mesma classe aparece em várias linhas. Sem o DISTINCT, o
-- JOIN multiplica os vínculos.
secao_cnae AS (
  SELECT DISTINCT
    classe,
    secao,
    descricao_secao
  FROM `basedosdados.br_bd_diretorios_brasil.cnae_2`
  WHERE classe IS NOT NULL
),

vinculos AS (
  SELECT
    r.ano,
    r.id_municipio,
    r.valor_remuneracao_media,
    COALESCE(s.secao, 'NAO_INFORMADO')          AS secao_cnae,
    COALESCE(s.descricao_secao, 'Seção não informada') AS descricao_secao
  FROM `basedosdados.br_me_rais.microdados_vinculos` AS r
  LEFT JOIN secao_cnae AS s
    ON s.classe = r.cnae_2
  WHERE r.ano BETWEEN (SELECT ano_inicio FROM params) AND (SELECT ano_fim FROM params)
    AND r.vinculo_ativo_3112 = '1'
    AND COALESCE(r.indicador_vinculo_abandonado, '0') != '1'
    AND r.id_municipio IS NOT NULL
)

SELECT
  v.ano,
  v.id_municipio,
  m.sigla_uf,
  m.nome                                   AS nome_municipio,
  m.nome_regiao_metropolitana,

  -- TOTAL = linha de município; demais valores = seção CNAE 2.0.
  IF(GROUPING(v.secao_cnae) = 1, 'TOTAL', v.secao_cnae)        AS secao_cnae,
  IF(GROUPING(v.secao_cnae) = 1, 'municipio', 'secao_cnae')    AS nivel_agregacao,
  IF(GROUPING(v.secao_cnae) = 1, 'Todos os setores',
     ANY_VALUE(v.descricao_secao))                             AS descricao_secao,

  -- Estoque de vínculos formais ativos em 31/12.
  COUNT(*)                                                    AS vinculos_ativos_3112,

  -- Remuneração média mensal nominal, em reais do ano.
  ROUND(AVG(v.valor_remuneracao_media), 2)                    AS remuneracao_media_nominal,
  ROUND(APPROX_QUANTILES(v.valor_remuneracao_media, 100)[OFFSET(50)], 2)
                                                              AS remuneracao_mediana_nominal,
  COUNTIF(v.valor_remuneracao_media IS NULL)                  AS vinculos_sem_remuneracao,

  -- Rastreabilidade.
  'basedosdados.br_me_rais.microdados_vinculos' AS fonte_tabela,
  'MTE — RAIS'                                  AS fonte_origem,
  CURRENT_DATE()                                AS extraido_em

FROM vinculos AS v
LEFT JOIN `basedosdados.br_bd_diretorios_brasil.municipio` AS m
  ON m.id_municipio = v.id_municipio
GROUP BY GROUPING SETS (
  (v.ano, v.id_municipio, m.sigla_uf, m.nome, m.nome_regiao_metropolitana, v.secao_cnae),
  (v.ano, v.id_municipio, m.sigla_uf, m.nome, m.nome_regiao_metropolitana)
)
ORDER BY v.ano, v.id_municipio, nivel_agregacao, secao_cnae;

-- -----------------------------------------------------------------------------
-- Ranking das cidades (D1/D2) sai daqui, sem consulta nova:
--
--   SELECT id_municipio, nome_municipio, vinculos_ativos_3112
--   FROM painel
--   WHERE ano = 2023 AND nivel_agregacao = 'municipio'
--   ORDER BY vinculos_ativos_3112 DESC
--   LIMIT 20;
--
-- Gere também os rankings por PIB e por população (01 e 02) e compare os três
-- lado a lado: a diferença entre critérios é parte do argumento do Bloco 2.
--
-- Testes:
--   1. UNIQUE(ano, id_municipio, secao_cnae) — 'TOTAL' incluído na chave.
--   2. Soma das seções = linha 'TOTAL' em cada ano × município.
--   3. vinculos_ativos_3112 > 0.
--   4. `vinculos_sem_remuneracao` / vinculos <= 0.05.
--   5. Nenhum município com secao_cnae = 'NAO_INFORMADO' acima de 10% do total.
-- -----------------------------------------------------------------------------
