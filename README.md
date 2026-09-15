# **AEON**

## **Visao Geral**

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

## **Funcionalidades**

### **Aplicativo Flutter**

* Cadastro e login com Firebase Authentication.
* Onboarding por quiz para formacao do perfil de recomendacao.
* Perfil do usuario com preferencias ajustaveis.
* Feed de reviews, curtidas e favoritos.
* Criacao e publicacao de avaliacoes.
* Validacao de reviews via Spring Boot.
* Mapa interativo com OpenStreetMap.
* Captura de localizacao do dispositivo.
* Consulta de clima via backend Spring Boot.
* Recomendacoes personalizadas com apoio de Firebase AI Logic/Gemini.
* Simulacao de rotas e modais de deslocamento.

### **Backend Spring Boot**

* API REST principal do AEON.
* Health check.
* Consulta de usuarios do Firebase Authentication.
* CRUD de perfis profissionais usando Firestore.
* Validacao e enriquecimento de reviews.
* Integracao com OpenWeather para clima.
* Documentacao via Swagger/OpenAPI.
* Configuracao de seguranca com Spring Security.

### **Dashboard Angular**

* Painel administrativo web.
* Consulta de usuarios.
* Consulta e gerenciamento de perfis profissionais.
* Metricas e visualizacao geral da plataforma.
* Formularios e filtros para apoio administrativo.

## **Tecnologias Adotadas**

| Categoria                    | Tecnologia                      |
| ---------------------------- | ------------------------------- |
| Mobile                       | Flutter, Dart                   |
| Estado no app                | Provider                        |
| Backend                      | Java, Spring Boot, Spring MVC   |
| API                          | REST, JSON                      |
| Seguranca backend            | Spring Security                 |
| Autenticacao                 | Firebase Authentication         |
| Banco atual                  | Cloud Firestore                 |
| Integracao Firebase servidor | Firebase Admin SDK              |
| IA                           | Firebase AI Logic / Gemini      |
| Clima                        | OpenWeather via Spring Boot     |
| Mapas                        | Flutter Map / OpenStreetMap     |
| Localizacao                  | Geolocator                      |
| Dashboard web                | Angular, TypeScript, HttpClient |
| Documentacao API             | Swagger / OpenAPI               |
| Build backend                | Maven                           |
| Hospedagem backend           | Render                          |
| IDEs de apoio                | Android Studio, VS Code         |
| Versionamento                | Git, GitHub                     |

Observacao: o projeto contem dependencias de JPA/H2 no backend Spring, mas o fluxo atual de Professional Profile usa Firestore via Firebase Admin SDK. H2/JPA nao sao a persistencia ativa desse fluxo.

## **Endpoints Principais**

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
POST /reviews/validate-and-enrich
```

Swagger:

```text
https://aeon-backend-deploy.onrender.com/swagger-ui/index.html
```

## **Catalogo e Validacao de Reviews**

O backend utiliza o catalogo estruturado do AEON localizado em:

```text
aeon-backend/src/main/resources/data/sp_catalog.json
```

O catalogo fornece informacoes dos locais utilizadas durante a validacao e enriquecimento das reviews, incluindo:

* identificacao do local;
* nome;
* endereco;
* tags;
* `profileHints`;
* `reviewPrompts`;
* demais metadados estruturados das experiencias.

O fluxo atual de review segue a seguinte estrutura:

```text
Flutter
    -> POST /reviews/validate
        -> Spring Boot
            -> validacao dos dados
            -> identificacao do local
            -> consulta ao catalogo AEON
            -> combinacao de tags
            -> enriquecimento da review
        -> resposta validada
    -> gravacao no Firestore
```

A implementacao integrada tambem possui uma camada especifica de validacao:

```text
aeon-backend/src/main/java/com/aeon/backend/service/ReviewValidationService.java
```

E testes automatizados relacionados ao controller e ao servico:

```text
aeon-backend/src/test/java/com/aeon/backend/controller/ReviewControllerTest.java
aeon-backend/src/test/java/com/aeon/backend/service/ReviewValidationServiceTest.java
```

## **Integracao com o Flutter**

O aplicativo Flutter utiliza uma camada central para comunicacao com o backend Spring Boot.

Principais fluxos:

```text
Flutter
    |
    +--> GET /api/health
    |
    +--> POST /weather
    |
    +--> POST /reviews/validate
    |
    +--> usuarios e perfis profissionais
```

A URL atualmente configurada para o backend publicado e:

```text
https://aeon-backend-deploy.onrender.com
```

O backend atua como camada intermediaria para integracoes que nao devem depender diretamente de credenciais externas no aplicativo, como a consulta de clima.

## **Backend Publicado**

O backend Spring Boot esta publicado no Render e possui ambiente de execucao separado da base principal da aplicacao.

Repositorio utilizado para deploy:

```text
Manu11000/aeon-backend-deploy
```

Branch de deploy:

```text
main
```

O repositorio principal da aplicacao utiliza:

```text
branch: entrega-aeon
```

A separacao e:

```text
Aplicacao AEON
    |
    +--> repositorio principal
         branch entrega-aeon

Backend para deploy
    |
    +--> aeon-backend-deploy
         branch main
         |
         +--> Render
```

## **Seguranca**

Arquivos de credenciais e configuracoes sensiveis nao fazem parte da entrega versionada.

Exemplos:

```text
google-services.json
GoogleService-Info.plist
```

As credenciais utilizadas pelo backend devem ser fornecidas por configuracao segura e variaveis de ambiente no ambiente de execucao.

Arquivos temporarios, backups, diretorios de build e artefatos gerados tambem nao fazem parte da entrega da aplicacao.

## **Estrutura**

```text
Aeon/
|-- flutter_application/   # Aplicativo Flutter
|-- aeon-backend/           # Backend Spring Boot
|-- aeon-angular/           # Dashboard Angular
|-- README.md
```

## **Execucao**

Consulte:

* `flutter_application/EXECUTE.md` para execucao do Flutter, Spring Boot e Angular.
* `flutter_application/BACKEND.md` para detalhes da API Spring Boot.

## **Validacao da Entrega**

A implementacao atual ja foi utilizada para validar os principais fluxos da arquitetura:

* compilacao do backend Spring Boot com Java 21;
* execucao do backend local;
* health check da API;
* consulta de clima;
* validacao de reviews;
* integracao do Flutter com o backend publicado;
* disponibilizacao da API no Render;
* documentacao da API via Swagger/OpenAPI;
* testes automatizados relacionados a validacao de reviews.

O backend publicado foi validado atraves dos endpoints:

```http
GET  /api/health
POST /weather
POST /reviews/validate
```

## **Desenvolvedores**

* Manoela Oliveira
* Paula Carregal
* Pedro Santiago
* Vanessa Fittipaldi
