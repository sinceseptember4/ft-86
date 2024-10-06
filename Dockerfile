# ベースイメージ
FROM php:8.2-apache

# システムパッケージのインストール
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    vim \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl bcmath gd

# Apacheのmod_rewriteを有効化
RUN a2enmod rewrite

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Node.js & npmのインストール
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# npmのキャッシュクリアと最新バージョンのインストール
RUN npm cache clean -f && npm install -g npm@latest

# Laravelの作業ディレクトリ
WORKDIR /var/www/html

# Laravelプロジェクトのインストール
RUN composer create-project --prefer-dist laravel/laravel contents

# Apacheの設定ファイルを設定
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

# 権限の設定
RUN chown -R www-data:www-data /var/www/html/contents \
    && chmod -R 755 /var/www/html/contents \
    && chmod -R 775 /var/www/html/contents/storage \
    && chmod -R 775 /var/www/html/contents/bootstrap/cache

# コンテナ内でのポートを指定
EXPOSE 80

# Apacheをフォアグラウンドで実行
CMD ["apache2-foreground"]
