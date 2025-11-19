# 🗑️ Guía para Eliminar Playas Manualmente desde Firebase

## 📋 Lista de Playas a Eliminar:

1. Parador Fotográfico Barahona
2. San Rafael
3. Barahona
4. Acapulco beach
5. Casa de Campo Resort and Villas
6. Playa Publica Bayahibe
7. Playa Bayahibe
8. Playa Teco Maimón Puerto Plata
9. Playa de Güibia
10. Public Beach Playa Dominicus
11. Puerto Turístico Taíno Bay
12. Terminal Turística Amber Cove
13. La Caleta

---

## 🔥 Método 1: Consola Web de Firebase (Recomendado)

### Paso 1: Acceder a Firebase Console
1. Ve a [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Selecciona tu proyecto **playas_rd_flutter**

### Paso 2: Ir a Firestore Database
1. En el menú lateral izquierdo, haz clic en **"Firestore Database"**
2. Deberías ver la colección `beaches` con todas las playas

### Paso 3: Buscar y Eliminar Documentos

#### Método: Eliminar Documento Directamente

1. **Abre la colección `beaches`:**
   - Haz clic en la colección `beaches` en el panel izquierdo
   - Verás una lista de todos los documentos (playas)

2. **Buscar cada playa a eliminar:**
   - Desplázate por la lista o usa la búsqueda
   - Busca cada uno de estos nombres:
     - `Parador Fotográfico Barahona`
     - `San Rafael`
     - `Barahona`
     - `Acapulco beach`
     - `Casa de Campo Resort and Villas`
     - `Playa Publica Bayahibe`
     - `Playa Bayahibe`
     - `Playa Teco Maimón Puerto Plata`
     - `Playa de Güibia`
     - `Public Beach Playa Dominicus`
     - `Puerto Turístico Taíno Bay`
     - `Terminal Turística Amber Cove`
     - `La Caleta`

3. **Eliminar cada documento:**
   Para cada documento encontrado, tienes dos opciones:
   
   **Opción A - Desde la lista de documentos:**
   - Haz clic derecho sobre el documento en la lista
   - Selecciona **"Delete document"** (Eliminar documento)
   - Confirma en el diálogo que aparece
   
   **Opción B - Desde dentro del documento:**
   - Haz clic en el documento para abrirlo
   - En la parte superior derecha, verás un menú con tres puntos (⋯) o un ícono de papelera (🗑️)
   - Haz clic en **"Delete document"** (Eliminar documento)
   - Confirma la eliminación en el diálogo

#### Usar Filtro para Buscar Específicamente

Si hay muchas playas y quieres encontrarlas más rápido:

1. En la colección `beaches`, haz clic en **"Add filter"** (Agregar filtro)
2. Configura el filtro:
   - Campo: `name`
   - Operador: `==` (igual a)
   - Valor: `[nombre exacto de la playa]`
   - Ejemplo: `Playa Bayahibe`
3. Haz clic en **"Apply"** (Aplicar)
4. Si encuentra el documento, haz clic derecho sobre él y selecciona **"Delete document"**
5. Repite el proceso para cada playa de la lista

### Paso 4: Verificar la Eliminación
1. Después de eliminar todas las playas, cuenta el total de documentos
2. Deberías tener aproximadamente **90 playas** (103 - 13 = 90)

---

## 💻 Método 2: Usar el Script de Eliminación

Si prefieres usar el script, conecta tu dispositivo Android y ejecuta:

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar el script de eliminación
flutter run -d [ID_DISPOSITIVO] --target=scripts/delete_beaches.dart
```

El script buscará automáticamente todas las playas de la lista y las eliminará.

---

## 📊 Método 3: Eliminar por Lotes (Bulk Delete)

Si tienes muchas playas similares, puedes:

1. En Firestore Console, selecciona múltiples documentos (Shift + Click)
2. Haz clic en el botón **"Delete"** en la parte superior
3. Confirma la eliminación

**Nota:** Esto solo funciona si las playas están visibles en la misma página.

---

## ⚠️ Consideraciones Importantes

### Antes de Eliminar:
- ✅ Haz un backup de tu base de datos (si es posible)
- ✅ Verifica que estas playas realmente deben eliminarse
- ✅ Ten en cuenta que esto afectará a todos los usuarios

### Después de Eliminar:
- ✅ Verifica que el total de playas sea correcto
- ✅ Ejecuta el script de exportación para verificar:
  ```bash
  flutter run -d [ID_DISPOSITIVO] --target=scripts/export_beaches_to_file.dart
  ```

---

## 🆘 Solución de Problemas

### No encuentro una playa:
- Verifica que el nombre sea exactamente igual (mayúsculas, acentos, espacios)
- Algunas playas pueden tener nombres ligeramente diferentes
- Usa la búsqueda parcial si es necesario

### Error al eliminar:
- Verifica que tengas permisos de escritura en Firestore
- Revisa las reglas de seguridad de Firestore en `firestore.rules`
- Asegúrate de estar autenticado como administrador

### ¿Necesito eliminar "La Caleta"?
**Nota importante:** "La Caleta" también está definida en el código local (ID: '17') como una playa válida. Si la eliminas de Firestore pero está en el código, se volverá a sincronizar. Considera si realmente quieres eliminarla o solo actualizar su información.

---

## ✅ Checklist de Verificación

- [ ] Accedí a Firebase Console
- [ ] Encontré la colección `beaches`
- [ ] Busqué cada una de las 13 playas
- [ ] Eliminé todas las playas encontradas
- [ ] Verifiqué el total de playas restantes (debe ser ~90)
- [ ] Probé buscar una de las playas eliminadas para confirmar

---

## 📞 Comandos Rápidos de Referencia

```bash
# Ver dispositivos conectados
flutter devices

# Exportar playas actuales (para verificar)
flutter run -d [ID] --target=scripts/export_beaches_to_file.dart

# Eliminar playas específicas
flutter run -d [ID] --target=scripts/delete_beaches.dart
```

---

**Última actualización:** 2024-12-19

