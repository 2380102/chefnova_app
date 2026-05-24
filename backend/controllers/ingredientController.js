
const db = require('../config/db');


const getAllIngredients = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT i.*, r.name AS recipe_name
      FROM ingredients i
      JOIN recipes r ON i.recipe_id = r.id
      ORDER BY i.created_at DESC
    `);
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const getIngredientsByRecipe = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM ingredients WHERE recipe_id = ? ORDER BY id ASC',
      [req.params.recipeId]
    );
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const getIngredientById = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM ingredients WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Ingredient nahi mila' });
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const createIngredient = async (req, res) => {
  try {
    const { recipe_id, name, quantity, unit } = req.body;
    if (!recipe_id || !name || !quantity) {
      return res.status(400).json({ success: false, message: 'recipe_id, name, quantity required hain' });
    }
    const [result] = await db.query(
      'INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES (?, ?, ?, ?)',
      [recipe_id, name, quantity, unit || '']
    );
    res.status(201).json({ success: true, message: 'Ingredient create ho gaya!', id: result.insertId });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const updateIngredient = async (req, res) => {
  try {
    const { recipe_id, name, quantity, unit } = req.body;
    const [result] = await db.query(
      'UPDATE ingredients SET recipe_id=?, name=?, quantity=?, unit=? WHERE id=?',
      [recipe_id, name, quantity, unit, req.params.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Ingredient nahi mila' });
    res.json({ success: true, message: 'Ingredient update ho gaya!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const deleteIngredient = async (req, res) => {
  try {
    const [result] = await db.query('DELETE FROM ingredients WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Ingredient nahi mila' });
    res.json({ success: true, message: 'Ingredient delete ho gaya!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getAllIngredients, getIngredientsByRecipe, getIngredientById, createIngredient, updateIngredient, deleteIngredient };
