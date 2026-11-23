"""
Lambda de predicción - VERSIÓN 1
Recibe el perfil de una persona desde la web y devuelve:
  1. Su perfil de vulnerabilidad (cluster de K-Means, notebook de Minería)
  2. Su riesgo de NO afiliación a salud (regresión logística, notebook de ML)
  3. Los factores que más suben y bajan ese riesgo
Los modelos se leen de S3 como JSON y se calculan con Python puro (sin scikit-learn).
"""
import json
import math
import os
import uuid
from datetime import datetime, timezone
from decimal import Decimal

import boto3  # librería de AWS para Python (ya viene incluida en Lambda)

# =====================================================
# Se ejecuta UNA vez cuando Lambda arranca (no en cada petición)
# =====================================================
s3 = boto3.client("s3")
tabla = boto3.resource("dynamodb").Table(os.environ["TABLA_PREDICCIONES"])


def cargar_json(clave):
    """Descarga un archivo JSON del bucket del modelo y lo convierte en diccionario."""
    objeto = s3.get_object(Bucket=os.environ["BUCKET_MODELO"], Key=clave)
    return json.loads(objeto["Body"].read())


CLUSTERING = cargar_json("modelo/clustering_config.json")
MODELO = cargar_json("modelo/modelo_afiliacion.json")

# Variables numéricas y su rango permitido (mínimo, máximo)
NUMERICAS = {
    "edad": (18, 90),
    "personas_hogar": (1, 20),
    "dependientes_economicos": (0, 20),
    "autopercepcion_nivel_economico": (1, 10),
    "horas_semana_asp": (0, 168),
    "edad_inicio_asp": (10, 90),
}

# Variables de sí/no (llegan como true/false)
BINARIAS = [
    "migrante", "grupo_etnico", "victima_conflicto_armado", "ingresos_insuficientes",
    "paga_intermediario_tercero", "discriminacion_general", "amenazas_recibidas",
    "forzada_relaciones_sexuales", "violencia_fuerza_publica",
]

# Nombres legibles para explicar el resultado en la web
NOMBRES = {
    "edad": "Edad",
    "personas_hogar": "Personas en el hogar",
    "dependientes_economicos": "Dependientes económicos",
    "autopercepcion_nivel_economico": "Nivel económico percibido",
    "horas_semana_asp": "Horas semanales de actividad",
    "edad_inicio_asp": "Edad de inicio de la actividad",
    "tiempo_viviendo_bogota": "Tiempo viviendo en Bogotá",
    "nivel_educativo": "Nivel educativo",
    "tipo_vivienda": "Tipo de vivienda",
    "migrante": "Condición de migrante",
    "grupo_etnico": "Pertenencia étnica",
    "victima_conflicto_armado": "Víctima del conflicto armado",
    "ingresos_insuficientes": "Ingresos insuficientes",
    "paga_intermediario_tercero": "Paga a un intermediario",
    "discriminacion_general": "Ha sufrido discriminación",
    "amenazas_recibidas": "Ha recibido amenazas",
    "forzada_relaciones_sexuales": "Ha sido forzada a relaciones sexuales",
    "violencia_fuerza_publica": "Violencia de la fuerza pública",
    "pobreza_monetaria_pct_2021": "Pobreza monetaria de la localidad",
    "gini_2021": "Desigualdad (Gini) de la localidad",
    "subsidiado_pct_propio_2022": "% régimen subsidiado de la localidad",
}


# =====================================================
# Función principal: AWS la ejecuta en cada petición
# =====================================================
def lambda_handler(event, context):
    # 1. Leer el perfil que llega en el cuerpo (body) de la petición
    try:
        perfil = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return respuesta(400, {"error": "El cuerpo debe ser un JSON válido"})

    # 2. Revisar que estén todas las respuestas y convertirlas a números
    valores, errores = validar_y_transformar(perfil)
    if errores:
        return respuesta(400, {"error": "Perfil incompleto o inválido", "detalles": errores})

    # 3. Perfil de vulnerabilidad (usa las 18 variables de la persona)
    cluster = asignar_cluster(valores)

    # 4. Riesgo de NO afiliación (18 variables + 3 indicadores de su localidad)
    indicadores = MODELO["indicadores_localidad"][perfil["localidad"]]
    valores_modelo = valores + [indicadores[v] for v in MODELO["variables"][len(valores):]]
    probabilidad, aportes = probabilidad_no_afiliacion(valores_modelo)
    alto_riesgo = probabilidad >= MODELO["umbral"]

    resultado = {
        "perfil_vulnerabilidad": {
            "cluster": cluster,
            "nombre": CLUSTERING["nombres_perfiles"][str(cluster)],
        },
        "riesgo_no_afiliacion": {
            "probabilidad": round(probabilidad, 3),
            "clasificacion": "Alto riesgo" if alto_riesgo else "Bajo riesgo",
            "umbral": MODELO["umbral"],
        },
        "factores_que_aumentan_riesgo": principales_factores(aportes, perfil, valores_modelo, positivos=True),
        "factores_que_reducen_riesgo": principales_factores(aportes, perfil, valores_modelo, positivos=False),
    }

    # 5. Guardar el registro en DynamoDB (anónimo: no se pide nombre ni documento)
    id_prediccion = str(uuid.uuid4())
    tabla.put_item(Item={
        "id": id_prediccion,
        "fecha": datetime.now(timezone.utc).isoformat(),
        "perfil": json.dumps(perfil, ensure_ascii=False),
        "cluster": cluster,
        "probabilidad": Decimal(str(round(probabilidad, 3))),  # DynamoDB no acepta float
        "alto_riesgo": alto_riesgo,
    })

    # 6. Todo lo que se imprime con print() queda en CloudWatch Logs
    print(json.dumps({"id": id_prediccion, "cluster": cluster,
                      "probabilidad": round(probabilidad, 3)}, ensure_ascii=False))

    # 7. Responder
    return respuesta(200, {"id": id_prediccion, **resultado})


# =====================================================
# Validación y transformación del perfil
# =====================================================
def validar_y_transformar(perfil):
    """Devuelve (lista de 18 valores en el orden del modelo, lista de errores)."""
    errores = []
    convertidos = {}

    for variable in CLUSTERING["variables"]:
        if variable not in perfil:
            errores.append("Falta: " + variable)
            continue
        dato = perfil[variable]

        if variable in NUMERICAS:
            minimo, maximo = NUMERICAS[variable]
            if isinstance(dato, bool) or not isinstance(dato, (int, float)) or not minimo <= dato <= maximo:
                errores.append("%s debe ser un número entre %s y %s" % (variable, minimo, maximo))
            else:
                convertidos[variable] = float(dato)

        elif variable in CLUSTERING["recodificacion"]:
            opciones = CLUSTERING["recodificacion"][variable]
            if dato not in opciones:
                errores.append("%s debe ser una de: %s" % (variable, ", ".join(opciones)))
            else:
                convertidos[variable] = float(opciones[dato])

        elif variable in BINARIAS:
            if not isinstance(dato, bool):
                errores.append(variable + " debe ser true o false")
            else:
                convertidos[variable] = 1.0 if dato else 0.0

    if perfil.get("localidad") not in MODELO["indicadores_localidad"]:
        errores.append("localidad debe ser una de las 19 localidades urbanas de Bogotá")

    if not errores and convertidos["edad_inicio_asp"] > convertidos["edad"]:
        errores.append("edad_inicio_asp no puede ser mayor que edad")

    valores = [convertidos.get(v) for v in CLUSTERING["variables"]]
    return valores, errores


# =====================================================
# Modelos (mismas funciones que se verificaron en los notebooks)
# =====================================================
def asignar_cluster(valores):
    """Escalado -> PCA -> centroide más cercano (K-Means)."""
    esc = CLUSTERING["escalador"]
    pca = CLUSTERING["pca"]

    z = [(v - m) / d for v, m, d in zip(valores, esc["media"], esc["desviacion"])]
    centrado = [a - m for a, m in zip(z, pca["media"])]
    componentes = [sum(a * c for a, c in zip(centrado, fila)) for fila in pca["componentes"]]
    distancias = [sum((a - b) ** 2 for a, b in zip(componentes, centroide))
                  for centroide in CLUSTERING["kmeans"]["centroides"]]
    return distancias.index(min(distancias))


def probabilidad_no_afiliacion(valores):
    """Escalado -> regresión logística. Devuelve la probabilidad y el aporte de cada variable."""
    esc = MODELO["escalador"]
    log = MODELO["logistica"]

    z = [(v - m) / d for v, m, d in zip(valores, esc["media"], esc["desviacion"])]
    aportes = {variable: c * v for variable, c, v in zip(MODELO["variables"], log["coeficientes"], z)}
    puntaje = log["intercepto"] + sum(aportes.values())
    return 1 / (1 + math.exp(-puntaje)), aportes


def principales_factores(aportes, perfil, valores_modelo, positivos, cuantos=3):
    """Las variables que más suben (positivos=True) o bajan (False) el riesgo de esta persona,
    con el valor que tiene la persona. Ej.: "Tiempo viviendo en Bogotá: Menos de 1 año"."""
    ordenados = sorted(aportes.items(), key=lambda par: par[1], reverse=positivos)
    factores = []
    for variable, aporte in ordenados[:cuantos]:
        if (positivos and aporte <= 0.05) or (not positivos and aporte >= -0.05):
            continue  # aportes muy pequeños no se muestran
        if variable in perfil:
            dato = perfil[variable]
            if isinstance(dato, bool):
                dato = "Sí" if dato else "No"
        else:  # indicadores de la localidad: no vienen en el perfil
            dato = valores_modelo[MODELO["variables"].index(variable)]
        factores.append("%s: %s" % (NOMBRES[variable], dato))
    return factores


def respuesta(codigo, cuerpo):
    """Arma la respuesta HTTP en el formato que espera API Gateway."""
    return {
        "statusCode": codigo,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(cuerpo, ensure_ascii=False),
    }
