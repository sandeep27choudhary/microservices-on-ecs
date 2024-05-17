# inventory_service.py
from flask import Flask, jsonify

app = Flask(__name__)

# Example inventory data
inventory_data = {
    'product1': {'name': 'Product 1', 'quantity': 10},
    'product2': {'name': 'Product 2', 'quantity': 20},
    # Add more product data as needed
}

@app.route('/products')
def get_products():
    return jsonify(inventory_data)

@app.route('/products/<product_id>')
def get_product(product_id):
    product = inventory_data.get(product_id)
    if product:
        return jsonify(product)
    else:
        return jsonify({'error': 'Product not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
