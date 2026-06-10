const express = require('express');
const router  = express.Router();
const { getAllIngredients, getIngredientsByRecipe, getIngredientById, createIngredient, updateIngredient, deleteIngredient } = require('../controllers/ingredientController');
const { protect } = require('../middleware/authMiddleware');

router.get('/',                    protect, getAllIngredients);
router.get('/recipe/:recipeId',    protect, getIngredientsByRecipe);
router.get('/:id',                 protect, getIngredientById);
router.post('/',                   protect, createIngredient);
router.put('/:id',                 protect, updateIngredient);
router.delete('/:id',              protect, deleteIngredient);

module.exports = router;
