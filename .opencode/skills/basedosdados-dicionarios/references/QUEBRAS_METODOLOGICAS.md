# Quebras metodológicas das séries de trabalho

Nunca emende duas séries sem declarar a quebra. Este arquivo é a referência rápida;
as notas completas estão em `rag_corpus/dicionarios/`.

## 1. PNAD → PNAD Contínua (2012)

- **Antes:** PNAD anual, com questionário e período de referência diferentes.
- **Depois:** PNAD Contínua trimestral, com período de referência de 30 dias para
  procura de trabalho e 7 dias para trabalho.
- **Consequência:** taxas de desocupação não são diretamente comparáveis.
- **Fonte local:** `rag_corpus/dicionarios/ibge_nota_pnad_pme_pnadc.pdf`

## 2. PNAD Contínua: reponderação e calendário (2020–2021)

- A pandemia exigiu coleta remota e gerou notas técnicas específicas.
- Houve revisão da série de rendimentos.
- **Fonte local:** `ibge_nota_ponderacao.pdf`,
  `ibge_nota_harmonizacao_rendimentos.pdf`

## 3. CAGED → Novo CAGED (2020)

- **Antes:** CAGED, declaração mensal por estabelecimento, cobertura específica.
- **Depois:** Novo CAGED, com mudanças de cobertura e de formulário.
- **Consequência:** saldo de 2020 em diante não é diretamente comparável com
  2019 e anteriores.
- **Fonte local:** `rag_corpus/dicionarios/ibge_nota_caged_vs_pnadc.pdf`

## 4. CAGED ≠ PNAD Contínua (sempre)

| Dimensão | CAGED | PNAD Contínua |
| --- | --- | --- |
| Natureza | registro administrativo | pesquisa amostral domiciliar |
| Unidade | vínculo celetista declarado | pessoa ocupada/desocupada |
| Cobertura | formal, com regras de declaração | formal e informal |
| Frequência | mensal | trimestral |
| Estoque ou fluxo | fluxo | estoque |

**Regra:** comparar CAGED com PNAD-C exige conversão explícita e ressalva. O IBGE
recomenda não comparar diretamente.

## 5. RAIS: republicações e mudanças de layout

- A RAIS passa por republicações que alteram anos anteriores.
- A Base dos Dados registra o histórico em `bd_readme_rais.md`.
- A partir de 2023, a estrutura de arquivos e algumas colunas mudam.
- **Fonte local:** `rag_corpus/dicionarios/bd_readme_rais.md`,
  `bd_schema_rais.yml`

## 6. PIB municipal: revisão e defasagem

- A série é revisada periodicamente e tem defasagem de cerca de dois anos.
- Comparar PIB municipal de anos diferentes sem verificar a revisão vigente gera
  erro de nível, não de tendência.
- **2022–2023:** o IBGE divulgou apenas PIB e PIB per capita, sem a abertura do VAB
  por setor. A abertura setorial volta com a nova série do SCN (ano-base 2021),
  prevista para 2027. Não calcular produtividade setorial nesses anos.
- **Regra:** usar sempre a mesma revisão em todo o estudo.

## 7. Deflatores

- **IPCA:** inflação ao consumidor, adequado para rendimento do trabalho.
- **INPC:** usado em reajustes e pisos; foco em famílias de menor renda.
- **Deflator implícito do PIB:** adequado para produto e produtividade.
- **Regra:** declarar índice, período-base e se a deflação foi mensal ou anual.
  Nunca deflacionar duas séries com índices diferentes e compará-las como se fossem
  a mesma coisa.

## 8. 2026 é ano parcial

- PNAD-C trimestral: depende do trimestre disponível.
- RAIS: não há 2026 consolidado.
- CAGED: meses disponíveis até a data de extração.
- **Regra:** todo gráfico com 2026 deve ter marcação visual de parcial e nota de
  rodapé.
