import unicodedata
import pandas as pd

ALIAS_LOCALIDADES = {
    "RAFAEL URIBE": "RAFAEL URIBE URIBE",
    "CANDELARIA": "LA CANDELARIA",
    "MARTIRES": "LOS MARTIRES",
}

def normalizar_localidad(texto: str) -> str:
    if pd.isna(texto):
        return ""
    texto = str(texto).strip().upper()
    texto = unicodedata.normalize("NFD", texto)
    texto = "".join(c for c in texto if unicodedata.category(c) != "Mn")
    texto = " ".join(texto.split())
    return ALIAS_LOCALIDADES.get(texto, texto)

def main():
    # 1. Cargar las tres bases limpias
    asp = pd.read_csv("data/raw/asp_2022_variables_renombradas.csv")
    pob = pd.read_csv("data/processed/pobreza_localidade_limpio.csv")
    afi = pd.read_csv("data/processed/afiliacion_localidades_limpio.csv")

    # 2. Crear llave normalizada para asegurar cruce exacto (100% de las 19 localidades)
    asp["_key_loc"] = asp["localidad"].apply(normalizar_localidad)
    pob["_key_loc"] = pob["localidad"].apply(normalizar_localidad)
    afi["_key_loc"] = afi["localidad"].apply(normalizar_localidad)

    # 3. Unir primero pobreza + afiliación por localidad (19 localidades)
    saludata = pd.merge(
        pob,
        afi.drop(columns=["codigo_localidad", "localidad"]),
        on="_key_loc",
        how="outer",
        validate="1:1",
    )

    # 4. Cruzar encuesta ASP con indicadores contextuales de SaluData (many-to-one)
    df_integrado = pd.merge(
        asp.drop(columns=["localidad"]),
        saludata,
        on="_key_loc",
        how="left",
        validate="m:1",
    ).drop(columns=["_key_loc"])

    df_integrado["codigo_localidad"] = df_integrado["codigo_localidad"].astype("Int64")

    # Reordenar para que codigo_localidad y localidad queden junto a id_persona
    cols_inicio = ["id_persona", "factor_expansion", "codigo_localidad", "localidad"]
    otras_cols = [c for c in df_integrado.columns if c not in cols_inicio]
    df_integrado = df_integrado[cols_inicio + otras_cols]

    # 5. Guardar dataset integrado
    ruta_salida = "data/processed/asp_2022_saludata_integrado.csv"
    df_integrado.to_csv(ruta_salida, index=False, encoding="utf-8-sig")

    # 6. Resumen ordenado en consola
    sin_cruce = df_integrado[df_integrado["codigo_localidad"].isna()]
    print("\n" + "=" * 60)
    print(" RESUMEN DE INTEGRACIÓN: ENCUESTA ASP 2022 + SALUDATA")
    print("=" * 60)
    print(f" Registros ASP originales : {len(asp):,}")
    print(f" Registros base integrada : {len(df_integrado):,}")
    print(f" Total de columnas        : {df_integrado.shape[1]}")
    print(f" Localidades cruzadas     : {df_integrado['localidad'].nunique()} de 19 localidades")
    print(f" Registros sin cruce      : {len(sin_cruce)}")
    print(f" Archivo guardado en      : {ruta_salida}")
    print("=" * 60)

    print("\nMuestra de validación (primeras 5 filas):")
    cols_vista = [
        "id_persona",
        "codigo_localidad",
        "localidad",
        "pobreza_monetaria_pct_2021",
        "gini_2021",
        "subsidiado_pct_boletin_2022",
    ]
    print(df_integrado[cols_vista].head().to_string(index=False))

if __name__ == "__main__":
    main()