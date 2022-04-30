ifneq (,$(wildcard ./.env))
    include .env
    export
endif
define backend_ip
$$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jedidesk_backend)
endef
define mysql_ip
     $$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jedidesk_db)
endef
define nginx_ip
     $$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jedidesk_nginx)
endef
define phpmyadmin_ip
	$$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' jedidesk_phpmyadmin)
endef
define sql_create
	echo ""
endef
echo:
	echo $(call DB_PORT)
	echo 'backend: '$(call backend_ip);
	echo 'phpmyadmin: '$(call phpmyadmin_ip);
	echo 'mysql: '$(call mysql_id);
	echo 'nginx: '$(call nginx_ip);

up:
	docker-compose up -d

stop:
	docker-compose stop

build:
	make clone_project
	docker-compose build
	docker-compose up -d
	make generate_env
	make set_hosts
	make laravel_init

init:
#	sudo sed -i 's/APP_URL=http://jedidesk.local/APP_URL=http://jedidesk.localhost/' $(call APP_PATH)/.env
#	sudo sed -i '/APP_URL=http/d' $(call APP_PATH)/.env
#	echo "APP_URL=http://jedidesk.locallll" | sudo tee --append $(call APP_PATH)/.env
#	sudo sed -i '/kameron.test/d' /etc/hosts
#	echo $(call nginx_ip)" kameron.test" | sudo tee --append /etc/hosts
	docker exec -it jedidesk_backend bash -c "php artisan key:generate" www-data
	docker exec -it jedidesk_backend bash -c "php artisan storage:link" www-data
	docker exec -it jedidesk_backend bash -c "chmod -R 777 storage" www-data
	docker exec -it jedidesk_backend bash -c "chmod -R 777 bootstrap/cache" www-data
	docker exec -it jedidesk_backend bash -c "chmod -R 777 public/app-assets" www-data
	docker exec -it jedidesk_backend bash -c "php artisan view:clear" www-data
	docker exec -it jedidesk_backend bash -c "php artisan cache:clear" www-data
	docker exec -it jedidesk_backend bash -c "php artisan route:clear" www-data
	#docker exec -it jedidesk_nginx bash -c "systemctl restart nginx" www-data
	docker exec -it jedidesk_nginx nginx -s reload

laravel_init:
	docker exec -it $(call APP_NAME)"_backend" bash -c "composer install" www-data
	docker exec -it $(call APP_NAME)"_backend" bash -c "php artisan key:generate" www-data
#	docker exec -it $(call APP_NAME)"_backend" bash -c "php artisan storage:link" www-data
#	docker exec -it $(call APP_NAME)"_backend" bash -c "chmod -R 777 storage" www-data
#	docker exec -it $(call APP_NAME)"_backend" bash -c "chmod -R 777 bootstrap/cache" www-data

clone_project:
	sudo rm -rf $(call APP_PATH)
	git clone $(call APP_GIT) $(call APP_PATH)

generate_env:
	sudo apt-get install -y rpl
	cp -rp $(call APP_PATH)/.env.example $(call APP_PATH)/.env
	rpl -f "APP_NAME=Laravel" "APP_NAME="$(call APP_NAME) $(call APP_PATH)/.env
	rpl -f "APP_KEY=" "APP_KEY="$(call APP_KEY) $(call APP_PATH)/.env
	rpl -f "APP_URL=http://localhost" "APP_URL="$(call APP_URL) $(call APP_PATH)/.env
	rpl -f "DB_HOST=127.0.0.1" "DB_HOST="$(call DB_HOST) $(call APP_PATH)/.env
	rpl -f "DB_DATABASE=laravel" "DB_DATABASE="$(call DB_DATABASE) $(call APP_PATH)/.env
	rpl -f "DB_USERNAME=root" "DB_USERNAME="$(call DB_USERNAME) $(call APP_PATH)/.env
	rpl -f "DB_PASSWORD=" "DB_PASSWORD="$(call DB_PASSWORD) $(call APP_PATH)/.env

init_db:
	docker exec -it $(call APP_NAME)"_db" bash -c "mysql --user=root -e \"DROP DATABASE IF EXISTS "$(call DB_DATABASE)"; CREATE DATABASE "$(call DB_DATABASE)" CHARACTER SET utf8 COLLATE utf8_unicode_ci;\""
	docker exec -it $(call APP_NAME)"_db" bash -c "mysql --user=root "$(call DB_DATABASE)" < /dumps/"$(call DB_DUMP_APP)
	docker exec -it $(call APP_NAME)"_db" bash -c "mysql --user=root -e \"CREATE USER '"$(call DB_USERNAME)"'@'%' IDENTIFIED BY '"$(call DB_PASSWORD)"';\""
	docker exec -it $(call APP_NAME)"_db" bash -c "mysql --user=root -e \"GRANT ALL ON "$(call DB_DATABASE)".* TO '"$(call DB_USERNAME)"'@'%';\""

set_hosts:
	sudo sed -i "/# JEDIDESK HOSTS/d" /etc/hosts;
	echo "# JEDIDESK HOSTS" | sudo tee --append /etc/hosts;
	sudo sed -i "/"$(call BACKEND_HOST)"/d" /etc/hosts;
	echo $(call nginx_ip)" "$(call BACKEND_HOST) | sudo tee --append /etc/hosts;
	sudo sed -i "/"$(call PHPMYADMIN_HOST)"/d" /etc/hosts;
	echo $(call phpmyadmin_ip)" "$(call PHPMYADMIN_HOST) | sudo tee --append /etc/hosts;
