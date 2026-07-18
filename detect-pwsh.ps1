<#
.SYNOPSIS
    local-{version}.profile-objects.md erstellen.
.DESCRIPTION
    Ermittelt laufende pwsh-Infos und schreibt eine Markdown-Datei: local-{version}.profile-objects.md
    Das Script hilft sozusagen bei den Analysen und Fehlern.
.EXAMPLE
    Eine PowerShell starten und .\detect-pwsh.ps1 aufrufen,z.B.
    {%EDITOR%} .\local-{0}.profile-objects.md . Dadurch erkennen Sie welche Umgebung in der shell geladen oder verarbeitet wird.
.NOTES 
    Dieses Projekt steht unter der Business Source License 1.1 (BSL 1.1).
    Kontakt für Lizenzanfragen: franjo_kiel [at] web [dot] de
    Alles Weitere in den Dateien:
    BITTE_Lesen.md und LICENSE.md 
.AUTHOR
    https://github.com/Mr-Luckyowl/
        
#>

#
# detect-pwsh.ps1
#
Set-StrictMode -Version Latest
#
try {
    # Versions- und Host-Infos
    $pwshVersion = $PSVersionTable.PSVersion.ToString()
    $safeVersion = $pwshVersion -replace '\.','_'
    $hostName = $Host.Name

    # Exe-Pfad und Dateiversion
    try {
        $exePath = (Get-Process -Id $PID -ErrorAction Stop).Path
        $exeFileVersion = (Get-Item -LiteralPath $exePath -ErrorAction Stop).VersionInfo.FileVersion
    }
    catch {
        $exePath = $null
        $exeFileVersion = $null
    }

    # Profile-Objekt (alle Pfade)
    $profiles = $PROFILE | Select-Object *

    # Prüfen ob Preview als Appx/MSIX installiert ist
    $appx = Get-AppxPackage -Name *PowerShellPreview* -ErrorAction SilentlyContinue
    $isAppxPreview = $null -ne $appx

    # Ausgabe-Pfad (Home-Verzeichnis)
    $outDir = $HOME
    if (-not (Test-Path -Path $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    $outFile = Join-Path -Path $outDir -ChildPath ("local-{0}.profile-objects.md" -f $safeVersion)
    #
    # $isDevShell = [string]::IsNullOrEmpty($env:VSAPPIDNAME) -eq $false -or $env:DeveloperCommandPrompt -eq "1"
    #
    # Prüft, ob IRGENDEINE wichtige Visual Studio Variable existiert, weil Microsoft nicht so konform arbeitet. 
    #  Das war ürsprünglich dazu da, um die Informationen abzufangen: 
    #  Get-ChildItem Env:\ | Where-Object { $_.Name -like "*VS*" -or $_.Name -like "*DEV*" }
    #
    #
    $isDevShell =[string]::IsNullOrEmpty($env:VSINSTALLDIR) -eq $false -or 
                 [string]::IsNullOrEmpty($env:VSAPPIDNAME) -eq $false -or $env:DeveloperCommandPrompt -eq "1" -or
                ([string]::IsNullOrEmpty($env:VSINSTALLDIR) -eq $false -and (Test-Path (Join-Path $env:VSINSTALLDIR "VC\vcpkg\vcpkg.exe"))) -or
                 [string]::IsNullOrEmpty($env:CONAN_HOME) -eq $false -or 
                        (Get-ChildItem Env:\ -Name -Filter "CONAN_*").Count -gt 0
    #
    # Payload zusammenstellen
    $payload = [PSCustomObject]@{
        SavedAt        = (Get-Date).ToString('o')
        PwshVersion    = $pwshVersion
        SafeVersion    = $safeVersion
        HostName       = $hostName
        ExePath        = $exePath
        ExeFileVersion = $exeFileVersion
        IsAppxPreview  = $isAppxPreview
        AppxPackage    = if ($isAppxPreview) { $appx | Select-Object Name, PackageFullName, InstallLocation } else { $null }
    # Neu: Befehlszeile eintragen, wenn es eine Dev-Shell ist
        CommandLine    = if ($isDevShell) { [Environment]::CommandLine } else { $null }
        Profiles       = $profiles
    }
    #
    # Markdown erzeugen (Header + JSON-Block)
    $jsonBlock = $payload | ConvertTo-Json -Depth 6
    $markdown = @"
# Profile objects for pwsh $pwshVersion
**SavedAt:** $($payload.SavedAt) 
**ExePath:** $($payload.ExePath) 
**ExeFileVersion:** $($payload.ExeFileVersion) 
**HostName:** $($payload.HostName)
**IsAppxPreview:** $($payload.IsAppxPreview)$(if ($payload.CommandLine) { "`n**CommandLine:** " + $payload.CommandLine })
```json
\$jsonBlock
```
"@
    # Behebt den 'assigned but never used' Fehler: Schreibt die Datei ins Home-Verzeichnis
    $markdown | Set-Content -Path $outFile -Encoding utf8
    Write-Host "Datei erfolgreich erstellt unter: $outFile" -ForegroundColor Green
}
catch {
    Write-Error "Fehler beim Ausführen des Skripts: $_"
}