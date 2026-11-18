# Matriz de eventos globais e catástrofes

Preencha **uma linha por evento**. As colunas 1–4 são obrigatórias. As colunas 5–7
são o teste de rigor: sem elas, o evento não pode entrar na narrativa.

| # | Evento / catástrofe comprovada | Data (início–fim) | Canal de transmissão | Reverberação no Brasil | Evidência empírica (indicador, período, fonte) | Contraprova (o que se esperaria ver) | Confundidores domésticos | Nível |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 |  |  | comércio exterior · câmbio · juros globais · inflação de energia/alimentos · cadeias produtivas · sanitário · climático | Direta · Indireta · Não comprovada / predominantemente doméstica |  |  |  | 1 · 2 · 3 |
| 2 |  |  |  |  |  |  |  |  |
| 3 |  |  |  |  |  |  |  |  |

---

## Como preencher

**1. Evento comprovado.** Só entra o que tem fonte institucional ou acadêmica que
documente data e escopo. Exemplos de fonte aceitável: OMS (pandemia), NOAA/INMET
(clima), FMI/Banco Mundial (crise financeira), MDIC/Comex Stat (tarifas).

**2. Canal de transmissão.** Escolha **um** canal principal e, se houver, um
secundário. "Crise global" não é canal: é rótulo.

**3. Reverberação.** Use exatamente uma das três categorias:

- `Direta`: existe evidência de que o canal atingiu o Brasil e moveu o indicador.
- `Indireta`: o canal chegou por intermediação (ex.: preço de alimento → inflação →
  juros → emprego).
- `Não comprovada / predominantemente doméstica`: o timing não bate, ou o movimento
  é explicado por fator interno.

**4. Evidência empírica.** Indicador + período + fonte + nível. Exemplo de formato:
`taxa de desocupação, 2020T2–2021T1 [IBGE/PNAD-C | 2020–2021 | Nível 1]`.

**5. Contraprova.** Se o canal fosse real, o que mais deveria ter se movido? Se nada
mais se moveu, a classificação precisa ser rebaixada.

**6. Confundidores domésticos.** Liste o que acontecia no Brasil ao mesmo tempo
(política fiscal, câmbio, eleição, greve, seca regional). Sem isso, atribuir o
movimento ao evento externo é frágil.

---

## Checklist antes de fechar a matriz

- [ ] Todo evento tem data e fonte de Nível 1 ou 2.
- [ ] Nenhum evento é descrito como "causou" sem canal + evidência.
- [ ] Eventos sem evidência ficam marcados como "não comprovado", não são apagados.
- [ ] A matriz tem pelo menos um evento por ano do recorte 2010–2026 **ou** uma nota
      dizendo por que o ano não teve choque relevante.
- [ ] As fontes estão registradas em `pesquisa/00_protocolo/fontes.csv`.
