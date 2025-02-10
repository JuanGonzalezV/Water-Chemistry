# installar renv 

install.packages('renv')
library(renv)

# reiniciar 
renv::activate()
.rs.restartR()

# Restaurar librerias usando renv
library(renv)
renv::init()
# Select option 1
