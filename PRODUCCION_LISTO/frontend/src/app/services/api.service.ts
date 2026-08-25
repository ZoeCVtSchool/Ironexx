import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = '/api';

  constructor(private http: HttpClient) {}

  getCategorias(): Observable<any> {
    return this.http.get(`${this.apiUrl}/categorias`);
  }

  getProductos(): Observable<any> {
    return this.http.get(`${this.apiUrl}/productos`);
  }

  login(credentials: {email: string, password: string, captchaToken?: string}): Observable<any> {
    return this.http.post(`${this.apiUrl}/login`, credentials);
  }

  crearPedido(pedido: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/pedidos`, pedido);
  }

  // --- REGISTRO ---
  registrarUsuario(usuario: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/registro`, usuario);
  }

  // --- CRUD USUARIOS (Dashboard) ---
  getUsuarios(): Observable<any[]> {
    return this.http.get<any[]>(`${this.apiUrl}/usuarios`);
  }
  crearUsuario(usuario: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/usuarios`, usuario);
  }
  actualizarUsuario(id: number, usuario: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/usuarios/${id}`, usuario);
  }
  eliminarUsuario(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/usuarios/${id}`);
  }

  // --- CRUD PRODUCTOS (Dashboard) ---
  crearProducto(producto: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/productos`, producto);
  }
  actualizarProducto(id: number, producto: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/productos/${id}`, producto);
  }
  eliminarProducto(id: number): Observable<any> {
    return this.http.delete(`${this.apiUrl}/productos/${id}`);
  }
}
