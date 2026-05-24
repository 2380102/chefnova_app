// backend/server.js
// Main backend file - yeh run karo: node server.js

const express = require('express');
const cors    = require('cors');
const app     = express();
const PORT    = 3000;

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/recipes',     require('./routes/recipeRoutes'));
app.use('/api/ingredients', require('./routes/ingredientRoutes'));

// Test endpoint
app.get('/', (req, res) => {
  res.json({ message: '🍽️ ChefNova Backend chal raha hai!', port: PORT });
});

app.listen(PORT, () => {
  console.log(`✅ Backend running: http://localhost:${PORT}`);
  console.log(`📌 Recipes:     http://localhost:${PORT}/api/recipes`);
  console.log(`📌 Ingredients: http://localhost:${PORT}/api/ingredients`);
});
