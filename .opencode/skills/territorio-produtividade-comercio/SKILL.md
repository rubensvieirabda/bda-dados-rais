---
name: territorio-produtividade-comercio
description: Mapeia indicadores de emprego, produtividade, polos de investimento e forças comerciais nas maiores cidades e regiões brasileiras.
---

## Objetivo
Cruzar o desempenho do mercado de trabalho com a dinâmica espacial, produtiva e comercial do Brasil nas maiores cidades e regiões econômicas.

## Eixos de Análise
1. **Recorte Urbano e Regional**:
   - Identificar o critério explícito de "maiores cidades" (população IBGE, PIB municipal IBGE ou estoque de vínculos formais RAIS) e manter o mesmo critério em toda a comparação.
   - Analisar capitais, regiões metropolitanas e polos regionais de destaque.
2. **Investimentos e Produtividade**:
   - Usar métricas padronizadas: PIB per capita, Valor Adicionado Bruto (VAB) por setor (agropecuária, indústria, serviços), produtividade do trabalho (VAB / pessoal ocupado) e fluxos de investimento anunciados/executados (BNDES, IBGE/PIA, relatórios estaduais e setoriais).
3. **Forças Comerciais nos Últimos Anos**:
   - Mapear balança comercial por UF/município (Comex Stat / MDIC), principais pautas exportadoras e importadoras, complexidade econômica e dinâmica do comércio varejista/serviços (PMC e PMS/IBGE).

## Regras de Rigor
- Sempre declarar o ano-base do PIB municipal ou da RAIS (pois dados municipais oficiais têm defasagem de divulgação em relação aos dados nacionais trimestrais).
- Evitar rankings sem informar a unidade de medida e o ano de referência.

## Arquivos de Apoio
- `scripts/extrair_territorio.py` — esqueleto de extração (PIB municipal, RAIS, Comex Stat).
- `templates/TABELA_CIDADES.md` — ranking com critério, unidade e ano-base declarados.
- `references/FONTES_TERRITORIO.md` — links oficiais (IBGE, MDIC, BNDES, IPEA).
