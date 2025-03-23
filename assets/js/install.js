// Eventos y lógica para la instalación de la PWA
let deferredPrompt;

// Detectar si la app está siendo ejecutada como una PWA instalada
const isRunningAsInstalled = () => {
  return window.matchMedia('(display-mode: standalone)').matches || 
         navigator.standalone || // Para Safari en iOS
         window.navigator.standalone;
};

// Detectar si es un dispositivo iOS
const isIOS = () => {
  return /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
};

// Detectar si es un dispositivo Android
const isAndroid = () => {
  return /Android/.test(navigator.userAgent);
};

// Capturar el evento beforeinstallprompt que se dispara cuando la PWA es instalable (principalmente en Chrome/Android)
window.addEventListener('beforeinstallprompt', (e) => {
  // Prevenir que Chrome muestre automáticamente la solicitud de instalación
  e.preventDefault();
  // Guardar el evento para poder activarlo más tarde
  deferredPrompt = e;
  console.log('PWA es instalable: evento beforeinstallprompt capturado');
});

// Detectar cuando la PWA ha sido instalada
window.addEventListener('appinstalled', (e) => {
  console.log('La aplicación ha sido instalada.');
  // Limpiar el evento ya que no lo necesitamos más
  deferredPrompt = null;
});

// Exportar funciones y variables para uso en otros scripts
export { deferredPrompt, isRunningAsInstalled, isIOS, isAndroid };