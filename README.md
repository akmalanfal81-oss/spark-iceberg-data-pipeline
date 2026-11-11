# Milestone 2a: End-to-End Data Pipeline (Kafka, MinIO, Spark, Iceberg)
**Mata Kuliah:** Analitik dan Skalabilitas Data (MK35)
**Nama:** [Isi Nama Lengkap Anda]
**NIM:** [Isi NIM Anda]
**Program Studi:** Teknologi Informasi, Universitas Pendidikan Nasional

## 📌 Deskripsi Proyek
Repositori ini berisi kode dan artefak hasil praktikum integrasi data *end-to-end* (Minggu 5-7). Alur data dimulai dari *producer* yang mengirim event ke Kafka (Redpanda), dikonsumsi dan disimpan sebagai file JSONL di MinIO (raw), lalu diproses menggunakan PySpark untuk *cleaning*, analisis optimasi (Skew, Salting, Join), dan disimpan ke dalam tabel Apache Iceberg (curated).

## 📂 Struktur Folder
- `docker/`: Berisi Dockerfile untuk environment Spark dan Tools.
- `scripts/`: Berisi *source code* Python (Setup, Producer, Consumer, Spark Pipeline, Audit).
- `hasil/smoke-a/`: Berisi artefak *output* praktikum (benchmarks.csv, partition_sizes.csv, plan_*.txt, quality.json).
- `docker-compose.yml`: Konfigurasi *container*.

## 🚀 Cara Menjalankan
1. Nyalakan Docker: `docker compose up -d --build`
2. Setup bucket: `docker compose exec tools python scripts/00_setup.py`
3. Buat topik: `docker compose exec redpanda rpk topic create ecommerce.orders -p 3 -r 1`
4. Jalankan Producer: `docker compose exec tools python scripts/01_producer.py --rows 20000 --run-id smoke-a`
5. Jalankan Consumer: `docker compose exec tools python scripts/02_consumer_raw_minio.py --expected 20000 --run-id smoke-a`
6. Jalankan PySpark: `PYTHONUNBUFFERED=1 docker compose exec -it spark bash scripts/run_spark.sh --run-id smoke-a --shuffle-partitions 8 --salt-buckets 16 --pause`
7. Audit Hasil: `docker compose exec tools python scripts/05_audit_hasil.py --run-id smoke-a`

## 📊 Ringkasan Hasil
- **Kualitas Data:** 20.000 baris *raw* -> 19.960 baris *clean* (40 data dibuang karena tidak valid).
- **Data Skew:** Berhasil diatasi dengan *Key Salting*. Partisi maksimal turun dari 15.968 baris menjadi 5.611 baris yang lebih merata.
- **Join Optimization:** *BroadcastHashJoin* (0.4977s) lebih cepat dibanding *SortMergeJoin* (0.8083s) untuk tabel dimensi kecil.
- **Partition Pruning:** Berhasil memangkas pembacaan file Iceberg dari 19.960 baris menjadi hanya 666 baris saat memfilter tanggal spesifik.
