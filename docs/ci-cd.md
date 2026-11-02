# CI/CD do Backend AEON

O workflow `.github/workflows/backend-ci-cd.yml` automatiza a validacao e a entrega do backend Spring Boot e dos objetos Oracle.

## Fluxo

```text
Push ou pull request
-> Java 21 + Maven
-> testes JUnit
-> cobertura JaCoCo
-> build do JAR
-> relatorios e artefatos

Push na main ou execucao manual
-> imagem Docker
-> GitHub Container Registry
-> upgrade incremental do Oracle
-> validacao de packages, wrappers e triggers
```

Pull requests tambem executam revisao de dependencias e bloqueiam novas dependencias com vulnerabilidade de severidade alta.

## Jobs

- `test-and-build`: executa `mvn clean verify`, gera o JAR, relatorios JUnit e cobertura JaCoCo.
- `dependency-review`: verifica dependencias adicionadas em pull requests.
- `publish-container`: publica a imagem `ghcr.io/<owner>/<repositorio>/aeon-backend` usando o `GITHUB_TOKEN`.
- `deploy-oracle`: aplica os scripts incrementais com Oracle SQLcl e publica o log da execucao.

O Render nao faz parte deste pipeline. A entrega do backend e feita como imagem versionada no GitHub Container Registry, pronta para ser executada em qualquer ambiente com Docker.

## Configuracao do Oracle

No GitHub, crie um Environment chamado `oracle` e adicione estes Secrets:

| Secret | Exemplo |
| --- | --- |
| `ORACLE_TNS_ALIAS` | `fiap_low` |
| `ORACLE_USER` | usuario do schema Oracle |
| `ORACLE_PASSWORD` | senha do schema Oracle |
| `ORACLE_WALLET_BASE64` | conteudo Base64 do arquivo `Wallet_FIAP.zip` |

As credenciais e os arquivos do wallet nao devem ser adicionados ao repositorio. O pipeline decodifica o wallet somente no ambiente temporario da execucao e usa a conexao mTLS do Autonomous Database.

No PowerShell, gere o valor de `ORACLE_WALLET_BASE64` sem alterar o arquivo original:

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("C:\Users\vanes\Documents\Oracle\Wallet_FIAP.zip")
) | Set-Clipboard
```

Se os Secrets nao estiverem configurados, o job informa que o deploy foi ignorado e os demais jobs continuam funcionando.

O schema base precisa ter sido criado uma vez com:

```sql
@aeon-backend/database/oracle/01_schema.sql
@aeon-backend/database/oracle/02_seed.sql
```

Depois disso, o pipeline executa automaticamente:

```sql
@aeon-backend/database/oracle/06_devops_upgrade.sql
@aeon-backend/database/oracle/03_functions.sql
@aeon-backend/database/oracle/04_procedures.sql
@aeon-backend/database/oracle/07_validate_deployment.sql
```

O `06_devops_upgrade.sql` e idempotente: ele cria somente as novas tabelas e indices que ainda nao existem. O `07_validate_deployment.sql` interrompe o job quando algum objeto obrigatorio estiver ausente ou invalido.

## Logs e relatorios

Cada execucao armazena por 14 dias:

- relatorios dos testes em `target/surefire-reports`;
- relatorio de cobertura em `target/site/jacoco/index.html`;
- JAR executavel do backend;
- log do deploy Oracle, quando o banco estiver configurado.

O resumo de cada job tambem fica visivel na pagina da execucao do GitHub Actions.

## Execucao manual

O workflow pode ser iniciado em:

```text
GitHub -> Actions -> Backend CI/CD -> Run workflow
```

Localmente, a mesma validacao principal pode ser executada dentro de `aeon-backend`:

```powershell
.\mvnw.cmd clean verify
```

Para executar a imagem publicada:

```powershell
docker run --rm -p 8080:8080 `
  -v "C:\Users\vanes\Documents\Oracle\Wallet_FIAP:/opt/oracle/wallet:ro" `
  -e ORACLE_URL="jdbc:oracle:thin:@fiap_low?TNS_ADMIN=/opt/oracle/wallet" `
  -e ORACLE_DRIVER="oracle.jdbc.OracleDriver" `
  -e ORACLE_USER="usuario" `
  -e ORACLE_PASSWORD="senha" `
  ghcr.io/<owner>/<repositorio>/aeon-backend:latest
```

Para executar o backend diretamente no Windows, use:

```powershell
$env:ORACLE_URL="jdbc:oracle:thin:@fiap_low?TNS_ADMIN=C:/Users/vanes/Documents/Oracle/Wallet_FIAP"
$env:ORACLE_DRIVER="oracle.jdbc.OracleDriver"
$env:ORACLE_USER="usuario"
$env:ORACLE_PASSWORD="senha"
.\mvnw.cmd spring-boot:run
```
