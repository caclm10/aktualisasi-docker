#!/bin/bash

# Pastikan script ini executable untuk Linux/Mac/WSL (jalankan sekali saja):
# chmod +x setup.sh

# Hentikan script jika ada command yang error
set -e

echo "🚀 Starting Fresh Setup..."

# ==========================================
# 1. COPY FILE .ENV (Host -> Container)
# ==========================================
# Kita gunakan 'docker cp' karena perintah ini sama persis di Windows & Linux
# Beda dengan 'cat' atau 'pipe' yang kadang beda syntax.
echo "📄 Copying file .env..."
docker cp ../backend/.env.production aktualisasi-backend:/var/www/.env

# ==========================================
# 2. FIX PERMISSION
# ==========================================
# Memastikan user www-data bisa baca tulis file tersebut
echo "🔒 Fixing permission..."
docker compose exec -u root -T backend chown www-data:www-data /var/www/.env

# ==========================================
# 3. GENERATE KEY
# ==========================================
echo "🔑 Generating Application Key..."
docker compose exec -T backend php artisan key:generate

# ==========================================
# 4. RESET CACHE
# ==========================================
# Wajib dilakukan agar key baru terbaca
echo "🧹 Clearing cache config..."
docker compose exec -T backend rm -f /var/www/bootstrap/cache/config.php
docker compose exec -T backend rm -f /var/www/bootstrap/cache/packages.php
docker compose exec -T backend rm -f /var/www/bootstrap/cache/services.php

# ==========================================
# 5. DATABASE MIGRATION & SEED
# ==========================================
echo "📦 Running Migration & Seeder..."
# --force digunakan agar tidak minta konfirmasi Yes/No (langsung jalan)
docker compose exec -T backend php artisan migrate:fresh --seed --force

# ==========================================
# 5. OPTIMIZE
# ==========================================
echo "🚀 Optimizing..."
docker compose exec -T backend php artisan optimize

# ==========================================
# 7. STORAGE LINK
# ==========================================
echo "🔗 Linking Storage..."
docker compose exec -T backend php artisan storage:link

echo "✅ Done Fresh Setup!"