#!/usr/bin/env Rscript
# Converte o layout oficial da RAIS (planilha .xls do MTE) em um dicionário tidy.
#
# Uso:
#   Rscript extrair_dicionario_rais.R <layout.xls> <saida.csv> [ano_base] [fonte]
#
# Saída (UTF-8, separador vírgula):
#   tabela, variavel, descricao, tamanho_bytes, codigo, rotulo, ano_layout, fonte
#
# Regras:
#   - A primeira coluna marca o início de um bloco de variável; as linhas seguintes
#     (com a coluna 1 vazia) continuam o bloco anterior.
#   - Linhas de template (ex.: "<999>", "99.999.999") são descartadas.
#   - Códigos são mantidos como texto para preservar "-1", "01" etc.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Uso: Rscript extrair_dicionario_rais.R <layout.xls> <saida.csv> [ano_base] [fonte]")
}

layout_path <- args[1]
saida <- args[2]
ano_layout <- if (length(args) >= 3) args[3] else ""
fonte <- if (length(args) >= 4) args[4] else "MTE - RAIS"

suppressMessages(library(readxl))
folhas <- excel_sheets(layout_path)
aba <- if ("RAISD - layout" %in% folhas) "RAISD - layout" else folhas[1]
d <- suppressMessages(read_excel(layout_path, sheet = aba, col_names = FALSE, .name_repair = "minimal"))

txt <- function(v) {
  if (length(v) == 0) return("")
  if (is.na(v)) return("")
  trimws(as.character(v))
}

linhas <- list()
variavel <- descricao <- tamanho <- ""
ignorar_bloco <- FALSE

for (i in seq_len(nrow(d))) {
  nome <- txt(d[i, 1][[1]])
  if (nzchar(nome)) {
    variavel <- nome
    descricao <- txt(d[i, 2][[1]])
    tamanho <- txt(d[i, 3][[1]])
    rotulo <- txt(d[i, 4][[1]])
    codigo <- txt(d[i, 5][[1]])
    # Nota descritiva do bloco (ex.: "ver planilha correspondente") não é código.
    ignorar_bloco <- grepl("^\\(ver", rotulo, ignore.case = TRUE) || !nzchar(codigo)
  } else {
    rotulo <- txt(d[i, 4][[1]])
    codigo <- txt(d[i, 5][[1]])
  }

  if (!nzchar(codigo) || !nzchar(rotulo) || ignorar_bloco) next
  # Descarta placeholders de formato do layout.
  if (grepl("^<.+>$", rotulo) || grepl("^[0-9.]+,[0-9]+$", rotulo)) next

  linhas[[length(linhas) + 1]] <- data.frame(
    tabela = "microdados_vinculos",
    variavel = variavel,
    descricao = descricao,
    tamanho_bytes = tamanho,
    codigo = codigo,
    rotulo = rotulo,
    ano_layout = ano_layout,
    fonte = fonte,
    stringsAsFactors = FALSE
  )
}

if (!length(linhas)) stop("Nenhum código extraído - verifique a planilha de layout.")

dic <- do.call(rbind, linhas)
dir.create(dirname(saida), showWarnings = FALSE, recursive = TRUE)
write.csv(dic, saida, row.names = FALSE, fileEncoding = "UTF-8")

cat("Layout:", layout_path, "| aba:", aba, "\n")
cat("Variáveis com códigos:", length(unique(dic$variavel)), "\n")
cat("Linhas de código:", nrow(dic), "\n")
cat("Saída:", saida, "\n")

alvo <- c("SEXO", "RACA_COR", "GR INSTRUCAO OU ESCOLARIDADE APÓS 2005")
for (v in alvo) {
  sub <- dic[dic$variavel == v, c("codigo", "rotulo")]
  if (nrow(sub)) {
    cat("\n", v, ":\n", sep = "")
    print(sub, row.names = FALSE)
  }
}
