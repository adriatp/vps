# VPS

## Init production services

1. Crear el droplet amb docker des de la pagina web amb clau ssh pública

2. Assignar IP reservada al VPS

3. Afegir a **.ssh/config** en local connexió al VPS (usuari root)

4. Connectar al VPS i crear usuari **deploy**

```bash
adduser deploy
usermod -aG sudo deploy
usermod -aG docker deploy
mkdir -p /home/deploy/.ssh
cp /root/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
chmod 700 /home/deploy/.ssh
chmod 600 /home/deploy/.ssh/authorized_keys
```

5. Crear carpeta per stack

```bash
sudo mkdir -p /opt/stack
sudo chown -R deploy:deploy /opt/stack
sudo -R 755 /opt/stack
```

6. Clonar repositori i inicialitzar servei

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
