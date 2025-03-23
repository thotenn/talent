sudo add-apt-repository ppa:rabbitmq/rabbitmq-erlang
sudo apt update
sudo apt install git elixir erlang inotify-tools certbot python3-certbot-nginx


# EN CASO DE QUE LUEGO DE COMPILAR APAREZCA ALGO COMO KILLED:
# Verificar si ya existe un swap
sudo swapon --show
# Crear un archivo de 2GB para swap
sudo fallocate -l 2G /swapfile
# Establecer permisos apropiados
sudo chmod 600 /swapfile
# Formatear como espacio de swap
sudo mkswap /swapfile
# Activar el swap
sudo swapon /swapfile
# Hacer permanente el swap (agregarlo a fstab)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
# Ajustar el swappiness (valor entre 0 y 100)
sudo sysctl vm.swappiness=10
# Hacer el cambio permanente
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
### FIN
