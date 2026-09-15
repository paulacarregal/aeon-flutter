import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface CatalogItem {
  id: string;
  name: string;
  kind: string;
  area: string;
  address: string;
  latitude: number;
  longitude: number;
  rating: number;
  priceLevel: number;
  priceRange: string;
  openingLabel: string;
  image: string;
  tags: string[];
  profileHints: string[];
  indoor: boolean;
  daytime: boolean;
  nightlife: boolean;
  startsAtLabel?: string;
  featuredTitle?: string;
  reviewPrompts: string[];
  notificationTemplate: string;
}

export interface CatalogResponse {
  items: CatalogItem[];
  count: number;
}

@Injectable({
  providedIn: 'root'
})
export class CatalogService {
  private readonly http = inject(HttpClient);

  private readonly apiUrl =
    'https://aeon-backend-deploy.onrender.com/catalog';

  getAll(): Observable<CatalogResponse> {
    return this.http.get<CatalogResponse>(this.apiUrl);
  }
}
