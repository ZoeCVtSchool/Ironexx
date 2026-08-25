# Aviso de Privacidad — Ironexx (Evaluación 2 Extraordinaria)

Este documento corresponde específicamente al ecosistema Wear OS + Teléfono + Firestore + Smart TV/PWA de la
Evaluación 2 Extraordinaria. Sustituye/complementa al aviso general del proyecto para reflejar la arquitectura
real implementada (no se modifica el documento original en `docs/aviso_privacidad.md`).

**Responsable:** Ironexx, sistema de administración y consulta de maquinaria de construcción.
**Fecha de vigencia:** 24 de agosto de 2026.

## 1. Datos personales y datos técnicos recopilados

### 1.1 Datos de sensores del wearable (E1/E2 — BLE)
- Temperatura del motor de la máquina operada (°C).
- Nivel de combustible (%).
- Horómetro / tiempo de operación (minutos).
- Timestamp del último valor recibido.

Estos datos **no son datos personales** — describen el estado de una máquina, no de una persona. Se generan
localmente en el wearable (simulador de sensores) y se transmiten por BLE GATT/NOTIFY al teléfono; no se
envían a ningún servidor externo.

### 1.2 Datos de sincronización (E4 — Firestore)
- Nombre de la máquina seleccionada en el teléfono.
- Sucursal asociada.
- Timestamp de la última actualización.

Se almacenan en el documento `estado_tv/actual` de Firebase Firestore (proyecto `ironexx-extraordinaria`) y
se leen en tiempo real por la PWA de la Smart TV mediante `onSnapshot()`. Tampoco constituyen datos
personales del usuario del sistema — son estado operativo de la aplicación.

### 1.3 Datos del administrador (heredado del sistema web)
- Nombre, correo electrónico — únicamente si el administrador inicia sesión en la app web/móvil del sistema
  de venta de maquinaria (fuera del alcance BLE/Firestore de esta evaluación).

## 2. Finalidad del tratamiento
- **Monitoreo de maquinaria:** mostrar en tiempo real el estado de la máquina que opera un técnico (E1/E2).
- **Sincronización de catálogo:** reflejar en la Smart TV la máquina de interés seleccionada desde el
  teléfono, sin necesidad de recargar la pantalla (E4).

## 3. Base legal
- **LFPDPPP:** Ley Federal de Protección de Datos Personales en Posesión de los Particulares (México).
- Los datos de sensores/sincronización de este ecosistema son datos operativos de equipo, no identifican a
  una persona física — se documentan aquí por transparencia y buenas prácticas, no porque LFPDPPP los
  clasifique como datos personales sensibles.

## 4. Derechos ARCO
El titular de datos personales (cuando aplique, ej. datos del administrador del sistema web) tiene derecho a:
- **Acceso** — conocer qué datos se tienen.
- **Rectificación** — corregir datos inexactos.
- **Cancelación** — solicitar eliminación.
- **Oposición** — oponerse a un tratamiento específico.

**Ejercicio de derechos:** correo `privacidad@ironexx.com`, incluyendo nombre completo, correo, derecho ARCO
a ejercer y descripción del dato. Respuesta en máximo 20 días hábiles.

## 5. Conservación
Ver `plan_retencion_datos.md` en esta misma carpeta para el detalle completo por tipo de dato.

## 6. Seguridad aplicada
- BLE: UUIDs de servicio custom (no reservados del SIG), filtrado por SERVICE_UUID, sin transmisión de datos
  personales.
- Firestore: reglas en modo de prueba durante el desarrollo de esta evaluación (documentado como decisión de
  alcance en `checklist_seguridad_pwa.md` de esta misma carpeta), sin almacenar datos personales.
- CSP configurado en la PWA para restringir orígenes de scripts/conexiones a los estrictamente necesarios
  (self + Firebase).

---
**Responsable de este documento:** Equipo de desarrollo Ironexx — Evaluación 2 Extraordinaria.
