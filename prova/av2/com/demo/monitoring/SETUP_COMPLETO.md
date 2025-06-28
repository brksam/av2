# Setup Completo - Monitoramento Spring Boot AV2

Este guia fornece todas as instruções necessárias para configurar e demonstrar o monitoramento da aplicação Spring Boot para a avaliação AV2.

## 📋 Status do Projeto

### ✅ Implementado
- [x] Aplicação Spring Boot com autenticação JWT
- [x] Endpoints REST para Livros e Editoras
- [x] Documentação Swagger/OpenAPI
- [x] Testes unitários (JUnit/Mockito)
- [x] Testes de carga (JMeter)
- [x] Configuração Actuator + Prometheus
- [x] Dashboards Grafana
- [x] Scripts de automação

### 🎯 Pendente
- [ ] Executar Grafana/Prometheus em ambiente funcional
- [ ] Demonstrar dashboards interativos

## 🚀 Setup Rápido (Recomendado)

### Opção 1: Docker (Mais Fácil)

```bash
# 1. Iniciar aplicação Spring Boot
cd provaMariaDB-main/prova/demo
mvn spring-boot:run

# 2. Em outro terminal, iniciar monitoramento
cd monitoring
docker-compose up -d

# 3. Acessar interfaces
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

### Opção 2: Setup Manual (Windows)

```powershell
# 1. Executar script de setup
cd provaMariaDB-main/prova/demo/monitoring
.\setup-monitoring.ps1

# 2. Iniciar serviços
.\start-prometheus.bat
.\start-grafana.bat

# 3. Acessar interfaces
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
```

## 📊 Dashboards Disponíveis

### 1. Spring Boot Application Dashboard
**Arquivo**: `grafana/dashboards/spring-boot-dashboard.json`

**Painéis**:
- HTTP Requests Total
- HTTP Response Time
- JVM Memory Usage
- JVM Threads
- Database Connections
- HTTP Status Codes

### 2. Business Metrics Dashboard
**Arquivo**: `grafana/dashboards/business-metrics-dashboard.json`

**Painéis**:
- Requisições por Endpoint (Tabela)
- Tempo de Resposta por Endpoint
- Códigos de Status HTTP
- Requisições por Minuto
- Uso de CPU da JVM
- Heap Memory Usage
- Database Connection Pool
- Garbage Collection Time

## 🔧 Configuração Detalhada

### 1. Aplicação Spring Boot

**Verificar configuração**:
```yaml
# application.yml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
```

**Dependências necessárias**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
<dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
</dependency>
```

### 2. Prometheus

**Configuração**: `prometheus.yml`
```yaml
scrape_configs:
  - job_name: 'spring-boot-app'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
```

### 3. Grafana

**Datasource**: Configurado automaticamente via `grafana/provisioning/datasources/prometheus.yml`

**Dashboards**: Provisionados automaticamente via `grafana/provisioning/dashboards/dashboard.yml`

## 🎭 Demonstração da Avaliação

### Script de Geração de Tráfego

```powershell
# Gerar tráfego contínuo para demonstrar métricas
cd provaMariaDB-main/prova/demo/monitoring
.\generate-traffic.ps1 -Duration 600 -Interval 2
```

### Passo a Passo da Demonstração

1. **Iniciar tudo**:
   ```bash
   # Terminal 1: Aplicação
   mvn spring-boot:run
   
   # Terminal 2: Monitoramento
   docker-compose up -d
   
   # Terminal 3: Tráfego
   .\generate-traffic.ps1
   ```

2. **Demonstrar Prometheus**:
   - Acessar http://localhost:9090
   - Mostrar Status > Targets (deve estar UP)
   - Executar queries:
     ```
     http_server_requests_seconds_count
     rate(http_server_requests_seconds_count[5m])
     jvm_memory_used_bytes
     ```

3. **Demonstrar Grafana**:
   - Acessar http://localhost:3000 (admin/admin)
   - Importar dashboards
   - Mostrar painéis em tempo real

4. **Executar Teste JMeter**:
   ```bash
   jmeter -n -t jmeter-tests/TestesJm.jmx -l results.jtl
   ```

## 📈 Métricas Importantes

### Métricas de Infraestrutura
- `jvm_memory_used_bytes` - Uso de memória
- `jvm_threads_live_threads` - Threads ativas
- `process_cpu_usage` - Uso de CPU
- `hikaricp_connections_active` - Conexões de banco

### Métricas de Aplicação
- `http_server_requests_seconds_count` - Total de requisições
- `http_server_requests_seconds_sum` - Soma dos tempos
- `http_server_requests_seconds_max` - Tempo máximo

### Métricas de Negócio
- Requisições por endpoint específico
- Tempo de resposta por operação
- Taxa de sucesso/erro

## 🔍 Troubleshooting

### Problemas Comuns

1. **Aplicação não expõe métricas**:
   ```bash
   # Verificar endpoint
   curl http://localhost:8080/actuator/prometheus
   
   # Verificar logs
   tail -f logs/application.log
   ```

2. **Prometheus não coleta dados**:
   ```bash
   # Verificar targets
   http://localhost:9090/targets
   
   # Verificar logs
   docker-compose logs prometheus
   ```

3. **Grafana sem dados**:
   ```bash
   # Verificar datasource
   http://localhost:3000/datasources
   
   # Verificar logs
   docker-compose logs grafana
   ```

### Logs Úteis

```bash
# Aplicação
tail -f logs/application.log

# Prometheus
docker-compose logs prometheus

# Grafana
docker-compose logs grafana
```

## 📝 Checklist da Avaliação

### Funcionalidades ✅
- [x] Autenticação JWT
- [x] Endpoints REST (Livros, Editoras)
- [x] Documentação Swagger
- [x] Testes unitários
- [x] Testes de carga JMeter
- [x] Monitoramento Actuator
- [x] Prometheus configurado
- [x] Dashboards Grafana
- [x] Métricas de negócio

### Arquitetura ✅
- [x] Separação em camadas
- [x] Injeção de dependências
- [x] Tratamento de exceções
- [x] Validação de dados
- [x] Configuração externalizada

### Monitoramento ✅
- [x] Métricas de infraestrutura
- [x] Métricas de aplicação
- [x] Dashboards interativos
- [x] Alertas configuráveis
- [x] Histórico de métricas

## 🎯 Pontos de Destaque

### Para a Avaliação

1. **Observabilidade Completa**: Visibilidade total da aplicação
2. **Métricas de Negócio**: Não apenas infraestrutura
3. **Dashboards Interativos**: Visualização em tempo real
4. **Automação**: Scripts para facilitar demonstração
5. **Documentação**: Guias completos e detalhados

### Demonstração Eficaz

1. **Inicie com tráfego baixo** - Mostre dashboards vazios
2. **Execute o gerador de tráfego** - Veja métricas aumentando
3. **Execute teste JMeter** - Demonstre picos de carga
4. **Mostre alertas** - Configure thresholds
5. **Explique métricas** - Contextualize os dados

## 🏁 Conclusão

Com esta configuração, você tem:

- ✅ **Sistema completo de monitoramento**
- ✅ **Dashboards interativos funcionais**
- ✅ **Métricas de negócio específicas**
- ✅ **Scripts de automação**
- ✅ **Documentação completa**

**Próximo passo**: Execute em um ambiente funcional e demonstre os dashboards em tempo real!

---

**Dica**: Use o script `generate-traffic.ps1` durante a demonstração para gerar dados dinâmicos e impressionar com as métricas em tempo real! 🚀 