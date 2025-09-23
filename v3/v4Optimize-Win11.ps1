<# 
    Script: Otimização Hardcore Ultra - Windows (V3 Gamer Edition)
    Autor:  SULPICIO (modificado)
    Versão: 3.2 (Gamer Hardcore: inclui tweaks de jogos + V3 base)
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
|         Suíte de Otimização v4.0 (Gamer Edition)      |
|                                                       |
\-------------------------------------------------------/
"@ -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}

# ========================
# Logs
# ========================
$logPath = "$PSScriptRoot\Optimizacao_SULPICIO_Gamer.log"
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
    try {
        Get-Process -Name $p -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host " - $p finalizado" -ForegroundColor DarkGray
    } catch {}
}

# ========================
# Serviços
# ========================
Write-Host "[+] Desativando serviços desnecessários (onde permitido)..." -ForegroundColor Yellow
$services = "DiagTrack","SysMain","WSearch","XblGameSave","MapsBroker","Fax","RemoteRegistry","RetailDemo","PrintSpooler"
foreach ($svc in $services) {
    try {
        Stop-Service -Name $svc -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host " - $svc desativado" -ForegroundColor DarkGray
    } catch {
        Write-Host " - $svc : não foi possível alterar (protegido/permissão)" -ForegroundColor DarkYellow
    }
}

# ========================
# Inicialização automática
# ========================
Write-Host "[+] Limpando inicialização automática..." -ForegroundColor Yellow
try {
    Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_.Name -ErrorAction SilentlyContinue
            Write-Host " - Removido: $($_.Name)" -ForegroundColor DarkGray
        } catch {}
    }
} catch {}

# ========================
# Registro básico
# ========================
Write-Host "[+] Aplicando tweaks no registro..." -ForegroundColor Yellow
$regTweaks = @{
    "HKCU\Control Panel\Desktop" = @{
        "MenuShowDelay"          = "0"
        "AutoEndTasks"           = "1"
        "HungAppTimeout"         = "1000"
        "WaitToKillAppTimeout"   = "1000"
    }
    "HKLM\SYSTEM\CurrentControlSet\Control" = @{
        "WaitToKillServiceTimeout" = "1000"
    }
    "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" = @{
        "LargeSystemCache"         = 1
        "DisablePagingExecutive"   = 1
    }
}
foreach ($path in $regTweaks.Keys) {
    foreach ($name in $regTweaks[$path].Keys) {
        $value = $regTweaks[$path][$name]
        try {
            if ($value -is [int]) {
                reg add $path /v $name /t REG_DWORD /d $value /f | Out-Null
            } else {
                reg add $path /v $name /t REG_SZ /d $value /f | Out-Null
            }
            Write-Host " - $path → $name = $value" -ForegroundColor DarkGray
        } catch {}
    }
}

# ========================
# Telemetria OFF
# ========================
Write-Host "[+] Aplicando configurações de telemetria..." -ForegroundColor Yellow
try {
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f | Out-Null
    Write-Host " - Chaves de telemetria aplicadas" -ForegroundColor DarkGray
} catch {}

# ========================
# Nota Defender
# ========================
Write-Host "[i] Nota: Windows Defender preservado nesta versão (não é parado à força)." -ForegroundColor Cyan

# ========================
# Indexação OFF
# ========================
Write-Host "[+] Desativando indexação de arquivos (WSearch)..." -ForegroundColor Yellow
try {
    Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
    Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host " - WSearch tratado" -ForegroundColor DarkGray
} catch {}

# ========================
# Tweaks TCP/IP
# ========================
Write-Host "[+] Aplicando ajustes de rede para baixa latência..." -ForegroundColor Yellow
try {
    netsh int tcp set global autotuninglevel=disabled | Out-Null
    netsh int tcp set global rss=enabled | Out-Null
    Write-Host " - Ajustes TCP aplicados" -ForegroundColor DarkGray
} catch {}

# ========================
# GPU máximo desempenho
# ========================
Write-Host "[+] Forçando GPU em máximo desempenho..." -ForegroundColor Yellow
try {
    reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "SystemDefault" /t REG_SZ /d "GpuPreference=2;" /f | Out-Null
    Write-Host " - Preferência GPU aplicada" -ForegroundColor DarkGray
} catch {}

# ========================
# Desativar tarefas agendadas Microsoft
# ========================
Write-Host "[+] Desabilitando tarefas agendadas pesadas..." -ForegroundColor Yellow
try {
    Get-ScheduledTask | Where-Object { $_.TaskPath -like "\Microsoft\Windows\*" -and $_.State -eq "Ready" } | ForEach-Object {
        try { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host " - Tarefas agendadas processadas" -ForegroundColor DarkGray
} catch {}

# ========================
# Energia
# ========================
Write-Host "[+] Ativando plano de energia Ultimate Performance..." -ForegroundColor Yellow
try {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    Write-Host " - Plano de energia Ultimate Performance ativado" -ForegroundColor DarkGray
} catch {}

# ========================
# Gamer Tweaks Extras
# ========================
Write-Host "[+] Aplicando otimizações específicas para jogos..." -ForegroundColor Yellow

# GameDVR / GameBar OFF
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f | Out-Null
reg add "HKCU\Software\Microsoft\GameBar" /v AllowAutoGameMode /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f | Out-Null
Write-Host " - GameDVR/GameBar desativados" -ForegroundColor DarkGray

# Efeitos visuais OFF
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f | Out-Null
Write-Host " - Efeitos visuais ajustados para desempenho" -ForegroundColor DarkGray

# Hibernar OFF
powercfg -h off
Write-Host " - Hibernação desativada" -ForegroundColor DarkGray

# Prefetch/Superfetch OFF
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f | Out-Null
Write-Host " - Prefetch/Superfetch desativados" -ForegroundColor DarkGray

# Notificações OFF
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f | Out-Null
Write-Host " - Notificações/sugestões desativadas" -ForegroundColor DarkGray

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
Write-Host "`n[✓] Otimização Ultra Gamer concluída!" -ForegroundColor Green
Write-Host "[✓] Log salvo em: $logPath" -ForegroundColor Green
try { Stop-Transcript | Out-Null } catch {}
Pause
