# Fontes de território, produtividade e comércio

Links oficiais para os blocos 2 e 3. Confirme a disponibilidade antes de citar.

> **Atenção:** o portal do IBGE responde `403` a requisições automatizadas
> (`curl`, `urllib`). Os links abaixo foram conferidos em navegador e são válidos;
> para baixar arquivos, use o FTP do IBGE (`https://ftp.ibge.gov.br/`), que aceita
> download direto.

## População e território

| Fonte | O que fornece | URL |
| --- | --- | --- |
| IBGE — Cidades e Estados | população estimada, área, código do município | <https://www.ibge.gov.br/cidades-e-estados> |
| IBGE — API de localidades | município, microrregião, UF, região | <https://servicodados.ibge.gov.br/api/v1/localidades/municipios/3106200> |
| IBGE — Censo 2022 | população residente por município | <https://www.ibge.gov.br/estatisticas/sociais/populacao/22827-censo-demografico-2022.html> |
| IBGE — Áreas territoriais | área oficial dos municípios | <https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/15761-areas-dos-municipios.html> |

## Produto e produtividade

| Fonte | O que fornece | URL |
| --- | --- | --- |
| IBGE — PIB dos Municípios | PIB, VAB por setor, defasagem de ~2 anos | <https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9088-produto-interno-bruto-dos-municipios.html> |
| IBGE — Contas Nacionais Trimestrais | PIB trimestral, VAB setorial | <https://www.ibge.gov.br/estatisticas/economicas/contas-nacionais/9300-contas-nacionais-trimestrais.html> |
| IBGE — PIA | produção, pessoal ocupado, custos industriais | <https://www.ibge.gov.br/estatisticas/economicas/industria/9042-pesquisa-industrial-anual.html> |
| IBGE — PAS | serviços, receita e pessoal ocupado | <https://www.ibge.gov.br/estatisticas/economicas/servicos/9026-pesquisa-anual-de-servicos.html> |
| IPEADATA | séries macro consolidadas | <http://www.ipeadata.gov.br/> |
| BCB — SGS | séries de juros, câmbio, atividade | <https://www.bcb.gov.br/estatisticas/txjuros> |

## Emprego e renda no território

| Fonte | O que fornece | URL |
| --- | --- | --- |
| Base dos Dados — RAIS | vínculos formais por município | <https://basedosdados.org/dataset/rais?table=microdados_vinculos> |
| Base dos Dados — Novo CAGED | fluxo mensal por município | <https://basedosdados.org/dataset/br-me-caged> |
| IBGE — PNAD Contínua | desocupação, ocupação, rendimento por UF | <https://www.ibge.gov.br/estatisticas/sociais/trabalho/17270-pnad-continua.html> |

## Comércio exterior

| Fonte | O que fornece | URL |
| --- | --- | --- |
| Comex Stat / MDIC | exportação e importação por município, produto (SH4) e parceiro | <https://comexstat.mdic.gov.br/pt/home> |
| MDIC — séries históricas | séries anuais consolidadas | <https://www.gov.br/mdic/pt-br/assuntos/comercio-exterior/estatisticas> |
| Observatório de Complexidade Econômica | índice de complexidade, pauta | <https://oec.world/pt/> |
| OMC — Statistics | comércio internacional comparado | <https://www.wto.org/english/res_e/statis_e/statis_e.htm> |
| UN Comtrade | comércio bilateral detalhado | <https://comtradeplus.un.org/> |

## Investimento

| Fonte | O que fornece | URL |
| --- | --- | --- |
| BNDES — desembolsos | investimento financiado por setor e região | <https://www.bndes.gov.br/wps/portal/site/home/transparencia/estatisticas-desempenho> |
| BNDES — Biblioteca Digital | estudos setoriais | <https://web.bndes.gov.br/bib/jspui/> |

---

## Regras de uso

- **PIB municipal tem defasagem longa.** Nunca apresente como "dado de 2026".
- **PIB municipal 2022–2023 não tem abertura setorial.** O IBGE informa que, nessas
  edições, só PIB e PIB per capita foram divulgados; o VAB por agropecuária,
  indústria e serviços volta após a nova série do SCN (ano-base 2021), prevista para
  2027. Não calcule produtividade setorial nesses anos.
- **Produtividade é razão.** Declare numerador e denominador.
- **Comex por município** depende do endereço do estabelecimento exportador, não da
  origem física do produto. Isso distorce cidades portuárias e sedes de tradings.
- **Rankings** seguem as regras de `templates/TABELA_CIDADES.md`.
