# Proposta de implementação — Bloco 2 (território, produtividade e investimento)

**Sprint:** `programacao/bloco_2` — primeira sprint de código do estudo
**Escopo:** Bloco 2 da pesquisa (`pesquisa/01_blocos/BLOCO_2_TERRITORIO.md`)
**Data:** 17/11/2026 · **Versão:** 0.3 (proposta + config, SQL e decisões D1–D5)
**Depende de:** `pesquisa/00_protocolo/PROTOCOLO_PESQUISA.md` §4 (Bloco 2) e §9 (decisões D1–D4)

> Esta pasta implementa o **Bloco 2 da pesquisa**. A numeração da pasta acompanha o
> bloco, não a ordem de execução: a programação começa pelo bloco com maior dependência
> de dados municipais.

---

## 1. Objetivo da sprint

Produzir, de forma reprodutível, o painel municipal que sustenta o Bloco 2:

1. selecionar cidades segundo **critérios declarados** — PIB, população, vínculos e
   a combinação dos três, lado a lado;
2. calcular PIB per capita, composição do VAB e produtividade por vínculo formal;
3. medir concentração (top-N e HHI) do PIB e do emprego formal;
4. cruzar com comércio exterior e investimento, quando a fonte permitir;
5. entregar tabela pronta para tela, com fonte, ano-base e unidade em cada coluna.

**Fora do escopo desta sprint:** séries nacionais (Bloco 1), pauta comercial detalhada
(Bloco 3), matriz de eventos (Bloco 4) e qualquer gráfico de apresentação final.

---

## 2. Decisões registradas (17/11/2026)

| # | Decisão do usuário | Como o código trata |
| --- | --- | --- |
| D1 | PIB e população podem ser abordados em etapas diferentes **e também juntos** | `selecao.criterios` com `pib`, `populacao`, `vinculos`; ranking principal `combinado` = média dos percentis. Nenhum critério é descartado. |
| D2 | **As três opções**: 10, 20 e 50 cidades | `selecao.top_n: [10, 20, 50]`; `top_n_principal: 20` |
| D3 | 2026 é parcial | `recorte.incluir_ano_parcial: true` + coluna `ano_parcial`; nenhum dado de 2026 marcado como consolidado |
| D4 | Sugestão aceita: **IPCA** | `deflator.indice: IPCA`, série 433 do BCB SGS, aplicada a rendimento |
| D5 | **Municípios pequenos, rurais, periféricos e metrópoles** | unidade principal = município; RMs entram só como corte. `recortes_complementares` e `validacao.estratos_obrigatorios` garantem cobertura dos quatro estratos nas saídas |

O modo exploratório foi encerrado (`modo_exploratorio: false`): os rankings podem ser
publicados, desde que cada tabela traga critério, ano-base e a ressalva "vínculo ≠
pessoa ocupada".

**Como D1 muda a leitura:** o critério deixou de ser uma escolha única. Onde a
conclusão depende do recorte, a defesa em tela deve mostrar os rankings lado a lado e
explicitar qual deles foi usado em cada etapa. O ranking combinado não substitui os
individuais — ele é uma quarta coluna.

**Como D5 muda a leitura:** o ranking de "maiores cidades" continua existindo, mas não
pode ser a única saída. Os cortes complementares entram separadamente, para que a
análise não silencie municípios pequenos, rurais e periféricos. A definição operacional
de "pequeno" e "rural" ainda precisa vir de diretório oficial do IBGE — enquanto isso,
os cortes saem marcados como tal em `metadados.json`.

---

## 3. Etapa 0 — validação de dicionário (concluída em 17/11/2026)

Conforme a skill `basedosdados-dicionarios`, nenhuma coluna entra no pipeline sem ficha.

- [x] Confirmar os nomes exatos de tabela e coluna. Feito contra os modelos dbt do
      repositório público [`basedosdados/pipelines`](https://github.com/basedosdados/pipelines),
      que é a definição publicada das tabelas do BigQuery:
  - PIB municipal — `br_ibge_pib.municipio`, colunas `pib`, `va`, `va_agropecuaria`,
    `va_industria`, `va_servicos`, `va_adespss` (em reais; a staging vem em milhares).
  - População municipal — `br_ibge_populacao.municipio`, colunas `ano`, `sigla_uf`,
    `id_municipio`, `populacao`.
  - RAIS — `br_me_rais.microdados_vinculos`, colunas `ano`, `sigla_uf`, `id_municipio`,
    `vinculo_ativo_3112`, `valor_remuneracao_media` e **`cnae_2` (classe, 5 dígitos)**.
    A coluna `cnae_2_secao` **não existe**; a seção sai do diretório
    `br_bd_diretorios_brasil.cnae_2`, com `DISTINCT` obrigatório no join.
  - Comex — `br_me_comex_stat.municipio_exportacao` e `.municipio_importacao`.
    **Está na Base dos Dados**; o download do CSV do MDIC passou a ser apenas fallback.
  - BNDES — `br_bndes_desembolsos.mensal`, `valor_desembolsado`. Disponível, fora do
    escopo obrigatório desta sprint.
  - Novo CAGED — `br_me_caged.microdados_movimentacao`, cobertura 2020 em diante.
- [ ] Preencher uma `FICHA_VARIAVEL.md` por variável usada (próximo passo).
- [ ] Registrar o hash do layout usado em `rag_corpus/dicionarios/REGISTRO.csv`.

**Saída da etapa 0:** `programacao/bloco_2/dicionario_validado.csv` — 52 linhas,
8 tabelas, com `tabela, coluna, tipo, unidade, fonte, validado_em, origem_validacao,
observacao`.

---

## 4. Pipeline proposto

```text
[1] extrair      →  dados brutos (CSV/JSON) em pesquisa/03_dados/brutos/
[2] tratar       →  tipagem, códigos IBGE, deduplicação → pesquisa/03_dados/tratados/
[3] validar      →  testes de integridade (soma, cobertura, anos)
[4] indicadores  →  PIB per capita, produtividade, shares, HHI
[5] selecionar   →  ranking das N cidades pelo critério escolhido
[6] publicar     →  tabela final + metadados em pesquisa/02_saidas/
```

### 4.1 Extração

| Fonte | Consulta | Destino | Observação |
| --- | --- | --- | --- |
| PIB municipal | `sql/01_pib_municipal.sql` | `pib_municipal.csv` | 2010–2023; **2022–2023 sem VAB setorial** |
| População | `sql/02_populacao_municipal.sql` | `populacao_municipal.csv` | Censo 2022 + estimativas |
| RAIS | `sql/03_rais_municipal.sql` | `rais_municipal.csv` | filtro `vinculo_ativo_3112 = '1'`; saída com seção CNAE |
| Comex Stat | `sql/04_comex_municipal.sql` | `comex_municipal.csv` | **está na BD**; CSV do MDIC é fallback |
| BNDES | `br_bndes_desembolsos.mensal` | `bndes_municipio.csv` | disponível, opcional nesta sprint |

Cada arquivo `sql/` traz no cabeçalho a origem, as colunas validadas, as armadilhas
metodológicas e os testes que o resultado precisa passar.

Script base já existente: `.opencode/skills/territorio-produtividade-comercio/scripts/extrair_territorio.py`
(hoje imprime SQL e calcula ranking a partir de CSVs tratados). A sprint **estende** esse
script, sem duplicar lógica.

### 4.2 Tratamento

- `id_municipio` sempre como texto de 7 dígitos (nunca numérico: perde zero à esquerda).
- Nome do município entra apenas para exibição; a chave é o código IBGE.
- Nenhum `JOIN` por nome.
- Anos ausentes ficam ausentes — não interpolar.
- Valores monetários: guardar nominal e real em colunas separadas
  (`pib_nominal`, `pib_real_2026`), com o deflator declarado.

### 4.3 Validação (testes automatizados)

| Teste | Regra | Falha se |
| --- | --- | --- |
| Unicidade | 1 linha por `ano × id_municipio × secao_cnae` (com `'TOTAL'` na chave) | duplicata |
| Fechamento setorial | soma das seções = linha `TOTAL` | divergir |
| Cobertura | municípios do ranking têm PIB e RAIS no mesmo ano | faltar um dos dois |
| Soma | soma dos VAB setoriais ≈ VAB total (tolerância 1%) | divergir mais que 1% |
| Negativo | PIB, população e vínculos > 0 | valor ≤ 0 |
| Ano | nenhum dado de 2026 marcado como consolidado | `ano_parcial = false` em 2026 |
| Remuneração ausente | vínculos sem remuneração ≤ 5% | acima de 5% |

---

## 5. Indicadores e fórmulas

| Indicador | Fórmula | Unidade | Cuidado |
| --- | --- | --- | --- |
| PIB per capita | PIB / população | R$ por habitante | população do mesmo ano |
| Produtividade por vínculo formal | VAB / vínculos ativos RAIS | R$ por vínculo | **não é** produtividade do trabalho total |
| Share setorial | VAB setor / VAB total | % | indisponível em 2022–2023 |
| Remuneração média real | remuneração nominal deflacionada pelo IPCA | R$ de 2026 | deflator nacional aplicado a valor municipal |
| Concentração top-N | soma dos N maiores / total | % | N declarado |
| HHI | Σ (participação_i)² | índice 0–10.000 | usar participação em % |
| Saldo comercial municipal | exportação − importação | US$ | câmbio não entra aqui |

**Ressalva central, que precisa aparecer na tela:** a RAIS mede **vínculos formais**, não
pessoas ocupadas. Usar vínculos como denominador produz um indicador de
"VAB por vínculo formal", que superestima a produtividade em municípios com muita
informalidade. O texto do Bloco 2 deve dizer isso explicitamente, e não chamar o número
de "produtividade do trabalho".

---

## 6. Estrutura de arquivos da sprint

```text
programacao/bloco_2/
├── PROPOSTA_BLOCO_2.md          # este documento
├── config.yaml                  # recorte, critério, top-N, deflator, fontes
├── dicionario_validado.csv      # etapa 0: tabela × coluna, tipo, unidade, origem
├── sql/
│   ├── 01_pib_municipal.sql
│   ├── 02_populacao_municipal.sql
│   ├── 03_rais_municipal.sql     # município + seção CNAE (GROUPING SETS)
│   └── 04_comex_municipal.sql
├── scripts/
│   ├── extrair.py               # executa os SQL no BigQuery
│   ├── tratar.py                # tipagem, chaves, deduplicação
│   ├── validar.py               # testes da §4.3
│   └── indicadores.py           # fórmulas da §5
├── testes/
│   └── test_indicadores.py      # testes unitários das fórmulas
└── saidas/
    ├── painel_cidades.csv
    ├── ranking_cidades.csv
    └── metadados.json           # fonte, ano-base, hash, data de extração
```

**Status:** `config.yaml`, `dicionario_validado.csv` e os quatro SQL existem. `scripts/`,
`testes/` e `saidas/` são o trabalho restante da sprint.

`saidas/metadados.json` é o que permite responder em tela "de onde veio este número".

---

## 7. Critérios de aceite

- [ ] `python scripts/validar.py` retorna 0 e imprime a tabela de testes.
- [ ] Toda coluna usada nos SQL aparece em `dicionario_validado.csv`.
- [ ] Todo CSV de saída tem coluna de ano-base e de fonte.
- [ ] Nenhum ranking é gerado sem `criterios`, `ano_base` e `top_n` definidos no `config.yaml`.
- [ ] Os quatro rankings (pib, populacao, vinculos e combinado) são gerados lado a lado,
      para que a diferença entre critérios fique visível na defesa.
- [ ] Os três valores de `top_n` (10, 20 e 50) aparecem nas saídas com o recorte declarado.
- [ ] As saídas cobrem os quatro estratos de D5; a ausência de qualquer um falha a validação.
- [ ] 2026 aparece em toda série em que entra, com `ano_parcial = true`.
- [ ] O texto do bloco passa em `harness_check.py --strict`.
- [ ] A ressalva "vínculo ≠ pessoa ocupada" aparece no documento do bloco.

---

## 8. Riscos e limitações declaradas

| Risco | Impacto | Mitigação |
| --- | --- | --- |
| PIB municipal 2022–2023 sem VAB setorial | sem share e sem produtividade setorial | limitar análise setorial a 2021 |
| Defasagem do PIB municipal (~2 anos) | ranking "desatualizado" | declarar ano-base em toda tabela |
| Comex por sede do exportador | distorce cidades portuárias | nota metodológica obrigatória |
| Certificado TLS do Comex Stat expirado | download do CSV oficial falha | usar a Base dos Dados (já validado); no fallback, `curl -k` e registrar |
| Custo de varredura da RAIS (~700 M linhas) | cota do BigQuery | rodar ano a ano; tabela particionada por `ano` |
| Join CNAE sem `DISTINCT` | multiplica vínculos | dimensão de seção já deduplicada no SQL |
| RAIS cobre só formal | produtividade superestimada | renomear o indicador e ressalvar |
| Municípios de uma mesma RM | dupla contagem de commuting | não somar sem nota |
| Investimento (BNDES) por município | fonte ainda não validada | tratar como opcional na sprint |

---

## 9. Cronograma da sprint

| Bloco de tempo | Atividade | Entrega |
| --- | --- | --- |
| 0h–2h | etapa 0: dicionário e fichas de variável | `dicionario_validado.csv` |
| 2h–4h | extração e tratamento | brutos + tratados |
| 4h–5h | validação | relatório de testes |
| 5h–7h | indicadores e rankings | `painel_cidades.csv` |
| 7h–8h | metadados, revisão e texto do bloco | `BLOCO_2_TERRITORIO.md` |

---

## 10. Estado das perguntas

Encerradas pelas respostas de 17/11/2026:

1. ~~Critério definitivo: população, PIB ou vínculos?~~ → os três, mais a combinação (D1).
2. ~~10, 20 ou 50 cidades?~~ → as três opções (D2).
3. ~~Municípios ou regiões metropolitanas?~~ → município, com RMs como corte (D5).
4. ~~2026 entra?~~ → entra, marcado como parcial (D3).

Ainda em aberto, mas **não bloqueiam a sprint** (resposta técnica, não de escopo):

5. Investimento: BNDES fica de fora do obrigatório desta sprint; a tabela já está
   validada para o Bloco 3.
6. Comparação na tela: o painel compara cidades entre si; a média nacional entra como
   linha de referência, não como critério de seleção.
7. Definição oficial dos estratos "pequeno", "rural" e "periférico" no IBGE — necessária
   para rotular os cortes de D5 sem palpite.
