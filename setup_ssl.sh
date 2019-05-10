#!/usr/bin/env bash

bash jms_keygen.sh
source .env

[ -f .env ] || touch .env
[ -d nginx ] || mkdir -p nginx

cat << EOF > nginx/nginx.conf
# For more information on configuration, see:                              
#   * Official English Documentation: http://nginx.org/en/docs/            
#   * Official Russian Documentation: http://nginx.org/ru/docs/            
                                                                           
user nginx;                                                                
worker_processes auto;                                                     
error_log /var/log/nginx/error.log;                                        
pid /run/nginx.pid;                                                        
                                                                           
# Load dynamic modules. See /usr/share/nginx/README.dynamic.               
include /usr/share/nginx/modules/*.conf;                                   
                                                                           
events {                                                                   
    worker_connections 1024;                                               
}                                                                          
                                                                           
http {                                                                     
    log_format  main  '\$remote_addr -  [\$time_local] "\$request" '          
                      '\$status  "\$http_referer" '                          
                      '"\$http_user_agent" "\$http_x_forwarded_for"';        
                                                                           
    access_log  /var/log/nginx/access.log  main;                           
                                                                           
    sendfile            on;                                                
    tcp_nopush          on;                                                
    tcp_nodelay         on;                                                
    keepalive_timeout   65;                                                
    types_hash_max_size 2048;                                              
    server_tokens off;                                                     
                                                                           
    include             /etc/nginx/mime.types;                             
    default_type        application/octet-stream;                          
                                                                           
    # Load modular configuration files from the /etc/nginx/conf.d directory
    # See http://nginx.org/en/docs/ngx_core_module.html#include            
    # for more information.                                                
    include /etc/nginx/conf.d/*.conf;                                      
                                                                           
    server {                                                               
        listen       80 default_server;                                    
        server_name  _;                                                    
        root         /usr/share/nginx/html;                                
        return 301   https://www.example.com\$request_uri;
                                                                           
        # Load configuration files for the default server block.           
        include /etc/nginx/default.d/*.conf;                               
              client_max_body_size 100m;                                   
                                                                           
        location /luna/ {                                                  
            try_files \$uri / /index.html;                                  
            alias /opt/luna/;                                              
        }                                                                  
                                                                           
        location /media/ {                                                 
            add_header Content-Encoding gzip;                              
            root /opt/jumpserver/data/;                                    
        }                                                                  
                                                                           
        location /static/ {                                                
            root /opt/jumpserver/data/;                                    
        }                                                                  
                                                                           
        location /socket.io/ {                                             
            proxy_pass       http://localhost:5000/socket.io/;             
            proxy_buffering off;                                           
            proxy_http_version 1.1;                                        
            proxy_set_header Upgrade \$http_upgrade;                        
            proxy_set_header Connection "upgrade";                         
            proxy_set_header X-Real-IP \$remote_addr;                       
            proxy_set_header Host \$host;                                   
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;   
            access_log off;                                                
        }                                                                  
                                                                           
        location /coco/ {                                                  
            proxy_pass       http://localhost:5000/coco/;                  
            proxy_set_header X-Real-IP \$remote_addr;                       
            proxy_set_header Host \$host;                                   
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;   
            access_log off;                                                
        }                                                                  
                                                                           
        location /guacamole/ {                                             
            proxy_pass       http://localhost:8081/;                       
            proxy_buffering off;                                           
            proxy_http_version 1.1;                                        
            proxy_set_header Upgrade \$http_upgrade;                        
            proxy_set_header Connection \$http_connection;                  
            proxy_set_header X-Real-IP \$remote_addr;                       
            proxy_set_header Host \$host;                                   
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;   
            access_log off;                                                
        }                                                                  
                                                                           
        location / {                                                       
            proxy_pass http://localhost:8080;                              
            proxy_set_header X-Real-IP \$remote_addr;                       
            proxy_set_header Host \$host;                                   
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;   
        }                                                                  
                                                                           
        error_page 404 /404.html;                                          
            location = /40x.html {                                         
        }                                                                  
                                                                           
        error_page 500 502 503 504 /50x.html;                              
            location = /50x.html {                                         
        }                                                                  
       
        listen 443 ssl; # managed by Certbot
        ssl_certificate /etc/letsencrypt/live/www.example.com/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/www.example.com/privkey.pem; # managed by Certbot
        include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    }               
}                                                                          
EOF


if [ "$EMAIL" = "" ]; then
    read -p 'input your email address: ' EMAIL
    echo "EMAIL=$EMAIL" >> .env
    echo "EMAIL: $EMAIL"
else
    echo "EMAIL: $EMAIL"
fi

if [ "$DOMAIN" = "" ]; then
    read -p 'input your web site domain: ' DOMAIN
    echo "DOMAIN=$DOMAIN" >> .env
    echo "DOMAIN: $DOMAIN"
    sed -i "s@server_name  _;@server_name  $DOMAIN;@g" nginx/nginx.conf
    sed -i "s@www.example.com@$DOMAIN;@g" nginx/nginx.conf
else
    echo "DOMAIN: $DOMAIN"
    sed -i "s@server_name  _;@server_name  $DOMAIN;@g" nginx/nginx.conf
    sed -i "s@www.example.com@$DOMAIN@g" nginx/nginx.conf
fi

[ -d letsencrypt ] || docker-compose rm -f

docker container run --interactive --detach --rm -v ${PWD}/letsencrypt/log/:/var/log/letsencrypt/ -v ${PWD}/letsencrypt/:/etc/letsencrypt/ -e EMAIL=$EMAIL -e DOMAIN=$DOMAIN -p 80:80 -p 443:443 linuxlovers/fake-certbot-nginx:latest

sed -i "s@#- \"443:443\"@- \"443:443\"@g" docker-compose.yml
sed -i "s@image: jumpserver/jms_all:1.4.10@image: linuxlovers/jms_all:latest@g" docker-compose.yml
sed -i "s@#- ./letsencrypt/:/etc/letsencrypt/@- ./letsencrypt/:/etc/letsencrypt/@g" docker-compose.yml
sed -i "s@#- ./nginx/nginx.conf:/etc/nginx/nginx.conf@- ./nginx/nginx.conf:/etc/nginx/nginx.conf@g" docker-compose.yml
