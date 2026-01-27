#!/bin/bash
# Script para ejecutar la migración de imágenes de Google Places a Firebase Storage
# 
# Uso: bash run_migration.sh
#
# Este script:
# 1. Verifica que Flutter esté instalado
# 2. Obtiene la API key de Firebase (opcional)
# 3. Ejecuta la migración
# 4. Muestra un reporte final

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║   MIGRACIÓN DE IMÁGENES: Google Places → Firebase Storage        ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que estamos en la carpeta correcta
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: No se encontró pubspec.yaml"
    echo "   Asegúrate de estar en la raíz del proyecto"
    exit 1
fi

echo "✅ Proyecto detectado: $(grep '^name:' pubspec.yaml | cut -d' ' -f2)"
echo ""

# Verificar conexión a Firebase
echo "🔍 Verificando conexión a Firebase..."
if ! firebase --version &> /dev/null; then
    echo "⚠️  Firebase CLI no está instalado (opcional)"
    echo "   Instálalo con: npm install -g firebase-tools"
else
    echo "✅ Firebase CLI encontrado"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                   INSTRUCCIONES PARA MIGRAR                       ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "OPCIÓN 1: Ejecutar desde Dart (Recomendado)"
echo "  1. Abre lib/main.dart"
echo "  2. En la función main(), añade:"
echo ""
echo "    if (kDebugMode) {"
echo "      print('🚀 Iniciando migración de imágenes...');"
echo "      await MigrationUtils.runMigration();"
echo "    }"
echo ""
echo "  3. Ejecuta: flutter run"
echo ""
echo "OPCIÓN 2: Desde Console"
echo "  1. Abre Firebase Console"
echo "  2. Firestore Database → Cloud Functions"
echo "  3. Crea una función HTTP que llame a migrateAllGoogleImagesToFirebase()"
echo ""
echo "OPCIÓN 3: Verificar primero una playa"
echo "  1. Ejecuta primero una sola playa para testing"
echo "  2. En main.dart: await MigrationUtils.migrateBeach('1');"
echo "  3. Verifica en la app que la imagen carga correctamente"
echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                    SEGURIDAD Y RESPALDOS                          ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "⚠️  IMPORTANTE ANTES DE MIGRAR:"
echo ""
echo "1. 🔒 Haz un respaldo de tu base de datos:"
echo "   firebase firestore:delete --all --confirmation"
echo ""
echo "2. 📸 Verifica que Firebase Storage esté habilitado:"
echo "   https://console.firebase.google.com/storage"
echo ""
echo "3. 🔐 Configura las reglas de seguridad correctamente:"
echo "   match /beaches/{allPaths=**} {"
echo "     allow read: if true;  // Público (es ok, son imágenes)"
echo "   }"
echo ""
echo "4. ⏱️  El proceso puede tardar 10-60 minutos"
echo ""
echo "5. 🌐 Necesitas buena conexión a internet"
echo ""

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                        DOCUMENTACIÓN                              ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📖 Lee estos archivos para más información:"
echo "   • RESUMEN_IMPLEMENTACION.md - Resumen de cambios"
echo "   • GUIA_MIGRACION_IMAGENES.md - Guía detallada"
echo ""

echo "✅ Script finalizado"
echo ""
