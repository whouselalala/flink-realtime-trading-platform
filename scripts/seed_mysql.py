"""Insert deterministic fixture records against Docker MySQL (host port 3307)."""
import pymysql
conn = pymysql.connect(host='127.0.0.1', port=3307, user='root', password='rootpass', database='ecommerce', autocommit=False)
try:
 with conn.cursor() as c:
  c.executemany('INSERT INTO orders(id,user_id,created_at) VALUES(%s,%s,%s) ON DUPLICATE KEY UPDATE user_id=VALUES(user_id)', [(1,101,'2026-10-01 09:01:00'),(2,102,'2026-10-01 09:01:00'),(3,103,'2026-10-01 09:02:00')])
  c.executemany('INSERT INTO payments(id,order_id,amount_cent,status,paid_at) VALUES(%s,%s,%s,%s,%s) ON DUPLICATE KEY UPDATE status=VALUES(status)', [(1,1,12000,'SUCCESS','2026-10-01 09:01:12'),(2,2,8000,'SUCCESS','2026-10-01 09:01:25'),(3,3,5000,'FAILED','2026-10-01 09:02:20')])
 conn.commit()
 print('Seeded: 2 successful payments, total 20000 cents')
finally:
 conn.close()
