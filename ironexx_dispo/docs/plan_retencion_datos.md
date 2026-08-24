# Plan de Retención de Datos - Ironexx

## 1. Datos Almacenados

### 1.1 Datos del Administrador
| Dato | Ubicación | Formato | Tiempo de Retención |
|------|-----------|---------|---------------------|
| Nombre | LocalStorage (PWA) | String | 30 días |
| Correo electrónico | LocalStorage (PWA) | String | 30 días |
| Teléfono | SQLite (Móvil) | String | 30 días |
| Ubicación | Memoria temporal | Coordenadas | Solo durante sesión |

### 1.2 Datos de Sensores (Wearable)
| Dato | Ubicación | Formato | Tiempo de Retención |
|------|-----------|---------|---------------------|
| Pasos | SQLite (Móvil) | Integer | 30 días |
| Ritmo cardíaco | SQLite (Móvil) | Integer | 30 días |
| Calorías | SQLite (Móvil) | Float | 30 días |
| Timestamp | SQLite (Móvil) | DateTime | 30 días |

### 1.3 Datos de Maquinaria
| Dato | Ubicación | Formato | Tiempo de Retención |
|------|-----------|---------|---------------------|
| Catálogo de máquinas | API (servidor) | JSON | Indefinido (datos públicos) |
| Consultas recientes | LocalStorage (PWA) | JSON | 30 días |
| Sucursal seleccionada | LocalStorage (PWA) | String | 30 días |

### 1.4 Datos de Sesión
| Dato | Ubicación | Formato | Tiempo de Retención |
|------|-----------|---------|---------------------|
| Token de sesión | SecureStorage (Móvil) | String | 30 días |
| Preferencias de UI | SharedPreferences (Móvil) | JSON | 30 días |
| Historial de navegación | LocalStorage (PWA) | JSON | 30 días |

## 2. Política de Retención

### 2.1 Periodo Estándar
- **Tiempo de retención:** 30 días
- **Inicio del conteo:** Fecha de creación/registro del dato
- **Final del conteo:** Automático al cumplir 30 días

### 2.2 Excepciones
- **Datos públicos:** El catálogo de maquinaria no tiene retención (es información pública)
- **Datos legales:** Se conservarán mientras sea necesario por requerimientos legales
- **Datos en litigio:** Se retendrán hasta la resolución del litigio

## 3. Mecanismo de Eliminación Automática

### 3.1 Implementación en PWA (JavaScript)

```javascript
// Función para eliminar datos antiguos al iniciar la app
function cleanOldData() {
    const RETENTION_DAYS = 30;
    const now = Date.now();
    const retentionMs = RETENTION_DAYS * 24 * 60 * 60 * 1000;
    
    // Limpiar LocalStorage
    for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        const value = localStorage.getItem(key);
        
        try {
            const data = JSON.parse(value);
            if (data.timestamp && (now - data.timestamp > retentionMs)) {
                localStorage.removeItem(key);
                console.log(`Eliminado: ${key}`);
            }
        } catch (e) {
            // Ignorar valores que no son JSON
        }
    }
    
    // Limpiar IndexedDB si se usa
    // ...
}

// Ejecutar al iniciar la app
document.addEventListener('DOMContentLoaded', cleanOldData);
```

### 3.2 Implementación en Móvil (Dart)

```dart
// Función para eliminar datos antiguos
Future<void> cleanOldData() async {
  final retentionDays = 30;
  final cutoffDate = DateTime.now().subtract(Duration(days: retentionDays));
  
  final db = await database;
  
  // Eliminar datos de sensores antiguos
  await db.delete(
    'sensor_data',
    where: 'timestamp < ?',
    whereArgs: [cutoffDate.toIso8601String()],
  );
  
  // Eliminar consultas antiguas
  await db.delete(
    'search_history',
    where: 'timestamp < ?',
    whereArgs: [cutoffDate.toIso8601String()],
  );
}

// Ejecutar al iniciar la app
@override
void initState() {
  super.initState();
  cleanOldData();
}
```

### 3.3 Implementación en Wearable (Dart)

```dart
// Los datos del wearable se transmiten al móvil
// No se almacenan localmente por más de la sesión actual
// El móvil maneja la retención según su política
```

## 4. Verificación de Eliminación

### 4.1 Monitoreo Automático
- **Frecuencia:** Al inicio de cada sesión de la aplicación
- **Log:** Se registra cada eliminación en consola (modo desarrollo)
- **Alerta:** Se notifica al usuario si hay error en eliminación

### 4.2 Verificación Manual
El usuario puede verificar la eliminación mediante:
- Revisión de LocalStorage en DevTools (PWA)
- Revisión de base de datos SQLite (Móvil)
- Solicitud de reporte de datos al equipo de soporte

## 5. Respuesta a Solicitudes ARCO

### 5.1 Cancelación
Cuando un usuario solicita la cancelación de sus datos:
1. Se elimina inmediatamente toda la información personal
2. Se confirma por correo electrónico
3. Se registra la solicitud en log de auditoría

### 5.2 Oposición
Cuando un usuario se opone al tratamiento:
1. Se marca el dato como "inactivo"
2. No se utiliza para nuevos procesamientos
3. Se elimina según el periodo de retención estándar

## 6. Copias de Seguridad

### 6.1 Backups Automáticos
- **Frecuencia:** Diaria
- **Ubicación:** Servidor seguro con encriptación
- **Retención:** 7 días (solo para recuperación de desastres)

### 6.2 Eliminación de Backups
Los backups se eliminan automáticamente después de 7 días, excepto:
- Backups requeridos por ley
- Backups en litigio

## 7. Auditoría

### 7.1 Auditoría Interna
- **Frecuencia:** Trimestral
- **Alcance:** Verificación de cumplimiento de retención
- **Responsable:** Oficial de privacidad

### 7.2 Auditoría Externa
- **Frecuencia:** Anual
- **Alcance:** Verificación de seguridad y cumplimiento LFPDPPP
- **Responsable:** Auditor externo certificado

## 8. Incumplimiento

En caso de incumplimiento de este plan:
- Se notificará al titular afectado
- Se implementarán medidas correctivas inmediatas
- Se documentará el incidente
- Se revisarán procedimientos para evitar recurrencia

---

**Versión:** 1.0  
**Fecha:** 11 de agosto de 2026  
**Responsable:** Oficial de Privacidad - Ironexx
