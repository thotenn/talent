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
    
    // NUEVO: Activar efecto hover en el contenedor para dispositivos móviles
    if (input.type === 'range') {
      // Buscar el contenedor del criterio (es el padre o el abuelo generalmente)
      let criterionContainer = findCriterionContainer(input);
      
      if (criterionContainer) {
        // Para dispositivos móviles
        input.addEventListener("touchstart", () => {
          criterionContainer.classList.add("active-mobile");
        }, { passive: true });
        
        input.addEventListener("touchend", () => {
          setTimeout(() => {
            criterionContainer.classList.remove("active-mobile");
          }, 500);
        }, { passive: true });
        
        // También para mouse
        input.addEventListener("mousedown", () => {
          criterionContainer.classList.add("active-mobile");
        });
        
        input.addEventListener("mouseup", () => {
          criterionContainer.classList.remove("active-mobile");
        });
      }
    }
    
    // Función auxiliar para encontrar el contenedor de criterio
    function findCriterionContainer(element) {
      // Buscar el elemento más cercano con la clase criterion-container
      return element.closest('.criterion-container');
    }
  }
};

// Agregar este hook al archivo hooks.js existente

// Hook para manejar el modo oscuro
Hooks.DarkMode = {
  mounted() {
  }
};

Hooks.SaveFieldValue = {
  mounted() {
    // Guardar el valor inicial
    this.storeValue();
    
    // Configurar listener para cambios
    this.el.addEventListener("input", () => {
      this.storeValue();
    });
    
    // Configurar listener para el evento de restauración
    this.handleEvent("restore-field-values", () => {
      // No hacemos nada aquí, los valores ya están en el DOM
    });
  },
  
  storeValue() {
    // Almacenar el valor actual en el elemento
    this.el.dataset.storedValue = this.el.value;
    
    // También enviamos el valor al servidor para que sea consciente del cambio
    this.pushEvent("save-field-value", {
      id: this.el.id,
      value: this.el.value
    });
  }
}

Hooks.NetworkFormFields = {
  mounted() {
    // Seleccionar todos los campos de redes sociales en este componente
    const inputs = this.el.querySelectorAll('input, select');
    
    // Configurar listeners para cada campo
    inputs.forEach(input => {
      input.addEventListener('change', () => {
        // Obtener todos los valores actuales
        this.saveNetworkValues();
      });
      
      // Para inputs de texto, también capturar mientras se escribe
      if (input.type === 'text') {
        input.addEventListener('input', () => {
          this.saveNetworkValues();
        });
      }
    });
  },
  
  // Método para enviar los valores de la red actual al servidor
  saveNetworkValues() {
    const index = this.el.dataset.index;
    const networkId = this.el.querySelector('[name$="[network_id]"]').value;
    const username = this.el.querySelector('[name$="[username]"]').value;
    const url = this.el.querySelector('[name$="[url]"]').value;
    
    // Aquí está el cambio clave: dirigir el evento al componente correcto
    this.pushEventTo(this.el.closest('[phx-target]'), 'update-network', {
      index: index,
      data: {
        network_id: networkId,
        username: username,
        url: url
      }
    });
  }
};

export default Hooks;