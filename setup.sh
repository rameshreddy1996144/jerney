#!/bin/bash
#====================================
# Jerney Blog Application - ec2 setup script
# Run this script on ubuntu ec2 instance
# ====================================
 


 Set -e 

 echo "Setting up jerney Blog Application... "
 echo "=================================="

 # --- Update system services ---
 echo "updating system packages"
 sudo apt update && apt sudo upgrade -y


 # --- Start application ---

 # --- Install Dependencies and prerequisites ---

 # --- Install backend service ---



 # --- Install Node.js 20.x... ----
 
 echo "Insatlling Node.js 20.x.. ."
 curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
 sudo apt install -y nodejs

 echo "Node.js version: $(node -v)"
 echo "npm version": $(npm -v)


 # ---- Install PostgreSQL ----
 echo "Installig PostgreSQL..."
 sudo apt install -y postgresql postgresql-contrib


 # --- Install Nginx ---
 echo "Installing  Nginx..."
 sudo apt install -y nginx


 # ---Installing PM2 (Process Manger) ---
 echo "Installing Process manager..."
 sudo npm install -g pm2


 # --- Configure PostgreSQL ---
 echo "onfigure PostgreSQL..."

 sudo -u postgres psql <<EOF
 CREATE USER jerney_user WITH PASSWORD 'jerney_pass_2026';
 CREATE DATABASE jerney_db OWNER jerney_user;
 GRANT ALL PRIVILEGES ON DATABASE jerney_db TO jerney_user;
 \c jerney_db
 GRANT ALL ON SCHEMA public TO jerney_user;
 EOF


 echo "PostgreSQL configured"


 # --- Set up Project Directory ---

 echo "Setting up project ..."

 sudo mkdir -p /var/www/jerney
 sudo chown -R $USER:$USER /var/www/jerney/

 # --- Copy projects files (assume you have transferred src to ~/jerney)

 cp -r ~/jerney/* /var/www/jerney/

 # ---Install backend dependencies ---
 echo "Installing backend dependencieson "
 cd /var/www/jerney/backend
 npm insatll --production


 # --- Build frontend ---
 echo "Building frontend ..."

 npm install
 npm run build


 # --- Configure Nginx ----

 echo "Configure Nginx..."
sudo cp /var/www/jerney/deploy/jerney-nginx.conf /etc/nginx/sites-available/jerney
sudo ln -sf /etc/nginx/sites-available/jerney /etc/nginx/sites-enabled/jerney
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx


# --- Start backend with PM2 ---
echo " Starting backend with PM2..."
cd /var/www/jerney/backend
pm2 start src/index.js --name jerney-backend
pm2 save
pm2 startup systemd -u $USER --hp /home/$USER | tail -1 | sudo bash


echo ""
echo "==========================================="
echo "🎉 Jerney is now live!"
echo "==========================================="
echo ""
echo "Access your blog at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo '<your-ec2-public-ip>')"
echo ""
echo "Useful commands:"
echo "  pm2 status          - Check backend status"
echo "  pm2 logs            - View backend logs"
echo "  pm2 restart all     - Restart backend"
echo "  sudo systemctl restart nginx - Restart Nginx"
echo ""