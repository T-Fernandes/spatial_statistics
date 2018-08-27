####################################################################################################
##                                                                                                ##
##                       Map of the Brazilian states by population in 2017                        ##
##                                                                                                ##
####################################################################################################

## Population Brazil: ftp://ftp.ibge.gov.br/Estimativas_de_Populacao/Estimativas_2017/estimativa_dou_2017.xls


## reading the population database by cities 
Pop_BR = read.csv('estimativa_dou_2017.csv', header = T, sep=';')

## visualizing the first lines
head(Pop_BR)

## renamed the columns
colnames(Pop_BR) = c('UF', 'COD_UF', 'COD_MUN', 'NOME_MUN', 'POP_EST')

## viewing the last lines 
tail(Pop_BR)

## verified missing values
table(is.na(Pop_BR))

## total population of each State
library("dplyr")
POP_UF_BR = Pop_BR %>% 
            group_by(UF, COD_UF) %>% 
            summarise(POP = sum(as.numeric(POP_EST)))


## color vector according to population
idcores = rep(1,27)
idcores[POP_UF_BR$POP>4000000 & POP_UF_BR$POP<=8000000] = 2
idcores[POP_UF_BR$POP>8000000 & POP_UF_BR$POP<=12000000] = 3
idcores[POP_UF_BR$POP>12000000 & POP_UF_BR$POP<=16000000] = 4
idcores[POP_UF_BR$POP>16000000 & POP_UF_BR$POP<=20000000] = 5
idcores[POP_UF_BR$POP>20000000 & POP_UF_BR$POP<=24000000] = 6
idcores[POP_UF_BR$POP>24000000] = 7

table(idcores)

## adding color vector to the dataframe
POP_UF_BR$idcores = idcores


####################################################################################################

## Shapefile of Brazil: http://www.usp.br/nereus/wp-content/uploads/Brasil.zip

library("raster")
#library(maptools)
#library(rgeos)

## reading the shapefile of Brazil
SHP_UF_BR = shapefile('UFEBRASIL.shp')

## visualizing the first lines
head(SHP_UF_BR@data)

## adjusting the character encoding of the dataset
df = apply(SHP_UF_BR@data, 2, as.character) 
Encoding(df) = "UTF-8"
SHP_UF_BR@data = as.data.frame(df)

####################################################################################################

## checking if the status code of the dataframes and shapefile is in the same order
table(SHP_UF_BR@data$CD_GEOCODU == POP_UF_BR$COD_UF)

## Sorting the status code of dataframes in relation to shapefile
ordenar_df<- merge(data.frame(cod=SHP_UF_BR@data$CD_GEOCODU), 
              data.frame(cod=POP_UF_BR$COD_UF, POP_UF_BR[,-2]), sort=FALSE)
dim(ordenar_df)
names(ordenar_df)
table(ordenar_df$cod == SHP_UF_BR@data$CD_GEOCODU)

## adding the data in shapefile
SHP_UF_BR@data = data.frame(SHP_UF_BR@data, ordenar_df[,-1])

## enumerating identifier column
SHP_UF_BR@data$ID = c(1:27)
names(SHP_UF_BR)[1] <- c("id")


## creating dataframe with shapefile data
library("ggplot2")
map_br <- fortify(SHP_UF_BR, region = "id")
map_br <- merge(map_br, SHP_UF_BR@data, by="id")  
 

## obtaining the centroid of each state
centroids <- setNames(do.call("rbind.data.frame", by(map_br, map_br$UF,
             function(x) {Polygon(x[c('long', 'lat')])@labpt})), c('long', 'lat')) 

## Obtaining the acronym of each state and assigning to the centroid
(x = table(map_br$UF))
centroids$label <- names(x)

## correction of the centroid of the acronym ES(Espirito santo)
centroids$long[8] = -40.54443
centroids$lat[8] = -19.93204

####################################################################################################

## map caption
legenda = c("0.5 - 4.0", 
            "4.0 - 8.0 ", 
            "8.0 - 12.0", 
            "12.0 - 16.0", 
            "16.0 - 20.0", 
            "20.0 - 24.0",
            "42.0 - 46.0")

## color palette
cores = c('#f5f5f5', 
          '#c7eae5', 
          '#80cdc1',
          '#35978f', 
          '#01665e', 
          '#004741', 
          '#001412')


#devtools::install_github("tidyverse/ggplot2", dependencies=T)
#devtools::install_github('oswaldosantos/ggsn')
library("ggsn")
library("ggrepel")

## plotting thematic map
windows()
ggplot(map_br) + 
  aes(x=long, y=lat, group=group, fill=factor(idcores)) +
  geom_polygon() +
  coord_equal() + 

  geom_path(color="black") +
  scale_fill_manual(values = cores , labels = legenda) +
  
  theme(legend.title = element_text(face = 'bold', size = 10)) +
  guides(fill=guide_legend(title = "Population (Milion)")) +
  
  theme(legend.text = element_text(face = NULL, size = 9)) +
  
  theme(legend.background = element_rect(fill="white", size=.5, linetype="dotted")) +
  theme(legend.position=c(0.12, 0.19)) +
  
  with(centroids, annotate(geom="label", x=long, y=lat, label=label, size=2, color='red3')) +
  
  ggsn::scalebar(map_br, dist = 500, st.size=3, height=0.01, dd2km = TRUE, model = 'WGS84') +
  ggsn::north(map_br, symbol = 16, scale = 0.15) +
  
  labs(title = "Map of the Brazilian states by population in 2017", y="latitude", x="longitude") 

####################################################################################################
