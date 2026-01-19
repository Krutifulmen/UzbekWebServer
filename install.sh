#!/bin/bash

# Uzbek Web Server (UzWS) - Установщик
# Скрипт установки для Linux систем

set -e

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Символы
CHECK="✅"
CROSS="❌"
INFO="🔷"
WARN="🔶"
ROCKET="🚀"
FLAG="🇺🇿"

# Функции
print_header() {
    clear
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║          Установка Uzbek Web Server (UzWS)              ║"
    echo "║                 Версия 2.0 'Plov Edition'               ║"
    echo "╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}${BOLD}$1${NC}"
}

print_success() {
    echo -e "${CHECK} ${GREEN}$1${NC}"
}

print_error() {
    echo -e "${CROSS} ${RED}$1${NC}"
}

print_info() {
    echo -e "${INFO} ${BLUE}$1${NC}"
}

# Проверяем права
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Не рекомендуется запускать установку от root!"
        print_info "Продолжить? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Проверяем систему
check_system() {
    print_step "1. Проверка системы..."
    
    # Проверяем ОС
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        print_success "ОС: $NAME $VERSION"
    else
        print_error "Не удалось определить ОС"
        exit 1
    fi
    
    # Проверяем Bash версию
    bash_version=$(bash --version | head -1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
    if [[ $(echo "$bash_version" | cut -d. -f1) -ge 4 ]]; then
        print_success "Bash версия: $bash_version"
    else
        print_error "Требуется Bash версии 4.0 или выше"
        exit 1
    fi
    
    # Проверяем netcat
    if command -v nc &> /dev/null; then
        nc_version=$(nc -h 2>&1 | head -1 | grep -o '[0-9]\+\.[0-9]\+')
        print_success "Netcat установлен: версия $nc_version"
    else
        print_warning "Netcat не установлен. Установка..."
        install_netcat
    fi
}

# Установка netcat
install_netcat() {
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y netcat-openbsd
    elif command -v yum &> /dev/null; then
        sudo yum install -y nc
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y nc
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm netcat
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y netcat-openbsd
    else
        print_error "Не удалось определить пакетный менеджер"
        print_info "Установите netcat вручную и перезапустите установку"
        exit 1
    fi
}

# Копируем файлы
copy_files() {
    print_step "2. Копирование файлов..."
    
    # Создаем директории
    mkdir -p ~/.uzws/examples
    print_success "Создана директория ~/.uzws"
    
    # Копируем основной скрипт
    if [[ -f "uzws" ]]; then
        cp uzws ~/.uzws/
        chmod +x ~/.uzws/uzws
        print_success "Основной скрипт скопирован"
    else
        print_error "Файл uzws не найден в текущей директории!"
        exit 1
    fi
    
    # Копируем примеры, если есть
    if [[ -d "examples" ]]; then
        cp -r examples/* ~/.uzws/examples/
        print_success "Примеры скопированы"
    fi
    
    # Создаем конфигурационный файл
    cat > ~/.uzws/config << EOF
# Конфигурация Uzbek Web Server
# Этот файл создан автоматически при установке

SERVER_NAME="Uzbek Web Server"
SERVER_VERSION="2.0"
DEFAULT_PORT="8080"
DEFAULT_DIR="."
LOG_REQUESTS="true"
SHOW_BANNER="true"
EOF
    print_success "Конфигурационный файл создан"
}

# Создаем символические ссылки
create_links() {
    print_step "3. Создание символических ссылок..."
    
    # Проверяем наличие директории в PATH
    if [[ ! ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        print_info "Добавляем ~/.local/bin в PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
        print_success "PATH обновлен (требуется перезапуск терминала)"
    fi
    
    # Создаем директорию для бинарников
    mkdir -p ~/.local/bin
    
    # Создаем ссылки
    ln -sf ~/.uzws/uzws ~/.local/bin/uzws
    ln -sf ~/.uzws/uzws ~/.local/bin/uzbekwebserver
    ln -sf ~/.uzws/uzws ~/.local/bin/uzws-server
    
    # Проверяем создание ссылок
    if [[ -L ~/.local/bin/uzws && -L ~/.local/bin/uzbekwebserver ]]; then
        print_success "Символические ссылки созданы:"
        echo -e "  ${GREEN}→${NC} uzws"
        echo -e "  ${GREEN}→${NC} uzbekwebserver"
        echo -e "  ${GREEN}→${NC} uzws-server"
    else
        print_error "Не удалось создать символические ссылки"
        exit 1
    fi
}

# Тестируем установку
test_installation() {
    print_step "4. Тестирование установки..."
    
    # Проверяем доступность команд
    if command -v uzws &> /dev/null; then
        print_success "Команда 'uzws' доступна"
    else
        print_error "Команда 'uzws' не найдена"
        exit 1
    fi
    
    if command -v uzbekwebserver &> /dev/null; then
        print_success "Команда 'uzbekwebserver' доступна"
    else
        print_error "Команда 'uzbekwebserver' не найдена"
        exit 1
    fi
    
    # Проверяем версию
    version_output=$(uzws --version 2>&1)
    if echo "$version_output" | grep -q "Uzbek Web Server"; then
        print_success "Версия определена корректно"
    else
        print_error "Не удалось определить версию"
    fi
}

# Показываем документацию
show_documentation() {
    print_step "5. Документация и примеры использования"
    
    echo ""
    echo -e "${PURPLE}${BOLD}✨ Установка завершена успешно!${NC}"
    echo ""
    echo -e "${CYAN}${BOLD}Доступные команды:${NC}"
    echo -e "  ${GREEN}uzws${NC}                    - Запустить сервер с настройками по умолчанию"
    echo -e "  ${GREEN}uzbekwebserver${NC}         - То же самое (алиас)"
    echo -e "  ${GREEN}uzws --help${NC}            - Показать справку"
    echo -e "  ${GREEN}uzws --version${NC}         - Показать версию"
    echo -e "  ${GREEN}uzws 3000 ./public${NC}     - Запустить на порту 3000 из папки public"
    echo ""
    
    echo -e "${CYAN}${BOLD}Быстрый старт:${NC}"
    echo -e "  1. ${GREEN}cd ~/.uzws/examples/basic-site${NC}"
    echo -e "  2. ${GREEN}uzws${NC}"
    echo -e "  3. Откройте ${YELLOW}http://localhost:8080${NC} в браузере"
    echo ""
    
    echo -e "${CYAN}${BOLD}Примеры находятся в:${NC}"
    echo -e "  ${GREEN}~/.uzws/examples/${NC}"
    echo ""
    
    echo -e "${YELLOW}${BOLD}Для удаления выполните:${NC}"
    echo -e "  ${GREEN}./uninstall.sh${NC}"
    echo ""
}

# Главная функция
main() {
    print_header
    check_root
    check_system
    copy_files
    create_links
    test_installation
    show_documentation
    
    echo -e "${ROCKET} ${GREEN}${BOLD}Uzbek Web Server успешно установлен!${NC} ${FLAG}"
    echo ""
}

# Запуск
main "$@"
