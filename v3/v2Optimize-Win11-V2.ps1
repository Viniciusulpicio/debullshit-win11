<# 
    Script: Otimização Hardcore Ultra - Windows (V3 - Defender preservado)
    Autor:  SULPICIO (modificado)
    Versão: 3.1 (Corrigido: remove tentativas de parar WinDefend + netsh compatível)
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
|               Suíte de Otimização v4.0 (V3)           |
|                                                       |
\-------------------------------------------------------/
"@ -ForegroundColor Cyan
    Start-Sleep -Seconds 1
}

# ========================
# Logs
# ========================
$logPath = "$PSScriptRoot\Optimizacao_SULPICIO_Ultra_v3.log"
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
$services = "DiagTrack","SysMain","WSearch","XblGameSave","MapsBroker","Fax","RemoteRegistry","RetailDemo"
foreach ($svc in $services) {
    try {
        Stop-Service -Name $svc -ErrorAction SilentlyContinue
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host " - $svc desativado" -ForegroundColor DarkGray
    } catch {
        Write-Host " - $svc : não foi possível alterar (permissão/serviço protegido)" -ForegroundColor DarkYellow
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
            # usa reg add para manter compatibilidade
            if ($value -is [int]) {
                reg add $path /v $name /t REG_DWORD /d $value /f | Out-Null
            } else {
                reg add $path /v $name /t REG_SZ /d $value /f | Out-Null
            }
            Write-Host " - $path → $name = $value" -ForegroundColor DarkGray
        } catch {
            Write-Host " - Falha ao aplicar $name em $path" -ForegroundColor DarkYellow
        }
    }
}

# ========================
# Telemetria OFF (políticas, pode exigir reboot)
# ========================
Write-Host "[+] Aplicando configurações de telemetria (políticas)..." -ForegroundColor Yellow
try {
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f | Out-Null
    Write-Host " - Chaves de telemetria aplicadas (pode exigir reinício)" -ForegroundColor DarkGray
} catch {
    Write-Host " - Não foi possível aplicar alguma chave de telemetria" -ForegroundColor DarkYellow
}

# ========================
# NOTA: preservando Windows Defender (não tentamos parar/disable via service)
# ========================
Write-Host "[i] Nota: Windows Defender preservado nesta versão do script para evitar bloqueios e perda de proteção." -ForegroundColor Cyan

# ========================
# Indexação OFF (WSearch)
# ========================
Write-Host "[+] Desativando indexação de arquivos (WSearch)..." -ForegroundColor Yellow
try {
    Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
    Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host " - WSearch tratado" -ForegroundColor DarkGray
} catch {}

# ========================
# Tweaks TCP/IP (compatível)
# ========================
Write-Host "[+] Aplicando ajustes de rede para baixa latência..." -ForegroundColor Yellow
try {
    netsh int tcp set global autotuninglevel=disabled | Out-Null
    netsh int tcp set global rss=enabled | Out-Null
    # comando 'chimney' removido (obsoleto)
    Write-Host " - Ajustes TCP aplicados (autotune=disabled, rss=enabled)" -ForegroundColor DarkGray
} catch {
    Write-Host " - Falha ao aplicar ajustes TCP (permissão/versão do SO)" -ForegroundColor DarkYellow
}

# ========================
# GPU máximo desempenho
# ========================
Write-Host "[+] Forçando GPU em máximo desempenho (preferências do usuário)..." -ForegroundColor Yellow
try {
    reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "SystemDefault" /t REG_SZ /d "GpuPreference=2;" /f | Out-Null
    Write-Host " - Preferência GPU aplicada" -ForegroundColor DarkGray
} catch {}

# ========================
# Desativar tarefas agendadas Microsoft (onde possível)
# ========================
Write-Host "[+] Desabilitando tarefas agendadas pesadas..." -ForegroundColor Yellow
try {
    Get-ScheduledTask | Where-Object { $_.TaskPath -like "\Microsoft\Windows\*" -and $_.State -eq "Ready" } | ForEach-Object {
        try { Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue } catch {}
    }
    Write-Host " - Tarefas agendadas processadas" -ForegroundColor DarkGray
} catch {
    Write-Host " - Falha ao listar/desabilitar algumas tarefas agendadas" -ForegroundColor DarkYellow
}

# ========================
# Energia
# ========================
Write-Host "[+] Ativando plano de energia máximo desempenho..." -ForegroundColor Yellow
try {
    powercfg -setactive SCHEME_MIN | Out-Null
    Write-Host " - Plano de energia definido" -ForegroundColor DarkGray
} catch {}

# ========================
# Limpeza de TEMP
# ========================
Write-Host "[+] Limpando arquivos temporários..." -ForegroundColor Yellow
try {
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host " - Pastas TEMP limpas" -ForegroundColor DarkGray
} catch {
    Write-Host " - Falha ao limpar alguma pasta TEMP" -ForegroundColor DarkYellow
}

# ========================
# Fim
# ========================
Write-Host "`n[✓] Otimização Ultra (V3) concluída!" -ForegroundColor Green
Write-Host "[✓] Log salvo em: $logPath" -ForegroundColor Green
try { Stop-Transcript | Out-Null } catch {}
Pause
