import {
  Component,
  OnInit,
  inject,
  ChangeDetectorRef
} from '@angular/core';

import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import {
  ProfessionalProfile,
  ProfessionalProfileService
} from '../../core/services/professional-profile.service';

@Component({
  selector: 'app-professional-profiles',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './professional-profiles.html',
  styleUrl: './professional-profiles.css',
})
export class ProfessionalProfiles implements OnInit {

  private readonly professionalProfileService = inject(
    ProfessionalProfileService
  );

  private readonly cdr = inject(ChangeDetectorRef);

  professionals: ProfessionalProfile[] = [];

  filteredProfessionals: ProfessionalProfile[] = [];

  loading = true;

  error = '';

  searchTerm = '';

  selectedStatus = '';

  selectedCategory = '';

  showForm = false;
  saving = false;

  form = {
    ownerUid: '',
    type: '',
    displayName: '',
    category: '',
    document: '',
    description: '',
    phone: '',
    website: '',
    instagram: '',
    city: '',
    address: '',
    status: 'pending'
  };

  ngOnInit(): void {
    this.loadProfessionals();
  }

  openForm(): void {
  this.showForm = true;
  this.error = '';
}

closeForm(): void {
  this.showForm = false;
  this.saving = false;
}

createProfessional(): void {
  if (
    !this.form.ownerUid ||
    !this.form.type ||
    !this.form.displayName ||
    !this.form.category ||
    !this.form.city
  ) {
    this.error = 'Preencha os campos obrigatórios.';
    return;
  }

  this.saving = true;
  this.error = '';

  this.professionalProfileService.create({
    ...this.form
  }).subscribe({
    next: (professional) => {
      console.log('Profissional criado:', professional);

      this.saving = false;
      this.showForm = false;

      this.form = {
        ownerUid: '',
        type: '',
        displayName: '',
        category: '',
        document: '',
        description: '',
        phone: '',
        website: '',
        instagram: '',
        city: '',
        address: '',
        status: 'pending'
      };

      this.loadProfessionals();
    },

    error: (err) => {
      console.error('Erro ao criar profissional:', err);

      this.error =
        'Não foi possível cadastrar o profissional.';

      this.saving = false;
    }
  });
}

  loadProfessionals(): void {
    this.loading = true;
    this.error = '';

    this.professionalProfileService.getAll().subscribe({
      next: (data) => {
        console.log('Profissionais recebidos:', data);
        console.log('Quantidade:', data.length);

        this.professionals = [...data];
        this.filteredProfessionals = [...data];
        this.loading = false;

        this.cdr.detectChanges();
      },

      error: (err) => {
        console.error('Erro ao carregar profissionais:', err);

        this.error =
          'Não foi possível carregar os perfis profissionais.';

        this.loading = false;
      }
    });
  }

  filterProfessionals(): void {
    const search = this.searchTerm
      .toLowerCase()
      .trim();

    this.filteredProfessionals = this.professionals.filter(
      (professional) => {

        const matchesSearch =
          !search ||
          professional.displayName
            ?.toLowerCase()
            .includes(search) ||
          professional.category
            ?.toLowerCase()
            .includes(search) ||
          professional.city
            ?.toLowerCase()
            .includes(search);

        const matchesStatus =
          !this.selectedStatus ||
          professional.status?.toLowerCase() ===
            this.selectedStatus.toLowerCase();

        const matchesCategory =
          !this.selectedCategory ||
          professional.category?.toLowerCase() ===
            this.selectedCategory.toLowerCase();

        return (
          matchesSearch &&
          matchesStatus &&
          matchesCategory
        );
      }
    );
  }

  get totalProfessionals(): number {
    return this.professionals.length;
  }

  get approvedProfessionals(): number {
    return this.professionals.filter(
      professional =>
        professional.status?.toLowerCase() === 'approved' ||
        professional.status?.toLowerCase() === 'aprovado'
    ).length;
  }

  get pendingProfessionals(): number {
    return this.professionals.filter(
      professional =>
        professional.status?.toLowerCase() === 'pending' ||
        professional.status?.toLowerCase() === 'pendente'
    ).length;
  }

  get rejectedProfessionals(): number {
    return this.professionals.filter(
      professional =>
        professional.status?.toLowerCase() === 'rejected' ||
        professional.status?.toLowerCase() === 'recusado'
    ).length;
  }

  getStatusLabel(status: string): string {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'aprovado':
        return 'Aprovado';

      case 'pending':
      case 'pendente':
        return 'Pendente';

      case 'rejected':
      case 'recusado':
        return 'Recusado';

      default:
        return status || 'Não informado';
    }
  }

  getStatusClass(status: string): string {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'aprovado':
        return 'approved';

      case 'pending':
      case 'pendente':
        return 'pending';

      case 'rejected':
      case 'recusado':
        return 'rejected';

      default:
        return 'pending';
    }
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
}