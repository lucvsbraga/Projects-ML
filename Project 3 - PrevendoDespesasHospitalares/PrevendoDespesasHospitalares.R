# Coletando os dados

despesas <- read.csv("despesas.csv")

# Visualizando as vari�veis
str(despesas)

# Medidas de Tend�ncia Central da vari�vel gastos
summary(despesas$gastos)

# Construindo um histograma
hist(despesas$gastos, main = 'Histograma', xlab = 'Gastos')

# Tabela de conting�ncia das regi�es
table(despesas$regiao)

# Explorando relacionamento entre as vari�veis: Matriz de Correla��o
cor(despesas[c('idade', 'bmi', 'filhos', 'gastos')])

# Nenhuma das correla��es da matriz s�o consideradas fortes, mas existem algumas associa��es interessantes.
# A idade e o bmi (imc) parecem ter uma correla��o positiva fraca, o que significa que com o aumento da idade, a massa corporal tende a aumentar.
# H� tamb�m uma correla��o positiva entre a idade e os gatos, al�m do n�mero de filhos e os gastos.

# Visualizando o relacionamento entre as vari�veis: Scatterplot
# Perceba que n�o existe um claro relacionamento entre as vari�veis
pairs(despesas[c('idade', 'bmi', 'filhos', 'gastos')])

# Scatterplot Matrix
library(psych)

# Este gr�fico fornece mais informa��es sobre o relacionamento entre as vari�veis
pairs.panels(despesas[c('idade', 'bmi', 'filhos', 'gastos')])

## Treinando o modelo
modelo <- lm(gastos ~ ., data = despesas)

# Visualizando os coeficientes
modelo

# Prevendo despesas m�dicas
previsao <- predict(modelo)
class(previsao)

head(previsao)

# Avaliando a Performance do Modelo
summary(modelo)

## Otimizando o Modelo

# Adicionado uma vari�vel com o dobro do valor das idades
despesas$idade2 <- despesas$idade ^ 2

# Adicionando um indicador para BMI >= 30
despesas$bmi30 <- ifelse(despesas$bmi >= 30, 1, 0)

# Criando o modelo final
modelo_v2 <- lm(gastos ~ idade + idade2 + filhos +bmi +sexo + bmi30 * fumante + regiao, data = despesas)

summary(modelo_v2)
