# ForestR (development version)

## ForestR 0.8.0

### Reorganização em pacote R

Nesta versão, o ForestR deixou de ser um único script (`ForestR_v0_8.R`)
para se tornar um pacote R padrão: `DESCRIPTION`, `NAMESPACE`, código dividido
em módulos sob `R/`, e suíte de testes formal em `tests/testthat/`. Nenhuma
equação, coeficiente ou lógica foi alterada nesse processo — apenas
reorganizada. Todo o histórico de correções abaixo (v0.1 a v0.8) é preservado
das notas originais do script.

### Módulos

- `R/alometria.R` — equações alométricas tropicais (Amazônia, Bacia do Congo,
  Sudeste Asiático, Pantropical), cadeia fresco→seco→carbono, fator de
  correção por altura dominante
- `R/irfa.R` — Índice de Resiliência Florestal Amazônica (IRFA), classificação
  fuzzy, padrões da triangulação IRFA-IPTA (Quadro 7)
- `R/inventario.R` — resumo de parcela, distribuição diamétrica
- `R/diversidade.R` — diversidade alfa (Shannon-Wiener, Pielou)
- `R/visualizacoes.R` — gráficos temáticos em ggplot2
- `R/tema.R` — paleta de cores e tema visual ForestR
- `R/validacao.R` — validação de entrada (DAP, parâmetros obrigatórios)

### Testes

21 testes em `tests/testthat/` (test-alometria.R, test-correcao-altura.R,
test-irfa.R), todos passando — cobrindo especificamente as equações que já
tiveram erro real em versões anteriores.

---

## Histórico de correções (preservado do script original)

### v0.3

1. Módulo 1 revertido para os coeficientes REAIS do artigo Higuchi et al.
   (1998). A versão anterior usava 0,0576 e 0,1281, que não aparecem em
   nenhum lugar do artigo original — os coeficientes corretos são
   exp(-1,754)=0,1731 e exp(-0,151)=0,8598 (Considerações Finais, item 3,
   Modelo 1).
2. Higuchi et al. (1998) estima peso FRESCO, não seco. A versão anterior
   aplicava a fração de carbono do IPCC (0,47) direto sobre o peso fresco,
   pulando a secagem — superestimando o carbono em ~1,66x (+66%). Adicionadas
   `converter_fresco_seco()` e `carbono_de_seco()`, com os fatores do próprio
   artigo (Tabela 3b: seco = 60,28% do fresco).
3. O valor `bref = 307 Mg/ha (Higuchi 1998)`, usado no gráfico de trajetória,
   não foi localizado no artigo. Sinalizado no código.
4. O claim de que equações pantropicais subestimam "em até 40%" (citado na
   tese e na nota técnica) NÃO aparece no artigo de 1998 conferido — coincide
   numericamente com o teor de água da madeira (39,7%, Tabela 3b).
5. IRFA (Módulo 2) reconciliado com a tese (Seção 3.3): cinco componentes
   (B, C, E, R, P), média NÃO ponderada, classificação fuzzy em cinco níveis.

### v0.4

6. Adicionadas `fator_correcao_altura_dominante()` e
   `biomassa_higuchi_corrigida()`: implementa o procedimento do LMF/INPA
   (projeto CADAF) para aplicar a equação de Manaus em sítios sem calibração
   destrutiva própria — caso de T1 e T2. Fonte: Higuchi, F.G. et al., in Lima
   et al. (2014), cap. 3. Valor default de altura dominante de calibração
   (30 m) sinalizado como ILUSTRATIVO nesta versão.
7. O argumento "regional > pantropical" substituído por evidência testada
   estatisticamente: Higuchi, F.G. et al. (2014) rejeitaram por ANCOVA a
   hipótese de equação única para toda a Amazônia (p < 0,000000).
8. Cadeia fresco→seco→carbono (Módulo 1) recebeu confirmação cruzada de duas
   fontes adicionais do mesmo grupo (LMF/INPA): Silva, R.P. (2007) e
   Higuchi, N. et al. (2004).

### v0.5

9. Resolvida a pendência da v0.4: altura dominante de calibração (Manaus,
   ZF-2) confirmada em Higuchi, F.G. (2015, tese de doutorado, UFPR):
   Hdom = 30,2 m, método das 10% árvores mais grossas amostradas (validado
   por ANOVA entre quatro métodos concorrentes). Default atualizado de 30
   para 30,2.
10. Exemplo de correção por altura atualizado com valores REAIS de RH98/GEDI
    L2A de T1 e T2 (21,27 m e 21,38 m). Nota de cautela adicionada: RH98
    (GEDI) e altura dominante de campo não são estritamente equivalentes.
11. Higuchi, F.G. (2015) também testou por ANCOVA, com 11 sítios reais do
    Amazonas (1.128 parcelas), se uma equação de volume única serviria para
    todo o estado — rejeitada (p < 0,000001 em todos os sítios).

### v0.6

12. Adicionada `classificar_padrao_dse()`: formaliza os quatro padrões
    descritivos do Quadro 7 (Seção 3.6 da tese) — A Coerência, B Defasagem
    por exclusão, C Ruptura sistematizada, D Otimismo desacoplado — usando a
    classificação fuzzy já existente, sem inventar limiares novos. Retorna
    "Indeterminado" quando IRFA ou IPTA caem em "Moderado". Função
    DESCRITIVA — nomeia o padrão, não recomenda ação; uma camada
    prescritiva de fato é linha de pesquisa de pós-doutorado, fora do escopo
    desta tese.

### v0.7

13. Cabeçalho reorganizado para nomear explicitamente a arquitetura em três
    níveis (mensuração / comparação / interpretação), no mesmo enquadramento
    adicionado à Seção 3.6 da tese (V18). Nenhuma mudança de comportamento —
    apenas documentação. Preservada em `R/irfa.R` nesta reorganização.

### v0.8

14. Ajuste cosmético: cor de fundo do painel no tema visual (`theme_forestr()`)
    padronizada para forma hexadecimal canônica de 6 dígitos (`#ffffff`, antes
    `#fff`). Mesma cor, sem mudança visual.

---

*Esta reorganização (0.6.0) estabelece a estrutura de pacote R padrão sobre
uma base metodológica já validada ao longo de seis iterações. Próximas
versões devem priorizar: suíte de testes para os módulos de inventário,
diversidade e visualização (ainda sem cobertura formal); e a decisão de
licença, hoje pendente.*
