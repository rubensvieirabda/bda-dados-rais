# Programação

Uma pasta por bloco da pesquisa. `bloco_N/` implementa o Bloco N descrito em
`pesquisa/01_blocos/`.

| Pasta | Bloco | Tema | Estado |
| --- | --- | --- | --- |
| `bloco_2/` | 2 | território, produtividade e investimento | proposta, `config.yaml`, dicionário validado e SQL prontos |
| `bloco_1/` | 1 | séries, extremos e tendências | a criar |
| `bloco_3/` | 3 | forças comerciais | a criar |
| `bloco_4/` | 4 | choques globais e catástrofes | a criar |
| `bloco_5/` | 5 | síntese e defesa em tela | a criar |

A ordem das pastas é a ordem dos blocos da pesquisa, não a ordem de execução. O
Bloco 2 começou primeiro porque é o que mais depende de dados municipais e o que
define o recorte territorial usado nos demais.

## Regra

Cada pasta tem:

- a proposta (`PROPOSTA_BLOCO_N.md`) com escopo, decisões e critérios de aceite;
- `config.yaml` com os parâmetros, sem valor hard-coded nos scripts;
- `sql/` com uma consulta por fonte, cada uma com o dicionário validado no cabeçalho;
- `scripts/`, `testes/` e `saidas/` quando a sprint começa a rodar.

Nenhum script lê dado sem passar pelo `dicionario_validado.csv`.
