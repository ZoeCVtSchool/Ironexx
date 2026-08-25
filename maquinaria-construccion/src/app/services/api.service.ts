import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private apiUrl = this.getApiBaseUrl();

  constructor(private http: HttpClient) {}

  private getApiBaseUrl(): string {
    if (typeof window === 'undefined') {
      return '/api';
    }

    const isLocalhost = ['localhost', '127.0.0.1', '0.0.0.0'].includes(window.location.hostname);
    return isLocalhost ? 'http://localhost:3000/api' : '/api';
  }

  private isBrowser(): boolean {
    return typeof window !== 'undefined' && typeof document !== 'undefined';
  }

  private getToken(): string | null {
    if (!this.isBrowser()) return null;
    return localStorage.getItem('authToken');
  }

  private getAuthHeaders(): HttpHeaders {
    const token = this.getToken();
    return new HttpHeaders({
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {})
    });
  }

  getCategorias(): Observable<any> {
    if (!this.isBrowser()) return of([]);
    return this.http.get(`${this.apiUrl}/categorias`);
  }

  getProductos(): Observable<any> {
    if (!this.isBrowser()) return of([]);
    return this.http.get(`${this.apiUrl}/productos`);
  }

  login(credentials: {email: string, password: string, captchaToken?: string}): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/auth/login`, credentials);
  }

  register(user: { nombre: string; email: string; password: string }): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/auth/register`, user);
  }

  me(): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.get(`${this.apiUrl}/auth/me`, { headers: this.getAuthHeaders() });
  }

  crearPedido(pedido: any): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/pedidos`, pedido, { headers: this.getAuthHeaders() });
  }

  // --- REGISTRO ---
  registrarUsuario(usuario: any): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/auth/register`, usuario);
  }

  // --- CRUD USUARIOS (Dashboard) ---
  getUsuarios(): Observable<any[]> {
    if (!this.isBrowser()) return of([]);
    return this.http.get<any[]>(`${this.apiUrl}/usuarios`, { headers: this.getAuthHeaders() });
  }
  crearUsuario(usuario: any): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/usuarios`, usuario, { headers: this.getAuthHeaders() });
  }
  actualizarUsuario(id: number, usuario: any): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.put(`${this.apiUrl}/usuarios/${id}`, usuario, { headers: this.getAuthHeaders() });
  }
  eliminarUsuario(id: number): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.delete(`${this.apiUrl}/usuarios/${id}`, { headers: this.getAuthHeaders() });
  }

  // --- CRUD PRODUCTOS (Dashboard) ---
  crearProducto(producto: any): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/productos`, producto, { headers: this.getAuthHeaders() });
  }
  actualizarProducto(id: number, producto: any): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.put(`${this.apiUrl}/productos/${id}`, producto, { headers: this.getAuthHeaders() });
  }
  eliminarProducto(id: number): Observable<any> {
    if (!this.isBrowser()) return of({ ok: true, skippedOnServer: true });
    return this.http.delete(`${this.apiUrl}/productos/${id}`, { headers: this.getAuthHeaders() });
  }

  getInventoryByBranch(branchId: number): Observable<any> {
    if (!this.isBrowser()) return of({ success: true, data: [] });
    return this.http.get(`${this.apiUrl}/inventory/branch/${branchId}`, { headers: this.getAuthHeaders() });
  }

  registerInventoryScan(payload: any): Observable<any> {
    if (!this.isBrowser()) return of({ success: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/inventory/scan`, payload, { headers: this.getAuthHeaders() });
  }

  sendContact(payload: any): Observable<any> {
    if (!this.isBrowser()) return of({ success: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/contact`, payload);
  }

  getNotifications(userId: number): Observable<any> {
    if (!this.isBrowser()) return of({ success: true, data: [] });
    return this.http.get(`${this.apiUrl}/notifications/user/${userId}`, { headers: this.getAuthHeaders() });
  }

  registerWearableToken(payload: any): Observable<any> {
    if (!this.isBrowser()) return of({ success: true, skippedOnServer: true });
    return this.http.post(`${this.apiUrl}/wearable/register-token`, payload, { headers: this.getAuthHeaders() });
  }

  getTvProducts(branchId: number): Observable<any> {
    if (!this.isBrowser()) return of({ success: true, data: [] });
    return this.http.get(`${this.apiUrl}/tv/products?branchId=${branchId}`);
  }
}
