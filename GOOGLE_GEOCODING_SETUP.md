# Configuración de Google Geocoding API

Este documento explica cómo configurar la API de Google para obtener coordenadas más precisas de las playas.

## Requisitos

1. Una cuenta de Google Cloud Platform
2. Un proyecto con las APIs habilitadas
3. Una API Key de Google Maps

## Pasos para Configurar

### 1. Habilitar las APIs necesarias

En Google Cloud Console, habilita las siguientes APIs:
- **Geocoding API** - Para convertir direcciones en coordenadas
- **Places API** - Para buscar lugares específicos (opcional pero recomendado)

### 2. Crear una API Key

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Selecciona tu proyecto
3. Ve a "APIs & Services" > "Credentials"
4. Haz clic en "Create Credentials" > "API Key"
5. Copia la API Key generada

### 2.1. Configurar Restricciones de Aplicación (IMPORTANTE)

**Para que la API Key funcione en tu app móvil, necesitas configurar las restricciones de aplicación:**

1. En Google Cloud Console, ve a "APIs & Services" > "Credentials"
2. Haz clic en tu API Key para editarla
3. En la sección "Application restrictions" (Restricciones de aplicación):
   
   **Opción A: Para Android (Recomendado para desarrollo)**
   - Selecciona "Android apps"
   - Haz clic en "Add an item"
   - Agrega:
     - **Package name**: `com.playasrd.playasrd` (verifica en `android/app/build.gradle`)
     - **SHA-1 certificate fingerprint**: Obténlo ejecutando:
       ```bash
       # Para debug
       keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
       
       # O para release (si tienes un keystore)
       keytool -list -v -keystore ruta/a/tu/keystore.jks -alias tu_alias
       ```
   - Copia el SHA-1 (formato: `AA:BB:CC:DD:EE:FF:...`)
   - Pega el SHA-1 en el campo correspondiente
   - Haz clic en "Save"

   **Opción B: Sin restricciones (Solo para desarrollo/pruebas)**
   - ⚠️ **NO recomendado para producción**
   - Selecciona "None" en "Application restrictions"
   - Esto permitirá que la API Key funcione desde cualquier aplicación
   - Haz clic en "Save"

4. **Verifica las restricciones de API:**
   - En "API restrictions", asegúrate de que estén seleccionadas:
     - ✅ **Geocoding API** (requerida)
     - ✅ **Places API** (recomendada)
     - ✅ **Maps SDK for Android** (si usas mapas)
   - O selecciona "Don't restrict key" temporalmente para pruebas

**Nota importante:** Después de cambiar las restricciones, puede tomar unos minutos para que los cambios se apliquen.

### 3. Configurar la API Key en la aplicación

#### Opción A: Usar archivo .env (Recomendado)

1. Crea un archivo `.env` en la raíz del proyecto (si no existe)
2. Agrega la siguiente línea:

```
GOOGLE_MAPS_API_KEY=tu_api_key_aqui
```

3. Asegúrate de que el archivo `.env` esté en `.gitignore` para no subirlo al repositorio

#### Opción B: Usar la API Key del AndroidManifest.xml

La aplicación ya tiene una API Key configurada en `android/app/src/main/AndroidManifest.xml`. 
Esta se usará como fallback si no hay una key en `.env`.

**Nota:** Para producción, siempre usa la opción A (archivo .env) para mayor seguridad.

## Uso de la Funcionalidad

### Actualizar coordenadas de una playa individual

```dart
import 'package:provider/provider.dart';
import 'providers/beach_provider.dart';

// En tu widget
final beachProvider = Provider.of<BeachProvider>(context);
final beach = beachProvider.selectedBeach;

if (beach != null) {
  final success = await beachProvider.updateBeachCoordinates(beach);
  if (success) {
    print('✅ Coordenadas actualizadas');
  } else {
    print('❌ Error actualizando coordenadas');
  }
}
```

### Actualizar coordenadas de todas las playas

```dart
final result = await beachProvider.updateAllBeachesCoordinates(
  onProgress: (current, total, beach) {
    print('Procesando ${beach.name} ($current/$total)');
  },
);

if (result['success']) {
  print('✅ ${result['updated']} playas actualizadas');
  print('⚠️ ${result['failed']} playas sin cambios');
} else {
  print('❌ Error: ${result['error']}');
}
```

### Usar el servicio directamente

```dart
import 'services/google_geocoding_service.dart';

// Obtener coordenadas desde una dirección
final coordinates = await GoogleGeocodingService.getCoordinatesFromQuery(
  'Playa Bávaro, Punta Cana, La Altagracia, República Dominicana',
);

if (coordinates != null) {
  final lat = coordinates['latitude'];
  final lng = coordinates['longitude'];
  print('Coordenadas: $lat, $lng');
}

// Obtener coordenadas usando Places API (más preciso)
final placeCoordinates = await GoogleGeocodingService.getCoordinatesFromPlace(
  'Playa Bávaro',
  province: 'La Altagracia',
  municipality: 'Punta Cana',
  approximateLatitude: 18.6825,
  approximateLongitude: -68.4276,
);
```

## Límites de la API

- **Geocoding API**: 40,000 solicitudes por mes (gratis)
- **Places API**: Varía según el plan

La aplicación incluye pausas entre solicitudes (200ms) para evitar exceder los límites.

## Solución de Problemas

### Error: "API key not valid"
- Verifica que la API key esté correctamente configurada
- Asegúrate de que las APIs estén habilitadas en Google Cloud Console
- Verifica que la API key tenga los permisos necesarios

### Error: "REQUEST_DENIED"
- Verifica las restricciones de la API key en Google Cloud Console
- Asegúrate de que la API key permita solicitudes desde tu aplicación

### No se encuentran coordenadas
- Verifica que el nombre de la playa sea correcto
- Intenta agregar más contexto (provincia, municipio)
- Algunas playas remotas pueden no estar en la base de datos de Google

## Verificar la API Key

```dart
import 'services/google_geocoding_service.dart';

final isValid = await GoogleGeocodingService.verifyApiKey();
if (isValid) {
  print('✅ API Key válida');
} else {
  print('❌ API Key inválida o no configurada');
}
```

