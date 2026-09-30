import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full'
  },
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./features/dashboard/dashboard')
        .then(m => m.Dashboard)
  },
  {
    path: 'professional-profiles',
    loadComponent: () =>
      import('./features/professional-profiles/professional-profiles')
        .then(m => m.ProfessionalProfiles)
  },
  {
    path: 'users',
    loadComponent: () =>
      import('./features/users/users')
        .then(m => m.Users)
  }
];
