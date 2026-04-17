const mysql = require('mysql2/promise');
require('dotenv').config({ path: 'c:\\Maquinaria\\backend\\.env' });

async function test() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: parseInt(process.env.DB_PORT) || 3307,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'ironexx'
  });

  try {
    console.log('--- SHOW TABLES ---');
    const [tables] = await pool.query('SHOW TABLES');
    console.log(tables);
  } catch(e) { console.error(e); }

  try {
    console.log('\n--- CREATE TABLE usuarios ---');
    const [rows] = await pool.query('SHOW CREATE TABLE usuarios');
    console.log(rows[0]['Create Table']);
  } catch(e) { console.error("Error from users:", e.message); }
  
  try {
    console.log('\n--- TEST INSERT ---');
    const [res] = await pool.query("INSERT INTO usuarios (nombre, email, password, rol) VALUES ('Test', 'test@test.com', '123_test', 'cliente')");
    console.log("Insert result:", res);
  } catch(e) { console.error("Error on insert:", e.message); }
  
  process.exit(0);
}
test();
