defmodule TalentWeb.Components.InstallButton do
  use Phoenix.Component

  def install_button(assigns) do
    ~H"""
    <div class="mt-4 mb-4">
      <button
        id="direct-install-button"
        class="inline-flex items-center rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        style="display: none;"
      >
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 mr-2">
          <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5M16.5 12L12 16.5m0 0L7.5 12m4.5 4.5V3" />
        </svg>
        Instalar aplicación
      </button>
    </div>

    <script>
      (function() {
        // Obtener el botón en esta instancia
        const installButton = document.getElementById('direct-install-button');
        if (!installButton) return;

        // Verificar si la app ya está instalada
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                          navigator.standalone ||
                          window.navigator.standalone;

        // Si ya está instalada, no mostrar el botón
        if (isStandalone) return;

        // Variable local para el evento (no bloqueará otros listeners)
        let deferredPrompt = null;

        // Solo mostrar el botón en dispositivos móviles
        const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

        if (isMobile) {
          // En dispositivos móviles, mostrar el botón siempre
          setTimeout(() => {
            installButton.style.display = 'inline-flex';
          }, 2000);
        } else {
          // En desktop, solo mostrar el botón si tenemos el evento
          window.addEventListener('beforeinstallprompt', (e) => {
            // NO llamamos a preventDefault() para evitar el error
            deferredPrompt = e;
            installButton.style.display = 'inline-flex';
          });
        }

        // Configurar el botón de instalación
        installButton.addEventListener('click', async () => {
          // Detectar si es iOS
          const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

          if (isIOS) {
            // Instrucciones para iOS
            alert('Para instalar esta app en iOS:\n\n1. Toca el botón "Compartir" en la parte inferior del navegador\n2. Selecciona "Añadir a pantalla de inicio"\n3. Toca "Añadir" en la esquina superior derecha');
            return;
          }

          // Para Android y otros navegadores
          if (!deferredPrompt) {
            // Si no tenemos el evento, dar instrucciones manuales
            alert('Para instalar esta app:\n\n• En Chrome/Edge: Toca el menú (tres puntos) y selecciona "Instalar app"\n• En Samsung Internet: Toca el menú y "Añadir a pantalla de inicio"');
            return;
          }

          // Mostrar el prompt de instalación
          deferredPrompt.prompt();

          try {
            // Esperar la respuesta del usuario
            const { outcome } = await deferredPrompt.userChoice;
            console.log(`Resultado de instalación: ${outcome}`);

            // Limpiar la referencia
            deferredPrompt = null;

            // Ocultar el botón después del intento
            installButton.style.display = 'none';
          } catch (error) {
            console.error('Error durante la instalación:', error);
          }
        });
      })();
    </script>
    """
  end
end
