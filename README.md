# ForestR

<!-- badges: start -->
![status](https://img.shields.io/badge/status-desenvolvimento-yellow)
![tests](https://img.shields.io/badge/testes-21%2F21%20passando-brightgreen)
<!-- badges: end -->

Análise alométrica, IRFA (Índice de Resiliência Florestal Amazônica) e
inventário florestal para florestas tropicais — Amazônia, Bacia do Congo,
Sudeste Asiático e modelos pantropicais. Metodologia validada contra
Higuchi et al. (1998) ao longo de oito iterações de correção (v0.1–v0.8),
com histórico completo em `NEWS.md`.

O IRFA segue a **arquitetura em três níveis** da tese BIODATUM (Seção 3.6):
Mensuração (`calcular_irfa()`) → Comparação (DSE/ICS) → Interpretação
(`classificar_padrao_dse()`, Quadro 7) — ver cabeçalho de `R/irfa.R`.

Pacote metodológico do projeto de tese **BIODATUM** (PPGCASA/UFAM). O
[`EcoBiomasBR`](https://github.com/scasttro7/EcoBiomasBR) importa deste
pacote a lógica de correção alométrica para a Amazônia, evitando duplicar
metodologia.

## Instalação

```r
remotes::install_github("scasttro7/ForestR")
```

## Uso básico

```r
library(ForestR)

# Biomassa fresca (Higuchi et al. 1998), seleção automática por classe de DAP
biomassa_higuchi(dap = 30)

# Cadeia completa fresco -> seco -> carbono
carbono_higuchi(dap = 30)

# Fator de correção por altura dominante (protocolo CADAF/LMF-INPA)
biomassa_higuchi_corrigida(dap = 30, h_dom_sitio = 21.3)

# IRFA (Índice de Resiliência Florestal Amazônica)
r <- calcular_irfa(B = 0.71, C = 0.66, E = 0.78, R = 0.52, P = 0.05)
imprimir_irfa(r)

# Padrão da triangulação IRFA-IPTA (Quadro 7 da tese)
classificar_padrao_dse(irfa = 0.75, ipta = 0.72)
```

## Módulos

| Módulo | Conteúdo |
|---|---|
| `alometria.R` | Catálogo de 19 equações alométricas (4 regiões tropicais), cadeia fresco→seco→carbono, fator de correção por altura dominante |
| `irfa.R` | `calcular_irfa()`, classificação fuzzy em 5 níveis, `classificar_padrao_dse()` (Quadro 7) |
| `inventario.R` | `resumo_parcela()`, `distribuicao_diametrica()` |
| `diversidade.R` | `diversidade_shannon()` (Shannon-Wiener, Pielou) |
| `visualizacoes.R` | Gráficos temáticos ggplot2: trajetória IRFA, componentes IRFA, distribuição diamétrica |
| `tema.R` | Paleta de cores e `theme_forestr()` |
| `validacao.R` | Validação de DAP e parâmetros obrigatórios |

## Cobertura regional das equações alométricas

| Região | Fontes |
|---|---|
| Amazônia | Higuchi et al. (1998, 3 variantes), Chambers et al. (2001), Nogueira et al. (2008), Baia et al. (2025) |
| Pantropical | Chave et al. (2005), Chave et al. (2014, 2 modelos) |
| Bacia do Congo | Djomo et al. (2010), Fayolle et al. (2013, 2018, 2024), Ngomanda et al. (2014) |
| Sudeste Asiático | Brown et al. (1997), Komiyama et al. (2008), Basuki et al. (2009), Kenzo et al. (2009), Rutishauser et al. (2013) |

Use `equacoes_alometricas()` para ver o catálogo completo com fórmulas e
unidades de saída — **atenção**: as equações de Higuchi et al. (1998)
retornam peso *fresco*; as demais retornam AGB *seca*. Nunca compare
diretamente sem converter (ver `converter_fresco_seco()`).

## Testes

```
tests/testthat/
├── test-alometria.R         (10 testes)
├── test-correcao-altura.R    (3 testes)
└── test-irfa.R                (8 testes)
```

**21/21 testes passando**, cobrindo especificamente as equações que já
tiveram erro real em versões anteriores (coeficientes de Higuchi trocados,
cadeia fresco→seco→carbono superestimando 66%, fator de correção por altura
dominante).

## Roadmap

- [ ] Testes formais para inventário, diversidade e visualizações
- [ ] Confirmar `h_dom_calibracao` e demais valores default ainda sinalizados como pendentes de fonte
- [ ] GitHub Actions (`R CMD check`)
- [ ] Decisão de licença

## Licença

A definir.
