(() => {
  const views = {
    inicio: { title: "Panel general", heading: "La misión empieza aquí", description: "Un espacio común para coordinar el trabajo, documentar avances y llevar BENISAT de Jerez al espacio." },
    actuaciones: { title: "Actuaciones", heading: "Cada tarea mueve la misión.", description: "Planificación de tareas, responsables, prioridades, fechas límite y seguimiento." },
    calendario: { title: "Calendario", heading: "El tiempo también forma parte de la misión.", description: "Hitos de CanSat, reuniones, pruebas y fechas de entrega." },
    financiacion: { title: "Financiación", heading: "Cada recurso cuenta.", description: "Control de presupuesto, ventas, aportaciones, gastos y patrocinios." },
    difusion: { title: "Comunicación", heading: "Contamos lo que descubrimos.", description: "Planificación de publicaciones, campañas, alcance y evidencias de difusión." },
    documentacion: { title: "Documentación", heading: "Todo avance deja evidencia.", description: "Documentos técnicos, pruebas, informes, fotografías y enlaces de Drive." }
  };
  const navButtons = document.querySelectorAll("[data-view]");
  const content = document.getElementById("view-content");
  const title = document.getElementById("page-title");
  const description = document.getElementById("page-description");
  const crumb = document.getElementById("crumb-current");

  navButtons.forEach(button => button.addEventListener("click", () => {
    const key = button.dataset.view;
    const view = views[key];
    if (!view) return;
    navButtons.forEach(item => item.classList.toggle("active", item === button));
    title.innerHTML = key === "inicio" ? "La misión empieza aquí<span>.</span>" : view.heading;
    description.textContent = view.description;
    crumb.textContent = view.title;
    if (key === "inicio") {
      location.hash = "";
      window.location.reload();
      return;
    }
    location.hash = key;
    content.innerHTML = `
      <div class="section-heading"><div><div class="eyebrow">CENTRO DE OPERACIONES</div><h2>${view.title}</h2></div><span class="muted">BENISAT · 2026–2027</span></div>
      <div class="page-placeholder">
        <span class="placeholder-label">MÓDULO PLANIFICADO</span>
        <h2>${view.title}</h2>
        <p>${view.description}</p>
        <p>Este módulo se conectará a Supabase cuando configuremos las tablas y los permisos. Así, el equipo podrá trabajar con los mismos datos desde distintos dispositivos, con acceso individual y trazabilidad.</p>
      </div>`;
  }));
})();