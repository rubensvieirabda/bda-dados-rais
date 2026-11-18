# RAIS 2022 · Mercado de trabalho formal de Belo Horizonte

![R](https://img.shields.io/badge/R-4.6-276DC3?logo=r&logoColor=white)
![tidyverse](https://img.shields.io/badge/tidyverse-2.0-1A162D?logo=tidyverse&logoColor=white)
![Base dos Dados](https://img.shields.io/badge/dados-Base%20dos%20Dados-0B6E4F)
![RAIS](https://img.shields.io/badge/RAIS-2022-1351B4)
![status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![licença](https://img.shields.io/badge/licen%C3%A7a-MIT%20%2B%20CC%20BY%204.0-green)

Projeto didático que reproduz, em R, uma análise exploratória dos microdados da RAIS
(Relação Anual de Informações Sociais) para Belo Horizonte em 2022. Os dados vêm da
tabela `basedosdados.br_me_rais.microdados_vinculos`, no BigQuery, e o tratamento usa
os pacotes do Tidyverse.

O script foi transcrito por OCR das imagens de uma videoaula e adaptado para código
executável. O objetivo aqui é menos o resultado estatístico e mais o caminho:
consulta SQL → exportação em CSV → importação → exploração inicial.

> **Atenção antes de usar os números**
> O arquivo versionado é um recorte de 1.000 linhas, sem critério de amostragem
> declarado. Ele serve para demonstrar o fluxo de trabalho e **não** representa a
> população de vínculos formais de Belo Horizonte. Nenhuma conclusão sobre o mercado
> de trabalho do município deve sair deste recorte.

## Sobre os dados

| Item | Descrição |
| --- | --- |
| Fonte original | Ministério do Trabalho e Emprego (MTE) — RAIS |
| Acesso | Base dos Dados, tabela `basedosdados.br_me_rais.microdados_vinculos` |
| Recorte | `ano = 2022` e `id_municipio = 3106200` (Belo Horizonte, MG) |
| Variáveis | `valor_remuneracao_media`, `raca_cor`, `sexo`, `grau_instrucao_apos_2005` |
| Nível de observação | vínculo de trabalho (uma linha = um vínculo) |
| Registros no arquivo | 1.000 |
| Valores monetários | remuneração média mensal em R$ nominais, sem deflação |

O código `3106200` é o identificador de município do IBGE com sete dígitos. Vale
lembrar que, na RAIS, `id_municipio` se refere ao município do estabelecimento
empregador, e não ao local de residência do trabalhador.

## Estrutura do repositório

```text
bda-dados-rais/
├── bda-dados-rais.Rproj          # projeto do RStudio
├── README.md
├── LICENSE                       # MIT (código)
├── LICENSE-CONTENT.md            # CC BY 4.0 (texto e documentação)
├── analise_rais_tidyverse.gt.R   # roteiro completo: dicionário → gráficos → GT → saídas
├── rais_2022_bh.csv              # opcional, não versionado: entrada local de dados reais
├── saidas/                       # gerado pelo script, não versionado
├── .opencode/                    # skills, agente de pesquisa e permissões
├── rag_corpus/                   # corpus local para RAG (dicionários, oficiais, imprensa, acadêmico)
├── pesquisa/                     # protocolo, blocos, dados tratados e fichas de defesa
├── programacao/                  # uma pasta por bloco: config, SQL e propostas
└── landing_page/                 # página de vendas do curso e referências
```

A camada `.opencode/`, `rag_corpus/` e `pesquisa/` sustenta o estudo descrito em
[`pesquisa/00_protocolo/PROTOCOLO_PESQUISA.md`](pesquisa/00_protocolo/PROTOCOLO_PESQUISA.md).
O README deste repositório continua sendo a porta de entrada do projeto de RAIS; o
protocolo é a porta de entrada da pesquisa comparativa 2010–2026.

`programacao/` guarda o que é executável: cada bloco tem proposta, `config.yaml` e as
consultas SQL com o dicionário validado no cabeçalho. `landing_page/` é material de
divulgação do curso, separado da pesquisa para não misturar as duas coisas.

O `dicionario_bairros_rais.csv` foi baixado junto com os dados, mas cobre apenas as
colunas `bairros_fortaleza`, `bairros_rj` e `bairros_sp` da tabela de vínculos. Ou
seja: ele **não** traz os rótulos de `raca_cor`, `sexo` ou `grau_instrucao_apos_2005`,
que estão documentados na seção [Dicionário de códigos](#dicionário-de-códigos).

## Metodologia

### 1. Extração

A consulta executada no Base dos Dados foi:

```sql
SELECT valor_remuneracao_media, raca_cor, sexo, grau_instrucao_apos_2005
FROM `basedosdados.br_me_rais.microdados_vinculos`
WHERE ano = 2022 AND id_municipio = 3106200
```

O resultado foi exportado para `rais_2022_bh.csv`. O script guarda a mesma consulta na
variável `sql_rais`, mas ela é apenas documentação: a execução parte do CSV já
exportado.

### 2. Importação e exploração

O script carrega o `tidyverse`, lê o CSV com `read_csv()` e aplica três funções de
inspeção: `head()` (primeiras linhas), `glimpse()` (estrutura e tipos) e `summary()`
(estatísticas descritivas). O `readr` interpreta as quatro colunas como `double`,
inclusive os códigos numéricos.

Não há, nesta etapa:

- recodificação dos códigos para rótulos;
- filtro de vínculos ativos em 31/12 (`vinculo_ativo_3112`, coluna que nem chegou a ser
  extraída);
- remoção de duplicatas ou tratamento de outliers;
- deflação dos valores;
- qualquer teste de hipótese ou modelo.

### 3. Decisões e limitações

- **O recorte não é uma amostra probabilística.** São 1.000 linhas de uma exportação,
  sem sorteio declarado. As estatísticas abaixo descrevem apenas o arquivo.
- **Vínculo não é pessoa.** Um mesmo trabalhador pode ter mais de um vínculo no ano, e
  o arquivo inclui vínculos encerrados durante 2022. Para medir estoque de emprego, a
  RAIS recomenda filtrar `vinculo_ativo_3112 = 1`.
- **Cobertura.** A RAIS cobre apenas o emprego formal; trabalhadores informais e
  autônomos não aparecem.
- **Renda nominal.** Os valores não foram corrigidos pela inflação.
- **Anonimização.** Os microdados públicos não trazem CNPJ nem CPF, o que impede
  acompanhar vínculos ou empresas ao longo do tempo.
- **Proveniência.** O CSV não carrega as colunas `ano` e `id_municipio`; o recorte é
  identificado pelo nome do arquivo e pela consulta registrada no script.

## Dicionário de códigos

Rótulos conforme o Manual de Orientação da RAIS (ano-base 2022) e a planilha de layout
dos microdados `RAIS_vinculos_layout2020.xls`, ambas publicadas pelo MTE.

**`sexo`**

| Código | Rótulo |
| ---: | --- |
| 1 | Masculino |
| 2 | Feminino |
| -1 | Ignorado |

**`raca_cor`**

| Código | Rótulo |
| ---: | --- |
| 1 | Indígena |
| 2 | Branca |
| 4 | Preta |
| 6 | Amarela |
| 8 | Parda |
| 9 | Não informado |
| -1 | Ignorado |

**`grau_instrucao_apos_2005`**

| Código | Rótulo |
| ---: | --- |
| 1 | Analfabeto |
| 2 | Até o 5º ano incompleto do Ensino Fundamental |
| 3 | 5º ano completo do Ensino Fundamental |
| 4 | Do 6º ao 9º ano do Ensino Fundamental incompleto |
| 5 | Ensino Fundamental completo |
| 6 | Ensino Médio incompleto |
| 7 | Ensino Médio completo |
| 8 | Educação Superior incompleta |
| 9 | Educação Superior completa |
| 10 | Mestrado completo |
| 11 | Doutorado completo |
| -1 | Ignorado |

## Como reproduzir

Pré-requisitos: R (testado na versão 4.6.2), `tidyverse` (2.0.0) e `gt` (1.4.0).
Sem `gt`, o script roda e gera gráficos e CSV, mas pula as tabelas formatadas.

```bash
git clone git@github.com:rubensvieirabda/bda-dados-rais.git
cd bda-dados-rais
Rscript -e 'install.packages(c("tidyverse", "gt"))'
Rscript analise_rais_tidyverse.gt.R
```

No RStudio, abra o `bda-dados-rais.Rproj` e rode o script com o diretório de trabalho
na raiz do projeto.

O script tem dois modos:

- **Com `rais_2022_bh.csv` na raiz:** usa os dados do arquivo. As saídas em `saidas/`
  carregam `origem_dados = rais_2022_bh.csv`.
- **Sem o CSV (padrão):** gera 1.000 linhas **sintéticas** só para o script rodar.
  Todo gráfico, tabela e metadado sai rotulado como `DADOS SINTÉTICOS` /
  `sintetico: true`. Nada disso pode ser publicado como dado real.

O arquivo `rais_2022_bh.csv` e o diretório `saidas/` estão no `.gitignore` justamente
para não misturar dados de teste ou derivados com o código versionado.

Para gerar o CSV a partir da fonte, é preciso uma conta no Google Cloud com o BigQuery
habilitado e o pacote `basedosdados` (ou a interface web do Base dos Dados). A consulta
está na seção [Extração](#1-extração). Recomenda-se extrair o ano completo, sem o
limite de 1.000 linhas.

## O que o recorte mostra

Estatísticas descritivas de `valor_remuneracao_media` (R$, formatação brasileira; no
CSV o separador decimal é o ponto):

| Estatística | Valor |
| --- | ---: |
| Mínimo | 13,45 |
| 1º quartil | 14.628,69 |
| Mediana | 17.297,67 |
| Média | 18.943,85 |
| 3º quartil | 22.116,39 |
| Máximo | 92.444,08 |
| Desvio-padrão | 8.060,14 |

Composição do recorte por `sexo`:

| Código | Rótulo | Vínculos |
| ---: | --- | ---: |
| 1 | Masculino | 731 |
| 2 | Feminino | 269 |

Composição por `raca_cor`:

| Código | Rótulo | Vínculos |
| ---: | --- | ---: |
| 1 | Indígena | 3 |
| 2 | Branca | 563 |
| 4 | Preta | 24 |
| 6 | Amarela | 9 |
| 8 | Parda | 388 |
| 9 | Não informado | 13 |

Composição por `grau_instrucao_apos_2005`:

| Código | Rótulo | Vínculos |
| ---: | --- | ---: |
| 4 | Do 6º ao 9º ano do EF incompleto | 1 |
| 5 | Ensino Fundamental completo | 8 |
| 6 | Ensino Médio incompleto | 5 |
| 7 | Ensino Médio completo | 116 |
| 8 | Educação Superior incompleta | 33 |
| 9 | Educação Superior completa | 802 |
| 10 | Mestrado completo | 24 |
| 11 | Doutorado completo | 11 |

Os códigos 1, 2 e 3 de escolaridade não aparecem no arquivo. As contagens acima são
úteis para conferir a importação, não para descrever Belo Horizonte.

## Roadmap

- [x] Extração da consulta e exportação em CSV
- [x] Importação e exploração inicial no Tidyverse
- [x] Recodificar os códigos para rótulos legíveis (mapas do layout RAIS 2020, com `.default`)
- [x] Filtrar remunerações inválidas com regra declarada (quantil 99,9%)
- [ ] Filtrar vínculos ativos em 31/12 (`vinculo_ativo_3112 = 1`)
- [ ] Refazer a extração sem o limite de 1.000 linhas
- [x] Montar tabelas com o pacote `gt`
- [x] Gráficos de remuneração por sexo, raça/cor e sexo × raça/cor
- [x] Saídas versionáveis em `saidas/` com `metadados.json`
- [ ] Implementar `programacao/bloco_2/scripts/` (extrair, tratar, validar, indicadores)

## Fontes

Todas as fontes foram consultadas em 17/11/2026.

1. Base dos Dados — conjunto RAIS, tabela `microdados_vinculos`:
   <https://basedosdados.org/dataset/rais?table=microdados_vinculos>
2. Base dos Dados — guia do conjunto RAIS (limitações, dados parciais, vínculos ativos):
   <https://github.com/basedosdados/website/blob/main/next/content/userGuide/pt/br-me-rais.md>
3. Base dos Dados — `schema.yml` com a descrição das colunas:
   <https://github.com/basedosdados/pipelines/blob/main/models/br_me_rais/schema.yml>
4. Base dos Dados — README de tratamento da RAIS (dicionário, republicações, testes):
   <https://github.com/basedosdados/pipelines/blob/main/models/br_me_rais/README.md>
5. MTE — Manual de Orientação da RAIS, ano-base 2022 (códigos de raça/cor e
   escolaridade): <https://www.rais.gov.br/sitio/rais_ftp/ManualRAIS2022.pdf>
6. MTE — pasta de layouts dos microdados de vínculos no FTP, arquivo
   `RAIS_vinculos_layout2020.xls` (códigos de sexo, raça/cor e escolaridade):
   <ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/Layouts/>
7. MTE — Microdados RAIS e CAGED:
   <https://www.gov.br/trabalho-e-emprego/pt-br/assuntos/estatisticas-trabalho/microdados-rais-e-caged>
8. IBGE — códigos de municípios: <https://www.ibge.gov.br/explica/codigos-dos-municipios.php>
9. IBGE — API de localidades, município 3106200:
   <https://servicodados.ibge.gov.br/api/v1/localidades/municipios/3106200>

## Licença

Licença dupla, separando código de conteúdo:

- **Código** (`.R`, `.py` e scripts) — [MIT](LICENSE).
- **Texto, tabelas, gráficos e documentação** — [CC BY 4.0](LICENSE-CONTENT.md).

Em resumo: você pode usar, adaptar e redistribuir, inclusive comercialmente, desde
que mantenha o aviso de copyright no código e dê a atribuição no conteúdo,
indicando se houve mudanças.

Os **dados não são licenciados por este repositório**. A RAIS é produzida pelo MTE e
o acesso via Base dos Dados segue os termos da plataforma e da fonte original.
Confira essas condições antes de redistribuir os microdados.
