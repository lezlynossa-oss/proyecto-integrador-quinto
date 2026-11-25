# Extracción e Integración de Indicadores Contextuales — SaluData Bogotá

Módulo de web scraping, limpieza e integración de indicadores socioeconómicos y de aseguramiento en salud por localidad urbana de Bogotá D.C., desarrollado para enriquecer la **Encuesta de Actividades Sexuales Pagadas (ASP) 2022**.

---

## 1. Fuente de Datos y Fecha de Extracción

* **Entidad fuente:** Observatorio de Salud de Bogotá — **SaluData** (Secretaría Distrital de Salud de Bogotá).
* **Documento oficial:** *Boletín Estadístico: Indicadores de Salud y Demografía Bogotá D.C. 2020–2023* (`boletin_indicadores_2020_2023.pdf`).
* **Portal web:** [https://saludata.saludcapital.gov.co](https://saludata.saludcapital.gov.co)
* **Fecha de extracción:** 13 de noviembre de 2026.
* **Cobertura geográfica:** 19 localidades urbanas de Bogotá D.C. (`codigo_localidad` 1 a 19; excluye Sumapaz por ausencia de medición en las tablas del boletín).

---

## 2. Estructura de Archivos

### Scripts (`Mineria/scraping/`)
* **`scraping_saludata.py`**: Descarga el boletín oficial en caché local (`data/raw/saludata/`) para evitar peticiones redundantes al servidor, verifica las tablas objetivo mediante `pdfplumber` y expresiones regulares (`re`), normaliza nombres/códigos de localidad y exporta los datasets limpios.
* **`integracion_asp_saludata.py`**: Normaliza las llaves textuales de localidad (tildes, mayúsculas y alias como `RAFAEL URIBE` → `Rafael Uribe Uribe`) y ejecuta un cruce `left` (`m:1`) entre los 3,004 registros de la encuesta ASP 2022 y los indicadores de SaluData.

### Datasets generados (`data/`)
* **`pobreza_localidade_limpio.csv`**: Indicadores de desigualdad y pobreza por localidad para los años 2011, 2014, 2017 y 2021 (`gini_*`, `pobreza_monetaria_pct_*`, `pobreza_extrema_pct_*`). Extraído de la página 42 del PDF.
* **`afiliacion_localidades_limpio.csv`**: Población afiliada y porcentajes por régimen de seguridad social en salud (Subsidiado, Contributivo y Excepción) para los años 2020 a 2023. Extraído de la página 19 del PDF.
* **`asp_2022_saludata_integrado.csv`**: Base final enriquecida con **3,004 registros** y **104 variables** (`19 de 19` localidades cruzadas, `0` registros sin cruce).

---

## 3. Requisitos y Ejecución

### Dependencias

```bash
pip install -r requirements.txt
```

(o solo las de este módulo: `pip install requests pdfplumber pandas`)

### Ejecución

Los scripts se ejecutan **desde la raíz del repositorio**, porque usan rutas `data/...`:

```bash
# 1. Ver el texto de las páginas de las tablas (opcional, para revisar)
python Mineria/scraping/scraping_saludata.py --debug

# 2. Descargar el boletín y extraer las tablas
python Mineria/scraping/scraping_saludata.py

# 3. Limpiar las tablas (nombres de columnas y porcentajes propios)
python Mineria/scraping/limpieza_saludata.py

# 4. Cruzar los indicadores con la encuesta ASP 2022
python Mineria/scraping/integracion_asp_saludata.py
```

El PDF se guarda en `data/raw/saludata/` (está en `.gitignore`, no se sube al repositorio). Si ya está descargado, el script no lo vuelve a pedir al servidor.

### Archivos que genera

| Paso | Archivo |
| --- | --- |
| 2 | `data/processed/saludata_pobreza_localidad_crudo.csv`, `data/processed/saludata_afiliacion_localidad_crudo.csv` |
| 3 | `data/processed/pobreza_localidade_limpio.csv`, `data/processed/afiliacion_localidades_limpio.csv` |
| 4 | `data/processed/asp_2022_saludata_integrado.csv` |