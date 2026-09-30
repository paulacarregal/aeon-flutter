import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { RouterLink, RouterLinkActive } from '@angular/router';

import { User, UserService } from '../../core/services/user.service';
import {
  ProfessionalProfile,
  ProfessionalProfileService
} from '../../core/services/professional-profile.service';

@Component({
  selector: 'app-dashboard',
  imports: [RouterLink, RouterLinkActive],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css',
})
export class Dashboard implements OnInit {

  private readonly userService = inject(UserService);

  private readonly professionalProfileService = inject(
    ProfessionalProfileService
  );

  private readonly cdr = inject(ChangeDetectorRef);

  users: User[] = [];
  professionals: ProfessionalProfile[] = [];

  ngOnInit(): void {
    console.log('Dashboard iniciado');

    this.loadUsers();
    this.loadProfessionals();
  }

  private loadUsers(): void {

    this.userService.getAll().subscribe({

      next: (data) => {

        console.log('Dashboard - usuários recebidos:', data);
        console.log('Dashboard - quantidade de usuários:', data.length);

        this.users = [...data];

        this.cdr.detectChanges();
      },

      error: (err) => {

        console.error(
          'Dashboard - erro ao carregar usuários:',
          err
        );

      }

    });
  }

  private loadProfessionals(): void {

    this.professionalProfileService.getAll().subscribe({

      next: (data) => {

        console.log(
          'Dashboard - profissionais recebidos:',
          data
        );

        console.log(
          'Dashboard - quantidade de profissionais:',
          data.length
        );

        this.professionals = [...data];

        this.cdr.detectChanges();
      },

      error: (err) => {

        console.error(
          'Dashboard - erro ao carregar profissionais:',
          err
        );

      }

    });
  }

  get totalUsers(): number {
    return this.users.length;
  }

  get totalProfessionals(): number {
    return this.professionals.length;
  }

  get activeUsers(): number {
    return this.users.filter(
      user => !user.disabled
    ).length;
  }

  get pendingProfessionals(): number {
    return this.professionals.filter(
      professional =>
        professional.status?.toLowerCase() === 'pending' ||
        professional.status?.toLowerCase() === 'pendente'
    ).length;
  }
}