# ForestR

Pacote em R para o subsistema biofísico do framework **BIODATUM** — cálculo de biomassa, carbono e do Índice de Resiliência Florestal Amazônica (IRFA), com equações verificadas contra fonte primária.

**Versão atual:** v0.8 (primeira versão executada de ponta a ponta, sem erro)
**Autora:** Sabrina Castro da Silva · Doutoranda, PPGCASA/UFAM
**Framework:** BIODATUM — tese "O que a floresta guarda?"
**Testes:** 42/42 passando (`testthat`)
**Licença:** a definir — não decidida até a qualificação (dezembro/2026)

> **Nota sobre versões anteriores:** uma versão inicial deste README (v0.1-alpha) continha equações e descrições que não correspondiam ao código real e foram descontinuadas. Este documento reflete apenas o que está implementado e testado em `ForestR_v0.8.R`.

---

## O que é o ForestR

ForestR implementa três módulos, organizados segundo a arquitetura de três níveis do BIODATUM (Seção 3.6 da tese): **mensuração → comparação → interpretação**.

| Nível | O que faz | Módulo |
|---|---|---|
| 1. Mensuração | Calcula os subsistemas primários de forma independente | Módulos 1 e 2 |
| 2. Comparação | Relaciona IRFA e IPTA numa escala comum (DSE, ICS) | `classificar_padrao_dse()` |
| 3. Interpretação | Nomeia padrões descritivos (Quadro 7), sem recomendar ação | `classificar_padrao_dse()` |

ForestR **não é** uma ferramenta de apoio à decisão para gestores — essa camada está fora do escopo desta tese, declarada como linha de pesquisa de pós-doutorado.

---

## Instalação

```r
# Dependências
install.packages(c("dplyr", "ggplot2", "scales", "testthat"))

# Carregar o pacote
source("ForestR_v0.8.R")
```

Requisitos: R ≥ 4.0. Testado em Linux (Ubuntu); sem dependências de sistema além dos pacotes acima.

---

## Módulo 1 — Biomassa e Carbono

Equações alométricas de **Higuchi et al. (1998)**, *Acta Amazonica* 28(2):153-166, verificadas diretamente contra a fonte primária (Considerações Finais, item 3, Modelo 1).

| Função | Descrição | Retorno |
|---|---|---|
| `biomassa_higuchi(dap)` | Peso fresco individual. Regime duplo: DAP < 20 cm e DAP ≥ 20 cm | kg/árvore (peso fresco) |
| `converter_fresco_seco(peso_fresco_kg, fator=0.6028)` | Converte peso fresco em peso seco (Tabela 3b, Higuchi et al. 1998) | kg/árvore (peso seco) |
| `carbono_de_seco(peso_seco_kg, teor_c=0.48)` | Converte peso seco em carbono | kg C/árvore |
| `carbono_higuchi(dap)` | Cadeia completa: fresco → seco → carbono, em uma chamada | kg C/árvore |
| `biomassa_alometrica(...)` | Catálogo de equações alométricas (Higuchi, Chave, regionais) para comparação | kg/árvore |
| `biomassa_chave(dap, altura, wd)` | Equação pantropical de Chave et al. (2014), para comparação/validação cruzada | kg/árvore |
| `fator_correcao_altura_dominante(h_dom_sitio, h_dom_calibracao=30.2)` | Fator de correção CADAF/LMF-INPA por altura dominante | adimensional |
| `biomassa_higuchi_corrigida(dap, h_dom_sitio, h_dom_calibracao=30.2)` | Biomassa corrigida pelo fator de altura dominante | kg/árvore |

**Correção crítica documentada:** versões anteriores calculavam carbono aplicando um fator direto sobre o peso fresco, o que superestima o carbono em cerca de 62–66% (ver changelog completo em `ForestR_v0.8.R`, cabeçalho). A cadeia correta é fresco → seco (×0,6028) → carbono (×0,48), confirmada por três fontes independentes do LMF/INPA: Higuchi et al. (1998), Silva (2007) e Higuchi et al. (2004).

### Catálogo de equações alométricas — `equacoes_alometricas()` / `biomassa_alometrica()`

O ForestR mantém um catálogo de 19 equações alométricas de biomassa, cobrindo Amazônia, Bacia do Congo, Sudeste Asiático e pantropical — usado para comparação e validação cruzada, nunca como default silencioso.

```r
equacoes_alometricas()          # lista as 19 equações, com fórmula, região e unidade de saída
biomassa_alometrica(dap = 30, equacao = "chave_2005", wd = 0.65)  # calcula com uma equação específica
```

| Região | Equações no catálogo |
|---|---|
| Amazônia | Higuchi et al. (1998) — 3 variantes; Chambers et al. (2001); Nogueira et al. (2008); Baia et al. (2025, modelo H-D) |
| Bacia do Congo | Djomo et al. (2010); Fayolle et al. (2013, 2018, 2024); Ngomanda et al. (2014); Brown et al. (1997, FAO); Komiyama et al. (2008) |
| Sudeste Asiático | Basuki et al. (2009); Kenzo et al. (2009); Rutishauser et al. (2013, modelo H-D) |
| Pantropical | Chave et al. (2005, 2014 — modelos I e II) |

**Status de verificação — importante:** apenas as equações de **Higuchi et al. (1998)** foram conferidas diretamente contra o artigo original (Considerações Finais, item 3). As demais 16 equações do catálogo **não foram verificadas individualmente** contra suas fontes primárias — foram digitadas a partir de nota técnica de referência e ainda precisam de conferência, uma a uma, antes de qualquer uso em publicação. Duas delas (`baia_2025_hd`, `rutishauser_2013_hd`) são modelos altura-diâmetro, não de biomassa — chamá-las por `biomassa_alometrica()` retorna erro deliberado, não um número.

Trate o catálogo como ponto de partida para comparação, não como equações prontas para citar sem checagem.

### Exemplo

```r
dap <- 28.3
agb <- biomassa_higuchi(dap)
c_stock <- carbono_higuchi(dap)

cat("Peso fresco:", round(agb, 1), "kg/árvore\n")
cat("Carbono:", round(c_stock, 1), "kg C/árvore\n")

# Saída real:
# Peso fresco: 1215.6 kg/árvore
# Carbono: 351.7 kg C/árvore
```

---

## Módulo 2 — IRFA (Índice de Resiliência Florestal Amazônica)

```r
IRFA = (B + C + E + R + (1 − P)) / 5
```

em que B = biomassa, C = ciclo do carbono, E = estrutura do dossel, R = recuperação pós-perturbação, P = perturbação antrópica acumulada (entra como complemento, 1 − P).

**Média não ponderada por padrão** — decisão metodológica deliberada (Seção 3.3 da tese): na ausência de consenso empírico sobre a contribuição relativa de cada componente, atribuir pesos a priori introduziria arbitrariedade não fundamentada. Pesos alternativos podem ser passados via `pesos=` apenas para análise de sensibilidade — nunca como default.

| Função | Descrição |
|---|---|
| `calcular_irfa(B, C, E, R, P, pesos=NULL)` | Calcula o IRFA. `pesos` é opcional, só para sensibilidade |
| `classificar_fuzzy(x)` | Classifica um score 0–1 em 5 níveis (Muito baixo → Muito alto) |
| `imprimir_irfa(resultado)` | Exibe laudo formatado |
| `plotar_componentes_irfa(resultado)` | Gráfico de barras dos componentes |
| `plotar_trajetoria_irfa(...)` | Curva de recuperação pós-perturbação |

### Exemplo

```r
resultado <- calcular_irfa(B = 0.62, C = 0.58, E = 0.66, R = 0.55, P = 0.22)
imprimir_irfa(resultado)

# IRFA Score: 0.6380
# Classificação: Alto
```

---

## Comparação e Interpretação — DSE, ICS e Padrões (Quadro 7)

```r
r <- classificar_padrao_dse(irfa = 0.75, ipta = 0.72)
# r$padrao  -> "A — Coerência"
# r$dse     -> 0.03
# r$ics     -> 0.97
```

Formaliza os quatro padrões descritivos do Quadro 7 (Seção 3.6 da tese) usando a classificação fuzzy já existente — nenhum limiar novo foi inventado. Retorna `"Indeterminado"` quando IRFA ou IPTA caem em "Moderado", para não forçar classificação onde o dado é ambíguo. **Função descritiva: nomeia o padrão, não recomenda ação.**

---

## Módulo 3 — Inventário Florestal

| Função | Descrição |
|---|---|
| `resumo_parcela(dados, area_parcela_ha=1)` | N/ha, área basal, DAP médio, biomassa e carbono total |
| `diversidade_shannon(especies)` | H' de Shannon-Wiener, J' de Pielou, riqueza |
| `distribuicao_diametrica(dap, amplitude=5)` | Distribuição por classes de DAP |
| `plotar_distribuicao_diametrica(dap, ...)` | Histograma (padrão J-invertido esperado) |

---

## Testes

```r
library(testthat)
source("ForestR_v0.8.R")
test_file("test-ForestR.R")
# [ FAIL 0 | WARN 0 | SKIP 0 | PASS 42 ]
```

Os testes cobrem exatamente os erros reais encontrados durante o desenvolvimento (coeficientes de Higuchi, cadeia fresco-seco-carbono, continuidade entre classes de DAP, lógica do IRFA e dos quatro padrões) — para que nenhum reapareça sem ser detectado.

---

## O que ForestR NÃO faz

- Não modela desmatamento nem cenários futuros de uso do solo — isso não faz parte deste pacote.
- Não calibra pesos do IRFA via PCA ou qualquer outro método estatístico — a média é deliberadamente não ponderada.
- Não recomenda ações de gestão a partir dos Padrões A–D — apenas os nomeia.
- Não é, ainda, um pacote R formal (sem `DESCRIPTION`/`NAMESPACE`) — consolidação como pacote está em andamento, sem prazo de publicação em CRAN/GitHub definido.

---

## Como citar

Enquanto a tese não é defendida, cite como material em desenvolvimento:

```
CASTRO DA SILVA, S. ForestR: pacote R para o subsistema biofísico do BIODATUM.
PPGCASA/UFAM, 2026. Material em desenvolvimento, não publicado.
```

Não cite ForestR como artigo publicado em periódico — nenhum artigo sobre o pacote foi submetido até o momento.

### Referências das equações

- HIGUCHI, N.; SANTOS, J.; RIBEIRO, R.J.; MINETTE, L.; BIOT, Y. Biomassa da parte aérea da vegetação da floresta tropical úmida de terra firme da Amazônia brasileira. **Acta Amazonica**, v. 28, n. 2, p. 153-166, 1998.
- HIGUCHI, N.; CHAMBERS, J.; SANTOS, J.; RIBEIRO, R.J.; PINTO, A.C.M.; SILVA, R.P.; ROCHA, R.M.; TRIBUZY, E.S. Dinâmica e balanço do carbono da vegetação primária da Amazônia Central. **Revista Floresta**, v. 34, n. 3, p. 295-304, 2004.
- SILVA, R.P. Alometria, estoque e dinâmica da biomassa de florestas primárias e secundárias na região de Manaus (AM). Tese (Doutorado) — INPA/UFAM, 2007.
- HIGUCHI, F.G. Dinâmica de volume e biomassa da floresta de terra firme do Amazonas. Tese (Doutorado) — UFPR, Curitiba, 2015.
- CHAVE, J. et al. Improved allometric models to estimate the aboveground biomass of tropical trees. **Global Change Biology**, v. 20, n. 10, p. 3177-3190, 2014.

---

## Contato

Sabrina Castro da Silva — PPGCASA/UFAM
Dúvidas ou sugestões: abrir uma issue neste repositório (quando publicado) ou contatar diretamente.
