import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def test_debezium_topic_contract():
    c=json.loads((ROOT / 'connect/debezium-mysql.json').read_text())['config']
    assert c['topic.prefix']=='shop'
    assert c['table.include.list']=='ecommerce.payments'
    raw=(ROOT / 'sql/raw_debezium_debug.sql').read_text()
    assert "'topic'='shop.ecommerce.payments'" in raw

def test_aggregated_upsert_contract():
    s=(ROOT/'sql/realtime.sql').read_text()
    assert "upsert-kafka" in s
    assert "'topic'='payment-state'" in s
    assert "status='SUCCESS'" in s
