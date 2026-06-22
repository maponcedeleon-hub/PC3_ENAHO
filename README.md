Participación ciudadana e identificación étnica en el Perú
Análisis con datos ENAHO 2025


Descripción

Este repositorio contiene el proyecto de análisis de datos para el curso de Estadística para el Análisis Sociológico 2 (SOC 285) de la Pontificia Universidad Católica del Perú.

El proyecto examina la relación entre la identificación étnica (aproximada mediante lengua materna) y la participación ciudadana en organizaciones sociales, usando los microdatos de la Encuesta Nacional de Hogares (ENAHO 2025) del INEI.


Pregunta de investigación

¿En qué medida la autoidentificación étnica se asocia con la participación en organizaciones sociales y comunales en el Perú?

Fuente de datos

ENAHO 2025 — Encuesta Nacional de Hogares sobre Condiciones de Vida y Pobreza

Estructura del repositorio

proyecto/
│
├── datos/
│   ├── crudos/           # Módulos originales ENAHO (no versionados)
│   └── procesados/       # Base de datos limpia y unida
│
├── outputs/              # Tablas, gráficos y resultados
│
├── docs/                 # Documentos y referencias del proyecto
│
├── 00_estructura.R       # Configura carpetas y gestión de paquetes
├── 01_carga_union.R      # Carga, merge y limpieza de módulos ENAHO
│
├── .gitignore            # Excluye datos crudos y archivos temporales
├── renv.lock             # Versiones exactas de paquetes (reproducibilidad)
└── README.md             # Este archivo


Reproducibilidad

Este proyecto usa renv para gestionar las versiones de paquetes y garantizar que el análisis sea reproducible.

Para reproducir el análisis:

r# 1. Restaurar el entorno de paquetes
renv::restore()


Variables principales

Variable - Módulo - Descripción
indice_participacion - 800A - Índice de participación (0–17 tipos de organización)
participa_binario -800A - Participa en al menos una organización (0/1)
identidad_etnica - 300 - Grupo étnico según lengua materna
nivel_educ - 300 - Nivel educativo alcanzado (recodificado)
sexo - 300 - Sexo de la persona
area - Sumaria - Área urbano / rural
POBREZA - Sumaria - Condición de pobreza
ESTRSOCIAL - Sumaria - Estrato socioeconómico (A–E, Rural)


Autora: María Alejandra Ponce de León Gamarra
Pontificia Universidad Católica del Perú
Curso: SOC 285 — Estadística para el Análisis Sociológico 2