# 🔥 Firebase Cloud Functions - Playas RD

Este proyecto contiene todas las Cloud Functions para la aplicación Playas RD.

## 📋 Funciones Implementadas

### 1. 🔔 Notificaciones Push - Cambio de Condición
**Función:** `notifyBeachConditionChange`
- **Trigger:** Cuando se actualiza un documento en `beaches/{beachId}`
- **Descripción:** Envía notificaciones push a todos los usuarios que tienen la playa en favoritos cuando cambia su condición.
- **Ejemplo:** "🏖️ Actualización de Playa Rincón: La condición cambió de Moderado a Excelente"

### 2. 🖼️ Procesamiento de Imágenes
**Función:** `processUploadedImage`
- **Trigger:** Cuando se sube una imagen al Storage
- **Descripción:** Procesa automáticamente las imágenes de reportes:
  - Crea versión optimizada (1200px, 85% calidad)
  - Crea thumbnail (400x400px, 80% calidad)
  - Comprime automáticamente para ahorrar espacio
- **Ubicación:** Solo procesa imágenes en `reports/`

### 3. 🧹 Limpieza Automática
**Función:** `cleanupOldReports`
- **Trigger:** Programado (Cron: `0 2 * * *`)
- **Horario:** Todos los días a las 2:00 AM (zona horaria de Santo Domingo)
- **Descripción:** Elimina reportes con más de 30 días de antigüedad
- **Logs:** Guarda estadísticas en `maintenance_logs`

### 4. 🌤️ Sincronización de Clima
**Función:** `updateBeachWeather`
- **Trigger:** Programado (Cron: `0 */6 * * *`)
- **Horario:** Cada 6 horas
- **Descripción:** Actualiza automáticamente los datos del clima de todas las playas usando OpenWeatherMap API
- **Datos:** Temperatura, humedad, viento, nubosidad, descripción
- **Requisito:** Necesita API key configurada (ver abajo)

### 5. 📢 Bonus: Notificar Nuevos Reportes
**Función:** `notifyNewReport`
- **Trigger:** Cuando se crea un documento en `reports/{reportId}`
- **Descripción:** Notifica a usuarios con la playa en favoritos cuando alguien hace un nuevo reporte

## 🚀 Instalación

### 1. Instalar dependencias
```bash
cd functions
npm install
```

### 2. Configurar API Key de OpenWeatherMap
Para que funcione la sincronización del clima, necesitas configurar tu API key:

```bash
# Desde la raíz del proyecto
firebase functions:config:set weather.api_key="TU_API_KEY_AQUI"
```

Obtén tu API key gratis en: https://openweathermap.org/api

También puedes usar el archivo `.env` para desarrollo local:
```bash
# functions/.env
WEATHER_API_KEY=tu_api_key_aqui
```

### 3. Desplegar todas las funciones
```bash
# Desde la raíz del proyecto
firebase deploy --only functions
```

### 4. Desplegar una función específica
```bash
firebase deploy --only functions:notifyBeachConditionChange
firebase deploy --only functions:processUploadedImage
firebase deploy --only functions:cleanupOldReports
firebase deploy --only functions:updateBeachWeather
firebase deploy --only functions:notifyNewReport
```

## 🧪 Probar Localmente

### Iniciar emuladores
```bash
cd functions
npm run serve
```

Esto iniciará los emuladores de:
- Functions
- Firestore
- Storage

## 📊 Monitoreo

### Ver logs en tiempo real
```bash
firebase functions:log
```

### Ver logs de una función específica
```bash
firebase functions:log --only notifyBeachConditionChange
```

### Ver logs en Firebase Console
https://console.firebase.google.com/project/playas-rd-2b475/functions

## 💰 Estimación de Costos

Con el plan **Blaze** (pago por uso):

- **Notificaciones:** ~$0 (incluidas en Firebase)
- **Procesamiento de imágenes:** ~$0.40 por GB procesado
- **Funciones programadas:** ~$0 (2 funciones cada 6 horas)
- **Invocaciones:** Primeras 2M gratis/mes

**Estimado mensual para ~100 playas y 1000 usuarios:** < $5 USD

## 🔧 Configuración Adicional Necesaria

### 1. Configurar FCM Tokens
En tu app Flutter, necesitas guardar el FCM token de cada usuario:

```dart
// En tu AuthProvider o similar
final fcmToken = await FirebaseMessaging.instance.getToken();
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'fcmToken': fcmToken});
```

### 2. Estructura de Datos

#### Collection: `beaches`
```javascript
{
  name: "Playa Rincón",
  condition: "Excelente", // Excelente, Bueno, Moderado, Peligroso
  coordinates: {
    latitude: 18.4667,
    longitude: -69.9500
  },
  weather: {
    temperature: 28,
    humidity: 75,
    description: "parcialmente nublado",
    // ...
  }
}
```

#### Collection: `users`
```javascript
{
  email: "usuario@example.com",
  favoriteBeaches: ["beach_id_1", "beach_id_2"],
  fcmToken: "fcm_token_here"
}
```

#### Collection: `reports`
```javascript
{
  beachId: "beach_id",
  userId: "user_id",
  condition: "Excelente",
  comment: "Playa hermosa hoy",
  createdAt: Timestamp,
  photos: ["storage_path_1"]
}
```

## 📝 Notas Importantes

1. **Costos:** Monitorea el uso en Firebase Console
2. **Límites:** Configurado con `maxInstances: 10` para control de costos
3. **Región:** Todas las funciones en `us-central1` (optimiza eligiendo la más cercana)
4. **Logs:** Se guardan por 30 días en Firebase
5. **Errores:** Las funciones tienen manejo de errores y logs detallados

## 🐛 Troubleshooting

### Error: "API key no configurada"
```bash
firebase functions:config:set weather.api_key="TU_API_KEY"
firebase deploy --only functions
```

### Error: "sharp installation failed"
```bash
cd functions
npm install --platform=linux --arch=x64 sharp
```

### Función no se ejecuta
1. Verifica logs: `firebase functions:log`
2. Revisa permisos en Firebase Console
3. Verifica que el trigger sea correcto

## 📚 Recursos

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [OpenWeatherMap API](https://openweathermap.org/api)
- [Sharp (Image Processing)](https://sharp.pixelplumbing.com/)
- [Cron Schedule Format](https://crontab.guru/)

## 🎯 Próximas Mejoras

- [ ] Backup automático de Firestore
- [ ] Análisis de tendencias de playas
- [ ] Sistema de recomendaciones personalizadas
- [ ] Detección de spam en reportes
- [ ] Integración con servicios de mareas

---

Desarrollado con ❤️ para Playas RD 🇩🇴

