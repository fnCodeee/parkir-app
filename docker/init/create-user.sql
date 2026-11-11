-- Init script yang dijalankan oleh entrypoint MySQL (hanya saat volume DB kosong / pertama kali).
-- Membuat user aplikasi + privilege, sesuai dengan .env.example (parkir-app / parkir123).

CREATE USER IF NOT EXISTS 'parkir-app'@'%' IDENTIFIED BY 'parkir123';
GRANT ALL PRIVILEGES ON db_parkir.* TO 'parkir-app'@'%';
FLUSH PRIVILEGES;
