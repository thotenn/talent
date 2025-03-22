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

export default Hooks;