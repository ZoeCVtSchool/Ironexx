require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const multer = require('multer');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Configuración de almacenamiento de Multer (Disco Duro local)
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, 'uploads'));
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    cb(null, Date.now() + '-' + Math.round(Math.random() * 1E9) + ext);
  }
});
const upload = multer({ storage: storage });

// Servir la carpeta uploads para acceso público HTTP (Angular leerá de aquí)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Base de datos - Configuración MySQL
const dbConfig = {
  host: process.env.DB_HOST || '127.0.0.1',
  port: parseInt(process.env.DB_PORT) || 3307,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ironexx'
};

const pool = mysql.createPool(dbConfig);

pool.getConnection()
    .then(conn => {
        console.log('✅ Conexión exitosa a la Base de Datos ironexx de MySQL en el puerto ' + dbConfig.port);
        conn.release();
    })
    .catch(err => console.error('❌ Error inicial conectando a MySQL:', err.message));

// ========================
// ENDPOINTS DE CATÁLOGO
// ========================

// 1. Obtener Categorías
app.get('/api/categorias', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT * FROM categorias');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 2. Obtener Productos
app.get('/api/productos', async (req, res) => {
  try {
    const query = `
      SELECT p.*, c.nombre as categoria_nombre 
      FROM productos p 
      LEFT JOIN categorias c ON p.categoria_id = c.id
    `;
    const [rows] = await pool.query(query);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ========================
// ENDPOINTS DE USUARIOS (Login y 2FA)
// ========================

app.post('/api/login', async (req, res) => {
  try {
    const { email, password, captchaToken } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ error: 'Faltan credenciales' });
    }

    if (!captchaToken) {
      return res.status(400).json({ error: 'Por favor, completa el CAPTCHA (No soy un robot).' });
    }

    // Verificar el CAPTCHA con Google
    const secretKey = process.env.RECAPTCHA_SECRET_KEY || '6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe';
    const verifyUrl = `https://www.google.com/recaptcha/api/siteverify?secret=${secretKey}&response=${captchaToken}`;
    
    const recaptchaRes = await fetch(verifyUrl, { method: 'POST' });
    const recaptchaData = await recaptchaRes.json();

    if (!recaptchaData.success) {
      console.error('❌ Error CAPTCHA:', recaptchaData['error-codes']);
      return res.status(400).json({ error: 'Verificación CAPTCHA fallida. Detectado como posible robot.' });
    }

    const [rows] = await pool.query('SELECT * FROM usuarios WHERE email = ?', [email]);
    if (rows.length === 0) return res.status(401).json({ error: 'Usuario no encontrado' });
    
    const user = rows[0];
    
    if (user.password !== password) {
      return res.status(401).json({ error: 'Contraseña incorrecta' });
    }

    // Retorna directamente al usuario sin 2FA
    res.json({ id: user.id, nombre: user.nombre, rol: user.rol, email: user.email });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ========================
// ENDPOINTS DE PAGOS (PEDIDOS)
// ========================

app.post('/api/pedidos', async (req, res) => {
  let connection;
  try {
    const { usuario_id, total, direccion_envio, telefono_contacto, paypal_order_id, items_carrito } = req.body;

    console.log('🔍 [Backend] Datos recibidos:', { usuario_id, total, paypal_order_id, items_count: items_carrito?.length });

    if (!items_carrito || items_carrito.length === 0) {
      return res.status(400).json({ error: 'El pedido no puede estar vacío' });
    }

    connection = await pool.getConnection();
    await connection.beginTransaction();

    // 1. Crear la cabecera del pedido
    console.log('🔍 [Backend] Insertando pedido...');
    const [orderResult] = await connection.query(
      `INSERT INTO pedidos (usuario_id, total, direccion_envio, telefono_contacto, estado_pago, paypal_order_id)
       VALUES (?, ?, ?, ?, 'pagado', ?)`,
      [usuario_id || null, total, direccion_envio, telefono_contacto, paypal_order_id]
    );
    
    const pedido_id = orderResult.insertId;
    console.log('✅ [Backend] Pedido creado con ID:', pedido_id);

    // 2. Insertar los detalles del pedido (Historial del carrito)
    for (const item of items_carrito) {
      console.log('🔍 [Backend] Insertando detalle:', item);
      await connection.query(
        `INSERT INTO pedido_detalles (pedido_id, producto_id, cantidad, precio_unitario)
         VALUES (?, ?, ?, ?)`,
        [pedido_id, item.id || 1, item.cantidad, item.precio]
      );
    }

    // 4. Confirmar los cambios
    await connection.commit();
    console.log('✅ [Backend] Pedido registrado exitosamente');
    res.status(201).json({ success: true, pedido_id, message: '¡Pedido registrado exitosamente!' });
    
  } catch (err) {
    if (connection) await connection.rollback();
    console.error('❌ [Backend] Error insertando la orden:', err);
    console.error('❌ [Backend] Error detalle:', err.message);
    console.error('❌ [Backend] Stack:', err.stack);
    res.status(500).json({ error: err.message, detail: err.stack });
  } finally {
    if (connection) connection.release();
  }
});

// ---------------------------
// ENDPOINTS DE REGISTRO
// ---------------------------
app.post('/api/registro', async (req, res) => {
  try {
    const { nombre, email, password } = req.body;
    if (!nombre || !email || !password) return res.status(400).json({ error: 'Faltan campos.' });
    
    // Verificar si ya existe
    const [existing] = await pool.query('SELECT id FROM usuarios WHERE email = ?', [email]);
    if (existing.length > 0) return res.status(400).json({ error: 'El email ya está registrado.' });

    // Insertar rol 'cliente'
    const [result] = await pool.query('INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, ?)', [nombre, email, password, 'cliente']);
    
    console.log(`✅ [DB MySQL] Nuevo cliente guardado en BD. ID de inserción: ${result.insertId} | Email: ${email}`);
    
    res.status(201).json({ success: true, message: 'Usuario registrado exitosamente', id: result.insertId });
  } catch (err) {
    console.error(`❌ [DB Error] Falló al insertar usuario a BD:`, err);
    res.status(500).json({ error: err.message });
  }
});

// ---------------------------
// CRUD USUARIOS (Dashboard)
// ---------------------------
app.get('/api/usuarios', async (req, res) => {
  try {
    const [rows] = await pool.query('SELECT id, nombre, email, rol, fecha_creacion FROM usuarios ORDER BY id DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/usuarios', async (req, res) => {
  try {
    const { nombre, email, password, rol } = req.body;
    const pwd = password || '123456'; // default
    const userRole = rol || 'cliente';
    
    const [result] = await pool.query('INSERT INTO usuarios (nombre, email, password, rol) VALUES (?, ?, ?, ?)', [nombre, email, pwd, userRole]);
    res.status(201).json({ success: true, id: result.insertId });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/usuarios/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const { nombre, email, rol } = req.body;
    await pool.query('UPDATE usuarios SET nombre=?, email=?, rol=? WHERE id=?', [nombre, email, rol, id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/usuarios/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM usuarios WHERE id=?', [req.params.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ---------------------------
// CRUD PRODUCTOS (Dashboard)
// ---------------------------
app.post('/api/productos', upload.single('imagen'), async (req, res) => {
  try {
    const { categoria_nombre, nombre, descripcion, precio, condicion, stock } = req.body;
    
    let catId = 1;
    if (categoria_nombre === 'Maquinaria Pesada') { catId = 1; }
    else if (categoria_nombre === 'Maquinaria Ligera') { catId = 2; }
    else if (categoria_nombre === 'Herramientas') { catId = 3; }

    const stockVal = stock || 0;
    
    // Si viene imagen anexa en la petición, crear su ruta absoluta, sino dejar la estática
    let imagen_url = '/assets/images/placeholder.svg';
    if (req.file) {
      imagen_url = `http://localhost:${process.env.PORT || 3000}/uploads/${req.file.filename}`;
    }
    
    const [result] = await pool.query(
      'INSERT INTO productos (categoria_id, nombre, descripcion, precio, imagen_url, condicion, stock) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [catId, nombre, descripcion || '', precio || 0, imagen_url, condicion || 'nuevo', stockVal]
    );
    res.status(201).json({ success: true, id: result.insertId, imagen_url });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/productos/:id', upload.single('imagen'), async (req, res) => {
  try {
    const id = req.params.id;
    const { categoria_nombre, nombre, precio, stock, condicion } = req.body;
    
    let catId = 1;
    if (categoria_nombre === 'Maquinaria Pesada') { catId = 1; }
    else if (categoria_nombre === 'Maquinaria Ligera') { catId = 2; }
    else if (categoria_nombre === 'Herramientas') { catId = 3; }

    let query = 'UPDATE productos SET categoria_id=?, nombre=?, precio=?, stock=?, condicion=?';
    let params = [catId, nombre, precio, stock, condicion || 'nuevo'];

    // Solo actualizar imagen MySQL si nos subieron un nuevo archivo
    if (req.file) {
      const imagen_url = `http://localhost:${process.env.PORT || 3000}/uploads/${req.file.filename}`;
      query += ', imagen_url=?';
      params.push(imagen_url);
    }
    
    query += ' WHERE id=?';
    params.push(id);

    await pool.query(query, params);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/productos/:id', async (req, res) => {
  try {
    await pool.query('DELETE FROM productos WHERE id=?', [req.params.id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ---------------------------
// ARRANQUE DEL SERVIDOR
// ---------------------------
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log('🚀 API Backend corriendo en http://localhost:' + PORT);
});
