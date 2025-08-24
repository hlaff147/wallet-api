# Dockerfile para Wallet API
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Informações do build
LABEL maintainer="hlaff@example.com"
LABEL version="1.0.0"
LABEL description="Wallet API - Sistema de carteiras digitais"

# Definir diretório de trabalho
WORKDIR /app

# Copiar POM e baixar dependências (cache layer)
COPY pom.xml ./
RUN mvn -B dependency:go-offline

# Copiar código fonte
COPY src/ src/

# Build da aplicação
RUN mvn -B -DskipTests clean package && \
    java -Djarmode=layertools -jar target/*.jar extract

# Runtime stage
FROM eclipse-temurin:17-jre
# Instalar curl para health checks
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Criar usuário não-root
RUN groupadd -r wallet && useradd -r -g wallet wallet

# Definir diretório de trabalho
WORKDIR /app

# Copiar layers da aplicação para otimizar cache
COPY --from=builder --chown=wallet:wallet /app/dependencies/ ./
COPY --from=builder --chown=wallet:wallet /app/spring-boot-loader/ ./
COPY --from=builder --chown=wallet:wallet /app/snapshot-dependencies/ ./
COPY --from=builder --chown=wallet:wallet /app/application/ ./

# Mudar para usuário não-root
USER wallet

# Expor porta da aplicação
EXPOSE 8080

# Variáveis de ambiente padrão
ENV JAVA_OPTS="-Xmx512m -Xms256m" \
    SPRING_PROFILES_ACTIVE="docker"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Comando de inicialização
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
