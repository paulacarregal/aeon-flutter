# AEON

## Visao Geral

O AEON e uma plataforma multiplataforma para descoberta de experiencias urbanas personalizadas. A solucao combina perfil do usuario, localizacao, clima, avaliacoes e inteligencia artificial para recomendar locais, rotas e experiencias em Sao Paulo.

Arquitetura atual:

```text
Flutter App
    -> Spring Boot REST API
        -> Firebase Authentication
        -> Cloud Firestore
        -> APIs externas

Angular Dashboard
    -> Spring Boot REST API
```

O backend principal da aplicacao e o Spring Boot. O backend FastAPI utilizado em fase anterior foi consolidado no Spring Boot e nao faz mais parte da arquitetura atual.

## Funcionalidades

### Aplicativo Flutter

- Cadastro e login com Firebase Authentication.
- Onboarding por quiz para formacao do perfil de recomendacao.
- Perfil do usuario com preferencias ajustaveis.
- Feed de reviews, curtidas e favoritos.
- Criacao e publicacao de avaliacoes.
- Validacao de reviews via Spring Boot.
- Mapa interativo com OpenStreetMap.
- Captura de localizacao do dispositivo.
- Consulta de clima via backend Spring Boot.
- Recomendacoes personalizadas com apoio de Firebase AI Logic/Gemini.
- Simulacao de rotas e modais de deslocamento.

### Backend Spring Boot

- API REST principal do AEON.
- Health check.
- Consulta de usuarios do Firebase Authentication.
- CRUD de perfis profissionais usando Firestore.
- Validacao e enriquecimento de reviews.
- Integracao com OpenWeather para clima.
- Documentacao via Swagger/OpenAPI.
- Configuracao de seguranca com Spring Security.

### Dashboard Angular

- Painel administrativo web.
- Consulta de usuarios.
- Consulta e gerenciamento de perfis profissionais.
- Metricas e visualizacao geral da plataforma.
- Formularios e filtros para apoio administrativo.

## Tecnologias Adotadas

| Categoria | Tecnologia |
| --- | --- |
| Mobile | Flutter, Dart |
| Estado no app | Provider |
| Backend | Java, Spring Boot, Spring MVC |
| API | REST, JSON |
| Seguranca backend | Spring Security |
| Autenticacao | Firebase Authentication |
| Banco atual | Cloud Firestore |
| Integracao Firebase servidor | Firebase Admin SDK |
| IA | Firebase AI Logic / Gemini |
| Clima | OpenWeather via Spring Boot |
| Mapas | Flutter Map / OpenStreetMap |
| Localizacao | Geolocator |
| Dashboard web | Angular, TypeScript, HttpClient |
| Documentacao API | Swagger / OpenAPI |
| Build backend | Maven |
| Hospedagem backend | Render |
| IDEs de apoio | Android Studio, VS Code |
| Versionamento | Git, GitHub |

Observacao: o projeto contem dependencias de JPA/H2 no backend Spring, mas o fluxo atual de Professional Profile usa Firestore via Firebase Admin SDK. H2/JPA nao sao a persistencia ativa desse fluxo.

## Endpoints Principais

Base publicada:

```text
https://aeon-backend-deploy.onrender.com
```

Endpoints usados pela solucao atual:

```http
GET  /api/health
GET  /api/users
GET  /api/professional-profiles
GET  /api/professional-profiles/{id}
POST /api/professional-profiles
PUT  /api/professional-profiles/{id}
DELETE /api/professional-profiles/{id}
POST /weather
POST /reviews/validate
```

Swagger:

```text
https://aeon-backend-deploy.onrender.com/swagger-ui/index.html
```

## Estrutura

```text
Aeon/
|-- flutter_application/   # Aplicativo Flutter
|-- aeon-backend/          # Backend Spring Boot
|-- aeon-angular/          # Dashboard Angular
|-- README.md
```

## Execucao

Consulte:

- `flutter_application/EXECUTE.md` para execucao do Flutter, Spring Boot e Angular.
- `flutter_application/BACKEND.md` para detalhes da API Spring Boot.

## Desenvolvedores

- Manoela Oliveira
- Paula Carregal
- Pedro Santiago
- Vanessa Fittipaldi
