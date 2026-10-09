-- Debezium JSON changelog -> upsert Kafka compacted-state topic.
-- Run this job before realtime.sql and create payment-state topic with cleanup.policy=compact.
SET 'execution.checkpointing.interval' = '10 s';
SET 'table.local-time-zone' = 'UTC';
CREATE TABLE source_payments (
 id BIGINT,
 order_id BIGINT,
 amount_cent BIGINT,
 status STRING,
 paid_at TIMESTAMP(3),
 PRIMARY KEY (id) NOT ENFORCED
) WITH (
 'connector'='kafka',
 'topic'='shop.ecommerce.payments',
 'properties.bootstrap.servers'='redpanda:9092',
 'properties.group.id'='normalize-payments-v1',
 'scan.startup.mode'='earliest-offset',
 'format'='debezium-json'
);
CREATE TABLE payment_state (
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
INSERT INTO payment_state SELECT id,order_id,amount_cent,status,paid_at FROM source_payments;
