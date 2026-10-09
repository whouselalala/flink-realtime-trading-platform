CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;
CREATE TABLE IF NOT EXISTS trade_minute (
 window_start DATETIME NOT NULL, paid_orders BIGINT, paid_gmv_cent BIGINT
) UNIQUE KEY(window_start)
DISTRIBUTED BY HASH(window_start) BUCKETS 1
PROPERTIES ("replication_num"="1");
