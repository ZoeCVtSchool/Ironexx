import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-cotizacion',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './cotizacion.html',
  styleUrls: ['./cotizacion.css'],
})
export class CotizacionComponent {
  contactoInfo = {
    telefono: '(55) 1234-5678',
    whatsapp: '+5210000000000',
    email: 'ventas@maquiconstruccion.com',
    horario: 'Lunes a Viernes: 8:00 AM - 6:00 PM'
  };

  formasContacto = [
    {
      titulo: 'Llamada Telefónica',
      descripcion: 'Habla directamente con nuestro equipo de ventas',
      icono: '📞',
      accion: `tel:${this.contactoInfo.telefono}`,
      tipo: 'tel'
    },
    {
      titulo: 'WhatsApp',
      descripcion: 'Respuesta inmediata y cotización rápida',
      icono: '📱',
      accion: `https://wa.me/${this.contactoInfo.whatsapp}?text=Hola,%20me%20gustaría%20solicitar%20una%20cotización`,
      tipo: 'whatsapp'
    },
    {
      titulo: 'Correo Electrónico',
      descripcion: 'Envíanos los detalles de tu proyecto',
      icono: '📧',
      accion: `mailto:${this.contactoInfo.email}?subject=Solicitud%20de%20Cotización`,
      tipo: 'email'
    },
    {
      titulo: 'Formulario Web',
      descripcion: 'Completa nuestro formulario detallado',
      icono: '📝',
      accion: '/contacto',
      tipo: 'link'
    }
  ];
}