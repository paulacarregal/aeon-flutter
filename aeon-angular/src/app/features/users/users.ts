import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { User, UserService } from '../../core/services/user.service';

@Component({
  selector: 'app-users',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './users.html',
  styleUrl: './users.css',
})
export class Users implements OnInit {

  private readonly userService = inject(UserService);

  private readonly cdr = inject(ChangeDetectorRef);

  users: User[] = [];
  loading = true;
  error = '';

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.loading = true;
    this.error = '';

    const startTime = performance.now();

    this.userService.getAll().subscribe({
      next: (data) => {
        const endTime = performance.now();

        console.log(
          `⏱️ Usuários carregados em ${(endTime - startTime).toFixed(2)} ms`
        );

        console.log('Usuários recebidos do backend:', data);
        console.log('Quantidade recebida:', data.length);

        this.users = [...data];
        this.loading = false;
        this.cdr.detectChanges();

        console.log('Quantidade em this.users:', this.users.length);
      },

      error: (err) => {
        console.error('Erro ao carregar usuários:', err);

        this.error = 'Não foi possível carregar os usuários.';
        this.loading = false;
      }
    });
  }

  get activeUsers(): number {
    return this.users.filter(user => !user.disabled).length;
  }

  get disabledUsers(): number {
    return this.users.filter(user => user.disabled).length;
  }

  get initials(): string {
    return '';
  }

  getInitials(name: string): string {
    if (!name) {
      return '?';
    }

    return name
      .split(' ')
      .filter(Boolean)
      .slice(0, 2)
      .map(part => part.charAt(0).toUpperCase())
      .join('');
  }

  getStatus(user: User): string {
    return user.disabled ? 'Desativado' : 'Ativo';
  }
}