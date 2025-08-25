# 🛠️ Development Guide

Centralized instructions for running and maintaining the project.

## 🐳 Docker
- **Prerequisites**: Docker 20.10+, Docker Compose 2.0+
- **Quick start**
```bash
git clone <repo-url>
cd wallet-api
docker-compose up -d
curl http://localhost:8080/actuator/health
```
- **Useful commands**
```bash
docker-compose logs -f
docker-compose stop
docker-compose down -v
```

## 📝 LoggingX Setup
- Install the `loggingx-spring-boot-starter` locally:
```bash
mvn clean install
```
- Uncomment the dependency in `pom.xml` and annotations in `WalletServiceImpl`.
- Configure `application.yml`:
```yaml
loggingx:
  service: wallet-api
  env: ${ENVIRONMENT:dev}
```
- Run tests and start the app to verify structured logs.

## ✅ Testing
- **Structure**: unit, web, repository and mapper tests under `src/test/java`.
- **Run all tests**
```bash
./mvnw test
```
- **Run specific groups**
```bash
./mvnw test -Dtest="**/*RepositoryTest"   # integration
./mvnw test -Dtest="WalletServiceImplTest" # single test
```
- Repository tests use Testcontainers, so Docker must be running.
