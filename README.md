# Task:

Develop a simple system that manages a list of restaurants and their properties. e.g., address, style (Italian, French, Korean), vegetarian (yes/no), opening hours, deliveries, etc.

 

The system will have an API for querying with a subset of these parameters and return a recommendation for a restaurant that answers the criteria, including the time of the request to check if it is open.

e.g., “A vegetarian Italian restaurant that is open now”  should return a JSON object with the restaurant and all its properties:

{

  restaurantRecommendation :

  {

    "name": "Pizza Hut",

    "style": "Italian",

    "address": "wherever street 99, somewhere",

    "openHour: "09:00",

    "clouseHour": "23:00",

    "vegetarian": false

  }

}

 

Requirements:

The assignment submission should be in a GIT repo that we can access; it could be yours or a dedicated one.
Please include all the codes required to set up the system.
The system has to be cloud-native, with a preference for Azure and a simple architecture that will require minimal maintenance.
The system should be written in full IaC style. We should be able to fully deploy it on our cloud instance without making manual changes. Use Terraform to configure the required cloud resources.
Some backend storage mechanisms should hold the history of all requests and returned responses.
Consider that the backend data stored is highly confidential.
Make sure the system is secure. However, there is no need for the user to authenticate with the system (Assume it’s a free public service)
The system code should be deployed using an automatic CI\CD pipeline following any code change, including adding or updating restaurants.
The code should be ready for code review (as possible)
Coding: Python \ PowerShell 
IaC: Terraform

# Design
Used terraform to deploy the system with this workflow .github/workflows/terraform.yaml
Added secrets to access azure, dockerhub, github-token, ssh to provisioned vm.

# Application Summary
This application provides an API to manage restaurant data. It allows users to perform the following operations:

Add a new restaurant: Allows users to add restaurant details like name, type, and location.
Query a restaurant: Allows users to retrieve information about a specific restaurant based on its unique identifier.
List all restaurants: Returns a list of all restaurants in the system.
The API provides the following endpoints:

Endpoints
POST /add_restaurant

Adds a new restaurant to the system.
Request body: Contains details of the restaurant (name, type, location).
Response: Confirmation that the restaurant has been added.
GET /query_restaurant

Retrieves details of a specific restaurant based on a unique identifier (restaurant ID).
Query parameters: id (Restaurant ID).
Response: The restaurant details if found, otherwise an error message.
GET /all_restaurants

Retrieves a list of all restaurants in the system.
Response: A JSON array containing all the restaurants' details.
How It Works
The app exposes a RESTful API that can be accessed by making HTTP requests to the defined endpoints.
The backend is built using Flask (or another relevant framework) for handling HTTP requests and processing the logic.
The data is stored in Azure Cosmos DB and accessed through the API.
Accessing Resources Through Azure Key Vault
This application securely accesses sensitive resources (such as database credentials, storage keys, and other secrets) using Azure Key Vault. The integration with Azure Key Vault ensures that sensitive information is never hardcoded in the application, which enhances security and makes it easier to manage secrets.

Steps for accessing resources through Azure Key Vault:
Azure Key Vault Setup:

The secrets, such as database connection strings and API keys, are stored in Azure Key Vault.
These secrets are referenced in the application using their respective names, which are mapped to environment variables.
Environment Variables:

The application uses environment variables (or .env files) to interact with Azure Key Vault.
Example environment variables that can be defined:
COSMOS_DB_CONNECTION_STRING: The connection string for Azure Cosmos DB.
BLOB_SAS_URL: The SAS URL for accessing Azure Blob Storage.
API_KEY: A key to interact with external APIs or services.
Azure SDK Integration:

The app uses the Azure SDK (e.g., azure-keyvault-secrets in Python) to retrieve the secrets stored in Azure Key Vault.
The SDK is configured to authenticate using Managed Identity or a Service Principal (depending on your setup).
Example Code for Retrieving Secrets from Azure Key Vault:

The following code snippet shows how the application retrieves a secret from Azure Key Vault:
python
Copy code
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

# Set up Key Vault client
key_vault_url = "https://<Your-KeyVault-Name>.vault.azure.net/"
credential = DefaultAzureCredential()
client = SecretClient(vault_url=key_vault_url, credential=credential)

# Retrieve a secret
secret_name = "COSMOS-DB-CONNECTION-STRING"
secret = client.get_secret(secret_name)

# Use the secret value (e.g., for connecting to Cosmos DB)
cosmos_db_connection_string = secret.value
Managed Identity:

If running the application in Azure, it's recommended to use Managed Identity to access the Key Vault without needing to handle credentials manually.
You can assign a Managed Identity to your app (e.g., Azure App Service, Azure VM, or Azure Function) and grant it the necessary Key Vault access policies.