# Parkir App

Aplikasi web sederhana untuk mengelola parkir kampus menggunakan Express, EJS,
dan MySQL.

## Fitur

- Melihat ringkasan transaksi dan pendapatan per area parkir.
- Mencatat kendaraan masuk dan kendaraan keluar.
- Menghitung biaya parkir berdasarkan jenis kendaraan dan durasi.
- Melihat serta mencari riwayat transaksi berdasarkan nomor plat.
- Menambah, mengubah, dan menghapus data pemilik kendaraan.

## Instalasi

### Prasyarat

- Node.js 20.6 atau lebih baru
- MySQL

### Langkah setup

1. Install dependensi:

   ```bash
   npm install
   ```

2. Buat database MySQL, lalu import struktur dan data awal:

   ```sql
   CREATE DATABASE db_parkir;
   ```

   ```bash
   mysql -u root -p db_parkir < database-parkir.sql
   ```

3. Salin konfigurasi environment:

   ```bash
   cp .env.example .env
   ```

   Sesuaikan nilai pada `.env` dengan konfigurasi MySQL lokal:

   ```env
   DB_HOST=localhost
   DB_USER=parkir-app
   DB_PASSWORD=parkir123
   DB_NAME=db_parkir
   ```

4. Jalankan aplikasi:

   ```bash
   node --env-file=.env app.js
   ```

   Buka [http://localhost:3000](http://localhost:3000) di browser.

## Menjalankan dengan Docker

Bagian ini menjalankan aplikasi **plus MySQL** dalam satu set container via
`docker-compose.yml` — tidak perlu install Node/MySQL manual di host.

### Struktur file Docker

| File | Fungsi |
|---|---|
| `Dockerfile` | Build image Node.js (multi-stage, Node 20) |
| `.dockerignore` | File yang tidak ikut ke dalam image build |
| `docker-compose.yml` | Service `app` + `db` (MySQL), env, healthcheck, volume |
| `docker/init/create-user.sql` | Buat user MySQL `parkir-app` saat inisialisasi pertama |
| `database-parkir.sql` | Struktur + data awal, di-import otomatis ke MySQL |

### Cara pakai (tinggal build + run pakai YML)

Prasyarat: Docker dan Docker Compose terinstall di host (Armbian).

1. **Bangun image & jalankan sekalian** (perintah tunggal):

   ```bash
   docker compose up --build -d
   ```

   atau dua langkah:

   ```bash
   docker build -t parkir-app .      # build image
   docker compose up -d              # jalankan service dari YML
   ```

2. **Tunggu container siap.** MySQL butuh waktu inisialisasi
   (import SQL + buat user) pertama kali:

   ```bash
   docker compose ps          # pastikan status db = healthy
   docker compose logs -f app # pantau log aplikasi sampai muncul "Server berjalan"
   ```

3. Buka [http://localhost:3000](http://localhost:3000).

### Mengubah kredensial / database (opsional)

`docker-compose.yml` membaca nilai default. Untuk menimpa tanpa edit file,
gunakan variabel environment saat menjalankan:

```bash
DB_USER=parkir-app DB_PASSWORD=parkir123 DB_NAME=db_parkir DB_ROOT_PASSWORD=root123 \
  docker compose up -d
```

Nilai default (jika tidak di-set):

| Variabel | Default |
|---|---|
| `DB_USER` | `parkir-app` |
| `DB_PASSWORD` | `parkir123` |
| `DB_NAME` | `db_parkir` |
| `DB_ROOT_PASSWORD` | `root123` |

> Catatan: kredensial MySQL hanya dibuat **saat volume DB pertama kali dibuat**
> (script init). Jika sudah pernah jalankan, hapus volume dulu agar perubahan
> diterapkan: `docker compose down -v`.

### Arsitektur (Armbian / ARMv8)

- Armbian berjalan di CPU ARM (biasanya ARMv8/arm64). Citra `node:20-alpine`
  dan `mysql:8.0` yang dipakai mendukung `arm64`, jadi `docker build` di Armbian
  akan menghasilkan image arm64 secara native — tidak perlu cross-build.
- Jika kamu build di mesin x86_64 lalu salin ke Armbian, gunakan buildx untuk
  target arm64: `docker buildx build --platform linux/arm64 -t parkir-app .`
  Lalu jalankan di Armbian dengan `docker compose up -d` (compose akan pull
  `mysql:8.0` versi arm64 otomatis).

### Perintah umum

| Aksi | Perintah |
|---|---|
| Cek status | `docker compose ps` |
| Lihat log | `docker compose logs -f` |
| Stop service | `docker compose stop` |
| Stop & hapus container | `docker compose down` |
| Hapus + buang data DB | `docker compose down -v` |
| Restart | `docker compose restart` |

## Cara Kerja Singkat

1. Halaman **Data Pemilik** digunakan untuk menyiapkan data kendaraan dan
   pemiliknya.
2. Halaman **Input Masuk** mencatat kendaraan dan area parkir dengan waktu
   masuk saat transaksi dibuat.
3. Halaman **Riwayat & Keluar** menampilkan transaksi. Saat kendaraan keluar,
   durasi dibulatkan ke atas dalam jam dengan minimum satu jam, kemudian biaya
   dihitung berdasarkan tarif jenis kendaraan.
4. **Dashboard** menampilkan jumlah transaksi selesai dan pendapatan, termasuk
   rekapitulasi per area parkir.

## Route Utama

| Route | Kegunaan |
|---|---|
| `/` | Dashboard |
| `/masuk` | Input kendaraan masuk |
| `/riwayat` | Riwayat dan proses kendaraan keluar |
| `/pemilik` | Kelola data pemilik kendaraan |
