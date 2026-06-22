# =============================================================================
# Script 01: Carga y unión de módulos ENAHO 2025
# Proyecto: Participación ciudadana y etnicidad en el Perú
# Fuente: ENAHO 2025
# Autor: María Alejandra Ponce de Léon Gamarra
# Fecha:21-06-2025
# =============================================================================

library(tidyverse)
library(haven)

# =============================================================================
# 1. CARGA DE MÓDULOS
# =============================================================================

# -----------------------------------------------------------------------------
# Sumaria: variables socioeconómicas del hogar
# Unidad de análisis: HOGAR (CONGLOME + VIVIENDA + HOGAR)
# -----------------------------------------------------------------------------
sumaria <- read_sav("datos/crudos/Sumaria-2025-12g.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR,
    DOMINIO,      # dominio geográfico (Costa Norte, Sierra, Selva, etc.)
    ESTRATO,      # estrato geográfico (tamaño de ciudad)
    ESTRSOCIAL,   # estrato socioeconómico (A, B, C, D, E, Rural)
    MIEPERHO,     # número de miembros del hogar
    POBREZA,      # condición de pobreza (Pobre Extremo / No Extremo / No Pobre)
    FACTOR07      # factor de expansión
  )

# -----------------------------------------------------------------------------
# Módulo 300: Educación
# Unidad de análisis: PERSONA (CONGLOME + VIVIENDA + HOGAR + CODPERSO)
# Variables clave: lengua materna (proxy étnico), nivel educativo, sexo, edad
# -----------------------------------------------------------------------------
mod300 <- read_sav("datos/crudos/Enaho01A-2025-300_Educación.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR, CODPERSO,
    P300A,    # lengua materna (1=Quechua, 2=Aimara, 3=Otra nativa, 4=Castellano, ...)
    P301A,    # nivel educativo alcanzado (1=Sin nivel ... 11=Maestría/Doctorado)
    P207,     # sexo (1=Hombre, 2=Mujer)
    P208A     # edad en años cumplidos
  )

# -----------------------------------------------------------------------------
# Módulo 800A: Gobernabilidad — participación del HOGAR en organizaciones
# Unidad de análisis: HOGAR (CONGLOME + VIVIENDA + HOGAR)
# Valores: 0 = No pertenece, número = pertenece a esa categoría
# -----------------------------------------------------------------------------
mod800A <- read_sav("datos/crudos/Enaho01-2025-800A.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR,
    P801_1,   # Clubes y asociaciones deportivas
    P801_2,   # Agrupación o partido político
    P801_3,   # Clubes culturales
    P801_4,   # Asociación vecinal / Junta vecinal
    P801_5,   # Ronda campesina
    P801_6,   # Asociación de regantes
    P801_7,   # Asociación profesional
    P801_8,   # Asociación de trabajadores o sindicato
    P801_9,   # Club de madres
    P801_10,  # Asociación de padres de familia (APAFA)
    P801_11,  # Vaso de leche
    P801_12,  # Comedor popular
    P801_13,  # Comité local administrativo de salud (CLAS)
    P801_14,  # Proceso de presupuesto participativo
    P801_15,  # Concejo de coordinación local distrital
    P801_16,  # Comunidad campesina
    P801_17,  # Asociación agropecuaria
    P801_19   # No pertenece, no participa (categoría de referencia)
  )

# -----------------------------------------------------------------------------
# Módulo 800B: Gobernabilidad — participación individual
# Unidad de análisis: PERSONA que participa (CONGLOME + VIVIENDA + HOGAR + CODPERSO)
# Solo tienen registro las personas que sí participan en alguna organización
# -----------------------------------------------------------------------------
mod800B <- read_sav("datos/crudos/Enaho01-2025-800B.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR, CODPERSO,
    P803,   # tipo de organización a la que pertenece
    P804,   # rol: Dirigente / Miembro activo / Miembro no activo / Otro
    P805    # cómo accedió: elección, amistad, designación, pago, afiliación, otro
  )

# =============================================================================
# 2. CONSTRUCCIÓN DEL ÍNDICE DE PARTICIPACIÓN (nivel hogar)
# Suma de tipos distintos de organización a los que pertenece el hogar (0–17)
# Lógica: cada P801_* vale 1 si el hogar participa (valor != 0), 0 si no
# =============================================================================

vars_participacion <- paste0("P801_", c(1:17))  # excluye P801_19 (no participa)

mod800A <- mod800A %>%
  mutate(
    across(
      all_of(vars_participacion),
      ~ if_else(. != 0, 1L, 0L)   # 1 = participa, 0 = no participa
    ),
    indice_participacion = rowSums(across(all_of(vars_participacion)), na.rm = TRUE),
    participa_binario    = if_else(indice_participacion > 0, 1L, 0L)
  )

# =============================================================================
# 3. MERGE
# =============================================================================

# unión a nivel persona (módulo 300 + 800B)
base_persona <- mod300 %>%
  left_join(mod800B, by = c("CONGLOME", "VIVIENDA", "HOGAR", "CODPERSO"))

# índice de participación del hogar (800A)
base_persona <- base_persona %>%
  left_join(
    mod800A %>% select(CONGLOME, VIVIENDA, HOGAR,
                       indice_participacion, participa_binario,
                       all_of(vars_participacion)),
    by = c("CONGLOME", "VIVIENDA", "HOGAR")
  )

# variables socioeconómicas del hogar (Sumaria)
base_final <- base_persona %>%
  left_join(sumaria, by = c("CONGLOME", "VIVIENDA", "HOGAR"))

# =============================================================================
# 4. LIMPIEZA Y FILTROS
# =============================================================================

base_final <- base_final %>%
  filter(
    P208A >= 18,           # solo mayores de edad (ciudadanxs)
    !is.na(P300A),         # con dato de lengua materna
    !is.na(indice_participacion)  # con dato de participación
  ) %>%
  mutate(
    # Recodificar lengua materna como identidad étnica (proxy)
    identidad_etnica = case_when(
      P300A == 1 ~ "Quechua",
      P300A == 2 ~ "Aimara",
      P300A %in% c(3, 10, 11, 12, 13, 14, 15) ~ "Otra lengua nativa",
      P300A == 4 ~ "Castellano",
      TRUE       ~ "Otra"
    ),
    identidad_etnica = factor(identidad_etnica,
                              levels = c("Castellano", "Quechua", "Aimara",
                                         "Otra lengua nativa", "Otra")),
    
    # Nivel educativo recodificado (agrupado)
    nivel_educ = case_when(
      P301A %in% 1:2       ~ "Sin nivel / Inicial",
      P301A %in% 3:4       ~ "Primaria",
      P301A %in% 5:6       ~ "Secundaria",
      P301A %in% 7:8       ~ "Superior no universitaria",
      P301A %in% 9:11      ~ "Superior universitaria o más",
      TRUE                 ~ NA_character_
    ),
    nivel_educ = factor(nivel_educ,
                        levels = c("Sin nivel / Inicial", "Primaria",
                                   "Secundaria", "Superior no universitaria",
                                   "Superior universitaria o más")),
    
    # Sexo como factor
    sexo = factor(if_else(P207 == 1, "Hombre", "Mujer")),
    
    # Área (urbano/rural) a partir del estrato
    area = factor(if_else(ESTRATO %in% 7:8, "Rural", "Urbano"))
  )

write_csv(base_final, "datos/procesados/base_participacion_etnica.csv")

# resumen
cat("============================================\n")
cat("Base exportada exitosamente\n")
cat(sprintf("Observaciones: %d\n", nrow(base_final)))
cat(sprintf("Variables:     %d\n", ncol(base_final)))
cat("--------------------------------------------\n")
cat("Distribución por identidad étnica (lengua materna):\n")
print(table(base_final$identidad_etnica, useNA = "ifany"))
cat("--------------------------------------------\n")
cat("Distribución del índice de participación:\n")
print(summary(base_final$indice_participacion))
cat("============================================\n")
