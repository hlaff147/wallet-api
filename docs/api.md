# 📘 API Reference

Guia centralizado de endpoints com exemplos completos de requisição e resposta.

## 🔌 Base
- **Run**: `./mvnw spring-boot:run`
- **URL**: `http://localhost:8080`
- **Swagger**: `http://localhost:8080/swagger-ui.html`

## 🗂️ Endpoints

| Método | Caminho | Descrição |
| ------ | ------- | --------- |
| `POST` | `/api/v1/wallets` | Criar nova carteira |
| `GET`  | `/api/v1/wallets/{id}/balance` | Consultar saldo atual |
| `GET`  | `/api/v1/wallets/{id}/balance/history?at=...` | Consultar saldo histórico |
| `GET`  | `/api/v1/wallets/{id}/ledger` | Listar movimentações |
| `POST` | `/api/v1/wallets/{id}/deposit` | Realizar depósito |
| `POST` | `/api/v1/wallets/{id}/withdraw` | Realizar saque |
| `POST` | `/api/v1/transfers` | Transferir entre carteiras |

## 💳 Wallets

### Criar Carteira
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","currency":"BRL"}'
```
**Response**
```json
{
  "id": "64a5b8f1e4b0a1b2c3d4e5f6",
  "userId": "user123",
  "currency": "BRL",
  "status": "ACTIVE",
  "balance": 0
}
```

### Consultar Saldo
```bash
curl http://localhost:8080/api/v1/wallets/{id}/balance
```
**Response**
```json
{
  "walletId": "{id}",
  "balance": 10000,
  "currency": "BRL"
}
```

### Saldo Histórico
```bash
curl "http://localhost:8080/api/v1/wallets/{id}/balance/history?at=2024-01-10T12:00:00Z"
```
**Response**
```json
{
  "walletId": "{id}",
  "balance": 5000,
  "currency": "BRL",
  "at": "2024-01-10T12:00:00Z"
}
```

## 💰 Operações

### Depósito
```bash
curl -X POST http://localhost:8080/api/v1/wallets/{id}/deposit \
  -H "Content-Type: application/json" \
  -d '{"amount":10000}'
```
**Response**
```json
{
  "walletId": "{id}",
  "operation": "DEPOSIT",
  "amount": 10000,
  "occurredAt": "2024-01-10T12:00:00Z"
}
```

### Saque
```bash
curl -X POST http://localhost:8080/api/v1/wallets/{id}/withdraw \
  -H "Content-Type: application/json" \
  -d '{"amount":2500}'
```
**Response**
```json
{
  "walletId": "{id}",
  "operation": "WITHDRAW",
  "amount": 2500,
  "occurredAt": "2024-01-10T13:00:00Z"
}
```

### Transferência
```bash
curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d '{"fromWalletId":"{from}","toWalletId":"{to}","amount":5000}'
```
**Response**
```json
{
  "debit": {
    "walletId": "{from}",
    "operation": "TRANSFER_DEBIT",
    "amount": 5000,
    "occurredAt": "2024-01-10T15:00:00Z"
  },
  "credit": {
    "walletId": "{to}",
    "operation": "TRANSFER_CREDIT",
    "amount": 5000,
    "occurredAt": "2024-01-10T15:00:00Z"
  }
}
```

## 📊 Consultas

### Extrato
```bash
curl "http://localhost:8080/api/v1/wallets/{id}/ledger?from=2024-01-01&to=2024-01-31&page=0&size=50"
```
**Response** *(resumido)*
```json
{
  "content": [
    {"operation": "DEPOSIT", "amount": 10000, "occurredAt": "2024-01-10T12:00:00Z"},
    {"operation": "TRANSFER_DEBIT", "amount": 3000, "occurredAt": "2024-01-10T13:00:00Z"}
  ],
  "pageable": {"pageNumber": 0, "pageSize": 50},
  "totalElements": 2
}
```

## 🔢 Enums
- **Currency**: `BRL`, `USD`, `EUR`
- **WalletStatus**: `ACTIVE`, `BLOCKED`, `SUSPENDED`
- **OperationType**: `DEPOSIT`, `WITHDRAW`, `TRANSFER_DEBIT`, `TRANSFER_CREDIT`

## ⚠️ Códigos de Erro
- `400` dados inválidos
- `404` carteira não encontrada
- `409` saldo insuficiente ou carteira duplicada
- `422` carteira inativa

**Exemplo de resposta de erro**
```json
{
  "type": "about:blank",
  "title": "Insufficient funds",
  "status": 409,
  "detail": "Saldo insuficiente para realizar a operação",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 📝 Fluxo Completo de Teste
```bash
W1=$(curl -s -X POST http://localhost:8080/api/v1/wallets -H 'Content-Type: application/json' -d '{"userId":"u1","currency":"BRL"}' | jq -r '.id')
W2=$(curl -s -X POST http://localhost:8080/api/v1/wallets -H 'Content-Type: application/json' -d '{"userId":"u2","currency":"BRL"}' | jq -r '.id')
curl -X POST http://localhost:8080/api/v1/wallets/$W1/deposit -H 'Content-Type: application/json' -d '{"amount":10000}'
curl -X POST http://localhost:8080/api/v1/transfers -H 'Content-Type: application/json' -d '{"fromWalletId":"'$W1'","toWalletId":"'$W2'","amount":3000}'
curl http://localhost:8080/api/v1/wallets/$W1/balance
curl http://localhost:8080/api/v1/wallets/$W2/balance
```
