# Wallet API - Guia Rápido

## Como Executar

```bash
./mvnw spring-boot:run
```

**URL Base**: `http://localhost:8080`  
**Swagger**: `http://localhost:8080/swagger-ui.html`

## Endpoints e Exemplos

### 1. Criar Carteira

```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "user123",
    "currency": "BRL"
  }'
```

**Resposta:**
```json
{
  "id": "64a5b8f1e4b0a1b2c3d4e5f6",
  "userId": "user123",
  "currency": "BRL",
  "status": "ACTIVE",
  "balance": 0
}
```

### 2. Consultar Saldo

```bash
curl http://localhost:8080/api/v1/wallets/{id}/balance
```

**Resposta:**
```json
{
  "id": "64a5b8f1e4b0a1b2c3d4e5f6",
  "currency": "BRL",
  "balance": 25000,
  "asOf": "2024-01-15T10:30:00Z"
}
```

### 3. Depósito

```bash
curl -X POST http://localhost:8080/api/v1/wallets/{id}/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 10000,
    "metadata": {
      "source": "PIX",
      "description": "Depósito via PIX"
    }
  }'
```

**Resposta:**
```json
{
  "id": "64a5b8f1e4b0a1b2c3d4e5f7",
  "walletId": "64a5b8f1e4b0a1b2c3d4e5f6",
  "operation": "DEPOSIT",
  "amount": 10000,
  "occurredAt": "2024-01-15T10:30:00Z",
  "resultingBalance": 10000
}
```

### 4. Saque

```bash
curl -X POST http://localhost:8080/api/v1/wallets/{id}/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "amount": 2500,
    "metadata": {
      "method": "TED",
      "destination": "Banco ABC"
    }
  }'
```

### 5. Transferência

```bash
curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d '{
    "fromWalletId": "64a5b8f1e4b0a1b2c3d4e5f6",
    "toWalletId": "64a5b8f1e4b0a1b2c3d4e5f8",
    "amount": 5000,
    "metadata": {
      "type": "payment",
      "description": "Pagamento de serviço"
    }
  }'
```

**Resposta:**
```json
{
  "transferId": "txn-123e4567-e89b-12d3-a456-426614174000",
  "fromWallet": {
    "id": "64a5b8f1e4b0a1b2c3d4e5f6",
    "newBalance": 5000
  },
  "toWallet": {
    "id": "64a5b8f1e4b0a1b2c3d4e5f8",
    "newBalance": 15000
  },
  "debitEntry": {
    "id": "64a5b8f1e4b0a1b2c3d4e5f9",
    "walletId": "64a5b8f1e4b0a1b2c3d4e5f6",
    "operation": "TRANSFER_DEBIT",
    "amount": 5000,
    "occurredAt": "2024-01-15T10:35:00Z",
    "resultingBalance": 5000
  },
  "creditEntry": {
    "id": "64a5b8f1e4b0a1b2c3d4e5fa",
    "walletId": "64a5b8f1e4b0a1b2c3d4e5f8",
    "operation": "TRANSFER_CREDIT",
    "amount": 5000,
    "occurredAt": "2024-01-15T10:35:00Z",
    "resultingBalance": 15000
  }
}
```

### 6. Extrato (com paginação)

```bash
# Extrato completo (últimas 50 movimentações)
curl "http://localhost:8080/api/v1/wallets/{id}/ledger"

# Extrato por período
curl "http://localhost:8080/api/v1/wallets/{id}/ledger?from=2024-01-01T00:00:00Z&to=2024-01-31T23:59:59Z"

# Extrato com paginação
curl "http://localhost:8080/api/v1/wallets/{id}/ledger?page=0&size=10&sort=occurredAt,desc"
```

### 7. Saldo Histórico

```bash
curl "http://localhost:8080/api/v1/wallets/{id}/balance/history?at=2024-01-10T12:00:00Z"
```

## Enums Disponíveis

### Currency (Moedas)
- `BRL` - Real Brasileiro
- `USD` - Dólar Americano  
- `EUR` - Euro

### WalletStatus (Status da Carteira)
- `ACTIVE` - Ativa
- `BLOCKED` - Bloqueada
- `SUSPENDED` - Suspensa

### OperationType (Tipos de Operação)
- `DEPOSIT` - Depósito
- `WITHDRAW` - Saque
- `TRANSFER_DEBIT` - Débito de transferência
- `TRANSFER_CREDIT` - Crédito de transferência

## Valores Monetários

- Todos os valores são em **centavos** (inteiros)
- R$ 100,00 = 10000 centavos
- R$ 1,50 = 150 centavos

## Códigos de Erro

- `400` - Dados inválidos
- `404` - Carteira não encontrada
- `409` - Saldo insuficiente ou carteira duplicada
- `422` - Carteira inativa

## Teste Rápido

```bash
# 1. Criar duas carteiras
WALLET1=$(curl -s -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"userId":"user1","currency":"BRL"}' | jq -r '.id')

WALLET2=$(curl -s -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"userId":"user2","currency":"BRL"}' | jq -r '.id')

# 2. Depositar na primeira carteira
curl -X POST http://localhost:8080/api/v1/wallets/$WALLET1/deposit \
  -H "Content-Type: application/json" \
  -d '{"amount":10000,"metadata":{"source":"test"}}'

# 3. Transferir entre carteiras
curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d "{\"fromWalletId\":\"$WALLET1\",\"toWalletId\":\"$WALLET2\",\"amount\":3000,\"metadata\":{\"type\":\"test\"}}"

# 4. Verificar saldos
curl http://localhost:8080/api/v1/wallets/$WALLET1/balance
curl http://localhost:8080/api/v1/wallets/$WALLET2/balance
```
