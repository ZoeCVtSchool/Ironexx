import { Component, signal } from '@angular/core';
import { RouterOutlet, Router } from '@angular/router';
import { FooterComponent } from './components/footer/footer';
import { CommonModule } from '@angular/common';
import { NotificationService } from './services/notification.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, FooterComponent, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('maquinaria-construccion');

  mobileMenuActive = false;
  isDashboardPage = false;
  isLoggedIn = false;
  userRole = '';
  userName = '';
  // @ts-ignore - Error temporal: Object is of type 'unknown' en el template
  notification$: any;

  constructor(private router: Router, private notificationService: NotificationService) {
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
}