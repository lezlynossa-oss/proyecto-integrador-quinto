"""
Lambda de predicción - VERSIÓN 0
Recibe un perfil desde la web, lo registra en DynamoDB y responde.
Todavía NO usa modelo: se integrará cuando ML lo exporte.
"""
import json
import os
import uuid
from datetime import datetime, timezone

import boto3  # librería de AWS para Python (ya viene incluida en Lambda)

# Se lee UNA vez cuando Lambda arranca (no en cada petición)
tabla = boto3.resource("dynamodb").Table(os.environ["TABLA_PREDICCIONES"])


def lambda_handler(event, context):
    """Función que AWS ejecuta en cada petición."""
    # 1. Leer el perfil que llega en el cuerpo (body) de la petición
    try:
        perfil = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return respuesta(400, {"error": "El cuerpo debe ser un JSON válido"})

    # 2. "Predecir" (por ahora, sin modelo)
    resultado = {
        "cluster": None,
        "riesgo_no_afiliacion": None,
        "estado": "modelo pendiente (versión 0)",
    }

    # 3. Guardar el registro en DynamoDB
    id_prediccion = str(uuid.uuid4())
    tabla.put_item(Item={
        "id": id_prediccion,
        "fecha": datetime.now(timezone.utc).isoformat(),
        "perfil": json.dumps(perfil, ensure_ascii=False),
        "estado": resultado["estado"],
    })

    # 4. Todo lo que se imprime con print() queda en CloudWatch Logs
    print(json.dumps({"id": id_prediccion, "perfil": perfil}, ensure_ascii=False))

    # 5. Responder
    return respuesta(200, {"id": id_prediccion, **resultado})


def respuesta(codigo, cuerpo):
    """Arma la respuesta HTTP en el formato que espera API Gateway."""
    return {
        "statusCode": codigo,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(cuerpo, ensure_ascii=False),
    }
