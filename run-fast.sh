#!/bin/bash

# Script para ejecutar la app Flutter en modo optimizado (sin LLDB)
# Uso: ./run-fast.sh [device-id]

echo "🚀 Ejecutando app en modo Profile (sin depurador LLDB)..."
echo ""

# Verificar si se proporcionó un device-id
if [ -n "$1" ]; then
    echo "📱 Dispositivo especificado: $1"
    flutter run --profile --no-debug -d "$1"
else
    echo "📱 Buscando dispositivos disponibles..."
    flutter run --profile --no-debug
fi
