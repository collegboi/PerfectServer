#!/bin/bash
#======================#
#====Creating New======#
#======================#

useradd -d /home/USERNAME -m -s /bin/bash USERNAME  
echo "USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers  

passwd USERNAME  

#======================#
#====Init server=======#
#======================#

export LC_ALL="en_US.UTF-8"  
export LC_CTYPE="en_US.UTF-8"  
sudo dpkg-reconfigure locales  
sudo apt-get update  
sudo apt-get upgrade -y

#======================#
#====SFTP package======#
#======================#


sudo apt-get install expect

#======================#
#====lib dependencies==#
#======================#

# if [ $(dpkg-query -W -f='${Status}' nano 2>/dev/null | grep -c "ok installed") -eq 0 ];
# then
#   apt-get install nano;
# fi

sudo apt-get install make clang libicu-dev pkg-config libssl-dev libsasl2-dev libcurl4-openssl-dev uuid-dev git curl wget unzip -y 

sudo apt-get install libminizip-dev

#======================#
#====swift installed===#
#======================#

cd /usr/src  
echo "Downloading Swift..."
sudo wget https://swift.org/builds/swift-3.0.2-release/ubuntu1604/swift-3.0.2-RELEASE/swift-3.0.2-RELEASE-ubuntu16.04.tar.gz
sudo gunzip < swift-3.0.2-RELEASE-ubuntu16.04.tar.gz | sudo tar -C / -xv --strip-components 1  
sudo rm -f swift-3.0.2-RELEASE-ubuntu16.04.tar.gz

# swift --version | grep 'Swift version' | awk '{print $3}'

if [ $(swift --version | grep 'Swift version') == "3.0.2"];
then
    echo "Swift installed";
fi

#MongoDB installation

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update

sudo apt-get install -y mongodb-org
echo "Installing MongoDB..."

sudo nano /etc/systemd/system/mongodb.service

# [Unit]
# Description=High-performance, schema-free document-oriented database
# After=network.target

# [Service]
# User=mongodb
# ExecStart=/usr/bin/mongod --quiet --config /etc/mongod.conf

# [Install]
# WantedBy=multi-user.target

echo "Starting MongoDB..."
sudo systemctl start mongodb

sudo systemctl status mongodb
#Active: active (running)

mkdir -p {running,app/.git} && cd app/.git  
git init . --bare  
cd hooks && rm -rf *.sample  

#add the contents to file
nano post-receive

chmod +x post-receive

supervisord --version # check if installed

sudo apt-get install supervisor -y
service supervisor restart

cd /etc/supervisor/conf.d
sudo nano THE_APP_NAME.conf

sudo supervisorctl reread

sudo supervisorctl reload

#======================#
#==swift dependencies==#
#======================#


sudo apt-get install libmongoc-dev libbson-dev libssl-dev

ln -s /usr/include/libmongoc-1.0/ libmongoc-1.0

sudo ln -s /usr/include/libmongoc-1.0/ /usr/local/include/libmongoc-1.0

git clone https://github.com/PerfectlySoft/PerfectTemplate.git

cd PerfectServer
sudo swift build

git remote add LIVE ssh://collegboi@128.199.54.34/home/collegboi/app/.git

sudo apt-get install nginx -y

cd /etc/nginx/sites-available  
sudo rm -rf default ../sites-enabled/default  
sudo nano app.vhost

sudo ln -s /etc/nginx/sites-available/app.vhost /etc/nginx/sites-enabled/app.vhost

#======================#
#====nginx installed===#
#======================#


cd /etc/nginx  
sudo mv nginx.conf nginx.conf.backup  
sudo nano nginx.conf

sudo /etc/init.d/nginx restart

curl http://YOUR_DROPLET_IP

apt-get install libminizip-dev

#======================#
#====SSL cert==========#
#======================#

sudo apt-get install letsencrypt

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.csr

sudo nano /etc/nginx/snippets/self-signed.conf

ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

sudo nano /etc/nginx/snippets/ssl-params.conf

# # from https://cipherli.st/
# # and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

# ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
# ssl_prefer_server_ciphers on;
# ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
# ssl_ecdh_curve secp384r1;
# ssl_session_cache shared:SSL:10m;
# ssl_session_tickets off;
# ssl_stapling on;
# ssl_stapling_verify on;
# resolver 8.8.8.8 8.8.4.4 valid=300s;
# resolver_timeout 5s;
# # Disable preloading HSTS for now.  You can use the commented out header line that includes
# # the "preload" directive if you understand the implications.
# #add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
# add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
# add_header X-Frame-Options DENY;
# add_header X-Content-Type-Options nosniff;

# ssl_dhparam /etc/ssl/certs/dhparam.pem;

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

curl -X POST -H 'Content-Type: application/json' -d '{"username":"admin","password":"admin"}' http://perfectserver.site/storage/Users


# server {
#     listen 80 default_server;
#     listen [::]:80 default_server;
#     listen 443 ssl http2 default_server;
#     listen [::]:443 ssl http2 default_server;

#     server_name server_domain_or_IP;
#     include snippets/self-signed.conf;
#     include snippets/ssl-params.conf;

#     . . .

#http://perfectserver.site

openssl req  -newkey rsa:2048 -nodes -keyout /etc/nginx/ssl/perfectserver.key -out /etc/nginx/ssl/perfectserver.csr