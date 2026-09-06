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
godot --headless --path . --script res://tests/run_tests.gd -- --suite storage
godot --headless --path . --script res://tests/run_tests.gd -- --suite integration
godot --headless --path . --script res://tests/run_tests.gd -- --suite routes
godot --headless --path . --script res://tests/run_tests.gd -- --suite presentation
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
~~~

Der Runner kennt ab P2b `smoke`, `core`, `storage`, `integration`, `routes`, `presentation` und `all`; ein unbekannter Name muss mit Exitcode ungleich null enden:

~~~powershell
godot --headless --path . --script res://tests/run_tests.gd -- --suite does-not-exist
~~~

P1c / #4 implementiert `storage` und die lokale Ablage unter `user://parkey-results/results-v1.json`. `duration_usec` und `error_count` liegen dort als kanonische Dezimalstrings vor, damit die numerischen Originalwerte verlustfrei rundreisen. `.tmp` und `.bak` sind kurzfristige Schreib-/Wiederanlaufdateien; sie nicht manuell als Rangliste bearbeiten oder löschen. Bestehende Benutzerbestzeiten niemals als Testablage verwenden: `storage` und `integration` verwenden vor `_ready` ausschließlich `user://parkey-test-results/...` und räumen nur diese eigenen Pfade auf. Reale Persistenzprüfungen stehen in [testing.md](testing.md) und der vollständige Vertrag einschließlich Browsergrenzen in [p1c-local-results.md](p1c-local-results.md).

Der Web-Export läuft derzeit ohne Threads. Für einen lokalen Testserver:

~~~powershell
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
~~~

Danach `http://127.0.0.1:8000/` in einem Desktop-Browser öffnen und den Server nach dem Test beenden. Ein direkt geöffnetes `index.html` ist kein gültiger Webtest.

## Diagnose und Grenzen

Die P0-Testszene zeigt eine Taste mit Y, eine Platzhalterfigur mit Kopf, eine erhöhte Kamera sowie das erwartete und tatsächlich aktive Renderprofil. Windows läuft standardmäßig mit Forward+; die Web-Projektüberschreibung erzwingt Compatibility.

`KeyInputNormalizer` wertet den erzeugten Unicodewert eines neuen A-Z-Key-down aus, nicht die physische Taste. Shift wird normalisiert; Key-up, Echo sowie Ctrl/Alt/Meta-Kombinationen werden verworfen.

Die P0-Szene liest `Time.get_ticks_usec()` beim Eintritt in `_unhandled_input`; `captured_usec` ist nur der monotone Zeitpunkt des Anwendungsempfangs. P1a stellt darauf aufbauend den testbaren `RunSession`-/Uhrvertrag bereit. P1b verdrahtet ihn über genau einen `_unhandled_input`-Pfad mit dem sichtbaren Parcours. Hardware-, OS- und Browserlatenzen werden nicht als identisch behauptet.

## P2b-Grafikprüfung reproduzieren

Normal spielen: Windows-Release starten bzw. Webexport über HTTP öffnen. F3 schaltet technische Diagnosen samt optionalem Textfokus-Test zu; erneutes F3 gibt Textfokus frei. Backspace/Escape behalten ihre P1-Bedeutung. Keine automatische Testeingabe ohne ausdrücklichen Prüfparameter.

```powershell
build/windows/parkey.exe --resolution 1920x1080 -- --p2b-evidence --evidence-size=1920x1080
build/windows/parkey.exe --resolution 2560x1440 -- --p2b-evidence --evidence-size=2560x1440
```

Die zusätzliche Größenangabe setzt nach der anfänglichen DPI-Aushandlung die Clientgröße; der Prüfhelfer protokolliert die tatsächlichen PNG-Pixelmaße. Screenshots und `metrics.json` entstehen unter `user://parkey-test-results/render-evidence/`; mit `--evidence-output=E:/Zeuch/Coding/parkey/build/evidence/eigener-lauf` direkt einen eigenen Ordner wählen. Testresultate liegen separat je Prozessstart; Benutzerbestzeiten werden nicht verändert. Rohdaten enthalten die geordneten Frameintervalle, reale Fenster-/Monitorwerte, Renderdriver sowie das anfängliche und abschließende FPS-Limit.

Web: Der lokale Prüftreiber verwendet nur Node-24-Bordmittel. Er dient den unveränderten Webexport aus und nimmt ausschließlich die eigenen Bilder/Messwerte des explizit aktivierten Spiels entgegen; keine Browser-Debugging-Schnittstelle, keine Profilzugriffe und kein externer Dienst.

```powershell
node tests/serve_web_evidence.mjs 8147 build/web build/evidence/p2b/web-1080
```

In Desktop-Chrome `http://127.0.0.1:8147/?evidence=1&capture=1` öffnen und etwa 55 Sekunden im Vordergrund lassen. Bilder und Bericht tragen die tatsächliche Canvasauflösung. Für eine zweite Fenstergröße den Server mit einem neuen Ausgabeordner neu starten und denselben Ablauf wiederholen. Fenster-/Vollbildgröße vor dem Lauf setzen; Fokuswechsel invalidieren laufende Versuche wie im Normalspiel. Auflösung immer an den erzeugten PNGs kontrollieren.

Der Server bindet ausschließlich `127.0.0.1`, akzeptiert nur begrenzte JSON-Nachweise mit festen Screenshotnamen und beendet sich nach dem Abschlussbericht. Ohne `evidence=1` wird kein Prüfhelfer instanziiert; ohne `capture=1` auf `127.0.0.1` sendet selbst der Helfer keine HTTP-Nachweise. Normale Spielläufe haben keinen Uploadpfad. Die Berichte enthalten GPU, Canvas, Browserkennung, erste Bildzeit, lokale Ressourcenladezeiten, vier vollständige Läufe und Framebeobachtungen. Exporte und Screenshots sind weiterhin keine subjektive Nutzerabnahme.

Die Nacharbeit erfasst acht Zustände einschließlich `beta` und `beta_long` für die schmalen Formate und das breite W. Native Messfenster sichtbar öffnen und während des Laufs fokussiert lassen; verdeckte Fenster können vom Desktop gedrosselt werden und liefern keine vergleichbare Vordergrundleistung. Nur im Prüfmodus wählt der Helfer den angeschlossenen Bildschirm mit der höchsten gemeldeten Frequenz, setzt die Fensterposition dorthin und fordert beim Start Fokus an. Der erste native Frame protokolliert Bildschirmfrequenz, Bildschirmindex, Fensterposition und VSync-Modus; der Abschluss zählt auch Messframes ohne Fensterfokus. Diese Zahl muss bei der Auswertung mit angegeben werden. Das normale Spiel erhält keine neue Bildschirm-/Fokussteuerung. `.gdignore` hält die reine Gestaltungsreferenz ebenso wie die Renderbelege aus dem Spielimport heraus.

Die P2b-Nacharbeit verwendet lokal versionierte OFL-Schriften, ein CC0-HDR und drei CC0-Holzkanäle unter `assets/`; Quellen und Lizenztexte stehen in [CREDITS.md](../CREDITS.md). Beide Export-Presets packen Credits und Lizenztexte mit ein. Das Spiel benötigt keine zusätzlichen Werkzeuge, Dienste oder Laufzeitdownloads.

Windows initialisiert regulär mit FIFO und schaltet am bestehenden Fenster auf Mailbox-VSync; das automatische Limit entspricht dem aktuellen Fenstermonitor (`WindowPacing`, Fallback 60). Für normale Nachweise weder `--disable-vsync`, `--max-fps` noch `--evidence-vsync` setzen. Die Platzierung bleibt Sache des Fenstersystems. `--evidence-screen=1` wählt im Prüfmodus explizit den zweiten Monitor; `--evidence-position=300,140` setzt nur die Prüfposition. `--evidence-pacing=40` misst statt vier Routen einen ruhenden Entscheidungsblick für 40 Sekunden. Diese statische Zusatzmessung ersetzt die Routen-/Bildprüfung nicht. `--evidence-window-mode=4` dient ausschließlich der getrennten Gegenprobe mit exklusivem Vollbild; die normale Fensterwahl bleibt unverändert.

Diagnosen dürfen `--evidence-vsync=1` (FIFO), `--evidence-vsync=3` (Mailbox), `--rendering-driver d3d12` oder `--disable-vsync --max-fps 144` getrennt vergleichen. Abweichende Synchronisation/Driver immer ausdrücklich kennzeichnen; niemals als Default-Erfolg ausgeben. Grafikläufe nacheinander und ohne gleichzeitig laufenden Export durchführen.

Optionales Windows-ETW-Werkzeug: [PresentMon 2.5.1](https://github.com/GameTechDev/PresentMon/releases/tag/v2.5.1), geprüft 2026-09-06, MIT. Portable Datei und unveränderte `LICENSE.txt` liegen unter `E:\Zeuch\Coding\Parkey-Tools\PresentMon-2.5.1`; kein PATH-/Treiber-/OS-Tuning. [EXE](https://github.com/GameTechDev/PresentMon/releases/download/v2.5.1/PresentMon-2.5.1-x64.exe), SHA-256 `9BEC3083069F58F911E6A512F4806DB51A27BD096103087BC1D05EF54C80A191`, [Lizenz](https://raw.githubusercontent.com/GameTechDev/PresentMon/v2.5.1/LICENSE.txt). Der Quellcode benötigt dieses Werkzeug nicht.

```powershell
New-Item -ItemType Directory -Force -Path build/evidence/present
Start-Process E:\Zeuch\Coding\Parkey-Tools\PresentMon-2.5.1\PresentMon.exe -WindowStyle Hidden -ArgumentList @('--process_name','parkey.exe','--output_file','E:/Zeuch/Coding/parkey/build/evidence/present/presents.csv','--no_console_stats','--no_track_input','--delay','8','--timed','30','--terminate_after_timed','--session_name','ParkeyPresent')
build/windows/parkey.exe --resolution 1920x1080 -- --p2b-evidence --evidence-size=1920x1080 --evidence-pacing=40 --evidence-output=E:/Zeuch/Coding/parkey/build/evidence/present
# Nach Ende beider Prozesse:
node tests/analyze_presents.mjs build/evidence/present/presents.csv build/evidence/present/present-summary.json
```

ETW meldet Present-Pfad und `MsBetweenDisplayChange` separat von Engine-Frames. **Auf gemischten Monitorfrequenzen sind diese Display-Zeitstempel nicht zuverlässig einem physischen Monitor zuzuordnen** ([PresentMon #108](https://github.com/GameTechDev/PresentMon/issues/108), geprüft 2026-09-06). Die lokale Gegenprobe meldet am 60-Hz-Monitor sogar mehr als 60 Display-Updates/s. Deshalb weder ungeprüfte Scanout-Erfolge noch entsprechende Fehler aus dieser Spalte ableiten. `NA`/nicht angezeigte Presents sind keine Null-ms-Bilder. `AllowsTearing` ist ein API-Erlaubnisflag, kein beobachteter Bildriss. Nichtadministrative Warnungen zu fremden/kurzlebigen Prozessen separat aufbewahren; eine leere CSV ist kein Erfolg.

Zusätzliche, getrennte Diagnose: `tests/windows_output_probe.cs` liest ausschließlich DXGI-Output-Duplication-Metadaten eines ausgewählten Monitors, keine Bildpixel. Zum Bauen mit vorhandenem .NET-8-SDK alle Ausgaben in die Werkzeugablage lenken:

```powershell
dotnet build tests/windows_output_probe.csproj -c Release -p:BaseIntermediateOutputPath=E:/Zeuch/Coding/Parkey-Tools/OutputTiming-Probe/obj/ -p:OutputPath=E:/Zeuch/Coding/Parkey-Tools/OutputTiming-Probe/bin/
E:/Zeuch/Coding/Parkey-Tools/OutputTiming-Probe/bin/windows_output_probe.exe
# Erst die ausgegebene DXGI-Geometrie dem gewünschten Monitor zuordnen!
# Beispiel: Output 0, 20 Sekunden, 8 Sekunden Startverzögerung:
E:/Zeuch/Coding/Parkey-Tools/OutputTiming-Probe/bin/windows_output_probe.exe 0 20 8 E:/Zeuch/Coding/parkey/build/evidence/output-timing.json
```

DXGI- und Godot-Indizes unterscheiden sich auf dem Prüfdesktop. [Microsoft](https://learn.microsoft.com/en-us/windows/win32/api/dxgi1_2/ns-dxgi1_2-dxgi_outdupl_frame_info) beschreibt `LastPresentTime` als Desktop-Aktualisierung, nicht als optischen Scanout. Die zusätzliche Capture-Schnittstelle verändert außerdem den beobachteten Present-Pfad. Diese Gegenprobe ist daher kein normaler Erfolgsnachweis und keine zusätzliche Spielabhängigkeit. Wahrnehmbares Stottern und Bildrisse bleiben Teil der offenen persönlichen Windows-Abnahme.
