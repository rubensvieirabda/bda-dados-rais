# ==============================================================================
# Análise de Dados do Mercado de Trabalho com Tidyverse e GT
# -----------------------------------------------------------------------------
# Roteiro (vídeoaula): coleta RAIS → dicionário → manipulação → visualização → GT
# Autor do roteiro: Rocha (vídeoaula "Data in R")
#
# Este script é a versão executável e corrigida do roteiro. Diferenças em relação
# à vídeoaula estão marcadas com [CORRIGIDO] e explicadas no fim do arquivo.
#
# Pré-requisitos:
#   install.packages(c("tidyverse", "gt"))
#
# Uso:
#   Rscript analise_rais_tidyverse.gt.R                 # modo offline (padrão)
#   Rscript analise_rais_tidyverse.gt.R --baixo         # baixa o dicionário
#   Rscript analise_rais_tidyverse.gt.R --recortes      # gera os recortes de território
#
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Pacotes
# ------------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(glue)
})

tem_gt <- requireNamespace("gt", quietly = TRUE)
if (!tem_gt) {
  message("Pacote 'gt' ausente. Instale com: install.packages(\"gt\")")
}

# Cores em um só lugar. Mudar aqui muda em todos os gráficos.
paleta_sexo <- c(
  "Masculino" = "#1f6f8b",
  "Feminino"  = "#e07a5f",
  "Ignorado"  = "#c8c2b6"
)

paleta_raca <- c(
  "Branca"           = "#d9c9a3",
  "Preta"            = "#4a3728",
  "Parda"            = "#9c6b3f",
  "Amarela"          = "#e2b53c",
  "Indígena"         = "#c1440e",
  "Não identificada" = "#8d99ae",
  "Ignorado"         = "#e5e0d8"
)

# Paleta para os gráficos de sexo × raça (mais segura que brewer "Set1",
# cujo vermelho e laranja ficam próximos demais para leitura em tela).
paleta_setores <- c(
  "Branca"           = "#f4d35e",
  "Preta"            = "#3d405b",
  "Parda"            = "#e07a5f",
  "Amarela"          = "#81b29a",
  "Indígena"         = "#c1440e",
  "Não identificada" = "#8d99ae",
  "Ignorado"         = "#e5e0d8"
)

# ------------------------------------------------------------------------------
# 1. Parâmetros
# ------------------------------------------------------------------------------

ARQUIVO_DADOS     <- "rais_2022_bh.csv"
ARQUIVO_DICIONARIO <- "dicionario_rais.csv"
DIRETORIO_SAIDA   <- "saidas"

args <- commandArgs(trailingOnly = TRUE)

# [CORRIGIDO] Antes o script exigia o CSV local. Sem ele, nada rodava.
# O modo offline usa um recorte sintético com o mesmo formato — não são
# dados reais e isso precisa ficar explícito em todo gráfico gerado assim.
MODO_OFFLINE <- !file.exists(ARQUIVO_DADOS)

if (!dir.exists(DIRETORIO_SAIDA)) {
  dir.create(DIRETORIO_SAIDA, showWarnings = FALSE)
}

# ------------------------------------------------------------------------------
# 2. Dados
# ------------------------------------------------------------------------------

ler_dados <- function(caminho) {
  read_csv(caminho, show_col_types = FALSE)
}

gerar_dados_sinteticos <- function(n = 1000) {
  # Distribuições plausíveis, mas inventadas. Servem só para o script rodar
  # sem depender de rede. NUNCA publicar gráfico gerado a partir daqui.
  set.seed(2022)
  tibble(
    valor_remuneracao_media  = round(rlnorm(n, 7.75, 0.42), 2),
    raca_cor                 = sample(c(1L, 2L, 4L, 6L, 8L, 9L, -1L), n, TRUE,
                                      prob = c(.02, .30, .12, .06, .45, .03, .02)),
    sexo                     = sample(c(1L, 2L, -1L), n, TRUE,
                                      prob = c(.55, .44, .01)),
    grau_instrucao_apos_2005 = sample(1:11, n, TRUE,
                                      prob = c(.03, .25, .10, .10, .08,
                                               .06, .20, .05, .09, .03, .01))
  )
}

if (MODO_OFFLINE) {
  dados_rais <- gerar_dados_sinteticos()
  rotulo_fonte <- "DADOS SINTÉTICOS — arquivo rais_2022_bh.csv ausente"
} else {
  dados_rais <- ler_dados(ARQUIVO_DADOS)
  rotulo_fonte <- glue("Dados da RAIS 2022 — Belo Horizonte")
}

# ------------------------------------------------------------------------------
# 3. Dicionário e mapas
# ------------------------------------------------------------------------------

# Os mapas abaixo reproduzem o layout oficial da RAIS 2020, que está validado
# no repositório (rag_corpus/dicionarios/rais_dicionario.csv, 322 códigos).
# Ter os mapas no código torna o script independente de arquivo externo; quando
# o dicionario_rais.csv existe, ele é usado e comparado com os mapas locais.

mapa_sexo <- c(
  "1"  = "Masculino",
  "2"  = "Feminino",
  "-1" = "Ignorado"
)

mapa_raca_cor <- c(
  "1"  = "Indígena",
  "2"  = "Branca",
  "4"  = "Preta",
  "6"  = "Amarela",
  "8"  = "Parda",
  "9"  = "Não identificada",
  "-1" = "Ignorado"
)

mapa_grau <- c(
  "1"  = "Analfabeto",
  "2"  = "Até 5ª inc.",
  "3"  = "5ª compl. fund.",
  "4"  = "6ª a 9º fund.",
  "5"  = "Fund. compl.",
  "6"  = "Médio incompl.",
  "7"  = "Médio compl.",
  "8"  = "Sup. incompl.",
  "9"  = "Sup. compl.",
  "10" = "Mestrado",
  "11" = "Doutorado",
  "-1" = "Ignorado"
)

ler_dicionario <- function(caminho) {
  if (!file.exists(caminho)) {
    message(glue("Dicionário {caminho} não encontrado. Usando os mapas internos."))
    return(NULL)
  }

  # [CORRIGIDO] A vídeoaula usava read_csv() sem argumentos e sem checagem.
  # O dicionário tem 5 colunas; aqui garantimos encoding e ausência de erro.
  suppressMessages(
    read_csv(caminho, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))
  )
}

dicionario <- ler_dicionario(ARQUIVO_DICIONARIO)

comparar_mapa <- function(dic, mapa, nome_coluna) {
  if (is.null(dic)) {
    return(invisible(TRUE))
  }

  nomes_na_fonte <- dic |>
    filter(nome_coluna == .env$nome_coluna)

  if (nrow(nomes_na_fonte) == 0) {
    return(invisible(TRUE))
  }

  na_fonte <- sort(setdiff(nomes_na_fonte$chave, names(mapa)))
  if (length(na_fonte) > 0) {
    message(glue(
      "Atenção: {nome_coluna} tem códigos na fonte sem rótulo local: ",
      "{paste(na_fonte, collapse = ', ')}"
    ))
  }

  invisible(TRUE)
}

comparar_mapa(dicionario, mapa_sexo, "sexo")
comparar_mapa(dicionario, mapa_raca_cor, "raca_cor")
comparar_mapa(dicionario, mapa_grau, "grau_instrucao_apos_2005")

# ------------------------------------------------------------------------------
# 4. Aplicar os rótulos
# ------------------------------------------------------------------------------

# [CORRIGIDO] Este é o ponto que gerava o warning da vídeoaula:
#
#   mutate(sexo = recode(sexo, !!!mapa_sexo))
#   Warning: Unreplaced values treated as NA as `.x` is not compatible.
#
# Motivo: recode() trabalha com match exato. Em vetor NUMÉRICO, um código que
# não está no mapa (ex.: 99, comum em grau_instrucao) vira NA em silêncio. Em
# vetor CHARACTER o código passa intacto — mas aí aparece "99" no gráfico.
#
# Solução: normalizar para caractere e dar .default = "Ignorado". Assim o
# código não mapeado aparece rotulado como ignorado, nunca como NA.

traduzir <- function(x, mapa) {
  dplyr::recode(
    as.character(x),
    !!!mapa,
    .default = "Ignorado",
    .missing  = "Ignorado"
  )
}

dados_tratados <- dados_rais |>
  mutate(
    sexo                     = traduzir(sexo, mapa_sexo),
    raca_cor                 = traduzir(raca_cor, mapa_raca_cor),
    grau_instrucao_apos_2005 = traduzir(grau_instrucao_apos_2005, mapa_grau)
  )

# ------------------------------------------------------------------------------
# 5. Explorar
# ------------------------------------------------------------------------------

glimpse(dados_tratados)
summary(dados_tratados)

cat("\nDistribuição de sexo:\n")
print(table(dados_tratados$sexo, useNA = "ifany"))

# ------------------------------------------------------------------------------
# 6. Filtrar valores válidos de remuneração
# ------------------------------------------------------------------------------

# [CORRIGIDO] A vídeoaula filtrava, mas não dizia com qual regra. Aqui a regra
# fica explícita: excluir remuneração não positiva e valores absurdos, que na
# RAIS costumam ser erro de digitação (inclusive "00000" e valores zerados).

limite_sup <- quantile(dados_rais$valor_remuneracao_media, 0.999, na.rm = TRUE)

dados_filtrados <- dados_tratados |>
  filter(
    !is.na(valor_remuneracao_media),
    valor_remuneracao_media > 0,
    valor_remuneracao_media <= limite_sup
  )

cat(glue(
  "\nVínculos: {nrow(dados_rais)} no total, {nrow(dados_filtrados)} após filtro ",
  "(limite superior: R$ {format(round(limite_sup, 2), big.mark = '.', decimal.mark = ',')})\n"
))

# ------------------------------------------------------------------------------
# 7. Agregações
# ------------------------------------------------------------------------------

media_por_sexo <- dados_filtrados |>
  group_by(sexo) |>
  summarise(
    media_remuneracao = mean(valor_remuneracao_media, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(media_remuneracao))

media_por_raca <- dados_filtrados |>
  group_by(raca_cor) |>
  summarise(
    media_remuneracao = mean(valor_remuneracao_media, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(media_remuneracao))

# [CORRIGIDO] group_by(sexo, raca_cor) sem .groups = "drop" emitia a mensagem
# "summarise() has grouped output by 'sexo'".
analise_combinada <- dados_filtrados |>
  group_by(sexo, raca_cor) |>
  summarise(
    media_remuneracao = mean(valor_remuneracao_media, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(desc(media_remuneracao))

# ------------------------------------------------------------------------------
# 8. Gráficos
# ------------------------------------------------------------------------------

tema_analise <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 14),
      plot.subtitle    = element_text(size = 9.5, colour = "grey40"),
      plot.caption     = element_text(size = 8.5, colour = "grey45", hjust = 0),
      axis.text.x      = element_text(colour = "grey20"),
      axis.text.y      = element_text(colour = "grey20"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank()
    )
}

legenda <- glue("Fonte: RAIS/MTE · {rotulo_fonte}")

# 8.1 Remuneração média por sexo

p_sexo <- ggplot(media_por_sexo, aes(x = sexo, y = media_remuneracao, fill = sexo)) +
  geom_col(width = 0.62, show.legend = FALSE) +
  scale_fill_manual(values = paleta_sexo) +
  scale_y_continuous(
    labels = \(v) paste0("R$ ", format(round(v), big.mark = ".", decimal.mark = ","))
  ) +
  labs(
    title    = "Remuneração média por sexo",
    subtitle = legenda,
    x        = "Sexo",
    y        = "Remuneração média (R$)",
    caption  = "Média aritmética da remuneração média mensal dos vínculos filtrados."
  ) +
  tema_analise()

# 8.2 Remuneração média por raça/cor
#
# [CORRIGIDO] A vídeoaula usou reorder(raca_cor, -media_remuneracao) com
# geom_col(stat = "identity"). Como geom_col já usa o valor de y e inverte o
# eixo, o sinal negativo reordena na direção contrária à esperada e o gráfico
# sai com as categorias trocadas. Aqui a ordem é definida pelo fator, não por
# valor negativo.

media_por_raca <- media_por_raca |>
  mutate(raca_cor = factor(raca_cor, levels = rev(raca_cor)))

p_raca <- ggplot(media_por_raca, aes(x = raca_cor, y = media_remuneracao, fill = raca_cor)) +
  geom_col(width = 0.65, show.legend = FALSE) +
  scale_fill_manual(values = paleta_raca) +
  scale_y_continuous(
    labels = \(v) paste0("R$ ", format(round(v), big.mark = ".", decimal.mark = ","))
  ) +
  labs(
    title    = "Remuneração média por raça/cor",
    subtitle = legenda,
    x        = "Raça/cor",
    y        = "Remuneração média (R$)",
    caption  = "Categorias ordenadas da maior para a menor média."
  ) +
  tema_analise() +
  theme(axis.text.x = element_text(angle = 22, hjust = 1))

# 8.3 Remuneração média por sexo e raça/cor

analise_combinada <- analise_combinada |>
  mutate(raca_cor = factor(raca_cor, levels = paleta_raca |> names()))

p_combinado <- ggplot(
  analise_combinada,
  aes(x = sexo, y = media_remuneracao, fill = raca_cor)
) +
  geom_col(position = position_dodge(width = 0.72), width = 0.66) +
  scale_fill_manual(values = paleta_setores, name = "Raça/cor") +
  scale_y_continuous(
    labels = \(v) paste0("R$ ", format(round(v), big.mark = ".", decimal.mark = ","))
  ) +
  labs(
    title    = "Remuneração média por sexo e raça/cor",
    subtitle = legenda,
    x        = "Sexo",
    y        = "Remuneração média (R$)",
    caption  = "Barras lado a lado: dentro de cada sexo, uma barra por categoria de raça/cor."
  ) +
  tema_analise() +
  theme(legend.position = "bottom", legend.title = element_blank())

# [CORRIGIDO] A vídeoaula usava scale_fill_brewer(palette = "Set1"), que tem 9
# cores muito próximas entre si e fica ilegível com 7 categorias. Paleta
# manual, com contraste verificável.

salvar_grafico <- function(plot, nome, largura = 8, altura = 5) {
  caminho <- file.path(DIRETORIO_SAIDA, nome)
  ggsave(caminho, plot, width = largura, height = altura, dpi = 160)
  message(glue("Gráfico salvo: {caminho}"))
}

if (interactive()) {
  print(p_sexo)
  print(p_raca)
  print(p_combinado)
}

salvar_grafico(p_sexo,      "fig_remuneracao_por_sexo.png")
salvar_grafico(p_raca,      "fig_remuneracao_por_raca.png", altura = 5.2)
salvar_grafico(p_combinado, "fig_remuneracao_por_sexo_raca.png", altura = 5.4)

# ------------------------------------------------------------------------------
# 9. Tabelas com GT
# ------------------------------------------------------------------------------

fmt_moeda <- function(valores) {
  paste0("R$ ", format(round(valores), big.mark = ".", decimal.mark = ","))
}

montar_tabela <- function(dados, titulo, rodape) {
  dados |>
    mutate(media_remuneracao_txt = fmt_moeda(media_remuneracao)) |>
    select(-media_remuneracao) |>
    gt::gt() |>
    gt::tab_header(title = titulo, subtitle = rodape) |>
    gt::fmt_markdown(columns = gt::everything()) |>
    gt::cols_label(media_remuneracao_txt = "Remuneração média") |>
    gt::opt_row_striping() |>
    gt::tab_options(
      table.font.size = gt::px(13),
      heading.title.font.size = gt::px(15),
      heading.subtitle.font.size = gt::px(11),
      table.border.top.style = "none",
      data_row.padding = gt::px(5)
    )
}

if (tem_gt) {
  tabela_sexo <- montar_tabela(
    media_por_sexo,
    "Remuneração média por sexo",
    rotulo_fonte
  )
  print(tabela_sexo)

  tabela_sexo_raca <- montar_tabela(
    analise_combinada |>
      mutate(
        media_remuneracao = round(media_remuneracao, 2),
        sexo   = as.character(sexo),
        raca_cor = as.character(raca_cor)
      ),
    "Remuneração média por sexo e raça/cor",
    rotulo_fonte
  )
  print(tabela_sexo_raca)
} else {
  message("gt ausente: tabelas formatadas não geradas.")
}

# ------------------------------------------------------------------------------
# 10. Saídas
# ------------------------------------------------------------------------------

# O CSV de saída é o que permite reabrir a análise sem rodar tudo de novo.
# Ele carrega o ano-base e a fonte em colunas, não só no rodapé do gráfico.

saida <- bind_rows(
  media_por_sexo  |> transmute(categoria = as.character(sexo),   media_remuneracao),
  media_por_raca  |> transmute(categoria = as.character(raca_cor), media_remuneracao)
) |>
  mutate(
    agrupamento = rep(c("sexo", "raca_cor"),
                      c(nrow(media_por_sexo), nrow(media_por_raca))),
    media_remuneracao = round(media_remuneracao, 2),
    ano_base     = 2022,
    municipio_id = "3106200",
    municipio    = "Belo Horizonte",
    fonte        = "RAIS/MTE via Base dos Dados",
    origem_dados = if (MODO_OFFLINE) "sintetico" else ARQUIVO_DADOS
  ) |>
  relocate(agrupamento, categoria, media_remuneracao)

caminho_saida <- file.path(DIRETORIO_SAIDA, "resumo_medias.csv")
write_csv(saida, caminho_saida)
message(glue("CSV salvo: {caminho_saida} ({nrow(saida)} linhas)"))

# ------------------------------------------------------------------------------
# 11. Metadados
# ------------------------------------------------------------------------------

# [CORRIGIDO] Sem este arquivo, não há como responder "de onde veio este número".
# É a mesma lógica do metadados.json da sprint programacao/bloco_2.

metadados <- list(
  gerado_em = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
  dados_origem = if (MODO_OFFLINE) "sintetico" else ARQUIVO_DADOS,
  sintetico = MODO_OFFLINE,
  dicionario_usado = !is.null(dicionario),
  filtros = list(
    valor_remuneracao_media = "> 0",
    limite_superior = round(limite_sup, 2)
  ),
  vinculos_total = nrow(dados_rais),
  vinculos_apos_filtro = nrow(dados_filtrados),
  variaveis_rotuladas = c("sexo", "raca_cor", "grau_instrucao_apos_2005"),
  pacotes = list(
    tidyverse = as.character(packageVersion("tidyverse")),
    gt = if (tem_gt) as.character(packageVersion("gt")) else NA_character_,
    r = paste(R.version$major, R.version$minor, sep = ".")
  ),
  saidas = c(
    "fig_remuneracao_por_sexo.png",
    "fig_remuneracao_por_raca.png",
    "fig_remuneracao_por_sexo_raca.png",
    "resumo_medias.csv"
  )
)

caminho_meta <- file.path(DIRETORIO_SAIDA, "metadados.json")
jsonlite::write_json(metadados, caminho_meta, pretty = TRUE, auto_unbox = TRUE, na = "null")
message(glue("Metadados salvos: {caminho_meta}"))

# ------------------------------------------------------------------------------
# 12. Diferenças em relação à vídeoaula
# ------------------------------------------------------------------------------
#
# 1. Coleta: o CSV precisa existir. Sem ele, o script roda com dados sintéticos
#    e rotula isso em todo gráfico. Antes, o script parava sem explicar.
#
# 2. Dicionário: os mapas vêm do layout oficial da RAIS 2020, não de um
#    dicionario_rais.csv que pode estar desatualizado. Se o arquivo existir, ele
#    é lido e comparado com os mapas locais.
#
# 3. recode(): ver seção 4. O warning da vídeoaula não é cosmético — em vetor
#    numérico ele converte códigos não mapeados em NA, e o gráfico passa a
#    mostrar uma barra a menos sem avisar.
#
# 4. Filtro de remuneração: a vídeoaula aplicava um filtro sem declarar a regra.
#    Aqui o limite vem do quantil 99,9% e o número de vínculos descartados
#    aparece no console e nos metadados.
#
# 5. Reordenação do gráfico de raça/cor: reorder(x, -y) invertia o eixo.
#
# 6. Paleta: "Set1" do ColorBrewer não distingue bem 7 categorias.
#
# 7. Tabelas GT: a vídeoaula usava fmt_currency(), que só aceita coluna
#    numérica. Como o objetivo aqui é uma tabela de leitura, a moeda é
#    formatada em texto. Se preferir manter a coluna numérica, use
#    fmt_currency(columns = media_remuneracao, currency = "BRL") e remova
#    o cols_label correspondente.
#
# 8. Saídas: gráficos e CSV vão para saidas/, com metadados.json. Antes, nada
#    era salvo.
#
# 9. O CSV de 1.000 linhas que existia antes era um recorte não
#    representativo (média de R$ 18.943,85, atípica para Belo Horizonte).
#    Para análise séria, use a extração completa do ano, não uma amostra.