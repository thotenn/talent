const CACHE_NAME = 'talent-cache-v1';
const urlsToCache = [
  '/',
  '/assets/app.css',
  '/assets/app.js',
  '/images/logo.svg',
  '/favicon.ico',
  '/offline.html',
  '/manifest.json'
];

// Instalación del Service Worker
self.addEventListener('install', event => {
  console.log('Service Worker instalándose');
  self.skipWaiting(); // Forzar activación inmediata
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('Cache abierto');
        return cache.addAll(urlsToCache);
      })
      .catch(error => {
        console.error('Error en la instalación del SW:', error);
      })
  );
});

// Activación del Service Worker
self.addEventListener('activate', event => {
  console.log('Service Worker activándose');
  // Tomar control de inmediato
  self.clients.claim();
  
  const cacheWhitelist = [CACHE_NAME];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames.map(cacheName => {
          if (cacheWhitelist.indexOf(cacheName) === -1) {
            console.log('Eliminando caché obsoleta:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Interceptar solicitudes y servir desde caché si está disponible
self.addEventListener('fetch', event => {
  // Para las solicitudes POST o solicitudes de API, pasar directamente a la red
  if (event.request.method !== 'GET' || 
      event.request.url.includes('/live') || 
      event.request.url.includes('/api/')) {
    return;
  }
  
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Si la respuesta está en caché, devuélvala
        if (response) {
          return response;
        }
        
        // Clonar la solicitud porque solo se puede usar una vez
        const fetchRequest = event.request.clone();
        
        // Si no está en caché, buscar en la red
        return fetch(fetchRequest)
          .then(response => {
            // Verificar si recibimos una respuesta válida
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Clonar la respuesta porque es un stream que solo se puede consumir una vez
            const responseToCache = response.clone();

            caches.open(CACHE_NAME)
              .then(cache => {
                // No cachear solicitudes websockets o API
                console.log('Añadiendo a caché:', event.request.url);
                cache.put(event.request, responseToCache);
              });

            return response;
          })
          .catch(error => {
            console.error('Error de fetch:', error);
            // Si estamos navegando a una página, mostrar la página offline
            if (event.request.mode === 'navigate') {
              return caches.match('/offline.html');
            }
            
            // Para recursos estáticos que no están en caché, simplemente fallar silenciosamente
            return new Response('', {
              status: 408,
              headers: new Headers({
                'Content-Type': 'text/plain'
              })
            });
          });
      })
  );
});