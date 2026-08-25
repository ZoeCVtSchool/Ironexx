import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { NotificationService } from '../../services/notification.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.css']
})
export class DashboardComponent implements OnInit {
  activeView: 'administradores' | 'usuarios' | 'productos' = 'administradores';
  
  constructor(private router: Router, private apiService: ApiService, private notificationService: NotificationService) {
    // Verificar si el usuario es administrador
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      const userRole = localStorage.getItem('userRole');
      if (userRole !== 'admin') {
        this.notificationService.show('Acceso denegado. Solo los administradores pueden acceder al panel.', 'error');
        this.router.navigate(['/catalogo']);
        return;
      }
    }
  }

  ngOnInit(): void {
    this.cargarDatosBD();
  }

  // Formularios
  adminForm: any = { id: 0, nombre: '', email: '', password: '', rol: 'admin', estado: 'Activo' };
  userForm: any = { id: 0, nombre: '', email: '', password: '', rol: 'cliente', estado: 'Activo' };
  productForm: any = { id: 0, nombre: '', categoria_nombre: 'Maquinaria Pesada', precio: 0, stock: 0, condicion: 'nuevo' };
  productImageFile: File | null = null;

  // Arreglos desde BD
  todosLosUsuarios: any[] = [];
  productos: any[] = [];
  categoriasLista: any[] = [];

  get administradores() {
    return this.todosLosUsuarios.filter(u => u.rol === 'admin');
  }
  
  get clientUsuarios() {
    return this.todosLosUsuarios.filter(u => u.rol === 'cliente');
  }

  cargarDatosBD() {
    this.apiService.getUsuarios().subscribe(data => this.todosLosUsuarios = data);
    this.apiService.getProductos().subscribe(data => this.productos = data);
    this.apiService.getCategorias().subscribe(data => {
      this.categoriasLista = data;
    });
  }

  // Logout
  logout() {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') localStorage.clear();
    this.router.navigate(['/login']);
  }

  setActiveView(view: 'administradores' | 'usuarios' | 'productos') {
    this.activeView = view;
  }

  // -------- ADMINISTRADORES --------
  saveAdmin() {
    this.adminForm.rol = 'admin';
    if (this.adminForm.id === 0) {
      this.apiService.crearUsuario(this.adminForm).subscribe(() => {
        this.notificationService.show('Administrador dado de alta exitosamente.', 'success');
        this.cargarDatosBD();
        this.resetAdminForm();
      });
    } else {
      this.apiService.actualizarUsuario(this.adminForm.id, this.adminForm).subscribe(() => {
        this.notificationService.show('Administrador actualizado.', 'success');
        this.cargarDatosBD();
        this.resetAdminForm();
      });
    }
  }
  editAdmin(admin: any) { this.adminForm = { ...admin }; }
  deleteAdmin(id: number) {
    if (confirm('¿Eliminar administrador definitivo?')) {
      this.apiService.eliminarUsuario(id).subscribe(() => {
        this.notificationService.show('Eliminado', 'info');
        this.cargarDatosBD();
      });
    }
  }
  resetAdminForm() { this.adminForm = { id: 0, nombre: '', email: '', password: '', rol: 'admin', estado: 'Activo' }; }

  // -------- USUARIOS (CLIENTES) --------
  saveUser() {
    this.userForm.rol = 'cliente';
    if (this.userForm.id === 0) {
      this.notificationService.show('La creación de clientes solo se permite desde el formulario público exterior.', 'info');
    } else {
      this.apiService.actualizarUsuario(this.userForm.id, this.userForm).subscribe(() => {
        this.notificationService.show('Cliente actualizado correctamente.', 'success');
        this.cargarDatosBD();
        this.resetUserForm();
      });
    }
  }
  editUser(user: any) { this.userForm = { ...user }; }
  deleteUser(id: number) {
    if (confirm('¿Dar de baja a este cliente?')) {
      this.apiService.eliminarUsuario(id).subscribe(() => {
        this.notificationService.show('Cliente dado de baja', 'info');
        this.cargarDatosBD();
      });
    }
  }
  resetUserForm() { this.userForm = { id: 0, nombre: '', email: '', password: '', rol: 'cliente', estado: 'Activo' }; }

  // -------- PRODUCTOS --------
  onFileSelected(event: any) {
    if (event.target.files.length > 0) {
      this.productImageFile = event.target.files[0];
    }
  }

  saveProduct() {
      const formData = new FormData();
      formData.append('categoria_nombre', this.productForm.categoria_nombre);
      formData.append('nombre', this.productForm.nombre);
      formData.append('precio', this.productForm.precio.toString());
      formData.append('stock', this.productForm.stock.toString());
      formData.append('condicion', this.productForm.condicion);
      
      if (this.productImageFile) {
        formData.append('imagen', this.productImageFile);
      }

      if (this.productForm.id === 0) {
        this.apiService.crearProducto(formData).subscribe(() => {
          this.notificationService.show('Inventario subido correctamente con imagen incluida.', 'success');
          this.cargarDatosBD();
          this.resetProductForm();
        });
      } else {
        this.apiService.actualizarProducto(this.productForm.id, formData).subscribe(() => {
          this.notificationService.show('Modificación guardada exitosamente en el catálogo.', 'success');
          this.cargarDatosBD();
          this.resetProductForm();
        });
      }
  }
  editProduct(product: any) { 
    this.productForm = { ...product }; 
    this.productImageFile = null;
    const fileInput: any = document.getElementById('productImageInput');
    if (fileInput) fileInput.value = '';
  }
  deleteProduct(id: number) {
    if (confirm('¿Eliminar inventario de MySQL permanentemente?')) {
      this.apiService.eliminarProducto(id).subscribe(() => {
        this.notificationService.show('Eliminado correctamente', 'info');
        this.cargarDatosBD();
      });
    }
  }
  resetProductForm() { 
    this.productForm = { id: 0, nombre: '', categoria_nombre: 'Maquinaria Pesada', precio: 0, stock: 0, condicion: 'nuevo' }; 
    this.productImageFile = null;
    if (typeof document !== 'undefined') {
      const fileInput: any = document.getElementById('productImageInput');
      if (fileInput) fileInput.value = '';
    }
  }

  resetForms() {
    this.resetAdminForm();
    this.resetUserForm();
    this.resetProductForm();
  }
}
