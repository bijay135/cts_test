#!/bin/bash
set -euo pipefail

# Variables
LARAVEL_HOME="/home/$USER/html/laravel"

echo "Running initialize script"

# Create folders in host and configure proper permissions
echo -e "\nCreating folders in host and configure permissions"
rm -rf $LARAVEL_HOME
mkdir -p $LARAVEL_HOME
chown $USER:$USER $LARAVEL_HOME
chmod 2775 $LARAVEL_HOME

# Configure docker-compose env and laravel with it's env
echo -e "\nConfiguring docker-compose enviroment file"
cp -af .env.dis .env
sed -i 's/$user/'"$USER"'/g' .env
echo -e "\nCloning laravel project"
git clone https://github.com/laravel/laravel.git $LARAVEL_HOME
cd $LARAVEL_HOME
echo -e "\nConfiguring laravel enviroment file"
cp -af .env.example .env
sed -i 's#^DB_HOST=.*#DB_HOST=db#' .env
sed -i 's#^DB_DATABASE=.*#DB_DATABASE=laraveldb#' .env
sed -i 's#^DB_USERNAME=.*#DB_USERNAME=laravel#' .env
sed -i 's#^DB_PASSWORD=.*#DB_PASSWORD=5hKh5EVswD#' .env

# Build app image and bring docker stack up
echo -e "\nBuilding app image"
cd -
docker-compose build
echo -e "\nStarting docker stack"
docker-compose up -d

# Install composer and generate app encryption key
echo -e "\nInstalling dependencies using composer"
docker-compose exec app rm -rf vendor composer.lock
docker-compose exec app composer install
echo -e "Generating fresh app encryption key"
docker-compose exec app php artisan key:generate

echo -e "\nInitialize script complete"
echo -e "\nApp should be browsable at http://localhost:8080"