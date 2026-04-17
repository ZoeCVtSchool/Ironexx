const mysql = require('mysql2/promise');
require('dotenv').config({ path: 'c:\\Maquinaria\\backend\\.env' });

async function test() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ironexx'
  });

  try {
    const [rows] = await pool.query('SHOW CREATE TABLE productos');
    console.log(rows[0]['Create Table']);
  } catch(e) { console.error("Error from productos:", e.message); }
  
  process.exit(0);
}
test();
