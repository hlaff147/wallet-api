# 🌐 Wallet API - Exemplos de Curl

Este documento contém exemplos completos de todos os endpoints da Wallet API usando `curl`. Todos os exemplos assumem que a API está rodando em `http://localhost:8080`.

## 📋 Índice

- [🚀 Setup e Configuração](#-setup-e-configuração)
- [💳 Gestão de Carteiras](#-gestão-de-carteiras)
- [💰 Operações Financeiras](#-operações-financeiras)
- [📊 Extrato e Consultas](#-extrato-e-consultas)
- [🎭 Cenários Completos](#-cenários-completos)
- [❌ Casos de Erro](#-casos-de-erro)
- [🔧 Utilitários](#-utilitários)

## 🚀 Setup e Configuração

### Verificar se a API está rodando
```bash
curl -X GET http://localhost:8080/actuator/health
```

### Acessar documentação Swagger
```bash
# Abrir no navegador
open http://localhost:8080/swagger-ui.html

# Ou baixar a especificação OpenAPI
curl -X GET http://localhost:8080/v3/api-docs | jq .
```

## 💳 Gestão de Carteiras

### 1. Criar Nova Carteira

**Carteira em Real (BRL)**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "currency": "BRL"
  }' | jq .
```

**Carteira em Dólar (USD)**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user456",
    "currency": "USD"
  }' | jq .
```

**Carteira em Euro (EUR)**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user789",
    "currency": "EUR"
  }' | jq .
```

**Resposta esperada:**
```json
{
  "id": "65f8c4b8e1234567890abcde",
  "userId": "user123",
  "currency": "BRL",
  "balance": 0,
  "status": "ACTIVE",
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-15T10:30:00Z"
}
```

### 2. Buscar Carteira por ID

```bash
WALLET_ID="65f8c4b8e1234567890abcde"

curl -X GET http://localhost:8080/api/v1/wallets/$WALLET_ID \
  -H "Accept: application/json" | jq .
```

### 3. Consultar Saldo Atual

```bash
curl -X GET http://localhost:8080/api/v1/wallets/$WALLET_ID/balance \
  -H "Accept: application/json" | jq .
```

**Resposta esperada:**
```json
{
  "id": "65f8c4b8e1234567890abcde",
  "balance": 25000,
  "currency": "BRL",
  "asOf": "2024-01-15T10:30:00Z"
}
```

### 4. Consultar Saldo Histórico

**Saldo em uma data específica**
```bash
DATE="2024-01-15T08:00:00Z"

curl -X GET "http://localhost:8080/api/v1/wallets/$WALLET_ID/balance/history?at=$DATE" \
  -H "Accept: application/json" | jq .
```

## 💰 Operações Financeiras

### 1. Realizar Depósito

**Depósito simples**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50000
  }' | jq .
```

**Depósito com metadata**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 25000,
    "metadata": {
      "source": "PIX",
      "description": "Transferência recebida",
      "externalId": "pix_12345"
    }
  }' | jq .
```

### 2. Realizar Saque

**Saque simples**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 10000
  }' | jq .
```

**Saque com metadata**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 5000,
    "metadata": {
      "destination": "BANK_TRANSFER",
      "bankAccount": "12345-6",
      "reason": "Pagamento de conta"
    }
  }' | jq .
```

### 3. Transferência entre Carteiras

**Transferência simples**
```bash
FROM_WALLET="65f8c4b8e1234567890abcde"
TO_WALLET="65f8c4b8e1234567890abcdf"

curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d "{
    \"fromWalletId\": \"$FROM_WALLET\",
    \"toWalletId\": \"$TO_WALLET\",
    \"amount\": 15000
  }" | jq .
```

**Transferência com metadata**
```bash
curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d "{
    \"fromWalletId\": \"$FROM_WALLET\",
    \"toWalletId\": \"$TO_WALLET\",
    \"amount\": 20000,
    \"metadata\": {
      \"type\": \"PAYMENT\",
      \"description\": \"Pagamento de serviço\",
      \"invoiceId\": \"INV-001\",
      \"category\": \"services\"
    }
  }" | jq .
```

## 📊 Extrato e Consultas

### 1. Extrato Completo

```bash
curl -X GET http://localhost:8080/api/v1/wallets/$WALLET_ID/ledger \
  -H "Accept: application/json" | jq .
```

### 2. Extrato por Período

**Último mês**
```bash
FROM_DATE="2024-01-01T00:00:00Z"
TO_DATE="2024-01-31T23:59:59Z"

curl -X GET "http://localhost:8080/api/v1/wallets/$WALLET_ID/ledger?from=$FROM_DATE&to=$TO_DATE" \
  -H "Accept: application/json" | jq .
```

**Últimas 24 horas**
```bash
FROM_DATE=$(date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%SZ)
TO_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

curl -X GET "http://localhost:8080/api/v1/wallets/$WALLET_ID/ledger?from=$FROM_DATE&to=$TO_DATE" \
  -H "Accept: application/json" | jq .
```

### 3. Extrato com Paginação

```bash
curl -X GET "http://localhost:8080/api/v1/wallets/$WALLET_ID/ledger?page=0&size=10&sort=occurredAt,desc" \
  -H "Accept: application/json" | jq .
```

**Resposta esperada:**
```json
{
  "content": [
    {
      "id": "65f8c4b8e1234567890abce0",
      "walletId": "65f8c4b8e1234567890abcde",
      "transferId": null,
      "operation": "DEPOSIT",
      "amount": 50000,
      "occurredAt": "2024-01-15T10:30:00Z",
      "resultingBalance": 50000,
      "metadata": {
        "source": "PIX"
      }
    }
  ],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10
  },
  "totalElements": 5,
  "totalPages": 1
}
```

## 🎭 Cenários Completos

### Cenário 1: Fluxo Básico de Carteira

```bash
#!/bin/bash

echo "🎯 Cenário 1: Fluxo Básico de Carteira"
echo "===================================="

# 1. Criar carteira
echo "1️⃣ Criando carteira..."
WALLET_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "demo-user",
    "currency": "BRL"
  }')

WALLET_ID=$(echo $WALLET_RESPONSE | jq -r '.id')
echo "✅ Carteira criada: $WALLET_ID"

# 2. Verificar saldo inicial
echo "2️⃣ Verificando saldo inicial..."
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_ID/balance | jq .

# 3. Fazer depósito
echo "3️⃣ Realizando depósito de R$ 500,00..."
curl -s -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 50000,
    "metadata": {
      "source": "PIX",
      "description": "Depósito inicial"
    }
  }' | jq .

# 4. Verificar novo saldo
echo "4️⃣ Verificando novo saldo..."
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_ID/balance | jq .

# 5. Fazer saque
echo "5️⃣ Realizando saque de R$ 150,00..."
curl -s -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 15000,
    "metadata": {
      "destination": "BANK_TRANSFER",
      "reason": "Pagamento"
    }
  }' | jq .

# 6. Ver extrato
echo "6️⃣ Visualizando extrato..."
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_ID/ledger | jq .

echo "🎉 Cenário concluído com sucesso!"
```

### Cenário 2: Transferência entre Carteiras

```bash
#!/bin/bash

echo "🎯 Cenário 2: Transferência entre Carteiras"
echo "=========================================="

# 1. Criar primeira carteira
echo "1️⃣ Criando carteira do usuário A..."
WALLET_A=$(curl -s -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-a",
    "currency": "BRL"
  }' | jq -r '.id')

# 2. Criar segunda carteira
echo "2️⃣ Criando carteira do usuário B..."
WALLET_B=$(curl -s -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user-b",
    "currency": "BRL"
  }' | jq -r '.id')

# 3. Depositar na carteira A
echo "3️⃣ Depositando R$ 1000,00 na carteira A..."
curl -s -X POST http://localhost:8080/api/v1/wallets/$WALLET_A/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 100000
  }' | jq .

# 4. Verificar saldos antes da transferência
echo "4️⃣ Saldos antes da transferência:"
echo "Carteira A:"
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_A/balance | jq .
echo "Carteira B:"
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_B/balance | jq .

# 5. Realizar transferência
echo "5️⃣ Transferindo R$ 300,00 de A para B..."
curl -s -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d "{
    \"fromWalletId\": \"$WALLET_A\",
    \"toWalletId\": \"$WALLET_B\",
    \"amount\": 30000,
    \"metadata\": {
      \"type\": \"P2P_TRANSFER\",
      \"description\": \"Transferência entre amigos\"
    }
  }" | jq .

# 6. Verificar saldos após transferência
echo "6️⃣ Saldos após transferência:"
echo "Carteira A:"
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_A/balance | jq .
echo "Carteira B:"
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_B/balance | jq .

# 7. Ver extratos
echo "7️⃣ Extrato da carteira A:"
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_A/ledger | jq .
echo "8️⃣ Extrato da carteira B:"
curl -s -X GET http://localhost:8080/api/v1/wallets/$WALLET_B/ledger | jq .

echo "🎉 Cenário concluído com sucesso!"
```

## ❌ Casos de Erro

### 1. Validação de Entrada

**Valor negativo**
```bash
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "amount": -1000
  }' | jq .
```

**Moeda inválida**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "currency": "INVALID"
  }' | jq .
```

**UserId vazio**
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "",
    "currency": "BRL"
  }' | jq .
```

### 2. Saldo Insuficiente

```bash
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET_ID/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 999999999
  }' | jq .
```

**Resposta esperada:**
```json
{
  "type": "about:blank",
  "title": "Insufficient funds",
  "status": 409,
  "detail": "Saldo insuficiente para realizar a operação",
  "instance": "/api/v1/wallets/65f8c4b8e1234567890abcde/withdraw"
}
```

### 3. Carteira Não Encontrada

```bash
curl -X GET http://localhost:8080/api/v1/wallets/000000000000000000000000 \
  -H "Accept: application/json" | jq .
```

**Resposta esperada:**
```json
{
  "type": "about:blank",
  "title": "Not Found",
  "status": 404,
  "detail": "Carteira não encontrada",
  "instance": "/api/v1/wallets/000000000000000000000000"
}
```

### 4. Transferência entre Moedas Diferentes

```bash
# Assumindo que WALLET_USD usa moeda USD
curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d "{
    \"fromWalletId\": \"$WALLET_ID\",
    \"toWalletId\": \"$WALLET_USD\",
    \"amount\": 10000
  }" | jq .
```

## 🔧 Utilitários

### 1. Scripts de Configuração

**Configurar variáveis de ambiente**
```bash
#!/bin/bash
export API_BASE_URL="http://localhost:8080"
export WALLET_API_TOKEN=""  # Se autenticação estiver habilitada

# Função helper para fazer requests
api_call() {
  local method=$1
  local endpoint=$2
  local data=$3
  
  curl -X $method "$API_BASE_URL$endpoint" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    ${data:+-d "$data"} | jq .
}

# Exemplo de uso
# api_call POST "/api/v1/wallets" '{"userId": "test", "currency": "BRL"}'
```

### 2. Validação de Valores

**Converter reais para centavos**
```bash
convert_to_cents() {
  local amount=$1
  echo $(echo "$amount * 100" | bc)
}

# Exemplo: R$ 15,50 = 1550 centavos
AMOUNT_CENTS=$(convert_to_cents 15.50)
echo $AMOUNT_CENTS  # Output: 1550
```

**Converter centavos para reais**
```bash
convert_to_reais() {
  local cents=$1
  echo "scale=2; $cents / 100" | bc
}

# Exemplo: 1550 centavos = R$ 15.50
AMOUNT_REAIS=$(convert_to_reais 1550)
echo "R$ $AMOUNT_REAIS"  # Output: R$ 15.50
```

### 3. Monitoramento

**Check da saúde da aplicação**
```bash
#!/bin/bash
echo "🔍 Verificando saúde da aplicação..."

HEALTH=$(curl -s http://localhost:8080/actuator/health)
STATUS=$(echo $HEALTH | jq -r '.status')

if [ "$STATUS" = "UP" ]; then
  echo "✅ Aplicação está funcionando"
  echo $HEALTH | jq .
else
  echo "❌ Aplicação com problemas"
  echo $HEALTH | jq .
  exit 1
fi
```

**Métricas da aplicação**
```bash
curl -s http://localhost:8080/actuator/metrics | jq .
curl -s http://localhost:8080/actuator/metrics/jvm.memory.used | jq .
curl -s http://localhost:8080/actuator/metrics/http.server.requests | jq .
```

---

## 📝 Notas Importantes

### 💰 Valores Monetários
- Todos os valores são em **centavos** para evitar problemas de ponto flutuante
- R$ 10,50 = 1050 centavos
- R$ 100,00 = 10000 centavos

### 🔗 Correlation IDs
- A API gera automaticamente correlation IDs para rastreabilidade
- Visíveis nos logs da aplicação

### 📅 Formatos de Data
- Todas as datas estão em formato ISO 8601 UTC
- Exemplo: `2024-01-15T10:30:00Z`

### 🎯 Headers Úteis
```bash
# Para debug
-H "X-Correlation-ID: your-custom-id"

# Para aceitar apenas JSON
-H "Accept: application/json"

# Para autenticação (se implementada)
-H "Authorization: Bearer <token>"
```

---

💡 **Dica**: Salve os exemplos como scripts `.sh` para reutilização fácil!
