#!/bin/bash

# ================================================
# SCRIPT PARA REINICIAR SERVICIOS
# ================================================

GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m"

echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  REINICIANDO SISTEMA                            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}[INFO]${NC} Deteniendo servicios..."
./stop.sh

echo ""
echo -e "${BLUE}[INFO]${NC} Iniciando servicios..."
./start.sh
