# Script de Setup do Monitoramento - Windows PowerShell
# Este script ajuda a configurar Prometheus e Grafana sem Docker

Write-Host "=== Setup do Monitoramento - Spring Boot Application ===" -ForegroundColor Green
Write-Host ""

# Verificar se a aplicação está rodando
Write-Host "1. Verificando se a aplicação Spring Boot está rodando..." -ForegroundColor Yellow
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

Write-Host ""
Write-Host "2. Configurando Prometheus..." -ForegroundColor Yellow

# Criar diretório para Prometheus
$prometheusDir = ".\prometheus-standalone"
if (!(Test-Path $prometheusDir)) {
    New-Item -ItemType Directory -Path $prometheusDir
}

# Download do Prometheus (Windows)
$prometheusUrl = "https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.windows-amd64.zip"
$prometheusZip = "$prometheusDir\prometheus.zip"

Write-Host "Baixando Prometheus..."
Invoke-WebRequest -Uri $prometheusUrl -OutFile $prometheusZip

Write-Host "Extraindo Prometheus..."
Expand-Archive -Path $prometheusZip -DestinationPath $prometheusDir -Force
Remove-Item $prometheusZip

# Copiar configuração
Copy-Item ".\prometheus.yml" "$prometheusDir\prometheus-2.48.0.windows-amd64\"

Write-Host "✓ Prometheus configurado" -ForegroundColor Green

Write-Host ""
Write-Host "3. Configurando Grafana..." -ForegroundColor Yellow

# Criar diretório para Grafana
$grafanaDir = ".\grafana-standalone"
if (!(Test-Path $grafanaDir)) {
    New-Item -ItemType Directory -Path $grafanaDir
}

# Download do Grafana (Windows)
$grafanaUrl = "https://dl.grafana.com/oss/release/grafana-10.2.0.windows-amd64.zip"
$grafanaZip = "$grafanaDir\grafana.zip"

Write-Host "Baixando Grafana..."
Invoke-WebRequest -Uri $grafanaUrl -OutFile $grafanaZip

Write-Host "Extraindo Grafana..."
Expand-Archive -Path $grafanaZip -DestinationPath $grafanaDir -Force
Remove-Item $grafanaZip

# Copiar configurações do Grafana
$grafanaConfigDir = "$grafanaDir\grafana-10.2.0\conf"
Copy-Item ".\grafana\provisioning" "$grafanaConfigDir\" -Recurse -Force

Write-Host "✓ Grafana configurado" -ForegroundColor Green

Write-Host ""
Write-Host "4. Criando scripts de inicialização..." -ForegroundColor Yellow

# Script para iniciar Prometheus
$prometheusScript = @"
@echo off
cd /d "%~dp0prometheus-standalone\prometheus-2.48.0.windows-amd64"
echo Iniciando Prometheus...
prometheus.exe --config.file=prometheus.yml
"@
$prometheusScript | Out-File -FilePath ".\start-prometheus.bat" -Encoding ASCII

# Script para iniciar Grafana
$grafanaScript = @"
@echo off
cd /d "%~dp0grafana-standalone\grafana-10.2.0\bin"
echo Iniciando Grafana...
grafana-server.exe
"@
$grafanaScript | Out-File -FilePath ".\start-grafana.bat" -Encoding ASCII

Write-Host "✓ Scripts criados" -ForegroundColor Green

Write-Host ""
Write-Host "=== Setup Concluído! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Para iniciar o monitoramento:" -ForegroundColor Yellow
Write-Host "1. Execute: .\start-prometheus.bat" -ForegroundColor White
Write-Host "2. Execute: .\start-grafana.bat" -ForegroundColor White
Write-Host "3. Acesse Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "4. Acesse Grafana: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host ""
Write-Host "Para importar o dashboard no Grafana:" -ForegroundColor Yellow
Write-Host "1. Acesse Grafana" -ForegroundColor White
Write-Host "2. Vá em Dashboards > Import" -ForegroundColor White
Write-Host "3. Selecione o arquivo: .\grafana\dashboards\spring-boot-dashboard.json" -ForegroundColor White
Write-Host "" 