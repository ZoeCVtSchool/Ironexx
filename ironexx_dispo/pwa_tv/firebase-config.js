// Configuracion de cliente de Firebase para Ironexx (proyecto ironexx-extraordinaria).
//
// Este apiKey NO es un secreto de servidor -- esta pensado para vivir en el
// codigo del cliente (Firebase lo documenta explicitamente). La seguridad
// real de los datos la dan las reglas de Firestore (ver Firebase Console >
// Firestore > Reglas), no ocultar este archivo. Documentar en E5 que el
// proyecto corre en "modo de prueba" (reglas abiertas 30 dias) por decision
// de alcance de esta entrega.
export const firebaseConfig = {
  apiKey: "AIzaSyDikgqJ1evu3R1nc_CtVU3AKJ3TZNV-M2Q",
  authDomain: "ironexx-extraordinaria.firebaseapp.com",
  projectId: "ironexx-extraordinaria",
  storageBucket: "ironexx-extraordinaria.firebasestorage.app",
  messagingSenderId: "78987802365",
  appId: "1:78987802365:web:74e82aaff64a9ef1823094",
};

// Modelo de datos E4: un unico documento con el estado actual seleccionado
// desde el telefono, escuchado en tiempo real por la TV.
export const ESTADO_TV_COLLECTION = "estado_tv";
export const ESTADO_TV_DOC_ID = "actual";
