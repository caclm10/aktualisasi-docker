# 🐳 Aktualisasi Docker

Docker configuration untuk deployment aplikasi **Aktualisasi** yang terdiri dari:

- **Backend**: Laravel (PHP 8.4-FPM)
- **Frontend**: React.js + Vite (Bun, served via Nginx)
- **Database**: MySQL 8.0

## 📋 Prerequisites

Pastikan sudah terinstall:

- [Docker](https://docs.docker.com/get-docker/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+) (jika belum terinstall, lihat dokumentasi resmi)

## 📁 Struktur Folder

Pastikan struktur folder project seperti berikut:

```
aktualisasi/
├── backend/           # Laravel app
│   ├── .env.production
│   └── ...
├── frontend/          # React.js app
│   ├── nginx.conf
│   └── ...
└── docker/            # Repository ini
    ├── .env
    ├── docker-compose.yaml
    ├── Dockerfile.backend
    ├── Dockerfile.frontend
    └── setup.sh
```

## 🚀 Quick Start

### 1. Clone Repository

- Clone ketiga repository ke dalam satu folder

```bash
mkdir aktualisasi && cd aktualisasi
```

```bash
git clone https://github.com/caclm10/aktualisasi-backend.git backend
```

```bash
git clone https://github.com/caclm10/aktualisasi-frontend.git frontend
```

```bash
git clone https://github.com/caclm10/aktualisasi-docker.git docker
```

### 2. Konfigurasi Environment

- Masuk ke folder docker

```bash
cd docker
```

- Copy file environment

```bash
cp .env.example .env
```

- Edit file `.env` dan isi dengan konfigurasi yang sesuai:

```env
# MySQL Configuration
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=aktualisasi
MYSQL_USER=aktualisasi
MYSQL_PASSWORD=your_db_password
MYSQL_PORT=3306

# Frontend Port
FRONTEND_PORT=8080
```

### 3. Siapkan Backend Environment

Pastikan file `.env.production` sudah ada di folder `backend/`

- Copy file environment backend

```bash
cp ../backend/.env.example ../backend/.env.production
```

- Contoh konfigurasi .env.production di backend

```bash
APP_ENV=production
APP_DEBUG=false
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=aktualisasi
DB_USERNAME=aktualisasi
DB_PASSWORD=your_db_password
```

### 4. Build & Run Containers

Build dan jalankan semua container

```bash
docker compose up -d --build
```

### 5. Setup Aplikasi

Setelah container berjalan, jalankan script setup:

- Berikan permission (hanya sekali untuk Linux/Mac/WSL)

```bash
chmod +x setup.sh
```

- Jalankan setup

```bash
./setup.sh
```

Script ini akan:

1. ✅ Copy file `.env` ke container backend
2. ✅ Fix permission file
3. ✅ Generate application key
4. ✅ Clear cache
5. ✅ Run database migration & seeder
6. ✅ Optimize aplikasi
7. ✅ Create storage symlink

### 6. Akses Aplikasi

Setelah setup selesai, aplikasi dapat diakses di:

| Service  | URL                   |
| -------- | --------------------- |
| Frontend | http://localhost:8080 |
| Backend  | Internal (port 9000)  |
| MySQL    | localhost:3306        |

> **Note**: Port dapat berbeda sesuai konfigurasi di file `.env`

## 🛠️ Perintah Berguna

### Container Management

```bash
# Lihat status container
docker compose ps

# Lihat logs
docker compose logs -f

# Lihat logs service tertentu
docker compose logs -f backend

# Stop semua container
docker compose down

# Stop dan hapus volume (⚠️ data akan hilang)
docker compose down -v
```

### Akses Shell Container

```bash
# Masuk ke container backend
docker compose exec backend bash

# Masuk ke container frontend
docker compose exec frontend sh

# Masuk ke MySQL
docker compose exec mysql mysql -u root -p
```

### Laravel Artisan Commands

```bash
# Jalankan artisan command
docker compose exec backend php artisan <command>

# Contoh: Clear cache
docker compose exec backend php artisan cache:clear

# Contoh: Run migration
docker compose exec backend php artisan migrate

# Contoh: Tinker
docker compose exec backend php artisan tinker
```

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────┐
│                    Docker Network                    │
│                (aktualisasi-network)                 │
│                                                      │
│  ┌──────────────┐    ┌──────────────┐    ┌────────┐  │
│  │   Frontend   │    │   Backend    │    │ MySQL  │  │
│  │    (Nginx)   │───▶│  (PHP-FPM)   │───▶│  8.0   │  │
│  │   :8080      │    │   :9000      │    │ :3306  │  │
│  └──────────────┘    └──────────────┘    └────────┘  │
│                                                      │
└──────────────────────────────────────────────────────┘
```

## 📦 Volumes

| Volume                 | Deskripsi                      |
| ---------------------- | ------------------------------ |
| `aktualisasi-database` | Data MySQL persisten           |
| `aktualisasi-storage`  | Laravel storage (uploads, dll) |

## ⚠️ Troubleshooting

### Container tidak bisa start

```bash
# Cek logs untuk error
docker compose logs backend
docker compose logs mysql

# Rebuild container
docker compose up -d --build --force-recreate
```

### Database connection refused

- Pastikan container MySQL sudah healthy
- Cek konfigurasi `DB_HOST=mysql` di `.env.production` backend
- Tunggu beberapa saat karena MySQL membutuhkan waktu untuk startup

### Permission denied pada storage

```bash
# Fix permission dari host
docker compose exec -u root backend chown -R www-data:www-data /var/www/storage
docker compose exec -u root backend chmod -R 775 /var/www/storage
```
