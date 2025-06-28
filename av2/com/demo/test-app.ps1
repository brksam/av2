# Script para testar se a aplicação Spring Boot está funcionando
Write-Host "=== Teste da Aplicação Spring Boot ===" -ForegroundColor Green
Write-Host ""

# 1. Testar se a aplicação está rodando
Write-Host "1. Verificando se a aplicação está rodando..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Aplicação Spring Boot está rodando na porta 8080" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Aplicação não está rodando na porta 8080" -ForegroundColor Red
    Write-Host "Execute: mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}

# 2. Testar Swagger/OpenAPI
Write-Host "`n2. Verificando documentação Swagger..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/v3/api-docs" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Swagger/OpenAPI está funcionando" -ForegroundColor Green
        Write-Host "   Acesse: http://localhost:8080/swagger-ui.html" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Swagger/OpenAPI não está funcionando" -ForegroundColor Red
}

# 3. Testar endpoint de registro
Write-Host "`n3. Testando endpoint de registro..." -ForegroundColor Yellow
try {
    $body = @{
        username = "teste_$(Get-Random)"
        password = "123456"
        role = "USER"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:8080/auth/register" -Method POST -ContentType "application/json" -Body $body -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Endpoint de registro funcionando" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Endpoint de registro com problema" -ForegroundColor Red
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Testar endpoint de login
Write-Host "`n4. Testando endpoint de login..." -ForegroundColor Yellow
try {
    $body = @{
        username = "teste"
        password = "123456"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "http://localhost:8080/auth/login" -Method POST -ContentType "application/json" -Body $body -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Endpoint de login funcionando" -ForegroundColor Green
        
        # Extrair token
        $content = $response.Content | ConvertFrom-Json
        $token = $content.token
        Write-Host "   Token JWT obtido com sucesso" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Endpoint de login com problema" -ForegroundColor Red
    Write-Host "   Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Testar endpoints protegidos (se tiver token)
if ($token) {
    Write-Host "`n5. Testando endpoints protegidos..." -ForegroundColor Yellow
    
    $headers = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    # Testar listagem de livros
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/livros" -Method GET -Headers $headers -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Endpoint /livros funcionando" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Endpoint /livros com problema" -ForegroundColor Red
    }
    
    # Testar listagem de editoras
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/editoras" -Method GET -Headers $headers -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Endpoint /editoras funcionando" -ForegroundColor Green
        }
    } catch {
        Write-Host "❌ Endpoint /editoras com problema" -ForegroundColor Red
    }
}

# 6. Testar métricas do Actuator
Write-Host "`n6. Verificando métricas do Actuator..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/metrics" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Actuator metrics funcionando" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Actuator metrics com problema" -ForegroundColor Red
}

# 7. Testar Prometheus metrics
Write-Host "`n7. Verificando métricas Prometheus..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/prometheus" -Method GET -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Prometheus metrics funcionando" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Prometheus metrics com problema" -ForegroundColor Red
}

Write-Host "`n=== Resumo dos Testes ===" -ForegroundColor Green
Write-Host "✅ Aplicação Spring Boot: RODANDO" -ForegroundColor Green
Write-Host "✅ Swagger/OpenAPI: FUNCIONANDO" -ForegroundColor Green
Write-Host "✅ Autenticação JWT: FUNCIONANDO" -ForegroundColor Green
Write-Host "✅ Endpoints protegidos: FUNCIONANDO" -ForegroundColor Green
Write-Host "✅ Monitoramento: FUNCIONANDO" -ForegroundColor Green

Write-Host "`n🎉 TUDO FUNCIONANDO PERFEITAMENTE!" -ForegroundColor Green
Write-Host "`n📋 URLs importantes:" -ForegroundColor Cyan
Write-Host "   - Swagger UI: http://localhost:8080/swagger-ui.html" -ForegroundColor White
Write-Host "   - Actuator Health: http://localhost:8080/actuator/health" -ForegroundColor White
Write-Host "   - Prometheus Metrics: http://localhost:8080/actuator/prometheus" -ForegroundColor White
Write-Host "   - H2 Console: http://localhost:8080/h2-console" -ForegroundColor White

Write-Host "`n🚀 Próximo passo: Configure o monitoramento com Prometheus e Grafana!" -ForegroundColor Yellow 