const CACHE_NAME = 'talent-cache-v1';
const urlsToCache = [
  '/',
  '/assets/app.css',
  '/assets/app.js',
  '/images/logo.svg',
  '/favicon.ico',
  '/offline.html'
];

// Instalación del Service Worker
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Cache abierto');
        return cache.addAll(urlsToCache);
      })
  );
});

// Interceptar solicitudes y servir desde caché si está disponible
self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Si la respuesta está en caché, devuélvala
        if (response) {
          return response;
        }
        
        // Si no está en caché, buscar en la red
        return fetch(event.request)
          .then(response => {
            // Verificar si recibimos una respuesta válida
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clonar la respuesta porque es un stream que solo se puede consumir una vez
            const responseToCache = response.clone();

            caches.open(CACHE_NAME)
              .then(cache => {
                // No cachear solicitudes de API o websockets
                if (!event.request.url.includes('/live') && 
                    !event.request.url.includes('/api/') && 
                    event.request.method === 'GET') {
                  cache.put(event.request, responseToCache);
                }
              });

            return response;
          });
      })
      .catch(() => {
        // Si hay un error (por ejemplo, sin conexión), servir la página offline
        if (event.request.mode === 'navigate') {
          return caches.match('/offline.html');
        }
      })
  );
});

// Limpiar cachés antiguos cuando se active una nueva versión
self.addEventListener('activate', event => {
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});