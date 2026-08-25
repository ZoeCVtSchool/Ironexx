# Checklist de Seguridad — pwa_tv (Evaluación 2 Extraordinaria)

Verificado contra la arquitectura real implementada el 24-ago-2026 (no modifica el checklist original en
`docs/checklist_seguridad_pwa.md`).

## CSP (Content Security Policy)

Implementación real en `pwa_tv/index.html`:
```html
<meta http-equiv="Content-Security-Policy"
      content="default-src 'self';
               connect-src 'self' http://localhost:3000 http://127.0.0.1:3000 https://firestore.googleapis.com https://www.googleapis.com;
               script-src 'self' https://www.gstatic.com;
               style-src 'self';
               img-src 'self' data: https:;
               media-src 'self' https:;">
```
- [x] `default-src 'self'` — todo restringido al mismo origen salvo excepciones explícitas abajo.
- [x] `script-src 'self' https://www.gstatic.com` — el SDK modular de Firebase se carga desde `gstatic.com`
      sin build step/npm; es la única fuente externa de scripts permitida.
- [x] `connect-src` incluye `firestore.googleapis.com`/`www.googleapis.com` — necesario para el canal en
      tiempo real de `onSnapshot()`. Es una excepción documentada, no una CSP abierta.
- [x] `img-src`/`media-src` permiten `https:` genérico para las imágenes de catálogo (data URIs SVG del
      catálogo de ejemplo).

## Validación de origin (BroadcastChannel)
- [x] `pwa_tv/app.js` valida `event.origin === window.location.origin` antes de procesar cualquier mensaje
      del canal `ironexx-ecosystem` (defensa en profundidad — BroadcastChannel ya es same-origin por spec).
- [x] Nota: BroadcastChannel **ya no es el mecanismo principal de sincronización** teléfono↔TV — eso lo hace
      Firestore (`onSnapshot()`), tal como exige la guía. BroadcastChannel se mantiene solo para interacción
      local dentro del propio navegador de la TV.

## Autenticación / filtrado BLE
- [x] UUID de servicio custom de 128 bits (no reservado del SIG Bluetooth), centralizado en
      `ble_constants.dart`, idéntico en `wearable_app` y `mobile_app`.
- [x] El teléfono filtra el scan por `SERVICE_UUID` (no por nombre — el wearable no anuncia `localName` a
      propósito, para no exceder el límite de 31 bytes del advertising BLE legacy).
- [x] Guard contra conexiones GATT duplicadas mientras existe una conexión en curso
      (`_isConnecting`/`_connectedDevice` en `ble_service.dart`).
- [x] Timeouts: 12s de scan, 15s de connect.

## Credenciales de Firebase
- [x] El `apiKey` de Firebase (web, en `pwa_tv/firebase-config.js`, y Android, en `google-services.json`) **no
      se trata como secreto de servidor** — es la propia documentación de Firebase la que indica que va
      embebido en el cliente: https://firebase.google.com/docs/projects/api-keys
- [x] La seguridad real la dan las **reglas de Firestore**, no ocultar el `apiKey`. El proyecto
      `ironexx-extraordinaria` corre en modo de prueba (reglas abiertas 30 días) — decisión documentada por
      alcance de tiempo de esta entrega; para un entorno de producción real se debe restringir por
      autenticación.
- [x] `google-services.json` está en el repositorio a propósito (no en `.gitignore`) para que el proyecto sea
      reproducible por el profesor (requisito E6.4) — ver nota en el `.gitignore` raíz del repo.

## Service Worker
- [x] Cache First para recursos estáticos (`STATIC_ASSETS` en `service-worker.js`, incluye
      `firebase-config.js`).
- [x] Solo cachea/responde recursos del mismo origen; las llamadas a Firestore no pasan por el Service
      Worker (van directo por el SDK).

## Fallo de recursos multimedia
- [x] `updateBackgroundMedia()` en `app.js` usa un preloader (`Image()`/`video.onerror`) para detectar cuando
      un recurso multimedia existe pero falla al cargar, mostrando un fallback visual (ícono ⚠ + nombre de la
      máquina) — no solo cuando no hay recurso definido.

## Verificación con Lighthouse (24-ago-2026)
- Performance 96-99, Accessibility 100, Best Practices 100, SEO 100 (después de agregar meta description).
- Ver `docs/extraordinaria/lighthouse.md` (o la sección correspondiente del informe formal) para el detalle
  antes/después.

---
**Responsable:** Equipo de desarrollo Ironexx — Evaluación 2 Extraordinaria.
