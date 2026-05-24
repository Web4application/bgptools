import time
import requests
from nacl.signing import SigningKey

HOSTNAME = "dyn.example.com"
SERVER = "http://127.0.0.1:8000/update"

# Load private key
PRIVATE_KEY_HEX = "YOUR_PRIVATE_KEY"
signing_key = SigningKey(bytes.fromhex(PRIVATE_KEY_HEX))

def get_ip():
    return requests.get("http://checkip.dns.he.net").text.strip()

ip = get_ip()
timestamp = int(time.time())

message = f"{HOSTNAME}:{ip}:{timestamp}".encode()

signature = signing_key.sign(message).signature.hex()

payload = {
    "hostname": HOSTNAME,
    "ip": ip,
    "timestamp": timestamp,
    "signature": signature
}

res = requests.post(SERVER, json=payload)
print(res.json())
