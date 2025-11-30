#!/usr/bin/env bash

set -euo pipefail

echo "==============================="
echo " DevOps tools installer script "
echo "==============================="

# Допоміжна функція для перевірки наявності команди
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ----------------------
# 1. Docker
# ----------------------
install_docker() {
    if command_exists docker; then
        echo "[Docker] Вже встановлений, пропускаю."
    else
        echo "[Docker] Не знайдено. Встановлюю Docker..."
        sudo apt-get update -y
        sudo apt-get install -y docker.io

        echo "[Docker] Увімкнення та запуск служби docker..."
        sudo systemctl enable docker
        sudo systemctl start docker

        # Додаємо поточного користувача в групу docker (щоб можна було працювати без sudo)
        if getent group docker >/dev/null 2>&1; then
            sudo usermod -aG docker "$USER" || true
            echo "[Docker] Користувача $USER додано до групи 'docker' (потрібний перелогін)."
        else
            echo "[Docker] Групу 'docker' не знайдено, пропускаю додавання користувача."
        fi

        echo "[Docker] Встановлення завершено."
    fi
}

# ----------------------
# 2. Docker Compose
# ----------------------
install_docker_compose() {
    if command_exists docker-compose; then
        echo "[Docker Compose] Вже встановлений (docker-compose)."
        return
    fi

    if command_exists docker && docker compose version >/dev/null 2>&1; then
        echo "[Docker Compose] Вже встановлений (docker compose як плагін Docker)."
        return
    fi

    echo "[Docker Compose] Не знайдено. Встановлюю через apt..."
    sudo apt-get update -y
    sudo apt-get install -y docker-compose

    if command_exists docker-compose; then
        echo "[Docker Compose] Встановлено успішно."
    else
        echo "[Docker Compose] Попередження: пакет встановлено, але команда не знайдена. Перевірте PATH."
    fi
}

# ----------------------
# 3. Python 3 (>= 3.9) + pip
# ----------------------
check_python_version() {    
    local ver
    ver=$(python3 -V 2>&1 | awk '{print $2}')
    local major minor
    IFS='.' read -r major minor _ <<<"$ver"
    if (( major > 3 )) || (( major == 3 && minor >= 9 )); then
        return 0
    else
        return 1
    fi
}

install_python() {
    if command_exists python3; then
        echo "[Python] Знайдено python3: $(python3 -V 2>&1)"

        if check_python_version; then
            echo "[Python] Версія підходить (>= 3.9), пропускаю встановлення."
        else
            echo "[Python] Попередження: версія < 3.9. Спробую оновити через apt..."
            sudo apt-get update -y
            sudo apt-get install -y python3
            echo "[Python] Поточна версія: $(python3 -V 2>&1)"
        fi
    else
        echo "[Python] Не знайдено python3. Встановлюю..."
        sudo apt-get update -y
        sudo apt-get install -y python3
        echo "[Python] Встановлено: $(python3 -V 2>&1)"
    fi
    
    if command_exists pip3; then
        echo "[pip] Вже встановлений (pip3)."
    else
        echo "[pip] Не знайдено pip3. Встановлюю..."
        sudo apt-get update -y
        sudo apt-get install -y python3-pip
        echo "[pip] Встановлено pip3: $(pip3 --version)"
    fi
}

# ----------------------
# 4. Django (через pip)
# ----------------------
install_django() {
    if python3 -m django --version >/dev/null 2>&1; then
        echo "[Django] Вже встановлений (python3 -m django)."
    else
        echo "[Django] Не знайдено. Встановлюю Django через pip3 (в домашню директорію користувача)..."
        pip3 install --user django
        if python3 -m django --version >/dev/null 2>&1; then
            echo "[Django] Успішно встановлено. Версія: $(python3 -m django --version)"
        else
            echo "[Django] Помилка: Django не вдалося встановити або не знайдено у PATH."
        fi
    fi
}

# ----------------------
# Запуск усіх кроків
# ----------------------
install_docker
install_docker_compose
install_python
install_django

echo "======================================="
echo " Усі перевірки та встановлення завершені."
echo " Можливо, потрібно перелогінитися для Docker-групи."
echo "======================================="
