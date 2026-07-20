#!/bin/bash

# ================================================
# SCRIPT DE INICIO - Sistema de Trámite Documentario
# IESTP "Jorge Desmaison Seminario"
# ================================================

# Colores para la terminal
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Directorios del proyecto
PROJECT_DIR="$HOME/proyectos/tramite-documentario"
BACKEND_DIR="$PROJECT_DIR/backend-laravel"
FRONTEND_DIR="$PROJECT_DIR/frontend-flutter"

# Configuración de puertos
BACKEND_PORT=8000

# Función para mostrar mensajes
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_header() {
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  SISTEMA DE TRÁMITE DOCUMENTARIO - IESTP                   ║${NC}"
    echo -e "${GREEN}║  INSTITUTO DE EDUCACIÓN SUPERIOR TECNOLÓGICO               ║${NC}"
    echo -e "${GREEN}║  JORGE DESMAISON SEMINARIO                                ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Función para verificar si un puerto está en uso
port_in_use() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0
    else
        return 1
    fi
}

# Función para matar procesos en un puerto
kill_port() {
    local port=$1
    if port_in_use $port; then
        print_warning "El puerto $port está en uso. Intentando liberarlo..."
        lsof -ti:$port | xargs kill -9 2>/dev/null
        sleep 1
        if port_in_use $port; then
            print_error "No se pudo liberar el puerto $port"
            return 1
        else
            print_success "Puerto $port liberado"
            return 0
        fi
    fi
    return 0
}

# Función para verificar si el backend está funcionando
check_backend() {
    local retry=0
    local max_retry=15
    print_message "Esperando que el backend esté disponible..."
    while [ $retry -lt $max_retry ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$BACKEND_PORT/api/consulta/dni/12345678" 2>/dev/null | grep -q "200\|404"; then
            return 0
        fi
        retry=$((retry + 1))
        sleep 1
    done
    return 1
}

# ================================================
# INICIO DEL SCRIPT
# ================================================

clear
print_header

# Verificar que los directorios existen
print_message "Verificando directorios del proyecto..."

if [ ! -d "$BACKEND_DIR" ]; then
    print_error "Directorio del backend no encontrado: $BACKEND_DIR"
    exit 1
fi

if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "Directorio del frontend no encontrado: $FRONTEND_DIR"
    exit 1
fi

print_success "Directorios verificados"

# ================================================
# INICIAR BACKEND
# ================================================

print_message "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message "INICIANDO BACKEND (Laravel)"
print_message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar que el backend no esté corriendo
if port_in_use $BACKEND_PORT; then
    print_warning "El backend ya está corriendo en el puerto $BACKEND_PORT"
    kill_port $BACKEND_PORT
fi

# Iniciar backend
print_message "Iniciando servidor Laravel en puerto $BACKEND_PORT..."
cd "$BACKEND_DIR"
php artisan serve --port=$BACKEND_PORT > /dev/null 2>&1 &
BACKEND_PID=$!

# Esperar a que el backend esté listo
if check_backend; then
    print_success "Backend iniciado correctamente en http://localhost:$BACKEND_PORT"
else
    print_error "El backend no respondió correctamente"
    exit 1
fi

# ================================================
# INICIAR FRONTEND
# ================================================

print_message "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_message "INICIANDO FRONTEND (Flutter)"
print_message "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verificar que Flutter está instalado
if ! command -v flutter &> /dev/null; then
    if [ -f "$HOME/flutter/bin/flutter" ]; then
        print_message "Usando Flutter desde $HOME/flutter/bin/flutter"
        FLUTTER_CMD="$HOME/flutter/bin/flutter"
    else
        print_error "Flutter no está instalado"
        exit 1
    fi
else
    FLUTTER_CMD="flutter"
fi

# Verificar que el frontend tiene soporte Linux
if [ ! -d "$FRONTEND_DIR/linux" ]; then
    print_warning "El proyecto no tiene soporte para Linux. Configurando..."
    cd "$FRONTEND_DIR"
    $FLUTTER_CMD config --enable-linux-desktop
    $FLUTTER_CMD create --platforms=linux . 2>/dev/null
    print_success "Soporte Linux configurado"
fi

# Instalar dependencias si es necesario
print_message "Verificando dependencias de Flutter..."
cd "$FRONTEND_DIR"
if [ ! -d ".dart_tool" ]; then
    print_message "Instalando dependencias..."
    $FLUTTER_CMD pub get
fi

# Iniciar frontend
print_message "Iniciando aplicación Flutter en Linux..."
print_warning "La aplicación se abrirá en una nueva ventana"
echo ""

cd "$FRONTEND_DIR"
$FLUTTER_CMD run -d linux

# ================================================
# LIMPIEZA AL SALIR
# ================================================

cleanup() {
    echo ""
    print_message "Deteniendo servicios..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    print_success "Servicios detenidos"
    exit 0
}

trap cleanup SIGINT SIGTERM

# ================================================
# INFORMACIÓN FINAL
# ================================================

echo ""
print_success "¡SISTEMA INICIADO CORRECTAMENTE!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Credenciales de acceso:"
echo "  ───────────────────────"
echo "  Email: admin@iestp.edu.pe"
echo "  Password: admin123"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_warning "Presione Ctrl+C para detener todos los servicios"

wait
