# VPS

## Init production services

1. Crear el droplet amb docker des de la pagina web amb clau ssh pública

2. Assignar IP reservada al VPS

3. Afegir a **.ssh/config** en local connexió al VPS (usuari root)

4. Connectar al VPS i crear usuari **deploy**

```bash
adduser deploy
usermod -aG sudo deploy
su deploy
cd ~
mkdir -p .ssh
touch .ssh/authorized_keys
chmod 700 .ssh
chmod 600 .ssh/authorized_keys
# posar clave a authorized_keys
```

5. Instalar docker

```bash
# Update system
sudo apt update
sudo apt upgrade -y

# Add dependencies
sudo apt install -y ca-certificates curl gnupg

# Add gpgp docker key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add official repo
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install docker and docker compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Check installation
docker --version
docker compose version

# Execute docker without sudo
sudo usermod -aG docker $USER
newgrp docker
```

6. Add programs to increase security

```bash
sudo apt install fail2ban
sudo systemctl enable --now fail2ban
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

8. Limit docker logs size

```bash
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker
```

9. Crear carpeta per stack

```bash
sudo mkdir -p /opt/stack
sudo chown -R deploy:deploy /opt/stack
sudo -R 755 /opt/stack
```

10. Clonar repositori i inicialitzar servei

```bash
git clone https://github.com/adriatp/vps.git
./scripts/init.sh <service_name>
# set env vars in 'out/<service_name>/.env' and 'out/<service_name>/<service_name>.env'
./scripts/run.sh <service_name>
```

## DB

### Export db

```bash
docker exec mariadb sh -c 'mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" chessdle' > "$(date +%Y%m%d%H%M%S).sql"
```

### Import db

```bash
# docker exec mariadb sh -c 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" -e "CREATE DATABASE chessdle;"'
docker exec -i mariadb sh -c 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" chessdle' < 20260714153045.sql
```
