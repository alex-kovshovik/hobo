// Service Worker for HOBO PWA
const CACHE_VERSION = 'v2';
const STATIC_CACHE = `hobo-static-${CACHE_VERSION}`;
const DYNAMIC_CACHE = `hobo-dynamic-${CACHE_VERSION}`;

// Assets to pre-cache on install
const PRECACHE_ASSETS = [
  '/offline.html',
  '/icon.png',
  '/icon-192.png',
  '/so-white.png',
  'https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/bulma.min.css'
];

// Patterns for cache-first strategy (static assets)
const CACHE_FIRST_PATTERNS = [
  /\.png$/,
  /\.jpg$/,
  /\.jpeg$/,
  /\.gif$/,
  /\.svg$/,
  /\.ico$/,
  /\.woff2?$/,
  /cdn\.jsdelivr\.net/,
  /kit\.fontawesome\.com/
];

// Patterns to always fetch from network (never cache)
const NETWORK_ONLY_PATTERNS = [
  /\/cable$/,           // Action Cable WebSocket
  /turbo-stream/,       // Turbo Stream responses
  /\.json$/,            // API responses
  /\/up$/               // Health check
];

// Install event - precache static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then(cache => cache.addAll(PRECACHE_ASSETS))
      .then(() => self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return Promise.all(
        cacheNames
          .filter(name => name.startsWith('hobo-') &&
                         name !== STATIC_CACHE &&
                         name !== DYNAMIC_CACHE)
          .map(name => caches.delete(name))
      );
    }).then(() => self.clients.claim())
  );
});

// Fetch event - implement caching strategies
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip non-GET requests (form submissions, etc.)
  if (request.method !== 'GET') {
    return;
  }

  // Skip cross-origin requests except for known CDNs
  if (url.origin !== self.location.origin &&
      !url.href.includes('cdn.jsdelivr.net') &&
      !url.href.includes('kit.fontawesome.com')) {
    return;
  }

  // Network-only for WebSocket, Turbo Streams, and API
  if (NETWORK_ONLY_PATTERNS.some(pattern => pattern.test(request.url))) {
    return;
  }

  // Cache-first for static assets
  if (CACHE_FIRST_PATTERNS.some(pattern => pattern.test(request.url))) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // Network-first for HTML pages (prioritize fresh data)
  if (request.headers.get('Accept')?.includes('text/html')) {
    event.respondWith(networkFirst(request));
    return;
  }

  // Stale-while-revalidate for JS/CSS
  if (request.url.includes('/assets/') ||
      request.url.endsWith('.js') ||
      request.url.endsWith('.css')) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }

  // Default: network first with cache fallback
  event.respondWith(networkFirst(request));
});

// Cache-first strategy: Try cache, fallback to network
async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) {
    return cached;
  }

  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(STATIC_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    if (request.headers.get('Accept')?.includes('text/html')) {
      return caches.match('/offline.html');
    }
    throw error;
  }
}

// Stale-while-revalidate: Return cache immediately, update in background
async function staleWhileRevalidate(request) {
  const cache = await caches.open(DYNAMIC_CACHE);
  const cached = await cache.match(request);

  const fetchPromise = fetch(request)
    .then(response => {
      if (response.ok) {
        cache.put(request, response.clone());
      }
      return response;
    })
    .catch(() => null);

  // Return cached version immediately if available
  if (cached) {
    fetchPromise; // Trigger background update
    return cached;
  }

  // No cache, wait for network
  const response = await fetchPromise;
  if (response) {
    return response;
  }

  // Network failed, return offline page
  return caches.match('/offline.html');
}

// Network-first: Try network, fallback to cache
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(DYNAMIC_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }

    if (request.headers.get('Accept')?.includes('text/html')) {
      return caches.match('/offline.html');
    }
    throw error;
  }
}

// Push notification handlers
self.addEventListener("push", async (event) => {
  const { title, options } = await event.data.json();
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener("notificationclick", function(event) {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: "window" }).then((clientList) => {
      for (let i = 0; i < clientList.length; i++) {
        let client = clientList[i];
        let clientPath = (new URL(client.url)).pathname;

        if (clientPath == event.notification.data.path && "focus" in client) {
          return client.focus();
        }
      }

      if (clients.openWindow) {
        return clients.openWindow(event.notification.data.path);
      }
    })
  );
});
