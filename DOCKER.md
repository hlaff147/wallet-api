# 🐳 Docker - Wallet API

Guia completo para executar a Wallet API usando Docker e Docker Compose.

## 📋 Pré-requisitos

- **Docker** 20.10+
- **Docker Compose** 2.0+
- **Git** para clonar o repositório

## 🚀 Quick Start

### 1. Clonar e Executar

```bash
# Clonar repositório
git clone <repo-url>
cd wallet-api

# Executar com Docker Compose
docker-compose up -d

# Verificar se está funcionando
curl http://localhost:8080/actuator/health
```

### 2. Acessar Serviços

| Serviço | URL | Descrição |
|---------|-----|-----------|
| **Wallet API** | http://localhost:8080 | API principal |
| **Swagger UI** | http://localhost:8080/swagger-ui.html | Documentação interativa |
| **MongoDB** | mongodb://localhost:27017 | Base de dados |
| **Mongo Express** | http://localhost:8081 | Interface web do MongoDB |

## 📊 Arquitetura Docker

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   wallet-api    │    │     mongodb     │    │  mongo-express  │
│   (port 8080)   │◄──►│   (port 27017)  │◄──►│   (port 8081)   │
│                 │    │                 │    │    (opcional)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Comandos Docker

### Gerenciamento Básico

```bash
# Subir serviços
docker-compose up -d

# Ver logs em tempo real
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f wallet-api
docker-compose logs -f mongodb

# Parar serviços
docker-compose stop

# Parar e remover containers
docker-compose down

# Parar e remover tudo (incluindo volumes)
docker-compose down -v
```

### Build e Deploy

```bash
# Rebuild da aplicação
docker-compose build wallet-api

# Rebuild e restart
docker-compose up --build -d

# Forçar recreação dos containers
docker-compose up --force-recreate -d
```

### Escalabilidade

```bash
# Executar múltiplas instâncias da API
docker-compose up -d --scale wallet-api=3

# Com load balancer (nginx)
docker-compose -f docker-compose.yml -f docker-compose.scale.yml up -d
```

## 📁 Estrutura de Arquivos Docker

```
wallet-api/
├── docker-compose.yml          # Definição dos serviços
├── Dockerfile                  # Build da aplicação Spring Boot
├── .dockerignore              # Arquivos ignorados no build
├── docker/
│   └── mongo-init/
│       └── 01-init-database.js # Script de inicialização do MongoDB
└── src/main/resources/
    └── application-docker.yml  # Configuração para ambiente Docker
```

## ⚙️ Configurações

### docker-compose.yml

O arquivo principal define 3 serviços:

1. **wallet-api**: Aplicação Spring Boot
2. **mongodb**: Base de dados MongoDB 7.0
3. **mongo-express**: Interface web (perfil admin)

### Variáveis de Ambiente

**Aplicação (wallet-api):**
```yaml
environment:
  - SPRING_PROFILES_ACTIVE=docker
  - MONGODB_URI=mongodb://mongodb:27017/wallet
  - JAVA_OPTS=-Xmx512m -Xms256m
```

**MongoDB:**
```yaml
environment:
  - MONGO_INITDB_ROOT_USERNAME=admin
  - MONGO_INITDB_ROOT_PASSWORD=admin123
  - MONGO_INITDB_DATABASE=wallet
```

**Mongo Express:**
```yaml
environment:
  - ME_CONFIG_MONGODB_ADMINUSERNAME=admin
  - ME_CONFIG_MONGODB_ADMINPASSWORD=admin123
  - ME_CONFIG_BASICAUTH_USERNAME=admin
  - ME_CONFIG_BASICAUTH_PASSWORD=admin123
```

## 🗄️ Persistência de Dados

### Volumes Docker

```bash
# Listar volumes
docker volume ls

# Inspecionar volume de dados
docker volume inspect wallet_mongodb_data

# Backup do banco de dados
docker exec wallet-mongodb mongodump --out /backup
docker cp wallet-mongodb:/backup ./backup

# Restore do banco de dados
docker cp ./backup wallet-mongodb:/backup
docker exec wallet-mongodb mongorestore /backup
```

### Backup Automático

```bash
#!/bin/bash
# backup-wallet-db.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups/$DATE"

mkdir -p $BACKUP_DIR

echo "🔄 Fazendo backup do banco de dados..."
docker exec wallet-mongodb mongodump --out /tmp/backup
docker cp wallet-mongodb:/tmp/backup $BACKUP_DIR

echo "✅ Backup salvo em: $BACKUP_DIR"
```

## 🔍 Monitoramento e Debug

### Health Checks

Todos os serviços têm health checks configurados:

```bash
# Status dos containers
docker-compose ps

# Health check manual
docker exec wallet-api curl -f http://localhost:8080/actuator/health
docker exec wallet-mongodb mongosh --eval "db.adminCommand('ping')"
```

### Logs Estruturados

```bash
# Logs com timestamp
docker-compose logs -f -t

# Logs das últimas 100 linhas
docker-compose logs --tail=100

# Filtrar logs por level
docker-compose logs | grep ERROR
docker-compose logs | grep -i "wallet"
```

### Debug da Aplicação

```bash
# Entrar no container da aplicação
docker exec -it wallet-api bash

# Ver variáveis de ambiente
docker exec wallet-api env | grep -E "(SPRING|MONGO|JAVA)"

# Verificar conectividade com MongoDB
docker exec wallet-api curl mongodb:27017
```

## 🌍 Configurações de Ambiente

### Desenvolvimento Local

```yaml
# docker-compose.override.yml (criado automaticamente)
version: '3.8'
services:
  wallet-api:
    environment:
      - SPRING_PROFILES_ACTIVE=docker,dev
      - LOGGING_LEVEL_COM_HLAFF_WALLET_API=DEBUG
    volumes:
      - ./src:/app/src:ro  # Hot reload (desenvolvimento)
```

### Produção

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  wallet-api:
    environment:
      - SPRING_PROFILES_ACTIVE=docker,prod
      - JAVA_OPTS=-Xmx1g -Xms512m -XX:+UseG1GC
    deploy:
      resources:
        limits:
          memory: 1.5G
        reservations:
          memory: 512M
  
  mongodb:
    deploy:
      resources:
        limits:
          memory: 2G
        reservations:
          memory: 1G
```

### Usar configuração de produção

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## 🔐 Segurança

### Rede Isolada

```bash
# Criar rede customizada
docker network create wallet-network --driver bridge

# Verificar isolamento
docker network inspect wallet-network
```

### Secrets Management

```yaml
# docker-compose.secrets.yml
version: '3.8'
services:
  mongodb:
    environment:
      - MONGO_INITDB_ROOT_PASSWORD_FILE=/run/secrets/mongo_password
    secrets:
      - mongo_password

secrets:
  mongo_password:
    file: ./secrets/mongo_password.txt
```

### SSL/TLS (Produção)

```yaml
# Para HTTPS em produção
services:
  nginx:
    image: nginx:alpine
    ports:
      - "443:443"
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl/certs
```

## 🧪 Testes com Docker

### Executar Testes

```bash
# Testes unitários
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  openjdk:17-jdk-slim \
  ./mvnw test -Dtest='**/*Test,!**/*RepositoryTest'

# Testes de integração (precisa do MongoDB)
docker-compose -f docker-compose.test.yml run --rm wallet-api-test
```

### docker-compose.test.yml

```yaml
version: '3.8'
services:
  wallet-api-test:
    build: .
    command: ./mvnw test
    environment:
      - SPRING_PROFILES_ACTIVE=test
      - MONGODB_URI=mongodb://mongodb-test:27017/wallet_test
    depends_on:
      - mongodb-test
  
  mongodb-test:
    image: mongo:7.0
    environment:
      - MONGO_INITDB_DATABASE=wallet_test
```

## 📈 Performance e Otimização

### Multistage Build

O Dockerfile usa multistage build para otimizar o tamanho:

```dockerfile
# Build stage
FROM openjdk:17-jdk-slim as builder
# ... build da aplicação

# Runtime stage  
FROM openjdk:17-jre-slim
# ... apenas runtime necessário
```

### Otimizações de JVM

```yaml
environment:
  - JAVA_OPTS=-Xmx512m -Xms256m -XX:+UseG1GC -XX:+UseContainerSupport
```

### Cache de Layers

```bash
# Build com cache
docker-compose build --parallel

# Limpar cache quando necessário
docker system prune -a
```

## 🚨 Troubleshooting

### Problemas Comuns

**1. Porta já em uso**
```bash
# Verificar o que está usando a porta
lsof -i :8080
lsof -i :27017

# Matar processo se necessário
kill -9 <PID>
```

**2. Problema de conectividade MongoDB**
```bash
# Verificar se MongoDB está rodando
docker exec wallet-mongodb mongosh --eval "db.adminCommand('ping')"

# Verificar logs do MongoDB
docker-compose logs mongodb
```

**3. Aplicação não inicia**
```bash
# Verificar logs detalhados
docker-compose logs wallet-api

# Verificar se todas as dependências estão up
docker-compose ps

# Restart específico
docker-compose restart wallet-api
```

**4. Problemas de memória**
```bash
# Verificar uso de recursos
docker stats

# Aumentar memória limite
# Editar docker-compose.yml e adicionar:
deploy:
  resources:
    limits:
      memory: 1G
```

### Reset Completo

```bash
#!/bin/bash
echo "🔄 Fazendo reset completo do ambiente..."

# Parar e remover tudo
docker-compose down -v

# Remover imagens
docker rmi wallet-api_wallet-api 2>/dev/null || true

# Limpar system
docker system prune -f

# Subir novamente
docker-compose up -d

echo "✅ Reset completo realizado!"
```

## 📝 Scripts Úteis

### start.sh
```bash
#!/bin/bash
echo "🚀 Iniciando Wallet API..."
docker-compose up -d

echo "⏳ Aguardando serviços ficarem prontos..."
sleep 30

echo "🔍 Verificando saúde da aplicação..."
curl -f http://localhost:8080/actuator/health

echo "✅ Wallet API rodando em http://localhost:8080"
echo "📊 Swagger UI: http://localhost:8080/swagger-ui.html"
echo "🗄️ Mongo Express: http://localhost:8081 (admin/admin123)"
```

### stop.sh
```bash
#!/bin/bash
echo "🛑 Parando Wallet API..."
docker-compose down
echo "✅ Serviços parados com sucesso!"
```

---

💡 **Dica**: Execute `./start.sh` para começar rapidamente ou `docker-compose up -d` para controle manual!
