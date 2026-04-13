from flask import Flask, jsonify

app = Flask(__name__)  # ← THIS LINE IS MISSING

@app.route("/")
def home():
    return jsonify({
        "message": "Hello from Romil's CI/CD Pipeline!",
        "status": "ok",
        "version": "2.0"
    })

if __name__ == "__main__":
    app.run(debug=True)