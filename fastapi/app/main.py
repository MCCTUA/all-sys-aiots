from fastapi import FastAPI

app = FastAPI(title="aiots-api")


@app.get("/")
def root():
    return {"service": "aiots-api", "status": "ok"}


@app.get("/health")
def health():
    return {"status": "ok"}
