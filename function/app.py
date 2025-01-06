import logging
import json
import os
from datetime import datetime
from typing import List, Optional
from flask import Flask, jsonify, request
from flask_swagger_ui import get_swaggerui_blueprint

# Setup logging for debugging
logging.basicConfig(level=logging.INFO)

# Flask app setup
app = Flask(__name__)

# Explicitly set the static folder for Azure compatibility
app._static_folder = os.path.abspath('./static')

# Swagger setup
SWAGGER_URL = '/swagger'
API_URL = '/swagger.json'
swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': "Restaurant Manager API"}
)
app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

# Load restaurant data from function.json
try:
    with open('function/function.json') as f:
        function_config = json.load(f)
        restaurant_data = function_config.get("restaurantData", [])
except FileNotFoundError:
    restaurant_data = []
    logging.warning("Warning: 'function.json' not found. Loaded with empty data.")

# Class and manager definitions remain unchanged

# Routes remain unchanged

# Run as WSGI application
main = app
