import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-contacto',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './contacto.html',
  styleUrls: ['./contacto.css'],
})
export class ContactoComponent {
  formData = {
    nombre: '',
    email: '',
    telefono: '',
    mensaje: ''
  };

  isSubmitting = false;
  enviado = false;
  mensajeEstado = '';
  tipoEstado: 'success' | 'error' | 'info' = 'info';

  constructor(
    private apiService: ApiService,
    private notificationService: NotificationService
  ) {}

  get formularioCompleto(): boolean {
    return !!(
      this.formData.nombre?.trim() &&
      this.formData.email?.trim() &&
      this.formData.mensaje?.trim()
    );
  }

  get nombreInvalido(): boolean {
    return !!this.formData.nombre && !this.formData.nombre.trim();
  }

  get emailInvalido(): boolean {
    return !!this.formData.email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.formData.email.trim());
  }

  get mensajeInvalido(): boolean {
    return !!this.formData.mensaje && !this.formData.mensaje.trim();
  }

  enviarFormulario() {
    if (!this.formData.nombre?.trim()) {
      this.tipoEstado = 'error';
      this.mensajeEstado = 'Escribe tu nombre completo antes de enviar el mensaje.';
      this.notificationService.show(this.mensajeEstado, 'error');
      return;
    }

    if (!this.formData.email?.trim()) {
      this.tipoEstado = 'error';
      this.mensajeEstado = 'Ingresa tu correo electrónico.';
      this.notificationService.show(this.mensajeEstado, 'error');
      return;
    }

    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.formData.email.trim())) {
      this.tipoEstado = 'error';
      this.mensajeEstado = 'Ingresa un correo electrónico válido.';
      this.notificationService.show(this.mensajeEstado, 'error');
      return;
    }

    if (!this.formData.mensaje?.trim()) {
      this.tipoEstado = 'error';
      this.mensajeEstado = 'Escribe el detalle de tu mensaje antes de enviar.';
      this.notificationService.show(this.mensajeEstado, 'error');
      return;
    }

    this.isSubmitting = true;
    this.enviado = false;
    this.tipoEstado = 'info';
    this.mensajeEstado = 'Enviando tu mensaje...';

    this.apiService.sendContact({
      nombre: this.formData.nombre.trim(),
      email: this.formData.email.trim(),
      telefono: this.formData.telefono?.trim() || '',
      mensaje: this.formData.mensaje.trim()
    }).subscribe({
      next: () => {
        this.enviado = true;
        this.tipoEstado = 'success';
        this.mensajeEstado = 'Tu mensaje se envió correctamente. Pronto nos pondremos en contacto contigo.';
        this.notificationService.show('Tu mensaje se envió correctamente. Pronto nos pondremos en contacto contigo.', 'success');
        this.formData = { nombre: '', email: '', telefono: '', mensaje: '' };
        this.isSubmitting = false;
      },
      error: (err) => {
        this.isSubmitting = false;
        this.enviado = false;
        this.tipoEstado = 'error';
        const message = err?.error?.message || 'No se pudo enviar tu mensaje. Por favor, contáctanos por teléfono o intenta más tarde.';
        this.mensajeEstado = message;
        this.notificationService.show(message, 'error');
      }
    });
  }
}