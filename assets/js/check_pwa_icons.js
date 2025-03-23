// Este script verifica si los iconos de la PWA existen y muestra advertencias si no

function checkPwaIcons() {
    if (window.location.hostname === 'localhost' || window.location.hostname.includes('127.0.0.1')) {
      console.log('🔍 Verificando iconos de PWA...');
      
      // Lista de iconos a verificar (desde manifest.json)
      const iconSizes = [72, 96, 128, 144, 152, 192, 384, 512];
      
      // Verificar cada tamaño de icono
      let missingIcons = [];
      
      Promise.all(
        iconSizes.map(size => {
          const iconUrl = `/images/icons/icon-${size}x${size}.png`;
          
          // Usar fetch para verificar si el icono existe
          return fetch(iconUrl, { method: 'HEAD' })
            .then(response => {
              if (!response.ok) {
                missingIcons.push(size);
                console.warn(`❌ Falta el icono ${iconUrl}. La PWA puede no ser instalable.`);
              } else {
                console.log(`✅ Icono ${iconUrl} encontrado.`);
              }
            })
            .catch(() => {
              missingIcons.push(size);
              console.warn(`❌ Error al verificar el icono ${iconUrl}`);
            });
        })
      ).then(() => {
        if (missingIcons.length > 0) {
          console.warn('⚠️ Faltan iconos requeridos para que la PWA sea instalable:', missingIcons.join(', '));
          
          // Sugerir solución
          console.log('💡 Sugerencia: Crea los iconos faltantes en priv/static/images/icons/ o actualiza el manifest.json');
        } else {
          console.log('✅ Todos los iconos están presentes. La PWA debería ser instalable.');
        }
        
        // Verificar también el manifest.json
        fetch('/manifest.json', { method: 'HEAD' })
          .then(response => {
            if (!response.ok) {
              console.warn('❌ Manifest.json no accesible. La PWA no será instalable.');
            } else {
              console.log('✅ Manifest.json accesible.');
            }
          })
          .catch(() => {
            console.warn('❌ Error al verificar manifest.json');
          });
      });
    }
  }
  
  // Ejecutar la verificación después de que la página se cargue
  window.addEventListener('load', checkPwaIcons);
  
  export default checkPwaIcons;