"""Static contract validation; not an end-to-end integration test."""
import json
from pathlib import Path

root=Path(__file__).resolve().parents[1]
config=json.loads((root/'connect/debezium-mysql.json').read_text())['config']
assert config['topic.prefix']=='shop'
assert config['table.include.list']=='ecommerce.payments'
sql=(root/'sql/realtime.sql').read_text()
assert "'topic'='payment-state'" in sql
assert "upsert-kafka" in sql
assert "status='SUCCESS'" in sql
print('CDC topic and SQL contracts validated')
