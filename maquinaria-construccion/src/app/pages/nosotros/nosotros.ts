import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-nosotros',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './nosotros.html',
  styleUrls: ['./nosotros.css'],
})
export class NosotrosComponent {
  valores = [
    {
      titulo: 'Calidad',
      descripcion: 'Ofrecemos únicamente equipos de las mejores marcas con garantía certificada',
      icono: '<svg viewBox="0 0 24 24"><path d="M12 2.5l2.5 5.1L20 8.2l-4 3.9.9 5.4L12 2.5l-4.9 2.5.9-5.4L4 8.2l5.5-.6L12 2.5zm-6 13.5h12v2H6v-2zm0 4h12v2H6v-2z"/></svg>'
    },
    {
      titulo: 'Confianza',
      descripcion: 'Más de 10 años de experiencia sirviendo a la industria de la construcción',
      icono: '<svg viewBox="0 0 24 24"><path d="M16.5 4.5A3.5 3.5 0 0 1 20 8a3.5 3.5 0 0 1-3.5 3.5H15v7h-2v-7h-1.5A3.5 3.5 0 0 1 8 8a3.5 3.5 0 0 1 3.5-3.5h5zm-5 2a1.5 1.5 0 0 0-1.5 1.5A1.5 1.5 0 0 0 11.5 9h1V6.5zm3.5 0H15v2.5h1.5A1.5 1.5 0 0 0 18 7.5 1.5 1.5 0 0 0 16.5 6.5zM4 11h2v8H4zm4 0h2v8H8z"/></svg>'
    },
    {
      titulo: 'Servicio',
      descripcion: 'Soporte técnico 24/7 y mantenimiento preventivo para todos nuestros clientes',
      icono: '<svg viewBox="0 0 24 24"><path d="M7 4h10a2 2 0 0 1 2 2v2.5h1.5a1.5 1.5 0 0 1 1.5 1.5V13a1.5 1.5 0 0 1-1.5 1.5H19v2a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-2H3.5A1.5 1.5 0 0 1 2 13v-3a1.5 1.5 0 0 1 1.5-1.5H5V6a2 2 0 0 1 2-2zm0 2v2h10V6H7zm-2 5v2h14v-2H5z"/></svg>'
    },
    {
      titulo: 'Innovación',
      descripcion: 'Siempre a la vanguardia con la tecnología más avanzada en maquinaria',
      icono: '<svg viewBox="0 0 24 24"><path d="M12 2.5a7.5 7.5 0 0 1 7.5 7.5c0 4.5-3.1 6.7-5.2 8.4A2.7 2.7 0 0 1 12 20a2.7 2.7 0 0 1-2.3-1.6C7.6 16.7 4.5 14.5 4.5 10A7.5 7.5 0 0 1 12 2.5zm0 4a3 3 0 1 0 0 6 3 3 0 0 0 0-6z"/></svg>'
    }
  ];

  equipo = [
    {
      nombre: 'Carlos Rodríguez',
      cargo: 'Director General',
      imagen: 'assets/IRONEX-removebg-preview.png',
      experiencia: '15 años en el sector'
    },
    {
      nombre: 'María González',
      cargo: 'Gerente de Ventas',
      imagen: 'assets/IRONEX-removebg-preview.png',
      experiencia: '12 años en ventas'
    },
    {
      nombre: 'José Martínez',
      cargo: 'Jefe de Servicio Técnico',
      imagen: 'assets/IRONEX-removebg-preview.png',
      experiencia: '18 años como técnico'
    }
  ];
}