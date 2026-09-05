# Entwicklung und reproduzierbare Werkzeuge

Stand: 2026-09-05. P0 verwendet den **Godot-Standardeditor 4.7.2.stable.official.ed1daf0bf** und die Export-Templates **4.7.2.stable**. Es ist bewusst kein .NET-Editor: der gemeinsame Kern bleibt in GDScript und der Web-Export ist damit möglich.

Die Version stammt von der offiziellen [Windows-Downloadseite](https://godotengine.org/download/windows/) und die Export-/Rendererannahmen aus der [Godot-4.7-Webdokumentation](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html), jeweils am 2026-09-05 geprüft. Der maschinenlesbare Pin steht in [godot-version.txt](../godot-version.txt).

## Windows einrichten

Die folgenden offiziellen Release-Artefakte gehören zusammen. Die SHA-256-Werte werden vor dem Entpacken geprüft; sie sind auch in der CI hinterlegt.

| Artefakt | SHA-256 |
| --- | --- |
| Godot_v4.7.2-stable_win64.exe.zip | 731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953 |
| Godot_v4.7.2-stable_export_templates.tpz | f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011 |

~~~powershell
$version = "4.7.2"
$editorArchive = "$env:TEMP\Godot_v$version-stable_win64.exe.zip"
$templateArchive = "$env:TEMP\Godot_v$version-stable_export_templates.tpz"
$editorDirectory = "C:\Tools\Godot-$version"

Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$version-stable/Godot_v$version-stable_win64.exe.zip" -OutFile $editorArchive
Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$version-stable/Godot_v$version-stable_export_templates.tpz" -OutFile $templateArchive
Get-FileHash -Algorithm SHA256 $editorArchive, $templateArchive

Expand-Archive $editorArchive -DestinationPath $editorDirectory
$templateStage = "$env:TEMP\ParkeyGodotTemplates"
Expand-Archive $templateArchive -DestinationPath $templateStage
$templateDestination = "$env:APPDATA\Godot\export_templates\$version.stable"
New-Item -ItemType Directory -Force -Path $templateDestination
Copy-Item "$templateStage\templates\*" $templateDestination -Recurse
~~~

Die Archive werden nicht eingecheckt. Der Standardeditor erwartet die Templates unter %APPDATA%\Godot\export_templates\4.7.2.stable; ein entpackter zusätzlicher templates-Unterordner an dieser Stelle ist falsch.

Für die aktuelle PowerShell-Sitzung kann der gepinnte Editor so als godot angesprochen werden:

~~~powershell
Set-Alias godot "C:\Tools\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe"
godot --version
~~~

## Lokale Prüfungen

Im Repository-Root ausführen. build/ ist absichtlich nicht versioniert.

~~~powershell
New-Item -ItemType Directory -Force -Path build/windows, build/web
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
~~~

Der Runner kennt in P0 nur smoke und all; ein unbekannter Name muss mit Exitcode ungleich null enden:

~~~powershell
godot --headless --path . --script res://tests/run_tests.gd -- --suite does-not-exist
~~~

Der Web-Export läuft in P0 ohne Threads. Für einen lokalen Testserver:

~~~powershell
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
~~~

Danach http://127.0.0.1:8000/ in einem Desktop-Browser öffnen und den Server nach dem Test beenden. Ein direkt geöffnetes index.html ist kein gültiger Webtest.

## P0-Diagnose und Grenzen

Die Testszene zeigt eine Taste mit Y, eine Platzhalterfigur mit Kopf, eine erhöhte Kamera sowie das erwartete und das tatsächlich aktive Renderprofil. Windows läuft standardmäßig mit Forward+; die web-Projektüberschreibung erzwingt Compatibility. Die Anzeige muss in einem Windows-Start forward_plus und im Webstart gl_compatibility melden.

KeyInputNormalizer wertet den erzeugten Unicodewert eines neuen A-Z-Key-down aus, nicht die physische Taste. Deshalb ist beispielsweise ein physisches KeyY mit erzeugtem z als sichtbares Z nachvollziehbar. Shift wird normalisiert, Key-up, Echo sowie Ctrl/Alt/Meta-Kombinationen werden verworfen und sichtbar diagnostiziert.

Die Szene liest Time.get_ticks_usec() beim Eintritt in _unhandled_input. captured_usec ist ausdrücklich nur der monotone Zeitpunkt des Anwendungsempfangs; P0 erfindet keinen OS- oder Browserereigniszeitstempel und startet keinen Renntimer. P1a muss diesen Empfangsrand mit dem dann beauftragten RunSession-/Uhrvertrag verbinden. Hardware-, OS- und Browserlatenzen werden damit nicht als identisch behauptet.

P0 ist kein Parcours und enthält keine RunSession, Timer, Fehlerpause, Rangliste oder Generator.
