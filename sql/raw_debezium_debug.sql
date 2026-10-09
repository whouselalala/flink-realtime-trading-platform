-- Raw Debezium CDC source can be inspected, but should not be fed directly
-- to append-only window aggregation when updates/deletes occur.
CREATE TABLE raw_payment_events (
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
 'scan.startup.mode'='earliest-offset',
 'format'='debezium-json'
);
SELECT * FROM raw_payment_events;
