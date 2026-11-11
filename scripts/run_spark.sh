#!/usr/bin/env bash
set -euo pipefail

RUN_ID="smoke-a"
SHUFFLE_PARTITIONS="8"
SALT_BUCKETS="16"
PAUSE_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run-id) RUN_ID="$2"; shift 2 ;;
    --shuffle-partitions) SHUFFLE_PARTITIONS="$2"; shift 2 ;;
    --salt-buckets) SALT_BUCKETS="$2"; shift 2 ;;
    --pause) PAUSE_ARGS+=(--pause); shift ;;
    --skip-iceberg) PAUSE_ARGS+=(--skip-iceberg); shift ;;
    *) echo "Argumen tidak dikenal: $1" >&2; exit 2 ;;
  esac
done

exec spark-submit \
  --master 'local[4]' \
  --packages "org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.7.1,org.apache.iceberg:iceberg-aws:1.7.1,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262,software.amazon.awssdk:bundle:2.24.6" \
  --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
  --conf spark.sql.catalog.lake=org.apache.iceberg.spark.SparkCatalog \
  --conf spark.sql.catalog.lake.type=rest \
  --conf spark.sql.catalog.lake.uri=http://rest:8181 \
  --conf spark.sql.catalog.lake.warehouse=s3://warehouse/ \
  --conf spark.sql.catalog.lake.io-impl=org.apache.iceberg.aws.s3.S3FileIO \
  --conf spark.sql.catalog.lake.s3.endpoint=http://minio:9000 \
  --conf spark.sql.catalog.lake.s3.path-style-access=true \
  --conf spark.sql.catalog.lake.s3.access-key-id=labadmin \
  --conf spark.sql.catalog.lake.s3.secret-access-key=labpassword123 \
  --conf spark.sql.catalog.lake.client.region=us-east-1 \
  --conf spark.hadoop.fs.s3a.endpoint=http://minio:9000 \
  --conf spark.hadoop.fs.s3a.access.key=labadmin \
  --conf spark.hadoop.fs.s3a.secret.key=labpassword123 \
  --conf spark.hadoop.fs.s3a.path.style.access=true \
  --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem \
  --conf spark.hadoop.fs.s3a.aws.credentials.provider=org.apache.hadoop.fs.s3a.SimpleAWSCredentialsProvider \
  /opt/lab/scripts/04_spark_pipeline.py \
  --run-id "$RUN_ID" \
  --shuffle-partitions "$SHUFFLE_PARTITIONS" \
  --salt-buckets "$SALT_BUCKETS" \
  "${PAUSE_ARGS[@]}"
