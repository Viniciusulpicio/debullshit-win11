<#
.SYNOPSIS
  Otimiza o Windows 11 para performance máxima, removendo bloatware e desativando telemetria de forma interativa.

.DESCRIPTION
  Este script PowerShell é uma suíte de otimização agressiva para o Windows 11.
  Ele permite ao usuário escolher quais otimizações aplicar, incluindo remoção de bloatware, desativação de telemetria,
  ajustes de plano de energia e configurações de registro para máxima resposta do sistema.
  
  Melhorias da v2.1:
  - Comentários explicativos do script original foram restaurados para melhor entendimento.
  - Execução como Administrador é verificada e exigida.
  - Menu interativo que permite aplicar todas as otimizações ou escolher categorias específicas.
  - Perguntas de confirmação para ações mais drásticas (Remover OneDrive, Desativar SmartScreen).
  - Criação de um log (transcript) de todas as operações em sua Área de Trabalho.
  - Função para gerar um script de reversão (`Reverter-Otimizacoes.ps1`) na Área de Trabalho.

.NOTES
  Autor: Vinicius Sulpicio
  Versão: 2.1
  Data: 18/09/2025
  Inspirado nas filosofias de otimização da comunidade de power users.
#>

# =================================================================================
# SUÍTE DE OTIMIZAÇÃO V2.1 - INTERATIVA, COMENTADA E COM LOGS
# Risco de instabilidade existe. USE O PONTO DE RESTAURAÇÃO SE NECESSÁRIO.
# =================================================================================

# --- MELHORIA 1: VERIFICAÇÃO DE PRIVILÉGIOS DE ADMINISTRADOR ---
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Este script precisa ser executado como Administrador."
    Write-Host "Clique com o botão direito no script e selecione 'Executar como Administrador'."
    Start-Sleep -Seconds 10
    Exit
}

# --- FUNÇÕES DE OTIMIZAÇÃO MODULARIZADAS E COMENTADAS ---

function Start-OptimizationSession {
    # Exibe o banner de boas-vindas
    Write-Host @"
/-------------------------------------------------------\
|                                                       |
|   ██████╗  ██████╗ ██╗   ██╗███████╗████████╗███████╗   |
|   ██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝   |
|   ██████╔╝██║   ██║ ╚████╔╝ ███████╗   ██║   ███████╗   |
|   ██╔═══╝ ██║   ██║  ╚██╔╝  ╚════██║   ██║   ╚════██║   |
|   ██║     ╚██████╔╝   ██║   ███████║   ██║   ███████║   |
|   ╚═╝      ╚═════╝    ╚═╝   ╚══════╝   ╚═╝   ╚══════╝   |
|                                                       |
|       Suíte de Otimização v2.1 - Comentada e Interativa       |
|                                                       |
\-------------------------------------------------------/
"@ -ForegroundColor Cyan
    Start-Sleep -Seconds 2

    # --- MELHORIA 3: INICIAR LOG (TRANSCRIPT) ---
    $LogPath = "$env:USERPROFILE\Desktop\Log-Otimizacao-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
    try {
        Start-Transcript -Path $LogPath
        Write-Host "Logging iniciado. Um log detalhado será salvo em: $LogPath" -ForegroundColor Green
    } catch {
        Write-Warning "Não foi possível criar o arquivo de log. Continuando sem logging."
    }

    Write-Output "Criando ponto de restauração 'ExpertGamingSetupV2.1'..."
    Checkpoint-Computer -Description "ExpertGamingSetupV2.1" -RestorePointType "MODIFY_SETTINGS"
}

function Remove-Bloatware {
    Write-Host "`n--- Iniciando Remoção de Bloatware ---" -ForegroundColor Yellow
    
    # Xbox Game Bar e apps relacionados são MANTIDOS por sua utilidade em jogos.
    Write-Output "Removendo bloatware, mas mantendo a infraestrutura de jogos..."
    Get-AppxPackage -AllUsers | Where-Object {
        $_.Name -match "3DViewer|Microsoft.MSPaint|ZuneMusic|ZuneVideo|Microsoft.YourPhone|Microsoft.MicrosoftSolitaireCollection|CandyCrush|SkypeApp|SolitaireCollection|BingNews|BingWeather|BingSports|BingFinance|Microsoft.Office.OneNote|MixedRealityPortal|Microsoft.Microsoft3DViewer|Microsoft.GetHelp|Microsoft.WindowsAlarms|Microsoft.WindowsMaps|Microsoft.WindowsSoundRecorder|Microsoft.WindowsFeedbackHub|Microsoft.People|Microsoft.Print3D|Microsoft.MSPaint|Microsoft.OfficeHub|Microsoft.MicrosoftEdge"
    } | Remove-AppxPackage -ErrorAction SilentlyContinue

    Get-AppxProvisionedPackage -Online | Where-Object {
        $_.PackageName -match "3DViewer|Microsoft.MSPaint|ZuneMusic|ZuneVideo|Microsoft.YourPhone|Microsoft.MicrosoftSolitaireCollection|CandyCrush|SkypeApp|SolitaireCollection|BingNews|BingWeather|BingSports|BingFinance|Microsoft.Office.OneNote|MixedRealityPortal|Microsoft.Microsoft3DViewer|Microsoft.GetHelp|Microsoft.WindowsAlarms|Microsoft.WindowsMaps|Microsoft.WindowsSoundRecorder|Microsoft.WindowsFeedbackHub|Microsoft.People|Microsoft.Print3D|Microsoft.MSPaint|Microsoft.OfficeHub|Microsoft.MicrosoftEdge"
    } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

    $confirmOneDrive = Read-Host "DESEJA REMOVER O ONEDRIVE COMPLETAMENTE? (Pode ser útil para alguns usuários) [s/N]"
    if ($confirmOneDrive -eq 's') {
        # O OneDrive pode consumir recursos em background sincronizando arquivos. Sua remoção libera esses recursos.
        Write-Output "Removendo OneDrive para evitar uso de recursos em background..."
        if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
            Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -Wait
        }
        elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
            Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" "/uninstall" -Wait
        }
    }
    else {
        Write-Host "Remoção do OneDrive ignorada." -ForegroundColor Green
    }
}

function Disable-TelemetryAndDistractions {
    Write-Host "`n--- Desativando Telemetria e Distrações ---" -ForegroundColor Yellow
    Write-Output "Desativando telemetria (coleta de dados de uso)..."
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
    
    Write-Output "Desativando Widgets, Cortana e sugestões de conteúdo..."
    Get-AppxPackage -AllUsers Microsoft.Windows.Cortana | Remove-AppxPackage -ErrorAction SilentlyContinue
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f

    Write-Output "Desativando tarefas agendadas de telemetria e manutenção..."
    $scheduledTasks = @(
        @{ Path = "\Microsoft\Windows\Application Experience\"; Name = "Microsoft Compatibility Appraiser" },
        @{ Path = "\Microsoft\Windows\Application Experience\"; Name = "ProgramDataUpdater" },
        @{ Path = "\Microsoft\Windows\Customer Experience Improvement Program\"; Name = "Consolidator" },
        @{ Path = "\Microsoft\Windows\Customer Experience Improvement Program\"; Name = "KernelCeipTask" },
        @{ Path = "\Microsoft\Windows\Customer Experience Improvement Program\"; Name = "UsbCeip" },
        @{ Path = "\Microsoft\Windows\DiskDiagnostic\"; Name = "Microsoft-Windows-DiskDiagnosticDataCollector" },
        @{ Path = "\Microsoft\Windows\Windows Error Reporting\"; Name = "QueueReporting" }
    )
    
    foreach ($task in $scheduledTasks) {
        Disable-ScheduledTask -TaskPath $task.Path -TaskName $task.Name -ErrorAction SilentlyContinue
    }
}

function Apply-PerformanceTweaks {
    Write-Host "`n--- Aplicando Otimizações de Performance e Rede ---" -ForegroundColor Yellow
    Write-Output "Ativando Plano de Energia de 'Desempenho Máximo'..."
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    
    Write-Output "Ajustando efeitos visuais para resposta rápida (removendo atraso de menu e transparência)..."
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f

    Write-Output "Aplicando otimizações de rede..."
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 0 /f
}

function Disable-UnnecessaryServices {
    Write-Host "`n--- Desativando Serviços Desnecessários ---" -ForegroundColor Yellow
    
    # O serviço de save do Xbox (XblGameSave) foi MANTIDO intencionalmente e não está na lista.
    # O SysMain (Superfetch) pré-carrega apps na RAM. Em SSDs rápidos, seu benefício é questionável e pode causar uso de disco desnecessário.
    $services = @("Fax", "WMPNetworkSvc", "RetailDemo", "DiagTrack", "SysMain")
    
    foreach ($s in $services) {
        if (Get-Service $s -ErrorAction SilentlyContinue) {
            Write-Output "Desativando serviço $s..."
            Stop-Service $s -Force -ErrorAction SilentlyContinue
            Set-Service $s -StartupType Disabled
        }
    }
}

function Apply-AdvancedRegistryTweaks {
    Write-Host "`n--- Aplicando Tweaks Avançados de Registro ---" -ForegroundColor Yellow
    # Desativa ID de anúncio e experiências personalizadas para maior privacidade.
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f
    # Reduz o tempo de espera para fechar serviços no desligamento.
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f

    $confirmSmartScreen = Read-Host "DESEJA DESATIVAR O SMARTSCREEN? (Isto reduz a segurança contra malware) [s/N]"
    if ($confirmSmartScreen -eq 's') {
        Write-Output "Desativando SmartScreen..."
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f
    }
    else {
        Write-Host "SmartScreen mantido ativo por segurança." -ForegroundColor Green
    }
}

# --- MELHORIA 4: GERADOR DE SCRIPT DE REVERSÃO ---
function Generate-RevertScript {
    $revertScriptContent = @"
<#
.SYNOPSIS
  Reverte as principais configurações aplicadas pelo script de otimização v2.1.
.DESCRIPTION
  Este script tenta redefinir os serviços, tarefas agendadas e configurações de registro
  para um estado mais próximo do padrão do Windows 11.
  NOTA: Ele NÃO reinstala bloatware, Cortana ou OneDrive.
.NOTES
  Execute como Administrador para garantir que todas as operações funcionem.
#>

Write-Host "Iniciando a reversão das otimizações..." -ForegroundColor Yellow

# 1. Reativar Serviços
Write-Output "Reativando serviços para seus padrões..."
# Padrões do Windows 11: DiagTrack (Automático), SysMain (Automático), Fax (Manual), WMPNetworkSvc (Automático)
Set-Service -Name "DiagTrack" -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
Set-Service -Name "Fax" -StartupType Manual -ErrorAction SilentlyContinue
Set-Service -Name "WMPNetworkSvc" -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name "DiagTrack", "SysMain", "WMPNetworkSvc" -ErrorAction SilentlyContinue

# 2. Reativar Tarefas Agendadas
Write-Output "Reativando tarefas agendadas..."
Enable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue
Enable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\ProgramDataUpdater" -ErrorAction SilentlyContinue
Enable-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator" -ErrorAction SilentlyContinue
Enable-ScheduledTask -TaskPath "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" -ErrorAction SilentlyContinue

# 3. Reverter Tweaks de Registro
Write-Output "Revertendo configurações de registro..."
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 1 /f
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "5000" /f
# Remove as políticas de rede caso não existissem antes
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f -ErrorAction SilentlyContinue
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /f -ErrorAction SilentlyContinue

# 4. Reverter Plano de Energia
Write-Output "Revertendo plano de energia para 'Equilibrado'..."
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e

Write-Host "Reversão concluída! Reinicie o computador para aplicar todas as alterações." -ForegroundColor Green
Start-Sleep 5
"@
    $revertPath = "$env:USERPROFILE\Desktop\Reverter-Otimizacoes.ps1"
    $revertScriptContent | Out-File -FilePath $revertPath -Encoding utf8
    Write-Host "`n------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "SCRIPT DE REVERSÃO GERADO!" -ForegroundColor Green
    Write-Host "Um arquivo chamado 'Reverter-Otimizacoes.ps1' foi salvo em sua Área de Trabalho."
    Write-Host "Para reverter as configurações, clique com o botão direito nele e 'Executar como Administrador'."
    Write-Host "Lembre-se: ele não reinstala programas removidos."
    Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
}

# --- MELHORIA 2: MENU INTERATIVO ---
function Show-Menu {
    do {
        Write-Host "`nO que você gostaria de fazer?`n" -ForegroundColor White
        Write-Host " [1] Aplicar TODAS as Otimizações (Modo Agressivo)"
        Write-Host " [2] Apenas Remover Bloatware e OneDrive"
        Write-Host " [3] Apenas Desativar Telemetria e Distrações"
        Write-Host " [4] Apenas Aplicar Tweaks de Performance (Energia, Rede, Visual)"
        Write-Host " [5] Apenas Desativar Serviços Desnecessários"
        Write-Host " [6] Apenas Aplicar Tweaks Avançados de Registro"
        Write-Host " [G] Gerar script para REVERTER otimizações"
        Write-Host " [S] Sair do Script`n"

        $choice = Read-Host "Digite sua escolha e pressione Enter"

        switch ($choice) {
            '1' {
                Start-OptimizationSession
                Remove-Bloatware
                Disable-TelemetryAndDistractions
                Apply-PerformanceTweaks
                Disable-UnnecessaryServices
                Apply-AdvancedRegistryTweaks
                $finish = $true
            }
            '2' {
                Start-OptimizationSession
                Remove-Bloatware
                $finish = $true
            }
            '3' {
                Start-OptimizationSession
                Disable-TelemetryAndDistractions
                $finish = $true
            }
            '4' {
                Start-OptimizationSession
                Apply-PerformanceTweaks
                $finish = $true
            }
            '5' {
                Start-OptimizationSession
                Disable-UnnecessaryServices
                $finish = $true
            }
            '6' {
                Start-OptimizationSession
                Apply-AdvancedRegistryTweaks
                $finish = $true
            }
            'g' {
                Generate-RevertScript
                # Não finaliza, permite que o usuário faça outra coisa
            }
            's' {
                Write-Host "Saindo do script."
                $finish = $true
            }
            default {
                Write-Warning "Opção inválida. Por favor, tente novamente."
            }
        }
    } until ($finish)
}

# --- EXECUÇÃO PRINCIPAL ---
Show-Menu

# Apenas mostra a mensagem de reinicio se alguma otimização foi feita (não ao sair ou gerar script de reversão)
if ($choice -ne 's' -and $choice -ne 'g') {
    Write-Host "`nSetup de performance aplicado! Reinicie o computador para o efeito máximo." -ForegroundColor Cyan
}

Write-Host "Pressione qualquer tecla para fechar esta janela..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# Finaliza o logging
if (Get-Transcript) {
    Stop-Transcript

}
