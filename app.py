from flask import Flask, request, jsonify
import json
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)


# Function to read JSON data from file
def read_metrics_data():
    data_file = '/opt/sentinela/data.json'
    with open(data_file, 'r') as f:
        data = json.load(f)
    return data


@app.route('/', methods=['GET'])
def test_connection():
    return jsonify({"message": "Connection successful"}), 200


@app.route('/metrics', methods=['GET'])
def metrics():
    # Log client information
    client_info = request.headers.get('User-Agent')
    app.logger.info(f"Client info: {client_info}")

    # Read metrics data from file
    data = read_metrics_data()
    return jsonify(data), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
