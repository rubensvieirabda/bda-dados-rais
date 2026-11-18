# Protocolo de pesquisa — Emprego, choques globais e território no Brasil (2010–2026)

**Versão:** 1.0 · **Data:** 17/11/2026
**Responsável:** pesquisador-emprego (agente `pesquisador-emprego`)
**Status:** bloco 0 concluído (infraestrutura). Blocos 1–4 em aberto. Análise de dados aprofundada na Etapa 2.

---

## 1. Pergunta central

Como o mercado de trabalho brasileiro se comportou nos períodos **2010–2018** e
**2019–2026**, e em que medida os choques globais e as catástrofes comprovadas desse
intervalo explicam as variações de emprego, desemprego, produtividade e comércio —
separando o que é choque externo do que é dinâmica doméstica?

Perguntas derivadas, uma por bloco:

| # | Pergunta | Bloco |
| --- | --- | --- |
| P1 | Quais foram os maiores e menores patamares de emprego e desemprego em cada período, e quando ocorreram? | 1 |
| P2 | Como esses patamares se distribuem entre as maiores cidades e regiões, e como se relacionam com produtividade e investimento? | 2 |
| P3 | Quais forças comerciais ganharam e perderam peso no período? | 3 |
| P4 | Quais choques globais e catástrofes comprovadas têm canal de transmissão identificável para o Brasil, e quais não têm? | 4 |
| P5 | Qual narrativa única integra P1–P4 com evidência suficiente para defesa em tela? | 5 |

---

## 2. Recorte e justificativa da divisão 2010–2018 / 2019–2026

A divisão não é arbitrária, mas também não deve ser tratada como fato estabelecido:
ela é uma **hipótese de mudança de regime** a ser testada, não um pressuposto.

- **2010–2018** — recuperação pós-crise de 2008, auge do ciclo de commodities,
  deterioração fiscal, recessão de 2014–2016 e recuperação lenta até 2018. O período
  termina com o mercado de trabalho ainda abaixo do nível de 2013–2014.
- **2019–2026** — pré-pandemia, choque sanitário de 2020, recomposição do emprego
  informal e do trabalho por conta própria, choque inflacionário global de 2021–2022,
  aperto monetário, e a partir de 2023 um mercado de trabalho formal aquecido
  convivendo com juros altos. 2026 é **ano incompleto** e entra apenas como
  parcial, sempre identificado.
- A fronteira em 2019 também coincide com a transição do **CAGED antigo** para o
  **Novo CAGED** (2020), o que reforça a necessidade de declarar a quebra.

> Regra: nenhuma afirmação de "mudança de regime" entra na narrativa sem teste
> estatístico ou, no mínimo, comparação explícita de médias, amplitudes e pontos de
> inflexão entre os dois períodos.

---

## 3. Unidades de análise e fontes por unidade

| Unidade | Uso | Fonte primária | Frequência | Defasagem típica |
| --- | --- | --- | --- | --- |
| País | Ciclo de emprego e desemprego | IBGE/PNAD Contínua | trimestral | ~2 meses |
| País | Estoque de vínculos formais | MTE/RAIS | anual (31/12) | ~12–18 meses |
| País | Fluxo de admissões e desligamentos | MTE/CAGED e Novo CAGED | mensal | ~1 mês |
| UF | Idem, recorte estadual | PNAD-C, RAIS, CAGED | idem | idem |
| Município | Estoque formal, remuneração, composição | RAIS | anual | ~12–18 meses |
| Município | PIB, VAB setorial, população | IBGE (PIB municipal) | anual | ~24 meses |
| Município/UF | Exportação e importação | MDIC/Comex Stat | mensal | ~1 mês |
| Município | Comércio e serviços | IBGE/PMC e PMS | mensal | ~2 meses |
| País | Preços, câmbio, juros, atividade | BCB (SGS, Focus, IBC-Br) | mensal/diário | ~1 mês |
| Internacional | Comparação e choques | Banco Mundial, FMI, OIT, CEPAL | anual | variável |

**Regra de ouro:** toda tabela declara unidade, fonte, período e defasagem. Dado
municipal nunca é apresentado como se fosse do ano corrente.

---

## 4. Blocos de trabalho

### Bloco 1 — Séries, tendências e os extremos do emprego (2010–2026)

**Entrega:** série consolidada com os indicadores abaixo, tabela de extremos (máximos
e mínimos) por período e gráfico de trajetória.

Indicadores obrigatórios — não usar apenas a taxa de desocupação:

1. Taxa de desocupação (PNAD-C).
2. Taxa composta de subutilização da força de trabalho.
3. Nível de ocupação (ocupados / população em idade de trabalhar).
4. Taxa de participação na força de trabalho.
5. Taxa de informalidade.
6. Rendimento médio real habitual (deflacionado pelo IPCA).
7. Saldo anual e estoque de empregos formais (CAGED/Novo CAGED e RAIS).
8. Massa salarial real (RAIS: remuneração × vínculos).

**Método:** para cada indicador, identificar máximos e mínimos locais e globais,
datas exatas e duração. Comparar médias dos dois períodos com intervalo de confiança
e declarar se a diferença é ou não significativa. Nenhuma série cross-era sem nota
de quebra.

**Aceite:** cada número da entrega rastreável a uma consulta registrada e a um
arquivo em `pesquisa/03_dados/tratados/`.

### Bloco 2 — Geografia: maiores cidades, produtividade e investimento

**Entrega:** ranking de cidades com critério declarado, painel de produtividade e
mapa de polos de investimento.

**Decisão pendente (ver §9):** critério de "maiores cidades" — população, PIB
municipal ou estoque de vínculos formais. O critério escolhido vale para todo o
estudo.

**Métricas padronizadas:**

- PIB per capita e VAB por setor (agropecuária, indústria, serviços).
- Produtividade aparente do trabalho = VAB / pessoal ocupado.
- Estoque de vínculos formais e remuneração média (RAIS).
- Fluxos de investimento anunciados/executados (BNDES, bancos de desenvolvimento,
  relatórios estaduais), sempre com ano e unidade.
- Exportações e importações por município/UF (Comex Stat).

**Aceite:** todo ranking informa critério, ano-base, unidade e fonte. Proibido
ranking sem esses quatro campos.

### Bloco 3 — Forças comerciais

**Entrega:** matriz de participação por produto e parceiro, saldo comercial e
evolução da pauta.

- Pauta exportadora e importadora por produto (SH4) e parceiro.
- Índice de complexidade econômica (se disponível via Observatório de Complexidade
  Econômica — declarar fonte e versão).
- Abertura comercial (comércio % do PIB) e termos de troca.
- Comércio varejista e serviços (PMC/PMS) como proxy de demanda interna.

### Bloco 4 — Matriz de choques globais e catástrofes

**Entrega:** `MATRIZ_EVENTOS.md` preenchida, com as quatro colunas obrigatórias
(evento, canal, reverberação, evidência).

Candidatos a evento, todos a confirmar com fonte antes de entrar:

| Período | Evento candidato | Natureza |
| --- | --- | --- |
| 2010–2012 | Crise da dívida soberana na zona do euro | financeiro |
| 2011–2014 | Fim do superciclo de commodities | comercial |
| 2014–2016 | Queda do preço do petróleo | comercial/financeiro |
| 2015–2016 | El Niño forte | climático |
| 2018 | Guerra comercial EUA–China | comercial |
| 2020–2021 | Pandemia de COVID-19 | sanitário |
| 2021–2022 | Gargalos globais de suprimentos e inflação | logístico/inflacionário |
| 2022 | Guerra Rússia–Ucrânia | energético/alimentos |
| 2022–2023 | Aperto monetário global | financeiro |
| 2023–2024 | El Niño e enchentes no Rio Grande do Sul | climático |
| 2025–2026 | Choque tarifário e incerteza comercial | comercial |

**Regra de causalidade:** para cada evento, preencher obrigatoriamente
(a) canal de transmissão, (b) evidência empírica no dado brasileiro, (c) contraprova
— o que se esperaria observar se o canal fosse real, e (d) confundidores domésticos.
Sem (a)–(d), o evento é classificado como **"não comprovado"**.

### Bloco 5 — Síntese e defesa em tela

**Entrega:** narrativa única em 5 atos, uma ficha de defesa por afirmação crítica e
roteiro de 10 minutos.

Estrutura narrativa proposta:

1. O Brasil chegou a 2010 em alta e perdeu tração antes do choque externo.
2. 2014–2016 é, sobretudo, uma crise doméstica com gatilho externo.
3. 2020 é o único choque verdadeiramente exógeno e simétrico do período.
4. 2021–2024: o emprego formal reage, mas a qualidade e a produtividade não.
5. O território concentra ganhos e perdas: não há "mercado de trabalho brasileiro",
   há vários.

Cada ato precisa de pelo menos uma evidência de Nível 1 e uma de Nível 2.

---

## 5. Hierarquia de evidência e etiquetagem

| Nível | O que é | Exemplos |
| --- | --- | --- |
| **1** | Dado primário oficial | IBGE, MTE, BCB, MDIC, Base dos Dados (espelho) |
| **2** | Literatura científica e organismos multilaterais | IPEA, FMI, Banco Mundial, OIT, CEPAL, artigos com revisão por pares |
| **3** | Imprensa especializada | CNN Brasil, Reuters, Valor, FT, Bloomberg |

Formato da tag: `[Fonte | Ano/Período | Nível N]`.

Regras:

- Imprensa (Nível 3) serve para **cronologia de eventos**, nunca para sustentar
  número estatístico.
- Toda afirmação causal exige Nível 1 (evidência) **e** Nível 2 (interpretação).
- "Não há evidência" ≠ "há evidência de que não houve". A redação deve distinguir.

---

## 6. Quebras metodológicas que precisam ser declaradas

| Quebra | Quando | Consequência |
| --- | --- | --- |
| PNAD antiga → PNAD Contínua | 2012 | séries de desemprego não são diretamente comparáveis |
| PNAD Contínua trimestral: mudança de calendário e reponderação | 2020–2021 | comparar com nota técnica do IBGE |
| CAGED antigo → Novo CAGED | 2020 | mudança de cobertura e de prestação de informação |
| RAIS: republicações e mudança de layout | 2018–2023 | conferir README da Base dos Dados antes de emendar anos |
| PIB municipal: revisão da série | periódica | usar a mesma revisão em todo o estudo |
| PIB municipal 2022–2023 sem abertura setorial | 2022–2023 | só PIB e PIB per capita; VAB setorial volta com a nova série do SCN (ano-base 2021), prevista para 2027 |
| Deflatores | — | declarar índice (IPCA), período-base e metodologia de deflação |

Fonte de apoio local: `rag_corpus/dicionarios/ibge_nota_caged_vs_pnadc.pdf`,
`ibge_nota_pnad_pme_pnadc.pdf`, `bd_readme_rais.md`.

---

## 7. Arquitetura do RAG e do harness

```text
rag_corpus/
├── dicionarios/   # layouts, notas metodológicas, schema (Nível 1)
├── oficiais/      # notas técnicas, boletins, relatórios (Nível 1–2)
├── imprensa/      # reportagens datadas (Nível 3)
├── academico/     # artigos e working papers (Nível 2)
└── .indice/       # índice BM25 gerado por rag_ingest.py
```

Fluxo:

1. `fontes.csv` registra toda fonte com URL, destino, nível e data.
2. `baixar_fontes.py` baixa, detecta HTML de erro e grava `.meta.json` com hash.
3. `validar_dicionario.py` confirma que o arquivo é o que diz ser.
4. `rag_ingest.py` indexa o corpus (PDF, MD, YML, CSV).
5. `rag_query.py` recupera trechos com caminho e nível de evidência.
6. `harness_check.py` audita o texto final: tags, parágrafos numéricos sem citação e
   fontes citadas fora do `fontes.csv`.

**Limitação declarada:** o índice é BM25 lexical, não semântico. Consultas com
sinônimos distantes podem falhar. Nesses casos, o agente deve declarar
"sem fonte no corpus" em vez de improvisar.

---

## 8. Cronograma

| Etapa | Data | Entrega |
| --- | --- | --- |
| 0. Infraestrutura | 17/11/2026 | skills, agente, corpus inicial, índice, protocolo |
| 1. Séries e extremos | 18/11/2026 | Bloco 1 + dados tratados |
| 2. Território | 18–19/11/2026 | Bloco 2 + ranking |
| 3. Comércio | 19/11/2026 | Bloco 3 |
| 4. Matriz de choques | 20/11/2026 | Bloco 4 + fichas de defesa |
| 5. Síntese | 21/11/2026 | Bloco 5 + roteiro de tela |

A Etapa 2 (análise de dados com metodologias adicionais) começa em 18/11/2026 e
inclui: decomposição de séries, sazonalidade, quebras estruturais (Bai–Perron),
diferenças em diferenças para eventos com grupo de comparação, e análise de
cointegração para comércio e emprego.

---

## 9. Decisões pendentes

| # | Decisão | Opções | Impacto |
| --- | --- | --- | --- |
| D1 | Critério de "maiores cidades" | população (IBGE) · PIB municipal · estoque RAIS | define o Bloco 2 inteiro |
| D2 | Quantas cidades | 10 · 20 · 50 | custo de extração e legibilidade |
| D3 | Tratamento de 2026 | excluir · incluir como parcial | narrativa do fim do período |
| D4 | Deflator | IPCA · INPC · deflator implícito do PIB | rendimento real |
| D5 | Licença do repositório | MIT + CC BY 4.0 · outra | redistribuição |

Enquanto D1–D4 não forem respondidas, o Bloco 2 fica em modo exploratório e nenhum
ranking é publicado.

---

## 10. Definição de pronto (por bloco)

Um bloco só é considerado concluído quando:

- [ ] todos os números têm consulta registrada e arquivo de saída;
- [ ] todas as afirmações têm tag `[Fonte | Período | Nível]`;
- [ ] `harness_check.py` roda sem tags malformadas;
- [ ] quebras metodológicas estão declaradas;
- [ ] há uma ficha de defesa por afirmação crítica;
- [ ] limitações estão escritas em linguagem simples, sem esconder o problema.
