const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;

// Example inventory service URL
const INVENTORY_SERVICE_URL = 'http://inventory:5000';

// Middleware
app.use(bodyParser.json());

// Routes
app.get('/', (req, res) => {
    res.send('Backend Service is up and running!');
});

// Route to get list of products
app.get('/products', async (req, res) => {
    try {
        const response = await axios.get(`${INVENTORY_SERVICE_URL}/products`);
        res.json(response.data);
    } catch (error) {
        console.error('Error fetching products from inventory service:', error);
        res.status(500).json({ error: 'Error fetching products from inventory service' });
    }
});

// Route to get details of a specific product
app.get('/products/:productId', async (req, res) => {
    const productId = req.params.productId;
    try {
        const response = await axios.get(`${INVENTORY_SERVICE_URL}/products/${productId}`);
        res.json(response.data);
    } catch (error) {
        if (error.response && error.response.status === 404) {
            res.status(404).json({ error: 'Product not found' });
        } else {
            console.error('Error fetching product details from inventory service:', error);
            res.status(500).json({ error: 'Error fetching product details from inventory service' });
        }
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
