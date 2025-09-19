<# 
    Script: Otimização Hardcore Ultra - Windows 
    Autor:  SULPICIO
    Versão: 3.0 (Estendida com Logs + Hardcore)
#>

# ========================
# Banner
# ========================
function Start-OptimizationSession {
    Write-Host @"
/-------------------------------------------------------\
|                                                       |
|   ███████╗██╗   ██╗██╗     ██████╗ ██╗ ██████╗██╗ ██████╗  |
|   ██╔════╝██║   ██║██║     ██╔══██╗██║██╔════╝██║██╔═══██╗ |
|   ███████║██║   ██║██║     ██████╔╝██║██║     ██║██║   ██║ |
|   ╚════██║██║   ██║██║     ██╔═══╝ ██║██║     ██║██║   ██║ |
|   ███████║╚██████╔╝███████╗██║     ██║╚██████╗██║╚██████╔╝ |
|   ╚══════╝ ╚═════╝ ╚══════╝╚═╝     ╚═╝ ╚═════╝╚═╝ ╚═════╝  |
|                                                       |
|               Suíte de Otimização v4.0                |
|                                                       |
\-------------------------------------------------------/
"@ -ForegroundColor Cyan
    Start-Sleep -Seconds 2
}

# ========================
# Logs
# ========================
$logPath = "$PSScriptRoot\Optimizacao_SULPICIO_Ultra.log"
Start-Transcript -Path $logPath -Append -Force | Out-Null
Write-Host "[+] Log iniciado em: $logPath" -ForegroundColor Green

# ========================
# Banner
# ========================
Start-OptimizationSession

# ========================
# Finalizar Processos Pesados
# ========================
Write-Host "[+] Finalizando processos inúteis..." -ForegroundColor Yellow
$processes = "OneDrive","Teams","Widgets","Cortana","Skype","YourPhone"
foreach ($p in $processes) {
    try { Get-Process $p -ErrorAction SilentlyContinue | Stop-Process -Force; Write-Host " - $p finalizado" -ForegroundColor DarkGray } catch {}
}

# ========================
# Serviços
# ========================
Write-Host "[+] Desativando serviços desnecessários..." -ForegroundColor Yellow
$services = "DiagTrack","SysMain","WSearch","XblGameSave","MapsBroker","Fax","RemoteRegistry","RetailDemo"
foreach ($svc in $services) {
    try {
        Stop-Service $svc -ErrorAction SilentlyContinue
        Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host " - $svc desativado" -ForegroundColor DarkGray
    } catch {}
}

# ========================
# Inicialização automática
# ========================
Write-Host "[+] Limpando inicialização automática..." -ForegroundColor Yellow
Get-CimInstance Win32_StartupCommand | ForEach-Object {
    try { Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_.Name -ErrorAction SilentlyContinue; Write-Host " - Removido: $($_.Name)" -ForegroundColor DarkGray } catch {}
}

# ========================
# Registro básico
# ========================
Write-Host "[+] Aplicando tweaks no registro..." -ForegroundColor Yellow
$regTweaks = @{
    "HKCU\Control Panel\Desktop" = @{
        "MenuShowDelay"      = "0"
        "AutoEndTasks"       = "1"
        "HungAppTimeout"     = "1000"
        "WaitToKillAppTimeout" = "1000"
    }
    "HKLM\SYSTEM\CurrentControlSet\Control" = @{
        "WaitToKillServiceTimeout" = "1000"
    }
    "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" = @{
        "LargeSystemCache"     = 1
        "DisablePagingExecutive" = 1
    }
}
foreach ($path in $regTweaks.Keys) {
    foreach ($name in $regTweaks[$path].Keys) {
        $value = $regTweaks[$path][$name]
        reg add $path /v $name /t REG_SZ /d $value /f | Out-Null
        Write-Host " - $path → $name = $value" -ForegroundColor DarkGray
    }
}

# ========================
# Telemetria OFF
# ========================
Write-Host "[+] Desativando telemetria..." -ForegroundColor Yellow
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

# ========================
# Defender OFF (Hardcore)
# ========================
Write-Host "[+] Desativando Windows Defender..." -ForegroundColor Yellow
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f
Stop-Service WinDefend -Force
Set-Service WinDefend -StartupType Disabled

# ========================
# Indexação OFF
# ========================
Write-Host "[+] Desativando indexação de arquivos (WSearch)..." -ForegroundColor Yellow
Stop-Service WSearch -Force
Set-Service WSearch -StartupType Disabled

# ========================
# Tweaks TCP/IP
# ========================
Write-Host "[+] Aplicando ajustes de rede para baixa latência..." -ForegroundColor Yellow
netsh int tcp set global autotuninglevel=disabled
netsh int tcp set global rss=enabled
netsh int tcp set global chimney=enabled
netsh int tcp set global dca=enabled

# ========================
# GPU máximo desempenho
# ========================
Write-Host "[+] Forçando GPU em máximo desempenho..." -ForegroundColor Yellow
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "SystemDefault" /t REG_SZ /d "GpuPreference=2;" /f

# ========================
# Desativar tarefas agendadas Microsoft
# ========================
Write-Host "[+] Desabilitando tarefas agendadas pesadas..." -ForegroundColor Yellow
Get-ScheduledTask | Where-Object {$_.TaskPath -like "\Microsoft\Windows\*" -and $_.State -eq "Ready"} | Disable-ScheduledTask -ErrorAction SilentlyContinue

# ========================
# Energia
# ========================
Write-Host "[+] Ativando plano de energia máximo desempenho..." -ForegroundColor Yellow
powercfg -setactive SCHEME_MIN

# ========================
# Limpeza de TEMP
# ========================
Write-Host "[+] Limpando arquivos temporários..." -ForegroundColor Yellow
try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " - Pastas TEMP limpas" -ForegroundColor DarkGray
} catch {}

# ========================
# Fim
# ========================
Write-Host "`n[✓] Otimização Ultra concluída!" -ForegroundColor Green
Write-Host "[✓] Log salvo em: $logPath" -ForegroundColor Green
try { Stop-Transcript | Out-Null } catch {}
Pause
