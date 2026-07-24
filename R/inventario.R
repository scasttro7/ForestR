# inventario.R
# ---------------------------------------------------------------------------
# Módulo 3 — Inventário florestal. Extraído do script original ForestR_v0.6.R.
# ---------------------------------------------------------------------------

# ══════════════════════════════════════════════════════════════════
#  MÓDULO 3 — INVENTÁRIO FLORESTAL
# ══════════════════════════════════════════════════════════════════

#' Resumo de parcela com equações de Higuchi et al. (1998)
#' Aplica a cadeia completa peso fresco -> peso seco -> carbono,
#' usando os fatores do próprio artigo (Tabela 3b; item 7).
#' @param dados Data frame com colunas dap e especie
#' @param area_parcela_ha Área em ha (padrão: 1 ha)

#' @export
resumo_parcela <- function(dados, area_parcela_ha = 1) {
  if (!all(c("dap","especie") %in% names(dados)))
    stop("Data frame precisa de colunas 'dap' e 'especie'.")
  pf_total_kg <- sum(biomassa_higuchi(dados$dap))
  ps_total_kg <- converter_fresco_seco(pf_total_kg)
  agb_seca_ha <- (ps_total_kg / 1000) / area_parcela_ha   # Mg/ha, peso SECO
  c_ha        <- carbono_de_seco(agb_seca_ha)              # Mg C/ha
  cat("\n══════════════════════════════════════════\n")
  cat("  RESUMO DA PARCELA — ForestR\n")
  cat("  Higuchi et al. 1998 · LMF/INPA\n")
  cat("══════════════════════════════════════════\n")
  cat(sprintf("  N / ha              : %.0f\n",  nrow(dados)/area_parcela_ha))
  cat(sprintf("  Riqueza (S)         : %d spp.\n", length(unique(dados$especie))))
  cat(sprintf("  DAP médio           : %.1f cm\n", mean(dados$dap)))
  cat(sprintf("  DAP quadrático      : %.1f cm\n", sqrt(mean(dados$dap^2))))
  cat(sprintf("  G (m²/ha)           : %.4f\n",   sum(area_basal(dados$dap))/area_parcela_ha))
  cat(sprintf("  AGB seca (Mg/ha)    : %.2f\n",   agb_seca_ha))
  cat(sprintf("  C AGB (Mg C/ha)     : %.2f\n",   c_ha))
  cat("  (peso fresco -> seco: fator 0,6028 · Tabela 3b, Higuchi et al. 1998)\n")
  cat("══════════════════════════════════════════\n\n")
  invisible(list(agb_seca_ha = agb_seca_ha, c_ha = c_ha))
}

#' Distribuição diamétrica por classes
#' @param dap Vetor de DAPs em cm · @param amplitude Amplitude das classes (cm)

#' @export
distribuicao_diametrica <- function(dap, amplitude = 5) {
  breaks <- seq(floor(min(dap)/amplitude)*amplitude,
                ceiling(max(dap)/amplitude)*amplitude, by = amplitude)
  classes <- cut(dap, breaks, right = FALSE,
                 labels = paste0(breaks[-length(breaks)],"–",
                                 breaks[-length(breaks)]+amplitude))
  tb <- as.data.frame(table(Classe = classes))
  tb$pct <- round(tb$Freq / sum(tb$Freq) * 100, 1)
  tb
}
