# Ironexx API Contract

Este documento define la API central de Ironexx para que la web, el móvil, la TV y el wearable consuman la misma fuente de verdad.

## Base URL

- Local: http://localhost:3000/api

## Autenticación

La API usa JWT.

### Header requerido

Authorization: Bearer <token>

## Endpoints

### 1) Auth

#### POST /auth/login
Request:
```json
{
  "email": "admin@ironexx.com",
  "password": "123456",
  "captchaToken": "token_recaptcha"
}
```

Response:
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "nombre": "Admin",
    "email": "admin@ironexx.com",
    "rol": "admin"
  }
}
```

#### POST /auth/register
Request:
```json
{
  "nombre": "Juan Perez",
  "email": "juan@mail.com",
  "password": "123456"
}
```

Response:
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "id": 12
}
```

#### GET /auth/me
Headers:
```http
Authorization: Bearer <token>
```

Response:
```json
{
  "success": true,
  "user": {
    "id": 1,
    "nombre": "Admin",
    "email": "admin@ironexx.com",
    "rol": "admin"
  }
}
```

### 2) Catálogo

#### GET /categorias
Response:
```json
[
  {
    "id": 1,
    "nombre": "Maquinaria Pesada"
  }
]
```

#### GET /productos
Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "categoria_id": 1,
      "nombre": "Excavadora",
      "descripcion": "Maquinaria de trabajo pesado",
      "precio": 3000000,
      "imagen_url": "http://localhost:3000/uploads/imagen.jpg",
      "condicion": "nuevo",
      "stock": 10
    }
  ]
}
```

#### GET /productos/:id
Response:
```json
{
  "success": true,
  "data": {
    "id": 5,
    "nombre": "Excavadora",
    "precio": 3000000
  }
}
```

### 3) Inventario

#### GET /inventory/branch/:branchId
Headers:
```http
Authorization: Bearer <token>
```

Response:
```json
{
  "success": true,
  "data": [
    {
      "producto_id": 5,
      "nombre": "Excavadora",
      "cantidad": 10,
      "estado": "disponible",
      "stock_minimo": 2
    }
  ]
}
```

#### POST /inventory/scan
Headers:
```http
Authorization: Bearer <token>
```

Request:
```json
{
  "producto_id": 5,
  "sucursal_id": 1,
  "cantidad": 3,
  "estado": "disponible",
  "codigo_escaneo": "EQ-00123",
  "stock_minimo": 2,
  "actualizado_por": 2
}
```

Response:
```json
{
  "success": true,
  "message": "Inventario actualizado correctamente",
  "data": {
    "producto_id": 5,
    "sucursal_id": 1,
    "cantidad": 3
  }
}
```

### 4) Contacto

#### POST /contact
Request:
```json
{
  "nombre": "Juan Perez",
  "email": "juan@mail.com",
  "telefono": "4420000000",
  "mensaje": "Necesito cotización para excavadora."
}
```

Response:
```json
{
  "success": true,
  "message": "Mensaje enviado correctamente",
  "data": {
    "id": 1
  }
}
```

### 5) Notificaciones

#### GET /notifications/user/:userId
Headers:
```http
Authorization: Bearer <token>
```

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "tipo": "info",
      "titulo": "Inventario actualizad",
      "mensaje": "Hay cambios recientes en su sucursal",
      "usuario_id": 2,
      "leido": 0
    }
  ]
}
```

#### POST /notifications
Headers:
```http
Authorization: Bearer <token>
```

Request:
```json
{
  "tipo": "alerta",
  "titulo": "Stock bajo",
  "mensaje": "El producto X tiene poco stock",
  "usuario_id": 2
}
```

### 6) Wearable

#### POST /wearable/register-token
Headers:
```http
Authorization: Bearer <token>
```

Request:
```json
{
  "usuario_id": 2,
  "device_id": "watch-001",
  "token": "abc123token",
  "plataforma": "android"
}
```

Response:
```json
{
  "success": true,
  "message": "Token registrado correctamente",
  "data": {
    "usuario_id": 2,
    "device_id": "watch-001",
    "activo": true
  }
}
```

#### GET /wearable/notifications/:userId
Headers:
```http
Authorization: Bearer <token>
```

Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "titulo": "Pedido",
      "mensaje": "Tu pedido ya fue procesado",
      "usuario_id": 2
    }
  ]
}
```

### 7) TV

#### GET /tv/branches
Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "Querétaro",
      "activa": 1
    }
  ]
}
```

#### GET /tv/products?branchId=1
Response:
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "nombre": "Excavadora",
      "descripcion": "Maquinaria de trabajo pesado",
      "precio": 3000000,
      "imagen_url": "http://localhost:3000/uploads/imagen.jpg",
      "cantidad": 10,
      "estado": "disponible"
    }
  ]
}
```

## Roles sugeridos

- admin
- cliente
- vendedor
- operador

## Recomendaciones

- Usar JWT con expiración corta.
- Guardar el token en localStorage o secure storage del cliente.
- Proteger rutas privadas con Authorization.
- Validar entradas y respuestas con estandar JSON.
- Centralizar toda la lógica de negocio en el backend.

## Cliente mapping

- Web: auth + catalog + orders + dashboard
- Móvil: auth + inventory + contact + notifications
- TV: branches + products
- Wearable: auth + notifications + register-token
