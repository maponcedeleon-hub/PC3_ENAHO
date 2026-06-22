#===========================================================================================
#Proyecto: Práctica Calificada 3
#Autor: María Alejandra Ponce de León Gamarra
#Fecha: 20-06-2026
#==========================================================================================

#Creamos carpetas--------------------------

dir.create("datos")
dir.create("datos/crudos")
dir.create("datos/procesados")
dir.create("outputs")
dir.create("docs")
dir.create("scripts")

install.packages("renv")
renv::init()

file.create("datos/crudos/.gitkeep")
file.create("datos/procesados/.gitkeep")
file.create("outputs/.gitkeep")
file.create("docs/.gitkeep")

renv::init()
renv::snapshot()
