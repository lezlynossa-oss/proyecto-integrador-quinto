<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ASP · Vulnerabilidad en el acceso a salud</title>
  <style>
    :root {
      --morado: #6d3fb0;
      --texto: #1f2937;
      --gris: #6b7280;
      --borde: #e5e7eb;
      --fondo: #f4f5f7;
      --alto: #c2410c;
      --alto-fondo: #fff1e7;
      --bajo: #1d6b57;
      --bajo-fondo: #e6f4ef;
    }
    * { box-sizing: border-box; }
    body { font-family: system-ui, -apple-system, sans-serif; background: var(--fondo); margin: 0; padding: 2rem 1rem; color: var(--texto); }
    .contenedor { max-width: 760px; margin: auto; }
    .card { background: #fff; border-radius: 12px; padding: 1.75rem; box-shadow: 0 1px 3px rgba(0,0,0,.08); margin-bottom: 1.25rem; }
    h1 { font-size: 1.4rem; margin: 0 0 .25rem; }
    h2 { font-size: 1rem; margin: 0 0 .25rem; color: var(--morado); }
    .sub { color: var(--gris); font-size: .9rem; margin: 0; line-height: 1.5; }
    fieldset { border: 0; border-top: 1px solid var(--borde); margin: 1.5rem 0 0; padding: 1.25rem 0 0; }
    legend { font-weight: 700; font-size: .95rem; padding: 0; }
    .grid { display: grid; grid-template-columns: 1fr 1fr; gap: .25rem 1rem; }
    @media (max-width: 600px) { .grid { grid-template-columns: 1fr; } }
    label { display: block; margin-top: .85rem; font-weight: 600; font-size: .85rem; }
    input, select { width: 100%; padding: .55rem .6rem; margin-top: .3rem; border: 1px solid #d1d5db; border-radius: 8px; font-size: .95rem; background: #fff; color: var(--texto); }
    input:focus, select:focus { outline: 2px solid var(--morado); outline-offset: 1px; }
    button { margin-top: 1.75rem; width: 100%; padding: .85rem; background: var(--morado); color: #fff; border: 0; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; }
    button:disabled { opacity: .6; cursor: wait; }

    /* Resultado */
    #resultado { display: none; }
    .etiqueta { font-size: .75rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; color: var(--gris); margin: 0 0 .35rem; }
    .perfil-nombre { font-size: 1.2rem; font-weight: 700; margin: 0 0 .35rem; }
    .riesgo { border-radius: 10px; padding: 1.1rem 1.25rem; margin-top: 1.25rem; }
    .riesgo.alto { background: var(--alto-fondo); }
    .riesgo.bajo { background: var(--bajo-fondo); }
    .riesgo-fila { display: flex; justify-content: space-between; align-items: baseline; gap: 1rem; flex-wrap: wrap; }
    .clasificacion { font-size: 1.15rem; font-weight: 700; }
    .alto .clasificacion { color: var(--alto); }
    .bajo .clasificacion { color: var(--bajo); }
    .porcentaje { font-size: 1.6rem; font-weight: 700; font-variant-numeric: tabular-nums; }
    .barra { position: relative; height: 10px; background: rgba(0,0,0,.08); border-radius: 5px; margin: .75rem 0 .35rem; }
    .barra-relleno { height: 100%; border-radius: 5px; }
    .alto .barra-relleno { background: var(--alto); }
    .bajo .barra-relleno { background: var(--bajo); }
    .barra-umbral { position: absolute; top: -4px; width: 2px; height: 18px; background: var(--texto); }
    .nota { font-size: .8rem; color: var(--gris); margin: 0; }
    .factores { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 1.25rem; }
    @media (max-width: 600px) { .factores { grid-template-columns: 1fr; } }
    .factores ul { margin: 0; padding-left: 1.1rem; font-size: .9rem; line-height: 1.6; }
    .sube { color: var(--alto); }
    .baja { color: var(--bajo); }
    .error { background: #fef2f2; color: #991b1b; border-radius: 8px; padding: 1rem; font-size: .9rem; }
    .error ul { margin: .5rem 0 0; padding-left: 1.1rem; }
    footer { font-size: .8rem; color: var(--gris); line-height: 1.5; text-align: center; }
    /* ---- Pestañas ---- */
    .tabs { display: flex; gap: .5rem; margin-bottom: 1.25rem; }
    .tabs button { margin: 0; width: auto; flex: 1; padding: .7rem 1rem; background: #fff; color: var(--texto); border: 1px solid var(--borde); font-size: .95rem; }
    .tabs button.activa { background: var(--morado); color: #fff; border-color: var(--morado); }
    .pestana { display: none; }
    .pestana.activa { display: block; }

    /* ---- Dashboard ---- */
    .kpis { display: grid; grid-template-columns: repeat(4, 1fr); gap: .6rem; margin-top: 1.25rem; }
    @media (max-width: 600px) { .kpis { grid-template-columns: 1fr 1fr; } }
    .kpi { border: 1px solid var(--borde); border-radius: 10px; padding: .8rem .5rem; text-align: center; font-size: .8rem; color: var(--gris); cursor: pointer; transition: border-color .15s, transform .15s; }
    .kpi:hover { border-color: var(--morado); transform: translateY(-2px); }
    .kpi b { display: block; font-size: 1.45rem; color: var(--texto); font-variant-numeric: tabular-nums; }
    .indice { position: sticky; top: 0; z-index: 5; display: flex; gap: .4rem; flex-wrap: wrap; padding: .6rem 0; background: var(--fondo); margin-bottom: .5rem; }
    .indice a { padding: .35rem .8rem; border-radius: 999px; background: #fff; border: 1px solid var(--borde); color: var(--texto); text-decoration: none; font-size: .85rem; }
    .indice a:hover { border-color: var(--morado); color: var(--morado); }
    .seccion-dash { scroll-margin-top: 3.5rem; }
    .seccion-dash > h2 { font-size: 1.1rem; margin: 1.5rem 0 .75rem; }
    .grafica h3 { font-size: 1rem; margin: 0 0 .25rem; }
    .grafica .hallazgo { margin: .5rem 0 0; font-size: .95rem; line-height: 1.5; }
    .grafica .hallazgo::before { content: "→ "; color: var(--morado); font-weight: 700; }
    .pie-dash { font-size: .8rem; color: var(--gris); line-height: 1.5; margin: 0 0 1.5rem; }
  </style>
  <script src="https://cdn.plot.ly/plotly-4.1.1.min.js"></script>
</head>
<body>
  <div class="contenedor">

    <nav class="tabs">
      <button type="button" class="activa" data-pestana="pestana-dashboard">Dashboard</button>
      <button type="button" data-pestana="pestana-prediccion">Predicción</button>
    </nav>

    <!-- ===== Pestaña Dashboard: estadística descriptiva de la encuesta ===== -->
    <section id="pestana-dashboard" class="pestana activa">
      <div class="card">
        <h1>Qué muestra la Encuesta ASP 2022</h1>
        <p class="sub">Panorama de las personas que realizan actividades sexuales pagadas (ASP) en Bogotá, según la encuesta de caracterización de la Secretaría Distrital de la Mujer. Haz clic en una cifra para ir a su sección.</p>
        <div class="kpis" id="kpis"></div>
      </div>
      <nav class="indice" id="indice"></nav>
      <div id="secciones-dash"></div>
      <p class="pie-dash">Todos los porcentajes están ponderados con el factor de expansión de la encuesta, así que representan a la población y no solo a las personas encuestadas. No se muestran grupos con menos de 10 respuestas. Pasa el cursor sobre una barra para ver cuántas respuestas hay detrás.</p>
    </section>

    <!-- ===== Pestaña Predicción (formulario existente) ===== -->
    <section id="pestana-prediccion" class="pestana">
    <div class="card">
      <h1>Vulnerabilidad en el acceso a salud</h1>
      <p class="sub">Herramienta de apoyo para identificar el perfil de vulnerabilidad y el riesgo de no afiliación a salud de personas que realizan actividades sexuales pagadas (ASP) en Bogotá. Modelos entrenados con la Encuesta ASP 2022 de la Secretaría Distrital de la Mujer.</p>

      <form id="formulario">
        <fieldset>
          <legend>Datos personales</legend>
          <div class="grid">
            <label>Edad
              <input type="number" id="edad" min="18" max="90" value="28" required>
            </label>
            <label>Localidad donde vive
              <select id="localidad" required></select>
            </label>
            <label>¿Nació fuera de Colombia?
              <select id="migrante" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
            <label>Tiempo viviendo en Bogotá
              <select id="tiempo_viviendo_bogota">
                <option>Menos de 1 año</option>
                <option>Entre 1 y 5 años</option>
                <option>Entre 6 y 10 años</option>
                <option>Más de 10 años</option>
              </select>
            </label>
            <label>Nivel educativo
              <select id="nivel_educativo">
                <option>Ninguno</option>
                <option>Preescolar</option>
                <option>Básica primaria</option>
                <option selected>Básica secundaria</option>
                <option>Media</option>
                <option>Técnico</option>
                <option>Tecnológico</option>
                <option>Universitario</option>
                <option>Especialización</option>
                <option>Doctorado</option>
              </select>
            </label>
            <label>¿Se reconoce de algún grupo étnico?
              <select id="grupo_etnico" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
          </div>
        </fieldset>

        <fieldset>
          <legend>Hogar y situación económica</legend>
          <div class="grid">
            <label>Personas en el hogar
              <input type="number" id="personas_hogar" min="1" max="20" value="2" required>
            </label>
            <label>Personas que dependen económicamente de ella
              <input type="number" id="dependientes_economicos" min="0" max="20" value="1" required>
            </label>
            <label>Tipo de vivienda
              <select id="tipo_vivienda">
                <option>Casa</option>
                <option>Apartamento</option>
                <option>Cuarto en estructura tipo vivienda</option>
                <option>Cuarto en hotel</option>
                <option>Cuarto en el establecimiento de ASP</option>
                <option>Otro tipo de vivienda</option>
              </select>
            </label>
            <label>Nivel económico percibido (1 = más bajo, 10 = más alto)
              <input type="number" id="autopercepcion_nivel_economico" min="1" max="10" value="3" required>
            </label>
            <label>¿Sus ingresos alcanzan para los gastos básicos?
              <select id="ingresos_insuficientes" data-tipo="si-no-invertido"><option>Sí</option><option>No</option></select>
            </label>
          </div>
        </fieldset>

        <fieldset>
          <legend>Actividad</legend>
          <div class="grid">
            <label>Horas a la semana en la actividad
              <input type="number" id="horas_semana_asp" min="0" max="168" value="40" required>
            </label>
            <label>Edad a la que inició la actividad
              <input type="number" id="edad_inicio_asp" min="10" max="90" value="20" required>
            </label>
            <label>¿Paga a un intermediario o tercero?
              <select id="paga_intermediario_tercero" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
          </div>
        </fieldset>

        <fieldset>
          <legend>Violencias y discriminación</legend>
          <div class="grid">
            <label>¿Es víctima del conflicto armado?
              <select id="victima_conflicto_armado" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
            <label>¿Ha sufrido discriminación?
              <select id="discriminacion_general" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
            <label>¿Ha recibido amenazas?
              <select id="amenazas_recibidas" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
            <label>¿Ha sido forzada a tener relaciones sexuales?
              <select id="forzada_relaciones_sexuales" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
            <label>¿Ha sufrido violencia de la fuerza pública?
              <select id="violencia_fuerza_publica" data-tipo="si-no"><option>No</option><option>Sí</option></select>
            </label>
          </div>
        </fieldset>

        <button type="submit" id="boton">Calcular perfil y riesgo</button>
      </form>
    </div>

    <div class="card" id="resultado"></div>
    </section>

    <footer>
      Prototipo académico · Proyecto integrador (Minería de Datos, Machine Learning y Cloud Computing) · Universidad Santo Tomás, Tunja.<br>
      No se piden nombres ni documentos: cada consulta se guarda de forma anónima. El resultado es una estimación estadística y no reemplaza la verificación de la afiliación en el sistema de salud.
    </footer>
  </div>

  <script>
    // Terraform reemplaza esto por la URL real de la API al subir la página
    var URL_API = "${url_api}";

    // Descripción corta de cada perfil (resultados del notebook de Minería)
    var DESCRIPCIONES = {
      0: "Cerca del 14 % de la población. Tienen las tasas más altas de amenazas, violencia sexual, violencia de la fuerza pública y discriminación; empezaron la actividad más jóvenes y trabajan más horas. Cerca del 32 % no está afiliada a salud.",
      1: "Cerca del 50 % de la población. La mayoría nació fuera de Colombia y lleva poco tiempo en Bogotá; son más jóvenes y tienen más personas a cargo. Casi 8 de cada 10 no tienen afiliación a salud.",
      2: "Cerca del 37 % de la población. Llevan muchos años en Bogotá, son mayores y la mayoría dice que sus ingresos no alcanzan. Es el perfil con mejor cobertura: cerca del 19 % no está afiliada."
    };

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

    // Lee el formulario y arma el perfil con los nombres y tipos que espera la Lambda
    function leerPerfil() {
      var perfil = {};
      document.querySelectorAll("#formulario input, #formulario select").forEach(function (campo) {
        var tipo = campo.getAttribute("data-tipo");
        if (campo.type === "number") {
          perfil[campo.id] = Number(campo.value);
        } else if (tipo === "si-no") {
          perfil[campo.id] = campo.value === "Sí";            // "Sí" -> true
        } else if (tipo === "si-no-invertido") {
          perfil[campo.id] = campo.value === "No";            // "¿alcanzan?" No -> ingresos insuficientes = true
        } else {
          perfil[campo.id] = campo.value;                     // categorías: se envían como texto
        }
      });
      return perfil;
    }

    // Escapa texto antes de ponerlo en la página (buena práctica de seguridad)
    function texto(valor) {
      var div = document.createElement("div");
      div.textContent = valor;
      return div.innerHTML;
    }

    function lista(elementos) {
      if (!elementos.length) return "<p class='nota'>Ningún factor destacado.</p>";
      return "<ul>" + elementos.map(function (e) { return "<li>" + texto(e) + "</li>"; }).join("") + "</ul>";
    }

    // Muestra el resultado de la Lambda de forma legible
    function mostrarResultado(datos) {
      var perfil = datos.perfil_vulnerabilidad;
      var riesgo = datos.riesgo_no_afiliacion;
      var nivel = riesgo.clasificacion === "Alto riesgo" ? "alto" : "bajo";
      var porcentaje = Math.round(riesgo.probabilidad * 100);
      var umbral = Math.round(riesgo.umbral * 100);

      return "" +
        "<p class='etiqueta'>Perfil de vulnerabilidad</p>" +
        "<p class='perfil-nombre'>" + texto(perfil.nombre) + "</p>" +
        "<p class='sub'>" + texto(DESCRIPCIONES[perfil.cluster] || "") + "</p>" +

        "<div class='riesgo " + nivel + "'>" +
          "<p class='etiqueta'>Riesgo de no estar afiliada a salud</p>" +
          "<div class='riesgo-fila'>" +
            "<span class='clasificacion'>" + texto(riesgo.clasificacion) + "</span>" +
            "<span class='porcentaje'>" + porcentaje + " %</span>" +
          "</div>" +
          "<div class='barra'>" +
            "<div class='barra-relleno' style='width:" + porcentaje + "%'></div>" +
            "<div class='barra-umbral' style='left:" + umbral + "%' title='Umbral'></div>" +
          "</div>" +
          "<p class='nota'>Se considera alto riesgo desde " + umbral + " % (línea negra). Modelo: regresión logística, AUC 0,88 en datos de prueba.</p>" +
        "</div>" +

        "<div class='factores'>" +
          "<div><p class='etiqueta sube'>Aumentan el riesgo</p>" + lista(datos.factores_que_aumentan_riesgo) + "</div>" +
          "<div><p class='etiqueta baja'>Reducen el riesgo</p>" + lista(datos.factores_que_reducen_riesgo) + "</div>" +
        "</div>";
    }

    function mostrarError(datos) {
      var detalles = datos.detalles ? lista(datos.detalles) : "";
      return "<div class='error'><strong>" + texto(datos.error || "Ocurrió un error") + "</strong>" + detalles + "</div>";
    }

    // Al enviar el formulario: mandar el perfil a la API y mostrar la respuesta
    document.getElementById("formulario").addEventListener("submit", function (evento) {
      evento.preventDefault(); // evita que la página se recargue
      var boton = document.getElementById("boton");
      var caja = document.getElementById("resultado");
      boton.disabled = true;
      boton.textContent = "Calculando...";

      fetch(URL_API, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(leerPerfil())
      })
        .then(function (r) {
          return r.json().then(function (datos) { return { ok: r.ok, datos: datos }; });
        })
        .then(function (res) {
          caja.innerHTML = res.ok ? mostrarResultado(res.datos) : mostrarError(res.datos);
        })
        .catch(function (error) {
          caja.innerHTML = mostrarError({ error: "No se pudo conectar con la API: " + error.message });
        })
        .finally(function () {
          caja.style.display = "block";
          caja.scrollIntoView({ behavior: "smooth" });
          boton.disabled = false;
          boton.textContent = "Calcular perfil y riesgo";
        });
    });
    // ===================== Pestañas y dashboard =====================
    // Cada cifra clave lleva a la sección que la explica
    var SECCION_DE_KPI = {
      "encuestas": "Dónde están",
      "sin afiliación a salud": "Acceso a salud",
      "migrantes": "Acceso a salud",
      "edad mediana": "Quiénes son"
    };

    function idSeccion(nombre) {
      return "sec-" + nombre.toLowerCase().normalize("NFD").replace(/[^a-z0-9]+/g, "-");
    }

    function irA(seccion) {
      var destino = document.getElementById(idSeccion(seccion));
      if (destino) destino.scrollIntoView({ behavior: "smooth" });
    }

    function dibujarDashboard(d) {
      // Cifras clave
      var kpis = document.getElementById("kpis");
      d.kpis.forEach(function (k) {
        var div = document.createElement("div");
        div.className = "kpi";
        div.innerHTML = "<b></b><span></span>";
        div.querySelector("b").textContent = k.valor;
        div.querySelector("span").textContent = k.etiqueta;
        if (SECCION_DE_KPI[k.etiqueta]) {
          div.addEventListener("click", function () { irA(SECCION_DE_KPI[k.etiqueta]); });
        }
        kpis.appendChild(div);
      });

      // Secciones, índice y una tarjeta por gráfica
      var contenedor = document.getElementById("secciones-dash");
      var indice = document.getElementById("indice");
      var secciones = {};
      d.figuras.forEach(function (g) {
        var nombreSec = g.seccion || "Resultados";
        if (!secciones[nombreSec]) {
          var sec = document.createElement("div");
          sec.className = "seccion-dash";
          sec.id = idSeccion(nombreSec);
          var h2 = document.createElement("h2");
          h2.textContent = nombreSec;
          sec.appendChild(h2);
          contenedor.appendChild(sec);
          secciones[nombreSec] = sec;

          var enlace = document.createElement("a");
          enlace.href = "#" + sec.id;
          enlace.textContent = nombreSec;
          enlace.addEventListener("click", function (e) { e.preventDefault(); irA(nombreSec); });
          indice.appendChild(enlace);
        }

        var layout = g.figura.layout || {};
        var tarjeta = document.createElement("div");
        tarjeta.className = "card grafica";
        var titulo = document.createElement("h3");
        titulo.textContent = (layout.title && layout.title.text) || "";
        var grafica = document.createElement("div");
        var hallazgo = document.createElement("p");
        hallazgo.className = "hallazgo";
        hallazgo.textContent = g.nota || "";
        tarjeta.appendChild(titulo);
        tarjeta.appendChild(grafica);
        if (g.nota) tarjeta.appendChild(hallazgo);
        secciones[nombreSec].appendChild(tarjeta);

        // El título va en la tarjeta (así se ajusta en el celular), no dentro de la gráfica
        delete layout.title;
        layout.margin = { t: 20, l: 10, r: 60, b: 50 };
        layout.font = { family: "system-ui, -apple-system, sans-serif", size: 12, color: "#1f2937" };
        layout.hoverlabel = { bgcolor: "#fff", bordercolor: "#6d3fb0", font: { color: "#1f2937" } };
        if (layout.yaxis) layout.yaxis.automargin = true;
        if (layout.xaxis) layout.xaxis.automargin = true;
        layout.xaxis = layout.xaxis || {};
        layout.xaxis.fixedrange = true;   // sin zoom accidental al tocar en el celular
        layout.yaxis = layout.yaxis || {};
        layout.yaxis.fixedrange = true;

        Plotly.newPlot(grafica, g.figura.data, layout, {
          responsive: true,
          displaylogo: false,
          modeBarButtons: [["toImage"]],   // solo el botón de descargar como imagen
          toImageButtonOptions: { filename: "asp-" + g.nombre }
        });
      });
    }

    var dashboardCargado = false;
    function cargarDashboard() {
      if (dashboardCargado) return;
      dashboardCargado = true;
      fetch("dashboard.json")
        .then(function (r) { return r.json(); })
        .then(dibujarDashboard)
        .catch(function () {
          document.getElementById("kpis").textContent = "No se pudo cargar el dashboard.";
        });
    }

    document.querySelectorAll(".tabs button").forEach(function (boton) {
      boton.addEventListener("click", function () {
        document.querySelectorAll(".tabs button, .pestana").forEach(function (el) {
          el.classList.remove("activa");
        });
        boton.classList.add("activa");
        document.getElementById(boton.dataset.pestana).classList.add("activa");
        if (boton.dataset.pestana === "pestana-dashboard") cargarDashboard();
      });
    });

    cargarDashboard();   // el dashboard es la pestaña que se ve al entrar
  </script>
</body>
</html>
