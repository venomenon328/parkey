# Entwicklung und reproduzierbare Werkzeuge

Stand: 2026-09-05. Parkey verwendet den **Godot-Standardeditor 4.7.2.stable.official.ed1daf0bf** und die Export-Templates **4.7.2.stable**. Es ist bewusst kein .NET-Editor: der gemeinsame Kern bleibt in GDScript und der Web-Export ist damit möglich.

Die Version stammt von der offiziellen [Windows-Downloadseite](https://godotengine.org/download/windows/) und die Export-/Rendererannahmen aus der [Godot-4.7-Webdokumentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html), jeweils am 2026-09-05 geprüft. Der maschinenlesbare Pin steht in [godot-version.txt](../godot-version.txt).

## Verbindliche Windows-Werkzeugablage

Für Parkey gilt **`E:\Zeuch\Coding\Parkey-Tools`** als verbindliches Stammverzeichnis für projektbezogene lokale Entwicklungswerkzeuge. Neue Parkey-Werkzeuge nicht unter `C:\Tools` oder anderen ad-hoc-Verzeichnissen installieren.

Vorgesehene Struktur für den aktuell gepinnten Editor:

```text
E:\Zeuch\Coding\Parkey-Tools\
├─ bin\
│  └─ godot.cmd
└─ Godot-4.7.2\
   ├─ Godot_v4.7.2-stable_win64.exe
   └─ Godot_v4.7.2-stable_win64_console.exe
```

Nur `E:\Zeuch\Coding\Parkey-Tools\bin` wird dauerhaft in den Benutzer-PATH aufgenommen. Ein späteres Engine-Upgrade ändert dadurch nur den Shim, nicht erneut den PATH.

Ausnahmen sind Verzeichnisse, die das jeweilige Werkzeug selbst an einem festen Benutzerpfad erwartet. Godot benötigt die Export-Templates unter `%APPDATA%\Godot\export_templates\4.7.2.stable`. Temporäre Archive und Entpackstufen dürfen `%TEMP%` verwenden.

## Godot unter Windows einrichten

Die folgenden offiziellen Release-Artefakte gehören zusammen. Die SHA-256-Werte werden vor dem Entpacken geprüft; sie sind auch in der CI hinterlegt.

| Artefakt | SHA-256 |
| --- | --- |
| Godot_v4.7.2-stable_win64.exe.zip | 731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953 |
| Godot_v4.7.2-stable_export_templates.tpz | f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011 |

~~~powershell
$version = '4.7.2'
$toolsRoot = 'E:\Zeuch\Coding\Parkey-Tools'
$editorDirectory = Join-Path $toolsRoot "Godot-$version"
$binDirectory = Join-Path $toolsRoot 'bin'
$editorArchive = "$env:TEMP\Godot_v$version-stable_win64.exe.zip"
$templateArchive = "$env:TEMP\Godot_v$version-stable_export_templates.tpz"
$templateStage = "$env:TEMP\ParkeyGodotTemplates"
$templateDestination = "$env:APPDATA\Godot\export_templates\$version.stable"

New-Item -ItemType Directory -Force -Path $toolsRoot, $binDirectory | Out-Null

Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$version-stable/Godot_v$version-stable_win64.exe.zip" -OutFile $editorArchive
Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$version-stable/Godot_v$version-stable_export_templates.tpz" -OutFile $templateArchive
Get-FileHash -Algorithm SHA256 $editorArchive, $templateArchive

if (Test-Path $editorDirectory) {
    throw "Godot-Ziel existiert bereits: $editorDirectory"
}
Expand-Archive $editorArchive -DestinationPath $editorDirectory

Remove-Item $templateStage -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $templateArchive -DestinationPath $templateStage
New-Item -ItemType Directory -Force -Path $templateDestination | Out-Null
Copy-Item "$templateStage\templates\*" $templateDestination -Recurse -Force

@"
@echo off
"$editorDirectory\Godot_v$version-stable_win64_console.exe" %*
"@ | Set-Content (Join-Path $binDirectory 'godot.cmd') -Encoding ASCII

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$pathParts = @($userPath -split ';' | Where-Object { $_ })
if ($binDirectory -notin $pathParts) {
    [Environment]::SetEnvironmentVariable('Path', (($pathParts + $binDirectory) -join ';'), 'User')
}
$env:Path = "$binDirectory;$env:Path"

godot --version
~~~

Die Archive werden nicht eingecheckt. Ein zusätzlicher `templates`-Unterordner innerhalb von `%APPDATA%\Godot\export_templates\4.7.2.stable` ist falsch; dessen Inhalt gehört direkt in das Versionsverzeichnis.

Bereits versehentlich anderswo installierte Parkey-Werkzeuge nicht automatisch löschen. Eine Migration oder Bereinigung erfolgt nur ausdrücklich; neue Einrichtung verwendet jedoch ausschließlich das oben festgelegte Stammverzeichnis.

## Lokale Prüfungen

Im Repository-Root ausführen. `build/` ist absichtlich nicht versioniert.

~~~powershell
New-Item -ItemType Directory -Force -Path build/windows, build/web
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite core
godot --headless --path . --script res://tests/run_tests.gd -- --suite integration
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
~~~

Der Runner kennt ab P1b `smoke`, `core`, `integration` und `all`; ein unbekannter Name muss mit Exitcode ungleich null enden:

~~~powershell
godot --headless --path . --script res://tests/run_tests.gd -- --suite does-not-exist
~~~

Der Web-Export läuft derzeit ohne Threads. Für einen lokalen Testserver:

~~~powershell
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
~~~

Danach `http://127.0.0.1:8000/` in einem Desktop-Browser öffnen und den Server nach dem Test beenden. Ein direkt geöffnetes `index.html` ist kein gültiger Webtest.

## Diagnose und Grenzen

Die P0-Testszene zeigt eine Taste mit Y, eine Platzhalterfigur mit Kopf, eine erhöhte Kamera sowie das erwartete und tatsächlich aktive Renderprofil. Windows läuft standardmäßig mit Forward+; die Web-Projektüberschreibung erzwingt Compatibility.

`KeyInputNormalizer` wertet den erzeugten Unicodewert eines neuen A-Z-Key-down aus, nicht die physische Taste. Shift wird normalisiert; Key-up, Echo sowie Ctrl/Alt/Meta-Kombinationen werden verworfen.

Die P0-Szene liest `Time.get_ticks_usec()` beim Eintritt in `_unhandled_input`; `captured_usec` ist nur der monotone Zeitpunkt des Anwendungsempfangs. P1a stellt darauf aufbauend den testbaren `RunSession`-/Uhrvertrag bereit. P1b verdrahtet ihn über genau einen `_unhandled_input`-Pfad mit dem sichtbaren Parcours. Hardware-, OS- und Browserlatenzen werden nicht als identisch behauptet.
