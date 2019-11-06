#!/bin/sh
# Alpine shell is `sh`
# Provision the environment in here!

echo "Starting app entrypoint..."

cd /var/www

echo "Ensuring laravel logs directory existence and permissions..."
mkdir -p /storage/logs
mkdir -p /storage/app/public
mkdir -p /storage/framework/cache
mkdir -p /storage/framework/sessions
mkdir -p /storage/framework/testing
mkdir -p /storage/framework/views
chown -R 1000:1000 /storage
chmod -R 0777 /storage

echo "Running artisan commands to get the app provisioned..."
php artisan cache:clear
php artisan config:clear
php artisan view:clear
php artisan migrate:fresh --seed

echo "Completed app entrypoint!"

# The container otherwise exits (code 0 correctly as the script as finished), but Docker closes the container...
# So get it to hang with the passed CMD from the dockerfile or any other args.
# https://stackoverflow.com/a/58429279/4494375
echo "Running container commands..."
exec "$@"
