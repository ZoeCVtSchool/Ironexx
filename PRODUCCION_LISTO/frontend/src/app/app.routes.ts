import { Routes } from '@angular/router';

export const routes: Routes = [
    { path: 'login', loadComponent: () => import('./pages/login/login').then(m => m.LoginComponent) },
    { path: 'dashboard', loadComponent: () => import('./pages/dashboard/dashboard').then(m => m.DashboardComponent) },
  { path: '', loadComponent: () => import('./pages/home/home').then(m => m.HomeComponent) },
  { path: 'catalogo', loadComponent: () => import('./pages/catalogo/catalogo').then(m => m.CatalogoComponent) },
  { path: 'nosotros', loadComponent: () => import('./pages/nosotros/nosotros').then(m => m.NosotrosComponent) },
  { path: 'contacto', loadComponent: () => import('./pages/contacto/contacto').then(m => m.ContactoComponent) },
  { path: 'cotizacion', loadComponent: () => import('./pages/cotizacion/cotizacion').then(m => m.CotizacionComponent) },
  { path: 'terminos-de-uso', loadComponent: () => import('./pages/terms-of-use/terms-of-use').then(m => m.TermsOfUseComponent) },
  { path: 'aviso-de-privacidad', loadComponent: () => import('./pages/aviso-de-privacidad/aviso-de-privacidad').then(m => m.AvisoDePrivacidadComponent) },
  //{ path: 'nosotros', loadComponent: () => import('./nosotros.component') },
  //{ path: 'contacto', loadComponent: () => import('./contacto.component') },
];
