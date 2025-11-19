// Importar los scripts de Firebase (versión compat para service workers)
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

// Configuración de Firebase (debe coincidir con firebase_options.dart)
const firebaseConfig = {
  apiKey: 'AIzaSyDM9AnOHCBlyKJ98jNI_5r1y-xfAcJYLgI',
  appId: '1:360714035813:web:ba82060633b2f57b629c8c',
  messagingSenderId: '360714035813',
  projectId: 'playas-rd-2b475',
  authDomain: 'playas-rd-2b475.firebaseapp.com',
  storageBucket: 'playas-rd-2b475.firebasestorage.app',
  measurementId: 'G-451PZ22SF7',
};

// Inicializar Firebase
firebase.initializeApp(firebaseConfig);

// Obtener instancia de Firebase Messaging
const messaging = firebase.messaging();

// Manejar mensajes en segundo plano
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Mensaje recibido en segundo plano:', payload);
  
  // Extraer información de la notificación
  const notificationTitle = payload.notification?.title || payload.data?.title || 'Playas RD';
  const notificationBody = payload.notification?.body || payload.data?.body || '';
  
  const notificationOptions = {
    body: notificationBody,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.messageId || 'playas-rd-notification',
    requireInteraction: false,
    data: payload.data || {},
    // Agregar acciones si es necesario
    actions: [],
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Manejar clics en notificaciones
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notificación clickeada:', event);
  
  event.notification.close();
  
  // Abrir o enfocar la aplicación
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // Si hay una ventana abierta, enfocarla
      for (const client of clientList) {
        if (client.url === '/' && 'focus' in client) {
          return client.focus();
        }
      }
      // Si no hay ventana abierta, abrir una nueva
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});

