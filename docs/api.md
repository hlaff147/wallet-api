# 📘 API Reference

Centralized list of Wallet API endpoints with minimal curl examples.

## 🔌 Base
- **Run**: `./mvnw spring-boot:run`
- **URL**: `http://localhost:8080`
- **Swagger**: `http://localhost:8080/swagger-ui.html`

## 💳 Wallets
### Criar Carteira
```bash
curl -X POST http://localhost:8080/api/v1/wallets \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","currency":"BRL"}'
```

### Consultar Saldo
```bash
curl http://localhost:8080/api/v1/wallets/{id}/balance
```

## 💰 Operações
### Depósito
```bash
curl -X POST http://localhost:8080/api/v1/wallets/{id}/deposit \
  -H "Content-Type: application/json" \
  -d '{"amount":10000}'
```

### Saque
```bash
curl -X POST http://localhost:8080/api/v1/wallets/{id}/withdraw \
  -H "Content-Type: application/json" \
  -d '{"amount":2500}'
```

### Transferência
```bash
curl -X POST http://localhost:8080/api/v1/transfers \
  -H "Content-Type: application/json" \
  -d '{"fromWalletId":"{from}","toWalletId":"{to}","amount":5000}'
```

## 📊 Consultas
### Extrato
```bash
curl "http://localhost:8080/api/v1/wallets/{id}/ledger"
```

### Saldo Histórico
```bash
curl "http://localhost:8080/api/v1/wallets/{id}/balance/history?at=2024-01-10T12:00:00Z"
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

## 📝 Teste Rápido
```bash
W1=$(curl -s -X POST http://localhost:8080/api/v1/wallets -H 'Content-Type: application/json' -d '{"userId":"u1","currency":"BRL"}' | jq -r '.id')
W2=$(curl -s -X POST http://localhost:8080/api/v1/wallets -H 'Content-Type: application/json' -d '{"userId":"u2","currency":"BRL"}' | jq -r '.id')
curl -X POST http://localhost:8080/api/v1/wallets/$W1/deposit -H 'Content-Type: application/json' -d '{"amount":10000}'
curl -X POST http://localhost:8080/api/v1/transfers -H 'Content-Type: application/json' -d '{"fromWalletId":"'$W1'","toWalletId":"'$W2'","amount":3000}'
curl http://localhost:8080/api/v1/wallets/$W1/balance
curl http://localhost:8080/api/v1/wallets/$W2/balance
```
