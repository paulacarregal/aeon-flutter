import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface ProfessionalProfile {
  id: string | null;
  ownerUid: string;
  type: string;
  displayName: string;
  category: string;
  document: string;
  description: string;
  phone: string;
  website: string;
  instagram: string;
  city: string;
  address: string;
  status: string;
  active: boolean;
}

@Injectable({
  providedIn: 'root'
})
export class ProfessionalProfileService {

  private readonly http = inject(HttpClient);

  private readonly apiUrl =
    'https://aeon-backend-deploy.onrender.com/api/professional-profiles';

  getAll(): Observable<ProfessionalProfile[]> {
    return this.http.get<ProfessionalProfile[]>(this.apiUrl);
  }

  getById(id: number) {
    return this.http.get<ProfessionalProfile>(
      `${this.apiUrl}/${id}`
    );
  }

  create(profile: Omit<ProfessionalProfile, 'id' | 'active'>) {
    return this.http.post<ProfessionalProfile>(
      this.apiUrl,
      profile
    );
  }

  update(
    id: number,
    profile: Omit<ProfessionalProfile, 'id' | 'active'>
  ) {
    return this.http.put<ProfessionalProfile>(
      `${this.apiUrl}/${id}`,
      profile
    );
  }

  delete(id: number) {
    return this.http.delete<void>(
      `${this.apiUrl}/${id}`
    );
  }
}