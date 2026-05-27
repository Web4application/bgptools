from fastapi import FastAPI

app = FastAPI()

@app.get("/asn/{asn}")
def get_asn(asn: int):
    return {
        "asn": asn,
        "prefixes": [],
        "neighbors": [],
        "risk_score": 0.12
    }

@app.get("/prefix/{cidr}")
def get_prefix(cidr: str):
    return {
        "prefix": cidr,
        "origin_asn": 0,
        "path": []
    }
