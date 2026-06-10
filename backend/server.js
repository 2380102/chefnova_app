const express = require('express');
const cors    = require('cors');
const app     = express();
const PORT    = 3000;

app.use(cors());
app.use(express.json());

// ===== Routes =====
app.use('/api/auth',        require('./routes/authRoutes'));
app.use('/api/recipes',     require('./routes/recipeRoutes'));
app.use('/api/ingredients', require('./routes/ingredientRoutes'));
app.use('/api/orders',      require('./routes/orderRoutes'));

app.get('/', (req, res) => {
  res.json({ message: 'ChefNova Backend chal raha hai!' });
});

app.listen(PORT, function() {
  console.log('Backend running: http://localhost:3000');
  console.log('Auth:        POST /api/auth/signup');
  console.log('Auth:        POST /api/auth/login');
  console.log('Recipes:     GET  /api/recipes      (JWT required)');
  console.log('Ingredients: GET  /api/ingredients  (JWT required)');
  console.log('Orders:      GET  /api/orders        (JWT required)');
});
