# descargar Rtools40
# descargar R4.1
# en Rstudio escoger R4.1 como la version global
# usar RENV e instalar una por
# una en el orden establecido


# installar y reiniciar
install.packages('renv')
library(renv)
renv::activate()
.rs.restartR()


renv::install("quadprog")
library(quadprog)

renv::install("PerformanceAnalytics")
library(PerformanceAnalytics)

renv::install("dplyr")
library(dplyr)

renv::install("reshape2")
library(reshape2)

renv::install("lubridate")
library(lubridate)

renv::snapshot()
