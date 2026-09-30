# Backend Spring Boot - AEON

## Objetivo

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

## Responsabilidades Atuais

- Disponibilizar endpoints REST para os clientes Flutter e Angular.
- Consultar usuarios do Firebase Authentication.
- Gerenciar perfis profissionais no Cloud Firestore.
- Validar e enriquecer reviews antes da gravacao pelo aplicativo.
- Consultar dados climaticos via OpenWeather sem expor a chave diretamente ao app.
- Expor documentacao interativa via Swagger/OpenAPI.
- Manter uma camada central para evolucao de seguranca e integracoes.

## Tecnologias

| Tecnologia | Uso |
| --- | --- |
| Java | Linguagem do backend |
| Spring Boot | Framework principal |
| Spring MVC | Criacao da API REST |
| Spring Security | Configuracao de seguranca |
| Bean Validation | Validacao de entrada |
| Firebase Admin SDK | Integracao servidor com Firebase |
| Cloud Firestore | Persistencia atual dos dados principais |
| OpenWeather | Servico externo de clima |
| Swagger/OpenAPI | Documentacao da API |
| Maven | Build e dependencias |
| Render | Hospedagem do backend |

Observacao: existem dependencias de JPA/H2 no projeto, mas elas nao sao usadas como persistencia ativa do fluxo de Professional Profile. Esse fluxo usa Firestore por meio do Firebase Admin SDK.

## Arquitetura Interna

```text
Controller
    -> Service
        -> Firebase Admin SDK / Firestore
        -> APIs externas
```

Camadas principais:

- `controller`: recebe requisicoes HTTP e define rotas REST.
- `service`: concentra regras de negocio e integracoes.
- `dto`: define contratos de entrada e saida.
- `config`: concentra configuracoes de Firebase, CORS e seguranca.
- `exception`: padroniza respostas de erro.

## Endpoints

Base local padrao:

```text
http://localhost:8080
```

Base publicada:

```text
https://aeon-backend-deploy.onrender.com
```

### Health

```http
GET /api/health
```

Retorna o estado basico da API.

### Usuarios

```http
GET /api/users
```

Consulta usuarios cadastrados no Firebase Authentication.

### Perfis Profissionais

```http
GET    /api/professional-profiles
GET    /api/professional-profiles/{id}
POST   /api/professional-profiles
PUT    /api/professional-profiles/{id}
DELETE /api/professional-profiles/{id}
```

Os perfis profissionais representam contas de estabelecimentos, marcas ou criadores associados ao AEON. A persistencia atual desse fluxo e no Cloud Firestore.

### Clima

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

### Validacao de Reviews

```http
POST /reviews/validate
```

Endpoint consumido pelo Flutter antes da review ser gravada no Firestore pelo app.

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
  "tags": ["ambiente", "drinks", "indoor", "night", "premium", "social", "urban"],
  "spendRange": "50+",
  "profileHints": ["Pioneiro Urbano", "Explorador Social"],
  "reviewPrompts": ["drinks", "ambiente", "musica", "fila", "preco"],
  "source": "aeon-spring",
  "status": "validated"
}
```

## Firebase

O backend usa Firebase Admin SDK. A credencial administrativa deve ser configurada no ambiente do servidor por meio de:

```text
GOOGLE_APPLICATION_CREDENTIALS
```

O aplicativo Flutter continua usando Firebase Authentication para login. O backend usa o Firebase Admin SDK para operacoes do lado servidor.

## Swagger

Documentacao publicada:

```text
https://aeon-backend-deploy.onrender.com/swagger-ui/index.html
```

## Execucao Local

```bash
cd aeon-backend
mvn spring-boot:run
```

Ou, com Maven Wrapper:

```powershell
.\mvnw.cmd spring-boot:run
```

O projeto backend esta configurado para Java 21.
