const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

// Enable CORS for all routes
app.use(cors());

app.get('/', (req, res) => {
    res.send('Hello from Backend!');
});

app.get('/api', (req, res) => {
    res.json({ message: 'Hello from Backend API!' });
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
