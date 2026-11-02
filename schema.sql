-- Sistem Parkir Kampus - Skema Database db_parkir
-- Jalankan: mysql -u root -p < schema.sql (pilih database db_parkir)

-- Tabel Jenis Kendaraan (1 ke banyak -> pemilik_kendaraan)
CREATE TABLE jenis_kendaraan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    tarif_per_jam INT NOT NULL
);

-- Tabel Area Parkir (1 ke banyak -> transaksi_parkir)
CREATE TABLE area_parkir (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nama_area VARCHAR(100) NOT NULL,
    kapasitas INT NOT NULL
);

-- Tabel Pemilik Kendaraan
CREATE TABLE pemilik_kendaraan (
    id INT AUTO_INCREMENT PRIMARY KEY,
    no_plat VARCHAR(50) NOT NULL UNIQUE,
    nama VARCHAR(100) NOT NULL,
    nim_nip VARCHAR(50) NOT NULL,
    kategori ENUM('mahasiswa','dosen','staff') NOT NULL,
    id_jenis INT,
    CONSTRAINT fk_jenis FOREIGN KEY (id_jenis)
        REFERENCES jenis_kendaraan(id) ON DELETE CASCADE
);

-- Tabel Transaksi Parkir
CREATE TABLE transaksi_parkir (
    id INT AUTO_INCREMENT PRIMARY KEY,
    no_plat VARCHAR(50) NOT NULL,
    id_area INT NOT NULL,
    waktu_masuk DATETIME NOT NULL,
    waktu_keluar DATETIME NULL,
    durasi_jam INT NULL,
    total_biaya INT NULL,
    CONSTRAINT fk_area FOREIGN KEY (id_area)
        REFERENCES area_parkir(id) ON DELETE CASCADE
);

-- Data awal
INSERT INTO jenis_kendaraan (nama, tarif_per_jam) VALUES
    ('Mobil', 20000),
    ('Motor', 10000),
    ('Lainnya', 5000);

INSERT INTO area_parkir (nama_area, kapasitas) VALUES
    ('Area A - Depan Gedung Fakultas', 50),
    ('Area B - Samping Masjid', 30),
    ('Area C - Lapangan Parkir Utama', 100);
