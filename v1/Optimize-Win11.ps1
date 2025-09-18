<#
.SYNOPSIS
    Otimiza o Windows 11 para performance máxima em, removendo bloatware e desativando telemetria.

.DESCRIPTION
    Este script PowerShell realiza uma série de otimizações agressivas no Windows 11.
    Ele remove aplicativos pré-instalados, desativa serviços e tarefas agendadas que consomem recursos, ajusta o
    plano de energia para desempenho máximo e aplica diversas configurações de registro para melhorar a resposta do sistema.
    Um ponto de restauração é criado antes de qualquer alteração ser feita.

.NOTES
    Autor: Vinicius Sulpicio
    Data: 18/09/2025
    Versão: 1.0
    Inspirado nas filosofias de otimização da comunidade de power users.
#>

# =============================================================
# Inspirado nas otimizações de scripts avançados para performance máxima.
# Risco de instabilidade é maior. USE O PONTO DE RESTAURAÇÃO SE NECESSÁRIO.
# =============================================================

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
|          Iniciando otimização para performance...     |
|                                                       |
\-------------------------------------------------------/
"@ -ForegroundColor Cyan


# Pausa rápida para o usuário ver o banner
Start-Sleep -Seconds 2


# 1. Criar ponto de restauração
Write-Output "Criando ponto de restauração 'ExpertGamingSetup'..."
Checkpoint-Computer -Description "ExpertGamingSetup" -RestorePointType "MODIFY_SETTINGS"

# 2. Remover Bloatware (Mantendo componentes Gamer)
Write-Output "Removendo bloatware, mas mantendo a infraestrutura de jogos..."
# Xbox Game Bar e apps relacionados são MANTIDOS por sua utilidade.
Get-AppxPackage -AllUsers | Where-Object {
    $_.Name -match "3DViewer|Microsoft.MSPaint|ZuneMusic|ZuneVideo|Microsoft.YourPhone|Microsoft.MicrosoftSolitaireCollection|CandyCrush|SkypeApp|SolitaireCollection|BingNews|BingWeather|BingSports|BingFinance|Microsoft.Office.OneNote|MixedRealityPortal|Microsoft.Microsoft3DViewer|Microsoft.GetHelp|Microsoft.WindowsAlarms|Microsoft.WindowsMaps|Microsoft.WindowsSoundRecorder|Microsoft.WindowsFeedbackHub|Microsoft.People|Microsoft.Print3D|Microsoft.MSPaint|Microsoft.OfficeHub|Microsoft.MicrosoftEdge"
} | Remove-AppxPackage -ErrorAction SilentlyContinue

Get-AppxProvisionedPackage -Online | Where-Object {
    $_.PackageName -match "3DViewer|Microsoft.MSPaint|ZuneMusic|ZuneVideo|Microsoft.YourPhone|Microsoft.MicrosoftSolitaireCollection|CandyCrush|SkypeApp|SolitaireCollection|BingNews|BingWeather|BingSports|BingFinance|Microsoft.Office.OneNote|MixedRealityPortal|Microsoft.Microsoft3DViewer|Microsoft.GetHelp|Microsoft.WindowsAlarms|Microsoft.WindowsMaps|Microsoft.WindowsSoundRecorder|Microsoft.WindowsFeedbackHub|Microsoft.People|Microsoft.Print3D|Microsoft.MSPaint|Microsoft.OfficeHub|Microsoft.MicrosoftEdge"
} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# 3. Remover OneDrive completamente
Write-Output "Removendo OneDrive para evitar uso de recursos em background..."
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" "/uninstall" -Wait
} elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" "/uninstall" -Wait
}

# 4. Desativar Telemetria
Write-Output "Desativando telemetria..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
Stop-Service DiagTrack -ErrorAction SilentlyContinue
Set-Service DiagTrack -StartupType Disabled

# 5. Desativar Widgets, Cortana e sugestões
Write-Output "Desativando Widgets, Cortana e distrações..."
Get-AppxPackage -AllUsers Microsoft.Windows.Cortana | Remove-AppxPackage -ErrorAction SilentlyContinue
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t REG_DWORD /d 0 /f

# 6. Ativar Ultimate Performance e ajustes visuais para resposta rápida
Write-Output "Ativando Ultimate Performance Mode e desativando animações..."
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value 0
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f

# 7. Desativando serviços desnecessários
Write-Output "Desativando serviços que não impactam jogos..."
# O serviço de save do Xbox (XblGameSave) foi MANTIDO por segurança e compatibilidade.
$services = @("Fax","WMPNetworkSvc","RetailDemo","DiagTrack")
foreach ($s in $services) {
    if (Get-Service $s -ErrorAction SilentlyContinue) {
        Stop-Service $s -Force -ErrorAction SilentlyContinue
        Set-Service $s -StartupType Disabled
    }
}

# 8. Ajustes de rede
Write-Output "Aplicando otimizações de rede..."
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d 0 /f

# 9. Desativar Tarefas Agendadas Invasivas
Write-Output "Desativando tarefas agendadas de telemetria e manutenção..."
$scheduledTasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
)
foreach ($task in $scheduledTasks) {
    Disable-ScheduledTask -TaskPath $task -ErrorAction SilentlyContinue
}

# 10. Otimizações de Registro Adicionais (Privacidade e Performance)
Write-Output "Aplicando tweaks avançados de registro..."
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f

# 11. Desativar mais serviços (SysMain/Superfetch)
# O SysMain pré-carrega apps na RAM. Em SSDs rápidos, isso pode ser desnecessário e causar uso de disco.
Write-Output "Desativando serviço SysMain (Superfetch)..."
Stop-Service SysMain -Force -ErrorAction SilentlyContinue
Set-Service SysMain -StartupType Disabled

# 12. Finalização
Write-Output "Setup de performace aplicado! Reinicie o computador para o efeito máximo."