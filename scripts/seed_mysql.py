"""Seed MySQL and produce Debezium create/update events."""
import os
import pymysql

conn = pymysql.connect(
    host=os.getenv('MYSQL_HOST','127.0.0.1'),
    port=int(os.getenv('MYSQL_PORT','3307')),
    user=os.getenv('MYSQL_USER','root'),
    password=os.getenv('MYSQL_PASSWORD','rootpass'),
    database='ecommerce'
)
try:
    with conn.cursor() as c:
        c.executemany(
            "INSERT INTO orders(id,user_id,created_at) VALUES(%s,%s,%s) ON DUPLICATE KEY UPDATE user_id=VALUES(user_id)",
            [(1,101,'2026-10-01 09:01:00'),(2,102,'2026-10-01 09:01:00'),(3,103,'2026-10-01 09:02:00')]
        )
        c.executemany(
            "INSERT INTO payments(id,order_id,amount_cent,status,paid_at) VALUES(%s,%s,%s,%s,%s) "
            "ON DUPLICATE KEY UPDATE amount_cent=VALUES(amount_cent), status=VALUES(status), paid_at=VALUES(paid_at)",
            [(1,1,12000,'SUCCESS','2026-10-01 09:01:12'),(2,2,8000,'SUCCESS','2026-10-01 09:01:25'),(3,3,5000,'FAILED','2026-10-01 09:02:20')]
        )
    conn.commit()
    print('seeded two successful payments (20000 cents)')
finally:
    conn.close()
