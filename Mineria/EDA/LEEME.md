# EDA · Encuesta ASP 2022 (Bogotá)

- `EDA_ASP.ipynb`: análisis exploratorio completo (pasos 0 a 16, incluye la tarea 24) y conexión con el clustering.
- `03_dashboard_eda.ipynb`: rehace en Plotly las gráficas del EDA y genera `Cloud/web/dashboard.json`, que se publica en la pestaña Dashboard de la página.
- `figuras/`: las 9 figuras en alta resolución (300 dpi).
- `asp_2022_con_perfil.csv`: base completa con el perfil (grupo) de cada persona. Sirve para Power BI y para el dashboard.
- `perfiles_ponderados.csv`: resumen ponderado de los 3 perfiles.
- `afiliacion_pobreza_localidad.csv`: afiliación, migración y pobreza 2021 por localidad (Figura 9).

## Cómo ejecutar

1. Correr antes `Mineria/01_limpieza_datos_ASP_2022.ipynb` y los scripts de `Mineria/scraping/` (ver el README principal).
2. Abrir `EDA_ASP.ipynb` desde esta carpeta y ejecutar todo. Lee los datos de `../../data/processed/`.
3. Abrir `03_dashboard_eda.ipynb` y ejecutar todo. Usa `asp_2022_con_perfil.csv`, que genera el paso anterior.