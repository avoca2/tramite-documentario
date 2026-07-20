#!/bin/bash

# ================================================
# SCRIPT PARA DETENER SERVICIOS
# ================================================

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  DETENIENDO SERVICIOS DEL SISTEMA               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Detener procesos en puerto 8000 (Backend)
print_message "Deteniendo backend (puerto 8000)..."
if lsof -ti:8000 >/dev/null 2>&1; then
    lsof -ti:8000 | xargs kill -9 2>/dev/null
    print_success "Backend detenido"
else
    print_warning "No hay procesos en el puerto 8000"
fi

# Detener procesos de Flutter
print_message "Deteniendo frontend (Flutter)..."
pkill -f "flutter run" 2>/dev/null
pkill -f "flutter_tool" 2>/dev/null
print_success "Frontend detenido"

echo ""
print_success "Todos los servicios han sido detenidos"
