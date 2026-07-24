# test-alometria.R
# Extraído de test-ForestR.R — cobre exatamente as equações que já tiveram
# erro real em sessões de trabalho anteriores (coeficientes trocados,
# cadeia fresco->seco->carbono superestimando 66%).

test_that("biomassa_higuchi usa os coeficientes corretos do artigo (não os da nota técnica errada)", {
  # Considerações Finais, item 3, Modelo 1:
  #   ln P = -1,754 + 2,665 ln D ; 5<=DAP<20   -> P = exp(-1,754)*D^2,665
  #   ln P = -0,151 + 2,170 ln D ; DAP>=20     -> P = exp(-0,151)*D^2,170
  esperado_10 <- exp(-1.754 + 2.665 * log(10))
  esperado_30 <- exp(-0.151 + 2.170 * log(30))
  expect_equal(biomassa_higuchi(10), esperado_10, tolerance = 1e-6)
  expect_equal(biomassa_higuchi(30), esperado_30, tolerance = 1e-6)
})

test_that("biomassa_higuchi NÃO reproduz os coeficientes errados da nota técnica (0,0576 / 0,1281)", {
  errado_10 <- 0.0576 * 10^2.665
  errado_30 <- 0.1281 * 30^2.170
  expect_false(isTRUE(all.equal(biomassa_higuchi(10), errado_10, tolerance = 0.01)))
  expect_false(isTRUE(all.equal(biomassa_higuchi(30), errado_30, tolerance = 0.01)))
})

test_that("biomassa_higuchi seleciona a equação certa por classe de DAP", {
  expect_equal(biomassa_higuchi(19.9), exp(-1.754 + 2.665 * log(19.9)), tolerance = 1e-6)
  expect_equal(biomassa_higuchi(20.0), exp(-0.151 + 2.170 * log(20.0)), tolerance = 1e-6)
})

test_that("biomassa_higuchi rejeita DAP <= 0", {
  expect_error(biomassa_higuchi(0))
  expect_error(biomassa_higuchi(-5))
})

test_that("converter_fresco_seco aplica o fator correto (Tabela 3b, Higuchi et al. 1998)", {
  expect_equal(converter_fresco_seco(100), 60.28, tolerance = 1e-6)
})

test_that("carbono_de_seco aplica o teor de carbono correto (48%)", {
  expect_equal(carbono_de_seco(100), 48, tolerance = 1e-6)
})

test_that("carbono_higuchi aplica a cadeia completa e NÃO superestima em 1,66x", {
  dap <- 30
  pf <- biomassa_higuchi(dap)
  c_correto <- pf * 0.6028 * 0.48
  c_errado_direto <- pf * 0.47  # erro histórico: carbono direto sobre peso fresco
  expect_equal(carbono_higuchi(dap), c_correto, tolerance = 1e-6)
  razao <- carbono_higuchi(dap) / pf
  expect_equal(razao, 0.6028 * 0.48, tolerance = 1e-6)
  expect_false(isTRUE(all.equal(carbono_higuchi(dap), c_errado_direto, tolerance = 0.05)))
})

test_that("a razão carbono/peso-fresco é constante em toda a faixa de DAP", {
  razoes <- sapply(c(10, 20, 30, 50, 80), function(d) carbono_higuchi(d) / biomassa_higuchi(d))
  expect_true(all(abs(razoes - razoes[1]) < 1e-9))
})

test_that("biomassa_higuchi é sempre positiva e cresce com o DAP", {
  daps <- c(5, 10, 20, 30, 50, 80, 120)
  valores <- sapply(daps, biomassa_higuchi)
  expect_true(all(valores > 0))
  expect_true(all(diff(valores) > 0))
})

test_that("area_basal bate com a fórmula pi*(DAP/200)^2", {
  expect_equal(area_basal(20), pi * (20/200)^2, tolerance = 1e-9)
})
