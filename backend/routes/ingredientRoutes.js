
const express = require('express');
const router  = express.Router();
const { getAllIngredients, getIngredientsByRecipe, getIngredientById, createIngredient, updateIngredient, deleteIngredient } = require('../controllers/ingredientController');

router.get('/',                    getAllIngredients);
router.get('/recipe/:recipeId',    getIngredientsByRecipe);
router.get('/:id',                 getIngredientById);
router.post('/',                   createIngredient);
router.put('/:id',                 updateIngredient);
router.delete('/:id',              deleteIngredient);

module.exports = router;
