# Script para Gerar Tráfego na Aplicação - Demonstração do Monitoramento
# Este script gera tráfego contínuo para demonstrar as métricas no Grafana

param(
    [int]$Duration = 300,  # Duração em segundos (padrão: 5 minutos)
    [int]$Interval = 2     # Intervalo entre requisições em segundos
)

Write-Host "=== Gerador de Tráfego para Demonstração ===" -ForegroundColor Green
Write-Host "Duração: $Duration segundos" -ForegroundColor Yellow
Write-Host "Intervalo: $Interval segundos" -ForegroundColor Yellow
Write-Host ""

# Verificar se a aplicação está rodando
Write-Host "Verificando se a aplicação está rodando..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Aplicação Spring Boot está rodando" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Aplicação Spring Boot não está rodando na porta 8080" -ForegroundColor Red
    Write-Host "Execute: mvn spring-boot:run" -ForegroundColor Yellow
    exit 1
}

# Registrar usuário de teste
Write-Host "Registrando usuário de teste..." -ForegroundColor Yellow
try {
    $registerBody = @{
        username = "demo_user"
        password = "demo123"
        role = "USER"
    } | ConvertTo-Json

    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8080/auth/register" `
        -Method POST `
        -ContentType "application/json" `
        -Body $registerBody

    Write-Host "✓ Usuário registrado com sucesso" -ForegroundColor Green
} catch {
    Write-Host "! Usuário já existe ou erro no registro" -ForegroundColor Yellow
}

# Fazer login e obter token
Write-Host "Fazendo login..." -ForegroundColor Yellow
try {
    $loginBody = @{
        username = "demo_user"
        password = "demo123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/auth/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body $loginBody

    $token = $loginResponse.token
    Write-Host "✓ Login realizado com sucesso" -ForegroundColor Green
} catch {
    Write-Host "✗ Erro no login" -ForegroundColor Red
    exit 1
}

# Headers para requisições autenticadas
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

# Criar dados de teste
Write-Host "Criando dados de teste..." -ForegroundColor Yellow

# Criar editoras
$editoras = @(
    @{ nome = "Editora A"; endereco = "Rua A, 123" },
    @{ nome = "Editora B"; endereco = "Rua B, 456" },
    @{ nome = "Editora C"; endereco = "Rua C, 789" }
)

$editoraIds = @()
foreach ($editora in $editoras) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/editoras" `
            -Method POST `
            -Headers $headers `
            -Body ($editora | ConvertTo-Json)
        $editoraIds += $response.id
        Write-Host "✓ Editora criada: $($editora.nome)" -ForegroundColor Green
    } catch {
        Write-Host "! Erro ao criar editora: $($editora.nome)" -ForegroundColor Yellow
    }
}

# Criar livros
$livros = @(
    @{ titulo = "Livro 1"; autor = "Autor 1"; isbn = "1234567890" },
    @{ titulo = "Livro 2"; autor = "Autor 2"; isbn = "1234567891" },
    @{ titulo = "Livro 3"; autor = "Autor 3"; isbn = "1234567892" },
    @{ titulo = "Livro 4"; autor = "Autor 4"; isbn = "1234567893" },
    @{ titulo = "Livro 5"; autor = "Autor 5"; isbn = "1234567894" }
)

$livroIds = @()
foreach ($livro in $livros) {
    try {
        $livroData = $livro.Clone()
        $livroData.editoraId = $editoraIds[0]  # Usar primeira editora
        $response = Invoke-RestMethod -Uri "http://localhost:8080/livros" `
            -Method POST `
            -Headers $headers `
            -Body ($livroData | ConvertTo-Json)
        $livroIds += $response.id
        Write-Host "✓ Livro criado: $($livro.titulo)" -ForegroundColor Green
    } catch {
        Write-Host "! Erro ao criar livro: $($livro.titulo)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Iniciando Geração de Tráfego ===" -ForegroundColor Green
Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
Write-Host ""

$startTime = Get-Date
$requestCount = 0
$endpoints = @(
    @{ method = "GET"; uri = "/livros" },
    @{ method = "GET"; uri = "/editoras" },
    @{ method = "GET"; uri = "/actuator/health" },
    @{ method = "GET"; uri = "/actuator/metrics" },
    @{ method = "GET"; uri = "/v3/api-docs" }
)

# Loop principal de geração de tráfego
while ((Get-Date) -lt $startTime.AddSeconds($Duration)) {
    $requestCount++
    $currentTime = Get-Date -Format "HH:mm:ss"
    
    # Selecionar endpoint aleatório
    $endpoint = $endpoints | Get-Random
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080$($endpoint.uri)" `
            -Method $endpoint.method `
            -Headers $headers `
            -TimeoutSec 5
        
        Write-Host "[$currentTime] ✓ $($endpoint.method) $($endpoint.uri) - 200 OK" -ForegroundColor Green
    } catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "[$currentTime] ✗ $($endpoint.method) $($endpoint.uri) - $statusCode" -ForegroundColor Red
    }
    
    # Operações ocasionais de POST/PUT/DELETE
    if ($requestCount % 10 -eq 0) {
        # Criar novo livro ocasionalmente
        try {
            $novoLivro = @{
                titulo = "Livro Gerado $requestCount"
                autor = "Autor Gerado"
                isbn = "GEN$requestCount"
                editoraId = $editoraIds[0]
            }
            
            $response = Invoke-RestMethod -Uri "http://localhost:8080/livros" `
                -Method POST `
                -Headers $headers `
                -Body ($novoLivro | ConvertTo-Json)
            
            Write-Host "[$currentTime] ✓ POST /livros - Livro criado" -ForegroundColor Cyan
        } catch {
            Write-Host "[$currentTime] ✗ POST /livros - Erro" -ForegroundColor Red
        }
    }
    
    if ($requestCount % 15 -eq 0) {
        # Criar nova editora ocasionalmente
        try {
            $novaEditora = @{
                nome = "Editora Gerada $requestCount"
                endereco = "Endereço Gerado $requestCount"
            }
            
            $response = Invoke-RestMethod -Uri "http://localhost:8080/editoras" `
                -Method POST `
                -Headers $headers `
                -Body ($novaEditora | ConvertTo-Json)
            
            Write-Host "[$currentTime] ✓ POST /editoras - Editora criada" -ForegroundColor Cyan
        } catch {
            Write-Host "[$currentTime] ✗ POST /editoras - Erro" -ForegroundColor Red
        }
    }
    
    Start-Sleep -Seconds $Interval
}

Write-Host ""
Write-Host "=== Geração de Tráfego Concluída ===" -ForegroundColor Green
Write-Host "Total de requisições: $requestCount" -ForegroundColor Yellow
Write-Host "Duração: $Duration segundos" -ForegroundColor Yellow
Write-Host ""
Write-Host "Agora você pode visualizar as métricas em:" -ForegroundColor Cyan
Write-Host "- Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "- Grafana: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Dica: Execute este script enquanto demonstra os dashboards!" -ForegroundColor Yellow 