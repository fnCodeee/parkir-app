import express from 'express'
import path from 'node:path'
import db from './config/db.js'
import { fileURLToPath } from 'node:url';
const app = express();

// Set EJS sebagai Template Engine

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Middleware Parse Form Body
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'))
// 1. DASHBOARD / INDEKS (Fitur Aggregate SUM & COUNT)
app.get('/', async (req, res) => {
    try {
        // Rekapitulasi per area parkir
        const [rekapArea] = await db.query(`
            SELECT 
                a.id,
                a.nama_area,
                a.kapasitas,
                COUNT(t.id) AS total_transaksi,
                COALESCE(SUM(t.total_biaya), 0) AS total_pendapatan
            FROM area_parkir a
            LEFT JOIN transaksi_parkir t ON a.id = t.id_area
            GROUP BY a.id, a.nama_area, a.kapasitas
        `);

        // Statistik Cepat Ringkasan
        const [[stats]] = await db.query(`
            SELECT 
                COUNT(t.id) AS total_transaksi_selesai,
                COALESCE(SUM(t.total_biaya), 0) AS total_pendapatan_keseluruhan
            FROM transaksi_parkir t
            WHERE t.waktu_keluar IS NOT NULL
        `);

        res.render('index', { rekapArea, stats });
    } catch (err) {
        console.error(err);
        res.status(500).send('Terjadi kesalahan database.');
    }
});

// 2. KENDARAAN MASUK (Form & Process INSERT)
app.get('/masuk', async (req, res) => {
    try {
        const [pemilik] = await db.query('SELECT no_plat, nama FROM pemilik_kendaraan');
        const [area] = await db.query('SELECT id, nama_area FROM area_parkir');
        res.render('masuk', { pemilik, area });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.post('/masuk', async (req, res) => {
    const { no_plat, id_area } = req.body;
    try {
        await db.query(
            'INSERT INTO transaksi_parkir (no_plat, id_area, waktu_masuk) VALUES (?, ?, NOW())',
            [no_plat, id_area]
        );
        res.redirect('/riwayat');
    } catch (err) {
        res.status(500).send('Gagal memasukkan kendaraan: ' + err.message);
    }
});

// 3. KENDARAAN KELUAR (UPDATE Jam Keluar & Hitung Biaya)
app.post('/keluar/:id', async (req, res) => {
    const idTransaksi = req.params.id;
    const body = req.body || {};
    try {
        // Ambil waktu_masuk transaksi untuk perhitungan durasi lintas hari
        const [[transaksi]] = await db.query(
            'SELECT waktu_masuk FROM transaksi_parkir WHERE id = ? AND waktu_keluar IS NULL',
            [idTransaksi]
        );
        if (!transaksi) {
            return res.status(404).send('Transaksi tidak ditemukan atau sudah selesai.');
        }

        // Validasi & bangun waktu keluar dari input terpisah: tanggal (YYYY-MM-DD) + jam (HH:mm)
        let waktuKeluarMysql;
        if (body.tanggal_keluar && body.jam_keluar) {
            // Input dari form: tanggal_keluar="2026-11-01", jam_keluar="04:18"
            const timestamp = `${body.tanggal_keluar}T${body.jam_keluar}:00`;
            const parsed = new Date(timestamp);
            if (isNaN(parsed.getTime())) {
                return res.status(400).send('Tanggal atau jam keluar tidak valid.');
            }
            const pad = (n) => String(n).padStart(2, '0');
            waktuKeluarMysql = `${parsed.getFullYear()}-${pad(parsed.getMonth() + 1)}-${pad(parsed.getDate())} `
                + `${pad(parsed.getHours())}:${pad(parsed.getMinutes())}:${pad(parsed.getSeconds())}`;
        } else {
            // Fallback: pakai waktu server saat ini
            const now = new Date();
            const pad = (n) => String(n).padStart(2, '0');
            waktuKeluarMysql = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} `
                + `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}`;
        }

        // Hitung durasi di Node.js untuk handle kasus lintas hari (selisih negatif → +24h)
        const waktuMasukDate = new Date(transaksi.waktu_masuk);
        const waktuKeluarDate = new Date(waktuKeluarMysql);
        let durasiMenit = Math.round((waktuKeluarDate - waktuMasukDate) / 60000);
        // Jika selisih negatif (waktu keluar sebelum masuk di tanggal sama),
        // interpretasikan sebagai keesokan harinya (+24 jam)
        if (durasiMenit < 0) durasiMenit += 24 * 60;
        // Minimum 1 jam (60 menit), dibulatkan ke atas ke jam penuh
        const durasiJam = Math.max(1, Math.ceil(durasiMenit / 60));

        // Query UPDATE menggunakan waktu simulasi & durasi yang sudah dihitung
        await db.query(`
            UPDATE transaksi_parkir t
            JOIN pemilik_kendaraan p ON t.no_plat = p.no_plat
            JOIN jenis_kendaraan j ON p.id_jenis = j.id
            SET 
                t.waktu_keluar = ?,
                t.durasi_jam = ?,
                t.total_biaya = ? * j.tarif_per_jam
            WHERE t.id = ? AND t.waktu_keluar IS NULL
        `, [waktuKeluarMysql, durasiJam, durasiJam, idTransaksi]);

        res.redirect('/riwayat');
    } catch (err) {
        res.status(500).send('Gagal memproses kendaraan keluar: ' + err.message);
    }
});

// 4. RIWAYAT & PENCARIAN PLAT NOMOR (READ / JOIN / SEARCH)
app.get('/riwayat', async (req, res) => {
    const searchPlat = req.query.search || '';
    try {
        const [transaksi] = await db.query(`
            SELECT 
                t.id,
                t.no_plat,
                p.nama AS nama_pemilik,
                p.kategori,
                j.nama AS jenis_kendaraan,
                a.nama_area,
                t.waktu_masuk,
                t.waktu_keluar,
                t.durasi_jam,
                t.total_biaya
            FROM transaksi_parkir t
            JOIN pemilik_kendaraan p ON t.no_plat = p.no_plat
            LEFT JOIN jenis_kendaraan j ON p.id_jenis = j.id
            JOIN area_parkir a ON t.id_area = a.id
            WHERE t.no_plat LIKE ?
            ORDER BY t.waktu_masuk DESC
        `, [`%${searchPlat}%`]);

        res.render('riwayat', { transaksi, searchPlat });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// 5. KELOLA PEMILIK KENDARAAN (CRUD Pemilik)
app.get('/pemilik', async (req, res) => {
    try {
        const [pemilik] = await db.query(`
            SELECT p.*, j.nama AS nama_jenis, 
                j.tarif_per_jam AS tarif_per_jam
            FROM pemilik_kendaraan p 
            LEFT JOIN jenis_kendaraan j ON p.id_jenis = j.id
        `);
        const [jenis] = await db.query('SELECT * FROM jenis_kendaraan');
        res.render('kendaraan', { pemilik, jenis });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.post('/pemilik/tambah', async (req, res) => {
    const { no_plat, nama, nim_nip, kategori, id_jenis } = req.body;
    try {
        await db.query(
            'INSERT INTO pemilik_kendaraan (no_plat, nama, nim_nip, kategori, id_jenis) VALUES (?, ?, ?, ?, ?)',
            [no_plat, nama, nim_nip, kategori, id_jenis]
        );
        res.redirect('/pemilik');
    } catch (err) {
        res.status(500).send('Gagal menambah pemilik: ' + err.message);
    }
});

app.post('/pemilik/hapus/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM pemilik_kendaraan WHERE id = ?', [req.params.id]);
        res.redirect('/pemilik');
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// 5b. EDIT PEMILIK KENDARAAN (Form & Process UPDATE)
app.get('/pemilik/edit/:id', async (req, res) => {
    try {
        const [[item]] = await db.query(
            `SELECT p.*, j.nama AS nama_jenis 
             FROM pemilik_kendaraan p 
             LEFT JOIN jenis_kendaraan j ON p.id_jenis = j.id
             WHERE p.id = ?`,
            [req.params.id]
        );
        if (!item) return res.status(404).send('Data tidak ditemukan.');
        const [jenis] = await db.query('SELECT * FROM jenis_kendaraan');
        res.render('kendaraan_edit', { item, jenis });
    } catch (err) {
        res.status(500).send(err.message);
    }
});

app.post('/pemilik/edit/:id', async (req, res) => {
    const { no_plat, nama, nim_nip, kategori, id_jenis } = req.body;
    try {
        await db.query(
            'UPDATE pemilik_kendaraan SET no_plat = ?, nama = ?, nim_nip = ?, kategori = ?, id_jenis = ? WHERE id = ?',
            [no_plat, nama, nim_nip, kategori, id_jenis, req.params.id]
        );
        res.redirect('/pemilik');
    } catch (err) {
        res.status(500).send('Gagal memperbarui pemilik: ' + err.message);
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server berjalan di http://localhost:${PORT}`);
});