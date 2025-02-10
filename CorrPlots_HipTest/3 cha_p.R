library(reshape2)
library(ggstatsplot)
library(ggplot2)
library(dplyr)
library(lubridate)
library(openxlsx)

# Clear env variables
rm(list=ls())

#read
df  <- read.csv(file = "df_filtrado.csv")%>%
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
  mutate(Year = year(Fecha)) %>%
  select(-c("Fecha","est_codigo"))%>%
  select_if(~!all(is.na(.))) %>%
  distinct(.keep_all = TRUE)

# arrays para crear los df

statistic_shapiro <-c()
p_valor_shapiro <-c()

statistic_kw <-c()
p_valor_kw <-c()

par_name <-c()

for (col in colnames(data)) {
  print(col)
  if(col != "Year"){
    
    # test normality
    # pvalor>0.05 entonces es normal
    test_shapiro <- shapiro.test(as.numeric(data[[col]]))
    statistic_shapiro <-c(statistic_shapiro,test_shapiro$statistic)
    p_valor_shapiro <-c(p_valor_shapiro,test_shapiro$p.value)
    
    # test varianza
    #pvalor > 0.05 entonces medianas diferentes
    test_kw <- kruskal.test(data[[col]] ~ data[["Year"]], data = data)
    statistic_kw <-c(statistic_kw,test_kw$statistic)
    p_valor_kw <-c(p_valor_kw,test_kw$p.value)
    
    par_name <- c(par_name,col)
  }
}

# make dataframes
df_shapiro <- data.frame(par_name,statistic_shapiro,p_valor_shapiro)
df_shapiro["test"] <- "Shapiro-Wilk"

df_kw <- data.frame(par_name,statistic_kw,p_valor_kw)
df_kw["test"] <- "Kruskal-Wallis"

# get special characters from the parameter name
# they will be deleted and used as the file name
sp<-c("\\[","\\]","\\(","\\)","\n","L/s")
sp <- c(unique(df$Unidad),sp)

df_spearman <- c()

for (col in colnames(data)) {
  # remove special characters from the parameter name to use it as a storing name
  name<-Reduce(function(x, y) gsub(y, "", x), c(col, sp))
  
  # set the number of xticks
  breaks <- data%>%
    select(col,Year) %>%
    na.omit() %>%
    summarise(n_distinct(Year))%>%
    pull()
  
  if(col != "Year"){
    
    #corr plot 
    p<- ggscatterstats(
      marginal = FALSE, # set as True to plot barplot as well
      title = "CHA_P",
      data = data,
      x    = Year,
      y    = !!sym(col),
      type = "np", # tipo de test: non-parametric
      ggplot.component = list(scale_x_continuous(n.breaks = breaks),
                              theme(axis.text = element_text(size = 20)),
                              theme(axis.title = element_text(size = 18)),
                              theme(plot.title = element_text(size=25,hjust = 0.5)),
                              theme(plot.subtitle = element_text(size = 15, face = "bold"))
                              ))
    
    # print(p)
    
    # save plot
    ggsave(filename = paste0("Plots/cha ",name," spearman corr.png"),device = "png",plot = p,
           units = "cm",width = 27,height = 15, scale = 0.9,dpi=1440)
    
    # spearman corr
    # pvalue < 0.05 then variable X has influence on Y.
    # The relationships are statistically significant
    
    statistics_spearman<-extract_stats(p)
    df_spearman <- bind_rows(df_spearman, statistics_spearman$subtitle_data[2:9])
    
  }
}


# Save the results
list_of_datasets <- list("Spearman" = df_spearman,
                         "Saphiro_Wilk"= df_shapiro,
                         "Kruskal_Wallis"= df_kw)

write.xlsx(list_of_datasets, file = "cha_statistical_test.xlsx")
