# diversidade.R
# ---------------------------------------------------------------------------
# Módulo 4 — Diversidade alfa (Shannon-Wiener, Pielou). Extraído do
# script original ForestR_v0.6.R.
# ---------------------------------------------------------------------------

# ══════════════════════════════════════════════════════════════════
#  MÓDULO 4 — DIVERSIDADE ALFA
# ══════════════════════════════════════════════════════════════════

#' Shannon-Wiener (H') e Pielou (J')
#' @param especies Vetor com identificação de cada indivíduo

#' @export
diversidade_shannon <- function(especies) {
  ct <- table(especies); n <- length(especies); s <- length(ct)
  p  <- as.numeric(ct) / n
  h  <- -sum(p * log(p)); j <- h / log(s)
  cat("\n══════════════════════════════════════════\n")
  cat("  DIVERSIDADE ALFA — ForestR\n")
  cat("══════════════════════════════════════════\n")
  cat(sprintf("  Riqueza (S) : %d spp.\n", s))
  cat(sprintf("  Shannon H'  : %.4f nats\n", h))
  cat(sprintf("  Pielou  J'  : %.4f\n", j))
  cat("══════════════════════════════════════════\n\n")
  invisible(list(S = s, H_prime = round(h,4), J_prime = round(j,4)))
}
