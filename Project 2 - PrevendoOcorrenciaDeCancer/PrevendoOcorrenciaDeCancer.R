# Coletando os dados
dados <- read.csv("bc_data.csv", stringsAsFactors = FALSE)

# Explorando os dados
dados <- dados[-1]
str(dados)

# Verificando se existem dados NA
any(is.na(dados))

# Muitos classificadores requerem que as vari�veis sejam do tipo fator
table(dados$diagnosis)
dados$diagnosis <- factor(dados$diagnosis, levels = c("B", "M"), labels = c("Benigno", "Maligno"))
str(dados$diagnosis)

# Verificando a propor��o
round(prop.table(table(dados$diagnosis)) * 100, digits = 1)

# Medidas de Tend�ncia Central
# Detectamos aqui um problema de escala entre os dados, que precisar�o ser normalizados
summary(dados[c("radius_mean", "area_mean", "smoothness_mean")])

# Criando uma fun��o de normaliza��o
normalizar <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

# Testando a fun��o de normaliza��o - os resultados devem ser id�nticos
normalizar(c(1 ,2 ,3 ,4, 5))
normalizar(c(10, 20, 30, 40, 50))

# Normalizando os dados
dados_norm <- as.data.frame(lapply(dados[2:31], normalizar))

# Confirmando que a normaliza��o ocorreu
summary(dados[c("radius_mean", "area_mean", "smoothness_mean")])
summary(dados_norm[c("radius_mean", "area_mean", "smoothness_mean")])

# Treinando o modelo
library(class)

# Criando dados de treino e teste
dados_treino <- dados_norm[1:469, ]
dados_teste <- dados_norm[470:569,]

# Criando os labels para os dados de treino e de teste
dados_treino_labels <- dados[1:469, 1]
dados_teste_labels <- dados[470:569, 1]

# KNN
# Criando o modelo
modelo <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k = 21)

# A fun��o knn() retorna um objeto do tipo fator com as previs�es de cada exemplo no dataset de teste
class(modelo)


# Avaliando a Performance do Modelo
library(gmodels)

# Criando uma tablea cruzada dos dados previstos x dados atuais
CrossTable(x = dados_teste_labels, y = modelo, prop.chisq = FALSE)

# Interpreta��o dos Resultados
# A tabela cruzada mostra 4 poss�veis valores, que representam os falso/verdadeiro positivos e negativos
# A primeira coluna lista os labels originais nos dados observados
# As duas colunas do modelo (Benigno e Maligno) do modelo, mostram os resultados da previs�o
# Temos os seguintes cen�rios:
# Cen�rio 1: C�lula Benigno (label) x Benigno (modelo) - 61 casos - true negative
# Cen�rio 2: C�lula Benigno (label) x Maligno (modelo) - 00 casos - false positivo
# Cen�rio 1: C�lula Maligno (label) x Benigno (modelo) - 02 casos - false negative (o modelo errou)
# Cen�rio 1: C�lula Maligno (label) x Maligno (modelo) - 37 casos - true positive

# True Negative = o modelo previu que a pessoa N�O tinha a doen�a e acertou
# False Positive = o modelo previu que a pessoa tinha a doen�a e os dados mostraram que N�O tinha
# False Negative = o modelo previu que a pessoa N�O tinha a doen�a e os dados mostraram que tinha
# True Positive = o modelo previu que a pessoa tinha a doen�a e os dados mostraram que tinha

# Falso Positivo - Erro tipo I
# Falso Negativo - Erro tipo II

# Taxa de acerto do Modelo: 98%

## Otimizando o Modelo

# Usando a fun��o scale() para pardonizar o z-score
dados_z <- as.data.frame(scale(dados[-1]))

# Confirmando a transforma��o realizada com sucesso
summary(dados_z$area_mean)

# Criando novos datasets de treino e de teste
dados_treino <- dados_z[1:469, ]
dados_teste <- dados_z[470:569, ]

dados_treino_labels <- dados[1:469, 1]
dados_teste_labels <- dados[470:569, 1]

# Reclassificando
modelo_v2 <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k = 21)

# Criando a cross table para comparar dados previstos com os dados reais
CrossTable(x = dados_teste_labels, y = modelo_v2, prop.chisq = FALSE)

# Testando diferentes valores para k
# Criando dados de treino e dados de teste
# dados_treino <- dados_norm[1:469, ]
# dados_teste <- dados_norm[470:569, ]
# Criando os labels para os dados de treino e de teste
# dados_treino_labels <- dados[1:469, 1]
# dados_teste_labels <- dados[470:569, 1]
# dados_test_pred <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k=1)
# CrossTable(x = dados_teste_labels, y = dados_test_pred, prop.chisq=FALSE)
# dados_test_pred <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k=5)
# CrossTable(x = dados_teste_labels, y = dados_test_pred, prop.chisq=FALSE)
# dados_test_pred <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k=11)
# CrossTable(x = dados_teste_labels, y = dados_test_pred, prop.chisq=FALSE)
# dados_test_pred <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k=15)
# CrossTable(x = dados_teste_labels, y = dados_test_pred, prop.chisq=FALSE)
# dados_test_pred <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k=21)
# CrossTable(x = dados_teste_labels, y = dados_test_pred, prop.chisq=FALSE)
# dados_test_pred <- knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k=27)
# CrossTable(x = dados_teste_labels, y = dados_test_pred, prop.chisq=FALSE)


## Calculando a taxa de erro
prev = NULL
taxa_erro = NULL

suppressWarnings(
  for(i in 1:20){
    set.seed(101)
    prev = knn(train = dados_treino, test = dados_teste, cl = dados_treino_labels, k = i)
    taxa_erro[i] = mean(dados$diagnosis != prev)
  }
)

# Obtendo os valores de k e das taxas de erro
library(ggplot2)
k.values <- 1:20
df_erro <- data.frame(taxa_erro, k.values)
df_erro

# � medida que aumetamos k, diminuimos a taxa de erro do modelo
ggplot(df_erro, aes(x = k.values, y = taxa_erro)) + geom_point()+ geom_line(lty = "dotted", color = 'red') +
  scale_x_continuous(breaks=seq(0, 20, 1))
