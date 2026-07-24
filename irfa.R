# irfa.R
# ---------------------------------------------------------------------------
# Módulo 2 — IRFA (Índice de Resiliência Florestal Amazônica) + padrões da
# triangulação IRFA-IPTA (Quadro 7). Extraído do ForestR_v0.8.R.
#
# ARQUITETURA EM TRÊS NÍVEIS (Seção 3.6 da tese):
#   1. MENSURAÇÃO   — subsistemas primários, calculados de forma
#                      independente: calcular_irfa() (este módulo); IPTA
#                      e IGL são calculados fora deste pacote.
#   2. COMPARAÇÃO    — métricas derivadas que relacionam IRFA e IPTA numa
#                      escala comum: DSE (= IRFA − IPTA) e ICS
#                      (= 1 − |IRFA − IPTA|), calculadas dentro de
#                      classificar_padrao_dse().
#   3. INTERPRETAÇÃO — tipologia descritiva dos quatro padrões (Quadro 7):
#                      classificar_padrao_dse() nomeia a configuração
#                      observada; NÃO recomenda ação.
# Cada nível carrega grau distinto de certeza epistemológica — os
# subsistemas são medidos, as métricas são calculadas, os padrões são
# categorias interpretativas do pesquisador. Não confundir os três ao
# usar ou estender este módulo.
# ---------------------------------------------------------------------------

# ══════════════════════════════════════════════════════════════════
#  MÓDULO 2 — IRFA
#  Índice de Resiliência Florestal Amazônica
#  IRFA = (B + C + E + R + (1 − P)) / 5
#
#  Definição conforme BIODATUM, Seção 3.3 da tese de qualificação.
#  A média é NÃO PONDERADA por decisão metodológica explícita: na
#  ausência de consenso empírico sobre a contribuição relativa de
#  cada componente à resiliência em tipologias amazônicas, pesos
#  a priori introduziriam arbitrariedade não fundamentada.
#  Precedentes: IDH (UNDP, 2024); Allen et al. (2016).
#
#  O argumento `pesos` existe APENAS para a análise de sensibilidade
#  prevista na tese. O default (NULL) é a média simples.
# ══════════════════════════════════════════════════════════════════

#' Classificação fuzzy em cinco níveis
#' Escala compartilhada por IRFA, IPTA e ICS no BIODATUM.
#' @param x Valor normalizado 0–1
#' @return character

#' @export
classificar_fuzzy <- function(x) {
  if (any(x < 0 | x > 1, na.rm = TRUE)) stop("Valor deve estar em 0–1.")
  cut(x,
      breaks = c(-Inf, 0.20, 0.40, 0.60, 0.80, Inf),
      labels = c("Muito baixo", "Baixo", "Moderado", "Alto", "Muito alto"),
      right  = TRUE) |> as.character()
}

#' Calcula o IRFA (Índice de Resiliência Florestal Amazônica)
#'
#' @param B Estoque de biomassa acima do solo, normalizado 0–1
#' @param C Eficiência de acumulação de carbono, 0–1
#' @param E Integridade estrutural do dossel (GEDI RH98 + cover), 0–1
#' @param R Taxa de recuperação de biomassa em áreas perturbadas, 0–1
#' @param P Intensidade de perturbação antrópica acumulada, 0–1
#'          (entra na fórmula como complemento, 1 − P)
#' @param pesos Vetor nomeado c(B=,C=,E=,R=,P=) para análise de
#'          sensibilidade. NULL (default) = média não ponderada.
#' @return list com irfa, classificacao e tabela de componentes

#' @export
calcular_irfa <- function(B, C, E, R, P, pesos = NULL) {

  comp <- c(B = B, C = C, E = E, R = R, P = P)
  if (any(comp < 0 | comp > 1, na.rm = TRUE))
    stop("Todos os componentes devem estar normalizados em 0–1.")

  # P é penalizador: entra como complemento
  termos <- c(B = B, C = C, E = E, R = R, `1-P` = 1 - P)

  if (is.null(pesos)) {
    w <- rep(1/5, 5)
    modo <- "média não ponderada (default BIODATUM)"
  } else {
    if (!all(c("B","C","E","R","P") %in% names(pesos)))
      stop("pesos deve ser um vetor nomeado c(B=,C=,E=,R=,P=).")
    w <- unname(pesos[c("B","C","E","R","P")])
    if (abs(sum(w) - 1) > 0.01)
      warning("Pesos não somam 1,00. Resultado fora da escala 0–1.")
    modo <- "ponderado (análise de sensibilidade)"
  }
  names(w) <- names(termos)

  irfa <- sum(w * termos)

  list(
    irfa          = round(irfa, 4),
    classificacao = classificar_fuzzy(irfa),
    modo          = modo,
    componentes   = data.frame(
      componente   = c("B", "C", "E", "R", "P"),
      descricao    = c("Biomassa acima do solo",
                       "Eficiência de acumulação de C",
                       "Integridade estrutural do dossel",
                       "Recuperação de biomassa",
                       "Perturbação acumulada"),
      valor        = c(B, C, E, R, P),
      termo        = c(B, C, E, R, 1 - P),
      peso         = as.numeric(w),
      contribuicao = as.numeric(w * termos),
      stringsAsFactors = FALSE
    )
  )
}

#' Imprime laudo textual do IRFA

#' @export
imprimir_irfa <- function(r) {
  cat("\n══════════════════════════════════════════════\n")
  cat("  IRFA — Índice de Resiliência Florestal Amazônica\n")
  cat("  BIODATUM · Seção 3.3 · ForestR\n")
  cat("══════════════════════════════════════════════\n")
  cat(sprintf("  Score : %.4f  |  %s\n", r$irfa, r$classificacao))
  cat(sprintf("  Modo  : %s\n\n", r$modo))
  for (i in seq_len(nrow(r$componentes))) {
    x <- r$componentes[i, ]
    cat(sprintf("  %-2s  val=%.2f  termo=%.2f  peso=%.2f  contrib=%.4f\n",
                x$componente, x$valor, x$termo, x$peso, x$contribuicao))
  }
  cat("  (P entra na fórmula como 1 − P)\n")
  cat("══════════════════════════════════════════════\n\n")
}

# ══════════════════════════════════════════════════════════════════
#  PADRÕES DA TRIANGULAÇÃO IRFA-IPTA (Quadro 7, Seção 3.6 da tese)
#
#  Formaliza, de forma computável, os quatro padrões descritivos já
#  definidos no Quadro 7: A (Coerência), B (Defasagem por exclusão),
#  C (Ruptura sistematizada), D (Otimismo desacoplado). A atribuição
#  usa a MESMA classificação fuzzy de 5 níveis já compartilhada por
#  IRFA, IPTA e ICS (classificar_fuzzy()) — nenhum limiar novo foi
#  inventado para esta função.
#
#  DELIBERADAMENTE, esta função retorna "Indeterminado" sempre que
#  IRFA ou IPTA caem em "Moderado": forçar todo território dentro de
#  quatro caixas nítidas seria estatisticamente desonesto quando o
#  dado está no meio da escala. Isso é coerente com o texto da tese:
#  os quatro padrões são estados possíveis, não categorias exaustivas.
#
#  Esta função é DESCRITIVA: nomeia o padrão observado. Ela NÃO
#  recomenda ação — a coluna "implicação para governança" do Quadro 7
#  é interpretação textual do pesquisador, não saída de algoritmo, e
#  não deve ser tratada como recomendação automatizada. Uma camada
#  prescritiva de fato (que avalie e recomende ações específicas a
#  gestores) está fora do escopo desta tese — ver nota de linha de
#  pesquisa futura na Seção 4.4.
# ══════════════════════════════════════════════════════════════════

#' Classifica o padrão da triangulação IRFA-IPTA (Quadro 7)
#' @param irfa Score IRFA normalizado, 0–1
#' @param ipta Score IPTA normalizado, 0–1
#' @return list com padrao (character), dse, icс e os níveis fuzzy de
#'   entrada, para rastreabilidade da classificação

#' @export
classificar_padrao_dse <- function(irfa, ipta) {
  if (any(irfa < 0 | irfa > 1) || any(ipta < 0 | ipta > 1))
    stop("IRFA e IPTA devem estar normalizados em 0–1.")

  nivel_irfa <- classificar_fuzzy(irfa)
  nivel_ipta <- classificar_fuzzy(ipta)
  dse <- irfa - ipta
  ics <- 1 - abs(irfa - ipta)

  alto  <- c("Alto", "Muito alto")
  baixo <- c("Muito baixo", "Baixo")

  padrao <- if (nivel_irfa == "Moderado" || nivel_ipta == "Moderado") {
    "Indeterminado (IRFA ou IPTA em faixa moderada — não força classificação)"
  } else if (nivel_irfa %in% alto && nivel_ipta %in% alto) {
    "A — Coerência"
  } else if (nivel_irfa %in% alto && nivel_ipta %in% baixo) {
    "B — Defasagem por exclusão"
  } else if (nivel_irfa %in% baixo && nivel_ipta %in% baixo) {
    "C — Ruptura sistematizada"
  } else if (nivel_irfa %in% baixo && nivel_ipta %in% alto) {
    "D — Otimismo desacoplado"
  } else {
    "Indeterminado"
  }

  list(padrao = padrao, dse = round(dse, 4), ics = round(ics, 4),
       nivel_irfa = nivel_irfa, nivel_ipta = nivel_ipta)
}
