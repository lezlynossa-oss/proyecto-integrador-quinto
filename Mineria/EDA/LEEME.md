# EDA · Encuesta ASP 2022 (Bogotá)

- `EDA_ASP.ipynb`: análisis exploratorio completo (pasos 0 a 16, incluye la tarea 24) y conexión con el clustering.
- `figuras/`: las 9 figuras en alta resolución (300 dpi).
- `asp_2022_con_perfil.csv`: base completa con el perfil (grupo) de cada persona. Sirve para Power BI.
- `perfiles_ponderados.csv`: resumen ponderado de los 3 perfiles.
- `afiliacion_pobreza_localidad.csv`: afiliación, migración y pobreza 2021 por localidad (Figura 9).

Para correr el notebook, copiar `asp_2022_variables_limpio.csv` (está en la carpeta `data/`) a esta misma carpeta y ejecutar las celdas en orden.

El paso 10 (afiliación vs pobreza) usa `asp_2022_saludata_integrado.csv` de Sofía (carpeta `data/` de la rama main); el notebook lo busca en `../../data/`.
