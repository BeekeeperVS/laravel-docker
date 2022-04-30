composer install
chmod -R 777 storage
chmod -R 777 bootstrap/cache
cp -rp .env.example .env
php-fpm