// Ryder CUP Service Worker
// Estrategia: network-first para navegación (HTML), offline fallback desde caché.
// 20261106: sin señal, ignora los "?_v=..." de la dirección y, si no encuentra
// esa página exacta, usa cualquier copia guardada de la app.

const CACHE = 'ryder-cache-v1';
const BASE = self.registration.scope;              // ej. https://.../Ryder/
const PAGES = ['', 'index.html', 'Ryder_SUASA.html'].map(p => BASE + p);

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c =>
    Promise.all(PAGES.map(u => c.add(u).catch(() => {})))
  ));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

function offlinePage(req) {
  return caches.open(CACHE).then(c =>
    c.match(req, { ignoreSearch: true })
      .then(r => r || c.match(BASE + 'Ryder_SUASA.html'))
      .then(r => r || c.match(BASE + 'index.html'))
      .then(r => r || c.match(BASE))
  );
}

self.addEventListener('fetch', e => {
  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request, { cache: 'no-cache' })
        .then(r => {
          if (r && r.ok) {
            const copy = r.clone();
            const url = new URL(e.request.url);
            caches.open(CACHE).then(c => c.put(url.origin + url.pathname, copy));
          }
          return r;
        })
        .catch(() => offlinePage(e.request))
    );
  }
  // Otros recursos: comportamiento normal del browser
});
