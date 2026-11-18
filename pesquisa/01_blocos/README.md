# Blocos de trabalho

Um arquivo por bloco, nomeado `BLOCO_<n>_<tema>.md`. Cada bloco só é fechado quando
passa pelo [checklist do protocolo](../00_protocolo/PROTOCOLO_PESQUISA.md#10-definição-de-pronto-por-bloco).

| Bloco | Arquivo | Tema | Status |
| --- | --- | --- | --- |
| 1 | `BLOCO_1_SERIES.md` | séries, extremos e tendências | a iniciar |
| 2 | `BLOCO_2_TERRITORIO.md` | cidades, produtividade, investimento | a iniciar |
| 3 | `BLOCO_3_COMERCIO.md` | forças comerciais | a iniciar |
| 4 | `BLOCO_4_CHOQUES.md` | matriz de eventos e catástrofes | a iniciar |
| 5 | `BLOCO_5_SINTESE.md` | narrativa e defesa em tela | a iniciar |

## Estrutura sugerida de cada arquivo

```markdown
# Bloco N — Título

## Pergunta do bloco
## Método
## Dados usados (arquivo, fonte, período, nível)
## Resultados
## Leitura
## Limitações
## Fichas de defesa relacionadas
## Pendências
```

## Regras de escrita

- Todo número leva tag `[Fonte | Período | Nível N]`.
- Toda tabela declara unidade, ano-base e fonte.
- Toda afirmação causal passa pelo teste de causalidade da
  [ficha de defesa](../../.opencode/skills/historia-emprego-choques-globais/templates/FICHA_DEFESA.md).
- Antes de publicar, rode:

```bash
python .opencode/skills/rag-harness-defesa/scripts/harness_check.py pesquisa/01_blocos/BLOCO_1_SERIES.md --fontes pesquisa/00_protocolo/fontes.csv --strict
```
