from pathlib import Path
import json

def test_cdc_topic_contract():
 root = Path(__file__).resolve().parents[1]
 c = json.loads((root / 'connect/debezium-mysql.json').read_text())['config']
 assert c['topic.prefix'] == 'shop'
 assert c['table.include.list'] == 'ecommerce.payments'
 sql = (root / 'sql/realtime.sql').read_text()
 assert "'topic'='shop.ecommerce.payments'" in sql
 assert "status='SUCCESS'" in sql
