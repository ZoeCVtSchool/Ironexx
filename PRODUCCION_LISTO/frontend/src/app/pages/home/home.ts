import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './home.html',
  styleUrls: ['./home.css'],
})
export class HomeComponent {
  servicios = [
    {
      titulo: 'Venta de Maquinaria',
      descripcion: 'Equipos nuevos y seminuevos de las mejores marcas',
      icono: '🏗️',
      enlace: '/catalogo'
    },
    {
      titulo: 'Alquiler de Equipos',
      descripcion: 'Solución temporal para tus proyectos de construcción',
      icono: '📅',
      enlace: '/cotizacion'
    },
    {
      titulo: 'Servicio Técnico',
      descripcion: 'Mantenimiento y reparación especializada 24/7',
      icono: '🔧',
      enlace: '/contacto'
    },
    {
      titulo: 'Asesoría Especializada',
      descripcion: 'Recomendaciones técnicas para tu proyecto',
      icono: '👨‍💼',
      enlace: '/nosotros'
    }
  ];

  estadisticas = [
    { numero: '500+', descripcion: 'Equipos Disponibles' },
    { numero: '10+', descripcion: 'Años de Experiencia' },
    { numero: '100%', descripcion: 'Clientes Satisfechos' },
    { numero: '24/7', descripcion: 'Soporte Técnico' }
  ];
}