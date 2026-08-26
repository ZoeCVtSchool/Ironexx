# Uso de Inteligencia Artificial en este proyecto

Este proyecto (ecosistema Wear OS + Firestore + Smart TV de la Evaluación 2 Extraordinaria) se desarrolló
con apoyo de **Claude** (Anthropic), usado como asistente de programación durante todo el proceso: revisión
del código existente, implementación del BLE GATT/NOTIFY entre el reloj y el teléfono, la sincronización con
Firestore, ajustes de la PWA de la Smart TV, y la documentación de seguridad. La autora supervisó, probó y
entendió cada cambio antes de aceptarlo, y es quien defiende el proyecto en la sesión de evaluación oral.

## Corrección de código

Durante el desarrollo se corrigieron varios problemas reales: el toolchain de Gradle/AGP/Kotlin estaba
desactualizado y no compilaba con JDK 21; faltaba el permiso de Internet en el wearable; el layout del reloj
no se ajustaba bien a la pantalla; y ya en la fase final de pruebas se encontró que el grid de la PWA
recortaba contenido en pantalla (se corrigió sin bajar ningún tamaño de fuente mínimo exigido por la guía).
También se corrigió la lógica de sincronización con la Smart TV, que al principio dependía de una lista de
máquinas registradas que empieza vacía.

## Incidente de seguridad: credenciales subidas por error a GitHub

Al revisar el repositorio se encontraron credenciales reales expuestas en el código y en el historial de
git: una contraseña de correo personal (reutilizada en varias cuentas), una contraseña de base de datos, y
una clave secreta de reCAPTCHA. Esto no debió haberse subido nunca. Se corrigió el código para usar variables
de entorno en vez de valores fijos, y se limpió el historial completo de git (con `git filter-repo`, en dos
pasadas) para que esas credenciales ya no existan en ningún commit del repositorio público, verificando que
esto no rompiera ni perdiera ningún commit funcional. La contraseña afectada ya fue cambiada por su dueña
antes de hacer este cambio.


