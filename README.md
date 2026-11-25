# Proyecto integrador ASP — Minería de Datos, Machine Learning y Cloud Computing

Segmentación predictiva de la vulnerabilidad en el acceso a salud de la población que realiza
actividades sexuales pagadas (ASP) en Bogotá — Encuesta ASP 2022 (Secretaría Distrital de la Mujer)
enriquecida con indicadores por localidad de SaluData.

## Estructura del repositorio

```
├── requirements.txt          librerías de Python del proyecto
├── data/
│   ├── raw/                  datos de entrada (no se modifican a mano)
│   └── processed/            datos generados por los notebooks y scripts
├── Mineria/
│   ├── 01_limpieza_datos_ASP_2022.ipynb
│   ├── 02_perfiles_vulnerabilidad_kmeans.ipynb   PCA + K-Means (y comparación con jerárquico)
│   ├── EDA/                  análisis exploratorio, figuras y dashboard (ver su LEEME)
│   └── scraping/             web scraping de SaluData (ver su README)
├── MachineLearning/
│   ├── 01_modelo_afiliacion_salud.ipynb   logística, Random Forest, Gradient Boosting, Grid/Random Search, SHAP
│   └── modelos/              modelos exportados (JSON) que usa la Lambda
└── Cloud/
    ├── terraform/            infraestructura AWS (S3, Lambda, API Gateway, DynamoDB, CloudWatch)
    ├── lambda/               código de la función de predicción
    └── web/                  página de demo (predicción + dashboard)
```

## Instalación

```bash
python3 -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

## Orden de ejecución

1. `Mineria/01_limpieza_datos_ASP_2022.ipynb` → `data/processed/asp_2022_variables_limpio.csv`
2. `Mineria/scraping/` (desde la raíz del repo) → CSV de SaluData y `data/processed/asp_2022_saludata_integrado.csv`
3. `Mineria/EDA/EDA_ASP.ipynb` → figuras y `asp_2022_con_perfil.csv`
4. `Mineria/EDA/03_dashboard_eda.ipynb` → `Cloud/web/dashboard.json`
5. `Mineria/02_perfiles_vulnerabilidad_kmeans.ipynb` → perfiles y `MachineLearning/modelos/clustering_config.json`
6. `MachineLearning/01_modelo_afiliacion_salud.ipynb` → `MachineLearning/modelos/modelo_afiliacion.json`
7. `Cloud/terraform/` → despliegue en AWS (ver abajo)

Los notebooks se ejecutan desde su propia carpeta (rutas `../data/...`); los scripts de
`Mineria/scraping/` se ejecutan desde la raíz del repositorio (rutas `data/...`).