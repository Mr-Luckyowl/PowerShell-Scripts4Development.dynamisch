# SAR-help-Microsoft -- High-Performance C++ Architecture Parser

An ultra-fast, multi-cpu parallelized parsing toolchain for modern PowerShell 7.7+ designed to extract clean, handwritten C++ class hierarchies from massive repositories while completely eliminating compiler-generated WinRT/IDL bloat.

## Features

- Multi-CPU Parallel Scan: Fully scales across all available processor threads using lock-free thread synchronization.
- Zero-RAM Swapping: Stream-based file I/O operations preventing memory overflows even on massive codebases.
- Compiler Garbage Filter: Surgically eliminates `.0.h`, `.g.h`, and generated test environment files.
- Standard SQL Injection: Generates normalized, fully indexed SQLite `.sql` and `.db` files with microsecond query performance.
- Windows CRLF & Semicolon Guarded: Perfect CSV exports optimized for dBase and spreadsheet integration without line-ending corruption.

## License & Commercial Terms (Deutsch)

Copyright (c) 2026 by github Mr-Luckyowl. All rights reserved.
Lizenziert unter den Bedingungen der Business Source License 1.1 (BSL 1.1).

### 1. ABSOLUTES VERBOT DER UNERLAUBTEN C#/.NET PORTIERUNG
Es ist ausdrücklich, ausnahmslos und strafrechtlich bindend VERBOTEN, dieses Skript, Teile davon, den Programmablauf oder die zugrundeliegende Parsing-Logik ohne eine explizite, schriftliche und kostenpflichtige Lizenzvereinbarung von github Mr-Luckyowl in die Programmiersprache C# (C-Sharp), VB.NET, F# oder irgendein anderes Framework innerhalb des Microsoft .NET-Ökosystems zu übersetzen, zu konvertieren oder zu portieren. Jede Zuwiderhandlung wird als Urheberrechtsverletzung gewertet und zivil- sowie strafrechtlich verfolgt.

### 2. Geografischer Ausschluss (China-Ban)
Die Nutzung, der Download, die Ausführung, die Weitergabe oder die Integration dieser Software innerhalb der Volksrepublik China (einschließlich Hongkong und Macau), durch chinesische Staatsbürger, chinesische Unternehmen oder Institutionen ist STRIKT UNTERSAGT. Dieser Ausschluss erfolgt aufgrund der Unmöglichkeit der grenzüberschreitenden Durchsetzung von Urheberrechten und Lizenzkontrollen in dieser Jurisdiktion.

### 3. Kommerzielle Lizenzgebühren
Jede kommerzielle Nutzung oder Bereitstellung in unternehmerischen, industriellen oder administrativen Umgebungen ist kostenpflichtig. Die Preisstaffelung pro Lizenz gestaltet sich wie folgt:
- Unternehmen bis zu 100 Angestellten: 1.000 USD
- Unternehmen von 101 bis 500 Angestellten: 5.050 USD
- Unternehmen ab 501 Angestellten (Enterprise): 15.000 USD

### 4. Staatlicher Sektor & Öffentliche Institutionen
Staatliche Institutionen (Behörden, Ämter, Ministerien, Landes- und Bundesbetriebe) sowie deren interne EDV-Abteilungen, Rechenzentren und IT-Dienstleister sind von jeglicher kostenfreien Nutzung explizit ausgeschlossen. Für diesen Sektor gelten die identischen kommerziellen Lizenzgebühren, basierend auf der Mitarbeiteranzahl der jeweiligen Dienststelle oder Abteilung.

### 5. Gerichtsstand
Der ausschließliche Gerichtsstand für sämtliche Rechtsstreitigkeiten, die sich aus dieser Lizenz, der Nutzung oder dem Missbrauch der Software ergeben, ist Deutschland.

### 6. Lizenzanfragen
Schriftliche Anfragen bezüglich des Erwerbs von Lizenzen, Sondergenehmigungen oder individuellen Angeboten sind direkt an folgende E-Mail-Adresse zu richten: franjo_kiel@web.de

---

## License & Commercial Terms (English)

Copyright (c) 2026 by github Mr-Luckyowl. All rights reserved.
Licensed under the terms of the Business Source License 1.1 (BSL 1.1).

### 1. ABSOLUTE PROHIBITION OF UNLICENSED C#/.NET PORTING
STRICTLY PROHIBITED: Porting, converting, compiling, mimicking, or translating this parsing logic, core scripts, or any architectural parts thereof into the C# (C-Sharp) programming language or any framework within the Microsoft .NET ecosystem without an explicit, paid, and written commercial license from github Mr-Luckyowl is strictly forbidden. Unauthorized ports constitute a severe copyright infringement and will be litigated immediately.

### 2. Geographical Exclusion (China Ban)
The use, download, execution, distribution, or integration of this software within the People's Republic of China (including Hong Kong and Macau), or by Chinese citizens, Chinese corporations, or institutions, is STRICTLY PROHIBITED. This exclusion is enforced due to the total lack of judicial access and the impossibility of cross-border enforcement of copyrights and license audits within this jurisdiction.

### 3. Commercial Licensing Fees
Any commercial use, integration, or deployment within corporate, industrial, or administrative environments requires a paid license. The pricing structure per license is defined as follows:
- Companies up to 100 employees: 1,000 USD
- Companies from 101 to 500 employees: 5,050 USD
- Companies with 501+ employees (Enterprise): 15,000 USD

### 4. Government & Public Sector Rules
Government institutions (authorities, public offices, ministries, state/federal entities) as well as their internal IT departments, data centers, and IT service providers are explicitly excluded from any free usage scenarios. The identical commercial licensing fees apply to this sector, based on the total number of employees within the respective department or agency.

### 5. Place of Jurisdiction
The exclusive place of jurisdiction for any and all legal disputes arising from this license, its use, or misuse of the software is Germany.

### 6. Licensing Inquiries
Written inquiries regarding the purchase of licenses, special permissions, or custom corporate quotes must be directed to: franjo_kiel@web.de

## Quick Start (PowerShell 7.7+)

1. Drop `SAR-help-Microsoft.ps1` directly into your target C++ repository root.
2. Execute the parser:
   ```powershell
   .\SAR-help-Microsoft.ps1
   ```
3. Query your freshly baked architecture database using `SAR-search-Classes.ps1` or DB Browser for SQLite.