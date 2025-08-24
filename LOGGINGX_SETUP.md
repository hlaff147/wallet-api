# Configuração LoggingX Spring Boot Starter

Este documento explica como configurar e usar a biblioteca LoggingX no projeto wallet-api.

## 📋 Status da Integração

✅ **Configurações adicionadas:**
- Dependência no `pom.xml` (comentada temporariamente)
- Configuração no `application.yml`
- Configuração do Logback em `logback-spring.xml`
- Anotações preparadas no `WalletServiceImpl` (comentadas temporariamente)

⚠️ **Próximos passos necessários:**
1. Compilar e instalar a biblioteca LoggingX localmente
2. Descomentar as dependências e anotações
3. Testar a integração

## 🛠️ Como Instalar a Biblioteca LoggingX

### 1. Criar o projeto LoggingX

Primeiro, crie o projeto da biblioteca conforme o POM fornecido:

```bash
# Criar diretório do projeto
mkdir loggingx-spring-boot-starter
cd loggingx-spring-boot-starter

# Copiar o conteúdo do pom.xml fornecido
# Implementar as classes da biblioteca
```

### 2. Instalar no repositório local Maven

```bash
# No diretório da biblioteca LoggingX
mvn clean install
```

### 3. Habilitar no projeto wallet-api

Após instalar a biblioteca localmente:

1. **Descomente a dependência no `pom.xml`:**

```xml
<!-- LoggingX Spring Boot Starter - descomente após instalar localmente -->
<dependency>
    <groupId>com.hlaff</groupId>
    <artifactId>loggingx-spring-boot-starter</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

2. **Descomente os imports no `WalletServiceImpl.java`:**

```java
import com.hlaff.loggingx.annotation.BusinessEvent;
import com.hlaff.loggingx.annotation.Loggable;
import com.hlaff.loggingx.annotation.Sensitive;
```

3. **Descomente as anotações nos métodos:**

```java
@Loggable
@BusinessEvent(type = "Wallet", name = "WalletCreated", version = 1)
public WalletResponse createWallet(CreateWalletRequest req) {
    // ...
}
```

## 🔧 Configurações Aplicadas

### application.yml

```yaml
loggingx:
  service: wallet-api
  env: ${ENVIRONMENT:dev}
  version: ${APP_VERSION:0.0.1-SNAPSHOT}
  
  redact-keys: 
    - password
    - token 
    - cpf
    - email
    - secret
    - accountNumber
    - balance
    - amount
    
  http:
    server:
      enabled: true
      log-body: false
    client: 
      enabled: true
      log-body: false
      
  mongo:
    enabled: true
    slow-queries-only: true
    slow-threshold-ms: 1000
    
  sampling:
    default-percent: 100
    rules:
      - pattern: ".*HealthCheck.*" 
        percent: 10
```

### logback-spring.xml

- Configuração para logs estruturados JSON em produção
- Logs simples em desenvolvimento
- Appender assíncrono para performance
- Configuração específica por ambiente

### Anotações Preparadas

- `@Loggable`: Para logging automático de entrada/saída de métodos
- `@BusinessEvent`: Para eventos de negócio estruturados
- `@Sensitive`: Para mascaramento de dados sensíveis como walletId

## 📊 Exemplo de Logs Esperados

### Log Técnico (com @Loggable)
```json
{
  "@timestamp": "2025-01-20T14:05:23.817Z",
  "level": "INFO",
  "service": "wallet-api",
  "env": "dev",
  "version": "0.0.1-SNAPSHOT",
  "correlationId": "c-7f1d5363",
  "component": "aop",
  "class": "WalletServiceImpl",
  "method": "createWallet",
  "args": {"userId": "user123", "currency": "BRL"},
  "return": {"id": "***", "userId": "user123", "status": "ACTIVE"},
  "durationMs": 45,
  "sampled": true
}
```

### Log de Negócio (com @BusinessEvent)
```json
{
  "@timestamp": "2025-01-20T14:05:23.820Z",
  "level": "INFO",
  "service": "wallet-api",
  "env": "dev",
  "correlationId": "c-7f1d5363",
  "component": "business",
  "eventType": "Wallet",
  "eventName": "WalletCreated",
  "eventVersion": 1,
  "eventPayload": {"id": "***", "userId": "user123", "currency": "BRL", "status": "ACTIVE"}
}
```

## 🚀 Testando a Integração

Após habilitar a biblioteca:

1. **Compile o projeto:**
```bash
mvn clean compile
```

2. **Execute os testes:**
```bash
mvn test
```

3. **Execute a aplicação:**
```bash
mvn spring-boot:run
```

4. **Teste uma operação:**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"userId": "user123", "currency": "BRL"}'
```

5. **Verifique os logs estruturados no console**

## 🔍 Troubleshooting

- **Erro de compilação**: Verifique se a biblioteca LoggingX foi instalada corretamente com `mvn install`
- **Anotações não funcionam**: Confirme se o Spring AOP está habilitado e as anotações estão descomentadas
- **Logs não aparecem**: Verifique a configuração do `application.yml` e `logback-spring.xml`

## 📝 Próximas Melhorias

- Adicionar interceptor HTTP para correlação automática
- Configurar monitoring com Micrometer/Prometheus
- Adicionar dashboards específicos para observabilidade
- Implementar alertas baseados em logs estruturados
