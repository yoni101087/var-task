import os
import uuid
import json
from datetime import datetime
from typing import Optional

from flask import Flask, jsonify, request
from flask_swagger_ui import get_swaggerui_blueprint

# ---------------- Azure Key Vault / Identity ----------------
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

from azure.cosmos import CosmosClient, PartitionKey
from azure.storage.blob import ContainerClient, ContentSettings
import requests

# 1. Create Key Vault client
key_vault_url = "https://keyvault-abc12345.vault.azure.net"
credential = DefaultAzureCredential()
secret_client = SecretClient(vault_url=key_vault_url, credential=credential)

COSMOS_URL = secret_client.get_secret("COSMOS-URL").value
COSMOS_KEY = secret_client.get_secret("COSMOS-KEY").value
DATABASE_NAME = secret_client.get_secret("COSMOS-DATABASE-NAME").value
CONTAINER_NAME = secret_client.get_secret("COSMOS-CONTAINER-NAME").value

# Fetch the SAS URL for the Blob container from Key Vault
BLOB_CONTAINER_SAS_URL = secret_client.get_secret("BLOB-SAS-URL").value
BLOB_CONTAINER_NAME = secret_client.get_secret("BLOB-CONTAINER-NAME").value
GITHUB_TOKEN = secret_client.get_secret("GITHUB-TOKEN").value

# Cosmos DB client (NoSQL / SQL API)
cosmos_client = CosmosClient(url=COSMOS_URL, credential=COSMOS_KEY)
database = cosmos_client.create_database_if_not_exists(DATABASE_NAME)
container = database.create_container_if_not_exists(
    id=CONTAINER_NAME,
    partition_key=PartitionKey(path="/id")
)

# Create a ContainerClient from the container-level SAS URL
blob_container_client = ContainerClient.from_container_url(BLOB_CONTAINER_SAS_URL)

# ---------------- Restaurant Model ----------------
class Restaurant:
    def __init__(self, name, address, style, vegetarian, open_hour, close_hour, deliveries, stars):
        self.id = str(uuid.uuid4())
        self.name = name
        self.address = address
        self.style = style
        self.vegetarian = vegetarian
        self.open_hour = datetime.strptime(open_hour, "%H:%M").time()
        self.close_hour = datetime.strptime(close_hour, "%H:%M").time()
        self.deliveries = deliveries
        self.stars = stars

    def is_open(self, current_time: datetime) -> bool:
        now = current_time.time()
        return self.open_hour <= now < self.close_hour

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "address": self.address,
            "style": self.style,
            "vegetarian": self.vegetarian,
            "openHour": self.open_hour.strftime("%H:%M"),
            "closeHour": self.close_hour.strftime("%H:%M"),
            "deliveries": self.deliveries,
            "stars": self.stars,
        }

# ---------------- Flask App ----------------
app = Flask(__name__)

# Log every request to Blob Storage
@app.before_request
def log_request_to_blob():
    log_data = {
        "method": request.method,
        "path": request.path,
        "ip": request.remote_addr,
        "args": dict(request.args),
        "json": request.json if request.is_json else None,
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
    log_str = json.dumps(log_data, indent=2)
    blob_name = f"log_{uuid.uuid4()}.json"

    blob_container_client.upload_blob(
        name=blob_name,
        data=log_str,
        overwrite=False,
        content_settings=ContentSettings(content_type="application/json")
    )

# GitHub Action trigger URL
GITHUB_WEBHOOK_URL = "https://api.github.com/repos/yoni101087/var-task/dispatches"

@app.route("/add_restaurant", methods=["POST"])
def add_restaurant():
    data = request.json
    try:
        restaurant = Restaurant(
            name=data["name"],
            address=data["address"],
            style=data["style"],
            vegetarian=data["vegetarian"],
            open_hour=data["openHour"],
            close_hour=data["closeHour"],
            deliveries=data["deliveries"],
            stars=data["stars"]
        )
        container.create_item(restaurant.to_dict())

        # Trigger GitHub Action
        response = requests.post(
            GITHUB_WEBHOOK_URL,
            headers={
                "Authorization": f"Bearer {GITHUB_TOKEN}",
                "Accept": "application/vnd.github.everest-preview+json"
            },
            json={
                "event_type": "add_restaurant",
                "client_payload": {
                    "name": data["name"],
                    "address": data["address"]
                }
            }
        )

        if response.status_code == 204:
            print("GitHub Action triggered successfully.")
        else:
            print("Failed to trigger GitHub Action:", response.content)

        return jsonify({"message": "Restaurant added successfully"}), 201

    except KeyError as e:
        return jsonify({"error": f"Missing field: {e}"}), 400
    except Exception as ex:
        return jsonify({"error": str(ex)}), 400

@app.route("/query_restaurant", methods=["GET"])
def query_restaurant():
    style = request.args.get("style")
    vegetarian_str = request.args.get("vegetarian")
    open_now_str = request.args.get("openNow", "false")

    vegetarian = None
    if vegetarian_str is not None:
        vegetarian = (vegetarian_str.lower() == "true")

    open_now = (open_now_str.lower() == "true")

    query = "SELECT * FROM c"
    items = list(container.query_items(query=query, enable_cross_partition_query=True))

    current_time = datetime.now()
    for item in items:
        item_open_hour = datetime.strptime(item["openHour"], "%H:%M").time()
        item_close_hour = datetime.strptime(item["closeHour"], "%H:%M").time()

        if style and item["style"].lower() != style.lower():
            continue
        if vegetarian is not None and item["vegetarian"] != vegetarian:
            continue
        if open_now and not (item_open_hour <= current_time.time() < item_close_hour):
            continue

        return jsonify({"restaurantRecommendation": item})

    return jsonify({"restaurantRecommendation": None})

@app.route("/all_restaurants", methods=["GET"])
def all_restaurants():
    query = "SELECT * FROM c"
    items = list(container.query_items(query=query, enable_cross_partition_query=True))
    return jsonify({"restaurants": items})

SWAGGER_URL = '/swagger'
API_URL = '/swagger.json'
swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={'app_name': "Restaurant Manager API"}
)
app.register_blueprint(swaggerui_blueprint, url_prefix=SWAGGER_URL)

@app.route("/swagger.json", methods=["GET"])
def swagger_spec():
    return jsonify({
        "swagger": "2.0",
        "info": {
            "title": "Restaurant Manager API",
            "description": "API for managing and querying restaurants",
            "version": "1.0.0"
        },
        "basePath": "/",
        "paths": {
            "/add_restaurant": {
                "post": {
                    "summary": "Add a restaurant",
                    "description": "Add a new restaurant to the database.",
                    "parameters": [
                        {
                            "name": "body",
                            "in": "body",
                            "required": True,
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "name": {"type": "string"},
                                    "address": {"type": "string"},
                                    "style": {"type": "string"},
                                    "vegetarian": {"type": "boolean"},
                                    "openHour": {"type": "string"},
                                    "closeHour": {"type": "string"},
                                    "deliveries": {"type": "boolean"},
                                    "stars": {"type": "number"}
                                },
                                "required": [
                                    "name", 
                                    "address", 
                                    "style", 
                                    "vegetarian", 
                                    "openHour", 
                                    "closeHour", 
                                    "deliveries", 
                                    "stars"
                                ]
                            }
                        }
                    ],
                    "responses": {
                        "201": {"description": "Restaurant added successfully"},
                        "400": {"description": "Invalid input"}
                    }
                }
            },
            "/query_restaurant": {
                "get": {
                    "summary": "Query a restaurant",
                    "description": "Retrieve a restaurant recommendation based on criteria.",
                    "parameters": [
                        {"name": "style", "in": "query", "type": "string", "required": False},
                        {"name": "vegetarian", "in": "query", "type": "boolean", "required": False},
                        {"name": "openNow", "in": "query", "type": "boolean", "required": False}
                    ],
                    "responses": {
                        "200": {
                            "description": "Successful response",
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "restaurantRecommendation": {
                                        "type": "object",
                                        "properties": {
                                            "id": {"type": "string"},
                                            "name": {"type": "string"},
                                            "style": {"type": "string"},
                                            "address": {"type": "string"},
                                            "openHour": {"type": "string"},
                                            "closeHour": {"type": "string"},
                                            "vegetarian": {"type": "boolean"},
                                            "deliveries": {"type": "boolean"},
                                            "stars": {"type": "number"}
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            },
            "/all_restaurants": {
                "get": {
                    "summary": "Get all restaurants",
                    "description": "Returns a list of all restaurants in the database.",
                    "responses": {
                        "200": {
                            "description": "Successful response",
                            "schema": {
                                "type": "object",
                                "properties": {
                                    "restaurants": {
                                        "type": "array",
                                        "items": {
                                            "type": "object",
                                            "properties": {
                                                "id": {"type": "string"},
                                                "name": {"type": "string"},
                                                "address": {"type": "string"},
                                                "style": {"type": "string"},
                                                "openHour": {"type": "string"},
                                                "closeHour": {"type": "string"},
                                                "vegetarian": {"type": "boolean"},
                                                "deliveries": {"type": "boolean"},
                                                "stars": {"type": "number"}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)