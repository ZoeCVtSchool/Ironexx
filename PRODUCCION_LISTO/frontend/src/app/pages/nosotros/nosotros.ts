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
      icono: '⭐'
    },
    {
      titulo: 'Confianza',
      descripcion: 'Más de 10 años de experiencia sirviendo a la industria de la construcción',
      icono: '🤝'
    },
    {
      titulo: 'Servicio',
      descripcion: 'Soporte técnico 24/7 y mantenimiento preventivo para todos nuestros clientes',
      icono: '🔧'
    },
    {
      titulo: 'Innovación',
      descripcion: 'Siempre a la vanguardia con la tecnología más avanzada en maquinaria',
      icono: '🚀'
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