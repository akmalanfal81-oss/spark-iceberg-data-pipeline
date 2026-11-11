# Milestone 2a: Integrasi Kafka, MinIO, Spark & Iceberg
**Mata Kuliah:** Analitik dan Skalabilitas Data (MK35)
**Nama:** [Isi Nama Lengkap Anda]
**NIM:** [Isi NIM Anda]
**Program Studi:** Teknologi Informasi, Universitas Pendidikan Nasional
**Run ID:** smoke-a

## 📌 Deskripsi Proyek
Repositori ini berisi kode dan artefak hasil praktikum integrasi data *end-to-end* dari Minggu 5 hingga Minggu 7. Alur data dimulai dari *producer* yang mengirim event ke Kafka (Redpanda), dikonsumsi dan disimpan sebagai file JSONL di MinIO (raw), lalu diproses menggunakan PySpark untuk *cleaning*, analisis optimasi (Skew, Salting, Join), dan disimpan ke dalam tabel Apache Iceberg (curated).

## 📂 Struktur Folder
- `docker/`: Berisi Dockerfile untuk environment Spark dan Tools.
- `scripts/`: Berisi *source code* Python (Producer, Consumer, Setup MinIO, Spark Pipeline, Audit).
- `hasil/smoke-a/`: Berisi artefak *output* praktikum (benchmarks.csv, partition_sizes.csv, plan_*.txt, quality.json).
- `docker-compose.yml`: Konfigurasi *container* (Redpanda, MinIO, Iceberg REST, Spark).

## 🚀 Cara Menjalankan (Smoke Test 20.000 baris)
1. Jalankan seluruh *service*: `docker compose up -d --build`
2. Setup bucket MinIO: `docker compose exec tools python scripts/00_setup.py`
3. Buat topik Kafka: `docker compose exec redpanda rpk topic create ecommerce.orders -p 3 -r 1`
4. Jalankan Producer: `docker compose exec tools python scripts/01_producer.py --rows 20000 --run-id smoke-a`
5. Jalankan Consumer: `docker compose exec tools python scripts/02_consumer_raw_minio.py --expected 20000 --run-id smoke-a`
6. Jalankan PySpark (dengan mode pause untuk melihat UI): 
   `PYTHONUNBUFFERED=1 docker compose exec -it spark bash scripts/run_spark.sh --run-id smoke-a --shuffle-partitions 8 --salt-buckets 16 --pause`
7. Audit Hasil: `docker compose exec tools python scripts/05_audit_hasil.py --run-id smoke-a`

## 📊 Ringkasan Hasil
- **Raw Count:** 20.000 baris
- **Clean Count:** 19.960 baris (40 data tidak valid/dihapus)
- **Data Skew:** Berhasil diatasi menggunakan teknik *Key Salting* (Partisi maksimal turun dari 15.968 menjadi 5.611 baris).
- **Join Optimization:** *BroadcastHashJoin* lebih cepat (0.4977s) dibanding *SortMergeJoin* (0.8083s) untuk tabel dimensi kecil.
- **Partition Pruning:** Berhasil memangkas pembacaan file Iceberg untuk filter tanggal spesifik.

*(Laporan analisis lengkap dapat dilihat pada file PDF yang dilampirkan di LMS)*
