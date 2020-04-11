
# !/bin/bash



echo Instalando Certificado y configurando NGINX para el dominio $1 con el correo $2
sleep 5s
apt install nginx -y
mkdir /etc/nginx/ssl
openssl dhparam -out /etc/nginx/ssl/dhp-2048.pem 2048
set -o nounset
set -o errexit
 
# May or may not have HOME set, and this drops stuff into ~/.local.
export HOME="/root"
export PATH="${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
# No package install yet.
wget https://dl.eff.org/certbot-auto
chmod a+x certbot-auto
mv certbot-auto /usr/local/bin
 
# Install the dependencies.
certbot-auto --noninteractive --os-packages-only
 
# Set up config file.
mkdir -p /etc/letsencrypt
cat > /etc/letsencrypt/cli.ini <<EOF
# Uncomment to use the staging/testing server - avoids rate limiting.
# server = https://acme-staging.api.letsencrypt.org/directory
 
# Use a 4096 bit RSA key instead of 2048.
rsa-key-size = 4096
 
# Set email and domains.
email = $2
domains = $1
 
# Text interface.
text = True
# No prompts.
non-interactive = True
# Suppress the Terms of Service agreement interaction.
agree-tos = True
 
# Use the webroot authenticator.
authenticator = webroot
webroot-path = /var/www/html
EOF
 
# Obtain cert.
certbot-auto certonly
 
# Set up daily cron job.
CRON_SCRIPT="/etc/cron.daily/certbot-renew"
 
cat > "${CRON_SCRIPT}" <<EOF
#!/bin/bash
#
# Renew the Let's Encrypt certificate if it is time. It won't do anything if
# not.
#
# This reads the standard /etc/letsencrypt/cli.ini.
#
 
# May or may not have HOME set, and this drops stuff into ~/.local.
export HOME="/root"
# PATH is never what you want it it to be in cron.
export PATH="\${PATH}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
certbot-auto --no-self-upgrade certonly
 
# If the cert updated, we need to update the services using it. E.g.:
if service --status-all | grep -Fq 'apache2'; then
  service apache2 reload
fi
if service --status-all | grep -Fq 'httpd'; then
  service httpd reload
fi
if service --status-all | grep -Fq 'nginx'; then
  service nginx reload
fi
EOF
chmod a+x "${CRON_SCRIPT}"
echo Generando archivo de configuracion para NGINX para el dominio $1   **************************
sleep 3s

#######  FALTA WGET DE ARCCHIVO DOMINIO.COM
chmod +x dominio.com


echo "***************************************************"
echo "                     * $1 *"
echo "***************************************************"
sleep 5s


cp dominio.com /etc/nginx/sites-available/$1
ln -s /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/$1

# **************** Change Variables Here ************
startdirectory="/etc/nginx/sites-available/$1"
searchterm="dominio.com"
replaceterm="$1"

i=0; 

  for file in $(grep -l -R $searchterm $startdirectory)
    do
      cp $file $file.bak
      sed -e "s/$searchterm/$replaceterm/ig" $file > tempfile.tmp
      mv tempfile.tmp $file
	/etc/init.d/nginx restart
	rm dominio.com configuracion_SSL.sh
	echo " *** Hemos terminado! *** NGINX esta configurado https://$1 ******
	
    let i++;

done
