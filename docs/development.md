# 🛠️ Development Guide

Centraliza instruções para executar, observar e testar o projeto.

## 🐳 Docker

### Pré‑requisitos
- Docker 20.10+
- Docker Compose 2.0+

### Quick start
```bash
git clone <repo-url>
cd wallet-api
docker-compose up -d
curl http://localhost:8080/actuator/health
```

### Comandos úteis
```bash
docker-compose logs -f                      # logs de todos os serviços
docker-compose logs -f wallet-api           # logs da aplicação
docker-compose stop                         # pausa mantendo volumes
docker-compose down -v                      # remove tudo
docker-compose up --build -d                # rebuild da aplicação
```

### Variáveis e volumes principais
```yaml
wallet-api:
  environment:
    - SPRING_PROFILES_ACTIVE=docker
    - MONGODB_URI=mongodb://mongodb:27017/wallet
  volumes:
    - mongodb_data:/data/db
mongodb:
  environment:
    - MONGO_INITDB_ROOT_USERNAME=admin
    - MONGO_INITDB_ROOT_PASSWORD=admin123
```

### Troubleshooting rápido
- **Porta 8080/27017 em uso**: `lsof -i :8080` e mate o processo.
- **MongoDB não sobe**: `docker-compose logs mongodb` para verificar credenciais.
- **Reset completo**: `docker-compose down -v && docker system prune -f`.

## 📝 LoggingX Setup

Biblioteca opcional para logs estruturados.

1. **Instalar localmente**
   ```bash
   mvn clean install
   ```
2. **Habilitar no projeto**
   - Descomente a dependência no `pom.xml` e as anotações no `WalletServiceImpl`.
3. **Configuração base** (`application.yml`)
   ```yaml
   loggingx:
     service: wallet-api
     env: ${ENVIRONMENT:dev}
     version: ${APP_VERSION:0.0.1-SNAPSHOT}
     http:
       server:
         enabled: true
         log-body: false
   ```
4. **Exemplo de log esperado**
   ```json
   {
     "service": "wallet-api",
     "class": "WalletServiceImpl",
     "method": "createWallet",
     "durationMs": 45
   }
   ```

## ✅ Testing

### Estrutura
Tests ficam em `src/test/java` separados em `service`, `controller`, `repository` e `mapper`.

### Executar
```bash
./mvnw test                              # todos
./mvnw test -Dtest="**/*RepositoryTest"   # apenas integração
./mvnw test -Dtest="WalletControllerTest" # teste específico
```

### Extras
- Gere cobertura: `./mvnw test jacoco:report`
- Testes de repository usam **Testcontainers**, portanto Docker deve estar rodando.
- Exemplo de teste:
  ```java
  @Test
  void shouldCreateWallet() {
      mockMvc.perform(post("/api/v1/wallets")
              .contentType(MediaType.APPLICATION_JSON)
              .content(json))
              .andExpect(status().isCreated());
  }
  ```
