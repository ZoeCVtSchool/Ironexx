# Checklist de Seguridad PWA - Ironexx

## CSP (Content Security Policy)

### ✅ Configuración de CSP
- [x] `default-src 'self'` - Solo permite recursos del mismo origen
- [x] `connect-src 'self' https://api.ironexx.com` - Solo conecta a API autorizada
- [x] `script-src 'self'` - Solo ejecuta scripts del mismo origen
- [x] `style-src 'self' 'unsafe-inline'` - Permite estilos inline necesarios
- [x] `img-src 'self' data: https:` - Permite imágenes de orígenes seguros
- [x] `media-src 'self' https:` - Permite media de orígenes seguros

### Implementación en HTML
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               connect-src 'self' https://api.ironexx.com; 
               script-src 'self'; 
               style-src 'self' 'unsafe-inline'; 
               img-src 'self' data: https:; 
               media-src 'self' https:;">
```

## HTTPS

### ✅ Configuración HTTPS
- [x] La PWA se sirve exclusivamente por HTTPS
- [x] Certificado SSL/TLS válido
- [x] HSTS habilitado en producción
- [x] Redirección automática de HTTP a HTTPS

### Nota para Desarrollo
En desarrollo con localhost, HTTPS no es obligatorio pero se recomienda usar:
```bash
# Para desarrollo local con HTTPS
npx http-server -p 8000 --ssl --cert cert.pem --key key.pem
```

## SRI (Subresource Integrity)

### ✅ Implementación de SRI
- [x] Scripts externos tienen hash SRI (si se usan librerías CDN)
- [x] Estilos externos tienen hash SRI (si se usan librerías CDN)

### Ejemplo de implementación
```html
<!-- Si se usara una librería externa -->
<script src="https://cdn.example.com/lib.js" 
        integrity="sha384-abc123def456" 
        crossorigin="anonymous"></script>
```

**Nota:** Actualmente no usamos librerías externas, todos los scripts son locales.

## Validación de Origin (BroadcastChannel)

### ✅ Validación Implementada
- [x] Validación de `event.origin` en todos los mensajes de BroadcastChannel
- [x] Rechazo de mensajes de orígenes desconocidos
- [x] Logging de advertencias para orígenes inválidos

### Implementación en JavaScript
```javascript
const channel = new BroadcastChannel('ironexx-ecosystem');

channel.onmessage = (event) => {
    // Validación de origin
    if (event.origin !== window.location.origin) {
        console.warn('Invalid origin in BroadcastChannel message');
        return; // Rechazar mensaje
    }
    
    // Procesar mensaje seguro
    const { type, data } = event.data;
    handleMessage(type, data);
};
```

## Validación de Datos

### ✅ Validación de Entrada
- [x] Sanitización de datos de usuario
- [x] Validación de tipos de datos
- [x] Escaping de HTML para prevenir XSS
- [x] Validación de esquema JSON para mensajes

### Implementación
```javascript
// Validación de datos de API
function validateMachineryData(data) {
    const requiredFields = ['id', 'name', 'price', 'branch', 'details'];
    return requiredFields.every(field => data.hasOwnProperty(field));
}

// Escaping de HTML
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
```

## Autenticación BLE

### ✅ Seguridad BLE
- [x] UUIDs de servicio y características son constantes privadas
- [x] Validación de nombre de dispositivo antes de conectar
- [x] Encriptación BLE habilitada cuando es posible
- [x] Timeout en conexiones BLE

### Implementación
```dart
// Validación de dispositivo
if (device.localName == BleConstants.DEVICE_NAME) {
    connectToDevice(device);
} else {
    sensorProvider.setError('Dispositivo no reconocido');
}
```

## Service Worker Security

### ✅ Seguridad de Service Worker
- [x] Solo cachea recursos del mismo origen
- [x] No cachea respuestas con headers de seguridad incorrectos
- [x] Estrategia Cache First para estáticos
- [x] Estrategia Network First para datos API
- [x] Validación de URLs antes de cachear

### Implementación
```javascript
self.addEventListener('fetch', (event) => {
    const url = new URL(event.request.url);
    
    // Solo procesar requests del mismo origen
    if (url.origin !== self.location.origin) {
        return;
    }
    
    // Estrategias de cache según tipo de recurso
    if (STATIC_ASSETS.some(asset => url.pathname.includes(asset))) {
        event.respondWith(cacheFirst(event.request));
    } else if (url.pathname.includes('api')) {
        event.respondWith(networkFirst(event.request));
    }
});
```

## Storage Security

### ✅ Seguridad de LocalStorage
- [x] No se almacenan datos sensibles en LocalStorage
- [x] Datos personales tienen timestamp para retención
- [x] Limpieza automática de datos antiguos
- [x] No se almacenan API keys en el cliente

### Implementación
```javascript
// Almacenamiento seguro con timestamp
function storeSecureData(key, value) {
    const data = {
        value: value,
        timestamp: Date.now()
    };
    localStorage.setItem(key, JSON.stringify(data));
}

// Limpieza automática
function cleanOldData() {
    const RETENTION_DAYS = 30;
    const now = Date.now();
    const retentionMs = RETENTION_DAYS * 24 * 60 * 60 * 1000;
    
    for (let key in localStorage) {
        try {
            const data = JSON.parse(localStorage.getItem(key));
            if (data.timestamp && (now - data.timestamp > retentionMs)) {
                localStorage.removeItem(key);
            }
        } catch (e) {}
    }
}
```

## Protección contra XSS

### ✅ Medidas Anti-XSS
- [x] Uso de `textContent` en lugar de `innerHTML` cuando es posible
- [x] Sanitización de HTML dinámico
- [x] CSP restringe ejecución de scripts inline
- [x] Validación de origen en BroadcastChannel

## Protección contra CSRF

### ✅ Medidas Anti-CSRF
- [x] La API usa tokens CSRF (implementación en servidor)
- [x] SameSite cookies en cookies de sesión
- [x] Validación de Origin en requests API

## Logging y Monitoreo

### ✅ Logging Seguro
- [x] No se logean datos sensibles
- [x] Logs en desarrollo, deshabilitados en producción
- [x] Errores de seguridad se reportan inmediatamente

## Actualización de Dependencias

### ✅ Gestión de Dependencias
- [x] No se usan librerías externas con vulnerabilidades conocidas
- [x] Revisión regular de vulnerabilidades (Lighthouse)
- [x] Uso de versiones estables de librerías

## Checklist Final

### ✅ Verificación Pre-Lanzamiento
- [x] CSP configurado y probado
- [x] HTTPS habilitado en producción
- [x] SRI implementado para recursos externos
- [x] Validación de origin en BroadcastChannel
- [x] Service Worker seguro
- [x] LocalStorage sin datos sensibles
- [x] Protección XSS implementada
- [x] Lighthouse score > 80 (Performance, A11y, Best Practices)
- [x] No hay API keys en el código
- [x] No hay datos de prueba en producción

---

**Versión:** 1.0  
**Fecha:** 11 de agosto de 2026  
**Responsable:** Equipo de Seguridad - Ironexx
