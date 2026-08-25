# Plan de Retención de Datos — Ecosistema BLE + Firestore (Evaluación 2 Extraordinaria)

Complementa (no reemplaza) `docs/plan_retencion_datos.md`, enfocado en los datos que realmente maneja el
ecosistema Wear OS + Teléfono + Firestore + Smart TV de esta evaluación.

## 1. Datos y su ciclo de vida

| Dato | Origen | Transporte | Almacenamiento | Retención |
|---|---|---|---|---|
| Temperatura del motor | Simulador en el wearable | BLE NOTIFY (Int32 LE) | Memoria del teléfono (no persiste) | Solo mientras dura la conexión BLE activa |
| Nivel de combustible | Simulador en el wearable | BLE NOTIFY (Int32 LE) | Memoria del teléfono (no persiste) | Solo mientras dura la conexión BLE activa |
| Horómetro | Simulador en el wearable | BLE NOTIFY (Int32 LE) | Memoria del teléfono (no persiste) | Solo mientras dura la conexión BLE activa |
| Máquina seleccionada (nombre, sucursal) | Selección del usuario en el teléfono | Firestore `setDoc()`/`.set(merge:true)` | Documento `estado_tv/actual` en Firestore | Se sobreescribe en cada nueva selección; no se acumula historial |
| Timestamp de última actualización | Generado al escribir en Firestore | Firestore | Documento `estado_tv/actual` | Igual que el dato anterior |

**Nota importante:** a diferencia del plan de retención general del proyecto (que habla de 30 días para datos
en LocalStorage/SQLite del sistema web), los datos de este ecosistema BLE/Firestore **no se persisten a largo
plazo en ningún lado** — los valores del wearable viven solo en memoria mientras hay conexión activa, y el
documento de Firestore siempre contiene únicamente el último estado (no un historial), por lo que no aplica
un borrado automático por antigüedad: cada escritura ya reemplaza a la anterior.

## 2. Justificación de no usar retención de 30 días aquí
El plan de 30 días del documento general aplica a datos que sí se guardan de forma duradera (SQLite,
LocalStorage). Los datos de este ecosistema son de naturaleza transitoria por diseño:
- BLE: streaming en tiempo real, sin buffer histórico.
- Firestore: un solo documento con el "estado actual", sin colección de eventos históricos.

Si en una iteración futura se decidiera guardar historial (ej. una colección `estado_tv_historial`), se
aplicaría el mismo periodo de 30 días documentado en el plan general, con borrado automático al iniciar la
app, igual patrón que ya está implementado para otros datos del sistema.

## 3. Eliminación de las credenciales de prueba
Como parte de la revisión de seguridad de esta evaluación se encontraron y corrigieron credenciales reales
hardcodeadas en el código (ver sección "Problemas y soluciones" del informe formal). Ninguna de esas
credenciales corresponde a datos de sensores o de Firestore — eran credenciales de acceso a servicios
externos (base de datos, correo, reCAPTCHA) que ya fueron removidas del código y del historial de git.

---
**Responsable:** Equipo de desarrollo Ironexx — Evaluación 2 Extraordinaria.
