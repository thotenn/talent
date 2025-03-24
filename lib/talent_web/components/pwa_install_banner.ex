defmodule TalentWeb.Components.PwaInstallBanner do
  use Phoenix.Component

  def install_banner(assigns) do
    ~H"""
    <div id="pwa-install-banner" class="hidden fixed bottom-0 left-0 right-0 bg-indigo-600 text-white p-4 shadow-lg z-50">
      <div id="ios-install-instructions" class="hidden">
        <div class="container mx-auto">
          <div class="flex justify-between items-start">
            <div class="flex-1">
              <p class="font-semibold text-lg mb-2">Instala Talent en tu iPhone/iPad</p>
              <ol class="list-decimal pl-5 text-sm space-y-2 mb-3">
                <li>Toca el ícono <span class="inline-block px-2 py-1 bg-gray-200 text-gray-800 rounded">Compartir</span> en la parte inferior de Safari</li>
                <li>Desplázate hacia abajo y selecciona <span class="font-medium">Añadir a pantalla de inicio</span></li>
                <li>Toca <span class="font-medium">Añadir</span> en la esquina superior derecha</li>
              </ol>
            </div>
            <button id="dismiss-ios-install" class="bg-indigo-700 hover:bg-indigo-800 px-3 py-1 rounded text-sm ml-2">
              Cerrar
            </button>
          </div>
        </div>
      </div>

      <div id="standard-install-banner" class="container mx-auto flex justify-between items-center">
        <div>
          <p class="font-semibold">Instala Talent en tu dispositivo</p>
          <p class="text-sm">Accede más rápido sin usar el navegador</p>
        </div>
        <div class="flex space-x-2">
          <button id="dismiss-install" class="px-3 py-1 rounded bg-indigo-700 hover:bg-indigo-800">
            No, gracias
          </button>
          <button id="install-button" class="px-3 py-1 rounded bg-white text-indigo-600 hover:bg-gray-100 font-semibold">
            Instalar
          </button>
        </div>
      </div>
    </div>

    <script>
      // Variables a nivel de módulo para el evento beforeinstallprompt
      let deferredPrompt;

      // Función para mostrar el banner de instalación de manera forzada
      function forceShowInstallBanner() {
        const installBanner = document.getElementById('pwa-install-banner');
        const standardBanner = document.getElementById('standard-install-banner');
        const iosInstructions = document.getElementById('ios-install-instructions');

        if (!installBanner) return;

        // Quitar la clase hidden y el estilo display: none
        installBanner.classList.remove('hidden');
        installBanner.style.removeProperty('display');

        // Mostrar interfaz apropiada según el dispositivo
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
        if (isIOS) {
          if (standardBanner) standardBanner.classList.add('hidden');
          if (iosInstructions) iosInstructions.classList.remove('hidden');
        } else {
          if (standardBanner) standardBanner.classList.remove('hidden');
          if (iosInstructions) iosInstructions.classList.add('hidden');
        }

        console.log("Banner mostrado forzadamente para " + (isIOS ? "iOS" : "Android/otros"));
      }

      window.addEventListener('beforeinstallprompt', (e) => {
        // Prevenir que Chrome muestre automáticamente la solicitud
        e.preventDefault();

        // Guardar el evento para activarlo después
        deferredPrompt = e;

        // Mostrar el banner solo si no ha sido descartado previamente
        const hasUserDismissed = localStorage.getItem('pwa-install-dismissed');
        const installBanner = document.getElementById('pwa-install-banner');
        const standardBanner = document.getElementById('standard-install-banner');
        const iosInstructions = document.getElementById('ios-install-instructions');

        if (hasUserDismissed !== 'true' && installBanner) {
          installBanner.classList.remove('hidden');
          // Asegurar que mostramos el banner estándar (no iOS)
          if (standardBanner) standardBanner.classList.remove('hidden');
          if (iosInstructions) iosInstructions.classList.add('hidden');
        }
      });

      // Comprobar si debemos mostrar el banner de instalación
      function checkShowInstallBanner() {
        const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                           navigator.standalone ||
                           window.navigator.standalone;
        const hasUserDismissed = localStorage.getItem('pwa-install-dismissed');

        // Si estamos en móvil, no estamos en modo standalone y el usuario no ha descartado el banner
        if (isMobile && !isStandalone && hasUserDismissed !== 'true') {
          forceShowInstallBanner();
          return true;
        }
        return false;
      }

      // Intentar mostrar el banner después de 3 segundos
      setTimeout(() => {
        checkShowInstallBanner();
      }, 3000);

      // Intentar de nuevo después de 7 segundos (por si acaso)
      setTimeout(() => {
        checkShowInstallBanner();
      }, 7000);

      // Configurar listeners cuando se cargue la página
      window.addEventListener('load', () => {
        const installBanner = document.getElementById('pwa-install-banner');
        const standardBanner = document.getElementById('standard-install-banner');
        const iosInstructions = document.getElementById('ios-install-instructions');
        const dismissButton = document.getElementById('dismiss-install');
        const dismissiOSButton = document.getElementById('dismiss-ios-install');
        const installButton = document.getElementById('install-button');

        // Detectar si es iOS
        const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

        // Verificar si la aplicación ya está instalada
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                           navigator.standalone ||  // Para Safari en iOS
                           window.navigator.standalone;

        if (isStandalone && installBanner) {
          installBanner.classList.add('hidden');
          return; // No necesitamos mostrar ningún banner si ya está instalada
        }

        // Manejar la acción de descartar el banner estándar
        if (dismissButton) {
          dismissButton.addEventListener('click', () => {
            installBanner.classList.add('hidden');
            localStorage.setItem('pwa-install-dismissed', 'true');
          });
        }

        // Manejar la acción de descartar las instrucciones de iOS
        if (dismissiOSButton) {
          dismissiOSButton.addEventListener('click', () => {
            installBanner.classList.add('hidden');
            localStorage.setItem('pwa-install-dismissed', 'true');
          });
        }

        // Manejar el botón de instalar
        if (installButton) {
          installButton.addEventListener('click', async () => {
            if (isIOS) {
              // En iOS, mostrar instrucciones específicas
              if (standardBanner) standardBanner.classList.add('hidden');
              if (iosInstructions) iosInstructions.classList.remove('hidden');
              return;
            }

            if (!deferredPrompt) {
              // En algunos navegadores que soportan PWA pero no disparan beforeinstallprompt
              alert('Para instalar la app: Abre las opciones del navegador (tres puntos) y selecciona "Instalar app" o "Añadir a pantalla de inicio".');
              return;
            }

            // Mostrar el prompt de instalación nativo
            deferredPrompt.prompt();

            try {
              // Esperar por la decisión del usuario
              const { outcome } = await deferredPrompt.userChoice;
              console.log(`Usuario respondió: ${outcome}`);

              if (outcome === 'accepted') {
                // Usuario aceptó la instalación
                installBanner.classList.add('hidden');
              }
            } catch (error) {
              console.error('Error durante la instalación:', error);
            } finally {
              // Limpiar la variable ya que solo se puede usar una vez
              deferredPrompt = null;
            }
          });
        }

        // Para dispositivos móviles, mostrar el banner si no ha sido descartado
        const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        if (isMobile && !isStandalone) {
          const hasUserDismissed = localStorage.getItem('pwa-install-dismissed');
          if (hasUserDismissed !== 'true' && installBanner) {
            setTimeout(() => {
              installBanner.classList.remove('hidden');

              // Mostrar las instrucciones específicas para iOS o el banner estándar para otros
              if (isIOS) {
                if (standardBanner) standardBanner.classList.add('hidden');
                if (iosInstructions) iosInstructions.classList.remove('hidden');
              } else {
                if (standardBanner) standardBanner.classList.remove('hidden');
                if (iosInstructions) iosInstructions.classList.add('hidden');
              }
            }, 3000); // Mostrar después de 3 segundos
          }
        }
      });
    </script>
    """
  end
end
