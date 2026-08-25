require('dotenv').config();
const mysql = require('mysql2/promise');

async function fix() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || '127.0.0.1',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME || 'ironexx'
  });

  try {
    await pool.query(`INSERT IGNORE INTO categorias (id, nombre) VALUES 
      (1, 'Maquinaria Pesada'),
      (2, 'Maquinaria Ligera'),
      (3, 'Herramientas')
    `);
    console.log("Categorías insertadas correctamente.");
  } catch(e) {
    console.error("Error al insertar:", e.message);
  }
  process.exit(0);
}
fix();
