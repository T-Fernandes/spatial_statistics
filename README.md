##  Spatial Statistics

Using spatial statistics to plot the thematic map of the Brazilian population estimated in 2017 by states.

Population Brazil: [Link1](https://www.ibge.gov.br/estatisticas-novoportal/sociais/populacao/9103-estimativas-de-populacao.html?=&t=resultados)

Shapefile of Brazil: [Link2](http://www.usp.br/nereus/wp-content/uploads/Brasil.zip)

### Reading the population database by cities 
```markdown
Pop_BR = read.csv('estimativa_dou_2017.csv', header = T, sep=';')
```
### Reading the shapefile of Brazil
```markdown
SHP_UF_BR = shapefile('UFEBRASIL.shp')
```

### Plotting thematic map
```markdown
library("ggsn")
library("ggrepel")

windows()
ggplot(map_br) + 
  aes(x=long, y=lat, group=group, fill=factor(idcores)) +
  geom_polygon() +
  coord_equal() + 

  geom_path(color="black") +
  scale_fill_manual(values=cores, labels=legenda) +
  
  theme(legend.title = element_text(face='bold', size=10)) +
  guides(fill=guide_legend(title="Population (Milion)")) +
  
  theme(legend.text = element_text(face=NULL, size=9)) +
  
  theme(legend.background = element_rect(fill="white", size=.5, linetype="dotted")) +
  theme(legend.position=c(0.12, 0.19)) +
  
  with(centroids, annotate(geom="label", x=long, y=lat, label=label, size=2, color='red3')) +
  
  ggsn::scalebar(map_br, dist=500, st.size=3, height=0.01, dd2km=TRUE, model='WGS84') +
  ggsn::north(map_br, symbol=16, scale=0.15) +
  
  labs(title="Map of the Brazilian states by population in 2017", y="latitude", x="longitude")`

```
![map_br.jpeg](https://github.com/T-Fernandes/spatial_statistics/blob/master/map_br.jpeg?raw=true)

