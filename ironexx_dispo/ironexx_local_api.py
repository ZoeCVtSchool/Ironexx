import json
import os
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

HOST = "0.0.0.0"
PORT = 3000

machines = []
notifications = []
web_notifications = []
wearable_tokens = []


def now_iso():
    return datetime.utcnow().isoformat(timespec='seconds') + 'Z'


def build_notification_for_machine(machine):
    branch = (machine.get('sucursal') or 'Sin sucursal').strip()
    name = (machine.get('nombre') or 'Máquina').strip()
    return {
        'id': len(notifications) + 1,
        'tipo': 'maquina',
        'titulo': 'Nueva máquina registrada',
        'mensaje': f'Se registró una nueva máquina en {branch}',
        'usuario_id': 2,
        'nombre': 'Administrador',
        'cliente': 'Administrador',
        'sucursal': branch,
        'branch': branch,
        'maquina': name,
        'machine_name': name,
        'nombre_maquina': name,
        'descripcion': machine.get('descripcion', ''),
        'creada_en': now_iso(),
        'leido': 0,
    }


def build_web_notification(user_id=2):
    return {
        'id': (len(web_notifications) + 1) * 1000,
        'tipo': 'web',
        'titulo': 'Notificación web',
        'mensaje': 'Se actualizó la vista web de Ironexx y requiere revisión.',
        'usuario_id': user_id,
        'nombre': 'Sistema Web',
        'cliente': 'Sistema Web',
        'sucursal': 'Sucursal Centro',
        'branch': 'Sucursal Centro',
        'maquina': 'Portal Web',
        'machine_name': 'Portal Web',
        'nombre_maquina': 'Portal Web',
        'descripcion': 'Notificación del portal web',
        'creada_en': now_iso(),
        'leido': 0,
    }


web_notifications.append(build_web_notification(2))


class ApiHandler(BaseHTTPRequestHandler):
    server_version = "IronexxLocalAPI/1.0"

    def send_json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        path = parsed.path

        if path == '/api/health':
            self.send_json(200, {'success': True, 'status': 'ok', 'machines': len(machines), 'notifications': len(notifications)})
            return

        if path == '/api/sucursales':
            self.send_json(200, {
                'success': True,
                'data': [
                    {'id': 1, 'nombre': 'Sucursal Centro'},
                    {'id': 2, 'nombre': 'Sucursal Norte'},
                    {'id': 3, 'nombre': 'Sucursal Sur'},
                ],
            })
            return

        if path == '/api/machines':
            self.send_json(200, {'success': True, 'data': machines})
            return

        if path.startswith('/api/wearable/notifications/'):
            user_id = path.rsplit('/', 1)[-1]
            machine_items = [item for item in notifications if str(item.get('usuario_id')) == str(user_id)]
            web_items = [item for item in web_notifications if str(item.get('usuario_id')) == str(user_id)]
            items = machine_items + web_items
            if not items:
                for machine in machines:
                    branch = (machine.get('sucursal') or 'Sin sucursal').strip()
                    name = (machine.get('nombre') or 'Máquina').strip()
                    if name:
                        items.append({
                            'id': len(items) + 1,
                            'tipo': 'maquina',
                            'titulo': 'Nueva máquina registrada',
                            'mensaje': f'Se registró una nueva máquina en {branch}',
                            'usuario_id': int(user_id),
                            'nombre': 'Administrador',
                            'cliente': 'Administrador',
                            'sucursal': branch,
                            'branch': branch,
                            'maquina': name,
                            'machine_name': name,
                            'nombre_maquina': name,
                            'descripcion': machine.get('descripcion', ''),
                            'creada_en': now_iso(),
                            'leido': 0,
                        })
            items = sorted(items, key=lambda item: item.get('creada_en', ''), reverse=True)
            self.send_json(200, {'success': True, 'data': items})
            return

        self.send_json(404, {'success': False, 'message': 'Not found'})

    def do_POST(self):
        parsed = urlparse(self.path)
        path = parsed.path

        try:
            content_length = int(self.headers.get('Content-Length', '0'))
            raw = self.rfile.read(content_length) if content_length > 0 else b'{}'
            payload = json.loads(raw.decode('utf-8')) if raw else {}
        except Exception:
            payload = {}

        if path == '/api/auth/login':
            email = str(payload.get('email', '')).strip().lower()
            password = str(payload.get('password', ''))
            demo_email = os.environ.get('IRONEXX_DEMO_EMAIL', 'admin@ironexx.com')
            demo_password = os.environ.get('IRONEXX_DEMO_PASSWORD', '123456')
            valid = email == demo_email.lower() and password == demo_password
            if not valid:
                self.send_json(401, {'success': False, 'message': 'Credenciales inválidas'})
                return

            user = {'id': 2, 'nombre': 'Admin', 'email': email, 'rol': 'admin'}
            self.send_json(200, {
                'success': True,
                'token': 'local-demo-token-ironexx',
                'user': user,
                'message': 'Login exitoso',
            })
            return

        if path == '/api/wearable/register-token':
            user_id = payload.get('usuario_id') or 2
            device_id = payload.get('device_id') or 'unknown'
            token = payload.get('token') or 'demo-token'
            wearable_tokens.append({
                'usuario_id': user_id,
                'device_id': device_id,
                'token': token,
                'plataforma': payload.get('plataforma', 'android'),
                'activo': True,
                'created_at': now_iso(),
            })
            self.send_json(200, {'success': True, 'message': 'Token registrado'})
            return

        if path == '/api/machines/register':
            required = ['nombre', 'sucursal']
            missing = [field for field in required if not str(payload.get(field, '')).strip()]
            if missing:
                self.send_json(400, {'success': False, 'message': f'Faltan campos: {", ".join(missing)}'})
                return

            machine = {
                'id': len(machines) + 1,
                'codigo': payload.get('codigo') or f"QR-{len(machines) + 1}",
                'nombre': payload.get('nombre'),
                'modelo': payload.get('modelo') or 'Sin modelo',
                'sucursal': payload.get('sucursal'),
                'descripcion': payload.get('descripcion') or '',
                'estado': payload.get('estado') or 'Activo',
                'registrado_en': now_iso(),
                'tipo': payload.get('tipo') or 'maquinaria',
                'precio': payload.get('precio') or 0,
            }
            machines.insert(0, machine)
            notification = build_notification_for_machine(machine)
            notifications.insert(0, notification)
            web_notifications.insert(0, {
                'id': max((item.get('id', 0) for item in web_notifications), default=0) + 1,
                'tipo': 'web',
                'titulo': 'Notificación web',
                'mensaje': f'La web sincronizó la máquina {machine["nombre"]} en {machine["sucursal"]}.',
                'usuario_id': 2,
                'nombre': 'Sistema Web',
                'cliente': 'Sistema Web',
                'sucursal': machine.get('sucursal'),
                'branch': machine.get('sucursal'),
                'maquina': machine.get('nombre'),
                'machine_name': machine.get('nombre'),
                'nombre_maquina': machine.get('nombre'),
                'descripcion': 'Actualización desde la web',
                'creada_en': now_iso(),
                'leido': 0,
            })
            self.send_json(200, {
                'success': True,
                'message': 'Máquina registrada correctamente',
                'data': machine,
                'notification': notification,
            })
            return

        self.send_json(404, {'success': False, 'message': 'Endpoint no encontrado'})


def run_server():
    server = ThreadingHTTPServer((HOST, PORT), ApiHandler)
    print(f'Ironexx local API running on http://localhost:{PORT}')
    print('Endpoints: /api/machines, /api/machines/register, /api/wearable/notifications/<userId>')
    server.serve_forever()


if __name__ == '__main__':
    run_server()
