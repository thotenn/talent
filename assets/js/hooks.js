// Este archivo contiene hooks personalizados para Phoenix LiveView
// Debe ser colocado en assets/js/hooks.js

let Hooks = {}

// Hook para resaltar elementos que cambian en tiempo real
Hooks.HighlightUpdates = {
  mounted() {
    console.log('Hook montado en elemento:', this.el.id);
    
    this.handleEvent("phx:update", () => {
      console.log('Evento phx:update recibido en', this.el.id);
      this.el.classList.add('bg-green-100');
      
      setTimeout(() => {
        this.el.classList.remove('bg-green-100');
      }, 2000);
    });
  }
}

// Hook para sincronizar inputs range y number en la interfaz de calificación
Hooks.SyncInputs = {
  mounted() {
    const input = this.el;
    const targetId = input.getAttribute("data-target");
    const displayId = input.getAttribute("data-display");
    
    // Función para actualizar valores relacionados
    const updateValues = () => {
      const targetInput = document.getElementById(targetId);
      const displayElement = displayId ? document.getElementById(displayId) : null;
      
      if (targetInput) {
        targetInput.value = input.value;
      }
      
      if (displayElement) {
        displayElement.textContent = input.value;
        
        // Añadir clase según el valor para cambiar colores
        displayElement.parentElement.classList.remove('low-score', 'medium-score', 'high-score');
        
        // Obtener el valor máximo del input
        const max = parseInt(input.max, 10) || 100;
        const value = parseInt(input.value, 10) || 0;
        const percentage = (value / max) * 100;
        
        // Asignar clase según porcentaje
        if (percentage < 33) {
          displayElement.parentElement.classList.add('low-score');
        } else if (percentage < 66) {
          displayElement.parentElement.classList.add('medium-score');
        } else {
          displayElement.parentElement.classList.add('high-score');
        }
        
        // Efecto de animación al cambiar
        displayElement.parentElement.classList.add('updated');
        setTimeout(() => {
          displayElement.parentElement.classList.remove('updated');
        }, 300);
      }
    };
    
    // Escuchar eventos de entrada
    input.addEventListener("input", updateValues);
    
    // Actualizar al montar para garantizar sincronización inicial
    updateValues();
  }
};

export default Hooks;