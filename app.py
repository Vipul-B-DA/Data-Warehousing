from flask import Flask, jsonify
from sqlalchemy import create_engine, text
from flask import request
from pydantic import BaseModel, ValidationError
from flask import abort 
import os
from dotenv import load_dotenv

load_dotenv()


# --- 1. Initialize the Flask App ---
app = Flask(__name__)

# --- 2. Configure the Database Connection using SQLAlchemy ---
# !! IMPORTANT: Replace with your actual server details, username, and password !!
# SQL Server Authentication is more straightforward for cross-platform connections.
server = 'localhost'
database = 'DataWarehouse'
username = 'SA'
password = os.getenv('DB_PASSWORD')
driver = 'ODBC Driver 17 for SQL Server' # This must match the driver you installed

# This is the SQLAlchemy connection string (URI)
connection_uri = f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver={driver}'

# Create the SQLAlchemy engine
engine = create_engine(connection_uri)


# Added the Pydantic model definition
class ProductModel(BaseModel):
    product_name: str
    category: str

# Error Handling and Enhanced Validation
@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not Found", "message": "The requested URL was not found on the server."}), 404

@app.errorhandler(400)
def bad_request(error):
    # For validation errors, we can pass a more specific message
    message = error.description if error.description else "The browser (or proxy) sent a request that this server could not understand."
    return jsonify({"error": "Bad Request", "message": message}), 400

# --- 3. Create API Endpoints ---
@app.route('/api/products', methods=['GET'])
def get_products():
    """Returns a list of products from the Gold layer."""
    query = text("SELECT product_key, product_name, category FROM gold.report_products")
    
    try:
        with engine.connect() as connection:
            result = connection.execute(query)
            # The .mappings().all() method conveniently returns a list of dictionaries
            list_of_dicts = [dict(row) for row in result.mappings()]
        return jsonify(list_of_dicts)
    except Exception as e:
        # Basic error handling
        return jsonify({"error": str(e)}), 500


@app.route('/api/customers/<string:segment>', methods=['GET'])
def get_customers_by_segment(segment):
    """Returns a list of customers belonging to a specific segment."""
    # Using parameters in a query safely prevents SQL injection
    query = text("SELECT customer_number, customer_name, Age_Group, customer_segment FROM gold.report_customers WHERE customer_segment = :seg")
    
    try:
        with engine.connect() as connection:
            result = connection.execute(query, {"seg": segment})
            list_of_dicts = [dict(row) for row in result.mappings()]
            
        if not list_of_dicts:
            return jsonify({"message": f"No customers found for segment: {segment}"}), 404
            
        return jsonify(list_of_dicts)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route('/')
def index():
    return "Welcome to your SQL Data API!"


# --- 4. CREATE a new product ---
@app.route('/api/products', methods=['POST'])
def create_product():
    try:
        # Validate the incoming JSON using the Pydantic model
        product_data = ProductModel(**request.get_json())
    except ValidationError as e:
        # If validation fails, abort with a 400 error and the validation message
        abort(400, description=str(e))

    sql = text("INSERT INTO gold.report_products (product_name, category) VALUES (:name, :category)")
    with engine.connect() as connection:
        connection.execute(sql, {"name": product_data.product_name, "category": product_data.category})
        connection.commit()
    return jsonify({"message": "Product created successfully"}), 201


# --- 5. READ a single product by its ID ---
@app.route('/api/products/<int:product_key>', methods=['GET'])
def get_product_by_id(product_key):
    sql = text("SELECT * FROM gold.report_products WHERE product_key = :key")
    with engine.connect() as connection:
        result = connection.execute(sql, {"key": product_key}).mappings().first()
    if result:
        return jsonify(dict(result))
    else:
        abort(404) # If no product is found, return a 404 error


# --- 6. UPDATE an existing product ---
@app.route('/api/products/<int:product_key>', methods=['PUT'])
def update_product(product_key):
    try:
        product_data = ProductModel(**request.get_json())
    except ValidationError as e:
        abort(400, description=str(e))
    
    sql = text("UPDATE gold.report_products SET product_name = :name, category = :category WHERE product_key = :key")
    with engine.connect() as connection:
        result = connection.execute(sql, {"name": product_data.product_name, "category": product_data.category, "key": product_key})
        connection.commit()
    if result.rowcount == 0:
        abort(404) # The product key to update was not found
    return jsonify({"message": "Product updated successfully"})


# --- 7. DELETE a product ---
@app.route('/api/products/<int:product_key>', methods=['DELETE'])
def delete_product(product_key):
    sql = text("DELETE FROM gold.report_products WHERE product_key = :key")
    with engine.connect() as connection:
        result = connection.execute(sql, {"key": product_key})
        connection.commit()
    if result.rowcount == 0:
        abort(404) # The product key to delete was not found
    return jsonify({"message": "Product deleted successfully"})


# --- Run the App ---
if __name__ == '__main__':
    app.run(debug=True, port=5001)