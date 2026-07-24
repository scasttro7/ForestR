# alometria.R
# ---------------------------------------------------------------------------
# Módulo 1 — Equações alométricas tropicais + fator de correção por altura
# dominante (CADAF/LMF-INPA). Extraído do script original ForestR_v0.6.R.
# Fonte primária verificada: Higuchi et al. (1998), Acta Amazonica 28(2).
# ---------------------------------------------------------------------------

# ══════════════════════════════════════════════════════════════════
#  MÓDULO 1 — EQUAÇÕES ALOMÉTRICAS TROPICAIS
#  Fonte primária verificada: Higuchi et al. (1998), Acta Amazonica
#  28(2):153-166 [conferida linha a linha nesta versão — ver nota v0.3]
#  Demais equações: conforme Equacoes_Alometricas_Tropicais_BIODATUM.pdf
# ══════════════════════════════════════════════════════════════════

#' Catálogo das equações alométricas incorporadas ao ForestR
#' @return data.frame com identificadores, região, variáveis e fórmula resumida
#' @export

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

#' @export

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

#' @export
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

#' @export
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

#' @export
carbono_de_seco <- function(peso_seco_kg, teor_c = 0.48) {
  peso_seco_kg * teor_c
}

#' Carbono acima do solo a partir do DAP, aplicando a cadeia completa
#' fresco -> seco -> carbono. Substitui a antiga carbono_higuchi(), que
#' aplicava a fração de carbono direto sobre peso fresco e por isso
#' SUPERESTIMAVA o carbono em ~1,66x. Ver nota de correção v0.3.
#' @param dap DAP em cm · @return Carbono em kg/árvore

#' @export
carbono_higuchi <- function(dap) {
  pf <- biomassa_higuchi(dap)
  ps <- converter_fresco_seco(pf)
  carbono_de_seco(ps)
}

#' Biomassa pantropical — Chave et al. (2014), modelo com altura
#' Mantida por compatibilidade com chamadas antigas.
#' @param dap DAP em cm; @param altura H em m; @param wd Densidade g/cm³

#' @export
biomassa_chave <- function(dap, altura, wd = 0.6) {
  biomassa_alometrica(dap = dap, altura = altura, wd = wd, equacao = "chave_2014_h")
}

#' Área basal individual · @param dap DAP em cm · @return m²

#' @export
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

#' @export
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

#' @export
biomassa_higuchi_corrigida <- function(dap, h_dom_sitio, h_dom_calibracao = 30.2) {
  fc <- fator_correcao_altura_dominante(h_dom_sitio, h_dom_calibracao)
  biomassa_higuchi(dap) * fc
}

