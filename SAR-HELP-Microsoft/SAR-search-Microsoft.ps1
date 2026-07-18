<#
.SYNOPSIS
    SAR-search-Classes.ps1 - Suchmaske für C++ Klassen.
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

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Clear-Host
    [Console]::WriteLine("FEHLER: DIESES SKRIPT ERFORDERT POWERSHELL 7 (pwsh) ODER HÖHER!")
    return
}

# Automatische Erkennung der DB im selben Ordner
$dbFile = Join-Path -Path $PSScriptRoot -ChildPath "terminal-classes.db"

if (-not (Test-Path $dbFile)) {
    Clear-Host
    [Console]::WriteLine("======================================================================")
    [Console]::WriteLine("FEHLER: Die Datenbankdatei 'terminal-classes.db' wurde nicht gefunden!")
    [Console]::WriteLine("Bitte starte zuerst das Analyse-Skript 'SAR-help-Microsoft.ps1'.")
    [Console]::WriteLine("======================================================================")
    return
}

# Benutzereingabe abfragen
Clear-Host
[Console]::WriteLine("======================================================================")
[Console]::WriteLine(" SAR-CLASS-SEARCH / HIGH-SPEED DATENBANK ABFRAGE"                      )
[Console]::WriteLine(" Copyright (c) 2026 by github Mr-Luckyowl. All rights reserved."       )
[Console]::WriteLine(" Licensed under Business Source License 1.1 (BSL 1.1)"                 )
[Console]::WriteLine("======================================================================")
[Console]::WriteLine("Hinweis: Wildcards sind erlaubt, z.B. *Terminal* oder *Renderer*)")
$searchQuery = Read-Host "Gesuchter C++ Klassenname"

if ([string]::IsNullOrEmpty($searchQuery)) {
    [Console]::WriteLine("Suche abgebrochen / search interrupted. Keine Eingabe erhalten.")
    return
}

# Wildcards für SQL vorbereiten (Aus * wird in SQL das %-Zeichen)
$sqlSearch = $searchQuery -replace '\*', '%'

[Console]::WriteLine("----------------------------------------------------------------------")
[Console]::WriteLine("Suche läuft in indizierten Datensätzen..."                             )
[Console]::WriteLine("----------------------------------------------------------------------")

# SQL-Abfrage an SQLite abfeuern (Nutzt COALESCE für echte NULL-Werte)
$query = "SELECT class_name AS 'Klasse', COALESCE(base_class, '---') AS 'Erbt von', filename AS 'Datei' FROM cpp_classes WHERE class_name LIKE '$sqlSearch' ORDER BY class_name ASC;"

if (Get-Command sqlite3 -ErrorAction SilentlyContinue) {
    sqlite3 -header -column $dbFile $query
} else {
    [Console]::WriteLine("FEHLER: 'sqlite3' ist auf diesem System nicht installiert.")
}

[Console]::WriteLine("----------------------------------------------------------------------")
[Console]::WriteLine("Suche beendet.")