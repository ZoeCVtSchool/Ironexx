import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

export interface Notification {
  message: string;
  type: 'success' | 'error' | 'info';
}

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  private notificationSubject = new BehaviorSubject<Notification | null>(null);
  public notification$ = this.notificationSubject.asObservable();
  private timeout: any;

  show(message: string, type: 'success' | 'error' | 'info' = 'info') {
    this.notificationSubject.next({ message, type });
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
    // Ocultar mágicamente a los 4 segundos
    this.timeout = setTimeout(() => {
      this.notificationSubject.next(null);
    }, 4000);
  }
}
