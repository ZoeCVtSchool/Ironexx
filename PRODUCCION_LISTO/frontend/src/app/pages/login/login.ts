import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.html',
  styleUrls: ['./login.css']
})
export class LoginComponent {
  showRegister = false;
  loginData = { email: '', password: '' };
  registerData = { email: '', username: '', password: '', confirmPassword: '' };
  showSuccessMessage = false;

  constructor(private router: Router, private apiService: ApiService, private notificationService: NotificationService) {}

  toggleRegister() {
    this.showRegister = !this.showRegister;
    
    // Limpiar el formulario de login
    this.loginData = { email: '', password: '' };
    
    // Ocultar el mensaje después de 3 segundos
    setTimeout(() => {
      this.showSuccessMessage = false;
    }, 3000);
  }

  login() {
    if (!this.loginData.email || !this.loginData.password) {
      this.notificationService.show('Por favor completa todos los campos', 'error');
      return;
    }
      
    const captchaToken = (document.getElementById('g-recaptcha-response') as HTMLInputElement)?.value;
    if (!captchaToken) {
      this.notificationService.show('Por favor marca la casilla "No soy un robot"', 'error');
      return;
    }

    this.apiService.login({ ...this.loginData, captchaToken }).subscribe({
      next: (user: any) => {
        if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
          localStorage.setItem('userRole', user.rol);
          localStorage.setItem('userName', user.nombre);
          localStorage.setItem('userEmail', user.email);
          localStorage.setItem('userId', user.id.toString());
        }
        this.showSuccessMessage = true;
        setTimeout(() => {
          if (user?.rol === 'admin') {
            this.router.navigate(['/dashboard']);
          } else {
            this.router.navigate(['/catalogo']);
          }
        }, 1000);
      },
      error: (err) => {
        this.notificationService.show(err.error?.error || 'Credenciales incorrectas', 'error');
        // Resetea el captcha en caso de que la contraseña esté mal para volver a pedir validación
        if (typeof (window as any).grecaptcha !== 'undefined') {
          (window as any).grecaptcha.reset();
        }
      }
    });
  }

  register() {
    if (!this.registerData.username || !this.registerData.email || !this.registerData.password) {
      this.notificationService.show('Rellena todos los campos', 'error');
      return;
    }
    if (this.registerData.password !== this.registerData.confirmPassword) {
      this.notificationService.show('Las contraseñas no coinciden', 'error');
      return;
    }
    
    // API CALL REAL AL BACKEND
    const userData = {
      nombre: this.registerData.username,
      email: this.registerData.email,
      password: this.registerData.password
    };
    
    console.log('🔍 [Front-End] Enviando datos de registro:', userData);
    
    this.apiService.registrarUsuario(userData).subscribe({
      next: (res) => {
        console.log('✅ [Front-End] Respuesta exitosa del servidor:', res);
        console.log(`🔍 [Front-End] Verificación finalizada: Angular conectó a servidor NodeJS y el usuario fue guardado. (MySQL ID Asignado: ${res.id})`);
        
        if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
          // Iniciar sesión automático post-registro
          localStorage.setItem('userRole', 'cliente');
          localStorage.setItem('userName', this.registerData.username);
          localStorage.setItem('userEmail', this.registerData.email);
          localStorage.setItem('userId', res.id.toString());
        }
        this.showSuccessMessage = true;
        setTimeout(() => {
          this.router.navigate(['/catalogo']);
        }, 2000);
      },
      error: (err) => {
        console.error('❌ [Front-End] Error en el registro:', err);
        console.error('❌ [Front-End] Detalles del error:', err.error);
        this.notificationService.show(err.error?.error || 'Falló el registro de cuenta en el servidor.', 'error');
      }
    });
  }

  ngOnDestroy() {
    // Limpieza al destruir componente
  }
}
