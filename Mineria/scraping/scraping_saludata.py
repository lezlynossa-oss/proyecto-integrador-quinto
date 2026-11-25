"""
scraping_saludata.py
Proyecto integrador ASP - Módulo de web scraping (requisito R6)

Fuente: Secretaría Distrital de Salud - Observatorio de Salud de Bogotá
(SaluData), "Boletín de indicadores básicos de salud 2020-2023".
De ese PDF se extraen dos tablas por localidad:
  - C2-Tabla 1: Pobreza en Bogotá D.C. (Gini, pobreza monetaria y
    pobreza monetaria extrema; 2011, 2014, 2017 y 2021)
  - C2-Tabla 2: Afiliación según régimen de aseguramiento en el SGSSS
    (subsidiado, contributivo, excepción; 2020-2023)

Uso (desde la raíz del repositorio, con el entorno virtual activado):
  1) Ver el texto de las páginas de las tablas (hazlo primero):
       python Mineria/scraping/scraping_saludata.py --debug
  2) Extraer las tablas a CSV:
       python Mineria/scraping/scraping_saludata.py
"""

import argparse
import re
import time
import unicodedata
from pathlib import Path

import pandas as pd
import pdfplumber
import requests

URL_PDF = ("https://saludata.saludcapital.gov.co/osb/wp-content/uploads/"
           "2024/06/BOLETIN-INDICADORES-BASICOS-SALUD-2020-2023_WebFinal.pdf")

CARPETA_RAW = Path("data/raw/saludata")
CARPETA_OUT = Path("data/processed")
PDF_LOCAL = CARPETA_RAW / "boletin_indicadores_2020_2023.pdf"

HEADERS = {
    "User-Agent": "Proyecto academico USTA Tunja - indicadores publicos "
                  "por localidad (contacto: daniela.lopez@ustatunja.edu.co)"
}

# Texto que identifica la página de cada tabla (en minúsculas y sin tildes)
TABLAS = {
    "pobreza": "c2-tabla 1",
    "afiliacion": "c2-tabla 2",
}

# Código de localidad -> palabra clave para encontrarla en el texto
LOCALIDADES = {
    1: ("Usaquén", "usaquen"), 2: ("Chapinero", "chapinero"),
    3: ("Santa Fe", "santafe"), 4: ("San Cristóbal", "sancristobal"),
    5: ("Usme", "usme"), 6: ("Tunjuelito", "tunjuelito"),
    7: ("Bosa", "bosa"), 8: ("Kennedy", "kennedy"),
    9: ("Fontibón", "fontibon"), 10: ("Engativá", "engativa"),
    11: ("Suba", "suba"), 12: ("Barrios Unidos", "barriosunidos"),
    13: ("Teusaquillo", "teusaquillo"), 14: ("Los Mártires", "martires"),
    15: ("Antonio Nariño", "antonionarino"),
    16: ("Puente Aranda", "puentearanda"),
    17: ("La Candelaria", "candelaria"),
    18: ("Rafael Uribe Uribe", "rafaeluribe"),
    19: ("Ciudad Bolívar", "ciudadbolivar"),
}

# Números en formato colombiano: 124.525 (miles), 30,8 (decimal), 2023
PATRON_NUM = re.compile(r"\d{1,3}(?:\.\d{3})+(?:,\d+)?|\d+,\d+|\d+")


def normalizar(texto: str) -> str:
    """Minúsculas, sin tildes y sin espacios: 'Ciudad Bolívar' -> 'ciudadbolivar'."""
    texto = unicodedata.normalize("NFKD", texto)
    texto = "".join(c for c in texto if not unicodedata.combining(c))
    return re.sub(r"\s+", "", texto.lower())


def a_numero(valor: str) -> float:
    """'124.525' -> 124525.0 ; '30,8' -> 30.8"""
    return float(valor.replace(".", "").replace(",", "."))


# ---------------------------------------------------------------------------
# Paso 1: descargar el PDF (una sola vez)
# ---------------------------------------------------------------------------
def descargar() -> Path:
    if PDF_LOCAL.exists():
        print(f"PDF ya descargado: {PDF_LOCAL}")
        return PDF_LOCAL
    CARPETA_RAW.mkdir(parents=True, exist_ok=True)
    print(f"Descargando {URL_PDF}")
    resp = requests.get(URL_PDF, headers=HEADERS, timeout=120)
    resp.raise_for_status()
    if not resp.content.startswith(b"%PDF"):
        raise ValueError("La respuesta no es un PDF (¿la página cambió?)")
    PDF_LOCAL.write_bytes(resp.content)
    time.sleep(2)
    print(f"Guardado en {PDF_LOCAL} ({len(resp.content)/1e6:.1f} MB)")
    return PDF_LOCAL


# ---------------------------------------------------------------------------
# Paso 2: encontrar la página de cada tabla
# ---------------------------------------------------------------------------
def buscar_paginas(ruta_pdf: Path) -> dict:
    """Devuelve {'pobreza': texto_pagina, 'afiliacion': texto_pagina}."""
    encontradas = {}
    with pdfplumber.open(ruta_pdf) as pdf:
        for i, pagina in enumerate(pdf.pages):
            texto = pagina.extract_text() or ""
            plano = normalizar(texto)
            for nombre, marca in TABLAS.items():
                # La primera vez que aparece suele ser el índice: nos quedamos
                # con la página que además tiene nombres de localidades.
                if (nombre not in encontradas and normalizar(marca) in plano
                        and "kennedy" in plano and "usme" in plano):
                    encontradas[nombre] = texto
                    print(f"  Tabla '{nombre}' en la página {i + 1} del PDF")
    return encontradas


# ---------------------------------------------------------------------------
# Paso 3: sacar los números de la fila de cada localidad
# ---------------------------------------------------------------------------
def filas_por_localidad(texto: str) -> pd.DataFrame:
    filas = []
    lineas = texto.splitlines()
    for codigo, (nombre, clave) in LOCALIDADES.items():
        for linea in lineas:
            if clave in normalizar(linea):
                numeros = [a_numero(n) for n in PATRON_NUM.findall(linea)]
                if len(numeros) >= 3:
                    filas.append({"cod_localidad": codigo, "localidad": nombre,
                                  **{f"v{j+1}": v for j, v in enumerate(numeros)}})
                    break
    return pd.DataFrame(filas)


# ---------------------------------------------------------------------------
# Paso 4: validar
# ---------------------------------------------------------------------------
def validar(df: pd.DataFrame, nombre: str) -> None:
    faltan = sorted(set(LOCALIDADES) - set(df.get("cod_localidad", [])))
    print(f"\n[{nombre}] localidades encontradas: {len(df)} de 19"
          + (f" -> faltan códigos {faltan}" if faltan else "  OK"))
    if len(df):
        n_cols = df.filter(like="v").notna().sum(axis=1)
        if n_cols.nunique() > 1:
            print("  OJO: no todas las filas tienen la misma cantidad de "
                  "números. Revisa con --debug.")
        print(df.head(3).to_string(index=False))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--debug", action="store_true",
                        help="muestra el texto crudo de las páginas de las tablas")
    args = parser.parse_args()

    ruta = descargar()
    paginas = buscar_paginas(ruta)

    if args.debug:
        for nombre, texto in paginas.items():
            print(f"\n{'=' * 30} {nombre.upper()} {'=' * 30}\n{texto}")
        if not paginas:
            print("No se encontraron las tablas. ¿El PDF tiene las tablas como imagen?")
        return

    CARPETA_OUT.mkdir(parents=True, exist_ok=True)
    for nombre, texto in paginas.items():
        df = filas_por_localidad(texto)
        validar(df, nombre)
        salida = CARPETA_OUT / f"saludata_{nombre}_localidad_crudo.csv"
        df.to_csv(salida, index=False, encoding="utf-8-sig")  # utf-8-sig: Excel muestra bien las tildes
        print(f"  Guardado: {salida}")

    print("\nLas columnas v1, v2, ... se nombran en el siguiente paso, "
          "mirando el encabezado de la tabla en el PDF.")


if __name__ == "__main__":
    main()