# visualizacoes.R
# ---------------------------------------------------------------------------
# Módulo 5 — Visualizações ForestR (ggplot2). Extraído do script original
# ForestR_v0.6.R.
# ---------------------------------------------------------------------------

#' @importFrom ggplot2 ggplot aes geom_col geom_line geom_ribbon geom_point
#'   geom_segment geom_label geom_text geom_histogram geom_vline geom_hline
#'   annotate labs scale_x_continuous scale_y_continuous scale_x_discrete
#'   scale_fill_manual position_nudge expansion element_blank theme
#' @importFrom scales number_format
NULL

# ══════════════════════════════════════════════════════════════════
#  MÓDULO 5 — VISUALIZAÇÕES FORESTR
# ══════════════════════════════════════════════════════════════════

#' Gráfico de trajetória de recuperação do IRFA
#' @param irfa_atual Score IRFA no momento atual (0–1)
#' @param anos_pos_disturbio Anos desde o distúrbio
#' @param cenario Descrição do cenário
#' @param bref Biomassa SECA de referência, Mg/ha. ATENÇÃO: o valor de
#'   307 Mg/ha usado em versões anteriores não foi localizado no artigo
#'   Higuchi et al. (1998) — não há citação verificável para esse número.
#'   Use um valor de referência territorial real (ex.: derivado do GEDI
#'   L4A para T1/T2) em vez do default. O default é mantido apenas por
#'   compatibilidade e deve ser tratado como ilustrativo.

#' @export
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
  # bref já é biomassa SECA (Mg/ha); carbono = seco * teor_c (não
  # aplicar sobre peso fresco — ver Módulo 1, carbono_de_seco()).
  c_perdido <- round(carbono_de_seco(bref - bref * irfa_atual), 1)

  ggplot() +
    # Zonas de resiliência
    annotate("rect", xmin=-Inf,xmax=Inf, ymin=0.60,ymax=1.0,
             fill=FC$moss,  alpha=0.07) +
    annotate("rect", xmin=-Inf,xmax=Inf, ymin=0.40,ymax=0.60,
             fill=FC$amber, alpha=0.07) +
    annotate("rect", xmin=-Inf,xmax=Inf, ymin=0.00,ymax=0.40,
             fill=FC$clay,  alpha=0.07) +
    # Linhas-guia
    geom_hline(yintercept=0.60, linetype="22",
               color=FC$fern, linewidth=0.5, alpha=0.8) +
    geom_hline(yintercept=0.40, linetype="22",
               color=FC$clay, linewidth=0.5, alpha=0.8) +
    # Rótulos das zonas
    annotate("text", x=19.6, y=0.83, label="Alto / Muito alto",
             hjust=1, size=3.0, color=FC$fern, family="mono") +
    annotate("text", x=19.6, y=0.50, label="Moderado",
             hjust=1, size=3.0, color=FC$amber, family="mono") +
    annotate("text", x=19.6, y=0.17, label="Baixo / Muito baixo",
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
      subtitle = paste0("Protocolo Higuchi · LMF/INPA · ForestR v0.2  |  ",
                        "Biomassa ref.: ", bref, " Mg/ha  |  ",
                        "ΔC estimado: −", c_perdido, " Mg C/ha"),
      x        = "Anos pós-distúrbio",
      y        = "IRFA Score",
      caption  = "IRFA = (B + C + E + R + (1 - P)) / 5  ·  media nao ponderada  ·  BIODATUM Secao 3.3"
    ) +
    theme_forestr()
}


#' Gráfico de componentes do IRFA
#' @param resultado Lista retornada por calcular_irfa()
#' @param cenario Nome do cenário

#' @export
plotar_componentes_irfa <- function(resultado, cenario = "") {
  df <- resultado$componentes
  df$componente <- factor(df$componente, levels = c("B","C","E","R","P"))
  cores <- c(B = FC$moss, C = FC$fern, E = FC$water,
             R = FC$leaf, P = FC$clay)
  irfa_val <- resultado$irfa

  ggplot(df, aes(x = componente, fill = componente)) +
    # Fundo: meta de recuperação plena
    geom_col(aes(y = 1), width = 0.6, fill = FC$bg2, alpha = 0.6) +
    # Barra principal (valor observado)
    geom_col(aes(y = termo), width = 0.6, alpha = 0.88) +
    # Barra de contribuição ponderada (estreita, sobreposta)
    geom_col(aes(y = contribuicao), width = 0.22, fill = "white",
             alpha = 0.45, position = position_nudge(x = 0.24)) +
    # Linha do IRFA final
    geom_hline(yintercept = irfa_val, linetype = "22",
               color = FC$ink, linewidth = 0.9) +
    annotate("text", x = 5.46, y = irfa_val + 0.025,
             label = paste0("IRFA = ", round(irfa_val, 3)),
             hjust = 1, size = 3.2, family = "mono", color = FC$ink) +
    # Limiares de classe
    geom_hline(yintercept = 0.60, linetype = "dotted",
               color = FC$fern, linewidth = 0.5, alpha = 0.7) +
    geom_hline(yintercept = 0.40, linetype = "dotted",
               color = FC$clay, linewidth = 0.5, alpha = 0.7) +
    # Valores numéricos sobre as barras
    geom_text(aes(y = termo + 0.032,
                  label = sprintf("%.2f", termo)),
              size = 4.2, family = "mono", fontface = "bold",
              color = FC$ink) +
    # Pesos abaixo
    geom_text(aes(y = 0.04,
                  label = sprintf("w=%.2f", peso)),
              size = 2.9, family = "mono", color = "white", vjust = 0) +
    scale_fill_manual(values = cores, guide = "none") +
    scale_x_discrete(labels = c(
      "B\nBiomassa",
      "C\nEficiência C",
      "E\nEstrutura dossel",
      "R\nRecuperação",
      "P\n(1 - P) Perturbação"
    )) +
    scale_y_continuous(
      limits = c(0, 1.06),
      breaks = c(0, 0.20, 0.40, 0.60, 0.80, 1.0),
      labels = c("0", "0.20", "0.40", "0.60", "0.80", "1.0"),
      expand = expansion(mult = c(0, 0.02))
    ) +
    labs(
      title    = if (cenario != "") paste0("Componentes IRFA — ", cenario)
                 else "Componentes do IRFA",
      subtitle = paste0("IRFA = (B + C + E + R + (1 - P)) / 5 = ",
                        round(irfa_val, 4), "  ·  ", resultado$classificacao),
      x        = NULL,
      y        = "Score (0–1)",
      caption  = paste0(
        "Barra larga = termo na fórmula (P entra como 1 - P)  ·  Barra estreita = contribuição\n",
        "BIODATUM Seção 3.3  ·  ForestR v0.2"
      )
    ) +
    theme_forestr() +
    theme(panel.grid.major.x = element_blank())
}


#' Gráfico de distribuição diamétrica (J-invertido)
#' @param dap Vetor de DAPs em cm
#' @param titulo Título do gráfico
#' @param amplitude Amplitude das classes em cm (padrão: 5)

#' @export
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
               "AGB seca ≈ ", round(sum(converter_fresco_seco(biomassa_higuchi(dap)))/1000, 2), " Mg"
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
