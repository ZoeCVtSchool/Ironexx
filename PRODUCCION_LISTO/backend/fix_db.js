const mysql = require('mysql2/promise');

async function fix() {
  const pool = mysql.createPool({
    host: '127.0.0.1',
    port: 3306,
    user: 'root',
    password: 'Diamante24',
    database: 'ironexx'
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
