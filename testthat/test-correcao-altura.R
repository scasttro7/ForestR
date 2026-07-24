# test-correcao-altura.R
# Extraído de test-ForestR.R — testes do fator de correção por altura
# dominante (método CADAF/LMF-INPA), introduzido na v0.4/v0.5.

test_that("fator_correcao_altura_dominante usa o default confirmado (30,2 m, Higuchi F.G. 2015)", {
  expect_equal(fator_correcao_altura_dominante(30.2), 1, tolerance = 1e-9)
  expect_equal(formals(fator_correcao_altura_dominante)$h_dom_calibracao, 30.2)
})

test_that("fator_correcao_altura_dominante rejeita calibração <= 0", {
  expect_error(fator_correcao_altura_dominante(20, h_dom_calibracao = 0))
})

test_that("biomassa_higuchi_corrigida aplica o fator corretamente sobre biomassa_higuchi", {
  dap <- 30; h_sitio <- 21.3
  esperado <- biomassa_higuchi(dap) * (h_sitio / 30.2)
  expect_equal(biomassa_higuchi_corrigida(dap, h_sitio), esperado, tolerance = 1e-9)
})
