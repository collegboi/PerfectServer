#!/bin/bash

sudo apt-get install make clang libicu-dev pkg-config libssl-dev libsasl2-dev libcurl4-openssl-dev uuid-dev git curl wget unzip -y 

cd /usr/src  
sudo wget https://swift.org/builds/swift-3.0-GM-CANDIDATE/ubuntu1510/swift-3.0-GM-CANDIDATE/swift-3.0-GM-CANDIDATE-ubuntu15.10.tar.gz  
sudo gunzip < swift-3.0-GM-CANDIDATE-ubuntu15.10.tar.gz | sudo tar -C / -xv --strip-components 1  
sudo rm -f swift-3.0-GM-CANDIDATE-ubuntu15.10.tar.gz 

swift --version

mkdir -p {running,app/.git} && cd app/.git  
git init . --bare  
cd hooks && rm -rf *.sample  

#add the contents to file
nano post-receive

chmod +x post-receive

supervisord --version

sudo apt-get install supervisor -y
service supervisor restart

cd /etc/supervisor/conf.d
sudo nano THE_APP_NAME.conf

sudo supervisorctl reread

#======================#

apt-get install libmongoc-dev libbson-dev libssl-dev

ln -s /usr/include/libmongoc-1.0/ libmongoc-1.0

sudo ln -s /usr/include/libmongoc-1.0/ /usr/local/include/libmongoc-1.0

git clone https://github.com/PerfectlySoft/PerfectTemplate.git

sudo apt-get install nginx -y

cd /etc/nginx/sites-available  
sudo rm -rf default ../sites-enabled/default  
sudo nano app.vhost

sudo ln -s /etc/nginx/sites-available/app.vhost /etc/nginx/sites-enabled/app.vhost


cd /etc/nginx  
sudo mv nginx.conf nginx.conf.backup  
sudo nano nginx.conf

sudo /etc/init.d/nginx restart

curl http://YOUR_DROPLET_IP 