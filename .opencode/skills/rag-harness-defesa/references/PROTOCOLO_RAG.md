# Protocolo de uso do RAG local

## O que o índice é

Uma busca lexical **BM25** sobre o texto extraído dos arquivos de `rag_corpus/`.
Não há embeddings, não há busca semântica, não há LLM consultando o corpus sozinho.
Isso é uma escolha deliberada: o resultado é auditável, reproduzível e não inventa
trecho que não existe.

## O que o índice não é

- **Não é um banco de dados.** Ele não responde com números atualizados; responde com
  trechos de documentos baixados em uma data.
- **Não cobre o que não foi baixado.** Se a resposta não está no corpus, a resposta
  correta é "sem fonte no corpus".
- **Não entende sinônimos distantes.** "Desemprego" e "desocupação" funcionam;
  "mercado de trabalho" e "emprego" podem não recuperar o mesmo trecho.

## Fluxo operacional

```bash
# 1. baixar e validar fontes novas
python .opencode/skills/rag-harness-defesa/scripts/baixar_fontes.py

# 2. reconstruir o índice (sempre depois de adicionar arquivo)
python .opencode/skills/rag-harness-defesa/scripts/rag_ingest.py

# 3. consultar
python .opencode/skills/rag-harness-defesa/scripts/rag_query.py "quebra de série CAGED" -k 8

# 4. filtrar por nível de evidência
python .opencode/skills/rag-harness-defesa/scripts/rag_query.py "COVID emprego" --level 1

# 5. auditar o texto antes de apresentar
python .opencode/skills/rag-harness-defesa/scripts/harness_check.py pesquisa/01_blocos/BLOCO_4.md --fontes pesquisa/00_protocolo/fontes.csv --strict
```

## Estrutura do índice

`rag_corpus/.indice/index.json` contém:

- `built_at`: data de construção (UTC);
- `n_chunks`, `avgdl`, `df`: parâmetros do BM25;
- `files`: manifesto com caminho, área, nível, bytes, SHA-256 e número de chunks;
- `chunks`: texto, caminho, título, data e nível.

O manifesto permite responder "qual documento exato sustentou esta afirmação?".

## Níveis de evidência por pasta

| Pasta | Nível | Uso |
| --- | --- | --- |
| `dicionarios/` | 1 | metadados, layouts, notas metodológicas |
| `oficiais/` | 1 | boletins, relatórios, séries oficiais |
| `academico/` | 2 | artigos, working papers |
| `imprensa/` | 3 | cronologia de eventos |

## Regras de citação

1. Cite **caminho do arquivo + título + nível**, nunca só "segundo o IBGE".
2. Para PDF, informe a página quando o trecho for específico.
3. Se dois trechos divergirem, apresente a divergência; não escolha o mais
   conveniente.
4. Imprensa nunca substitui dado oficial. Se a única fonte for imprensa, o nível da
   afirmação é 3 e isso precisa aparecer.

## Manutenção

- Adicionou arquivo? Rode `rag_ingest.py` de novo.
- Arquivo baixado é HTML de erro? `baixar_fontes.py` marca `html` e grava o
  `.meta.json`; apague o arquivo inválido antes de reindexar.
- Índice grande (>50 MB)? Considere dividir o corpus por bloco.
- Mudou o layout oficial? Registre em `REGISTRO.csv` e revalide o dicionário.
