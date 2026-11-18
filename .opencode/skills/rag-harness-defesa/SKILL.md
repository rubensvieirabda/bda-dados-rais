---
name: rag-harness-defesa
description: Aplica o protocolo RAG e o harness de auditoria de fontes, metodologias e referencial acadêmico para sustentar apresentações e defesas técnicas em tela.
---

## Objetivo
Garantir que todo dado, gráfico, afirmação histórica ou argumento apresentado em tela seja 100% auditável, rastreável e respaldado por fontes oficiais, imprensa de referência e literatura científica.

## Arquitetura do Corpus Local (`./rag_corpus/`)
- `./rag_corpus/dicionarios/`: dicionários de variáveis e layouts oficiais (Base dos Dados, IBGE, MTE).
- `./rag_corpus/oficiais/`: notas metodológicas, boletins e séries (IBGE, BCB, IPEA, MDIC, OIT, FMI, Banco Mundial).
- `./rag_corpus/imprensa/`: reportagens datadas e verificadas (CNN Brasil, Valor Econômico, Reuters, Financial Times, Bloomberg) usadas apenas para contextualização factual de eventos.
- `./rag_corpus/academico/`: artigos revisados por pares, working papers (IPEA, NBER, BCB) e livros de referência com citação completa (Autor, Ano, Título, Periódico/Editora, DOI/URL).

## Regras do Harness de Validação
1. **Rastreabilidade Total**: Toda afirmação factual ou numérica deve carregar a tag `[Fonte | Ano/Período | Nível de Evidência]`.
2. **Hierarquia de Evidência**:
   - **Nível 1 (Dado Primário Oficial)**: IBGE, MTE, BCB, MDIC, Base dos Dados (espelho oficial).
   - **Nível 2 (Literatura Científica e Organismos Multilaterais)**: Artigos com revisão por pares, IPEA, FMI, Banco Mundial, OIT, CEPAL.
   - **Nível 3 (Imprensa Especializada)**: CNN Brasil, Reuters, FT, Valor — usada para cronologia de eventos e choques, nunca substituindo dado estatístico oficial.
3. **Preparação para Defesa em Tela**:
   - Ao final de cada bloco entregue, gerar um quadro **"Ficha de Defesa"**:
     - *Pergunta crítica provável da banca/audiência*;
     - *Resposta objetiva baseada nos dados*;
     - *Limitação metodológica assumida com transparência*;
     - *Fonte exata para exibição em tela*.

## Arquivos de Apoio
- `scripts/rag_ingest.py` — indexa o corpus (chunks + BM25) em `./rag_corpus/.indice/`.
- `scripts/rag_query.py` — consulta o índice e devolve trechos com caminho, título e nível de evidência.
- `scripts/harness_check.py` — audita um texto: tags de citação, existência dos arquivos citados e cobertura de fontes por bloco.
- `templates/FICHA_DEFESA.md` — modelo do quadro de defesa.
- `references/PROTOCOLO_RAG.md` — regras de uso e limitações do índice local.
