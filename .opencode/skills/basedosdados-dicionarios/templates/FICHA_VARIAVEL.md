# Ficha de variável

Preencha uma ficha por variável usada no estudo, **antes** de qualquer consulta.

| Campo | Conteúdo |
| --- | --- |
| Nome no estudo |  |
| Nome original na fonte |  |
| Tabela / conjunto |  |
| Tipo de dado | inteiro · decimal · texto · data |
| Unidade de medida | R$ · % · pessoas · vínculos · índice |
| Descrição oficial |  |
| Domínio de códigos |  |
| Cobertura temporal |  |
| Cobertura espacial |  |
| Nível de observação | vínculo · estabelecimento · pessoa · domicílio · município |
| Valores ausentes | como aparecem (`-1`, vazio, `NA`) e como serão tratados |
| Quebra de série conhecida |  |
| Arquivo local validado | `rag_corpus/dicionarios/...` |
| URL de origem |  |
| SHA-256 |  |
| Data de download |  |
| Observações |  |

---

## Exemplo preenchido — `sexo` (RAIS)

| Campo | Conteúdo |
| --- | --- |
| Nome no estudo | `sexo` |
| Nome original na fonte | `SEXO` |
| Tabela / conjunto | `br_me_rais.microdados_vinculos` |
| Tipo de dado | inteiro |
| Unidade de medida | código categórico |
| Descrição oficial | Sexo do trabalhador |
| Domínio de códigos | 1 = Masculino; 2 = Feminino; -1 = Ignorado |
| Cobertura temporal | 1985–2025 |
| Cobertura espacial | Brasil |
| Nível de observação | vínculo |
| Valores ausentes | `-1` (Ignorado); não confundir com ausência de informação |
| Quebra de série conhecida | nenhuma documentada para esta variável |
| Arquivo local validado | `rag_corpus/dicionarios/rais_dicionario.csv` |
| URL de origem | `ftp://ftp.mtps.gov.br/pdet/microdados/RAIS/Layouts/` |
| SHA-256 | `6fe18cea...` (ver `REGISTRO.csv`) |
| Data de download | 17/11/2026 |
| Observações | Rótulos conferidos no layout oficial 2020 e no Manual RAIS 2022 |
