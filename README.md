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

* Calculo de rotas reais utilizando OSRM.

* Exibicao da geometria real do percurso no mapa.

* Exibicao da distancia e duracao estimada da rota.

* Opcoes de deslocamento e estimativas de tempo para diferentes modais.

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

## **Rotas**

O aplicativo Flutter possui um fluxo de calculo e exibicao de rotas integrado ao mapa.

O fluxo atual funciona da seguinte forma:

```text
Usuario seleciona um local
        |
        v
Flutter define o destino
        |
        v
Localizacao atual do dispositivo
        |
        v
RouteRequest
        |
        v
RouteService
        |
        v
OSRM Routing API
        |
        +--> distancia real
        |
        +--> duracao estimada
        |
        +--> geometria da rota
        |
        v
RouteResult
        |
        v
Flutter Map
        |
        +--> desenha a rota
        |
        +--> ajusta automaticamente a camera
        |
        +--> apresenta dados do percurso
```

O calculo de rota utiliza o serviço publico de roteamento do **OSRM (Open Source Routing Machine)**, evitando a necessidade de uma API comercial de roteamento.

A requisicao utiliza as coordenadas de origem e destino e solicita a geometria completa do percurso em formato GeoJSON:

```text
/route/v1/driving/{origem};{destino}?overview=full&geometries=geojson
```

A resposta utilizada pelo aplicativo fornece:

* distancia do percurso em metros;

* duracao estimada em segundos;

* lista de coordenadas que representa a geometria da rota.

Esses dados sao convertidos para os objetos de dominio utilizados pelo aplicativo.

### **Componentes da rota**

A implementacao esta organizada nos seguintes arquivos:

```text
flutter_application/
|
+-- lib/
    |
    +-- features/
        |
        +-- map/
            |
            +-- domain/
            |   |
            |   +-- route_coordinate.dart
            |   +-- route_request.dart
            |   +-- route_result.dart
            |
            +-- services/
            |   |
            |   +-- route_service.dart
            |
            +-- presentation/
                |
                +-- maps_screen.dart
```

O `RouteRequest` representa os dados de origem e destino utilizados no calculo.

O `RouteCoordinate` representa uma coordenada geografica de latitude e longitude.

O `RouteResult` representa o resultado retornado pelo servico de rota, incluindo:

* pontos da geometria;

* distancia em metros;

* duracao em segundos.

O `RouteService` e responsavel por:

* montar a requisicao para o OSRM;

* realizar a chamada HTTP;

* validar a resposta recebida;

* extrair distancia e duracao;

* converter a geometria retornada pelo OSRM em coordenadas utilizadas pelo Flutter.

O `MapsScreen` integra o servico ao fluxo visual do aplicativo. A rota e calculada quando um destino e selecionado e, quando o resultado e recebido, seus pontos sao convertidos para `LatLng` e desenhados no mapa.

A camera do mapa tambem e ajustada automaticamente para enquadrar o percurso completo.

### **Origem e destino**

A origem da rota utiliza a localizacao atual do dispositivo quando disponivel.

O destino pode ser definido a partir de um local selecionado no aplicativo, incluindo locais retornados pelas recomendacoes da inteligencia artificial.

O fluxo de recomendacao com IA utiliza o local retornado pela recomendacao como destino:

```text
Recomendacao IA
    |
    v
Place selecionado
    |
    v
_routeDestination
    |
    v
_calculateRoute()
    |
    v
RouteService
    |
    v
OSRM
```

Da mesma forma, um local selecionado diretamente pelo usuario pode ser utilizado como destino.

### **Dados reais da rota**

Diferentemente das estimativas anteriores, a rota principal apresentada no mapa utiliza os dados reais retornados pelo OSRM para distancia e duracao do percurso.

A duracao retornada pelo servico e convertida para minutos e utilizada na apresentacao das opcoes de deslocamento.

Quando o servico de rota ainda esta sendo calculado, a interface apresenta o estado de carregamento. Caso ocorra uma falha, o erro e armazenado no estado da tela e a rota e removida da visualizacao.

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
| Roteamento                   | OSRM                            |
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

O calculo de rotas nao utiliza um endpoint do Spring Boot. O aplicativo Flutter realiza a consulta de roteamento diretamente ao OSRM.

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

O fluxo de roteamento possui uma integracao separada:

```text
Flutter

    |
    +--> localizacao atual
    |
    +--> destino selecionado
            |
            v
        RouteService
            |
            v
        OSRM
            |
            v
        rota real
            |
            v
        Flutter Map
```

A URL atualmente configurada para o backend publicado e:

```text
https://aeon-backend-deploy.onrender.com
```

O backend atua como camada intermediaria para integracoes que nao devem depender diretamente de credenciais externas no aplicativo, como a consulta de clima.

O servico de roteamento e uma excecao a esse fluxo, pois o Flutter consulta diretamente o OSRM para obter os dados da rota.

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

* testes automatizados relacionados a validacao de reviews;

* obtencao da localizacao atual no aplicativo;

* calculo de rota utilizando OSRM;

* obtencao da distancia e duracao retornadas pelo servico de roteamento;

* desenho da geometria real da rota no mapa;

* ajuste automatico da camera para enquadramento do percurso.

O backend publicado foi validado atraves dos endpoints:

```http
GET  /api/health

POST /weather

POST /reviews/validate
```

O fluxo de roteamento foi validado separadamente no aplicativo Flutter por meio da integracao direta com o OSRM.

## **Desenvolvedores**

* Manoela Oliveira

* Paula Carregal

* Pedro Santiago

* Vanessa Fittipaldi
