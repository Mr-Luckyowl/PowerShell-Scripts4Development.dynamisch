<#
.SYNOPSIS
   FJF.DYNAMIC.ENGINE // Multi-Core MSVC Performance & Build Pipeline
.DESCRIPTION
   Forced multi-core compiler execution and isolated .NET SDK environment purging.
.LICENSE
   Licensed under the Business Source License 1.1 (BSL 1.1) until July 22, 2037.
   Change License after Change Date: Apache License 2.0 / MIT License.
.PRICING
   - Private / Non-Commercial Use: 100% FREE forever.
   - SMB (Up to 100 employees): $5.00 USD per developer.
   - Enterprises & Public Sector (101+ employees / Gov): $1,500,000.00 USD flat-rate.
   Commercial deployment without verified payment constitutes direct copyright infringement.
.COPYRIGHT
   Copyright (c) 2026 luckyowl. All rights reserved under German/EU jurisdiction.
#>

#requires -Version 7.6.3
#requires -PSEdition Core
#requires -Modules @{ModuleName="PSScriptAnalyzer"; ModuleVersion="1.25.0"}

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$ScriptDir  = $PSScriptRoot
$LogPath    = Join-Path $ScriptDir "build_log.txt"
$JsonPath   = Join-Path $ScriptDir "build_report.json"
$GlobalDotNet   = "C:\Program Files\dotnet\dotnet.exe"

if (-not (Test-Path $GlobalDotNet)) {
    Write-Host "CRITICAL ERROR: GLOBAL .Net SDK unter C:\Program Files\dotnet\ fehlt!" -ForegroundColor Red
    $Stopwatch.Stop()
    Exit
}
if ($null -eq $LogPath -or $null -eq $JsonPath) {
   Write-Host "HINWEIS: `$LogPath` oder `$JsonPath` sind nicht definiert! Dateioperationen schlagen gleich fehl." -ForegroundColor Orange
}

$env:BuildPassReferences ="true"
$env:CL_MP ="true"
$env:EnforceProcessCountAcrossBuilds="true"
$env:MSBuildUseMultiToolTask ="true"
$env:PATH = ($env:PATH -split ';' | Where-Object { $_ -notlike "*AppData\Local\dotnet*" }) -join ';'
$env:DOTNET_MSBUILD_SDK_RESOLVER_SDKS_DIR = "C:\Program Files\dotnet\sdk\9.0.316"
$env:MSBuildSDKsPath = "C:\Program Files\dotnet\sdk\9.0.316\Sdks"

if ($env:PATH -split ';' -notcontains "C:\Program Files\dotnet") {
    $env:PATH   = "C:\Program Files\dotnet;$env:PATH"
}
$DevEnvPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.com"

Start-Process -FilePath $DevEnvPath -ArgumentList "`"OpenConsole.slnx`" /Build `"Release|x64`" /Out `"$LogPath`"" -WorkingDirectory $ScriptDir -NoNewWindow -Wait
# &$DevEnvPath "OpenConsole.slnx" /Build "Release | x64" /out $LogPath

$targetPath = "C:\Program Files\dotnet"

if ($env:Path -split ';' -notcontains $targetPath) {
   $env:Path = "$targetPath;$env:Path"
}

$Stopwatch.Stop()

$ElapsedTime = $Stopwatch.Elapsed

$Errors = [System.Collections.Generic.List[string]]::new()

$Warnings = [System.Collections.Generic.List[string]]::new()

if (Test-Path $LogPath) {
   $Reader = $null
   try {
      $Reader = [System.IO.StreamReader]::new($LogPath)
      while ($true) {
         $line = $Reader.ReadLine()
         if ($null -eq $line) {
            break 
         }
         $trimmedLine = $line.Trim()
         if ($trimmedLine -match "error") {
            $Errors.Add($trimmedLine)
         }
         elseif ($trimmedLine -match "warning") {
            $Warnings.Add($trimmedLine)
         }
      }
   }
   finally {
      if ($null -ne $Reader) {
         $Reader.Close()
         $Reader.Dispose()
      }
   }   
}

$ReportObject = [pscustomobject]@{
   Timestamp       = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
   Project         = "OpenConsole.slnx"
   Configuration   = "Release"
   Platform        = "x64"
   Duration        = "$($ElapsedTime.Minutes)m $($ElapsedTime.Seconds)s"
   Status          = if ($Errors.Count -eq 0) { "Success" } else { "Failed" }
   ErrorCount      = $Errors.Count
   WarningCount    = $Warnings.Count
   Errors          = [string[]]$Errors
   Warnings        = [string[]]$Warnings
}

$JsonString = $ReportObject | ConvertTo-Json -Depth 4

Set-Content -Path $JsonPath -Value $JsonString -Encoding utf8 -Force 

Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host "Prozess beendet!" -ForegroundColor Green
Write-Host "Dauer: $($ElapsedTime.Minutes) Minuten, $($ElapsedTime.Seconds) Sekunden" -ForegroundColor Yellow
Write-Host "JSON-Report generieren: $JsonPath" -ForegroundColor Magenta
Write-Host "----------------------------------------" -ForegroundColor Gray