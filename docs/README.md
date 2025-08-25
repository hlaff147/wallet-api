# 📊 Documentação Técnica - Wallet API

Esta pasta contém a documentação técnica e diagramas do projeto.

## 📁 Arquivos

- **[api.md](api.md)** - Endpoints e exemplos de uso
- **[development.md](development.md)** - Docker, LoggingX e testes
- **[architecture.puml](architecture.puml)** - Diagrama UML da arquitetura do sistema

## 🗺️ Visão Geral do Projeto

A **Wallet API** é uma aplicação Spring Boot para gerenciamento de carteiras digitais com arquitetura em camadas, auditoria de operações e testes abrangentes.

## 🎨 Como Visualizar o Diagrama PlantUML

### Opção 1: Online (Mais Fácil)

1. Copie o conteúdo do arquivo `architecture.puml`
2. Acesse: http://www.plantuml.com/plantuml/
3. Cole o código e clique em "Submit"

### Opção 2: Visual Studio Code

1. Instale a extensão "PlantUML"
2. Abra o arquivo `architecture.puml`
3. Use `Ctrl+Shift+P` → "PlantUML: Preview Current Diagram"

### Opção 3: PlantUML Local

```bash
# Instalar PlantUML (requer Java)
brew install plantuml

# Gerar PNG
plantuml docs/architecture.puml

# Gerar SVG
plantuml -tsvg docs/architecture.puml
```

### Opção 4: Docker

```bash
# Gerar diagrama usando Docker
docker run --rm -v $(pwd):/data plantuml/plantuml:latest \
  -tpng /data/docs/architecture.puml

# Resultado será salvo como architecture.png
```

## 🏗️ Visão Geral da Arquitetura

O diagrama mostra a arquitetura em camadas do sistema:

### 📊 Camadas Principais

1. **Controllers** - Endpoints REST da API
2. **DTOs** - Objetos de transferência de dados
3. **Services** - Regras de negócio
4. **Mappers** - Conversão entre DTOs e Models
5. **Models** - Entidades do domínio
6. **Repositories** - Acesso aos dados
7. **Enums** - Tipos enumerados
8. **Exceptions** - Tratamento de erros
9. **Utils** - Utilitários

### 🔄 Fluxo de Dados

```
HTTP Request → Controller → Service → Repository → MongoDB
                   ↓           ↓          ↑
                 DTOs ←→ Mappers ←→ Models
```

### 🎯 Características Arquiteturais

- **Separação de Responsabilidades**: Cada camada tem uma função específica
- **Inversão de Dependência**: Services dependem de abstrações (interfaces)
- **Mapeamento Automático**: MapStruct reduz boilerplate
- **Auditoria Completa**: LedgerEntry registra todas as operações
- **Tratamento de Erros**: GlobalExceptionHandler padroniza respostas

## 📋 Convenções

### Nomenclatura
- **Controllers**: `{Entity}Controller`
- **Services**: `{Entity}Service` / `{Entity}ServiceImpl`
- **Repositories**: `{Entity}Repository`
- **DTOs**: `{Entity}Request` / `{Entity}Response`
- **Mappers**: `{Entity}Mapper`

### Padrões
- **Request/Response**: Uso de DTOs para entrada e saída
- **Paginação**: Suporte padrão Spring Data
- **Validação**: Bean Validation nas DTOs
- **Auditoria**: Registro de todas operações no LedgerEntry

## 🔧 Ferramentas de Desenvolvimento

### Extensões Recomendadas (VS Code)
- **PlantUML** - Visualização de diagramas
- **Java Extension Pack** - Suporte completo Java
- **Spring Boot Extension Pack** - Ferramentas Spring
- **Docker** - Gerenciamento de containers

### IntelliJ IDEA
- **PlantUML Integration** - Plugin oficial
- **Spring Boot** - Suporte nativo
- **MongoDB** - Plugin para visualização

## 📈 Métricas e Monitoramento

O sistema expõe as seguintes métricas via Spring Actuator:

- **Health Check**: `/actuator/health`
- **Métricas**: `/actuator/metrics`
- **Info**: `/actuator/info`

### Monitoramento Sugerido

- **Performance**: Tempo de resposta dos endpoints
- **Negócio**: Volume de transações, saldos totais
- **Técnico**: Uso de memória, conexões MongoDB
- **Erros**: Taxa de erro por endpoint

## 🧪 Estratégia de Testes

### Pirâmide de Testes

```
        E2E Tests (poucos)
       ──────────────────
      Integration Tests (alguns)
     ─────────────────────────────
    Unit Tests (muitos)
   ──────────────────────────────────
```

### Tipos Implementados

1. **Unit Tests**: Services, Mappers, Utils
2. **Integration Tests**: Repositories com Testcontainers
3. **Web Tests**: Controllers com MockMvc
4. **Application Tests**: Contexto Spring completo

## 🚀 Roadmap Técnico

### Próximas Melhorias

#### Arquitetura
- [ ] Event Sourcing completo
- [ ] CQRS (Command Query Responsibility Segregation)
- [ ] Saga Pattern para transações distribuídas

#### Performance
- [ ] Cache Redis para consultas frequentes
- [ ] Conexion pooling otimizado
- [ ] Índices MongoDB avançados

#### Observabilidade
- [ ] Distributed Tracing (Zipkin/Jaeger)
- [ ] Métricas customizadas (Micrometer)
- [ ] Logs estruturados (JSON)

#### Segurança
- [ ] Autenticação JWT
- [ ] Rate Limiting
- [ ] Audit Logging

---

💡 **Contribuição**: Para atualizar a documentação, edite os arquivos correspondentes e regenere os diagramas quando necessário.
