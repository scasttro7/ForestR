# ══════════════════════════════════════════════════════════════════
#  ForestR — Análise de Florestas Tropicais
#  BIODATUM v0.1
#  Autora: Sabrina Castro · PPGCASA/UFAM · 2026
# ══════════════════════════════════════════════════════════════════
#
#  COMO USAR:
#  1. Selecione tudo (Ctrl+A) e execute (Ctrl+Enter)
#  2. Role até o final e rode os exemplos linha a linha
#
# ══════════════════════════════════════════════════════════════════

# ── DEPENDÊNCIAS ─────────────────────────────────────────────────
if (!requireNamespace("dplyr",   quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("scales",  quietly = TRUE)) install.packages("scales")

library(dplyr)
library(ggplot2)
library(scales)


# ══════════════════════════════════════════════════════════════════
#  TEMA VISUAL FORESTR
#  Paleta inspirada na floresta de terra-firme da Amazônia Central
# ══════════════════════════════════════════════════════════════════

FC <- list(
  moss  = "#2d5a20", fern  = "#4a8c38", leaf = "#6db855",
  bark  = "#8b6010", amber = "#c8940c", clay = "#8c3820",
  water = "#1e5a78", bg    = "#f7f4ee", bg2  = "#efeae0",
  rule  = "#d4cfc4", ink   = "#1a2a0e", ink2 = "#3d5a28",
  ink3  = "#7a9a60", ink4  = "#b0c890"
)

theme_forestr <- function(base_size = 12) {
  theme_minimal(base_size = base_size) %+replace% theme(
    plot.background  = element_rect(fill = FC$bg,  color = NA),
    panel.background = element_rect(fill = "#fff", color = NA),
    panel.border     = element_rect(color = FC$rule, fill = NA, linewidth = 0.5),
    panel.grid.major = element_line(color = FC$bg2, linewidth = 0.4),
    panel.grid.minor = element_blank(),
    plot.title    = element_text(family = "serif", face = "bold",
                                 size = base_size * 1.35, color = FC$ink,
                                 hjust = 0, margin = margin(b = 4)),
    plot.subtitle = element_text(family = "mono", size = base_size * 0.72,
                                 color = FC$ink3,  hjust = 0,
                                 margin = margin(b = 14)),
    plot.caption  = element_text(family = "mono", size = base_size * 0.62,
                                 color = FC$ink4,  hjust = 1,
                                 margin = margin(t = 10)),
    plot.margin   = margin(20, 24, 16, 20),
    axis.title    = element_text(family = "mono", size = base_size * 0.78,
                                 color = FC$ink2),
    axis.text     = element_text(family = "mono", size = base_size * 0.72,
                                 color = FC$ink3),
    axis.ticks    = element_line(color = FC$rule),
    legend.background = element_rect(fill = FC$bg, color = NA),
    legend.key        = element_rect(fill = FC$bg, color = NA),
    legend.title  = element_text(family = "mono", size = base_size * 0.72,
                                 color = FC$ink2),
    legend.text   = element_text(family = "mono", size = base_size * 0.70,
                                 color = FC$ink3),
    strip.background = element_rect(fill = FC$bg2, color = NA),
    strip.text    = element_text(family = "mono", size = base_size * 0.75,
                                 color = FC$moss, face = "bold")
  )
}


# ══════════════════════════════════════════════════════════════════
# ═════════════════════════════════════════════════════════════════
#  MÓDULO 1 — EQUAÇÕES ALOMÉTRICAS TROPICAIS
#  Fonte: Equacoes_Alometricas_Tropicais_BIODATUM.pdf · BIODATUM/PPGCASA/UFAM · 2026
# ═════════════════════════════════════════════════════════════════

#' Catálogo das equações alométricas incorporadas ao ForestR
#' @return data.frame com identificadores, região, variáveis e fórmula resumida

equacoes_alometricas <- function() {
  data.frame(
    id = c(
      "higuchi_1994", "higuchi_1998", "chambers_2001", "chave_2005",
      "nogueira_2008", "djomo_2010", "fayolle_2013", "ngomanda_2014",
      "fayolle_2018", "fayolle_2024_bgb", "brown_1997", "komiyama_2008",
      "basuki_2009_dipterocarpus", "chave_2014_h", "chave_2014_e",
      "kenzo_2009", "baia_2025_hd", "rutishauser_2013_hd"
    ),
    regiao = c(
      "Amazonia", "Amazonia", "Amazonia", "Pantropical", "Amazonia",
      "Congo", "Congo", "Congo", "Congo", "Congo", "Sudeste Asiatico",
      "Sudeste Asiatico", "Sudeste Asiatico", "Pantropical", "Pantropical",
      "Sudeste Asiatico", "Amazonia", "Sudeste Asiatico"
    ),
    referencia = c(
      "Higuchi et al. (1994)", "Higuchi et al. (1998)", "Chambers et al. (2001)",
      "Chave et al. (2005)", "Nogueira et al. (2008)", "Djomo et al. (2010)",
      "Fayolle et al. (2013)", "Ngomanda et al. (2014)", "Fayolle et al. (2018)",
      "Fayolle et al. (2024)", "Brown et al. (1997)", "Komiyama et al. (2008)",
      "Basuki et al. (2009)", "Chave et al. (2014) - modelo I",
      "Chave et al. (2014) - modelo II", "Kenzo et al. (2009)",
      "Baia et al. (2025)", "Rutishauser et al. (2013)"
    ),
    formula = c(
      "AGB = exp(-1.754 + 2.665*ln(DAP))",
      "DAP < 20: AGB = 0.0576*DAP^2.665; DAP >= 20: AGB = 0.1281*DAP^2.170",
      "AGB = exp(-2.289 + 2.649*ln(DAP) - 0.021*ln(DAP)^2)",
      "AGB = wd*exp(-1.499 + 2.148*ln(DAP) + 0.207*ln(DAP)^2 - 0.0281*ln(DAP)^3)",
      "AGB = 0.0332*DAP^2.695",
      "AGB = exp(-2.9826 + 2.3656*ln(DAP))",
      "AGB = exp(-1.803 + 2.310*ln(DAP) + 0.967*ln(wd))",
      "AGB = exp(-2.6077 + 2.4638*ln(DAP))",
      "AGB = 0.0736*(wd*DAP^2*H)^0.973",
      "BGB = 0.324*AGB^1.135",
      "AGB = exp(-2.134 + 2.530*ln(DAP))",
      "AGB = 0.251*wd*DAP^2.46",
      "AGB = 0.1527*DAP^2.39",
      "AGB = 0.0673*(wd*DAP^2*H)^0.976",
      "AGB = exp(-2.024 + 2.481*ln(DAP) + 0.434*ln(wd) - E)",
      "AGB = exp(-2.00 + 2.39*ln(DAP))",
      "Modelo altura-DAP local; coeficientes nao detalhados no PDF",
      "Modelo com DAP, H e wd; coeficientes nao detalhados no PDF"
    ),
    variaveis = c(
      "dap", "dap", "dap", "dap, wd", "dap", "dap", "dap, wd", "dap",
      "dap, altura, wd", "agb", "dap", "dap, wd", "dap", "dap, altura, wd",
      "dap, wd, e", "dap", "dap, altura", "dap, altura, wd"
    ),
    stringsAsFactors = FALSE
  )
}

validar_dap <- function(dap) {
  if (any(dap <= 0, na.rm = TRUE)) stop("DAP deve ser > 0.")
}

validar_parametro <- function(x, nome) {
  if (is.null(x)) stop(sprintf("Parametro '%s' e obrigatorio para esta equacao.", nome))
  if (any(x <= 0, na.rm = TRUE)) stop(sprintf("Parametro '%s' deve ser > 0.", nome))
}

#' Biomassa acima do solo por equações alométricas tropicais
#' @param dap DAP em cm
#' @param altura Altura em m, quando requerida
#' @param wd Densidade da madeira em g/cm3, quando requerida
#' @param e Fator ambiental E de Chave et al. (2014), quando requerido
#' @param agb Biomassa acima do solo em kg, para equações de BGB
#' @param equacao Identificador em equacoes_alometricas()$id
#' @return Biomassa em kg/arvore

biomassa_alometrica <- function(dap = NULL, altura = NULL, wd = 0.6, e = NULL,
                                agb = NULL, equacao = "higuchi_1998") {
  eq <- match.arg(equacao, equacoes_alometricas()$id)

  if (eq == "fayolle_2024_bgb") {
    validar_parametro(agb, "agb")
    return(0.324 * agb^1.135)
  }

  validar_parametro(dap, "dap")

  switch(eq,
    higuchi_1994 = exp(-1.754 + 2.665 * log(dap)),
    higuchi_1998 = ifelse(dap < 20,
                          0.0576 * dap^2.665,
                          0.1281 * dap^2.170),
    chambers_2001 = exp(-2.289 + 2.649 * log(dap) - 0.021 * log(dap)^2),
    chave_2005 = {
      validar_parametro(wd, "wd")
      wd * exp(-1.499 + 2.148 * log(dap) + 0.207 * log(dap)^2 - 0.0281 * log(dap)^3)
    },
    nogueira_2008 = 0.0332 * dap^2.695,
    djomo_2010 = exp(-2.9826 + 2.3656 * log(dap)),
    fayolle_2013 = {
      validar_parametro(wd, "wd")
      exp(-1.803 + 2.310 * log(dap) + 0.967 * log(wd))
    },
    ngomanda_2014 = exp(-2.6077 + 2.4638 * log(dap)),
    fayolle_2018 = {
      validar_parametro(altura, "altura")
      validar_parametro(wd, "wd")
      0.0736 * (wd * dap^2 * altura)^0.973
    },
    brown_1997 = exp(-2.134 + 2.530 * log(dap)),
    komiyama_2008 = {
      validar_parametro(wd, "wd")
      0.251 * wd * dap^2.46
    },
    basuki_2009_dipterocarpus = 0.1527 * dap^2.39,
    chave_2014_h = {
      validar_parametro(altura, "altura")
      validar_parametro(wd, "wd")
      0.0673 * (wd * dap^2 * altura)^0.976
    },
    chave_2014_e = {
      validar_parametro(wd, "wd")
      if (is.null(e)) stop("Parametro 'e' e obrigatorio para Chave et al. (2014) modelo II.")
      exp(-2.024 + 2.481 * log(dap) + 0.434 * log(wd) - e)
    },
    kenzo_2009 = exp(-2.00 + 2.39 * log(dap)),
    baia_2025_hd = stop("Baia et al. (2025) e modelo H-D; o PDF nao traz coeficientes de biomassa para calcular AGB."),
    rutishauser_2013_hd = stop("Rutishauser et al. (2013) aparece no PDF como modelo generico; coeficientes nao detalhados.")
  )
}

#' Biomassa acima do solo — Higuchi et al. 1998
#' Mantida por compatibilidade. Use biomassa_alometrica(..., equacao = "higuchi_1998") para novas analises.
#' @param dap DAP em cm · @return AGB em kg/arvore

biomassa_higuchi <- function(dap) biomassa_alometrica(dap = dap, equacao = "higuchi_1998")

#' Carbono acima do solo (fração C = 0.47)
#' @param dap DAP em cm · @return Carbono em kg/arvore

carbono_higuchi <- function(dap) biomassa_higuchi(dap) * 0.47

#' Biomassa pantropical — Chave et al. 2014
#' @param dap DAP em cm; @param altura H em m; @param wd Densidade g/cm3

biomassa_chave <- function(dap, altura, wd = 0.6) {
  biomassa_alometrica(dap = dap, altura = altura, wd = wd, equacao = "chave_2014_h")
}

#' Area basal individual · @param dap DAP em cm · @return m2

area_basal <- function(dap) pi * (dap / 200)^2

#  MÓDULO 2 — IRFA
#  Indicador de Resiliência Florestal Amazônica
#  IRFA = α·TNR + β·TRB + γ·IEC
# ══════════════════════════════════════════════════════════════════

#' Calcula o IRFA
#' @param tnr Taxa de Regeneração Natural (0–1)
#' @param trb Taxa de Recuperação de Biomassa (0–1)
#' @param iec Índice de Estrutura da Comunidade (0–1)
#' @param w_tnr Peso α · @param w_trb Peso β · @param w_iec Peso γ

calcular_irfa <- function(tnr, trb, iec,
                          w_tnr = 0.35, w_trb = 0.40, w_iec = 0.25) {
  if (any(c(tnr,trb,iec) < 0 | c(tnr,trb,iec) > 1))
    stop("TNR, TRB e IEC devem estar entre 0 e 1.")
  if (abs(w_tnr + w_trb + w_iec - 1) > 0.01)
    warning("Pesos não somam 1.00.")
  irfa <- w_tnr*tnr + w_trb*trb + w_iec*iec
  list(
    irfa          = round(irfa, 4),
    classificacao = case_when(irfa >= 0.65 ~ "Alta Resiliência",
                              irfa >= 0.35 ~ "Resiliência Moderada",
                              TRUE         ~ "Baixa Resiliência"),
    componentes   = data.frame(
      componente   = c("TNR","TRB","IEC"),
      descricao    = c("Regen. Natural","Recup. Biomassa","Estrutura Comunidade"),
      valor        = c(tnr, trb, iec),
      peso         = c(w_tnr, w_trb, w_iec),
      contribuicao = c(w_tnr*tnr, w_trb*trb, w_iec*iec)
    )
  )
}

#' Imprime laudo textual do IRFA

imprimir_irfa <- function(r) {
  cat("\n══════════════════════════════════════════\n")
  cat("  IRFA — Resiliência Florestal Amazônica\n")
  cat("  Protocolo Higuchi · LMF/INPA · ForestR\n")
  cat("══════════════════════════════════════════\n")
  cat(sprintf("  Score : %.4f  |  %s\n\n", r$irfa, r$classificacao))
  for (i in seq_len(nrow(r$componentes))) {
    x <- r$componentes[i,]
    cat(sprintf("  %s  val=%.2f  peso=%.2f  contrib=%.4f\n",
                x$componente, x$valor, x$peso, x$contribuicao))
  }
  cat("══════════════════════════════════════════\n\n")
}


# ══════════════════════════════════════════════════════════════════
#  MÓDULO 3 — INVENTÁRIO FLORESTAL
# ══════════════════════════════════════════════════════════════════

#' Resumo de parcela com equações de Higuchi et al. 1998
#' @param dados Data frame com colunas dap e especie
#' @param area_parcela_ha Área em ha (padrão: 1 ha)

resumo_parcela <- function(dados, area_parcela_ha = 1, equacao = "higuchi_1998", wd = 0.6, e = NULL) {
  if (!all(c("dap","especie") %in% names(dados)))
    stop("Data frame precisa de colunas 'dap' e 'especie'.")
  altura <- if ("altura" %in% names(dados)) dados$altura else NULL
  wd_calc <- if ("wd" %in% names(dados)) dados$wd else wd
  e_calc <- if ("e" %in% names(dados)) dados$e else e
  agb_ha <- (sum(biomassa_alometrica(dap = dados$dap, altura = altura, wd = wd_calc, e = e_calc, equacao = equacao)) / 1000) / area_parcela_ha
  cat("\n══════════════════════════════════════════\n")
  cat("  RESUMO DA PARCELA — ForestR\n")
  cat(sprintf("  Equacao: %s\n", equacao))
  cat("══════════════════════════════════════════\n")
  cat(sprintf("  N / ha          : %.0f\n",  nrow(dados)/area_parcela_ha))
  cat(sprintf("  Riqueza (S)     : %d spp.\n", length(unique(dados$especie))))
  cat(sprintf("  DAP médio       : %.1f cm\n", mean(dados$dap)))
  cat(sprintf("  DAP quadrático  : %.1f cm\n", sqrt(mean(dados$dap^2))))
  cat(sprintf("  G (m²/ha)       : %.4f\n",   sum(area_basal(dados$dap))/area_parcela_ha))
  cat(sprintf("  AGB (Mg/ha)     : %.2f\n",   agb_ha))
  cat(sprintf("  C AGB (Mg C/ha) : %.2f\n",   agb_ha * 0.47))
  cat("══════════════════════════════════════════\n\n")
  invisible(list(agb_ha = agb_ha, c_ha = agb_ha * 0.47, equacao = equacao))
}

#' Distribuição diamétrica por classes
#' @param dap Vetor de DAPs em cm · @param amplitude Amplitude das classes (cm)

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


# ══════════════════════════════════════════════════════════════════
#  MÓDULO 4 — DIVERSIDADE ALFA
# ══════════════════════════════════════════════════════════════════

#' Shannon-Wiener (H') e Pielou (J')
#' @param especies Vetor com identificação de cada indivíduo

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


# ══════════════════════════════════════════════════════════════════
#  MÓDULO 5 — VISUALIZAÇÕES FORESTR
# ══════════════════════════════════════════════════════════════════

#' Gráfico de trajetória de recuperação do IRFA
#' @param irfa_atual Score IRFA no momento atual (0–1)
#' @param anos_pos_disturbio Anos desde o distúrbio
#' @param cenario Descrição do cenário
#' @param bref Biomassa de referência Mg/ha (Higuchi 1998: 307)

plotar_trajetoria_irfa <- function(irfa_atual, anos_pos_disturbio,
                                    cenario = "Distúrbio", bref = 307) {
  alpha     <- pmax(0.06, -log(1 - irfa_atual * 0.95) / anos_pos_disturbio)
  anos      <- seq(0, 20, 0.2)
  traj      <- pmin(0.97,
                    0.04 + (irfa_atual - 0.04) *
                      (1 - exp(-alpha * anos)) /
                      (1 - exp(-alpha * anos_pos_disturbio)))
  traj[anos == 0] <- 0.04

  df        <- data.frame(anos = anos, irfa = traj)
  df_pt     <- data.frame(anos = anos_pos_disturbio, irfa = irfa_atual)
  cor_pt    <- ifelse(irfa_atual >= 0.65, FC$moss,
               ifelse(irfa_atual >= 0.35, FC$amber, FC$clay))
  c_perdido <- round((bref - bref * irfa_atual) * 0.47, 1)

  ggplot() +
    # Zonas de resiliência
    annotate("rect", xmin=-Inf,xmax=Inf, ymin=0.65,ymax=1.0,
             fill=FC$moss,  alpha=0.07) +
    annotate("rect", xmin=-Inf,xmax=Inf, ymin=0.35,ymax=0.65,
             fill=FC$amber, alpha=0.07) +
    annotate("rect", xmin=-Inf,xmax=Inf, ymin=0.00,ymax=0.35,
             fill=FC$clay,  alpha=0.07) +
    # Linhas-guia
    geom_hline(yintercept=0.65, linetype="22",
               color=FC$fern, linewidth=0.5, alpha=0.8) +
    geom_hline(yintercept=0.35, linetype="22",
               color=FC$clay, linewidth=0.5, alpha=0.8) +
    # Rótulos das zonas
    annotate("text", x=19.6, y=0.83, label="Alta Resiliência",
             hjust=1, size=3.0, color=FC$fern, family="mono") +
    annotate("text", x=19.6, y=0.50, label="Resiliência Moderada",
             hjust=1, size=3.0, color=FC$amber, family="mono") +
    annotate("text", x=19.6, y=0.17, label="Comprometido",
             hjust=1, size=3.0, color=FC$clay, family="mono") +
    # Área e curva
    geom_ribbon(data=df, aes(x=anos, ymin=0, ymax=irfa),
                fill=FC$moss, alpha=0.08) +
    geom_line(data=df, aes(x=anos, y=irfa),
              color=FC$moss, linewidth=1.6) +
    # Linha vertical do momento atual
    geom_segment(data=df_pt,
                 aes(x=anos, xend=anos, y=0, yend=irfa),
                 linetype="dotted", color=cor_pt, linewidth=0.7, alpha=0.7) +
    # Ponto atual (dupla camada para efeito de borda)
    geom_point(data=df_pt, aes(x=anos, y=irfa),
               color="white", size=5.5) +
    geom_point(data=df_pt, aes(x=anos, y=irfa),
               color=cor_pt, size=4) +
    # Label do ponto
    geom_label(data=df_pt,
               aes(x=anos, y=irfa,
                   label=paste0("t = ",anos," anos\nIRFA = ",round(irfa,3))),
               hjust=-0.12, vjust=0.5, size=3.0, family="mono",
               color=cor_pt, fill=FC$bg,
               label.size=0.3, label.padding=unit(0.3,"lines")) +
    scale_x_continuous(limits=c(0,20), breaks=seq(0,20,2),
                       labels=paste0(seq(0,20,2),"a"),
                       expand=expansion(mult=c(0.01,0.02))) +
    scale_y_continuous(limits=c(0,1), breaks=seq(0,1,0.1),
                       labels=number_format(accuracy=0.1),
                       expand=expansion(mult=c(0.01,0.02))) +
    labs(
      title    = paste0("Trajetória de Recuperação — ", cenario),
      subtitle = paste0("Protocolo Higuchi · LMF/INPA · ForestR v0.1  |  ",
                        "Biomassa ref.: ", bref, " Mg/ha  |  ",
                        "ΔC estimado: −", c_perdido, " Mg C/ha"),
      x        = "Anos pós-distúrbio",
      y        = "IRFA Score",
      caption  = "IRFA = α·TNR + β·TRB + γ·IEC  ·  pesos via ACP sobre parcelas LMF/INPA (1980–presente)"
    ) +
    theme_forestr()
}


#' Gráfico de componentes do IRFA
#' @param resultado Lista retornada por calcular_irfa()
#' @param cenario Nome do cenário

plotar_componentes_irfa <- function(resultado, cenario = "") {
  df <- resultado$componentes
  df$componente <- factor(df$componente, levels = c("TNR","TRB","IEC"))
  cores <- c(TNR = FC$moss, TRB = FC$bark, IEC = FC$water)
  irfa_val <- resultado$irfa

  ggplot(df, aes(x = componente, fill = componente)) +
    # Fundo: meta de recuperação plena
    geom_col(aes(y = 1), width = 0.6, fill = FC$bg2, alpha = 0.6) +
    # Barra principal (valor observado)
    geom_col(aes(y = valor), width = 0.6, alpha = 0.88) +
    # Barra de contribuição ponderada (estreita, sobreposta)
    geom_col(aes(y = contribuicao), width = 0.22, fill = "white",
             alpha = 0.45, position = position_nudge(x = 0.24)) +
    # Linha do IRFA final
    geom_hline(yintercept = irfa_val, linetype = "22",
               color = FC$ink, linewidth = 0.9) +
    annotate("text", x = 3.46, y = irfa_val + 0.025,
             label = paste0("IRFA = ", round(irfa_val, 3)),
             hjust = 1, size = 3.2, family = "mono", color = FC$ink) +
    # Limiares de classe
    geom_hline(yintercept = 0.65, linetype = "dotted",
               color = FC$fern, linewidth = 0.5, alpha = 0.7) +
    geom_hline(yintercept = 0.35, linetype = "dotted",
               color = FC$clay, linewidth = 0.5, alpha = 0.7) +
    # Valores numéricos sobre as barras
    geom_text(aes(y = valor + 0.032,
                  label = sprintf("%.2f", valor)),
              size = 4.2, family = "mono", fontface = "bold",
              color = FC$ink) +
    # Pesos abaixo
    geom_text(aes(y = 0.04,
                  label = paste0("α=", peso)),
              size = 2.9, family = "mono", color = "white", vjust = 0) +
    scale_fill_manual(values = cores, guide = "none") +
    scale_x_discrete(labels = c(
      "TNR\nRegen. Natural",
      "TRB\nRecup. Biomassa",
      "IEC\nEstrutura Comunidade"
    )) +
    scale_y_continuous(
      limits = c(0, 1.06),
      breaks = c(0, 0.35, 0.65, 1.0),
      labels = c("0", "0.35", "0.65", "1.0"),
      expand = expansion(mult = c(0, 0.02))
    ) +
    labs(
      title    = if (cenario != "") paste0("Componentes IRFA — ", cenario)
                 else "Componentes do IRFA",
      subtitle = paste0("IRFA = 0.35·TNR + 0.40·TRB + 0.25·IEC = ",
                        round(irfa_val, 4), "  ·  ", resultado$classificacao),
      x        = NULL,
      y        = "Score (0–1)",
      caption  = paste0(
        "Barra larga = valor observado  ·  Barra estreita = contribuição ponderada\n",
        "Protocolo Higuchi · LMF/INPA · ForestR v0.1"
      )
    ) +
    theme_forestr() +
    theme(panel.grid.major.x = element_blank())
}


#' Gráfico de distribuição diamétrica (J-invertido)
#' @param dap Vetor de DAPs em cm
#' @param titulo Título do gráfico
#' @param amplitude Amplitude das classes em cm (padrão: 5)

plotar_distribuicao_diametrica <- function(dap, titulo = "Distribuição Diamétrica",
                                            amplitude = 5) {
  df <- data.frame(dap = dap)

  ggplot(df, aes(x = dap)) +
    geom_histogram(
      binwidth = amplitude,
      fill     = FC$moss, color = FC$bg,
      alpha    = 0.86,
      boundary = floor(min(dap) / amplitude) * amplitude
    ) +
    geom_vline(xintercept = mean(dap), linetype = "22",
               color = FC$amber, linewidth = 0.9) +
    annotate("text", x = mean(dap) + 0.8, y = Inf,
             label = paste0("DAP médio\n", round(mean(dap),1), " cm"),
             vjust = 1.4, hjust = 0, size = 3.0,
             family = "mono", color = FC$amber) +
    # Box de estatísticas
    annotate("label",
             x = max(dap) - 0.5, y = Inf,
             label = paste0(
               "N = ", length(dap), " ind.\n",
               "DAP quad. = ", round(sqrt(mean(dap^2)),1), " cm\n",
               "AGB ≈ ", round(sum(biomassa_alometrica(dap = dap, equacao = "higuchi_1998"))/1000, 2), " Mg"
             ),
             vjust = 1.3, hjust = 1, size = 2.9, family = "mono",
             color = FC$ink2, fill = FC$bg,
             label.size = 0.3, label.padding = unit(0.4,"lines")) +
    scale_x_continuous(
      breaks = pretty(dap, n = 8),
      labels = function(x) paste0(x, " cm")
    ) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.14))) +
    labs(
      title    = titulo,
      subtitle = "Higuchi et al. 1998 · Parcelas permanentes LMF/INPA · ForestR v0.1",
      x        = "Classe de DAP (cm)",
      y        = "Frequência (nº indivíduos)",
      caption  = "AGB estimada pela equação de Higuchi et al. 1998 · Floresta de terra-firme · Amazônia Central"
    ) +
    theme_forestr()
}


# ══════════════════════════════════════════════════════════════════
#  EXEMPLOS — RODE DAQUI PARA BAIXO
#  Selecione as linhas que quiser e aperte Ctrl+Enter
# ══════════════════════════════════════════════════════════════════

cat("\n══════════════════════════════════════════════\n")
cat("  🌳  ForestR · Protocolo Higuchi · v0.1\n")
cat("  LMF/INPA · BIODATUM · PPGCASA/UFAM · 2026\n")
cat("══════════════════════════════════════════════\n\n")


# ── EXEMPLO 1: Equações de Higuchi ──────────────────────────────
cat("── 1. Biomassa e Carbono (Higuchi et al. 1998) ──\n")
arvores <- data.frame(
  especie = c("Eschweilera coriacea","Piptadenia suaveolens",
              "Scleronema micranthum","Qualea paraensis",
              "Goupia glabra","Minquartia guianensis"),
  dap     = c(28.3, 15.6, 12.4, 22.1, 35.0, 18.9),
  altura  = c(7.2,  5.8,  5.2,  7.5,  9.1,  6.4)
) %>%
  mutate(agb_kg = round(biomassa_alometrica(dap = dap, altura = altura, equacao = "higuchi_1998"), 1),
         agb_chave_kg = round(biomassa_alometrica(dap = dap, altura = altura, equacao = "chave_2014_h"), 1),
         c_kg   = round(agb_kg * 0.47,  1),
         g_m2   = round(area_basal(dap), 4))
print(arvores)


# ── EXEMPLO 2: Resumo de parcela ────────────────────────────────
cat("\n── 2. Resumo da Parcela (1000 m²) ──\n")
resumo_parcela(arvores, area_parcela_ha = 0.1)


# ── EXEMPLO 3: IRFA — El Niño 2015-2016 ─────────────────────────
cat("── 3. IRFA — Seca El Niño 2015–2016 ──\n")
r <- calcular_irfa(tnr = 0.48, trb = 0.52, iec = 0.58)
imprimir_irfa(r)


# ── EXEMPLO 4: Shannon-Wiener ───────────────────────────────────
cat("── 4. Diversidade Alfa ──\n")
spp <- c(rep("Eschweilera coriacea",  8), rep("Piptadenia suaveolens", 5),
         rep("Scleronema micranthum", 4), rep("Qualea paraensis",      3),
         rep("Goupia glabra",         2), rep("Minquartia guianensis", 1))
diversidade_shannon(spp)


# ── EXEMPLO 5: Gráfico — Trajetória IRFA ────────────────────────
cat("── 5. Gráfico: Trajetória de Recuperação IRFA ──\n")
plotar_trajetoria_irfa(
  irfa_atual         = 0.52,
  anos_pos_disturbio = 8,
  cenario            = "Seca Severa · El Niño 2015–2016 · Amazônia Central"
)


# ── EXEMPLO 6: Gráfico — Componentes IRFA ───────────────────────
cat("── 6. Gráfico: Componentes do IRFA ──\n")
plotar_componentes_irfa(r, cenario = "El Niño 2015–2016 · t = 8 anos")


# ── EXEMPLO 7: Distribuição diamétrica ──────────────────────────
cat("── 7. Gráfico: Distribuição Diamétrica ──\n")
set.seed(2026)
daps_tf <- c(runif(38,5,15), runif(18,15,30), runif(8,30,50), runif(2,50,80))
plotar_distribuicao_diametrica(
  daps_tf, "Parcela de Terra-Firme · Manaus · LMF/INPA"
)


cat("\n🌿 ForestR v0.1 · BIODATUM\n\n")
# ══════════════════════════════════════════════════════════════════
