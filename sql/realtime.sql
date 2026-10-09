-- Snapshot/update CDC stream is a changelog, not append-only.
-- Deduplicate by primary key using Kafka upsert semantics before event-time analytics.
SET 'execution.checkpointing.interval' = '10 s';
SET 'table.local-time-zone' = 'UTC';
CREATE TABLE payment_cdc (
 id BIGINT,
 order_id BIGINT,
 amount_cent BIGINT,
 status STRING,
 paid_at TIMESTAMP(3),
 PRIMARY KEY (id) NOT ENFORCED
) WITH (
 'connector'='upsert-kafka',
 'topic'='payment-state',
 'properties.bootstrap.servers'='redpanda:9092',
 'key.format'='json',
 'value.format'='json'
);
-- For the prototype, feed this normalized compacted topic using a separate CDC normalizer.
-- NOT the raw Debezium envelope topic.
CREATE TABLE minute_sink (
 window_start TIMESTAMP(3),
 paid_orders BIGINT,
 paid_gmv_cent BIGINT,
 PRIMARY KEY (window_start) NOT ENFORCED
) WITH (
 'connector'='doris',
 'fenodes'='doris-fe:8030',
 'table.identifier'='ecommerce.trade_minute',
 'username'='root',
 'password'='',
 'sink.label-prefix'='trade_minute'
);
-- Materialized-time aggregation over payment-state updates (not event-time windows);
-- production should support late updates / repartitioning and payment status corrections.
INSERT INTO minute_sink
SELECT
  CAST(DATE_FORMAT(paid_at, 'yyyy-MM-dd HH:mm:00') AS TIMESTAMP(3)) AS window_start,
  COUNT(*) AS paid_orders,
  SUM(amount_cent) AS paid_gmv_cent
FROM payment_cdc
WHERE status='SUCCESS'
GROUP BY CAST(DATE_FORMAT(paid_at, 'yyyy-MM-dd HH:mm:00') AS TIMESTAMP(3));
