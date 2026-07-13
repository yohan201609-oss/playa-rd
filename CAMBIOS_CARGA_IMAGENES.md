# Cambios: carga de imágenes y Firebase Storage

Documento de referencia con todo lo implementado en la app para usar fotos desde **Firebase Storage** (en lugar de Google Places), evitar cobros por visualización y reducir imágenes rotas.

**Fecha de referencia:** junio 2026  
**Proyecto:** Playas RD (`playas-rd-2b475`)

---

## Contexto del problema

| Antes (Google Places) | Después (Firebase Storage) |
|----------------------|----------------------------|
| URLs temporales que expiran | URLs estables ligadas al archivo en Storage |
| Cobro por cada visualización (~USD 0.007/foto) | Sin coste de Places Photo API al mostrar |
| Header `X-Ios-Bundle-Identifier` obligatorio en iOS | Solo necesario si queda alguna URL de Google |
| Regeneración automática vía Places API | Fotos oficiales desde Firestore + Storage |

**Importante:** Tener archivos en Storage y URLs en Firestore no basta por sí solo; la app debe **no volver a llamar** a Google Places y debe **resolver** las URLs de forma estable. Eso es lo que cubren estos cambios.

---

## Archivos modificados o creados

| Archivo | Tipo | Resumen |
|---------|------|---------|
| `lib/utils/beach_image_utils.dart` | **Nuevo** | Utilidades centralizadas: detectar Firebase/Google, URLs públicas sin token, headers condicionales |
| `lib/screens/beach_detail_screen.dart` | Modificado | No llama a Places si hay Firebase; `resolveImageUrl` en carrusel/visor; subida de fotos de usuario con URL estable |
| `lib/widgets/beach_card.dart` | Modificado | Lista: URL resuelta + headers solo para Google; error solo regenera Places |
| `lib/screens/map_screen.dart` | Modificado | Miniatura del mapa con URL resuelta y headers condicionales |
| `lib/providers/beach_provider.dart` | Modificado | No regenera ni actualiza fotos desde Google si la playa ya tiene Firebase |
| `lib/services/firebase_service.dart` | Modificado | Migración/subida guarda URL pública sin token (`publicStorageUrl`) |

### Archivos de documentación / migración (sin cambios de código en esta tarea)

| Archivo | Nota |
|---------|------|
| `GUIA_MIGRACION_IMAGENES.md` | Guía previa para migrar Google → Storage |
| `storage.rules` | Ya tenía `allow read: if true` en `beaches/` y `beach_photos/` (requisito para URLs sin token) |

---

## 1. `lib/utils/beach_image_utils.dart` (nuevo)

Utilidad compartida para toda la app.

### Funciones y constantes

- `storageBucket` — `playas-rd-2b475.firebasestorage.app`
- `isFirebaseStorageImageUrl(url)` — URL de Storage o ruta `beaches/...` / `beach_photos/...`
- `isGooglePlacesPhotoUrl(url)` — `maps.googleapis.com/.../place/photo`
- `beachHasFirebasePhotos(imageUrls)` — al menos una foto oficial en Firebase
- `storagePathFromStored(stored)` — extrae ruta desde URL con token o desde path guardado
- `publicStorageUrl(storagePath)` — URL pública **sin token**: `.../o/{path}?alt=media`
- `resolveImageUrl(stored)` — normaliza cualquier valor guardado a URL estable para mostrar
- `httpHeadersForUrl(url)` — header iOS solo para URLs de Google Places

### Por qué URLs sin token

Las URLs con `?token=...` de `getDownloadURL()` no caducan por tiempo, pero pueden invalidarse si se revoca el token o cambia el archivo. Con reglas de lectura pública, la URL `?alt=media` sin token depende solo de que exista el archivo en la ruta.

---

## 2. `lib/screens/beach_detail_screen.dart`

### `_loadAllPhotos`

- Antes: si había &lt; 3 fotos, llamaba a `GooglePlacesService.getBeachPhotos` y podía añadir mapa estático.
- Ahora: si `beach.imageUrls` tiene al menos una URL de Firebase Storage, **omite** Google Places y el mapa estático de relleno.
- Log: `Fotos oficiales en Firebase Storage; omitiendo Google Places`.

### Visualización

- Carrusel del `SliverAppBar` y visor a pantalla completa usan `BeachImageUtils.resolveImageUrl(...)`.
- `errorWidget`: solo llama a `regenerateExpiredImageUrls` si la URL fallida es de Google Places.

### Validación `_isValidImageUrl`

- Acepta rutas `beaches/` y `beach_photos/` vía `BeachImageUtils.isFirebaseStorageImageUrl`.

### Subida de foto por usuario

- Tras `putFile`, guarda en Firestore `BeachImageUtils.publicStorageUrl(storagePath)` en lugar de `getDownloadURL()` con token.

---

## 3. `lib/widgets/beach_card.dart`

- `CachedNetworkImage` usa `resolveImageUrl(beach.imageUrls.first)`.
- `httpHeaders` solo si la URL original es de Google Places.
- En error: `regenerateExpiredImageUrls` solo para URLs de Places; si es Firebase, muestra icono de playa sin llamar a Google.

---

## 4. `lib/screens/map_screen.dart`

- `NetworkImage` en la lista inferior del mapa usa `resolveImageUrl` y headers condicionales.

---

## 5. `lib/providers/beach_provider.dart`

### `regenerateExpiredImageUrls`

- Sale de inmediato si `beachHasFirebasePhotos(beach.imageUrls)`.
- Solo sigue si quedan URLs de `maps.googleapis.com/.../place/photo` (playas no migradas).

### `updateAllBeachesPhotos` / `updateBeachPhotos`

- Excluyen playas que ya tienen fotos en Firebase Storage.
- `updateBeachPhotos` retorna `true` sin llamar a Google si ya hay Firebase.

---

## 6. `lib/services/firebase_service.dart`

### `transferImageToFirebase`

- Sube a `beaches/{beachId}/photo_{index}.jpg`.
- Devuelve `BeachImageUtils.publicStorageUrl(storagePath)` en lugar de `getDownloadURL()`.
- Las migraciones futuras escriben URLs estables en Firestore.

---

## Flujo de carga actual (resumen)

```
Firestore beaches.imageUrls
        ↓
BeachProvider.loadBeaches()
        ↓
UI (BeachCard / Map / Detalle)
        ↓
BeachImageUtils.resolveImageUrl()  →  URL pública Storage (sin token)
        ↓
CachedNetworkImage / NetworkImage
```

### Detalle de playa (fotos combinadas)

1. `beach.imageUrls` (oficiales, Firebase).
2. Colección `beach_photos` (usuarios).
3. **Solo si no hay Firebase oficial** y faltan fotos: Google Places + mapa estático.

---

## Comportamiento cuando la imagen falla

| Tipo de URL | ¿Auto-reparación? | Qué ve el usuario |
|-------------|------------------|-------------------|
| Firebase Storage | No (no llama a Google) | Placeholder (icono playa / imagen rota) |
| Google Places (legacy) | Sí → `regenerateExpiredImageUrls` | Placeholder + intento de nuevas URLs |

### Cómo evitar roturas (operación)

- No borrar archivos en `beaches/{id}/` sin actualizar Firestore.
- Mantener `allow read: if true` en `storage.rules` para `beaches/**`.
- Al reemplazar una foto, usar la misma ruta (`photo_0.jpg`, etc.).
- No depender de regeneración desde Places en playas ya migradas.

---

## Costes (recordatorio)

| Servicio | Al mostrar fotos migradas |
|----------|---------------------------|
| Google Places Photo | No |
| Firebase Storage | Descarga (egress) + almacenamiento (tier gratuito generoso) |
| Firestore | Lectura del documento de la playa (no por cada imagen) |

---

## Cómo probar

1. Abrir detalle de una playa con `imageUrls` de `firebasestorage.googleapis.com` (ej. playa `1`).
2. En consola/debug: mensaje de omisión de Google Places.
3. Verificar en red que las peticiones de imagen van a `firebasestorage.googleapis.com/...?alt=media` **sin** depender de `token=` (la app puede seguir teniendo token en Firestore; se normaliza al mostrar).
4. Lista y mapa: mismas URLs resueltas.

---

## Opcional (no implementado)

- Script para reescribir todas las `imageUrls` en Firestore al formato sin token (la app ya funciona sin ello gracias a `resolveImageUrl`).
- Reintento automático o mensaje “Foto no disponible” solo para errores de Firebase.
- App Check en Storage (seguridad anti-abuso, no evita roturas por archivo borrado).

---

## Relación con la migración existente

La migración manual o vía `MigrationUtils` / `FirebaseService.migrateAllGoogleImagesToFirebase()` sigue siendo válida. Tras migrar:

1. Archivos en `gs://.../beaches/{id}/photo_*.jpg`
2. `imageUrls` en Firestore (con o sin token en datos viejos)
3. Esta capa de código evita nuevas llamadas a Places y estabiliza la URL al mostrar

Ver también: `GUIA_MIGRACION_IMAGENES.md`.
