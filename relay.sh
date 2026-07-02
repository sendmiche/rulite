#!/bin/bash

# Проверка на root-права
if [ "$EUID" -ne 0 ]; then
    echo "[-] Ошибка: Пожалуйста, запустите скрипт с правами root."
    exit 1
fi

CONFIG_FILE="/etc/relay_rules.conf"
PATH_FILE="/etc/relay_nginx_path.conf"
NGINX_CONF="/etc/nginx/conf.d/relay_status.conf"

touch "$CONFIG_FILE"

# Определение интерфейса через реальный маршрут в интернет
INTERFACE=$(ip route get 1.1.1.1 | grep -oP 'dev \K\S+' | head -n 1)

if [ -z "$INTERFACE" ]; then
    echo "[-] Ошибка: Не удалось автоматически определить сетевой интерфейс."
    exit 1
fi

update_nginx_conf() {
    local path_string=$1
    # Создаем конфиг
    cat << EOF > "$NGINX_CONF"
server {
    listen 80;
    server_name _;
    location = /$path_string {
        default_type application/json;
        return 200 '{"status":"ok"}';
    }
}
EOF
    rm -f /etc/nginx/sites-enabled/default
    systemctl restart nginx > /dev/null 2>&1
}

setup_system() {
    # 1. Включение форвардинга
    if ! grep -q "net.ipv4.ip_forward=1" /etc/sysctl.d/99-ipforward.conf 2>/dev/null; then
        echo "[+] Настройка IP-форвардинга..."
        echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-ipforward.conf
        sysctl --system > /dev/null 2>&1
    fi

    # 2. Установка зависимостей
    if ! command -v nginx >/dev/null 2>&1 || ! dpkg -l | grep -q iptables-persistent; then
        echo "[+] Установка необходимых пакетов (nginx, iptables-persistent)..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq
        apt-get install -y -qq iptables-persistent nginx > /dev/null 2>&1
    fi

    # 3. Настройка динамического пути Nginx
    if [ ! -f "$PATH_FILE" ]; then
        # Если файла нет, генерируем случайный путь из 24 символов
        echo "[+] Генерация уникального пути Nginx..."
        local new_path=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)
        echo "$new_path" > "$PATH_FILE"
        update_nginx_conf "$new_path"
    elif [ ! -f "$NGINX_CONF" ]; then
        # Если файл с путем есть, а конфига nginx нет (например, случайно удалили)
        local current_path=$(cat "$PATH_FILE")
        update_nginx_conf "$current_path"
    fi
}

# --- Функции IPTABLES ---

apply_iptables() {
    local proto=$1
    local lport=$2
    local rip=$3
    local rport=$4

    if [ "$proto" == "tcp" ] || [ "$proto" == "both" ]; then
        iptables -t nat -A PREROUTING -i $INTERFACE -p tcp --dport $lport -j DNAT --to-destination $rip:$rport
        iptables -t nat -A POSTROUTING -p tcp -d $rip --dport $rport -j MASQUERADE
    fi
    if [ "$proto" == "udp" ] || [ "$proto" == "both" ]; then
        iptables -t nat -A PREROUTING -i $INTERFACE -p udp --dport $lport -j DNAT --to-destination $rip:$rport
        iptables -t nat -A POSTROUTING -p udp -d $rip --dport $rport -j MASQUERADE
    fi
}

remove_iptables() {
    local proto=$1
    local lport=$2
    local rip=$3
    local rport=$4

    if [ "$proto" == "tcp" ] || [ "$proto" == "both" ]; then
        iptables -t nat -D PREROUTING -i $INTERFACE -p tcp --dport $lport -j DNAT --to-destination $rip:$rport 2>/dev/null
        iptables -t nat -D POSTROUTING -p tcp -d $rip --dport $rport -j MASQUERADE 2>/dev/null
    fi
    if [ "$proto" == "udp" ] || [ "$proto" == "both" ]; then
        iptables -t nat -D PREROUTING -i $INTERFACE -p udp --dport $lport -j DNAT --to-destination $rip:$rport 2>/dev/null
        iptables -t nat -D POSTROUTING -p udp -d $rip --dport $rport -j MASQUERADE 2>/dev/null
    fi
}

add_rule() {
    echo ""
    read -p "Протокол (tcp/udp/both): " proto < /dev/tty
    if [[ ! "$proto" =~ ^(tcp|udp|both)$ ]]; then echo "[-] Ошибка: неверный протокол"; return; fi
    
    read -p "Порт на этом сервере: " lport < /dev/tty
    if grep -q -E "^(tcp|udp|both) $lport " "$CONFIG_FILE"; then
        echo "[-] Ошибка: Локальный порт $lport уже занят другим правилом!"
        return
    fi

    read -p "IP удаленного сервера: " rip < /dev/tty
    read -p "Порт на удаленном сервере: " rport < /dev/tty

    echo "$proto $lport $rip $rport" >> "$CONFIG_FILE"
    apply_iptables "$proto" "$lport" "$rip" "$rport"
    netfilter-persistent save > /dev/null 2>&1
    echo "[+] Правило добавлено и сохранено."
}

delete_rule() {
    list_rules
    if [ ! -s "$CONFIG_FILE" ]; then return; fi
    
    read -p "Введите номер правила для удаления (0 для отмены): " num < /dev/tty
    if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -eq 0 ]; then return; fi

    local rule=$(sed -n "${num}p" "$CONFIG_FILE")
    if [ -z "$rule" ]; then
        echo "[-] Правило под номером $num не найдено."
        return
    fi

    read -r proto lport rip rport <<< "$rule"
    remove_iptables "$proto" "$lport" "$rip" "$rport"
    sed -i "${num}d" "$CONFIG_FILE"
    netfilter-persistent save > /dev/null 2>&1
    echo "[+] Правило удалено."
}

edit_rule() {
    list_rules
    if [ ! -s "$CONFIG_FILE" ]; then return; fi

    read -p "Введите номер правила для изменения (0 для отмены): " num < /dev/tty
    if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -eq 0 ]; then return; fi

    local rule=$(sed -n "${num}p" "$CONFIG_FILE")
    if [ -z "$rule" ]; then
        echo "[-] Правило не найдено."
        return
    fi
    read -r old_proto old_lport old_rip old_rport <<< "$rule"

    echo ""
    echo "Оставьте поле пустым и нажмите Enter, чтобы не менять значение."
    read -p "Новый протокол (tcp/udp/both) [$old_proto]: " proto < /dev/tty
    proto=${proto:-$old_proto}
    
    read -p "Новый порт на этом сервере [$old_lport]: " lport < /dev/tty
    lport=${lport:-$old_lport}
    
    if [ "$lport" != "$old_lport" ] && grep -q -E "^(tcp|udp|both) $lport " "$CONFIG_FILE"; then
        echo "[-] Ошибка: Локальный порт $lport уже занят!"
        return
    fi

    read -p "Новый IP удаленного сервера [$old_rip]: " rip < /dev/tty
    rip=${rip:-$old_rip}
    
    read -p "Новый порт на удаленном сервере [$old_rport]: " rport < /dev/tty
    rport=${rport:-$old_rport}

    remove_iptables "$old_proto" "$old_lport" "$old_rip" "$old_rport"
    sed -i "${num}d" "$CONFIG_FILE"

    echo "$proto $lport $rip $rport" >> "$CONFIG_FILE"
    apply_iptables "$proto" "$lport" "$rip" "$rport"
    netfilter-persistent save > /dev/null 2>&1
    echo "[+] Правило успешно изменено."
}

list_rules() {
    echo ""
    echo "=== Текущие правила проброса ==="
    if [ ! -s "$CONFIG_FILE" ]; then
        echo "   Правил пока нет."
    else
        nl -w 2 -s ". " "$CONFIG_FILE" | while read -r line; do
            num=$(echo "$line" | awk '{print $1}')
            proto=$(echo "$line" | awk '{print $2}')
            lport=$(echo "$line" | awk '{print $3}')
            rip=$(echo "$line" | awk '{print $4}')
            rport=$(echo "$line" | awk '{print $5}')
            echo " $num) [$proto] Порт $lport  -->  $rip:$rport"
        done
    fi
    echo "================================"
}

# --- Функции Nginx ---

show_nginx_path() {
    echo ""
    echo "=== Статус-путь Nginx ==="
    if [ ! -f "$PATH_FILE" ]; then
        echo "[-] Путь еще не настроен."
    else
        local current_path=$(cat "$PATH_FILE")
        local server_ip=$(curl -s -4 ifconfig.me || echo "IP_ВАШЕГО_СЕРВЕРА")
        echo "Текущий путь: /$current_path"
        echo "Ссылка:       http://$server_ip/$current_path"
    fi
    echo "========================="
}

change_nginx_path() {
    echo ""
    if [ -f "$PATH_FILE" ]; then
        local current_path=$(cat "$PATH_FILE")
        echo "Текущий путь: /$current_path"
    fi
    
    echo "Введите новый путь (без слеша в начале) или оставьте пустым для генерации случайного:"
    read -p "Новый путь: " new_path < /dev/tty

    # Если пусто - генерируем
    if [ -z "$new_path" ]; then
        new_path=$(tr -dc 'a-z0-9' < /dev/urandom | head -c 24)
        echo "[+] Сгенерирован новый случайный путь!"
    fi

    # Очищаем ввод от лишних символов (пробелов и слешей)
    new_path=$(echo "$new_path" | tr -d '/ \\')

    if [ -z "$new_path" ]; then
        echo "[-] Ошибка: путь не может быть пустым."
        return
    fi

    echo "$new_path" > "$PATH_FILE"
    update_nginx_conf "$new_path"
    
    echo "[+] Nginx успешно обновлен с новым путем!"
    show_nginx_path
}

# --- Запуск ---

setup_system

while true; do
    echo ""
    echo "Управление релеем (Интерфейс: $INTERFACE)"
    echo "1. Добавить проброс"
    echo "2. Изменить правило"
    echo "3. Удалить правило"
    echo "4. Показать все правила"
    echo "5. Показать статус-путь (Nginx)"
    echo "6. Изменить статус-путь (Nginx)"
    echo "0. Выход"
    read -p "Выберите действие [0-6]: " choice < /dev/tty

    case $choice in
        1) add_rule ;;
        2) edit_rule ;;
        3) delete_rule ;;
        4) list_rules ;;
        5) show_nginx_path ;;
        6) change_nginx_path ;;
        0) echo "Выход."; exit 0 ;;
        *) echo "[-] Неверный выбор." ;;
    esac
done
