import {
  AfterViewInit,
  Component,
  OnDestroy,
  inject
} from '@angular/core';

import { CommonModule } from '@angular/common';
import * as L from 'leaflet';

import {
  CatalogItem,
  CatalogService
} from '../../core/services/catalog.service';

@Component({
  selector: 'app-maps',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './maps.html',
  styleUrl: './maps.css',
})
export class Maps implements AfterViewInit, OnDestroy {

  private readonly catalogService = inject(CatalogService);

  private map?: L.Map;
  private markers: L.Marker[] = [];

  items: CatalogItem[] = [];
  loading = true;
  error = '';

  ngAfterViewInit(): void {
    this.initializeMap();
    this.loadCatalog();
  }

  ngOnDestroy(): void {
    this.map?.remove();
  }

  private initializeMap(): void {
    this.map = L.map('aeon-map', {
      center: [-23.5505, -46.6333],
      zoom: 14,
      zoomControl: true,
    });

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap contributors'
      }
    ).addTo(this.map);
  }

  private loadCatalog(): void {
    this.loading = true;
    this.error = '';

    this.catalogService.getAll().subscribe({
      next: (response) => {
        this.items = response.items ?? [];
        this.loading = false;
        this.renderMarkers();
      },

      error: (err) => {
        console.error('Erro ao carregar catálogo no mapa:', err);
        this.error = 'Não foi possível carregar os locais do mapa.';
        this.loading = false;
      }
    });
  }

  private renderMarkers(): void {
    if (!this.map) {
      return;
    }

    this.markers.forEach(marker => marker.remove());
    this.markers = [];

    const validItems = this.items.filter(
      item =>
        Number.isFinite(item.latitude) &&
        Number.isFinite(item.longitude) &&
        item.latitude !== 0 &&
        item.longitude !== 0
    );

    validItems.forEach(item => {
      const markerIcon = L.divIcon({
        className: 'aeon-map-marker',
        html: `
          <div class="aeon-marker-pin">
            <div class="aeon-marker-dot"></div>
          </div>
        `,
        iconSize: [34, 42],
        iconAnchor: [17, 42],
        popupAnchor: [0, -42]
      });

      const marker = L.marker(
        [item.latitude, item.longitude],
        {
          title: item.name,
          icon: markerIcon
        }
      );

      marker.bindPopup(this.buildPopup(item));

      marker.addTo(this.map!);
      this.markers.push(marker);
    });

    if (validItems.length > 0) {
      const bounds = L.latLngBounds(
        validItems.map(item => [
          item.latitude,
          item.longitude
        ] as [number, number])
      );

      this.map.fitBounds(bounds, {
        padding: [40, 40],
        maxZoom: 15
      });
    }
  }

  private buildPopup(item: CatalogItem): string {
    const rating = Number(item.rating || 0).toFixed(1);

    return `
      <div class="aeon-map-popup">
        <strong>${this.escapeHtml(item.name)}</strong>

        <div class="popup-rating">
          ★ ${rating}
        </div>

        <div class="popup-price">
          ${this.escapeHtml(item.priceRange || 'Preço não informado')}
        </div>

        <div class="popup-address">
          ${this.escapeHtml(item.address || 'Endereço não informado')}
        </div>

        <div class="popup-opening">
          ${this.escapeHtml(item.openingLabel || '')}
        </div>
      </div>
    `;
  }

  private escapeHtml(value: string): string {
    return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#039;');
  }
}

