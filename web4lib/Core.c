
app = FastAPI()

# -------------------------
# REGISTERED DEVICE KEYS
# -------------------------
DEVICE_KEYS = {
    "bgp.he.net": bytes.fromhex("PUT_PUBLIC_KEY_HERE")
}

# -------------------------
# HE.NET CONFIG
# -------------------------
HE_PASSWORD = "YOUR_HE_DDNS_PASSWORD"
HE_ENDPOINT = "https://dyn.bgp.he.net/nic/update"


# -------------------------
# REQUEST MODEL
# -------------------------
class DDNSRequest(BaseModel):
    hostname: str
    ip: str
    timestamp: int
    signature: str


# -------------------------
# VERIFY SIGNATURE
# -------------------------
def verify_signature(public_key, message, signature):
    try:
        vk = VerifyKey(public_key)
        vk.verify(message, bytes.fromhex(signature))
        return True
    except Exception:
        return False


# -------------------------
# UPDATE ROUTE
# -------------------------
@app.post("/update")
def update_dns(req: DDNSRequest):

    # 1. Check device exists
    if req.hostname not in DEVICE_KEYS:
        raise HTTPException(status_code=403, detail="Unknown device")

    public_key = DEVICE_KEYS[req.hostname]

    # 2. Replay protection (30 sec window)
    if abs(time.time() - req.timestamp) > 30:
        raise HTTPException(status_code=403, detail="Request expired")

    # 3. Build signed message
    message = f"{req.hostname}:{req.ip}:{req.timestamp}".encode()

    # 4. Verify signature
    if not verify_signature(public_key, message, req.signature):
        raise HTTPException(status_code=403, detail="Invalid signature")

    # 5. Call HE.net DDNS
    response = requests.get(
        HE_ENDPOINT,
        params={
            "hostname": req.hostname,
            "password": HE_PASSWORD,
            "myip": req.ip
        }
    )

    return {
        "status": "updated",
        "he_response": response.text
    }
