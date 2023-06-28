#!/bin/bash
# version 6 (23/08/2022) (based on create-domain.bash)


#Скрипт для переноса/контейнеризации домена.
#Указываем имена для проекта и потом для домена.
#Делаем папки и распологаем файлы.
#Получем список действующих портов, которые задействованы на сервере, указываю новый
# ===== Нужен файл ~/template.tgz =====
# ===== Для нового сервера еще и ~/php71mongo42mem31.tgz =====
#Генерация новых портов и новой структуры, генерация конфигов
#   В финальной форме выполняется
#Первичный запуск самого контейнера
#Попытка стартового nginx автогененрации и тестирование.

# для автоматизации использовать ProjName=$1 && domain=$2 && ReadOFF=$3
# выключатель READ-ов (убрать значение пошагово Наличие auto - автоматический скрипт
ReadOFF=$3


# сектор для сохранения, на время разработки (NOT USED IN SCRIPT)
NonActive () {

cat > $DChome/Dockerfile <<EOF
FROM php:7.1-fpm
RUN apt-get update \
    && apt-get install -y git zip unzip libcurl4-openssl-dev pkg-config libssl-dev \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php && apt clean \
    && docker-php-ext-install opcache \
    && pecl install mongodb apcu && docker-php-ext-enable mongodb apcu opcache
EOF

}

# Конечно же форма безсмысленная, но вдруг что-то пойдет не так...
BakForm () {
    [ -d /bak ] || mkdir /bak
    cp -v --parents /etc/nginx/sites-enabled/$domain /bak/ || (echo "ERROR: $?" && exit)
    cp -v --parents /etc/supervisor/conf.d/mongod.conf /bak/||(echo "ERROR: $?" && exit)
    cp --parents ${LogName}* /bak/
    echo "
    <<<<    ARCHIVE COPY TASK IS DONE!"
    # nextStep in -- CreateFileCompose
    }



# Теперь подготовка к запуску контейнера
FinalForm () {
    # Теперь подготовка к запуску контейнера и повышение версии базы
#    echo " COPY PHP SCRIPTS NOW "
#    cp -r $wwwRoot/* $DChome/data/www/
    echo "
    >>>>    CHECK image PHP-MONGO"
    [ ! -z "`docker image ls --no-trunc | grep php-mdb-mem`" ] || (gunzip -ck ~/php71mongo42mem31.tgz | docker load)
    # добавление правила firewall
    #iptables -A INPUT -p tcp -m tcp -s 127.0.0.1 --dport ${DBNEWPORT} -j ACCEPT
    # замена подключения БД
    sed -i s/localhost/mongod/ $DChome/data/www/app/Database.php
    sed -i s/localhost/mongod/ $DChome/data/www/app/config/config.php
    # экспорт крона
    crontab -l | grep $domain > $DChome/cron.$domain.txt
    echo "
    >>>>    Crontab saved: $DChome/cron.$domain.txt
    ----    sleep 10s  ----"
    sleep 10

    # Финализация процесса
    # Перед запуском контейнера стоит еще раз проверить конфиги
    cd $DChome && docker-compose up -d # OR docker-compose up -d && docker-compose logs -f
    echo "    sleep 60 and read logs"
    sleep 60
    cd $DChome && docker-compose logs --tail 50
    curl --resolve ${domain}1.example.com:80:${IPV4_NET}.2 http://${domain}1.example.com
    sed -i "s'${wwwRoot}'/var/www'g" $DChome/cron.$domain.txt
    sed -i "s/ php / docker exec -t ${dom_short}_php_1 php /g" $DChome/cron.$domain.txt

    # вроде как всё, запускаем, проверяем - мусор удаляем
    echo '
    >>>>    If all ok, need in next step add cron and iptables:
    Crontab ADD -- crontab $DChome/cron.$domain.txt
    iptables -A INPUT -p tcp -m tcp -s 127.0.0.1 --dport ${DBNEWPORT} -j ACCEPT
    iptables -A INPUT -p tcp -m tcp -s 127.0.0.2 --dport ${DBNEWPORT} -j ACCEPT'
    nginx -t && nginx -s reload

}

# Создание композитного файла
CreateFileCompose () {
cat > $DChome/conf/mongod/mongod.conf <<EOF
net:
  ipv6: true
  port: ${DBPort}
processManagement:
  fork: "false"
#replication:
#  replSetName: ${DBName}
storage:
  dbPath: /data/db/
  wiredTiger:
    engineConfig:
      cacheSizeGB: ${MONGO_CACHE}
EOF
#==============================================
    chown -R 999:999 ${DChome}/data/
    chown -R 999:0 ${DChome}/conf/mongod/
    iptables -I INPUT -p tcp -m tcp -s 127.0.0.1 --dport ${DBNEWPORT} -j ACCEPT
    
    docker-compose --file $DChome/docker-compose.yml up -d
    sleep 5
    mongodump --archive --port $DBPort | mongorestore --archive --port ${DBNEWPORT}

    # если потребуется, но она не нужна при реальном дампе    
#    UpperMongoForm

#==============================================
cat > $DChome/conf/nginx/conf.d/${domain}.conf <<EOF
server {
  listen   80;
#  listen   [::]:80;

  server_name ${DomainName};
  root /var/www/;
  index index.php;
  charset utf-8;
#  error_log /var/log/nginx/${DomainName}.log;
  add_header Access-Control-Allow-Origin *;

  location = /php7-fpm-status {
    access_log off;
    allow 127.0.0.1;
    deny all;
    include fastcgi_params;
    fastcgi_pass unix:/run/php7.1-dock.sock;
  }

  location = /ping {
    access_log off;
    allow 127.0.0.1;
    deny all;
    include fastcgi_params;
    fastcgi_pass unix:/run/php7.1-dock.sock;
  }
  
  location / {
    add_header Access-Control-Allow-Origin *;
    index index.php;
  }

  location ~ \.php\$ {
    try_files \$uri =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)\$;
    fastcgi_pass unix:/run/php7.1-dock.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    include fastcgi_params;
  }
}
EOF
#==============================================
cat > $DChome/conf/php/conf.d/php-fpm.conf <<EOF
[global]
pid = /run/php7.1-fpm.pid
error_log = syslog
; var/log/php7.1-fpm.log
log_level = notice
emergency_restart_threshold = 0
emergency_restart_interval = 1m
process_control_timeout = 5s
daemonize = no
include=/etc/php/conf.d/pool.d/*.conf
EOF

cat > $DChome/conf/php/conf.d/pool.d/www.conf <<EOF
[www-dock]
user = www-data
group = www-data
listen = /var/run/php7.1-dock.sock
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 10
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.status_path = /php7-fpm-status
slowlog = /var/log/\$pool.log.slow
request_slowlog_timeout = 3s
EOF

#==============================================
#cat > $DChome/${domain}.conf <<EOF
cat > /etc/nginx/sites-enabled/${domain}.conf <<EOF
server {
    listen          80;
    listen          [::]:80;
    server_name     ${domain}1.example.com;
    return          301 https://\$server_name\$request_uri permanent;
  }

server {
    listen          443;
    listen          [::]:443;
    server_name     ${domain}1.example.com;
    error_log       /var/log/nginx/${domain}.log;
    ssl                  on;
    ssl_certificate      example.crt;
    ssl_certificate_key  example.key;
    ssl_session_timeout  5m;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         ALL:!ADH:+HIGH:+MEDIUM:+LOW:+EXP:!kEDH:!aNULL:!RC4:!SSLv2;
    ssl_prefer_server_ciphers   on;
    ssl_session_cache shared:TLS:2m;

    location / {
        proxy_read_timeout      3600;
        proxy_connect_timeout   3600;
        proxy_redirect          off;
        proxy_http_version 1.1;
        proxy_set_header        Host              \$http_host;
        proxy_set_header X-Real-IP      \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade        \$http_upgrade;
        proxy_set_header Connection     connection_upgrade;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_pass http://${IPV4_NET}.2:80;
      }

}
EOF

#======================================
cat > $DChome/.env <<EOF
COMPOSE_PROJECT_NAME=${dom_short}
IPV4_NET=${IPV4_NET}
domain=${domain}
DChome=${DChome}
DomainName=${DomainName}
dom_short=${dom_short}
NGINXPORT=${NGINXPORT}
DBPort=${DBPort}
DBNEWPORT=${DBNEWPORT}
MG_ADM=${MG_ADM}
MG_PASS=${MG_PASS}

EOF

#======================================
cat > $DChome/docker-compose.yml <<EOF
version: '2'
services:
  nginx:
    image: 'nginx:stable'
    networks:
      domain-${dom_short}:
        ipv4_address: '${IPV4_NET}.2'
    hostname: '${domain}_nginx'
    volumes:
      - './conf/nginx/:/etc/nginx:ro,z'
      - './conf/run/:/var/run:z'
      - './data/www/:/var/www/'
    depends_on:
      - 'mongodb'
      - 'php'

  mongodb:
    image: 'mongo:4.2'
    networks:
      domain-${dom_short}:
        ipv4_address: '${IPV4_NET}.3'
        aliases:
          - mongod
    ports:
      - '${DBNEWPORT}:${DBPort}'
    hostname: '${domain}_mongo'
    environment:
      - 'MONGO_INITDB_ROOT_USERNAME:${MG_ADM}'
      - 'MONGO_INITDB_ROOT_USERNAME:${MG_PASS}'
    volumes:
      - './data/mongodb/:/data/db:rw'
      - './conf/mongod/:/data/configdb:ro'
    command: '--config /data/configdb/mongod.conf'

  php:
    image: 'php-mdb-mem:71-42-31'
    networks:
      domain-${dom_short}:
        ipv4_address: '${IPV4_NET}.4'
        aliases:
          - php
    hostname: '${domain}_fpm'
    restart: always
    volumes:
      - './data/www/:/var/www/:ro'
      - './conf/run/:/var/run:z'
      - './conf/php/:/etc/php:ro'
      - './data/log/:/var/log/gamelog:z'
    command: ['-y', '/etc/php/conf.d/php-fpm.conf', '-O']
networks:
    domain-${dom_short}:
#      enable_ipv6: true
      driver: bridge
      driver_opts:
        com.docker.network.bridge.name: br-${dom_short}
      ipam:
        driver: default
        config:
          - subnet: '${IPV4_NET}.0/29'
EOF

    echo " COPY PHP SCRIPTS NOW "
    cp -r $wwwRoot/* $DChome/data/www/
    chown -R 999:999 ${DChome}/data/
    chown -R 999:0 ${DChome}/conf/mongod/
    chmod 777 ${DChome}/data/log/$ProjName/
    chmod 666 ${DChome}/data/log/$ProjName/${dom_short}.log
    # nextStep in -- FinalForm
}

# создаем новое окружение для контейнера
ConfForm () {
    DChome=/home/$ProjName/$domain
    # Бубунта меняет название, для этого - такое извращение
    dom_short=$(echo ${domain} | tr -dc A-Za-z)
    DBPath=${DChome}/data/mongodb
    #NGINXPORT=$(( $DBPort + 13000 ))
    DBNEWPORT=$(( $DBPort + 100 ))
    MG_ADM=MonAdm
    MG_PASS=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 14)
    IPV4_NET=$( echo 172.30.$(echo $DBPort | cut -c 4,5) )

    echo "    >>>>    Now start created file    ---- 
        NETWORKS: '${IPV4_NET}.0/29'
        NGINX: ${IPV4_NET}.2
            ${DomainName}:80
            for container ${dom_short}
        MONGODB: ${IPV4_NET}.3
            port ${IPV4_NET}.3:${DBPort}
            or connect from world: ${DBNEWPORT}
         - ADM: ${MG_ADM}
         - PAS: ${MG_PASS}
         
         DOMAIN IS: ${domain}

        WORKING FOLDER IS: ${DChome}

        Cheking address (must be empty):
    `ss -tln4 | grep ${IPV4_NET}`
    `ip add | grep ${DBNEWPORT}`
        Its OK?
            (Press Ctrl+C for abort OR Enter for continue)" ; $ReadOFF read nextStep
    mkdir -p ${DChome}/conf/{nginx,mongod,php}
    tar -xzf ~/template.tgz -C ${DChome}/conf/
    mkdir -p ${DChome}/data/{www,mongodb,log}
    mkdir -p ${DChome}/data/www/html
    mkdir -p ${DChome}/data/log/$ProjName/
    touch ${DChome}/data/log/$ProjName/${dom_short}.log
    # nextStep in -- BakForm
}

# ловим плавающий порт в конфигах
FindPortProject () { 
    DBPort=$(grep "localhost" $HomeRoot/app/Database.php | awk -F: '{print $3}'| cut -c -5)
    [[ ${DBPort} == *[[:digit:]]* ]] && return
    DBPort=$(grep -A 4 db $HomeRoot/app/config/config.php | awk -F: '{print $3}' | grep 2 | cut -c -5)
    [[ ${DBPort} == *[[:digit:]]* ]] && return
    DBPort=$(grep -A 4 "mongodb" $HomeRoot/app/config/config.php | grep port | awk '{print $3}' | cut -c -5 )
}

# Запускаем проверку и парсинг конфиг файлов
CheckForm () {
    wwwRoot=$(grep -m 1 home/ /etc/nginx/sites-enabled/$domain | grep root | \
        awk {'print $2'} |rev|cut -c 2-|rev)
    DomainName=$(grep -m 1 $domain /etc/nginx/sites-enabled/* | grep server_name | \
        awk {'print $3'})
    DomainName=$(echo $DomainName |rev|cut -c 2-|rev)
    LogName=$(grep -m 1 log /etc/nginx/sites-enabled/$domain | awk '{print $2}'|rev|cut -c 2-|rev)
    FindPortProject
    DBName=$(grep $DBPort /etc/supervisor/conf.d/mongod.conf | grep -o 'replSet.*' | awk {'print $2'})
    DBPath=$(grep $DBPort /etc/supervisor/conf.d/mongod.conf | grep -o 'dbpath.*' | awk {'print $2'})
    MONGO_CACHE=$(grep $DBPort /etc/supervisor/conf.d/mongod.conf | grep -o 'wiredTigerCacheSizeGB.*' | awk {'print $2'})
    echo "    --------- CHECK FOUNDED INFO ---------------
    HOME: $HomeRoot
    DOMAIN: $DomainName
    DPATH: $DBPath
    DPORT: $DBPort 
    DNAME: $DBName"
    echo "--------- OK? ---------------" ; $ReadOFF read nextStep
}





# ------- start here -----------------------------
if [ -z $1 ] ; 
  then
    echo "    >>>>    WELCOME! Specify your project <----"
    read ProjName
    echo "    >>>>    $ProjName is a grace name! Specify old project"
    read domain
  else ProjName=$1 && domain=$2
fi
echo "    OKay! Now we need create a new docker file, for used docker-compose.
    We have old name:   $domain
    And new name:       $ProjName

"

# Приступаем к получению данных
echo "    >>>>    GET OLD ENVIRONMENT " ; CheckForm
echo "    >>>>    GENERATE NEW ENVIRONMENT " ; ConfForm
echo "    >>>>    BACKUP FILES " ; BakForm
echo "    >>>>    CREATE NEW INFRASTRUCTURE" ; CreateFileCompose
echo "    >>>>    START NEW ENVIRONMENT" ; FinalForm


echo '
+-----------------------+
|v6                     |
|        LEVkinS        |
|                   2023|
+-----------------------+
'
exit

