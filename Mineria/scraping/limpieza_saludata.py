"""
Limpieza y estandarizacion de las tablas extraidas del boletin de SaluData
(Indicadores Basicos de Salud en Bogota D.C. 2020-2023).

Uso (desde la raiz del repositorio):
    python Mineria/scraping/limpieza_saludata.py
"""

from pathlib import Path
import pandas as pd

CARPETA_PROCESSED = Path("data/processed")

CRUDO_POBREZA = CARPETA_PROCESSED / "saludata_pobreza_localidad_crudo.csv"
LIMPIO_POBREZA = CARPETA_PROCESSED / "pobreza_localidade_limpio.csv"

CRUDO_AFILIACION = CARPETA_PROCESSED / "saludata_afiliacion_localidad_crudo.csv"
LIMPIO_AFILIACION = CARPETA_PROCESSED / "afiliacion_localidades_limpio.csv"

ANIOS_POBREZA = [2011, 2014, 2017, 2021]
ANIOS_AFILIACION = [2020, 2021, 2022, 2023]


def limpiar_pobreza() -> pd.DataFrame:
    if CRUDO_POBREZA.exists():
        df = pd.read_csv(CRUDO_POBREZA)
        renombre = {"cod_localidad": "codigo_localidad"}
        idx = 1
        for anio in ANIOS_POBREZA:
            renombre[f"v{idx}"] = f"gini_{anio}"
            renombre[f"v{idx + 1}"] = f"pobreza_monetaria_pct_{anio}"
            renombre[f"v{idx + 2}"] = f"pobreza_extrema_pct_{anio}"
            idx += 3
        df = df.rename(columns=renombre)
    else:
        df = pd.read_csv(LIMPIO_POBREZA)

    cols = ["codigo_localidad", "localidad"] + [
        col
        for anio in ANIOS_POBREZA
        for col in (
            f"gini_{anio}",
            f"pobreza_monetaria_pct_{anio}",
            f"pobreza_extrema_pct_{anio}",
        )
    ]
    df = df[cols].sort_values("codigo_localidad").reset_index(drop=True)
    df.to_csv(LIMPIO_POBREZA, index=False, encoding="utf-8-sig")
    print(f"[OK] Pobreza limpia guardada en {LIMPIO_POBREZA} ({len(df)} localidades)")
    return df


def limpiar_afiliacion() -> pd.DataFrame:
    usar_crudo = False
    if CRUDO_AFILIACION.exists():
        df_crudo = pd.read_csv(CRUDO_AFILIACION)
        if "v24" in df_crudo.columns:
            renombre = {"cod_localidad": "codigo_localidad"}
            idx = 1
            for anio in ANIOS_AFILIACION:
                for regimen in ("subsidiado", "contributivo", "excepcion"):
                    renombre[f"v{idx}"] = f"{regimen}_n_{anio}"
                    renombre[f"v{idx + 1}"] = f"{regimen}_pct_boletin_{anio}"
                    idx += 2
            df = df_crudo.rename(columns=renombre)
            usar_crudo = True

    if not usar_crudo:
        df = pd.read_csv(LIMPIO_AFILIACION)

    for anio in ANIOS_AFILIACION:
        col_sub = f"subsidiado_n_{anio}"
        col_con = f"contributivo_n_{anio}"
        col_exc = f"excepcion_n_{anio}"
        col_tot = f"total_afiliados_{anio}"

        df[col_tot] = df[col_sub] + df[col_con] + df[col_exc]
        df[f"subsidiado_pct_propio_{anio}"] = (df[col_sub] / df[col_tot] * 100).round(2)
        df[f"contributivo_pct_propio_{anio}"] = (df[col_con] / df[col_tot] * 100).round(2)
        df[f"excepcion_pct_propio_{anio}"] = (df[col_exc] / df[col_tot] * 100).round(2)

    cols_base = ["codigo_localidad", "localidad"]
    cols_boletin = [
        f"{reg}_{tipo}_{anio}"
        for anio in ANIOS_AFILIACION
        for reg in ("subsidiado", "contributivo", "excepcion")
        for tipo in ("n", "pct_boletin")
    ]
    cols_propios = [
        col
        for anio in ANIOS_AFILIACION
        for col in (
            f"total_afiliados_{anio}",
            f"subsidiado_pct_propio_{anio}",
            f"contributivo_pct_propio_{anio}",
            f"excepcion_pct_propio_{anio}",
        )
    ]
    df = df[cols_base + cols_boletin + cols_propios].sort_values("codigo_localidad").reset_index(drop=True)
    df.to_csv(LIMPIO_AFILIACION, index=False, encoding="utf-8-sig")
    print(f"[OK] Afiliacion limpia guardada en {LIMPIO_AFILIACION} ({len(df)} localidades)")
    return df


def main() -> None:
    CARPETA_PROCESSED.mkdir(parents=True, exist_ok=True)
    limpiar_pobreza()
    limpiar_afiliacion()


if __name__ == "__main__":
    main()
