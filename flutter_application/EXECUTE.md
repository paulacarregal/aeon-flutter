# Como Executar o AEON

Este documento descreve como executar os componentes atuais do projeto:

- Aplicativo Flutter.
- Backend Spring Boot.
- Dashboard Angular.

O FastAPI legado foi removido da arquitetura atual. O backend oficial e o Spring Boot.

## 1. Pre-requisitos

- Flutter SDK.
- Dart SDK compativel com o Flutter instalado.
- Android Studio ou VS Code.
- Java JDK 21 para o backend Spring Boot.
- Node.js e npm.
- Angular CLI.
- Git.
- Chrome, Edge, emulador Android ou dispositivo fisico.

Verificacoes uteis:

```bash
flutter doctor
java -version
node -v
ng version
```

## 2. Backend Spring Boot

O backend pode ser usado publicado no Render ou executado localmente.

API publicada:

```text
https://aeon-backend-deploy.onrender.com
```

Swagger:

```text
https://aeon-backend-deploy.onrender.com/swagger-ui/index.html
```

Para executar localmente:

```bash
cd aeon-backend
mvn spring-boot:run
```

Ou no Windows, usando Maven Wrapper:

```powershell
cd aeon-backend
.\mvnw.cmd spring-boot:run
```

Observacao: o backend esta configurado para Java 21.

## 3. Aplicativo Flutter

Acesse a pasta do app:

```bash
cd flutter_application
flutter pub get
```

Listar dispositivos:

```bash
flutter devices
```

Executar no navegador:

```bash
flutter run -d edge
```

ou:

```bash
flutter run -d chrome
```

Executar em dispositivo Android conectado:

```bash
flutter run -d ID_DO_DISPOSITIVO
```

O Flutter esta configurado para consumir o backend Spring Boot publicado em:

```text
https://aeon-backend-deploy.onrender.com
```

## 4. Firebase

O app usa Firebase Authentication e outros servicos Firebase. Os arquivos esperados no projeto Flutter sao:

```text
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart
```

O backend Spring Boot usa Firebase Admin SDK com credencial configurada por variavel de ambiente no servidor.

## 5. Dashboard Angular

Acesse a pasta do dashboard:

```bash
cd aeon-angular
npm install
ng serve
```

Abra:

```text
http://localhost:4200
```

O Angular consome a mesma API Spring Boot publicada:

```text
https://aeon-backend-deploy.onrender.com/api
```

## 6. Fluxos de Integracao

```text
Flutter
    -> Spring Boot REST API
        -> Firebase Authentication / Firestore / APIs externas

Angular
    -> Spring Boot REST API
```

Fluxos relevantes:

- Login: Flutter -> Firebase Authentication.
- Clima: Flutter -> Spring Boot `POST /weather` -> OpenWeather.
- Reviews: Flutter -> Spring Boot `POST /reviews/validate` -> Flutter grava review no Firestore.
- Perfis profissionais: Flutter/Angular -> Spring Boot -> Firestore.
- Usuarios administrativos: Angular -> Spring Boot -> Firebase Authentication.

## 7. Ordem Recomendada para Demonstracao

1. Abrir o Swagger do backend publicado.
2. Executar o Angular com `ng serve`.
3. Executar o Flutter no navegador ou dispositivo fisico.
4. Validar login, mapa, clima, review e perfil profissional.

## 8. Observacoes

- O backend publicado no Render pode demorar mais na primeira requisicao apos inatividade.
- Nao e necessario iniciar nenhum backend Python para a versao atual.
- O antigo FastAPI nao e dependencia runtime do Flutter, Angular ou Spring.
