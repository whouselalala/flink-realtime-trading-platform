# Flink Real-time Trading Platform — development prototype

Architecture: MySQL binlog → Debezium → Redpanda → Flink normalization → compacted `payment-state` → Flink minute aggregation → Doris. **The complete pipeline has not yet been executed or validated in Docker.**

## CDC smoke test
1. Install Docker Engine with Compose and Python 3.11.
2. `docker compose up -d mysql redpanda connect`
3. Confirm readiness: `curl -s http://localhost:8083/connectors`.
4. `curl -X POST http://localhost:8083/connectors -H 'Content-Type: application/json' --data-binary @connect/debezium-mysql.json`
5. `pip install -r requirements.txt && python scripts/seed_mysql.py`
6. `docker compose exec redpanda rpk topic consume shop.ecommerce.payments -n 5`

## Experimental full pipeline (requires image and connector verification)
1. Start services: `docker compose up -d --build`.
2. Register CDC as above.
3. Create compacted topic: `docker compose exec redpanda rpk topic create payment-state -c cleanup.policy=compact`
4. Initialize Doris: `doris/init.sql` using MySQL protocol (port 9030); verify FE/BE cluster health first.
5. Start normalizer: `docker compose exec -T jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/sql/normalize.sql`.
6. Start minute aggregation: `docker compose exec -T jobmanager /opt/flink/bin/sql-client.sh -f /opt/flink/sql/realtime.sql`.
7. Seed MySQL, then validate raw events, normalized topic, Doris totals and subsequent status updates.

Note: some images and connector jar coordinates are not verified. Compose is not claimed to run successfully as-is. In particular, the MySQL CDC event structure and Flink changelog semantics need integration validation; processing-time update aggregation does not provide late-event watermark guarantees. Refund integration and load benchmarks are pending.

## Run static checks
`python -m pytest -q` and `python scripts/check_contract.py`.

## Security
Local development only. Passwords are examples. Do not expose the database/services publicly or reuse local credentials.
