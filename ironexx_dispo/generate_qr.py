import json
from pathlib import Path

try:
    import qrcode
except Exception as exc:  # pragma: no cover
    raise SystemExit(f'Falta la libreria qrcode: {exc}')

out_path = Path(r'C:\ironexx_dispo\qr_producto_ironexx.png')

data = {
    'id': 5,
    'categoria_id': 1,
    'nombre': 'Maquina Super Util',
    'descripcion': '',
    'precio': 3000000,
    'imagen_url': 'http://localhost:3000/uploads/1774644009336-88695466.jpeg',
    'condicion': 'nuevo',
    'stock': 10,
}

text = json.dumps(data, ensure_ascii=False)
img = qrcode.make(text)
img.save(out_path)
print(f'QR generado: {out_path}')
