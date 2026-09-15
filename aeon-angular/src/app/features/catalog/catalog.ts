import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';

import {
  CatalogItem,
  CatalogService
} from '../../core/services/catalog.service';

@Component({
  selector: 'app-catalog',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './catalog.html',
  styleUrl: './catalog.css',
})
export class Catalog implements OnInit {

  private readonly catalogService = inject(CatalogService);

  items: CatalogItem[] = [];
  count = 0;
  loading = true;
  error = '';

  ngOnInit(): void {
    console.log('CATALOG INICIADO');
    this.loadCatalog();
  }

  loadCatalog(): void {
    this.loading = true;
    this.error = '';

    this.catalogService.getAll().subscribe({
      next: (response) => {
        console.log('CATALOG - resposta recebida:', response);
        this.items = response.items ?? [];
        this.count = response.count ?? this.items.length;
        this.loading = false;
      },

      error: (err) => {
        console.error('Erro ao carregar catálogo:', err);

        this.error = 'Não foi possível carregar o catálogo.';
        this.loading = false;
      }
    });
  }

  getKindLabel(kind: string): string {
    switch (kind) {
      case 'place':
        return 'Local';

      case 'event':
        return 'Evento';

      case 'cinema':
        return 'Cinema';

      default:
        return kind;
    }
  }

  getPriceLabel(priceLevel: number): string {
    if (priceLevel <= 0) {
      return 'Grátis';
    }

    return 'R$'.padEnd(priceLevel + 1, '$');
  }
}

