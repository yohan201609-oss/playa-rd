# 🚀 Configuración de Firebase Functions - Playas RD

## ✅ Funciones Implementadas

Has implementado exitosamente 5 Cloud Functions:

1. **🔔 Notificaciones Push** - Cuando cambie condición de playa
2. **🖼️ Procesamiento de Imágenes** - Redimensionar y comprimir automáticamente
3. **🧹 Limpieza Automática** - Eliminar reportes antiguos (diario a las 2 AM)
4. **🌤️ Sincronización de Clima** - Actualizar cada 6 horas
5. **📢 Notificar Nuevos Reportes** - Alertar a usuarios interesados

## 📦 Próximos Pasos

### 1. Instalar dependencias de Node.js
```powershell
cd functions
npm install
```

Esto instalará:
- `sharp` - Para procesamiento de imágenes
- `axios` - Para llamadas HTTP a la API de clima

### 2. Configurar API Key de OpenWeatherMap

#### Opción A: Para Producción (Recomendado)
```powershell
# Desde la raíz del proyecto (no desde /functions)
cd ..
firebase functions:config:set weather.api_key="TU_API_KEY_AQUI"
```

#### Opción B: Para Desarrollo Local
Crea un archivo `functions/.env`:
```env
WEATHER_API_KEY=tu_api_key_aqui
```

**Obtén tu API key gratis aquí:** https://openweathermap.org/api

### 3. Probar localmente (Opcional pero recomendado)
```powershell
# Iniciar emuladores
firebase emulators:start --only functions,firestore,storage
```

### 4. Desplegar a Firebase
```powershell
# Desplegar todas las funciones
firebase deploy --only functions

# O desplegar una por una
firebase deploy --only functions:notifyBeachConditionChange
firebase deploy --only functions:processUploadedImage
firebase deploy --only functions:cleanupOldReports
firebase deploy --only functions:updateBeachWeather
firebase deploy --only functions:notifyNewReport
```

## 🔧 Configuración en la App Flutter

### 1. Guardar FCM Token del usuario

Necesitas modificar tu `AuthProvider` para guardar el token FCM cuando el usuario inicie sesión:

```dart
// lib/providers/auth_provider.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class AuthProvider extends ChangeNotifier {
  // ... tu código existente ...

  Future<void> _saveFcmToken(String userId) async {
    try {
      // Obtener token FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken != null) {
        // Guardar en Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': fcmToken});
        
        print('✅ FCM Token guardado: ${fcmToken.substring(0, 20)}...');
      }
    } catch (e) {
      print('⚠️ Error guardando FCM token: $e');
    }
  }

  // Llama esta función después de login exitoso
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await loadUserData();
        await _saveFcmToken(credential.user!.uid); // 👈 Agregar esto
      }
    } catch (e) {
      // ... manejo de errores
    }
  }
}
```

### 2. Configurar permisos de notificaciones

En tu `main.dart` o donde inicialices Firebase:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Solicitar permisos de notificaciones
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  runApp(const PlayasRDApp());
}
```

### 3. Actualizar estructura de datos

Asegúrate de que tus playas tengan coordenadas:

```dart
// Cuando crees o actualices una playa
{
  'name': 'Playa Rincón',
  'condition': 'Excelente',
  'coordinates': {
    'latitude': 18.4667,
    'longitude': -69.9500,
  },
  // ... otros campos
}
```

## 📊 Monitoreo

### Ver logs en tiempo real
```powershell
firebase functions:log
```

### Ver logs de una función específica
```powershell
firebase functions:log --only notifyBeachConditionChange
```

### Firebase Console
Monitorea métricas, errores y ejecuciones:
https://console.firebase.google.com/project/playas-rd-2b475/functions

## 💡 Cómo Funcionan las Funciones

### 🔔 Notificaciones de Cambio de Condición
**Trigger:** Automático cuando actualizas `condition` de una playa en Firestore
```dart
// En tu app Flutter
await FirebaseFirestore.instance
    .collection('beaches')
    .doc(beachId)
    .update({'condition': 'Excelente'});
// 👆 Esto activará la función automáticamente
```

### 🖼️ Procesamiento de Imágenes
**Trigger:** Automático cuando subes una imagen a Storage en `reports/`
```dart
// En tu ReportScreen al subir foto
final ref = FirebaseStorage.instance
    .ref()
    .child('reports/${DateTime.now().millisecondsSinceEpoch}.jpg');
await ref.putFile(imageFile);
// 👆 Creará automáticamente versión optimizada y thumbnail
```

### 🧹 Limpieza de Reportes
**Trigger:** Automático, se ejecuta todos los días a las 2:00 AM
- No requiere intervención manual
- Elimina reportes con más de 30 días
- Guarda estadísticas en `maintenance_logs`

### 🌤️ Sincronización de Clima
**Trigger:** Automático, se ejecuta cada 6 horas
- No requiere intervención manual
- Actualiza el campo `weather` en cada playa
- Usa la API de OpenWeatherMap

## 🧪 Probar las Funciones

### Probar Notificaciones
1. Agrega una playa a favoritos en la app
2. Cambia la condición de esa playa en Firebase Console
3. Deberías recibir una notificación push

### Probar Procesamiento de Imágenes
1. Sube un reporte con foto desde la app
2. Ve a Firebase Storage
3. Verás 3 versiones: original, _optimized, _thumb

### Probar Limpieza (Manual)
```powershell
# Desde Firebase Console > Functions > cleanupOldReports > "Ejecutar ahora"
```

### Probar Clima (Manual)
```powershell
# Desde Firebase Console > Functions > updateBeachWeather > "Ejecutar ahora"
```

## 💰 Costos Estimados

Con ~100 playas y ~1000 usuarios activos:

| Función | Invocaciones/mes | Costo estimado |
|---------|-----------------|----------------|
| Notificaciones condición | ~500 | $0 |
| Procesamiento imágenes | ~2000 | ~$2 |
| Limpieza reportes | 30 | $0 |
| Sincronización clima | 120 | $0 |
| Notificar reportes | ~500 | $0 |
| **TOTAL** | | **~$2-5 USD/mes** |

**Nota:** Firebase ofrece 2M de invocaciones gratis mensualmente.

## ⚠️ Troubleshooting

### Error: "sharp installation failed"
```powershell
cd functions
rm -rf node_modules
npm install --platform=linux --arch=x64 sharp
npm install
```

### Error: "WEATHER_API_KEY no configurada"
```powershell
firebase functions:config:set weather.api_key="TU_API_KEY"
firebase deploy --only functions
```

### Error: "Permission denied"
Verifica que tu cuenta de Firebase tenga permisos de Admin en la consola.

### Las notificaciones no llegan
1. Verifica que el FCM token esté guardado en Firestore
2. Revisa los logs: `firebase functions:log --only notifyBeachConditionChange`
3. Verifica que el usuario tenga la playa en favoritos
4. Comprueba los permisos de notificaciones en el dispositivo

## 📚 Documentación Adicional

- **Guía completa:** Ver `functions/README.md`
- **Código fuente:** Ver `functions/index.js` (con comentarios en español)
- **Firebase Docs:** https://firebase.google.com/docs/functions

## ✨ ¡Listo!

Tus Cloud Functions están implementadas y listas para usar. Solo necesitas:

1. ✅ Instalar dependencias: `cd functions && npm install`
2. ✅ Configurar API key de clima
3. ✅ Desplegar: `firebase deploy --only functions`
4. ✅ Actualizar tu app para guardar FCM tokens

---

**¿Necesitas ayuda?** Revisa los logs con `firebase functions:log`

Desarrollado con ❤️ para Playas RD 🇩🇴

