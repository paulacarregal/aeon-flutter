# **Backend Spring Boot - AEON**

## **Objetivo**

O backend oficial do AEON e uma API REST desenvolvida em Java com Spring Boot. Ele centraliza as operacoes que precisam passar por servidor, evitando que o aplicativo dependa de backends legados ou chamadas locais.

Arquitetura atual:

```text
Flutter
    -> Spring Boot REST API
        -> Firebase / Firestore / APIs externas

Angular
    -> Spring Boot REST API
```

O FastAPI usado em uma etapa anterior foi consolidado no Spring Boot e nao e componente atual da solucao.

## **Responsabilidades Atuais**

* Disponibilizar endpoints REST para os clientes Flutter e Angular.
* Consultar usuarios do Firebase Authentication.
* Gerenciar perfis profissionais no Cloud Firestore.
* Validar e enriquecer reviews antes da gravacao pelo aplicativo.
* Consultar dados climaticos via OpenWeather sem expor a chave diretamente ao app.
* Expor documentacao interativa via Swagger/OpenAPI.
* Manter uma camada central para evolucao de seguranca e integracoes.

## **Tecnologias**

| Tecnologia         | Uso                                     |
| ------------------ | --------------------------------------- |
| Java 21            | Linguagem e runtime do backend          |
| Spring Boot 4      | Framework principal                     |
| Spring MVC         | Criacao da API REST                     |
| Spring Security    | Configuracao de seguranca               |
| Bean Validation    | Validacao de entrada                    |
| Firebase Admin SDK | Integracao servidor com Firebase        |
| Cloud Firestore    | Persistencia atual dos dados principais |
| OpenWeather        | Servico externo de clima                |
| Swagger/OpenAPI    | Documentacao da API                     |
| Maven              | Build e dependencias                    |
| Render             | Hospedagem do backend                   |

Observacao: existem dependencias de JPA/H2 no projeto, mas elas nao sao usadas como persistencia ativa do fluxo de Professional Profile. Esse fluxo usa Firestore por meio do Firebase Admin SDK.

## **Arquitetura Interna**

```text
Controller
    -> Service
        -> Firebase Admin SDK / Firestore
        -> Catalogo AEON
        -> APIs externas
```

Camadas principais:

* `controller`: recebe requisicoes HTTP e define rotas REST.
* `service`: concentra regras de negocio e integracoes.
* `dto`: define contratos de entrada e saida.
* `config`: concentra configuracoes de Firebase, CORS e seguranca.
* `exception`: padroniza respostas de erro.

## **Estrutura do Backend**

```text
aeon-backend/
|
|-- src/
|   |-- main/
|   |   |-- java/com/aeon/backend/
|   |   |   |-- config/
|   |   |   |-- controller/
|   |   |   |-- dto/
|   |   |   |-- exception/
|   |   |   |-- service/
|   |   |
|   |   |-- resources/
|   |       |-- data/
|   |           |-- sp_catalog.json
|   |
|   |-- test/
|       |-- java/com/aeon/backend/
|           |-- controller/
|           |-- service/
|
|-- pom.xml
|-- mvnw
|-- mvnw.cmd
|-- Dockerfile
```

O arquivo `sp_catalog.json` contem os dados estruturados dos locais utilizados no enriquecimento das reviews.

## **Endpoints**

Base local padrao:

```text
http://localhost:8080
```

Base publicada:

```text
https://aeon-backend-deploy.onrender.com
```

## **Health**

```http
GET /api/health
```

Retorna o estado basico da API.

Exemplo:

```json
{
  "status": "UP",
  "service": "AEON Backend",
  "version": "1.0.0"
}
```

Teste local:

```powershell
Invoke-RestMethod `
    -Uri "http://localhost:8080/api/health" `
    -Method GET
```

Teste publicado:

```powershell
Invoke-RestMethod `
    -Uri "https://aeon-backend-deploy.onrender.com/api/health" `
    -Method GET
```

## **Usuarios**

```http
GET /api/users
```

Consulta usuarios cadastrados no Firebase Authentication.

Esse endpoint depende da configuracao do Firebase Admin SDK no ambiente do backend.

## **Perfis Profissionais**

```http
GET    /api/professional-profiles
GET    /api/professional-profiles/{id}
POST   /api/professional-profiles
PUT    /api/professional-profiles/{id}
DELETE /api/professional-profiles/{id}
```

Os perfis profissionais representam contas de estabelecimentos, marcas ou criadores associados ao AEON. A persistencia atual desse fluxo e no Cloud Firestore.

## **Clima**

```http
POST /weather
```

Payload:

```json
{
  "city": "Sao Paulo"
}
```

Resposta:

```json
{
  "temperature": 22.5,
  "humidity": 70,
  "windSpeed": 3.2,
  "description": "ceu limpo"
}
```

Teste local:

```powershell
$body = @{
    city = "Sao Paulo"
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://localhost:8080/weather" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

Teste publicado:

```powershell
$body = @{
    city = "Sao Paulo"
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "https://aeon-backend-deploy.onrender.com/weather" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

O backend centraliza essa chamada para o OpenWeather, evitando expor diretamente a chave da API externa no aplicativo Flutter.

## **Validacao de Reviews**

O fluxo de reviews recebe os dados enviados pelo Flutter, valida os campos, identifica o local e utiliza os metadados do catalogo AEON para enriquecer a resposta.

Endpoints:

```http
POST /reviews/validate
POST /reviews/validate-and-enrich
```

O endpoint e consumido pelo Flutter antes da review ser gravada no Firestore pelo app.

Payload:

```json
{
  "userId": "uid-do-usuario",
  "placeId": "bar-tan-tan",
  "placeName": "Bar Tan Tan",
  "address": "Rua informada",
  "rating": 5,
  "comment": "Experiencia muito boa",
  "tags": ["ambiente", "drinks"],
  "spendRange": "50+"
}
```

Resposta:

```json
{
  "userId": "uid-do-usuario",
  "placeId": "bar-tan-tan",
  "placeName": "Bar Tan Tan",
  "address": "Rua Fradique Coutinho, 153 - Pinheiros",
  "rating": 5,
  "comment": "Experiencia muito boa",
  "tags": [
    "ambiente",
    "drinks",
    "indoor",
    "night",
    "premium",
    "social",
    "urban"
  ],
  "spendRange": "50+",
  "profileHints": [
    "Pioneiro Urbano",
    "Explorador Social"
  ],
  "reviewPrompts": [
    "drinks",
    "ambiente",
    "musica",
    "fila",
    "preco"
  ],
  "source": "aeon-spring",
  "status": "validated"
}
```

### **Catalogo utilizado na validacao**

O catalogo esta localizado em:

```text
src/main/resources/data/sp_catalog.json
```

Ele contem informacoes estruturadas dos locais, como:

* `id`;
* `name`;
* `address`;
* `tags`;
* `profileHints`;
* `reviewPrompts`;
* demais metadados utilizados pela experiencia AEON.

Fluxo:

```text
Flutter
    |
    | POST /reviews/validate
    v
Spring Boot
    |
    +--> valida payload
    |
    +--> identifica local
    |
    +--> consulta sp_catalog.json
    |
    +--> combina tags
    |
    +--> adiciona profileHints
    |
    +--> adiciona reviewPrompts
    |
    v
ReviewValidationResponse
    |
    v
Flutter
    |
    +--> grava resultado no Firestore
```

### **Camadas de validacao**

A implementacao atual possui a camada:

```text
src/main/java/com/aeon/backend/service/ReviewService.java
```

Tambem foi incorporado o servico:

```text
src/main/java/com/aeon/backend/service/ReviewValidationService.java
```

A entrega inclui testes automatizados associados ao novo fluxo:

```text
src/test/java/com/aeon/backend/controller/ReviewControllerTest.java

src/test/java/com/aeon/backend/service/ReviewValidationServiceTest.java
```

## **Firebase**

O backend usa Firebase Admin SDK. A credencial administrativa deve ser configurada no ambiente do servidor por meio de:

```text
GOOGLE_APPLICATION_CREDENTIALS
```

O aplicativo Flutter continua usando Firebase Authentication para login. O backend usa o Firebase Admin SDK para operacoes do lado servidor.

### **Configuracao local**

A credencial administrativa nao deve ser adicionada ao Git.

Para executar localmente, configure a variavel de ambiente apontando para uma credencial Firebase valida.

Exemplo no PowerShell:

```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\caminho\seguro\firebase-service-account.json"
```

Depois execute o backend no mesmo terminal.

No ambiente publicado, a credencial deve ser configurada de forma segura no ambiente do servidor.

## **Swagger**

Documentacao publicada:

```text
https://aeon-backend-deploy.onrender.com/swagger-ui/index.html
```

Quando o backend estiver rodando localmente:

```text
http://localhost:8080/swagger-ui/index.html
```

O Swagger permite visualizar os endpoints e testar as requisicoes da API.

## **Execucao Local**

### **Pre-requisitos**

Antes de executar o backend, verificar:

```powershell
java -version
```

A versao esperada e Java 21.

Tambem e necessario ter o projeto clonado e acessar a pasta do backend:

```powershell
cd aeon-backend
```

### **Opcao 1 — Maven instalado**

Se o Maven estiver instalado:

```powershell
mvn spring-boot:run
```

### **Opcao 2 — Maven Wrapper**

A opcao recomendada para garantir o Maven utilizado pelo projeto e:

```powershell
.\mvnw.cmd spring-boot:run
```

Quando o servidor iniciar, a API ficara disponivel em:

```text
http://localhost:8080
```

### **Parar o backend**

No terminal onde o Spring Boot estiver executando:

```text
Ctrl + C
```

## **Compilacao**

Para gerar o pacote do backend:

```powershell
.\mvnw.cmd clean package -DskipTests
```

O resultado sera gerado em:

```text
target/aeon-backend-0.0.1-SNAPSHOT.jar
```

Para executar o pacote gerado:

```powershell
java -jar target/aeon-backend-0.0.1-SNAPSHOT.jar
```

## **Testes Automatizados**

Para executar todos os testes:

```powershell
.\mvnw.cmd clean test
```

Os testes relacionados a validacao de reviews ficam em:

```text
src/test/java/com/aeon/backend/controller/ReviewControllerTest.java
src/test/java/com/aeon/backend/service/ReviewValidationServiceTest.java
```

O objetivo desses testes e validar o comportamento das camadas de controller e servico relacionadas ao fluxo de reviews.

## **Validacao Manual da API**

Depois de iniciar o backend localmente, recomenda-se validar nesta ordem:

### 1. Health

```powershell
Invoke-RestMethod `
    -Uri "http://localhost:8080/api/health" `
    -Method GET
```

### 2. Clima

```powershell
$body = '{"city":"Sao Paulo"}'

Invoke-RestMethod `
    -Uri "http://localhost:8080/weather" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

### 3. Review

```powershell
$body = @{
    userId     = "teste-flutter"
    placeId    = "bar-tan-tan"
    placeName  = "Bar Tan Tan"
    address    = "Rua Fradique Coutinho, 153 - Pinheiros"
    rating     = 5
    comment    = "Experiencia muito boa"
    tags       = @("ambiente", "drinks")
    spendRange = "50+"
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri "http://localhost:8080/reviews/validate" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

A resposta esperada deve apresentar o status de validacao e os dados enriquecidos pelo catalogo AEON.

## **Backend Publicado**

O backend utilizado pela aplicacao esta publicado em:

```text
https://aeon-backend-deploy.onrender.com
```

Principais verificacoes:

```text
GET  /api/health
POST /weather
POST /reviews/validate
```

O servico publicado foi utilizado para validar os fluxos principais da API.

O Render pode apresentar um pequeno tempo de inicializacao quando o servico retorna de um periodo de inatividade.

## **Deploy**

O backend de deploy possui um repositorio separado do repositorio principal da aplicacao.

Repositorio de deploy:

```text
Manu11000/aeon-backend-deploy
```

Branch utilizada para o deploy:

```text
main
```

A aplicacao completa permanece no repositorio principal do AEON, na branch:

```text
entrega-aeon
```

Estrutura:

```text
Repositorio principal
    |
    +--> Flutter
    +--> Angular
    +--> Spring Boot
         |
         +--> branch entrega-aeon

Repositorio de deploy
    |
    +--> aeon-backend-deploy
         |
         +--> main
              |
              +--> Render
```

Essa separacao permite manter o backend utilizado pelo Render em um repositorio especifico sem alterar a organizacao do repositorio principal da aplicacao.

## **Docker**

O backend possui `Dockerfile` para execucao em ambiente de deploy.

O processo utiliza:

```text
Java 21
    ->
Maven Wrapper
    ->
Spring Boot
    ->
aeon-backend-0.0.1-SNAPSHOT.jar
```

O container utiliza a porta definida pela variavel `PORT`, com fallback para `8080` em ambiente local.

## **Integracao com Flutter**

O Flutter utiliza o backend publicado como API principal para os fluxos que dependem do servidor.

Configuracao atual:

```text
https://aeon-backend-deploy.onrender.com
```

Principais integracoes:

```text
Flutter
    |
    +--> GET /api/health
    |
    +--> POST /weather
    |
    +--> POST /reviews/validate
    |
    +--> usuarios
    |
    +--> perfis profissionais
```

No fluxo de reviews:

```text
Flutter
    |
    +--> envia review
    |
    v
Spring Boot
    |
    +--> valida
    +--> enriquece
    |
    v
Flutter
    |
    +--> grava resultado no Firestore
```

## **Integracao com Angular**

O dashboard Angular utiliza a mesma API Spring Boot para os recursos administrativos disponibilizados pelo backend.

Fluxo:

```text
Angular Dashboard
    |
    v
Spring Boot REST API
    |
    +--> Firebase Authentication
    +--> Cloud Firestore
```

A base publicada utilizada pelo dashboard e:

```text
https://aeon-backend-deploy.onrender.com
```

## **Ordem Recomendada para Executar o Projeto**

Para executar a solucao completa localmente:

### **1. Backend**

```powershell
cd aeon-backend
.\mvnw.cmd spring-boot:run
```

Verificar:

```text
http://localhost:8080/api/health
```

### **2. Angular**

Em outro terminal:

```powershell
cd aeon-angular
npm install
ng serve
```

Acessar:

```text
http://localhost:4200
```

### **3. Flutter**

Em outro terminal:

```powershell
cd flutter_application
flutter pub get
flutter run
```

O Flutter esta configurado para utilizar o backend publicado, salvo quando houver configuracao especifica de ambiente para executar contra o backend local.

## **Observacoes Importantes**

* O backend oficial atual e Spring Boot.
* O FastAPI legado nao deve ser iniciado para executar a arquitetura atual.
* O backend utiliza Java 21.
* O Flutter utiliza o backend Spring Boot para clima e validacao de reviews.
* O catalogo `sp_catalog.json` faz parte do backend e e utilizado no enriquecimento das reviews.
* Credenciais Firebase nao devem ser versionadas.
* O backend local utiliza a porta `8080` por padrao.
* O Render utiliza a porta fornecida pela variavel de ambiente `PORT`.
* O backend publicado pode apresentar demora na primeira requisicao apos inatividade.
* O Swagger pode ser utilizado para inspecionar e testar a API.
* Alteracoes destinadas ao ambiente de deploy devem respeitar a separacao entre o repositorio principal e o repositorio `aeon-backend-deploy`.
