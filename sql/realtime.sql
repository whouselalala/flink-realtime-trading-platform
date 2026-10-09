SET 'execution.checkpointing.interval' = '10 s';
SET 'table.local-time-zone' = 'UTC';
CREATE TABLE payment_cdc (
 id BIGINT,
 order_id BIGINT,
 amount_cent BIGINT,
 status STRING,
 paid_at TIMESTAMP(3),
 PRIMARY KEY (id) NOT ENFORCED,
 WATERMARK FOR paid_at AS paid_at - INTERVAL '5' SECOND
) WITH (
 'connector'='kafka',
 'topic'='shop.ecommerce.payments',
 'properties.bootstrap.servers'='redpanda:9092',
 'properties.group.id'='flink-payment-agg',
 'scan.startup.mode'='earliest-offset',
 'format'='debezium-json',
 'debezium-json.ignore-parse-errors'='false'
);
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
 'sink.label-prefix'='flink_trade_minute'
);
INSERT INTO minute_sink
SELECT window_start, COUNT(*) AS paid_orders, SUM(amount_cent) AS paid_gmv_cent
FROM TABLE(TUMBLE(TABLE payment_cdc, DESCRIPTOR(paid_at), INTERVAL '1' MINUTE))
WHERE status='SUCCESS'
GROUP BY window_start,window_end;
