import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService } from '../../services/api.service';

declare var paypal: any;

@Component({
  selector: 'app-catalogo',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './catalogo.html',
  styleUrls: ['./catalogo.css'],
})
export class CatalogoComponent implements OnInit {
  userRole = '';
  userName = '';
  isLoggedIn = false;
  carrito: any[] = [];
  showCarrito = false;
  formData = {
    nombre: '',
    email: '',
    telefono: '',
    direccion: ''
  };

  constructor(private apiService: ApiService) {
    this.checkLoginStatus();
    
    // Verificar si PayPal está cargado con reintentos
    this.checkPayPalSDK();
  }

  ngOnInit() {
    this.cargarProductos();
  }

  cargarProductos() {
    this.apiService.getProductos().subscribe({
      next: (res) => {
        // Mapeamos los campos de la BD a los nombres de variables que usa el HTML
        this.productosDestacados = res.map((p: any) => ({
          ...p,
          categoria: p.categoria_nombre,
          imagen: p.imagen_url
        }));
        // Inicializar productos filtrados con todos los productos
        this.productosFiltrados = [...this.productosDestacados];
      },
      error: (err) => {
        console.error('Error cargando los productos desde la base de datos:', err);
      }
    });
  }

  checkPayPalSDK(attempts: number = 0) {
    const maxAttempts = 10;
    
    if (typeof paypal !== 'undefined' && paypal.Buttons) {
      console.log(' [PayPal] SDK cargado correctamente');
      return;
    }
    
    if (attempts < maxAttempts) {
      console.log(` [PayPal] Intento ${attempts + 1}/${maxAttempts} - SDK no disponible, reintentando...`);
      setTimeout(() => this.checkPayPalSDK(attempts + 1), 1000);
    } else {
      console.error(' [PayPal] SDK no se cargó después de', maxAttempts, 'intentos');
      console.error(' [PayPal] Verifica que el script esté en index.html y no haya bloqueadores');
    }
  }

  checkLoginStatus() {
    if (typeof window !== 'undefined' && typeof localStorage !== 'undefined') {
      this.isLoggedIn = !!localStorage.getItem('userRole');
      this.userRole = localStorage.getItem('userRole') || '';
      this.userName = localStorage.getItem('userName') || '';
    }
  }



  productosDestacados: any[] = [];
  terminoBusqueda: string = '';
  productosFiltrados: any[] = [];

  agregarAlCarrito(producto: any) {
    if (!this.isLoggedIn) {
      alert('Debes iniciar sesión para agregar productos al carrito');
      return;
    }
    
    const existe = this.carrito.find(item => item.nombre === producto.nombre);
    if (existe) {
      existe.cantidad++;
    } else {
      this.carrito.push({ ...producto, cantidad: 1 });
    }
  }

  eliminarDelCarrito(index: number) {
    this.carrito.splice(index, 1);
  }

  getTotalItemsCarrito() {
    return this.carrito.reduce((sum, item) => sum + item.cantidad, 0);
  }

  getTotalCarrito() {
    return this.carrito.reduce((total, item) => total + (item.precio * item.cantidad), 0);
  }

  procesarPagoPayPal() {
    console.log(' [PayPal] Iniciando proceso de pago...');
    
    if (this.carrito.length === 0) {
      alert('El carrito está vacío');
      return;
    }

    if (!this.formData.nombre || !this.formData.email || !this.formData.telefono || !this.formData.direccion) {
      alert('Por favor completa todos los datos del formulario');
      return;
    }

    console.log(' [PayPal] Datos validados, renderizando botones...');
    this.renderPayPalButtons();
  }

  // Cargar SDK de PayPal dinámicamente
  loadPayPalSDK(): Promise<void> {
    return new Promise((resolve, reject) => {
      // Verificar si ya está cargado
      if (typeof paypal !== 'undefined' && paypal.Buttons) {
        console.log('✅ [PayPal] SDK ya estaba cargado');
        resolve();
        return;
      }

      console.log('🔍 [PayPal] Cargando SDK dinámicamente...');

      // Crear script element
      const script = document.createElement('script');
      script.src = 'https://www.paypal.com/sdk/js?client-id=test&currency=MXN&locale=es_MX&components=buttons';
      script.async = true;
      
      script.onload = () => {
        console.log('✅ [PayPal] SDK cargado dinámicamente');
        resolve();
      };
      
      script.onerror = (err) => {
        console.error('❌ [PayPal] Error cargando SDK:', err);
        reject(new Error('No se pudo cargar el SDK de PayPal'));
      };

      document.head.appendChild(script);
    });
  }

  async renderPayPalButtons() {
    console.log('🔍 [PayPal] Iniciando renderizado de botones...');
    
    try {
      // Cargar SDK si no está disponible
      await this.loadPayPalSDK();
      
      console.log('🔍 [PayPal] PayPal object:', typeof paypal);
      console.log('🔍 [PayPal] PayPal disponible:', paypal !== undefined);
      
      if (typeof paypal === 'undefined' || !paypal.Buttons) {
        console.error('❌ [PayPal] SDK no está cargado correctamente');
        alert('Error: PayPal no está disponible.');
        return;
      }

      const container = document.getElementById('paypal-button-container');
      console.log('🔍 [PayPal] Contenedor encontrado:', container);
      
      if (!container) {
        console.error('❌ [PayPal] No se encontró el contenedor #paypal-button-container');
        alert('Error: No se encontró el contenedor de PayPal.');
        return;
      }
      
      // Limpiar contenedor
      container.innerHTML = '';
      console.log('🔍 [PayPal] Contenedor limpiado');

      console.log('🔍 [PayPal] Creando botones con estilo...');
      
      const buttons = paypal.Buttons({
        style: {
          color: 'blue',
          shape: 'pill',
          label: 'pay',
          height: 45,
          layout: 'vertical'
        },
        createOrder: (data: any, actions: any) => {
          console.log('🔍 [PayPal] Creando orden...');
          const total = this.getTotalCarrito();
          console.log('🔍 [PayPal] Total a pagar:', total);
          
          return actions.order.create({
            purchase_units: [{
              amount: {
                value: total.toFixed(2),
                currency_code: 'MXN'
              }
            }]
          });
        },
        onApprove: async (data: any, actions: any) => {
          try {
            console.log('🔍 [PayPal] Procesando aprobación...');
            const order = await actions.order.capture();
            console.log('✅ [PayPal] Pago aprobado:', order);
            
            this.enviarPedidoAlBackend(order);
            
          } catch (error) {
            console.error('❌ [PayPal] Error procesando pago:', error);
            alert('Hubo un error procesando tu pago. Por favor intenta nuevamente.');
          }
        },
        onError: (err: any) => {
          console.error('❌ [PayPal] Error en botones:', err);
          alert('Ocurrió un error con PayPal: ' + (err.message || 'Error desconocido'));
        },
        onCancel: () => {
          console.log('🔍 [PayPal] Pago cancelado por el usuario');
        },
        onInit: (data: any, actions: any) => {
          console.log('✅ [PayPal] Botones inicializados correctamente');
        }
      });
      
      console.log('🔍 [PayPal] Objeto buttons creado:', buttons);
      
      if (!buttons) {
        console.error('❌ [PayPal] No se pudo crear el objeto buttons');
        alert('Error: No se pudieron crear los botones de PayPal.');
        return;
      }
      
      // Renderizar botones
      buttons.render('#paypal-button-container').then(() => {
        console.log('✅ [PayPal] Botones renderizados exitosamente');
      }).catch((err: any) => {
        console.error('❌ [PayPal] Error al renderizar:', err);
        alert('Error al mostrar los botones de PayPal: ' + (err.message || 'Error desconocido'));
      });
      
    } catch (error) {
      console.error('❌ [PayPal] Error en renderPayPalButtons:', error);
      alert('Error al cargar PayPal: ' + (error as Error).message);
    }
  }

  async enviarPedidoAlBackend(order: any) {
    try {
      const pedidoData = {
        usuario_id: localStorage.getItem('userId'),
        total: this.getTotalCarrito(),
        direccion_envio: this.formData.direccion,
        telefono_contacto: this.formData.telefono,
        paypal_order_id: order.id,
        items_carrito: this.carrito.map(item => ({
          id: item.id || 1, // ID temporal si no existe
          nombre: item.nombre,
          cantidad: item.cantidad,
          precio: item.precio
        }))
      };

      // Enviar pedido al backend
      const response = await this.apiService.crearPedido(pedidoData).toPromise();
      console.log('Pedido guardado:', response);
      
      // Limpiar carrito después del pago
      this.carrito = [];
      this.showCarrito = false;
      
      alert('¡Pago procesado exitosamente! Tu pedido ha sido confirmado.');
      
    } catch (error) {
      console.error('Error enviando pedido:', error);
      alert('Hubo un error guardando tu pedido. Contacta al soporte.');
    }
  }

  abrirCarrito() {
    this.showCarrito = true;
    // Renderizar botones de PayPal cuando se abre el carrito
    setTimeout(() => {
      if (this.carrito.length > 0) {
        this.renderPayPalButtons();
      }
    }, 100);
  }

  cerrarCarrito() {
    this.showCarrito = false;
  }

  onImageError(event: any) {
    event.target.src = '/assets/images/placeholder.svg';
  }

  onBusquedaChange() {
    const termino = this.terminoBusqueda.toLowerCase().trim();
    
    if (!termino) {
      // Si el término está vacío, mostrar todos los productos
      this.productosFiltrados = [...this.productosDestacados];
      return;
    }
    
    // Filtrar productos por nombre, categoría o descripción
    this.productosFiltrados = this.productosDestacados.filter(producto => {
      const nombre = producto.nombre?.toLowerCase() || '';
      const categoria = producto.categoria?.toLowerCase() || '';
      const descripcion = producto.descripcion?.toLowerCase() || '';
      
      return nombre.includes(termino) || 
             categoria.includes(termino) || 
             descripcion.includes(termino);
    });
  }
}