defmodule TalentWeb.Components.MobilePwaBanner do
  use Phoenix.Component

  def mobile_install_detector(assigns) do
    ~H"""
    <script>
      // Este script es independiente y se ejecuta directamente en el móvil
      document.addEventListener('DOMContentLoaded', function() {
        // Comprobar si es un dispositivo móvil
        const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

        // Comprobar si la app ya está instalada
        const isStandalone = window.matchMedia('(display-mode: standalone)').matches ||
                           navigator.standalone ||
                           window.navigator.standalone;

        // Comprobar si el usuario ha descartado el banner previamente
        const hasUserDismissed = localStorage.getItem('pwa-install-dismissed');

        // Solo procede si es móvil, no instalada y no descartada
        if (isMobile && !isStandalone && hasUserDismissed !== 'true') {
          setTimeout(function() {
            // Crear el banner manualmente para iOS
            const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

            let bannerHTML;

            if (isIOS) {
              bannerHTML = `
                <div id="mobile-pwa-banner" style="position: fixed; bottom: 0; left: 0; right: 0; background-color: #4f46e5; color: white; padding: 16px; z-index: 9999; box-shadow: 0 -4px 6px -1px rgba(0, 0, 0, 0.1);">
                  <div style="max-width: 600px; margin: 0 auto;">
                    <div style="margin-bottom: 12px;">
                      <p style="font-weight: 600; font-size: 16px; margin: 0 0 4px 0;">Instala Talent en tu iPhone/iPad</p>
                      <ol style="margin: 0; padding-left: 24px; font-size: 14px;">
                        <li>Toca el botón <strong>Compartir</strong> en Safari</li>
                        <li>Selecciona <strong>Añadir a pantalla de inicio</strong></li>
                        <li>Toca <strong>Añadir</strong></li>
                      </ol>
                    </div>
                    <div style="text-align: right;">
                      <button id="mobile-dismiss-banner" style="background-color: rgba(255,255,255,0.9); color: #4f46e5; border: none; padding: 8px 16px; border-radius: 4px; font-weight: 600; font-size: 14px;">
                        Entendido
                      </button>
                    </div>
                  </div>
                </div>
              `;
            } else {
              bannerHTML = `
                <div id="mobile-pwa-banner" style="position: fixed; bottom: 0; left: 0; right: 0; background-color: #4f46e5; color: white; padding: 16px; z-index: 9999; box-shadow: 0 -4px 6px -1px rgba(0, 0, 0, 0.1);">
                  <div style="display: flex; justify-content: space-between; align-items: center; max-width: 600px; margin: 0 auto;">
                    <div>
                      <p style="font-weight: 600; font-size: 16px; margin: 0 0 4px 0;">Instala Talent en tu dispositivo</p>
                      <p style="font-size: 14px; margin: 0;">Accede más rápido sin usar el navegador</p>
                    </div>
                    <div>
                      <button id="mobile-dismiss-banner" style="background-color: rgba(0,0,0,0.2); color: white; border: none; padding: 8px 12px; border-radius: 4px; margin-right: 8px; font-size: 14px;">
                        No, gracias
                      </button>
                      <button id="mobile-install-button" style="background-color: white; color: #4f46e5; border: none; padding: 8px 12px; border-radius: 4px; font-weight: 600; font-size: 14px;">
                        Instalar
                      </button>
                    </div>
                  </div>
                </div>
              `;
            }

            // Insertar el banner en el body
            document.body.insertAdjacentHTML('beforeend', bannerHTML);

            // Configurar los eventos para los botones
            document.getElementById('mobile-dismiss-banner').addEventListener('click', function() {
              document.getElementById('mobile-pwa-banner').style.display = 'none';
              localStorage.setItem('pwa-install-dismissed', 'true');
            });

            // Para el botón de instalar en Android
            if (!isIOS) {
              document.getElementById('mobile-install-button').addEventListener('click', function() {
                // Intentar disparar el evento A2HS si existe
                if (window.deferredPrompt) {
                  window.deferredPrompt.prompt();
                  window.deferredPrompt.userChoice.then(function(choiceResult) {
                    if (choiceResult.outcome === 'accepted') {
                      console.log('Usuario aceptó la instalación desde el banner móvil');
                    }
                    window.deferredPrompt = null;
                  });
                } else {
                  alert('Para instalar la app: Abre las opciones del navegador (tres puntos) y selecciona "Instalar app" o "Añadir a pantalla de inicio".');
                }
              });
            }
          }, 4000);
        }
      });
    </script>
    """
  end
end
