from flask import Flask, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import time

app = Flask(__name__)

REQUEST_COUNT = Counter('app_requests_total', 'Total request count', ['endpoint'])

@app.route("/")
def home():
    REQUEST_COUNT.labels(endpoint="/").inc()
    return jsonify({
        "message": "Hello from Romil's CI/CD Pipeline!",
        "status": "ok",
        "version": "3.0"
    })

@app.route("/health")
def health():
    REQUEST_COUNT.labels(endpoint="/health").inc()
    return jsonify({"status": "healthy"}), 200

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(debug=True)