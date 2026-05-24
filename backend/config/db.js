const mysql = require('mysql2');

const pool = mysql.createPool({
  host: '127.0.0.1',
  port: 3306,
  user: 'root',
  password: 'Ahmed2380102',
  database: 'chefnova_db',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool.promise();