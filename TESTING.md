# Guia de Testes - Wallet API

## Estrutura de Testes

A aplicação possui uma cobertura completa de testes organizados em diferentes camadas:

### 📁 Estrutura de Arquivos de Teste

```
src/test/java/com/hlaff/wallet_api/
├── service/
│   └── WalletServiceImplTest.java      # Testes unitários do service
├── controller/
│   ├── WalletControllerTest.java       # Testes da API de carteiras
│   ├── TransferControllerTest.java     # Testes da API de transferências
│   └── LedgerControllerTest.java       # Testes da API de extrato
├── repository/
│   ├── WalletRepositoryTest.java       # Testes de integração com MongoDB
│   └── LedgerEntryRepositoryTest.java  # Testes de queries customizadas
└── mapper/
    ├── WalletMapperTest.java           # Testes dos mappers MapStruct
    ├── LedgerEntryMapperTest.java      # Testes de conversões DTO/Model
    └── BalanceMapperTest.java          # Testes de formatação de saldo
```

## Tipos de Teste

### 🧪 **Testes Unitários (Service)**
- **Tecnologias**: JUnit 5, Mockito, AssertJ
- **Escopo**: Lógica de negócio isolada
- **Mocks**: Repositories e Mappers
- **Cobertura**: Todos os cenários de regras de negócio

**Cenários testados:**
- ✅ Criação de carteiras (sucesso e duplicação)
- ✅ Consulta de saldos (atual e histórico)
- ✅ Depósitos e saques
- ✅ Transferências entre carteiras
- ✅ Validações de negócio (saldo insuficiente, carteira inativa)
- ✅ Tratamento de exceções

### 🌐 **Testes de Controller (WebMvcTest)**
- **Tecnologias**: Spring WebMvcTest, MockMvc
- **Escopo**: Camada REST e serialização JSON
- **Mocks**: WalletService
- **Cobertura**: Endpoints, validações, códigos HTTP

**Cenários testados:**
- ✅ Validação de entrada (Bean Validation)
- ✅ Respostas HTTP corretas (200, 201, 400, 404, 409)
- ✅ Serialização/deserialização JSON
- ✅ Tratamento de exceções globais (RFC 7807)

### 🗄️ **Testes de Repository (DataMongoTest + TestContainers)**
- **Tecnologias**: Spring DataMongoTest, TestContainers
- **Escopo**: Queries MongoDB e persistência
- **Banco**: MongoDB real em container Docker
- **Cobertura**: Queries customizadas, índices, constraints

**Cenários testados:**
- ✅ CRUD básico (save, find, delete)
- ✅ Queries customizadas com filtros
- ✅ Paginação e ordenação
- ✅ Constraints de unicidade
- ✅ Índices compostos

### 🔄 **Testes de Mapper (MapStruct)**
- **Tecnologias**: JUnit 5, MapStruct
- **Escopo**: Conversões DTO ↔ Model
- **Cobertura**: Mapeamentos automáticos e customizados

**Cenários testados:**
- ✅ Conversões DTO Request → Model
- ✅ Conversões Model → DTO Response
- ✅ Preservação de enums e tipos
- ✅ Campos ignorados e calculados

## Como Executar os Testes

### 🚀 **Executar Todos os Testes**

```bash
# Maven
./mvnw test

# Gradle (se aplicável)
./gradlew test
```

### 🎯 **Executar por Categoria**

```bash
# Apenas testes unitários (rápidos)
./mvnw test -Dtest="**/*Test"

# Apenas testes de integração (com TestContainers)
./mvnw test -Dtest="**/*RepositoryTest"

# Apenas testes de controllers
./mvnw test -Dtest="**/*ControllerTest"

# Teste específico
./mvnw test -Dtest="WalletServiceImplTest"
```

### 🐳 **Pré-requisitos para Testes de Integração**

Os testes de repository usam **TestContainers** que requer:

```bash
# Docker deve estar rodando
docker --version

# TestContainers irá baixar automaticamente:
# - mongo:7.0 (container MongoDB)
```

### 📊 **Relatório de Cobertura**

```bash
# Gerar relatório de cobertura (JaCoCo)
./mvnw test jacoco:report

# Visualizar em: target/site/jacoco/index.html
```

## Estrutura dos Testes

### **WalletServiceImplTest** - Exemplos de Cenários

```java
@Test
@DisplayName("Deve realizar depósito com sucesso")
void shouldDepositSuccessfully() {
    // Given
    when(walletRepository.findById("wallet-123")).thenReturn(Optional.of(wallet));
    
    // When
    LedgerEntryResponse result = walletService.deposit("wallet-123", amountRequest);
    
    // Then
    assertThat(result.operation()).isEqualTo(OperationType.DEPOSIT);
    verify(walletRepository).save(wallet);
}
```

### **WalletControllerTest** - Exemplos de Testes REST

```java
@Test
@DisplayName("Deve criar carteira com sucesso")
void shouldCreateWalletSuccessfully() throws Exception {
    mockMvc.perform(post("/api/v1/wallets")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.id").value("wallet-123"));
}
```

### **WalletRepositoryTest** - Exemplos com TestContainers

```java
@DataMongoTest
@Testcontainers
class WalletRepositoryTest {
    
    @Container
    static MongoDBContainer mongoDBContainer = new MongoDBContainer("mongo:7.0");
    
    @Test
    void shouldFindWalletByUserIdAndCurrency() {
        // Teste com MongoDB real
    }
}
```

## Configuração de Teste

### **application-test.yml**
```yaml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/wallet-test

logging:
  level:
    com.hlaff.wallet_api: DEBUG
```

## Boas Práticas Implementadas

### ✅ **Nomenclatura Clara**
- Métodos com nomes descritivos
- `@DisplayName` em português
- Estrutura Given/When/Then

### ✅ **Isolamento**
- Cada teste é independente
- Setup/cleanup adequados
- Mocks bem definidos

### ✅ **Cobertura Completa**
- Cenários de sucesso
- Casos de erro
- Edge cases

### ✅ **Performance**
- Testes unitários rápidos (<100ms)
- TestContainers com reuso
- Mocks em vez de integração quando possível

### ✅ **Manutenibilidade**
- Factories e builders para dados de teste
- Constantes para valores reutilizados
- Helpers para cenários comuns

## Executar Testes em CI/CD

```yaml
# GitHub Actions exemplo
- name: Run Tests
  run: ./mvnw test
  
- name: Generate Test Report
  run: ./mvnw jacoco:report
  
- name: Upload Coverage
  uses: codecov/codecov-action@v1
```

## Troubleshooting

### **MongoDB TestContainers não inicia**
```bash
# Verificar Docker
docker ps

# Limpar containers
docker system prune -f
```

### **Testes lentos**
```bash
# Executar apenas unitários
./mvnw test -Dtest="!**/*RepositoryTest"
```

### **Falhas de serialização JSON**
- Verificar anotações Jackson nos DTOs
- Conferir configuração ObjectMapper

## Métricas de Qualidade

- **Cobertura de Código**: > 90%
- **Tempo de Execução**: < 30s (unitários)
- **Tempo de Execução**: < 2min (todos)
- **Flakiness**: 0% (testes determinísticos)
