<#
.SYNOPSIS
    SAR-help-Microsoft.ps1 - Mit Multi-CPU Generierung::C++ Architektur-Parser für pwsh 7.x!
.COPYRIGHT
    Copyright (c) 2026 by github Mr-Luckyowl. All rights reserved.
.LICENSE
    Licensed under the Business Source License 1.1 (BSL 1.1).
    SÄMTLICHE RECHTE VORBEHALTEN. Es ist ausdrücklich VERBOTEN, dieses Skript,
    Teile davon oder die zugrundeliegende Logik ohne eine explizite, schriftliche 
    Lizenzvereinbarung von github Mr-Luckyowl in die Programmiersprache C# (C-Sharp) 
    oder ein darauf basierendes .NET-Projekt zu übersetzen, zu konvertieren oder zu portieren.
    GEOGRAFISCHER AUSSCHLUSS: Die Nutzung in der Volksrepublik China ist strikt untersagt.
    Licensed under the Business Source License 1.1 (BSL 1.1).
    STRENGSTES PORTIERUNGSVERBOT: Es ist ausdrücklich und ausnahmslos VERBOTEN,
    dieses Skript, Teile davon, die zugrundeliegende Parsing-Logik oder die 
    Funktionsweise ohne eine explizite, schriftliche und kostenpflichtige Lizenz
    von github Mr-Luckyowl in die Programmiersprache C# (C-Sharp) oder in ein 
    darauf basierendes .NET-Projekt zu übersetzen, zu konvertieren oder zu portieren.
    GEOGRAFISCHER AUSSCHLUSS: Die Nutzung in der Volksrepublik China ist strikt untersagt.
#>

# 1. LIZENZ-, PREIS- UND COPYRIGHT-ANZEIGE AM START
Clear-Host
[Console]::WriteLine("===================================================================")
[Console]::WriteLine(" SAR-HELP-MICROSOFT -- PROFI ARCHITEKTUR SCANNER (CLEAN CODE ONLY) ")
[Console]::WriteLine(" Copyright (c) 2026 by github Mr-Luckyowl. All rights reserved."    )
[Console]::WriteLine(" Licensed under Business Source License 1.1 (BSL 1.1)"              )
[Console]::WriteLine("-------------------------------------------------------------------")
[Console]::WriteLine(" GEGEBENER GERICHTSSTAND: Deutschland. Anfragen an: franjo_kiel@web.de")
[Console]::WriteLine(" GEOGRAFISCHER AUSSCHLUSS: VR China (inkl. HK/Macau) ist STRIKT GEBANNT.")
[Console]::WriteLine(" HINWEIS: Portierung in C# ohne Lizenz ist strengstens verboten."    )
[Console]::WriteLine("=====================================================================")   

# 2. HARDENING: VERSIONS-PRÜFUNG
if ($PSVersionTable.PSVersion.Major -lt 7) {
    [Console]::WriteLine("ERROR: THIs SCRIPT needs POWERSHELL 7 (pwsh) or higher!")
    return
}

# 3. DYNAMISCHE PFAD-ERKENNUNG
$projectPath = $PSScriptRoot
if ([string]::IsNullOrEmpty($projectPath)) { $projectPath = Get-Location }

$outputSql   = Join-Path -Path $projectPath -ChildPath "terminal-classes.sql"
$outputDb    = Join-Path -Path $projectPath -ChildPath "terminal-classes.db"
$tempCsv     = Join-Path -Path $projectPath -ChildPath "terminal-classes.tmp.csv"

[Console]::WriteLine("Projektordner: $projectPath")
[Console]::WriteLine("Bereinige alte Dateireste...")

# GEHÄRTETER BLOCKADE-SCHUTZ: Fängt gesperrte SQLite-Dateien im Windows-Dateisystem ab
if (Test-Path $outputSql) { Remove-Item -Path $outputSql -Force }
if (Test-Path $tempCsv)   { Remove-Item -Path $tempCsv -Force }

if (Test-Path $outputDb) {
    try {
        Remove-Item -Path $outputDb -Force -ErrorAction Stop
    } catch {
        [Console]::WriteLine("======================================================================")
        [Console]::WriteLine("Alert: DATABASE IS STILL BLOCKED!")
        [Console]::WriteLine("Please close 'DB Browser for SQLite' or your SAR-search-Microsoft.ps1.")
        [Console]::WriteLine("======================================================================")
        $null = Read-Host "Press ENTER, if you have closed, in order to go ahead..."
        try {
            Remove-Item -Path $outputDb -Force -ErrorAction Stop
        } catch {
            [Console]::WriteLine("ERROR: file still opened. CANCEL.")
            return
        }
    }
}

# 4. FILTERUNG DER DATEILISTE (Befreit den Entwickler vom Microsoft-Müll)
[Console]::WriteLine("Lese Quellcode-Struktur ein...")
$allHeaders = Get-ChildItem -Path $projectPath -Recurse -Include *.h,*.hpp -ErrorAction SilentlyContinue

# Hier fliegen alle auto-generierten WinRT-Zwischenlager (.0.h, .g.h) und Testordner raus
$headers = $allHeaders | Where-Object {
    $_.Name -notmatch '\.[0-9]\.h$' -and
    $_.Name -notmatch '\.g\.hpp$' -and
    $_.Name -notmatch '\.g\.h$' -and
    $_.FullName -notmatch '\\(UT|UnitTests|Test|packages|Generated Files)\\.'
}

$totalFiles = $headers.Count
if ($totalFiles -eq 0) {
    [Console]::WriteLine("ERROR: No real C++ Header files found!")
    return
}

[Console]::WriteLine("$totalFiles real, Header files separated. Multi-CPU-Scan is working and running...")
$scanTimer = [System.Diagnostics.Stopwatch]::StartNew()

# Temporäre CSV initialisieren
"ClassName,BaseClass,FileName,FilePath" | Out-File -FilePath $tempCsv -Encoding utf8

# REGEX-HÄRTUNG: Schließt Vorwärtsdeklarationen (Klasse endet mit Semikolon ';') strikt aus
$pattern = '^\s*(class|struct)\s+(?:[A-Z0-9_]+_API\s+|[A-Z0-9_]+_EXPORT\s+)?([a-zA-Z_][a-zA-Z0-9_]*)\s*(?!;)(?:\s*:\s*(?:public|protected|private)\s+([a-zA-Z_][a-zA-Z0-9_]*))?'
$globalCounter = [int64]0

# 5. PARALLELER PARSE-STREAM (KORRIGIERTE INDIZIERUNG FÜR PWSH 7)
$headers | ForEach-Object -Parallel {
    $pattern = $using:pattern
    $tempCsv = $using:tempCsv
    $total   = $using:totalFiles
    $file    = $_
    
    try {
        $content = [System.IO.File]::ReadLines($file.FullName)
        $localBuffer = [System.Collections.Generic.List[string]]::new()
        
        foreach ($line in $content) {
            # Zeile bereinigen (Inline-Kommentare abschneiden, um Falschtreffer zu verhindern)
            $cleanLine = $line -replace '//.*$', ''
            
            if ($cleanLine -match $pattern) {
                # Klasse ist immer in Gruppe 2
                $className = $Matches[2]
                
                # BUGFIX: Saubere Prüfung der Vererbungsgruppe via .ContainsKey
                $baseClass = if ($Matches.ContainsKey(3) -and -not [string]::IsNullOrWhiteSpace($Matches[3])) { $Matches[3] } else { "NONE" }
                
                # Double-Check: Wenn am Ende der Zeile ein Semikolon steht, war es nur eine Deklaration
                if ($cleanLine -match ';\s*$') { continue }
                
                $safePath  = $file.FullName -replace '\\', '\\\\' -replace "'", "''"
                $safeFile  = $file.Name -replace "'", "''"
                $safeClass = $className -replace "'", "''"
                $safeBase  = $baseClass -replace "'", "''"
                
                $localBuffer.Add("$safeClass,$safeBase,$safeFile,$safePath")
            }
        }
        
        if ($localBuffer.Count -gt 0) {
            [System.IO.File]::AppendAllLines($tempCsv, $localBuffer)
        }
    } catch {}

    $current = [System.Threading.Interlocked]::Increment([ref]$using:globalCounter)
    if ($current % 100 -eq 0 -or $current -eq $total) {
        $percent = [math]::Round(($current / $total) * 100, 1)
        [Console]::WriteLine("Goal to end--> : $current von $total real files found ($percent%)")
    }
} -ThrottleLimit ([Environment]::ProcessorCount)

$scanTimer.Stop()
[Console]::WriteLine("----------------------------------------------------------------------")
[Console]::WriteLine("Scanning ends. how long it took: $($scanTimer.Elapsed.ToString('hh\:mm\:ss'))")
[Console]::WriteLine("sort and building clean SQL-structure...")
[Console]::WriteLine("----------------------------------------------------------------------")

# 6. SAUBERE SQL-GENERIERUNG MIT INLINE-COPYRIGHTS FÜR MR-LUCKYOWL
$sqlTimer = [System.Diagnostics.Stopwatch]::StartNew()

$sqlHeader = @(
    "CREATE TABLE IF NOT EXISTS cpp_classes (",
    "    id INTEGER PRIMARY KEY AUTOINCREMENT,",
    "    class_name TEXT NOT NULL, -- COPYRIGHT (C) 2026 BY GITHUB MR-LUCKYOWL. ALL RIGHTS RESERVED.",
    "    base_class TEXT,          -- LICENSED UNDER BUSINESS SOURCE LICENSE 1.1 (BSL 1.1). CHINA IS STRICTLY BANNED.",
    "    filename TEXT NOT NULL,   -- PORTING OR CONVERTING THIS LOGIC TO C# WITHOUT A LICENSE IS STRICTLY PROHIBITED.",
    "    filepath TEXT NOT NULL",
    ");",
    "CREATE INDEX IF NOT EXISTS idx_class_name ON cpp_classes(class_name);",
    "CREATE INDEX IF NOT EXISTS idx_base_class ON cpp_classes(base_class);",
    "BEGIN TRANSACTION;"
)
$sqlHeader | Out-File -FilePath $outputSql -Encoding utf8

if (Test-Path $tempCsv) {
    $bufferList = [System.Collections.Generic.List[string]]::new()
    
    # Importiert, filtert Duplikate und sortiert alphabetisch
    Import-Csv -Path $tempCsv | Select-Object ClassName, BaseClass, FileName, FilePath -Unique | Sort-Object ClassName | ForEach-Object {
        # BUGFIX: Wandelt den Platzhalter 'NONE' in ein echtes SQL NULL ohne Anführungszeichen um
        $sqlBase = if ($_.BaseClass -eq "NONE" -or [string]::IsNullOrEmpty($_.BaseClass)) { "NULL" } else { "'$($_.BaseClass)'" }
        $bufferList.Add("INSERT INTO cpp_classes (class_name, base_class, filename, filepath) VALUES ('$($_.ClassName)', $sqlBase, '$($_.FileName)', '$($_.FilePath)');")
        
        if ($bufferList.Count -ge 5000) {
            $bufferList | Out-File -FilePath $outputSql -Append -Encoding utf8
            $bufferList.Clear()
        }
    }
    
    if ($bufferList.Count -gt 0) { $bufferList | Out-File -FilePath $outputSql -Append -Encoding utf8 }
    "COMMIT;" | Out-File -FilePath $outputSql -Append -Encoding utf8
    Remove-Item -Path $tempCsv -Force
    $sqlTimer.Stop()
    
    [Console]::WriteLine("Dauer der SQL-Generierung: $($sqlTimer.Elapsed.ToString('hh\:mm\:ss'))")
    [Console]::WriteLine("Datenbasis erfolgreich bereinigt gesichert: $outputSql")
    [Console]::WriteLine("----------------------------------------------------------------------")
    
    # 7. AUTOMATISCHER SQLITE-IMPORT (VOLLSTÄNDIG)
    if (Get-Command sqlite3 -ErrorAction SilentlyContinue) {
        [Console]::WriteLine("Konvertiere in saubere, compiler-müll-freie Architektur-Datenbank...")
        sqlite3 $outputDb ".read '$outputSql'"
        [Console]::WriteLine("Bereinigte Profi-Datenbank erfolgreich versiegelt: $outputDb")
    }
    [Console]::WriteLine("======================================================================")
    [Console]::WriteLine(" SUCCESSFUL! NO MS-GENERAT-BLACKHOLE ."                                )
    [Console]::WriteLine("======================================================================")
} else {
    [Console]::WriteLine("ERROR: SORRY, no real classes detected.")
}