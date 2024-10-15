build:
	docker build -f Dockerfile -t php8-centerapi:latest .
	docker build -f nginx.Dockerfile -t nginx-centerapi:latest .

run:
	docker compose -f docker-compose.yml up -d php-fpm nginx --build db_mysql phpmyadmin

deps:
	docker exec -u 1000 -i php8-centerapi /bin/sh -c "composer install"
	docker exec -u 1000 -i php8-centerapi /bin/sh -c "php artisan migrate"
	docker run --rm -v .:/var/www/html -u root -i node:alpine /bin/sh -c "cd /var/www/html && npm install && npm run build"
	docker exec -u 1000 -i php8-centerapi /bin/sh -c "php artisan storage:link"

perms:
	docker exec -u root -i php8-centerapi /bin/sh -c "chown -R lempdock:www-data /var/www/*"
	docker exec -u 1000 -i php8-centerapi /bin/sh -c "chmod -R g+rw /var/www/*"

down:
	docker compose -f docker-compose.local.yml down
