# Flink Real-time Trading Analytics

Reference integration: MySQL binlog CDC -> Redpanda (Kafka) -> Flink SQL -> Doris. **End-to-end Docker Compose deployment and connector compatibility have not yet been verified.**

1. `docker compose up -d --build`
2. `curl -X POST http://localhost:8083/connectors -H 'Content-Type: application/json' -d @connect/debezium-mysql.json`
3. Create Doris target using `doris/init.sql` via FE port 9030.
4. `docker compose exec -T jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/sql/realtime.sql`
5. `pip install -r requirements.txt && python scripts/seed_mysql.py`

Local example only, not production-hardened.