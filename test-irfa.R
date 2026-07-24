# test-irfa.R
# Extraído de test-ForestR.R — cobre IRFA, classificação fuzzy e os quatro
# padrões da triangulação IRFA-IPTA (Quadro 7 da tese).

test_that("calcular_irfa usa média NÃO ponderada por default", {
  r <- calcular_irfa(B = 1, C = 1, E = 1, R = 1, P = 0)
  expect_equal(r$irfa, 1, tolerance = 1e-9)
  r2 <- calcular_irfa(B = 0, C = 0, E = 0, R = 0, P = 1)
  expect_equal(r2$irfa, 0, tolerance = 1e-9)
})

test_that("calcular_irfa trata P como complemento (1-P), não como termo direto", {
  r_baixo_p <- calcular_irfa(B = 0.7, C = 0.7, E = 0.7, R = 0.7, P = 0.1)
  r_alto_p  <- calcular_irfa(B = 0.7, C = 0.7, E = 0.7, R = 0.7, P = 0.9)
  expect_true(r_baixo_p$irfa > r_alto_p$irfa)
})

test_that("classificar_fuzzy usa os cinco níveis e limiares corretos (Seção 3.3 da tese)", {
  expect_equal(classificar_fuzzy(0.10), "Muito baixo")
  expect_equal(classificar_fuzzy(0.20), "Muito baixo")
  expect_equal(classificar_fuzzy(0.30), "Baixo")
  expect_equal(classificar_fuzzy(0.50), "Moderado")
  expect_equal(classificar_fuzzy(0.70), "Alto")
  expect_equal(classificar_fuzzy(0.90), "Muito alto")
})

test_that("calcular_irfa aceita pesos alternativos para análise de sensibilidade sem alterar o default", {
  r_default <- calcular_irfa(B = 0.7, C = 0.6, E = 0.8, R = 0.5, P = 0.1)
  r_pesado  <- calcular_irfa(B = 0.7, C = 0.6, E = 0.8, R = 0.5, P = 0.1,
                             pesos = c(B = 0.4, C = 0.1, E = 0.2, R = 0.2, P = 0.1))
  expect_false(isTRUE(all.equal(r_default$irfa, r_pesado$irfa)))
  expect_match(r_default$modo, "não ponderada")
})

test_that("classificar_padrao_dse reproduz os quatro padrões do Quadro 7", {
  expect_match(classificar_padrao_dse(0.75, 0.72)$padrao, "^A")
  expect_match(classificar_padrao_dse(0.72, 0.18)$padrao, "^B")
  expect_match(classificar_padrao_dse(0.15, 0.12)$padrao, "^C")
  expect_match(classificar_padrao_dse(0.18, 0.78)$padrao, "^D")
})

test_that("classificar_padrao_dse retorna Indeterminado quando IRFA ou IPTA está em Moderado", {
  expect_match(classificar_padrao_dse(0.50, 0.65)$padrao, "Indeterminado")
  expect_match(classificar_padrao_dse(0.65, 0.50)$padrao, "Indeterminado")
})

test_that("classificar_padrao_dse calcula DSE e ICS corretamente", {
  r <- classificar_padrao_dse(0.75, 0.72)
  expect_equal(r$dse, 0.75 - 0.72, tolerance = 1e-9)
  expect_equal(r$ics, 1 - abs(0.75 - 0.72), tolerance = 1e-9)
})

test_that("classificar_padrao_dse rejeita valores fora de 0-1", {
  expect_error(classificar_padrao_dse(1.2, 0.5))
  expect_error(classificar_padrao_dse(0.5, -0.1))
})
