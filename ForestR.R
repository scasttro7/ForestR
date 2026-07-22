# ══════════════════════════════════════════════════════════════════
#  ForestR — Análise de Florestas Tropicais
#  BIODATUM v0.8
#  Autora: Sabrina Castro da Silva · PPGCASA/UFAM · 2026
#
#  ARQUITETURA EM TRÊS NÍVEIS (Seção 3.6 da tese):
#    1. MENSURAÇÃO   — subsistemas primários, calculados de forma
#                       independente: calcular_irfa() (Módulo 2); IPTA
#                       e IGL são calculados fora deste pacote.
#    2. COMPARAÇÃO    — métricas derivadas que relacionam IRFA e IPTA
#                       numa escala comum: DSE (= IRFA − IPTA) e ICS
#                       (= 1 − |IRFA − IPTA|), calculadas dentro de
#                       classificar_padrao_dse().
#    3. INTERPRETAÇÃO — tipologia descritiva dos quatro padrões
#                       (Quadro 7): classificar_padrao_dse() nomeia a
#                       configuração observada; NÃO recomenda ação.
#  Cada nível carrega grau distinto de certeza epistemológica — os
#  subsistemas são medidos, as métricas são calculadas, os padrões
#  são categorias interpretativas do pesquisador. Não confundir os
#  três ao usar ou estender este pacote.
#
#  NOTAS DE CORREÇÃO — v0.3 (conferida contra Higuchi et al. 1998,
#  Acta Amazonica 28(2):153-166, fonte primária):
#
#  1. Módulo 1 revertido para os coeficientes REAIS do artigo.
#     A versão anterior usava 0,0576 e 0,1281, que não aparecem em
#     nenhum lugar do artigo original — os coeficientes corretos são
#     exp(-1,754)=0,1731 e exp(-0,151)=0,8598 (Considerações Finais,
#     item 3, Modelo 1). Esse erro também está presente na nota
#     técnica Equacoes_Alometricas_Tropicais_BIODATUM.pdf e precisa
#     ser corrigido lá também.
#
#  2. Higuchi et al. (1998) estima peso FRESCO, não seco (isto é
#     explícito no artigo, p.7). A versão anterior aplicava a fração
#     de carbono do IPCC (0,47) direto sobre o peso fresco, pulando a
#     secagem — superestimando o carbono em ~1,66x (+66%). Adicionadas
#     as funções converter_fresco_seco() e carbono_de_seco(), com os
#     fatores do próprio artigo (Tabela 3b: seco = 60,28% do fresco).
#     carbono_higuchi() agora aplica a cadeia completa.
#
#  3. O valor 'bref = 307 Mg/ha (Higuchi 1998)', usado no gráfico de
#     trajetória, não foi localizado no artigo. Sinalizado no código;
#     substitua por um valor territorial real antes de usar em T1/T2.
#
#  4. O claim de que equações pantropicais subestimam 'em até 40%'
#     (citado na tese e na nota técnica como Higuchi et al. 1997/1998)
#     NÃO aparece no artigo de 1998 conferido aqui — o texto testa 4
#     modelos contra o próprio banco de dados do INPA, sem comparação
#     com equação pantropical nenhuma. Coincide numericamente com o
#     teor de água da madeira (39,7%, Tabela 3b). Verificar a fonte
#     exata (pode estar no capítulo interno de 1997, sem acesso aqui)
#     antes de manter esse argumento na tese. Ver Exemplo 9 abaixo.
#
#  5. IRFA (Módulo 2) reconciliado com a tese (Seção 3.3): cinco
#     componentes (B, C, E, R, P), média NÃO ponderada, classificação
#     fuzzy em cinco níveis. Ver notas de v0.2 preservadas no Módulo 2.
#
#  NOTAS — v0.4:
#
#  6. Adicionada fator_correcao_altura_dominante() e
#     biomassa_higuchi_corrigida(): implementa o procedimento do
#     LMF/INPA (projeto CADAF) para aplicar a equação de Manaus em
#     sítios sem calibração destrutiva própria — caso de T1 e T2.
#     Fonte: HIGUCHI, F.G. et al., in LIMA et al. (2014), cap. 3.
#     O valor default de altura dominante de calibração (30 m) é
#     ILUSTRATIVO — confirme o valor real usado pelo LMF/INPA.
#
#  7. O argumento "regional > pantropical", antes apoiado num "até
#     40%" sem fonte primária verificável, foi substituído por
#     evidência testada estatisticamente: HIGUCHI, F.G. et al. (2014)
#     rejeitaram por ANCOVA a hipótese de equação única para toda a
#     Amazônia (p < 0,000000), citando também NGOMANDA et al. (2014)
#     sobre a falha de equações pantropicais em capturar variabilidade
#     alométrica em escala global. Ver Exemplo 9 (mantido como
#     demonstração de unidade, não como fonte do argumento) e Exemplo
#     10 (novo).
#
#  8. Cadeia fresco->seco->carbono (Módulo 1) recebeu confirmação
#     cruzada de duas fontes adicionais do mesmo grupo (LMF/INPA):
#     SILVA, R.P. (2007) e HIGUCHI, N. et al. (2004).
#
#  NOTAS — v0.5:
#
#  9. Resolvida a pendência da v0.4: o valor de altura dominante de
#     calibração (Manaus, ZF-2) estava com default ilustrativo (30 m)
#     por falta de fonte confirmada. Agora confirmado em HIGUCHI, F.G.
#     (2015, tese de doutorado, UFPR): Hdom = 30,2 m, método das 10%
#     árvores mais grossas amostradas (validado por ANOVA entre quatro
#     métodos concorrentes). Default de fator_correcao_altura_dominante()
#     e biomassa_higuchi_corrigida() atualizado de 30 para 30,2.
#
#  10. Exemplo 10 atualizado com os valores REAIS de RH98/GEDI L2A de
#      T1 e T2 (21,27 m e 21,38 m, respectivamente), extraídos de
#      BIODATUM_IRFA_componentes_T1_T2.csv, no lugar de valores
#      ilustrativos. Nota de cautela adicionada: RH98 (GEDI) e altura
#      dominante de campo (10% árvores mais grossas) não são
#      estritamente equivalentes — a aproximação deve ser declarada
#      como tal na tese, não apresentada como identidade metodológica.
#
#  11. HIGUCHI, F.G. (2015) também testou por ANCOVA, com 11 sítios
#      reais do Amazonas (1.128 parcelas), se uma equação de volume
#      única serviria para todo o estado — rejeitada (p < 0,000001 em
#      todos os sítios). Reforça de forma independente o mesmo achado
#      já citado na tese (HIGUCHI, F.G. et al., 2014, cap. 2).
#
#  NOTAS — v0.6:
#
#  12. Adicionada classificar_padrao_dse(): formaliza os quatro
#      padrões descritivos do Quadro 7 (Seção 3.6 da tese) — A
#      Coerência, B Defasagem por exclusão, C Ruptura sistematizada,
#      D Otimismo desacoplado — usando a classificação fuzzy já
#      existente (classificar_fuzzy()), sem inventar limiares novos.
#      Retorna "Indeterminado" quando IRFA ou IPTA caem em "Moderado",
#      para não forçar classificação onde o dado é ambíguo. Função
#      DESCRITIVA — nomeia o padrão, não recomenda ação. Uma camada
#      prescritiva de verdade é linha de pesquisa de pós-doutorado,
#      fora do escopo desta tese.
#
#  NOTAS — v0.7:
#
#  13. Cabeçalho reorganizado para nomear explicitamente a arquitetura
#      em três níveis (mensuração / comparação / interpretação), no
#      mesmo enquadramento adicionado à Seção 3.6 da tese (V18).
#      Nenhuma mudança de comportamento — apenas documentação.
# ══════════════════════════════════════════════════════════════════
#
#  COMO USAR:
#  1. Selecione tudo (Ctrl+A) e execute (Ctrl+Enter)
#  2. Role até o final e rode os exemplos linha a linha
#
# ══════════════════════════════════════════════════════════════════

# ── DEPENDÊNCIAS ─────────────────────────────────────────────────

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


# ══════════════════════════════════════════════════════════════════
#  MÓDULO 1 — EQUAÇÕES ALOMÉTRICAS TROPICAIS
#  Fonte primária verificada: Higuchi et al. (1998), Acta Amazonica
#  28(2):153-166 [conferida linha a linha nesta versão — ver nota v0.3]
#  Demais equações: conforme Equacoes_Alometricas_Tropicais_BIODATUM.pdf
# ══════════════════════════════════════════════════════════════════

#' Catálogo das equações alométricas incorporadas ao ForestR
#' @return data.frame com identificadores, região, variáveis e fórmula resumida

equacoes_alometricas <- function() {
  data.frame(
    id = c(
      "higuchi_1998_a", "higuchi_1998_b", "higuchi_1998_unica",
      "chambers_2001", "chave_2005", "nogueira_2008", "djomo_2010",
      "fayolle_2013", "ngomanda_2014", "fayolle_2018", "fayolle_2024_bgb",
      "brown_1997", "komiyama_2008", "basuki_2009_dipterocarpus",
      "chave_2014_h", "chave_2014_e", "kenzo_2009",
      "baia_2025_hd", "rutishauser_2013_hd"
    ),
    regiao = c(
      "Amazonia", "Amazonia", "Amazonia",
      "Amazonia", "Pantropical", "Amazonia", "Congo",
      "Congo", "Congo", "Congo", "Congo",
      "Sudeste Asiatico", "Sudeste Asiatico", "Sudeste Asiatico",
      "Pantropical", "Pantropical", "Sudeste Asiatico",
      "Amazonia", "Sudeste Asiatico"
    ),
    referencia = c(
      "Higuchi et al. (1998) - Modelo 1a, 5<=DAP<20",
      "Higuchi et al. (1998) - Modelo 1b, DAP>=20",
      "Higuchi et al. (1998) - Modelo 1, equacao unica DAP>=5",
      "Chambers et al. (2001)", "Chave et al. (2005)",
      "Nogueira et al. (2008)", "Djomo et al. (2010)",
      "Fayolle et al. (2013)", "Ngomanda et al. (2014)",
      "Fayolle et al. (2018)", "Fayolle et al. (2024)",
      "Brown et al. (1997) - FAO", "Komiyama et al. (2008)",
      "Basuki et al. (2009)", "Chave et al. (2014) - modelo I",
      "Chave et al. (2014) - modelo II", "Kenzo et al. (2009)",
      "Baia et al. (2025)", "Rutishauser et al. (2013)"
    ),
    formula = c(
      "P = exp(-1,754 + 2,665*ln(DAP))  [peso FRESCO, kg]",
      "P = exp(-0,151 + 2,170*ln(DAP))  [peso FRESCO, kg]",
      "P = exp(-1,497 + 2,548*ln(DAP))  [peso FRESCO, kg]",
      "AGB = exp(-2,289 + 2,649*ln(DAP) - 0,021*ln(DAP)^2)",
      "AGB = wd*exp(-1,499 + 2,148*ln(D) + 0,207*ln(D)^2 - 0,0281*ln(D)^3)",
      "AGB = 0,0332*DAP^2,695",
      "AGB = exp(-2,9826 + 2,3656*ln(DAP))",
      "AGB = exp(-1,803 + 2,310*ln(DAP) + 0,967*ln(wd))",
      "AGB = exp(-2,6077 + 2,4638*ln(DAP))",
      "AGB = 0,0736*(wd*DAP^2*H)^0,973",
      "B = 0,324*AGB^1,135",
      "AGB = exp(-2,134 + 2,530*ln(DAP))",
      "AGB = 0,251*wd*DAP^2,46",
      "AGB = 0,1527*DAP^2,39",
      "AGB = 0,0673*(wd*DAP^2*H)^0,976",
      "AGB = exp(-2,024 + 2,481*ln(DAP) + 0,434*ln(wd) - E)",
      "AGB = exp(-2,00 + 2,39*ln(DAP))",
      "Modelo altura-DAP local; sem coeficientes de biomassa no PDF",
      "Modelo com DAP, H e wd; coeficientes nao detalhados no PDF"
    ),
    variaveis = c(
      "dap", "dap", "dap",
      "dap", "dap, wd", "dap", "dap",
      "dap, wd", "dap", "dap, altura, wd", "agb",
      "dap", "dap, wd", "dap",
      "dap, altura, wd", "dap, wd, e", "dap",
      "dap, altura", "dap, altura, wd"
    ),
    unidade_saida = c(
      "kg (peso fresco)", "kg (peso fresco)", "kg (peso fresco)",
      "kg (AGB seca)", "kg (AGB seca)", "kg (AGB seca)", "kg (AGB seca)",
      "kg (AGB seca)", "kg (AGB seca)", "kg (AGB seca)", "kg (BGB seca)",
      "kg (AGB seca)", "kg (AGB seca)", "kg (AGB seca)",
      "kg (AGB seca)", "kg (AGB seca)", "kg (AGB seca)",
      "-", "-"
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
#'
#' ATENÇÃO À UNIDADE DE SAÍDA: as três equações de Higuchi et al. (1998)
#' (`higuchi_1998_a`, `_b`, `_unica`) retornam PESO FRESCO em kg, conforme
#' definido explicitamente no artigo original (Acta Amazonica 28(2), p.7:
#' "P = peso da massa fresca de cada árvore, em quilograma"). Todas as
#' DEMAIS equações deste catálogo (Chave, Chambers, Fayolle etc.) já
#' retornam AGB SECA. Não são diretamente comparáveis sem conversão.
#' Use `converter_fresco_seco()` e `carbono_de_seco()` explicitamente —
#' nunca aplique fração de carbono direto sobre o peso fresco de Higuchi.
#'
#' @param dap DAP em cm
#' @param altura Altura em m, quando requerida
#' @param wd Densidade da madeira em g/cm3, quando requerida
#' @param e Fator ambiental E de Chave et al. (2014), quando requerido
#' @param agb Biomassa acima do solo em kg, para equações de BGB
#' @param equacao Identificador em equacoes_alometricas()$id
#' @return Biomassa em kg/arvore (ver unidade_saida no catálogo)

biomassa_alometrica <- function(dap = NULL, altura = NULL, wd = 0.6, e = NULL,
                                agb = NULL, equacao = "higuchi_1998_a") {
  eq <- match.arg(equacao, equacoes_alometricas()$id)

  if (eq == "fayolle_2024_bgb") {
    validar_parametro(agb, "agb")
    return(0.324 * agb^1.135)
  }
  if (eq %in% c("baia_2025_hd", "rutishauser_2013_hd")) {
    stop(sprintf("%s e modelo H-D; o PDF de referencia nao traz coeficientes de biomassa para calcular AGB.", eq))
  }

  validar_parametro(dap, "dap")

  switch(eq,
    # ── Higuchi et al. (1998), Acta Amazonica 28(2):153-166 ──────────
    # Coeficientes conferidos diretamente no artigo (Considerações
    # Finais, item 3, Modelo 1). Retornam peso FRESCO em kg.
    higuchi_1998_a = exp(-1.754 + 2.665 * log(dap)),   # 5 <= DAP < 20 cm
    higuchi_1998_b = exp(-0.151 + 2.170 * log(dap)),   # DAP >= 20 cm
    higuchi_1998_unica = exp(-1.497 + 2.548 * log(dap)), # DAP >= 5 cm, menos preciso que a/b

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
    kenzo_2009 = exp(-2.00 + 2.39 * log(dap))
  )
}

#' Biomassa acima do solo com seleção automática por classe de DAP,
#' equações a/b de Higuchi et al. (1998) — RECOMENDADO para inventário.
#' Retorna peso FRESCO em kg (ver aviso em biomassa_alometrica()).
#' @param dap DAP em cm · @return AGB fresca em kg/arvore

biomassa_higuchi <- function(dap) {
  validar_dap(dap)
  ifelse(dap < 20,
         biomassa_alometrica(dap = dap, equacao = "higuchi_1998_a"),
         biomassa_alometrica(dap = dap, equacao = "higuchi_1998_b"))
}

# ══════════════════════════════════════════════════════════════════
#  CONVERSÃO FRESCO -> SECO -> CARBONO
#  Fatores tirados DIRETAMENTE de Higuchi et al. (1998):
#    - Tabela 3b: peso seco médio = 60,28% do peso fresco (n=38)
#    - Considerações finais, item 7: teor de carbono por compartimento
#      tronco 48%, galho grosso 48%, galho fino 47%, folhas 39%
#  Usar SEMPRE esta cadeia ao partir de biomassa_higuchi(); NUNCA
#  aplicar fração de carbono direto sobre peso fresco.
#
#  CONFIRMAÇÃO CRUZADA (v0.3): dois trabalhos independentes do mesmo
#  grupo (LMF/INPA) usam fatores muito próximos, na mesma direção:
#    - Silva, R.P. (2007) Tese de Doutorado, INPA/UFAM: seco = 58,4%
#      do fresco (biomassa total), carbono = 48,5% do seco.
#    - Higuchi et al. (2004), Revista Floresta 34(3):295-304: água
#      média = 40% (seco ~ 60% do fresco), carbono = 48% do seco.
#  Os três valores (60,28% / 58,4% / ~60%) convergem, o que reduz a
#  chance de o fator de Higuchi et al. (1998) estar equivocado.
# ══════════════════════════════════════════════════════════════════

#' Converte peso fresco (Higuchi et al. 1998) em peso seco
#' @param peso_fresco_kg Peso fresco, kg/árvore
#' @param fator Fração seco/fresco. Default 0,6028 (Tabela 3b, n=38,
#'        média entre todos os compartimentos). Ajustável se o usuário
#'        tiver fator específico por compartimento (Tabela 3b: tronco
#'        61%, copa 58%).
#' @return Peso seco, kg/árvore

converter_fresco_seco <- function(peso_fresco_kg, fator = 0.6028) {
  peso_fresco_kg * fator
}

#' Converte peso seco em carbono
#' @param peso_seco_kg Peso seco, kg/árvore
#' @param teor_c Fração de carbono. Default 0,48 (tronco, o compartimento
#'        dominante — 65,6% do peso total segundo Higuchi et al. 1998,
#'        item 6). Para estimativa mais fina por compartimento, seria
#'        necessário particionar tronco/galho/folha antes de aplicar
#'        teores distintos (48% / 47% / 39%).
#' @return Carbono, kg/árvore

carbono_de_seco <- function(peso_seco_kg, teor_c = 0.48) {
  peso_seco_kg * teor_c
}

#' Carbono acima do solo a partir do DAP, aplicando a cadeia completa
#' fresco -> seco -> carbono. Substitui a antiga carbono_higuchi(), que
#' aplicava a fração de carbono direto sobre peso fresco e por isso
#' SUPERESTIMAVA o carbono em ~1,66x. Ver nota de correção v0.3.
#' @param dap DAP em cm · @return Carbono em kg/árvore

carbono_higuchi <- function(dap) {
  pf <- biomassa_higuchi(dap)
  ps <- converter_fresco_seco(pf)
  carbono_de_seco(ps)
}

#' Biomassa pantropical — Chave et al. (2014), modelo com altura
#' Mantida por compatibilidade com chamadas antigas.
#' @param dap DAP em cm; @param altura H em m; @param wd Densidade g/cm³

biomassa_chave <- function(dap, altura, wd = 0.6) {
  biomassa_alometrica(dap = dap, altura = altura, wd = wd, equacao = "chave_2014_h")
}

#' Área basal individual · @param dap DAP em cm · @return m²

area_basal <- function(dap) pi * (dap / 200)^2


# ══════════════════════════════════════════════════════════════════
#  FATOR DE CORREÇÃO POR ALTURA DOMINANTE (método CADAF/LMF-INPA)
#
#  Quando não há inventário de campo próprio para calibrar a equação
#  de Higuchi et al. (1998) — caso de T1 e T2 no BIODATUM — o LMF/INPA
#  usa, desde o projeto CADAF, um fator de correção baseado na razão
#  entre a altura dominante do sítio de aplicação e a altura dominante
#  do sítio onde a equação foi calibrada (Estação Experimental de
#  Silvicultura Tropical, ZF-2, Manaus). A altura dominante é obtida
#  em campo de árvores caídas naturalmente, sem necessidade de abate.
#
#  MÉTODO E VALOR DE CALIBRAÇÃO CONFIRMADOS (v0.5): a altura dominante
#  de Manaus (ZF-2) é 30,2 m, estimada como a média das alturas totais
#  das 10% árvores mais grossas amostradas — método validado por ANOVA
#  entre diferentes definições de altura dominante (HIGUCHI, F.G. 2015.
#  Dinâmica de volume e biomassa da floresta de terra firme do
#  Amazonas. Tese de Doutorado, UFPR, Curitiba, Tabela 20 e 21). A
#  mesma tese aplicou o fator a 11 sítios reais do Amazonas (fc entre
#  0,850 e 1,096) e testou por ANCOVA se uma equação única serviria
#  para todo o estado — rejeitada (p < 0,000001 em todos os sítios),
#  reforçando de forma independente o mesmo achado de Higuchi, F.G.
#  et al. (2014, cap. 2) já citado na tese do BIODATUM.
#
#  Aqui, a altura dominante é aproximada pelo RH98 do GEDI L2A (já
#  usado no componente E do IRFA), o que permite aplicar o fator sem
#  custo adicional de aquisição de dados. Este procedimento NÃO
#  substitui a calibração direta com inventário de campo (INPA/RAINFOR)
#  caso ela seja confirmada dentro dos polígonos de T1/T2 — é um
#  substituto declarado e transparente na ausência dela.
# ══════════════════════════════════════════════════════════════════

#' Fator de correção da biomassa por altura dominante
#' @param h_dom_sitio Altura dominante do sítio de aplicação (m). No
#'   BIODATUM, aproximada pelo RH98 médio do GEDI L2A no polígono.
#' @param h_dom_calibracao Altura dominante do sítio onde a equação de
#'   Higuchi et al. (1998) foi calibrada (ZF-2, Manaus). Default 30,2 m,
#'   CONFIRMADO por Higuchi, F.G. (2015, Tabela 21) — média das alturas
#'   totais das 10% árvores mais grossas amostradas em árvores caídas
#'   naturalmente na ZF-2.
#' @return Fator multiplicativo a aplicar sobre biomassa_higuchi()

fator_correcao_altura_dominante <- function(h_dom_sitio, h_dom_calibracao = 30.2) {
  if (h_dom_calibracao <= 0) stop("h_dom_calibracao deve ser > 0.")
  h_dom_sitio / h_dom_calibracao
}

#' Biomassa fresca de Higuchi corrigida por altura dominante do sítio
#' @param dap DAP em cm
#' @param h_dom_sitio Altura dominante do sítio (m), ex.: RH98/GEDI
#' @param h_dom_calibracao Altura dominante do sítio de calibração (m),
#'   default 30,2 m (Manaus, ZF-2 — Higuchi, F.G. 2015)
#' @return Peso fresco corrigido, kg/árvore

biomassa_higuchi_corrigida <- function(dap, h_dom_sitio, h_dom_calibracao = 30.2) {
  fc <- fator_correcao_altura_dominante(h_dom_sitio, h_dom_calibracao)
  biomassa_higuchi(dap) * fc
}


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


# ══════════════════════════════════════════════════════════════════
#  MÓDULO 3 — INVENTÁRIO FLORESTAL
# ══════════════════════════════════════════════════════════════════

#' Resumo de parcela com equações de Higuchi et al. (1998)
#' Aplica a cadeia completa peso fresco -> peso seco -> carbono,
#' usando os fatores do próprio artigo (Tabela 3b; item 7).
#' @param dados Data frame com colunas dap e especie
#' @param area_parcela_ha Área em ha (padrão: 1 ha)

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
#' @param bref Biomassa SECA de referência, Mg/ha. ATENÇÃO: o valor de
#'   307 Mg/ha usado em versões anteriores não foi localizado no artigo
#'   Higuchi et al. (1998) — não há citação verificável para esse número.
#'   Use um valor de referência territorial real (ex.: derivado do GEDI
#'   L4A para T1/T2) em vez do default. O default é mantido apenas por
#'   compatibilidade e deve ser tratado como ilustrativo.

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


# ══════════════════════════════════════════════════════════════════
#  EXEMPLOS — RODE DAQUI PARA BAIXO
#  Selecione as linhas que quiser e aperte Ctrl+Enter
# ══════════════════════════════════════════════════════════════════

# ── EXEMPLO 1: Equações de Higuchi (peso fresco -> seco -> carbono) ─
cat("── 1. Cadeia fresco -> seco -> carbono (Higuchi et al. 1998) ──\n")
arvores <- data.frame(
  especie = c("Eschweilera coriacea","Piptadenia suaveolens","Scleronema micranthum",
              "Qualea paraensis","Goupia glabra","Minquartia guianensis"),
  dap     = c(28.3, 15.6, 12.4, 22.1, 35.0, 18.9),
  altura  = c(7.2,  5.8,  5.2,  7.5,  9.1,  6.4)
) %>%
  mutate(peso_fresco_kg = round(biomassa_higuchi(dap), 1),
         peso_seco_kg   = round(converter_fresco_seco(peso_fresco_kg), 1),
         carbono_kg     = round(carbono_de_seco(peso_seco_kg), 1),
         g_m2           = round(area_basal(dap), 4))
print(arvores)


# ── EXEMPLO 2: Resumo de parcela ────────────────────────────────
cat("\n── 2. Resumo da Parcela (1000 m²) ──\n")
resumo_parcela(arvores, area_parcela_ha = 0.1)


# ── EXEMPLO 3: IRFA — cinco componentes (BIODATUM Seção 3.3) ────
# ATENÇÃO: valores ilustrativos, NÃO são resultados de T1 ou T2.
cat("── 3. IRFA — exemplo ilustrativo ──\n")
r <- calcular_irfa(B = 0.71, C = 0.66, E = 0.78, R = 0.52, P = 0.05)
imprimir_irfa(r)

# Análise de sensibilidade dos pesos (prevista na Seção 3.3 da tese).
r_sens <- calcular_irfa(B = 0.71, C = 0.66, E = 0.78, R = 0.52, P = 0.05,
                        pesos = c(B = 0.25, C = 0.15, E = 0.20,
                                  R = 0.25, P = 0.15))
imprimir_irfa(r_sens)


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
  cenario            = "Exemplo ilustrativo"
)


# ── EXEMPLO 6: Gráfico — Componentes IRFA ───────────────────────
cat("── 6. Gráfico: Componentes do IRFA ──\n")
plotar_componentes_irfa(r, cenario = "Exemplo ilustrativo")


# ── EXEMPLO 7: Distribuição diamétrica ──────────────────────────
cat("── 7. Distribuição Diamétrica ──\n")
print(distribuicao_diametrica(arvores$dap, amplitude = 5))
plotar_distribuicao_diametrica(arvores$dap)


# ── EXEMPLO 8: Catálogo de equações disponíveis ─────────────────
cat("── 8. Catálogo de Equações Alométricas ──\n")
print(equacoes_alometricas())

# ── EXEMPLO 9: Comparação Higuchi (regional) vs. Chave (pantropical)
# Demonstra por que a comparação exige cuidado de unidade: Higuchi
# retorna peso FRESCO, Chave retorna AGB SECA. Comparar direto sem
# converter produz uma diferença artificial (~40%) que é, em grande
# parte, o teor de água da madeira (~39,7%, Tabela 3b), não
# necessariamente uma diferença real de calibração regional.
# ATUALIZAÇÃO v0.3: o argumento "regional > pantropical" na tese não
# depende mais de um percentual solto — está ancorado em Higuchi, F.G.
# et al. (2014), que testou estatisticamente (ANCOVA, variável dummy)
# se uma equação única serve para toda a Amazônia e REJEITOU essa
# hipótese (p < 0,000000). Este exemplo permanece como demonstração
# numérica do cuidado de unidade (fresco vs. seco), não como fonte do
# argumento da tese.
cat("── 9. Higuchi (regional, seco) vs. Chave (pantropical, seco) ──\n")
dap_teste <- 30; wd_teste <- 0.65
higuchi_seco <- converter_fresco_seco(biomassa_higuchi(dap_teste))
chave_seco   <- biomassa_alometrica(dap = dap_teste, wd = wd_teste,
                                    equacao = "chave_2005")
cat(sprintf("  DAP = %d cm | Higuchi (seco) = %.1f kg | Chave 2005 (seco) = %.1f kg | diff = %.1f%%\n",
            dap_teste, higuchi_seco, chave_seco,
            (chave_seco/higuchi_seco - 1) * 100))


# ── EXEMPLO 10: Fator de correção por altura dominante (CADAF) ──
# Demonstra o procedimento institucional do LMF/INPA para aplicar a
# equação de Manaus em sítios sem calibração destrutiva própria (caso
# de T1 e T2). Valores de h_dom_sitio são os RH98 médios REAIS do
# GEDI L2A extraídos para T1 e T2 (BIODATUM_IRFA_componentes_T1_T2.csv).
# h_dom_calibracao usa o default confirmado (30,2 m, Manaus/ZF-2).
cat("── 10. Fator de correção por altura dominante (CADAF/LMF-INPA) ──\n")
h_dom_T1 <- 21.27  # RH98 médio real, T1 Puranga Conquista (GEDI L2A)
h_dom_T2 <- 21.38  # RH98 médio real, T2 Rio Madeira (GEDI L2A)
fc_T1 <- fator_correcao_altura_dominante(h_dom_T1)
fc_T2 <- fator_correcao_altura_dominante(h_dom_T2)
cat(sprintf("  T1: fator = %.3f | T2: fator = %.3f\n", fc_T1, fc_T2))
cat(sprintf("  DAP=30cm sem correção: %.1f kg | T1 corrigido: %.1f kg | T2 corrigido: %.1f kg\n",
            biomassa_higuchi(30),
            biomassa_higuchi_corrigida(30, h_dom_T1),
            biomassa_higuchi_corrigida(30, h_dom_T2)))
cat("  NOTA: RH98 do GEDI mede altura de dossel via LiDAR espacial, não é\n")
cat("  idêntico à altura dominante de campo (10% árvores mais grossas) que\n")
cat("  calibra o fc original — mas é a melhor aproximação disponível sem\n")
cat("  inventário de campo em T1/T2. Declarar essa aproximação na tese.\n")



# ── EXEMPLO 11: Padrão da triangulação IRFA-IPTA (Quadro 7) ─────
# ATENÇÃO: valores ilustrativos, não são resultados de T1 ou T2.
cat("── 11. Classificação do padrão IRFA-IPTA (Quadro 7) ──\n")
casos <- list(
  c(irfa = 0.75, ipta = 0.72),  # esperado: A - Coerência
  c(irfa = 0.72, ipta = 0.18),  # esperado: B - Defasagem por exclusão
  c(irfa = 0.15, ipta = 0.12),  # esperado: C - Ruptura sistematizada
  c(irfa = 0.18, ipta = 0.78),  # esperado: D - Otimismo desacoplado
  c(irfa = 0.50, ipta = 0.65)   # esperado: Indeterminado (IRFA moderado)
)
for (caso in casos) {
  r <- classificar_padrao_dse(caso["irfa"], caso["ipta"])
  cat(sprintf("  IRFA=%.2f IPTA=%.2f | DSE=%+.2f ICS=%.2f | %s\n",
              caso["irfa"], caso["ipta"], r$dse, r$ics, r$padrao))
}
