# **Como Executar o AEON**

Este documento descreve como executar os componentes atuais do projeto:

* Aplicativo Flutter.
* Backend Spring Boot.
* Dashboard Angular.

O FastAPI legado foi removido da arquitetura atual. O backend oficial e o Spring Boot.

## **1. Pre-requisitos**

Instale e configure:

* Flutter SDK.
* Dart SDK compativel com o Flutter instalado.
* Android Studio ou VS Code.
* Java JDK 21 para o backend Spring Boot.
* Node.js e npm.
* Angular CLI.
* Git.
* Chrome, Edge, emulador Android ou dispositivo fisico.

Verificacoes uteis:

```bash id="v8v7oj"
flutter doctor
java -version
node -v
npm -v
ng version
```

O backend Spring Boot requer **Java 21**.

## **2. Estrutura do Projeto**

A partir da pasta raiz:

```text id="q4u9bc"
AeonFlutter/
|
|-- flutter_application/   # Aplicativo Flutter
|-- aeon-backend/           # Backend Spring Boot
|-- aeon-angular/           # Dashboard Angular
|-- README.md
```

Para executar a aplicacao completa localmente, recomenda-se utilizar terminais separados para cada componente.

## **3. Backend Spring Boot**

O backend pode ser utilizado de duas formas:

1. utilizando a API publicada no Render;
2. executando o Spring Boot localmente.

### **3.1 Backend publicado**

API:

```text id="7r1d4m"
https://aeon-backend-deploy.onrender.com
```

Swagger:

```text id="4s6f3h"
https://aeon-backend-deploy.onrender.com/swagger-ui/index.html
```

Health check:

```text id="h3y6q8"
https://aeon-backend-deploy.onrender.com/api/health
```

Quando o objetivo for apenas executar o Flutter ou Angular utilizando o ambiente publicado, nao e necessario iniciar o Spring Boot localmente.

### **3.2 Executar o backend localmente**

Abra um terminal na raiz do projeto:

```powershell id="5h0p9a"
cd aeon-backend
```

Com Maven instalado:

```powershell id="p1z4b7"
mvn spring-boot:run
```

No Windows, a opcao recomendada e utilizar o Maven Wrapper:

```powershell id="w6c2q1"
.\mvnw.cmd spring-boot:run
```

O servidor sera iniciado, por padrao, em:

```text id="e3s9p5"
http://localhost:8080
```

### **3.3 Verificar o backend local**

Em outro terminal:

```powershell id="u7k1r9"
Invoke-RestMethod `
    -Uri "http://localhost:8080/api/health" `
    -Method GET
```

Uma resposta esperada e semelhante a:

```json id="j5w2x8"
{
  "status": "UP",
  "service": "AEON Backend",
  "version": "1.0.0"
}
```

### **3.4 Swagger local**

Com o backend rodando:

```text id="f0m6s3"
http://localhost:8080/swagger-ui/index.html
```

O Swagger permite consultar os endpoints disponíveis e executar requisicoes diretamente pelo navegador.

## **4. Configuracao do Firebase para o Backend**

O backend utiliza Firebase Admin SDK para operacoes do lado servidor.

A credencial administrativa deve ser fornecida por configuracao de ambiente e **nao deve ser adicionada ao Git**.

A variavel utilizada e:

```text id="d8v4k2"
GOOGLE_APPLICATION_CREDENTIALS
```

No PowerShell, exemplo:

```powershell id="z1m7q4"
$env:GOOGLE_APPLICATION_CREDENTIALS="C:\caminho\seguro\firebase-service-account.json"
```

Depois execute:

```powershell id="n4b8x0"
.\mvnw.cmd spring-boot:run
```

Os arquivos de credenciais do Firebase utilizados pelo aplicativo tambem devem permanecer fora da entrega versionada quando forem arquivos de ambiente/seguranca.

## **5. Testes Automatizados do Backend**

Para executar todos os testes:

```powershell id="c3r9v1"
cd aeon-backend
.\mvnw.cmd clean test
```

Os testes relacionados ao fluxo de reviews incluem:

```text id="a8k5s2"
src/test/java/com/aeon/backend/controller/ReviewControllerTest.java

src/test/java/com/aeon/backend/service/ReviewValidationServiceTest.java
```

Para apenas gerar o pacote sem executar os testes:

```powershell id="m6x2p8"
.\mvnw.cmd clean package -DskipTests
```

O pacote sera gerado em:

```text id="r5t1n7"
target/aeon-backend-0.0.1-SNAPSHOT.jar
```

Para executar o pacote:

```powershell id="q9c4w6"
java -jar target/aeon-backend-0.0.1-SNAPSHOT.jar
```

Para parar o servidor:

```text id="k2v8d1"
Ctrl + C
```

## **6. Testar o Endpoint de Clima**

Com o backend local executando:

```powershell id="s7p3h0"
$body = '{"city":"Sao Paulo"}'

Invoke-RestMethod `
    -Uri "http://localhost:8080/weather" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

O mesmo fluxo pode ser testado no backend publicado:

```powershell id="b4n9q6"
$body = '{"city":"Sao Paulo"}'

Invoke-RestMethod `
    -Uri "https://aeon-backend-deploy.onrender.com/weather" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

Fluxo:

```text id="t5y1c7"
Flutter
    |
    v
Spring Boot
    |
    v
OpenWeather
```

A chave do OpenWeather nao precisa ficar exposta diretamente no aplicativo para que o backend realize a integracao.

## **7. Testar Validacao de Reviews**

A API possui os endpoints:

```http id="p8m3x6"
POST /reviews/validate
POST /reviews/validate-and-enrich
```

Exemplo de teste local:

```powershell id="h2q7v9"
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

Teste contra o backend publicado:

```powershell id="x4n8s1"
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
    -Uri "https://aeon-backend-deploy.onrender.com/reviews/validate" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

O backend utiliza o catalogo:

```text id="c7m2v5"
aeon-backend/src/main/resources/data/sp_catalog.json
```

Esse catalogo fornece dados estruturados dos locais, incluindo tags, `profileHints` e `reviewPrompts`.

Fluxo:

```text id="n9f3k1"
Flutter
    |
    | POST /reviews/validate
    v
Spring Boot
    |
    +--> valida dados
    +--> identifica local
    +--> consulta sp_catalog.json
    +--> combina tags
    +--> gera profileHints
    +--> gera reviewPrompts
    |
    v
Flutter
    |
    +--> grava resultado validado no Firestore
```

## **8. Aplicativo Flutter**

Acesse a pasta do aplicativo:

```powershell id="u1j6q4"
cd flutter_application
```

Instale as dependencias:

```powershell id="f8w2r5"
flutter pub get
```

Verifique os dispositivos disponíveis:

```powershell id="v3c9n7"
flutter devices
```

### **8.1 Executar no Edge**

```powershell id="d6p1s8"
flutter run -d edge
```

### **8.2 Executar no Chrome**

```powershell id="q2m7x4"
flutter run -d chrome
```

### **8.3 Executar em dispositivo Android**

Primeiro:

```powershell id="a5r8k2"
flutter devices
```

Depois:

```powershell id="y9c3v6"
flutter run -d ID_DO_DISPOSITIVO
```

O identificador deve ser substituido pelo dispositivo exibido pelo comando `flutter devices`.

## **9. Configuracao do Flutter**

O aplicativo esta configurado para utilizar o backend Spring Boot publicado:

```text id="e7b4n0"
https://aeon-backend-deploy.onrender.com
```

A configuracao central do backend fica no aplicativo Flutter em:

```text id="m2q8s5"
lib/core/app_config.dart
```

A comunicacao com o backend e centralizada pelo servico de API do aplicativo.

Entre os fluxos integrados estao:

* health check;
* clima;
* validacao de reviews;
* recursos de usuarios;
* recursos de perfis profissionais.

## **10. Firebase no Flutter**

O aplicativo utiliza Firebase Authentication e outros servicos Firebase.

Arquivos esperados para a configuracao do aplicativo:

```text id="w5n1p7"
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

Os arquivos que contem credenciais ou configuracoes sensiveis devem ser tratados de acordo com a configuracao do ambiente e nao devem ser publicados indevidamente.

O login segue:

```text id="r3k9v2"
Flutter
    |
    v
Firebase Authentication
```

Os dados persistidos pelo aplicativo utilizam os servicos Firebase correspondentes, incluindo Cloud Firestore.

## **11. Dashboard Angular**

Abra outro terminal na raiz do projeto:

```powershell id="t8m4q1"
cd aeon-angular
```

Instale as dependencias:

```powershell id="j6v2p9"
npm install
```

Inicie o servidor de desenvolvimento:

```powershell id="x1c7r5"
ng serve
```

Acesse:

```text id="b9n3w6"
http://localhost:4200
```

O Angular utiliza a API Spring Boot para os recursos administrativos disponibilizados pelo backend.

Backend publicado utilizado pela aplicacao:

```text id="k4s8y2"
https://aeon-backend-deploy.onrender.com
```

## **12. Fluxos de Integracao**

Arquitetura geral:

```text id="p7m2d9"
Flutter
    |
    v
Spring Boot REST API
    |
    +--> Firebase Authentication
    +--> Cloud Firestore
    +--> OpenWeather
    +--> Catalogo AEON

Angular
    |
    v
Spring Boot REST API
    |
    +--> Firebase Authentication
    +--> Cloud Firestore
```

Fluxos relevantes:

### **Login**

```text
Flutter -> Firebase Authentication
```

### **Clima**

```text
Flutter
    -> Spring Boot
        -> OpenWeather
```

### **Reviews**

```text
Flutter
    -> Spring Boot /reviews/validate
        -> Catalogo AEON
        -> validacao/enriquecimento
    -> Firestore
```

### **Perfis profissionais**

```text
Flutter / Angular
    -> Spring Boot
        -> Cloud Firestore
```

### **Usuarios administrativos**

```text
Angular
    -> Spring Boot
        -> Firebase Authentication
```

## **13. Execucao Completa Local**

Para executar a solucao completa localmente, utilize tres terminais.

### **Terminal 1 — Backend**

```powershell
cd aeon-backend
.\mvnw.cmd spring-boot:run
```

Backend:

```text
http://localhost:8080
```

### **Terminal 2 — Angular**

```powershell
cd aeon-angular
npm install
ng serve
```

Dashboard:

```text
http://localhost:4200
```

### **Terminal 3 — Flutter**

```powershell
cd flutter_application
flutter pub get
flutter devices
flutter run -d chrome
```

O fluxo recomendado e:

```text id="g8q4n1"
Terminal 1
Spring Boot
    |
    v
localhost:8080

Terminal 2
Angular
    |
    v
localhost:4200

Terminal 3
Flutter
    |
    v
Aplicativo
```

## **14. Execucao Usando o Backend Publicado**

Tambem e possivel executar apenas Flutter e Angular utilizando o backend publicado no Render.

Nesse caso:

### **Flutter**

```powershell
cd flutter_application
flutter pub get
flutter run -d chrome
```

### **Angular**

Em outro terminal:

```powershell
cd aeon-angular
npm install
ng serve
```

Backend utilizado:

```text
https://aeon-backend-deploy.onrender.com
```

Nesse modo nao e necessario iniciar:

```text
aeon-backend
```

localmente.

## **15. Ordem Recomendada para Demonstracao**

1. Verificar o backend publicado pelo health check.
2. Abrir o Swagger.
3. Executar o Angular com `ng serve`.
4. Executar o Flutter no navegador ou dispositivo fisico.
5. Realizar login.
6. Verificar mapa e localizacao.
7. Verificar consulta de clima.
8. Criar uma review.
9. Validar o fluxo de review pelo Spring Boot.
10. Verificar a gravacao da review no Firestore.
11. Verificar os recursos de perfil profissional.

## **16. Validacao Rapida do Backend Publicado**

Antes de iniciar uma demonstracao, executar:

```powershell
Invoke-RestMethod `
    -Uri "https://aeon-backend-deploy.onrender.com/api/health" `
    -Method GET
```

Depois, se necessario, testar clima:

```powershell
$body = '{"city":"Sao Paulo"}'

Invoke-RestMethod `
    -Uri "https://aeon-backend-deploy.onrender.com/weather" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

E review:

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
    -Uri "https://aeon-backend-deploy.onrender.com/reviews/validate" `
    -Method POST `
    -ContentType "application/json; charset=utf-8" `
    -Body $body
```

## **17. Repositorios e Deploy**

A aplicacao completa esta no repositorio principal do AEON, na branch:

```text
entrega-aeon
```

O backend destinado ao deploy possui repositorio separado:

```text
Manu11000/aeon-backend-deploy
```

Branch de deploy:

```text
main
```

O Render utiliza esse repositorio separado para hospedar o backend publicado.

Portanto:

```text id="s6k1v9"
Repositorio principal
    |
    +--> Flutter
    +--> Angular
    +--> Spring Boot
         |
         +--> entrega-aeon

Repositorio de deploy
    |
    +--> aeon-backend-deploy
         |
         +--> main
              |
              +--> Render
```

Nao deve ser feito push do backend para o repositorio ou branch errados.

## **18. Solucao de Problemas**

### **Backend nao inicia**

Verifique:

```powershell
java -version
```

O projeto requer Java 21.

Depois:

```powershell
.\mvnw.cmd clean test
```

Se o problema estiver relacionado ao Firebase, verifique a configuracao de:

```text
GOOGLE_APPLICATION_CREDENTIALS
```

### **Flutter nao encontra dispositivo**

Execute:

```powershell
flutter devices
```

E confirme se o Chrome, Edge, emulador ou dispositivo fisico esta disponivel.

### **Angular nao inicia**

Verifique:

```powershell
node -v
npm -v
ng version
```

Depois:

```powershell
npm install
ng serve
```

### **Backend publicado parece lento**

O servico no Render pode demorar mais na primeira requisicao apos um periodo de inatividade.

Execute novamente:

```powershell
Invoke-RestMethod `
    -Uri "https://aeon-backend-deploy.onrender.com/api/health" `
    -Method GET
```

### **Erro de comunicacao Flutter -> Backend**

Confirme se a URL configurada no Flutter aponta para:

```text
https://aeon-backend-deploy.onrender.com
```

E verifique primeiro:

```text
/api/health
```

## **19. Observacoes Importantes**

* O backend oficial atual e Spring Boot.
* O FastAPI legado nao deve ser iniciado para executar a arquitetura atual.
* O backend utiliza Java 21.
* O backend local utiliza a porta `8080` por padrao.
* O Render utiliza a porta fornecida pela variavel de ambiente `PORT`.
* O Flutter utiliza o backend Spring Boot para clima e validacao de reviews.
* O catalogo `sp_catalog.json` faz parte do backend.
* O catalogo e utilizado no enriquecimento das reviews.
* Credenciais Firebase nao devem ser versionadas.
* O Swagger pode ser utilizado para inspecionar e testar a API.
* O backend publicado pode apresentar demora na primeira requisicao apos inatividade.
* Alteracoes de deploy devem respeitar a separacao entre o repositorio principal e `aeon-backend-deploy`.
* Nao e necessario iniciar nenhum backend Python para a versao atual.
* O antigo FastAPI nao e dependencia runtime do Flutter, Angular ou Spring.
