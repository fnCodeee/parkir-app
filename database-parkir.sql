-- MySQL dump 10.13  Distrib 8.4.11, for Linux (x86_64)
--
-- Host: localhost    Database: db_parkir
-- ------------------------------------------------------
-- Server version	8.4.11-0ubuntu0.26.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `area_parkir`
--

DROP TABLE IF EXISTS `area_parkir`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `area_parkir` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nama_area` varchar(150) NOT NULL,
  `kapasitas` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `area_parkir`
--

LOCK TABLES `area_parkir` WRITE;
/*!40000 ALTER TABLE `area_parkir` DISABLE KEYS */;
INSERT INTO `area_parkir` VALUES (1,'pom pertamina',512),(2,'West Building',128),(3,'East Building',256);
/*!40000 ALTER TABLE `area_parkir` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jenis_kendaraan`
--

DROP TABLE IF EXISTS `jenis_kendaraan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jenis_kendaraan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nama` varchar(50) NOT NULL,
  `tarif_per_jam` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jenis_kendaraan`
--

LOCK TABLES `jenis_kendaraan` WRITE;
/*!40000 ALTER TABLE `jenis_kendaraan` DISABLE KEYS */;
INSERT INTO `jenis_kendaraan` VALUES (1,'Mobil',20000),(2,'Motor',10000),(3,'Lainnya',5000);
/*!40000 ALTER TABLE `jenis_kendaraan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pemilik_kendaraan`
--

DROP TABLE IF EXISTS `pemilik_kendaraan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pemilik_kendaraan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `no_plat` varchar(50) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `nim_nip` varchar(50) NOT NULL,
  `kategori` enum('mahasiswa','dosen','staff') NOT NULL,
  `id_jenis` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `no_plat` (`no_plat`),
  KEY `fk_jenis` (`id_jenis`),
  CONSTRAINT `fk_jenis` FOREIGN KEY (`id_jenis`) REFERENCES `jenis_kendaraan` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pemilik_kendaraan`
--

LOCK TABLES `pemilik_kendaraan` WRITE;
/*!40000 ALTER TABLE `pemilik_kendaraan` DISABLE KEYS */;
INSERT INTO `pemilik_kendaraan` VALUES (6,'B 1234 CBC','Fajril Jusin','1234567890','mahasiswa',2),(7,'T 3030 CBC','Fadhil hazzanjay Jep Jep','321000123','staff',2),(8,'F  412 ATH','Faiz Atha','4112755201250113','dosen',1),(9,'T 3000 ND','M. Refa ','1234567890','mahasiswa',2);
/*!40000 ALTER TABLE `pemilik_kendaraan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaksi_parkir`
--

DROP TABLE IF EXISTS `transaksi_parkir`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaksi_parkir` (
  `id` int NOT NULL AUTO_INCREMENT,
  `no_plat` varchar(50) NOT NULL,
  `id_area` int NOT NULL,
  `waktu_masuk` datetime NOT NULL,
  `durasi_jam` int DEFAULT '0',
  `total_biaya` int DEFAULT '0',
  `waktu_keluar` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_plat` (`no_plat`),
  KEY `fk_area` (`id_area`),
  CONSTRAINT `fk_area` FOREIGN KEY (`id_area`) REFERENCES `area_parkir` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_plat` FOREIGN KEY (`no_plat`) REFERENCES `pemilik_kendaraan` (`no_plat`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaksi_parkir`
--

LOCK TABLES `transaksi_parkir` WRITE;
/*!40000 ALTER TABLE `transaksi_parkir` DISABLE KEYS */;
INSERT INTO `transaksi_parkir` VALUES (1,'B 1234 CBC',2,'2026-11-01 19:18:11',6,60000,'2026-11-01 01:18:00'),(2,'T 3030 CBC',3,'2026-11-01 19:18:23',19,190000,'2026-11-01 14:18:00'),(3,'F  412 ATH',1,'2026-11-01 19:35:51',1,20000,'2026-01-11 20:35:00'),(5,'T 3030 CBC',2,'2026-11-01 20:00:23',0,0,NULL),(6,'F  412 ATH',3,'2026-11-01 20:00:33',0,0,NULL),(7,'T 3000 ND',2,'2026-11-02 20:01:41',3,30000,'2026-11-02 23:01:00');
/*!40000 ALTER TABLE `transaksi_parkir` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-02 20:07:57
