

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
  console.log(`✅ Backend running: http:
  console.log(`📌 Recipes:     http:
  console.log(`📌 Ingredients: http:
});
