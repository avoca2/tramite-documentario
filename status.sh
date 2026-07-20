#!/bin/bash

# ================================================
# SCRIPT PARA VERIFICAR ESTADO DE SERVICIOS
# ================================================

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ESTADO DEL SISTEMA                             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar Backend
echo -n "Backend (puerto 8000): "
if lsof -ti:8000 >/dev/null 2>&1; then
    echo -e "${GREEN}ACTIVO${NC}"
    PID=$(lsof -ti:8000 | head -1)
    echo "  PID: $PID"
    echo "  URL: http://localhost:8000"
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8000/api/consulta/dni/12345678" 2>/dev/null | grep -q "200\|404"; then
        echo "  Estado: ${GREEN}Respondiendo${NC}"
    else
        echo "  Estado: ${RED}No responde${NC}"
    fi
else
    echo -e "${RED}DETENIDO${NC}"
fi

echo ""

# Verificar Frontend
echo -n "Frontend (Flutter): "
if pgrep -f "flutter run" >/dev/null 2>&1; then
    echo -e "${GREEN}ACTIVO${NC}"
else
    echo -e "${RED}DETENIDO${NC}"
fi

echo ""
