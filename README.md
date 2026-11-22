# Proyecto integrador ASP — Minería de Datos, Machine Learning y Cloud Computing

Segmentación predictiva de la vulnerabilidad en el acceso a salud de la población que realiza
actividades sexuales pagadas (ASP) en Bogotá — Encuesta ASP 2022 (Secretaría Distrital de la Mujer)
enriquecida con indicadores por localidad de SaluData.

## Estructura del repositorio

```
├── data/
│   ├── raw/                  datos de entrada (no se modifican a mano)
│   │   └── asp_2022_variables_renombradas.csv
│   └── processed/            datos generados por los notebooks y scripts
│       ├── asp_2022_variables_limpio.csv       ← salida de Mineria/01
│       ├── pobreza_localidade_limpio.csv       ← SaluData
│       ├── afiliacion_localidades_limpio.csv   ← SaluData
│       ├── asp_2022_saludata_integrado.csv     ← Mineria/scraping/integracion
│       ├── asp_perfiles_kmeans.csv             ← salida de Mineria/02 (cluster por persona)
│       └── perfiles_ponderados.csv             ← salida de Mineria/02 (tabla de perfiles)
├── Mineria/
│   ├── 01_limpieza_datos_ASP_2022.ipynb
│   ├── 02_perfiles_vulnerabilidad_kmeans.ipynb  (PCA + K-Means)
│   └── scraping/             scripts de SaluData (ver su README)
├── MachineLearning/
│   └── modelos/              modelos entrenados (.joblib) que usará la Lambda
└── Cloud/
    ├── terraform/            infraestructura AWS (S3, Lambda, API Gateway, DynamoDB, CloudWatch)
    ├── lambda/               código de la función de predicción
    └── web/                  página de demo
```

## Orden de ejecución

1. `Mineria/01_limpieza_datos_ASP_2022.ipynb` → genera `data/processed/asp_2022_variables_limpio.csv`
2. `Mineria/scraping/` (desde la raíz del repo) → genera los CSV de SaluData y la base integrada
3. `Mineria/02_perfiles_vulnerabilidad_kmeans.ipynb` → genera los perfiles de K-Means
4. `MachineLearning/` → modelo supervisado de afiliación a salud (en construcción)
5. `Cloud/terraform/` → despliegue en AWS

Los notebooks se ejecutan desde su propia carpeta (rutas `../data/...`); los scripts de
`Mineria/scraping/` se ejecutan desde la raíz del repositorio (rutas `data/...`).
