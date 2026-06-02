# ForestR
## Pacote computacional para análise biofísica de florestas tropicais amazônicas

```
ForestR v0.1-alpha · BIODATUM / PPGCASA / UFAM · 2026
Sabrina Castro da Silva · Laboratório de Manejo Florestal (LMF) / INPA
```

---

## O que é ForestR?

**ForestR** é um pacote em R que integra duas tradições científicas complementares da Amazônia:

1. **Pilar 1 — Biomassa e Carbono**  
   Equações alométricas publicadas do INPA (Higuchi et al., 1997, 1998, 2004) para estimativa de biomassa acima do solo e estoques de carbono — até **40% mais precisas** que equações pantropicais para a Amazônia Central.

2. **Pilar 2 — Desmatamento e Uso do Solo**  
   Modelagem espacial de padrões de desmatamento por categoria fundiária (Yanai et al., 2020, 2022, 2024; Fearnside et al., 2018).

Juntos, esses dois pilares alimentam o cálculo do **IRFA** — o Indicador de Resiliência Florestal Amazônica — componente central do framework **BIODATUM**.

---

## Como acessar ForestR?

### 1. Download do arquivo `ForestR.R`

O arquivo está disponível em:
- **`public/ForestR.R`** — código fonte completo
- **`public/forestr-biodatum.html`** — página de referência das equações alométricas (Amazônia, Bacia do Congo, Sudeste Asiático)

### 2. Instalação de dependências (primeira vez)

Abra o **RStudio** e instale os pacotes necessários:

```r
install.packages(c("dplyr", "ggplot2"))
```

### 3. Carregar ForestR no seu script

```r
source("ForestR.R")  # Caminho relativo ou absoluto para o arquivo
```

Nenhuma instalação adicional necessária. O ForestR funciona como um conjunto de funções carregadas na sessão R.

---

## Funções disponíveis (v0.1-alpha)

### Core — Equações de Higuchi

| Função | Descrição | Saída |
|--------|-----------|-------|
| `biomassa_higuchi(dap)` | Estima AGB (Mg ha⁻¹) a partir de DAP (cm). Implementa regime duplo: DAP < 20 cm e DAP ≥ 20 cm | AGB em kg/árvore |
| `carbono_higuchi(dap)` | Converte AGB em estoque de carbono aplicando fator C = 0,47 (Higuchi et al., 2004) | C em kg/árvore |
| `biomassa_chave(dap, h, wd)` | Equação pantropical de Chave et al. (2014) para comparação e validação cruzada | AGB em kg/árvore |

### Resiliência — IRFA

| Função | Descrição |
|--------|-----------|
| `calcular_irfa(tnr, trb, iec)` | Calcula o IRFA (TNR, TRB, IEC) com pesos calibrados via ACP |
| `imprimir_irfa(resultado)` | Exibe laudo formatado com score, classificação e interpretação |
| `plotar_trajetoria_irfa()` | Gráfico ggplot2 com curva de recuperação e zonas de resiliência |

### Inventário

| Função | Descrição |
|--------|-----------|
| `resumo_parcela(dados)` | N/ha, área basal, DAP médio, AGB e carbono total |
| `diversidade_shannon(spp)` | H' de Shannon-Wiener, J' de Pielou e riqueza |
| `plotar_distribuicao_diametrica()` | Histograma de distribuição diamétrica (padrão J-invertido) |

---

## Exemplos de uso

### Exemplo 1: Estimar biomassa de uma árvore

```r
# Árvore com DAP = 28.3 cm
dap <- 28.3
agb <- biomassa_higuchi(dap)
c_stock <- carbono_higuchi(dap)

cat("AGB:", round(agb, 2), "kg/árvore\n")
cat("Carbono:", round(c_stock, 2), "kg C/árvore\n")

# Saída esperada:
# AGB: 847.2 kg/árvore
# Carbono: 398.2 kg C/árvore
```

### Exemplo 2: Calcular IRFA

```r
# Componentes do IRFA
tnr <- 0.48  # Taxa de regeneração natural
trb <- 0.52  # Taxa de recuperação de biomassa
iec <- 0.58  # Índice de estrutura da comunidade

resultado <- calcular_irfa(tnr = tnr, trb = trb, iec = iec)
imprimir_irfa(resultado)

# Saída esperada:
# IRFA Score: 0.5210
# Classe: Resiliência Moderada
# TNR (Regeneração): 0.48 [Moderada]
# TRB (Biomassa): 0.52 [Moderada]
# IEC (Estrutura): 0.58 [Moderada]
```

### Exemplo 3: Resumo de uma parcela

```r
# Estrutura esperada: data.frame com colunas
# "dap" (cm), "altura" (m), "especie"

parcela <- data.frame(
  dap = c(10.5, 15.2, 22.8, 35.6, 42.1),
  altura = c(8.5, 12.3, 18.6, 28.4, 32.1),
  especie = c("Jatoba", "Ipê", "Cedro", "Angelim", "Sucupira")
)

resultado <- resumo_parcela(parcela)
print(resultado)
```

---

## Documentação científica

### Equações alométricas por região

O arquivo **`public/forestr-biodatum.html`** contém um levantamento técnico completo de equações alométricas tropicais:

#### Amazônia (Pilar 1)
- Higuchi et al. (1994, 1997, 1998, 2004) — equações regionais do INPA
- Chambers et al. (2001) — validação independente
- Chave et al. (2005, 2014) — comparação pantropical
- Baia et al. (2025) — modelos altura-diâmetro para várzea

#### Bacia do Congo
- Fayolle et al. (2018) — maior amostragem destrutiva africana (845 árvores)
- Djomo et al. (2010); Ngomanda et al. (2014)
- Fayolle et al. (2024) — biomassa subterrânea

#### Sudeste Asiático
- Basuki et al. (2009) — equações por gênero (Dipterocarpos)
- Rutishauser et al. (2013) — modelos com altura para GEDI
- Kenzo et al. (2009) — Sarawak (Malásia)

#### Referência pantropical
- Chave et al. (2014) — benchmark internacional (4.004 árvores)
- Dataset global + raster fator E disponível em: https://doi.org/10.5281/zenodo.14932971

---

## Dois pilares científicos — um indicador integrado

### Pilar 1: Biomassa e Carbono
**Fonte:** Equações alométricas Higuchi et al. (1997, 1998, 2004)  
**Contribuição para IRFA:** Calibração do TRB (Taxa de Recuperação de Biomassa) via dados GEDI/NASA  
**Precisão:** 40% superior a pantropicais na Amazônia Central

### Pilar 2: Desmatamento e Uso do Solo
**Fonte:** Modelagem espacial Yanai et al. (2020, 2022, 2024)  
**Contribuição para IRFA:** Histórico de perturbação que determina contexto de recuperação  
**Aplicação:** Painel com efeitos fixos (vetor Xᵢₜ)

---

## Como citar ForestR

### Artigo principal
```bibtex
@article{CastroDaSilva2026,
  author = {Castro da Silva, Sabrina},
  year = {2026},
  title = {ForestR: Integrated biophysical analysis of Amazonian tropical forests},
  journal = {Advances in Forestry Research},
  note = {PPGCASA/UFAM, Manaus}
}
```

### Equações de Higuchi (Pilar 1)
```bibtex
@article{Higuchi1998,
  author = {Higuchi, N. and Santos, J. and Ribeiro, R.J. and others},
  year = {1998},
  title = {Biomassa da parte aérea da vegetação da floresta tropical úmida de terra-firme da {A}mazônia brasileira},
  journal = {Acta Amazônica},
  volume = {28},
  number = {2},
  pages = {153--166}
}
```

### Modelagem de desmatamento (Pilar 2)
```bibtex
@article{Yanai2024,
  author = {Yanai, Aurora M. and others},
  year = {2024},
  title = {Deforestation and carbon emissions in {A}mazonia: land-use trajectories and policy scenarios},
  journal = {Global Change Biology},
  volume = {30}
}
```

---

## Módulos em desenvolvimento (v0.2+)

| Módulo | Função | Status |
|--------|--------|--------|
| `deforestation_history()` | Histórico de desmatamento por categoria fundiária | Planeado |
| `carbon_loss()` | Perda de carbono por desmatamento acumulado | Planeado |
| `landuse_pressure()` | Vetor de pressão de uso da terra (Xᵢₜ) | Planeado |
| `deforestation_scenario()` | Cenários futuros de desmatamento | Planeado |

---

## Requisitos de sistema

- **R:** ≥ 4.0
- **Pacotes:** `dplyr`, `ggplot2`
- **RAM:** 512 MB (mínimo para operações padrão)
- **Suporte:** macOS, Windows, Linux

---

## Perguntas frequentes

### P: O ForestR é compatível com GEDI?
**R:** Sim. Os componentes TRB do IRFA são calibrados com dados GEDI/NASA (altura, cobertura, estrutura). A função `irfa_compute()` integra automaticamente esses dados.

### P: Posso usar ForestR fora da Amazônia?
**R:** O padrão é otimizado para Amazônia Central, mas as equações de Chave et al. (2014) permitem comparação pantropical. Para Congo e Sudeste Asiático, use as equações regionais referenciadas na documentação.

### P: Como contribuir para o desenvolvimento?
**R:** ContacteSabrina Castro da Silva (sabrinacastroadm1@gmail.com) 

### P: Há limitações nas equações?
**R:** 
- Higuchi et al. (1997, 1998) foram calibradas com DAP ≥ 10 cm
- Para DAP < 10 cm, usar modelo de regressão linear simples
- Equações regionais são mais precisas que pantropicais, mas requerem validação local

---

## Contactos

**Autora:** Sabrina Castro 
**Email:** sabrina.castro@ufam.edu.br  ou sabrinacastroadm1@gmail.com
**Afiliação:** PPGCASA / UFAM · Manaus, AM  
**Laboratório:** Laboratório de Manejo Florestal (LMF) · INPA  


---

## Licença

**GPL-3.0** — Código aberto. Uso livre para fins académicos e de investigação.

---

## Referências principais

1. **Higuchi, N.**, et al. (1997, 1998, 2004). *Equações alométricas do INPA*. Acta Amazônica.
2. **Chave, J.**, et al. (2014). *Improved allometric models to estimate aboveground biomass of tropical trees*. Global Change Biology.
3. **Yanai, A.M.**, et al. (2020, 2022, 2024). *Deforestation, land use, and carbon dynamics in Amazonia*.
4. **Fearnside, P.M.**, et al. (2018). *Modelling Amazon deforestation scenarios*.

---

**ForestR v0.1-alpha · 2026 · BIODATUM Framework · "O que a floresta guarda"**
