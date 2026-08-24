# Ironexx - Sistema de Compra-Venta de Maquinaria de Construcción

Proyecto del ecosistema de dispositivos inteligentes para la materia de Desarrollo para Dispositivos Inteligentes.

## Descripción del Proyecto

Ironexx es un sistema tecnológico integral orientado a mejorar la administración, supervisión y consulta de maquinaria disponible en las distintas sucursales de la empresa. El ecosistema consta de tres aplicaciones:

1. **Aplicación Móvil (Flutter)**: Permite a los administradores escanear códigos de barras de máquinas, recibir notificaciones del wearable y consultar maquinaria.
2. **Aplicación Wearable (Wear OS)**: Sistema de notificaciones para administradores con datos de sensores en tiempo real.
3. **PWA para Smart TV**: Pantalla interactiva de consulta de maquinaria con diseño 10-foot para televisión.

## Estructura del Proyecto

```
ironexx_dispo/
├── mobile_app/          # Aplicación móvil Flutter
├── wearable_app/        # Aplicación Wear OS Flutter
├── pwa_tv/             # PWA para Smart TV
└── README.md           # Este archivo
```

## Requisitos Previos

### Para las aplicaciones Flutter (móvil y wearable):
- Flutter SDK >= 3.3.3
- Dart SDK >= 3.3.3
- Android Studio con plugins Flutter y Dart
- Emulador de teléfono (API Level recomendado: 33)
- Emulador Wear OS (API Level recomendado: 30)

### Para la PWA:
- Navegador Chrome (para desarrollo y pruebas)
- Servidor HTTP local (opcional para pruebas)

## Instrucciones de Ejecución

### 1. Aplicación Móvil

```bash
cd mobile_app
flutter pub get
flutter run
```

**Permisos requeridos:**
- Bluetooth
- Ubicación precisa
- Escaneo Bluetooth

### 2. Aplicación Wearable

```bash
cd wearable_app
flutter pub get
flutter run
```

**Permisos requeridos:**
- Bluetooth
- Publicidad Bluetooth
- Conexión Bluetooth

### 3. PWA para Smart TV

Para ejecutar la PWA, necesitas un servidor HTTP local. Puedes usar:

```bash
cd pwa_tv
# Opción 1: Usar Python
python -m http.server 8000

# Opción 2: Usar Node.js (con http-server instalado)
npx http-server -p 8000
```

Luego abre Chrome en: `http://localhost:8000`

**Para emular Smart TV en Chrome DevTools:**
1. Abre DevTools (F12)
2. Ve a More tools → Remote devices
3. Configura la emulación a 1920x1080
4. Usa User Agent de Smart TV

## Integración del Ecosistema

### Flujo de Datos

1. **Wearable → Móvil (BLE)**
   - El wearable genera datos de sensores (pasos, ritmo cardíaco, calorías)
   - Transmite datos vía Bluetooth Low Energy con características GATT NOTIFY
   - El móvil se conecta y recibe datos en tiempo real

2. **Móvil → TV (BroadcastChannel)**
   - El móvil muestra datos de la API de maquinaria
   - Comunicación con la TV vía BroadcastChannel para sincronización
   - La TV actualiza su interfaz según selecciones del móvil

### Configuración BLE

**UUIDs compartidos (definidos en `ble_constants.dart`):**
- Service UUID: `0000180A-0000-1000-8000-00805F9B34FB`
- Steps Characteristic: `00002A7D-0000-1000-8000-00805F9B34FB`
- Heart Rate Characteristic: `00002A37-0000-1000-8000-00805F9B34FB`
- Calories Characteristic: `00002A19-0000-1000-8000-00805F9B34FB`

### Umbrales Críticos

- Ritmo cardíaco: > 120 BPM
- Pasos: > 10,000 pasos

## Seguridad

### Permisos y Privacidad

- **LFPDPPP**: Los datos personales manejados son identificados con base legal
- **Aviso de privacidad**: Incluye responsable, datos, finalidad y derechos ARCO
- **Retención de datos**: Los datos se guardan por 30 días y se eliminan automáticamente

### Content Security Policy (PWA)

```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               connect-src 'self' https://api.ironexx.com; 
               script-src 'self'; 
               style-src 'self' 'unsafe-inline'; 
               img-src 'self' data: https:; 
               media-src 'self' https:;">
```

### Validación de BroadcastChannel

```javascript
channel.onmessage = (event) => {
    if (event.origin !== window.location.origin) {
        console.warn('Invalid origin in BroadcastChannel message');
        return;
    }
    // Procesar mensaje...
};
```

## Pruebas

### Plan de Pruebas

1. **Prueba API (P2.5)**: Verificar que la app móvil muestra datos reales de la API
2. **Prueba BLE NOTIFY (P2.6)**: Verificar que los datos del wearable llegan al móvil en tiempo real
3. **Prueba D-pad (PWA)**: Verificar navegación con flechas del teclado en la TV
4. **Prueba modo offline**: Verificar que el Service Worker sirve la app sin red
5. **Prueba de sincronización**: Verificar que un cambio en el móvil se refleja en la TV en < 2 segundos

### Ejecución de Pruebas

```bash
# Ejecutar pruebas unitarias (móvil)
cd mobile_app
flutter test

# Ejecutar pruebas unitarias (wearable)
cd wearable_app
flutter test
```

## Configuración de Emuladores

### Emulador de Teléfono
- Modelo: Pixel 6
- API Level: 33
- RAM: 4GB

### Emulador Wear OS
- Forma: Round
- API Level: 30
- RAM: 512MB

### Emulación TV en Chrome
- Resolución: 1920x1080
- User Agent: Smart TV

## Dependencias Principales

### mobile_app
- `flutter_blue_plus: ^1.32.0` - Conectividad BLE
- `http: ^1.2.0` - Cliente HTTP
- `provider: ^6.1.1` - State management
- `permission_handler: ^11.2.0` - Gestión de permisos

### wearable_app
- `flutter_blue_plus: ^1.32.0` - Conectividad BLE
- `permission_handler: ^11.2.0` - Gestión de permisos

## Archivos Sensibles

⚠️ **IMPORTANTE**: Nunca commits archivos sensibles:
- `.env` - Variables de entorno
- `.jks` / `.keystore` - Keystores de Android
- API keys en cualquier archivo de código

## Versión

- **Versión actual**: 1.0.0
- **Release**: v1.0

## Autor

- **Nombre**: Sandra Zoé Cabrera Velázquez
- **Grupo**: IDGS16
- **Carrera**: Tecnologías de la Información
- **Institución**: Universidad Tecnológica de Querétaro

## Licencia

Este proyecto es desarrollado con fines educativos para la materia de Desarrollo para Dispositivos Inteligentes.
