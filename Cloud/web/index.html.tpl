<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ASP · Predicción de vulnerabilidad en salud</title>
  <style>
    body { font-family: system-ui, sans-serif; background: #f4f5f7; margin: 0; padding: 2rem; color: #1f2937; }
    .card { max-width: 520px; margin: auto; background: #fff; border-radius: 12px; padding: 2rem; box-shadow: 0 2px 10px rgba(0,0,0,.08); }
    h1 { font-size: 1.3rem; margin-top: 0; }
    .sub { color: #6b7280; font-size: .9rem; }
    label { display: block; margin-top: 1rem; font-weight: 600; font-size: .9rem; }
    input, select { width: 100%; padding: .6rem; margin-top: .3rem; border: 1px solid #d1d5db; border-radius: 8px; font-size: 1rem; box-sizing: border-box; }
    button { margin-top: 1.5rem; width: 100%; padding: .8rem; background: #7B42BC; color: #fff; border: 0; border-radius: 8px; font-size: 1rem; cursor: pointer; }
    button:disabled { opacity: .6; }
    #resultado { display: none; margin-top: 1.5rem; padding: 1rem; border-radius: 8px; background: #f3f4f6; white-space: pre-wrap; font-family: monospace; font-size: .85rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>Predicción de vulnerabilidad en el acceso a salud</h1>
    <p class="sub">Población ASP · Bogotá · Prototipo académico (versión 0)</p>

    <form id="formulario">
      <label>Edad
        <input type="number" id="edad" min="18" max="90" required>
      </label>
      <label>Localidad
        <select id="localidad" required></select>
      </label>
      <label>Nivel educativo
        <select id="nivel_educativo">
          <option>Ninguno</option>
          <option>Primaria</option>
          <option>Secundaria</option>
          <option>Técnico / tecnológico</option>
          <option>Universitario</option>
        </select>
      </label>
      <button type="submit" id="boton">Predecir</button>
    </form>

    <div id="resultado"></div>
  </div>

  <script>
    // Terraform reemplaza esto por la URL real de la API al subir la página
    var URL_API = "${url_api}";

    // Las 19 localidades urbanas de Bogotá
    var localidades = ["Usaquén", "Chapinero", "Santa Fe", "San Cristóbal", "Usme",
      "Tunjuelito", "Bosa", "Kennedy", "Fontibón", "Engativá", "Suba", "Barrios Unidos",
      "Teusaquillo", "Los Mártires", "Antonio Nariño", "Puente Aranda", "La Candelaria",
      "Rafael Uribe Uribe", "Ciudad Bolívar"];
    var select = document.getElementById("localidad");
    localidades.forEach(function (nombre) {
      var opcion = document.createElement("option");
      opcion.textContent = nombre;
      select.appendChild(opcion);
    });

    // Al enviar el formulario: mandar el perfil a la API y mostrar la respuesta
    document.getElementById("formulario").addEventListener("submit", function (evento) {
      evento.preventDefault(); // evita que la página se recargue
      var boton = document.getElementById("boton");
      var caja = document.getElementById("resultado");
      boton.disabled = true;
      boton.textContent = "Consultando...";

      var perfil = {
        edad: Number(document.getElementById("edad").value),
        localidad: document.getElementById("localidad").value,
        nivel_educativo: document.getElementById("nivel_educativo").value
      };

      fetch(URL_API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(perfil)
      })
        .then(function (r) { return r.json(); })
        .then(function (datos) { caja.textContent = JSON.stringify(datos, null, 2); })
        .catch(function (error) { caja.textContent = "Error: " + error.message; })
        .finally(function () {
          caja.style.display = "block";
          boton.disabled = false;
          boton.textContent = "Predecir";
        });
    });
  </script>
</body>
</html>
