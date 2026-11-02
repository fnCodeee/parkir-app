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
