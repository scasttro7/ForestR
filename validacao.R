# validacao.R
# ---------------------------------------------------------------------------
# Funções de validação de entrada, usadas pelos módulos de alometria e IRFA.
# Extraídas do script original ForestR_v0.6.R para módulo próprio.
# ---------------------------------------------------------------------------

#' Valida que o DAP é positivo
#' @param dap DAP em cm
#' @keywords internal
validar_dap <- function(dap) {
  if (any(dap <= 0, na.rm = TRUE)) stop("DAP deve ser > 0.")
}

#' Valida que um parâmetro obrigatório foi informado e é positivo
#' @param x Valor do parâmetro
#' @param nome Nome do parâmetro (para a mensagem de erro)
#' @keywords internal
validar_parametro <- function(x, nome) {
  if (is.null(x)) stop(sprintf("Parametro '%s' e obrigatorio para esta equacao.", nome))
  if (any(x <= 0, na.rm = TRUE)) stop(sprintf("Parametro '%s' deve ser > 0.", nome))
}
