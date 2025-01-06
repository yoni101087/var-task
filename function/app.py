import json
from datetime import datetime
from typing import List, Optional
from flask import Flask, jsonify, request
from flask_swagger_ui import get_swaggerui_blueprint

# Class to define a Restaurant with necessary attributes
class Restaurant:
    def __init__(self, name: str, address: str, style: str, vegetarian: bool,
                 open_hour: str, close_hour: str, deliveries: bool, stars: float):
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

# Manager to handle the list of restaurants
class RestaurantManager:
    def __init__(self, restaurant_data):
        self.restaurants: List[Restaurant] = [Restaurant(
            name=entry["name"],
            address=entry["address"],
            style=entry["style"],
            vegetarian=entry["vegetarian"],
            open_hour=entry["openHour"],
            close_hour=entry["closeHour"],
            deliveries=entry["deliveries"],
            stars=entry["stars"]
        ) for entry in restaurant_data]

    def query_restaurant(self, style: Optional[str] = None, vegetarian: Optional[bool] = None,
                         open_now: bool = False, current_time: Optional[datetime] = None) -> Optional[dict]:
        current_time = current_time or datetime.now()
        for restaurant in self.restaurants:
            if style and restaurant.style.lower() != style.lower():
                continue
            if vegetarian is not None and restaurant.vegetarian != vegetarian:
                continue
            if open_now and not restaurant.is_open(current_time):
                continue
            return {
                "restaurantRecommendation": {
                    "name": restaurant.name,
                    "style": restaurant.style,
                    "address": restaurant.address,
                    "openHour": restaurant.open_hour.strftime("%H:%M"),
                    "closeHour": restaurant.close_hour.strftime("%H:%M"),
                    "vegetarian": restaurant.vegetarian,
                    "deliveries": restaurant.deliveries,
                    "stars": restaurant.stars
                }
            }
        return {"restaurantRecommendation": None}

# Flask app setup
app = Flask(__name__)

# Load restaurant data from function.json
with open('function/function.json') as f:
    function_config = json.load(f)
    restaurant_data = function_config.get("restaurantData", [])

# Pass the restaurant data to the RestaurantManager
manager = RestaurantManager(restaurant_data)

# Swagger setup
SWAGGER_URL = '/swagger'
API_URL = '/swagger.json'
swaggerui_blueprint = get_swaggerui_blueprint(
    SWAGGER_URL,
    API_URL,
    config={
        'app_name': "Restaurant Manager API"
    }
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
            }
        }
    })

@app.route("/query_restaurant", methods=["GET"])
def query_restaurant():
    style = request.args.get("style")
    vegetarian = request.args.get("vegetarian")
    open_now = request.args.get("openNow", "false").lower() == "true"
    
    if vegetarian is not None:
        vegetarian = vegetarian.lower() == "true"
    
    current_time = datetime.now()
    result = manager.query_restaurant(style=style, vegetarian=vegetarian, open_now=open_now, current_time=current_time)
    return jsonify(result)

@app.route("/all_restaurants", methods=["GET"])
def all_restaurants():
    all_restaurants_data = [
        {
            "name": restaurant.name,
            "address": restaurant.address,
            "style": restaurant.style,
            "vegetarian": restaurant.vegetarian,
            "openHour": restaurant.open_hour.strftime("%H:%M"),
            "closeHour": restaurant.close_hour.strftime("%H:%M"),
            "deliveries": restaurant.deliveries,
            "stars": restaurant.stars
        }
        for restaurant in manager.restaurants
    ]
    return jsonify({"restaurants": all_restaurants_data})

# Run the Flask app (this starts the web server)
if __name__ == "__main__":
    app.run(debug=True)