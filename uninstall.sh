#!/bin/bash

# Uzbek Web Server (UzWS) - Скрипт удаления

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CROSS="❌"
CHECK="✅"
INFO="🔷"
WARN="🔶"

print_message() {
    echo -e "$1"
}

print_header() {
    echo -e "${RED}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          Удаление Uzbek Web Server (UzWS)               ║"
    echo "╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

confirm_uninstall() {
    echo -e "${YELLOW}Вы уверены, что хотите удалить Uzbek Web Server?${NC}"
    echo -e "${YELLOW}Это действие нельзя отменить. (y/N): ${NC}"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Удаление отменено.${NC}"
        exit 0
    fi
}

remove_links() {
    echo -e "${BLUE}Удаление символических ссылок...${NC}"
    
    local links_removed=0
    local links=("uzws" "uzbekwebserver" "uzws-server")
    
    for link in "${links[@]}"; do
        if [[ -L ~/.local/bin/"$link" ]]; then
            rm ~/.local/bin/"$link"
            echo -e "${CHECK} Удалена ссылка: $link"
            ((links_removed++))
        fi
    done
    
    if [[ $links_removed -eq 0 ]]; then
        echo -e "${INFO} Символические ссылки не найдены"
    fi
}

remove_files() {
    echo -e "${BLUE}Удаление файлов сервера...${NC}"
    
    if [[ -d ~/.uzws ]]; then
        rm -rf ~/.uzws
        echo -e "${CHECK} Удалена директория ~/.uzws"
    else
        echo -e "${INFO} Директория ~/.uzws не найдена"
    fi
}

cleanup_path() {
    echo -e "${BLUE}Очистка переменной PATH...${NC}"
    
    # Убираем из .bashrc, если добавляли
    if grep -q "export PATH=\"\$HOME/.local/bin:\$PATH\"" ~/.bashrc; then
        # Проверяем, есть ли другие программы в .local/bin
        if [[ -d ~/.local/bin ]] && [[ $(ls -A ~/.local/bin 2>/dev/null | wc -l) -eq 0 ]]; then
            # Если директория пуста, убираем из PATH
            sed -i '/export PATH="\$HOME\/.local\/bin:\$PATH"/d' ~/.bashrc
            echo -e "${CHECK} Удалено из ~/.bashrc"
        else
            echo -e "${INFO} В ~/.local/bin есть другие программы, оставляем в PATH"
        fi
    fi
}

show_final_message() {
    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Uzbek Web Server успешно удален!${NC}"
    echo ""
    echo -e "Файлы и настройки были удалены из системы."
    echo -e "Если вы хотите установить его снова, просто запустите:"
    echo -e "  ${YELLOW}./install.sh${NC}"
    echo ""
    echo -e "${GREEN}Спасибо за использование Uzbek Web Server! 🇺🇿${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
}

main() {
    print_header
    confirm_uninstall
    remove_links
    remove_files
    cleanup_path
    show_final_message
}

main "$@"
