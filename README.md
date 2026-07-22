# FJF.DYNAMIC.ENGINE // MSVC Environment Initializer

A highly adaptive, zero-overhead C++ development environment patch that bypasses Microsoft's broken `VsDevCmd.bat` and `Enter-VsDevShell` routines entirely. Built with pure performance, robust validation, and maximum reliability for modern C++20/C++23 developers.

---

## ⚡ The Problem: Microsoft's Broken Routines
The default Visual Studio Developer PowerShell scripts are notorious for failing with cryptic errors such as:
```text
Enter-VsDevShell : [ERROR:VsDevCmd.bat] *** VsDevCmd.bat encountered errors. Environment may be incomplete and/or incorrect. ***
CategoryInfo          : NotSpecified: (:) [Enter-VsDevShell], Exception
FullyQualifiedErrorId : DevCmdError
```
This patch completely eliminates the Microsoft batch script overhead and injects clean, reliable path variables directly into your current shell via an interactive interface.

---

## 🚀 Features
* **Registry-Free Engine Discovery:** Uses the official native `vswhere.exe` API to automatically detect compiler paths across different drives and editions.
* **Dual-Target Core Support:** Instantly switches between **Visual Studio 2022 (v143)** and **Visual Studio 2026 (v145)**.
* **Multi-Arch Architecture Selector:** Toggle between **x64 Native** and **x86 Cross-Compilers** on the fly.
* **Automatic Windows SDK Discovery:** Dynamically lists and mounts any installed Windows 10 or Windows 11 SDKs.
* **Fast-Forward Option (3x SPACE):** Smash the Spacebar three times to instantly launch into the optimal default environment.
* **Noob-Proof Execution:** Safe against accidental keyboard mashing, blank spaces, or illegal keystrokes via robust robust `.NET TryParse` tokenizing.

---

## ⚙️ Quick Installation

### 1. Configure the Script
Make sure `msvc_init.ps1` is located in your desired scripts folder, for example:
`C:\Users\YOUR_USERNAME\Documents\PowerShell\msvc-inits\msvc_init.ps1`

### 2. Redirect Visual Studio Start Menu Shortcuts
1. Search your Windows Start Menu for **"Developer PowerShell for VS 2022"** (or 2026).
2. Right-click ➔ **Open file location**.
3. Right-click the shortcut file ➔ **Properties**.
4. Overwrite the **Target (Ziel)** field completely with this line:
   ```text
   C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -NoExit -ExecutionPolicy Bypass -File "C:\Users\YOUR_USERNAME\Documents\PowerShell\msvc-inits\msvc_init.ps1"
   ```

### 3. Inject into VS Code (`settings.json`)
Open your VS Code `settings.json` file and append the profile directly before the final closing bracket:
```json
    "terminal.integrated.profiles.windows": {
        "FJF MSVC Core": {
            "path": "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
            "args": [
                "-NoExit",
                "-ExecutionPolicy", "Bypass",
                "-File", "C:\\Users\\YOUR_USERNAME\\Documents\\PowerShell\\msvc-inits\\msvc_init.ps1"
            ],
            "icon": "terminal-powershell"
        }
    },
    "terminal.integrated.defaultProfile.windows": "FJF MSVC Core"
```


![Erster Screenshot](images/Developer_PowerShell-without-Microsoft-batch-Nonsense.png)

![Zweiter Screenshot](images/Developer-PowerShell_Insert_to_CLI_SETUP.png)


---

## ⚖️ License & Commercial Pricing
This project is multi-licensed under the **Business Source License 1.1 (BSL 1.1)**. 

* **Private / Non-Commercial Use:** 100% Free forever for personal use, hobbyists, and open-source contributions.
* **Small-to-Medium Businesses (Up to 100 employees):** Subject to a commercial license fee of **$5.00 USD** per developer using the script.
* **Enterprises & Public Sector (101+ employees or Government/State-owned IT departments):** Required to purchase a flat-rate Commercial License of **$1,500,000 USD**.

Any commercial, corporate, or institutional use without verified payment or explicit authorization constitutes copyright infringement and will be processed under German/EU jurisdiction.

### 💳 How to Pay
Please activate your sponsorship via **GitHub Sponsors** on this repository or reach out directly to the author for a professional corporate invoice:
* **Developer Profile:** [https://github.com/Mr-Luckyowl](https://github.com/Mr-Luckyowl)
* **Inquiries:** `franjo_kiel [at] web [dot] de`

---
*On December 31, 2036, this license will automatically convert to the unrestricted open-source Apache License, Version 2.0.*
