# Etapa 1: Build do JAR
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY ../../.. .
RUN mvn -f av2/com/demo/pom.xml clean package -DskipTests

# Etapa 2: Imagem final para rodar o JAR
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=build /app/av2/com/demo/target/demo-0.0.1-SNAPSHOT.jar app.jar

# Adicione metadados
LABEL maintainer="Demo Project" \
      version="0.0.1-SNAPSHOT" \
      description="Spring Boot Demo Application"

# Crie um usuário não-root para segurança
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Mude a propriedade do arquivo para o usuário não-root
RUN chown appuser:appuser app.jar

# Mude para o usuário não-root
USER appuser

# Exponha a porta padrão do Spring Boot
EXPOSE 8080

# Configurações de JVM otimizadas para containers
ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Healthcheck para verificar se a aplicação está funcionando
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

# Comando para rodar a aplicação com as configurações otimizadas
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"] 