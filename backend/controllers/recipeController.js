

const db = require('../config/db');


const getAllRecipes = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM recipes ORDER BY created_at DESC');
    res.json({ success: true, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const getRecipeById = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM recipes WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ success: false, message: 'Recipe not found' });
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const createRecipe = async (req, res) => {
  try {
    const { name, category, description, cook_time, difficulty, emoji } = req.body;
    if (!name || !category || !cook_time || !difficulty) {
      return res.status(400).json({ success: false, message: 'name, category, cook_time, difficulty required hain' });
    }
    const [result] = await db.query(
      'INSERT INTO recipes (name, category, description, cook_time, difficulty, emoji) VALUES (?, ?, ?, ?, ?, ?)',
      [name, category, description || '', cook_time, difficulty, emoji || '🍽️']
    );
    res.status(201).json({ success: true, message: 'Recipe create ho gayi!', id: result.insertId });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const updateRecipe = async (req, res) => {
  try {
    const { name, category, description, cook_time, difficulty, emoji } = req.body;
    const [result] = await db.query(
      'UPDATE recipes SET name=?, category=?, description=?, cook_time=?, difficulty=?, emoji=? WHERE id=?',
      [name, category, description, cook_time, difficulty, emoji, req.params.id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Recipe nahi mili' });
    res.json({ success: true, message: 'Recipe update ho gayi!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


const deleteRecipe = async (req, res) => {
  try {
    const [result] = await db.query('DELETE FROM recipes WHERE id = ?', [req.params.id]);
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Recipe nahi mili' });
    res.json({ success: true, message: 'Recipe delete ho gayi!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { getAllRecipes, getRecipeById, createRecipe, updateRecipe, deleteRecipe };
