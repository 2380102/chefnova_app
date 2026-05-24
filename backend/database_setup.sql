
CREATE DATABASE IF NOT EXISTS chefnova_db;
USE chefnova_db;


CREATE TABLE IF NOT EXISTS recipes (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(150) NOT NULL,
  category    VARCHAR(80)  NOT NULL,
  description TEXT,
  cook_time   INT          NOT NULL,
  difficulty  VARCHAR(20)  NOT NULL DEFAULT 'Easy',
  emoji       VARCHAR(10)  NOT NULL DEFAULT '🍽️',
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS ingredients (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  recipe_id   INT          NOT NULL,
  name        VARCHAR(150) NOT NULL,
  quantity    VARCHAR(80)  NOT NULL,
  unit        VARCHAR(50)  DEFAULT '',
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);


INSERT INTO recipes (name, category, description, cook_time, difficulty, emoji) VALUES
('Chicken Biryani',  'Main Course', 'Authentic Pakistani Biryani with aromatic spices', 45,  'Medium', '🍛'),
('Margherita Pizza', 'Fast Food',   'Classic Italian pizza with fresh toppings',         30,  'Easy',   '🍕'),
('Creamy Pasta',     'Main Course', 'Rich and creamy white sauce pasta',                 20,  'Easy',   '🍝'),
('Chicken Burger',   'Fast Food',   'Juicy homemade chicken burger',                     25,  'Medium', '🍔'),
('Nihari',           'Main Course', 'Slow-cooked beef stew Karachi style',               180, 'Hard',   '🍲'),
('Halwa Puri',       'Breakfast',   'Classic Pakistani breakfast combo',                  40,  'Medium', '🍮');

INSERT INTO ingredients (recipe_id, name, quantity, unit) VALUES
(1, 'Chicken',           '500', 'g'),
(1, 'Basmati Rice',      '2',   'cups'),
(1, 'Yogurt',            '1',   'cup'),
(1, 'Biryani Masala',    '2',   'tbsp'),
(2, 'Pizza Dough',       '1',   'piece'),
(2, 'Tomato Sauce',      '0.5', 'cup'),
(2, 'Mozzarella Cheese', '200', 'g'),
(3, 'Pasta',             '200', 'g'),
(3, 'Cream',             '0.5', 'cup'),
(3, 'Garlic',            '4',   'cloves'),
(4, 'Chicken Patty',     '2',   'pieces'),
(4, 'Burger Buns',       '2',   'pieces'),
(5, 'Beef',              '1',   'kg'),
(5, 'Nihari Masala',     '3',   'tbsp'),
(6, 'All-Purpose Flour', '2',   'cups'),
(6, 'Semolina',          '1',   'cup');
