# tema.R
# ---------------------------------------------------------------------------
# Tema visual ForestR — paleta inspirada na floresta de terra-firme da
# Amazônia Central. Extraído do script original ForestR_v0.6.R.
# ---------------------------------------------------------------------------

# ══════════════════════════════════════════════════════════════════
#  TEMA VISUAL FORESTR
#  Paleta inspirada na floresta de terra-firme da Amazônia Central
# ══════════════════════════════════════════════════════════════════

#' Paleta de cores ForestR (interna)
#' @keywords internal
FC <- list(
  moss  = "#2d5a20", fern  = "#4a8c38", leaf = "#6db855",
  bark  = "#8b6010", amber = "#c8940c", clay = "#8c3820",
  water = "#1e5a78", bg    = "#f7f4ee", bg2  = "#efeae0",
  rule  = "#d4cfc4", ink   = "#1a2a0e", ink2 = "#3d5a28",
  ink3  = "#7a9a60", ink4  = "#b0c890"
)

#' Tema visual ggplot2 do ForestR
#'
#' @param base_size Tamanho base da fonte
#' @return Um objeto `theme` do ggplot2
#' @importFrom ggplot2 theme_minimal theme element_rect element_line element_blank element_text margin unit %+replace%
#' @export
theme_forestr <- function(base_size = 12) {
  theme_minimal(base_size = base_size) %+replace% theme(
    plot.background  = element_rect(fill = FC$bg,  color = NA),
    panel.background = element_rect(fill = "#ffffff", color = NA),
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

