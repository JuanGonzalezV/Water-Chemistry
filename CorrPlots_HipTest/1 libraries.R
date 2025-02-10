# descargar Rtools43
# descargar R4.3
# en Rstudio escoger R4.3 como la version global
# usar RENV e instalar una por
# una en el orden establecido

# installar y reiniciar
install.packages('renv')
.rs.restartR()
library(renv)
renv::activate()
library(renv)

renv::install("ggstatsplot")
library(ggstatsplot)
# mas info sobre ggstatsplot: 
# https://indrajeetpatil.github.io/ggstatsplot/


renv::install("ggplot2")
library(ggplot2)

renv::install("dplyr")
library(dplyr)
renv::install("lubridate")
library(lubridate)

renv::install("openxlsx")
library(openxlsx)

renv::install("reshape2")
library(reshape2)
