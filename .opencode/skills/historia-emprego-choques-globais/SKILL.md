---
name: historia-emprego-choques-globais
description: Estrutura a análise histórica comparativa do mercado de trabalho brasileiro (2010–2018 vs. 2019–2026) cruzando indicadores de emprego/desemprego com eventos globais e catástrofes comprovadas.
---

## Objetivo
Construir uma narrativa rigorosa, cronológica e verificável sobre os maiores e menores índices de emprego no Brasil entre **2010–2018** e **2019–2026**, separando choques externos comprovados de fatores domésticos.

## Métricas Obrigatórias (Não Usar Apenas Taxa de Desocupação)
- Taxa de desocupação (IBGE/PNAD-C).
- Taxa composta de subutilização da força de trabalho (desocupados + subocupados por insuficiência de horas + força de trabalho potencial).
- Nível de ocupação e taxa de participação na força de trabalho.
- Taxa de informalidade e rendimento médio real habitual.
- Saldo anual e estoque de empregos formais (CAGED / Novo CAGED e RAIS).

## Matriz de Eventos Globais e Catástrofes
Para cada evento global ou catástrofe analisada (ex.: crise da dívida europeia, fim do superciclo das commodities, pandemia de COVID-19, gargalos nas cadeias globais de suprimentos, guerra Rússia-Ucrânia, choques climáticos extremos como El Niño/La Niña e desastres de grande escala), classifique obrigatoriamente em 4 colunas:
1. **Evento / Catástrofe Comprovada** (data, escopo e fonte oficial/internacional).
2. **Canal de Transmissão Econômica** (comércio exterior, câmbio, juros globais, inflação de energia/alimentos, cadeias produtivas ou choque sanitário/climático).
3. **Reverberação no Brasil** (`Direta`, `Indireta` ou `Não comprovada / Predominantemente doméstica`).
4. **Evidência Empírica nos Dados** (indicador, período exato e fonte).

## Regras de Rigor
- Nunca afirmar causalidade direta sem citar estudo econômico, relatório institucional (Banco Central, IPEA, FMI, Banco Mundial, OIT, CEPAL) ou evidência empírica documentada.
- Deixar explícita a transição de regimes e quebras metodológicas entre 2010–2018 e 2019–2026.

## Arquivos de Apoio
- `scripts/extrair_serie_pnadc.py` — esqueleto de extração dos indicadores no BigQuery (Base dos Dados).
- `templates/MATRIZ_EVENTOS.md` — matriz de eventos com as 4 colunas obrigatórias.
- `templates/FICHA_DEFESA.md` — quadro de perguntas críticas para defesa em tela.
- `references/LINHA_DO_TEMPO.md` — marcos domésticos e externos.
