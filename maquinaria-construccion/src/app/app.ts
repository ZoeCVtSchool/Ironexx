import { Component, signal } from '@angular/core';
import { RouterOutlet, Router } from '@angular/router';
import { FooterComponent } from './components/footer/footer';
import { CommonModule } from '@angular/common';
import { NotificationService } from './services/notification.service';

interface SeasonalTheme {
  badge: string;
  title: string;
  message: string;
  ctaLabel: string;
  ctaHref: string;
  mainBackground: string;
}

interface EventMenuItem {
  label: string;
  description: string;
  href: string;
}

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, FooterComponent, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('maquinaria-construccion');

  mobileMenuActive = false;
  eventMenuOpen = false;
  isDashboardPage = false;
  isLoggedIn = false;
  userRole = '';
  userName = '';
  readonly seasonalTheme = this.resolveSeasonalTheme(new Date());
  readonly eventMenuItems: EventMenuItem[] = [
    {
      label: 'Catálogo rápido',
      description: 'Abre la lista de equipos disponibles para obra inmediata.',
      href: '/catalogo',
    },
    {
      label: 'Cotización express',
      description: 'Solicita una propuesta para el proyecto que tengas en curso.',
      href: '/cotizacion',
    },
    {
      label: 'Atención directa',
      description: 'Contacta al equipo para resolver dudas o revisar inventario.',
      href: '/contacto',
    },
  ];
  // @ts-ignore - Error temporal: Object is of type 'unknown' en el template
  notification$: any;

  constructor(private readonly router: Router, private readonly notificationService: NotificationService) {
    this.notification$ = this.notificationService.notification$;
    this.router.events.subscribe(() => {
      this.isDashboardPage = this.router.url.includes('/dashboard');
      this.checkLoginStatus();
    });
    
    // Verificar estado de login al iniciar
    this.checkLoginStatus();
  }

  checkLoginStatus() {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      this.isLoggedIn = !!localStorage.getItem('userRole');
      this.userRole = localStorage.getItem('userRole') || '';
      this.userName = localStorage.getItem('userName') || '';
    }
  }

  logout() {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      localStorage.removeItem('userRole');
      localStorage.removeItem('userName');
    }
    this.isLoggedIn = false;
    this.userRole = '';
    this.userName = '';
    this.router.navigate(['/login']);
  }

  toggleMobileMenu() {
    this.mobileMenuActive = !this.mobileMenuActive;
  }

  openEventMenu() {
    this.eventMenuOpen = true;
  }

  closeEventMenu() {
    this.eventMenuOpen = false;
  }

  private resolveSeasonalTheme(currentDate: Date): SeasonalTheme {
    const month = currentDate.getMonth();

    if (month >= 5 && month <= 8) {
      return {
        badge: 'Temporada de mantenimiento',
        title: 'Campaña de verano: equipos listos para obra intensa',
        message: 'Durante esta temporada destacamos maquinaria con mejor rendimiento para jornadas largas y revisiones preventivas.',
        ctaLabel: 'Ver catálogo de temporada',
        ctaHref: '/catalogo',
        mainBackground:
          'linear-gradient(135deg, #fff7eb 0%, #ffe0b2 48%, #fef3e0 100%)',
      };
    }

    if (month >= 0 && month <= 2) {
      return {
        badge: 'Inicio de obra',
        title: 'Arranque de año con equipos para proyectos nuevos',
        message: 'El sitio se adapta para mostrar una interfaz más clara y enfocada en la planeación de proyectos.',
        ctaLabel: 'Cotizar equipo',
        ctaHref: '/cotizacion',
        mainBackground:
          'linear-gradient(135deg, #eef5ff 0%, #d7e7ff 50%, #f8fbff 100%)',
      };
    }

    if (month >= 3 && month <= 4) {
      return {
        badge: 'Temporada de expansión',
        title: 'Primavera enfocada en crecimiento y nuevas obras',
        message: 'La interfaz resalta cotizaciones y contacto para acelerar decisiones comerciales.',
        ctaLabel: 'Solicitar asesoría',
        ctaHref: '/contacto',
        mainBackground:
          'linear-gradient(135deg, #effaf1 0%, #d9f5df 48%, #f6fff7 100%)',
      };
    }

    if (month === 9 || month === 10) {
      return {
        badge: 'Cierre de año',
        title: 'Otoño con enfoque en disponibilidad y entregas',
        message: 'La experiencia visual cambia para enfatizar inventario, stock y respuesta rápida.',
        ctaLabel: 'Explorar equipos',
        ctaHref: '/catalogo',
        mainBackground:
          'linear-gradient(135deg, #f9f0ea 0%, #f0ddd0 45%, #fff8f2 100%)',
      };
    }

    return {
      badge: 'Operación continua',
      title: 'Interfaz activa para impulsar cualquier proyecto de construcción',
      message: 'La navegación y los banners se mantienen listos para atender consultas, catálogo y cotizaciones.',
      ctaLabel: 'Ir a cotización',
      ctaHref: '/cotizacion',
      mainBackground:
        'linear-gradient(135deg, #f4f6f8 0%, #e8edf1 45%, #fafbfc 100%)',
    };
  }
}