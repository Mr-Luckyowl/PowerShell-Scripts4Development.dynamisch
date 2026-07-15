<#
.SYNOPSIS
    FJF.DYNAMIC.ENGINE // MSVC INTELLIGENCE CORE (VS 2022 & VS 2026)
.DESCRIPTION
    Ermittelt laufende pwsh-Infos, umgeht die fehlerhafte VsDevCmd.bat vollständig
    und injiziert die korrekten MSVC- und SDK-Umgebungsvariablen live via vswhere.exe.
.EXAMPLE
    C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -NoExit -ExecutionPolicy Bypass -File ".\msvc_init.ps1"
.NOTES 
    Dieses Projekt steht unter der Business Source License 1.1 (BSL 1.1).
    Nutzung in Firmenumgebungen, staatlichen Stellen, Behörden sowie deren 
    EDV-Abteilungen (Commercial & Public Sector Use) ist strikt kostenpflichtig!
    Kontakt für Lizenzanfragen: franjo_kiel [at] web [dot] de
    Alles Weitere in den Dateien: BITTE_Lesen.md und LICENSE.md
.AUTHOR
    https://github.com
#>

$ErrorActionPreference = 'Stop'

Clear-Host
Write-Host "=====================================================================" -ForegroundColor DarkGray
Write-Host " FJF.UDDS // ARCHITECTURE & ENGINE SELECTOR" -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor DarkGray

# 1. INTERAKTIVE SELEKTION (VERSION)
Write-Host "`n[STEP 1] Wähle MSVC Compiler-Version:" -ForegroundColor White
Write-Host "  1 -> Visual Studio 2022 (v143)" -ForegroundColor Yellow
Write-Host "  2 -> Visual Studio 2026 (v145)" -ForegroundColor Yellow
$vsChoice = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').Character

# 2. COMPILER-DISCOVERY VIA MS-VSWHERE (REGISTRY-FREE)
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"

if (-not (Test-Path $vswhere)) {
    Write-Host "`n[ERROR] Microsoft vswhere.exe wurde nicht gefunden! Installer korrupt?" -ForegroundColor Red
    return
}

# Live-Scan der exakten Installationspfade unabhängig vom Laufwerk
if ($vsChoice -eq '2') {
    $vsInstallPath = & $vswhere -version '[18.0,19.0)' -property installationPath
    $vsName = 'MSVC 2026 (v145)'
} else {
    $vsInstallPath = & $vswhere -version '[17.0,18.0)' -property installationPath
    $vsName = 'MSVC 2022 (v143)'
}

if (-not $vsInstallPath) {
    Write-Host "`n[ERROR] $vsName wurde auf diesem System nicht gefunden!" -ForegroundColor Red
    return
}

# 3. INTERAKTIVE SELEKTION (ARCHITEKTUR)
Write-Host "`n[STEP 2] Wähle Ziel-Architektur für" -f$vsName: -ForegroundColor White
Write-Host "  1 -> x64 (Native 64-Bit Compiler)" -ForegroundColor Yellow
Write-Host "  2 -> x86 (Cross-Compiler Hostx64\x86)" -ForegroundColor Yellow
$archChoice = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').Character

# Taste '2' schaltet auf x86 um, jede andere Taste nimmt x64 als Default
$arch = if ($archChoice -eq '2') { 'x86' } else { 'x64' }
$hostArch = if ($archChoice -eq '2') { 'Hostx64\x86' } else { 'Hostx64\x64' }

# 4. AUTOMATISCHE DISCOVERY (SDK & COMPILER REVISION)
$msvcRoot = Join-Path $vsInstallPath "VC\Tools\MSVC"
if (-not (Test-Path $msvcRoot)) {
    Write-Host "`n[ERROR] MSVC Tools-Verzeichnis nicht gefunden unter: $msvcRoot" -ForegroundColor Red
    return
}
$v = (Get-ChildItem $msvcRoot | Sort-Object Name -Descending | Select-Object -First 1).Name
$vsPath = Join-Path $msvcRoot $v

# Scannt alle installierten Windows SDK-Ordner
$sdkFolder = 'C:\Program Files (x86)\Windows Kits\10\Include\'
if (-not (Test-Path $sdkFolder)) {
    Write-Host "`n[ERROR] Windows 10/11 SDK nicht im Standardpfad gefunden!" -ForegroundColor Red
    return
}
$sdkList = Get-ChildItem $sdkFolder | Where-Object { $_.Name -like '10.*' } | Sort-Object Name -Descending

Write-Host "`n[STEP 3] Verfügbare Windows SDKs erkannt. Wähle Target:" -ForegroundColor White
for ($i = 0; $i -lt $sdkList.Count; $i++) {
    Write-Host ("  {0} -> Windows SDK {1}" -f ($i + 1), $sdkList[$i].Name) -ForegroundColor Yellow
}
$sdkChoice = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown').Character

# Fehler-Absicherung: Verhindert Abstürze bei Leertaste, Enter oder Buchstaben
$sdkIndex = -1
$isNumber = [int]::TryParse([string]$sdkChoice, [ref]$sdkIndex)
$sdkIndex = $sdkIndex - 1

# Wenn die Zahl gültig und im Bereich ist, nimm das gewählte SDK, ansonsten das neueste (Index 0)
$sdk = if ($isNumber -and $sdkIndex -ge 0 -and $sdkIndex -lt $sdkList.Count) { $sdkList[$sdkIndex].Name } else { $sdkList.Name }

# 5. INJEKTION DER UMGEBUNGSVARIABLEN (DYNAMIC MATRIX)
$env:PATH = "$vsPath\bin\$hostArch;C:\Program Files (x86)\Windows Kits\10\bin\$sdk\$arch;" + $env:PATH

$env:INCLUDE = "$vsPath\include;" +
               "C:\Program Files (x86)\Windows Kits\10\Include\$sdk\ucrt;" +
               "C:\Program Files (x86)\Windows Kits\10\Include\$sdk\um;" +
               "C:\Program Files (x86)\Windows Kits\10\Include\$sdk\shared;"

$env:LIB = "$vsPath\lib\$arch;" +
           "C:\Program Files (x86)\Windows Kits\10\Lib\$sdk\ucrt\$arch;" +
           "C:\Program Files (x86)\Windows Kits\10\Lib\$sdk\um\$arch;"

# 6. HIGH-FINESSE STATUS DASHBOARD
Clear-Host
Write-Host "=====================================================================" -ForegroundColor DarkGray
Write-Host " >>> FJF.UDDS MATRIX ENGINE DEPLOYED COMPLIANT <<<" -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor DarkGray
Write-Host ("   ENGINE:    {0} ({1})" -f $vsName, $v) -ForegroundColor Gray
Write-Host ("   ARCH:      {0} (via {1})" -f $arch.ToUpper(), $hostArch) -ForegroundColor Gray
Write-Host ("   WIN SDK:   {0}" -f $sdk) -ForegroundColor Gray
Write-Host "=====================================================================" -ForegroundColor DarkGray

# 7. WORKSPACE LOCATION
if (Test-Path "$env:USERPROFILE\source\repos") {
    Set-Location "$env:USERPROFILE\source\repos"
}