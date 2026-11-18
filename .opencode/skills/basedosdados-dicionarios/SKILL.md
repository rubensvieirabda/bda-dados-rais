---
name: basedosdados-dicionarios
description: Valida e baixa dicionários oficiais e metadados de colunas da Base dos Dados, IBGE e MTE (PNAD-C, RAIS, CAGED) antes de qualquer consulta ou análise.
---

## Objetivo
Garantir que nenhum nome de coluna, código categórico ou unidade de medida seja usado sem estar conferido no dicionário oficial baixado localmente.

## Regras Obrigatórias
1. **Verificação de Integridade**: Antes de usar qualquer dicionário em `./rag_corpus/dicionarios/`, confirme que o arquivo não é HTML de erro, página de redirecionamento ou versão desatualizada.
2. **Fontes Primárias de Metadados**:
   - Base dos Dados (`basedosdados` via Python/CLI ou metadados diretos das tabelas `br_ibge_pnadc`, `br_me_rais`, `br_me_caged`).
   - Notas técnicas oficiais do IBGE (PNAD Contínua) e do Ministério do Trabalho e Emprego (Novo CAGED / RAIS).
3. **Diferenciação Metodológica Obrigatória**:
   - **PNAD Contínua**: pesquisa amostral domiciliar (captura ocupação formal, informal, desocupação e subutilização).
   - **RAIS**: registro administrativo anual de estoque de vínculos formais em 31/12.
   - **CAGED / Novo CAGED**: registro administrativo mensal de fluxo (admissões, desligamentos e saldo celetista). Nunca comparar diretamente a série pré-2020 (CAGED antigo) com pós-2020 (Novo CAGED) sem declarar a quebra metodológica.

## Checklist de Saída
Sempre que responder usando esta skill, entregue:
- Nome exato da tabela e dataset.
- Nome original da coluna, tipo de dado, descrição oficial e domínio de códigos.
- Caminho local do dicionário validado em `./rag_corpus/dicionarios/` e URL oficial de origem.

## Arquivos de Apoio
- `scripts/validar_dicionario.py` — testa se um arquivo baixado é realmente dicionário/layout (não HTML de erro), registra hash e origem.
- `templates/FICHA_VARIAVEL.md` — modelo de ficha por variável.
- `references/` — anotações sobre quebras metodológicas (CAGED antigo × Novo CAGED, PNAD × RAIS).
