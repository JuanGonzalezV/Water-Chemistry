library(reshape2)
library(PerformanceAnalytics)
library(dplyr)
library(lubridate)


rm(list=ls())

#read
df  <- read.csv(file = "df_filtrado.csv",encoding="UTF-8")%>%
  mutate(par_nombre=paste0(par_nombre,"\n[",Unidad,"]"))

#covenrt parameters to col 
dff<-dcast(df,Fecha+est_codigo~par_nombre,value.var = "valor")

# get caudal
caudal<- df %>% 
  select(c("Fecha","Q"))

#merge
dff <- merge(dff,caudal,by="Fecha")%>%arrange()
colnames(dff)[23]<- "Q [L/s]"

##### GET CHA_P data

# filter/rename data if necesary
data <- dff%>%subset(est_codigo=="CHA_P")%>%
  mutate(Fecha= ymd_hms(Fecha))%>%
  select_if(~!all(is.na(.))) %>%
  distinct(.keep_all = TRUE)

# Index col
rownames(data)<- data$Fecha

# unwanted columns
data <- data %>% select(-c("Fecha","est_codigo"))

# Rename
colnames(data)[c(1:18)]<-
  c("COT","CT",
    "ColorA","CE",
    "DBO","DQO",
    "DT","Ecoli",
    "FT","Fe",
    "Mn","NO3-",
    "NTD","OD",
    "pH","SST",
    "SO4²-","T") 

# PNG device
png(filename = "Plots/CHA_CorrPlot.png",
    width = 1440, height = 1440, 
    units = "px", pointsize = 12,
    bg = "white" )

# PLOT
chart.Correlation(data, histogram = TRUE, method = "spearman")

# Close device
dev.off()
