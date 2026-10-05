# AEON

## Visao Geral

O AEON e uma plataforma multiplataforma para descoberta de experiencias urbanas personalizadas. A solucao combina perfil do usuario, localizacao, clima, avaliacoes e regras de recomendacao para sugerir locais, rotas e experiencias em Sao Paulo.

Arquitetura atual:

```text
Flutter App
    -> Spring Boot REST API
        -> Firebase Authentication
        -> Cloud Firestore
        -> Oracle PL/SQL
        -> APIs externas

Angular Dashboard
    -> Spring Boot REST API
```

O backend principal da aplicacao e o Spring Boot. A camada Oracle complementa o projeto com scoring deterministico, historico de interacoes e procedures PL/SQL para recomendacoes.

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
- Integracao JDBC com Oracle para recomendacoes PL/SQL.
- Documentacao via Swagger/OpenAPI.
- Configuracao de seguranca com Spring Security.

### Oracle PL/SQL

- Modelo relacional para usuarios, locais, tags, interacoes, avaliacoes e historico de recomendacoes.
- Function `FN_CALCULAR_AFINIDADE` para calcular score de afinidade entre usuario e local.
- Function `FN_RESUMO_LOCAL` para gerar resumo textual do local.
- Function `FN_CLASSIFICAR_AFINIDADE` para classificar scores em faixas simples.
- Procedure `PR_REGISTRAR_INTERACAO` para registrar comportamento do usuario.
- Procedure `PR_GERAR_RECOMENDACOES` para consolidar recomendacoes no historico.
- Procedure `PR_ATUALIZAR_NOTA_MEDIA_LOCAL` para recalcular a nota media de um local.

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
| Banco principal do app | Cloud Firestore |
| Banco relacional da Fase 6 | Oracle, PL/SQL, JDBC |
| Integracao Firebase servidor | Firebase Admin SDK |
| IA | Firebase AI Logic / Gemini |
| Clima | OpenWeather via Spring Boot |
| Mapas | Flutter Map / OpenStreetMap |
| Localizacao | Geolocator |
| Dashboard web | Angular, TypeScript, HttpClient |
| Documentacao API | Swagger / OpenAPI |
| Build backend | Maven |
| Versionamento | Git, GitHub |

## Modelo Oracle

A camada Oracle nao substitui Firebase Auth nem Firestore. Ela adiciona uma base relacional para demonstrar recomendacoes com regras auditaveis em PL/SQL.

Fluxo:

```text
Cliente REST ou Flutter
-> Spring Boot
-> JDBC
-> Oracle
-> Functions e Procedures PL/SQL
```

Principais tabelas:

- `USUARIO`: vincula `FIREBASE_UID` ao usuario Oracle e guarda preferencias.
- `LOCAL`: armazena locais, categoria, coordenadas, nota, status e caracteristicas.
- `TAG`: catalogo de tags.
- `USUARIO_TAG`: tags preferidas por usuario.
- `LOCAL_TAG`: tags associadas aos locais.
- `INTERACAO_USUARIO`: registra `VISUALIZOU`, `CURTIU`, `SALVOU`, `VISITOU` e `IGNOROU`.
- `AVALIACAO`: armazena notas e comentarios.
- `HISTORICO_RECOMENDACAO`: guarda recomendacoes geradas por score.

## Dados De Teste

O arquivo `aeon-backend/database/oracle/02_seed.sql` cria usuarios exclusivamente para testes e demonstracoes do algoritmo. Eles nao representam contas reais do aplicativo.

| Usuario | ID | Firebase UID | Perfil |
| --- | --- | --- | --- |
| Blair Willow | `1` | `uid-demo-blair` | social, noturno, premium, gastronomia, musica |
| Ken | `2` | `uid-demo-ken` | outdoor, diurno, ativo, natureza, cultura |

Esses dados permitem demonstrar que a mesma base de locais pode gerar resultados diferentes conforme o perfil. Locais gastronomicos, sociais e noturnos tendem a pontuar melhor para Blair Willow; locais outdoor, diurnos e ativos tendem a pontuar melhor para Ken.

## Endpoints Principais

Base local:

```text
http://localhost:8081
```

Endpoints usados pela solucao:

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
POST /api/interactions
GET  /api/recommendations/{firebaseUid}
```

## Execucao Oracle

Ordem dos scripts no SQL Developer:

```sql
@aeon-backend/database/oracle/01_schema.sql
@aeon-backend/database/oracle/02_seed.sql
@aeon-backend/database/oracle/03_functions.sql
@aeon-backend/database/oracle/04_procedures.sql
@aeon-backend/database/oracle/05_examples.sql
```

Variaveis para rodar o backend com Oracle:

```powershell
$env:PORT="8081"
$env:ORACLE_URL="jdbc:oracle:thin:@//oracle.fiap.com.br:1521/ORCL"
$env:ORACLE_USER="seu_usuario"
$env:ORACLE_PASSWORD="sua_senha"
$env:ORACLE_DRIVER="oracle.jdbc.OracleDriver"
```

Rodar o backend:

```powershell
cd aeon-backend
java -jar target\aeon-backend-0.0.1-SNAPSHOT.jar
```

Testar a API:

```powershell
curl http://localhost:8081/api/health
curl http://localhost:8081/api/recommendations/uid-demo-blair
curl http://localhost:8081/api/recommendations/uid-demo-ken
```

Registrar uma interacao:

```powershell
curl -Method POST http://localhost:8081/api/interactions `
  -ContentType "application/json" `
  -Body '{"firebaseUid":"uid-demo-blair","localId":1,"tipoInteracao":"SALVOU"}'
```

## Exemplos SQL

Comparar locais para Blair Willow:

```sql
SELECT
    l.nome,
    fn_calcular_afinidade(1, l.id_local) AS afinidade
FROM local l
WHERE l.ativo = 'S'
ORDER BY afinidade DESC;
```

Comparar Blair Willow e Ken no mesmo local:

```sql
SELECT
    fn_calcular_afinidade(1, 1) AS blair,
    fn_calcular_afinidade(2, 1) AS ken
FROM dual;
```

Validar os objetos PL/SQL:

```sql
SELECT
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN (
    'FN_CALCULAR_AFINIDADE',
    'FN_RESUMO_LOCAL',
    'FN_CLASSIFICAR_AFINIDADE',
    'PR_REGISTRAR_INTERACAO',
    'PR_GERAR_RECOMENDACOES',
    'PR_ATUALIZAR_NOTA_MEDIA_LOCAL'
)
ORDER BY object_type, object_name;
```

## Estrutura

```text
Aeon/
|-- flutter_application/   # Aplicativo Flutter
|-- aeon-backend/          # Backend Spring Boot
|-- aeon-angular/          # Dashboard Angular
|-- docs/                  # Documentacao complementar
|-- README.md
```

## Documentacao Complementar

- `docs/oracle-plsql.md` detalha o modelo Oracle, regras de score, functions, procedures e exemplos de apresentacao.
- `flutter_application/EXECUTE.md` descreve a execucao do Flutter, Spring Boot e Angular.
- `flutter_application/BACKEND.md` descreve detalhes da API Spring Boot.

## Desenvolvedores

- Manoela Oliveira
- Paula Carregal
- Pedro Santiago
- Vanessa Fittipaldi
