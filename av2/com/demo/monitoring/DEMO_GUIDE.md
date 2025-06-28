# Guia de Demonstração - Monitoramento com Grafana

Este guia mostra como demonstrar o monitoramento da aplicação Spring Boot durante a avaliação AV2.

## Pré-requisitos

1. Aplicação Spring Boot rodando
2. Prometheus e Grafana configurados
3. Dados de teste na aplicação

## Passo a Passo da Demonstração

### 1. Preparação Inicial

```bash
# 1. Iniciar a aplicação
cd provaMariaDB-main/prova/demo
mvn spring-boot:run

# 2. Em outro terminal, iniciar o monitoramento
cd monitoring
docker-compose up -d
# OU usar os scripts manuais:
# .\start-prometheus.bat
# .\start-grafana.bat
```

### 2. Gerar Dados de Teste

Execute os seguintes comandos para gerar tráfego na aplicação:

```bash
# Registrar usuário
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"teste","password":"123456","role":"USER"}'

# Fazer login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"teste","password":"123456"}'

# Extrair token do response e usar nas próximas requisições
TOKEN="seu_token_aqui"

# Criar editoras
curl -X POST http://localhost:8080/editoras \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"nome":"Editora Teste","endereco":"Rua Teste, 123"}'

# Listar editoras
curl -X GET http://localhost:8080/editoras \
  -H "Authorization: Bearer $TOKEN"

# Criar livros
curl -X POST http://localhost:8080/livros \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"titulo":"Livro Teste","autor":"Autor Teste","isbn":"1234567890","editoraId":1}'

# Listar livros
curl -X GET http://localhost:8080/livros \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Demonstração do Prometheus

1. **Acesse**: http://localhost:9090
2. **Mostre os targets**: Vá em Status > Targets
   - Deve mostrar "spring-boot-app" como UP
3. **Execute queries**:
   ```
   # Total de requisições HTTP
   http_server_requests_seconds_count
   
   # Tempo médio de resposta
   rate(http_server_requests_seconds_sum[5m]) / rate(http_server_requests_seconds_count[5m])
   
   # Uso de memória JVM
   jvm_memory_used_bytes
   
   # Conexões de banco ativas
   hikaricp_connections_active
   ```

### 4. Demonstração do Grafana

1. **Acesse**: http://localhost:3000 (admin/admin)
2. **Importe os dashboards**:
   - Vá em Dashboards > Import
   - Selecione `spring-boot-dashboard.json`
   - Selecione `business-metrics-dashboard.json`

3. **Demonstre os painéis**:

#### Dashboard Principal (Spring Boot Application)
- **HTTP Requests Total**: Mostra quantas requisições foram feitas para cada endpoint
- **HTTP Response Time**: Tempo médio de resposta por endpoint
- **JVM Memory Usage**: Uso de memória da aplicação
- **JVM Threads**: Número de threads ativas
- **Database Connections**: Conexões ativas com o banco
- **HTTP Status Codes**: Distribuição de códigos de status

#### Dashboard de Métricas de Negócio
- **Requisições por Endpoint**: Tabela com taxa de requisições
- **Tempo de Resposta por Endpoint**: Gráfico de performance
- **Códigos de Status HTTP**: Estatísticas de sucesso/erro
- **Requisições por Minuto**: Throughput da aplicação
- **Uso de CPU da JVM**: Monitoramento de recursos
- **Heap Memory Usage**: Uso de memória heap
- **Database Connection Pool**: Pool de conexões
- **Garbage Collection Time**: Tempo de GC

### 5. Teste de Carga com JMeter

1. **Execute o teste JMeter**:
   ```bash
   # Se tiver JMeter instalado
   jmeter -n -t jmeter-tests/TestesJm.jmx -l results.jtl
   ```

2. **Observe as métricas em tempo real**:
   - No Grafana, veja os gráficos atualizando
   - No Prometheus, execute queries para ver picos de tráfego

### 6. Demonstração de Alertas

Configure alertas no Grafana:

1. **Vá em Alerting > Alert Rules**
2. **Crie alertas para**:
   - Tempo de resposta > 1 segundo
   - Uso de memória > 80%
   - Erros HTTP 5xx > 5%
   - Conexões de banco > 80%

### 7. Pontos de Destaque para a Avaliação

#### Funcionalidades Implementadas ✅
- ✅ Autenticação JWT com Spring Security
- ✅ Endpoints REST para Livros e Editoras
- ✅ Documentação com Swagger/OpenAPI
- ✅ Testes unitários com JUnit/Mockito
- ✅ Testes de carga com JMeter
- ✅ Monitoramento com Actuator e Prometheus
- ✅ Dashboards interativos no Grafana
- ✅ Métricas de negócio específicas

#### Arquitetura e Boas Práticas ✅
- ✅ Separação em camadas (Controller, Service, Repository)
- ✅ Injeção de dependências
- ✅ Tratamento de exceções
- ✅ Validação de dados
- ✅ Configuração externalizada
- ✅ Logs estruturados

#### Monitoramento e Observabilidade ✅
- ✅ Métricas de infraestrutura (CPU, memória, threads)
- ✅ Métricas de aplicação (HTTP, banco de dados)
- ✅ Dashboards em tempo real
- ✅ Alertas configuráveis
- ✅ Histórico de métricas

### 8. Scripts de Demonstração

Crie scripts para automatizar a demonstração:

```bash
# demo-monitoring.sh
#!/bin/bash
echo "=== Demonstração do Monitoramento ==="

echo "1. Gerando tráfego na aplicação..."
# Execute os comandos curl aqui

echo "2. Aguardando coleta de métricas..."
sleep 30

echo "3. Abrindo interfaces..."
start http://localhost:9090  # Prometheus
start http://localhost:3000  # Grafana

echo "Demonstração pronta!"
```

### 9. Checklist da Avaliação

- [ ] Aplicação Spring Boot funcionando
- [ ] Autenticação JWT implementada
- [ ] Endpoints REST documentados
- [ ] Testes unitários executando
- [ ] Testes de carga com JMeter
- [ ] Prometheus coletando métricas
- [ ] Grafana com dashboards funcionando
- [ ] Métricas de negócio visíveis
- [ ] Alertas configurados
- [ ] Documentação completa

## Troubleshooting

### Problemas Comuns

1. **Prometheus não coleta dados**:
   - Verifique se a aplicação está rodando
   - Confirme o endpoint `/actuator/prometheus`
   - Verifique logs do Prometheus

2. **Grafana sem dados**:
   - Configure o datasource Prometheus
   - Verifique se o Prometheus está acessível
   - Importe os dashboards corretamente

3. **Aplicação não expõe métricas**:
   - Verifique dependências no `pom.xml`
   - Confirme configuração no `application.yml`
   - Reinicie a aplicação

### Logs Úteis

```bash
# Logs da aplicação
tail -f logs/application.log

# Logs do Prometheus
docker-compose logs prometheus

# Logs do Grafana
docker-compose logs grafana
```

## Conclusão

Com esta configuração, você tem um sistema completo de monitoramento que demonstra:

1. **Observabilidade**: Visibilidade completa da aplicação
2. **Performance**: Métricas de tempo de resposta e throughput
3. **Recursos**: Monitoramento de CPU, memória e threads
4. **Negócio**: Métricas específicas da aplicação
5. **Alertas**: Capacidade de detectar problemas proativamente

Isso atende completamente aos requisitos da avaliação AV2 e demonstra conhecimento avançado em monitoramento e observabilidade. 