// server.js (Backend)
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Example inventory data
const inventoryData = {
    product1: { name: 'Product 1', quantity: 10 },
    product2: { name: 'Product 2', quantity: 20 },
    // Add more product data as needed
};

// Middleware
app.use(bodyParser.json());

// Routes
app.get('/', (req, res) => {
    res.send('Backend Service is up and running!');
});

// Route to get list of products
app.get('/products', (req, res) => {
    res.json(inventoryData);
});

// Route to get details of a specific product
app.get('/products/:productId', (req, res) => {
    const productId = req.params.productId;
    const product = inventoryData[productId];
    if (product) {
        res.json(product);
    } else {
        res.status(404).json({ error: 'Product not found' });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
