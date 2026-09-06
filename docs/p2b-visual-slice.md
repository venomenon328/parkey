# P2b: Fidelity-Pass und Windows-Frame-Pacing

Stand: 2026-09-06. Nacharbeit auf `codex/p2b-visual-slice`, bestehender [Draft-PR #18](https://github.com/venomenon328/parkey/pull/18), Arbeitsbasis `81d0b75`, visueller/runtimebezogener Vergleich `5659242`. Verbindlich sind [Fidelity-Auftrag #6](https://github.com/venomenon328/parkey/issues/6#issuecomment-5560900493) und die [anschließende Referenzklarstellung](https://github.com/venomenon328/parkey/issues/6#issuecomment-5560962048). **Subjektive Nutzerabnahme und persönlich gespielter vollständiger Windows-Lauf bleiben offen.**

## Referenz und echte Renderiteration

Der lesbare Original-Mock im Nutzerauftrag wurde als externe Referenz verwendet. Die unbrauchbare Repo-Kopie wurde weder repariert noch erneut importiert; [Einordnung](reference/p2b/README.md). Der Mock gibt Materialqualität, plastische Formen, Figurdetail, räumliche Tiefe und Timer-Hierarchie vor, keine identische Streckenanordnung oder Holzpflicht für die Kappen. Diese bleiben warmer matter Kunststoff.

Vier neue native 1440p-Iterationen wurden tatsächlich gerendert. Die jeweils versionierten Bilder zeigen Bereitschaft, erste und zweite Entscheidung sowie Ergebnis; die bisherigen acht Iterationen gehören zum [historischen Bericht bei 5659242](https://github.com/venomenon328/parkey/blob/5659242/docs/p2b-visual-slice.md).

| Pass | Bildbefund und folgende Korrektur |
| --- | --- |
| 1: [Bereit](evidence/p2b-fidelity/iterations/iteration-1/ready.png), [Alpha](evidence/p2b-fidelity/iterations/iteration-1/alpha.png), [Beta](evidence/p2b-fidelity/iterations/iteration-1/beta.png), [Ergebnis](evidence/p2b-fidelity/iterations/iteration-1/result.png) | Mehr Schrank-/Regaldetails, gebogene Pflanzen und deutlich gegliederte Kleidung. Fotoholz wirkte zu rot/glänzend, Haarsträhnen standen ab, Stoffstruktur war zu grob. Holzfinish/Rauheit, anliegende Frisur und feinere Stoffnormalen erneut bearbeitet. |
| 2: [Bereit](evidence/p2b-fidelity/iterations/iteration-2/ready.png), [Alpha](evidence/p2b-fidelity/iterations/iteration-2/alpha.png), [Beta](evidence/p2b-fidelity/iterations/iteration-2/beta.png), [Ergebnis](evidence/p2b-fidelity/iterations/iteration-2/result.png) | Figur besser integriert, Matte/Dielen durchgängig gestaltet. Der erste honigfarbene Shader verlor zu viel Maserung. Luminanzbereich an die tatsächliche Fototextur angepasst, Mipmaps/anisotrope Abtastung aktiviert. |
| 3: [Bereit](evidence/p2b-fidelity/iterations/iteration-3/ready.png), [Alpha](evidence/p2b-fidelity/iterations/iteration-3/alpha.png), [Beta](evidence/p2b-fidelity/iterations/iteration-3/beta.png), [Ergebnis](evidence/p2b-fidelity/iterations/iteration-3/result.png) | Holzstruktur sichtbar, zurückhaltendes SSIL ergänzt die Kontaktwirkung. Nutzerhinweis: Maserung muss längs zur Brettform laufen. Farb-, Normal- und Rauheitsabbildung gemeinsam gedreht. |
| 4: [Bereit](evidence/p2b-fidelity/iterations/iteration-4/ready.png), [Alpha](evidence/p2b-fidelity/iterations/iteration-4/alpha.png), [Beta](evidence/p2b-fidelity/iterations/iteration-4/beta.png), [Ergebnis](evidence/p2b-fidelity/iterations/iteration-4/result.png) | Längsmaserung auf Dielen, Arbeitsplatten und Regalböden bestätigt; kleine Holzgriffe folgen ihrer eigenen Längsachse. Beide Alternativen und Ergebnis bleiben lesbar. Kein weiterer Kamera-/Kappenumbau erforderlich. |
| Echter Chrome-Pass: [vorher](evidence/p2b-fidelity/iterations/web-before-color-fix/ready.png), [korrigiert](evidence/p2b-fidelity/web-chrome/ready.png) | Compatibility zeigte anfangs fast einfarbiges Holz und eine zu dunkle Matte. Explizite Farbraumbehandlung im gemeinsamen Materialshader erhält die Maserung und Palette auch im sRGB-Profil. Erneuter vollständiger Chrome-Lauf mit acht Bildern und vier Routen. |

Direkter Vergleich zum **unmittelbaren Runtime-Vorstand 5659242**: [Bereit vorher](https://github.com/venomenon328/parkey/blob/5659242/docs/evidence/p2b/windows-1440/ready.png), [Alpha vorher](https://github.com/venomenon328/parkey/blob/5659242/docs/evidence/p2b/windows-1440/alpha.png), [Beta vorher](https://github.com/venomenon328/parkey/blob/5659242/docs/evidence/p2b/windows-1440/beta.png), [Ergebnis vorher](https://github.com/venomenon328/parkey/blob/5659242/docs/evidence/p2b/windows-1440/result.png). Die finalen Gegenstücke stehen unten. Neu sichtbar sind geformte Blätter/Töpfe, mehrgeschossige Regale, Schubladenlippen/Griffe/Etiketten, Werkzeuge, Leuchtengelenke, Geländersockel und Portalbeschläge. Fotoholz, gewebte Matte, Stoff/Leder/Metall und weichere Schatten geben den Flächen unterschiedliche Antworten auf dasselbe Licht. Die Figur besitzt eine geformte Jacke, Kragen/Nähte/Taschen, Werkzeugrolle, anliegende Frisur, Ohr-/Handdetails und mehrteilige Schuhe. Der aufwendig illustrierte Mock bleibt bei organischer Modellierung und szenischer Dichte sichtbar weiter ausgearbeitet; Gleichwertigkeit oder Nutzerfreigabe wird nicht behauptet.

## Umsetzung und unveränderte Verträge

`AtelierMesh` erzeugt nur kosmetische gerundete Vollkörper, Profilkörper und Röhren. Gemeinsame unveränderliche Grundmeshes reduzieren wiederholte Generierung; materialgetreue Bündelung hält die statische Werkstatt günstig. Pflanzen und Werkstattstationen stehen weiterhin auf dem zusammenhängenden Kulissenboden unterhalb der Strecke. Keine neuen scheinbaren Anschlüsse, Kollisionen oder Begehbarkeit.

Kappen/Legenden/HUD bleiben auf dem verbesserten Stand von 5659242: glatte verjüngte Schale, beleuchtete Barlow-Druckzeichen, keine Statussymbole; Timer und normale Ergebnisse in `MM:SS.mmm`, exakte Originalzeiten nur intern/F3. Der Hub bleibt **0,13 Einheiten / 45 ms**, Halten bis zum logischen Verlassen, sofortiger Restart. Kopf-/Gliedmaßenreaktion bleibt rein visuell; gültige Eingaben ab 200 ms werden auch während der laufenden Reaktion angenommen. Die Rückkamera bleibt bei Höhe 4,7, Abstand 7,4, Schulterversatz 1,0 und unveränderten 50-/80-ms-Aufholbudgets.

**Keine Änderung** an `scripts/core`, `scripts/input`, `scripts/course`, `scripts/storage`, Feldstatus-Priorität oder Persistenz-/Rankingsemantik. Alle vier Routen verwenden unverändert:

`course-identity-v1:4dff5df394060f3ce5ffc236f6a9bef0a7e9d0a174b8f4d34308063c73e18e1a`

Keine P3-Inhalte, neue Spielimplementierung oder Projektlizenz.

## Profile, Assets und Bildbudget

Forward+: Vulkan, 4× MSAA, ein Schattenwerfer (Winkel 2,5°, Entfernung 55), schattenloses Fülllicht, ACES, SSAO (0,65 / 1,65) und dezentes SSIL (2,0 / 0,65). Die warme Hauptbeleuchtung und kühlere Umgebung trennen Materialformen. Compatibility: gleiche Modelle, Schriften, Materialkanäle und Pflichtinformationen; ohne Schatten/SSAO/SSIL/MSAA, lineares Tonemapping. Kein DOF/Blur, Glow, SSR, volumetrischer Nebel oder Partikelsystem. Shader berücksichtigen den unterschiedlichen Ausgabe-Farbraum; Mipmaps und entfernungsabhängig ausgeblendete Mikrostruktur begrenzen Flimmern.

Neu: unveränderte 1K-PNG-Kanäle von Poly Haven **Wood Table 001** (Dimitrios Savva / Rico Cilliers), CC0, lokal versioniert und beim Import VRAM-komprimiert. Eigener Shader richtet Maserung und Normalantwort gemeinsam längs zu Brettern/Griffen aus. Versionierter CC0-Himmel und OFL-Schriften bleiben erhalten. [CREDITS.md](../CREDITS.md) enthält Autoren, direkte Downloads und die mitexportierten Lizenztexte; das [Manifest](evidence/p2b-fidelity/source-manifest.json) enthält Größen und Hashes. Keine Downloads, Dienste oder Zusatzbibliothek im Spiel.

Der freigegebene Headroom wird für Formen und Kontaktlicht genutzt, **ohne Qualitätsreduktion zur Umgehung des VSync-Problems**. Arbeitsbudget dieses Passes: unter 600 Draw Calls / 1,3 Millionen gerenderten Primitiven im nativen Entscheidungsbild, weiterhin Ziel stabile 60 FPS. Final gemessen: Windows **506 / 1.140.534**, Chrome **258 / 285.606**. Die Primitivzahl enthält Render-/Schattenpässe; sie ist keine Anzahl eindeutiger Modelldreiecke. Das alte 450.000-Primitivenbudget wird durch dieses gemessene Paketbudget ersetzt; 144 FPS sind kein neues Produktziel.

## Ursache und normale Windows-Konfiguration

Testrechner: Windows 11 Pro Build 26200, Ryzen 7 5800X, RTX 3070, Treiber 32.0.15.9649. Zwei 2560×1440-Monitore, von Godot als Bildschirm 0 mit 143,973 Hz und Bildschirm 1 mit 59,951 Hz gemeldet. Engine unverändert `4.7.2.stable.official.ed1daf0bf`.

Die Untersuchung begann vor dem Fidelity-Umbau mit der Darstellung von 5659242 und erweiterter Messinstrumentierung. Der 1080p-FIFO-Befund ist reproduzierbar: etwa 60 FPS, Frameabstände nahe zwei/drei 144-Hz-Refreshperioden statt gleichmäßigem 16,7-ms-Takt. Fensterzentrierung und D3D12 allein lösen ihn nicht:

| Getrennte Diagnose, je 20 s, keine Fokusverluste | Ø FPS | Anwendungs-p99 ms | Frames >20 ms |
| --- | --- | --- | --- |
| [Vulkan/FIFO am Bildschirmrand](evidence/p2b-fidelity/diagnostics/vulkan-edge/metrics.json) | 59,96 | 21,219 | 421 |
| [Vulkan/FIFO zentriert](evidence/p2b-fidelity/diagnostics/vulkan-centered/metrics.json) | 59,95 | 21,280 | 441 |
| [D3D12/FIFO zentriert](evidence/p2b-fidelity/diagnostics/d3d12-centered/metrics.json) | 59,95 | 21,193 | 478 |
| [Vulkan/Mailbox](evidence/p2b-fidelity/diagnostics/vulkan-mailbox/metrics.json) | 143,88 | 9,290 | 0 |

PresentMon 2.5.1 erfasst zusätzlich echte Windows-Presentereignisse: [FIFO-Trace](evidence/p2b-fidelity/diagnostics/present-fifo/present-summary.json) mit 896 Composed-Flip-Ereignissen und GPU-Arbeit p99 **7,224 ms**. [Mailbox ohne Limit](evidence/p2b-fidelity/diagnostics/present-mailbox/present-summary.json) wechselt im damaligen Desktopzustand in Independent Flip, während die Anwendung unnötig 273,59 FPS erzeugt. [Mailbox mit Diagnoselimit 144](evidence/p2b-fidelity/diagnostics/present-mailbox-capped/present-summary.json) hält begrenzte Arbeit. Diese Gegenproben und der vorhandene VSync-off-Nachweis belegen Render-Headroom und lokalisieren die ungleichmäßigen Anwendungsframes im Present-/Desktop-Synchronisationspfad; eine genaue interne Windows-/Treiberursache jenseits dieser Messungen wird nicht behauptet. Die zusätzlich als Display-Change gemeldeten ETW-Werte haben auf diesem gemischten Desktop eine unten erläuterte Messgrenze.

**Normale Voreinstellung:** Fenster mit FIFO initialisieren (Projektmodus 1), dann durch `WindowPacing` am bestehenden Fenster auf Mailbox-VSync (Modus 3) schalten. Die Anwendung begrenzt Renderframes auf die aufgerundete Frequenz des aktuellen Fenstermonitors, bei fehlenden Daten auf 60. Prüfung alle 0,5 Sekunden, explizite bestehende FPS-Limits werden respektiert; beim Szenenwechsel wird das eigene Limit freigegeben. Keine neue Fenster-/Fokussteuerung und keine Veränderung von Eingaben oder Laufuhr. Der Prüfhelfer kann beim ersten Frame noch das Limit des ursprünglichen Monitors melden; der Abschluss protokolliert das nach dem Umsetzen wirksame Limit. Web bleibt browsergetaktet.

Die Initialisierungsreihenfolge ist gemessen: unmittelbarer Mailbox-Start wählte auf diesem NVIDIA-Treiber einen GDI-Copy-Pfad; FIFO-Initialisierung mit anschließendem Mailbox wählte DXGI. Am schnellen Monitor gelang damit Hardware Composed Independent Flip ([Gegenprobe](evidence/p2b-fidelity/diagnostics/fifo-init-mailbox-144hz/present-summary.json): 2865 Presents, Present-p99 8,542 ms, kein Present >20 ms). Ein Wechsel zu D3D12, Zentrieren einschließlich Fensterrahmen, höhere Diagnoselimits sowie gewöhnliches/exklusives Vollbild lieferten am langsamen Monitor keinen gleichermaßen eindeutigen Display-Zeitstempel-Nachweis. Diese Einstellungen wurden nicht als neue Voreinstellung übernommen; OS-/Treiberprofile und Monitorfrequenzen blieben unverändert.

Die folgenden finalen Läufe verwenden **keine** VSync-/FPS-/Driver-Diagnoseflags. Normaler Vulkan-Renderer und volle neue Bildqualität bleiben aktiv. PresentMon-Pfade hängen auch vom Desktopzustand ab; Independent Flip wird deshalb nicht als dauerhafte Garantie ausgegeben. Einzelne Betriebssystemspitzen werden ausdrücklich mit ausgewiesen.

## Technische Pflichtprüfungen

Alle Befehle tatsächlich auf Windows mit der gepinnten Engine ausgeführt, nach der letzten Runtime-/Shaderkorrektur:

| Pflichtbefehl | Ergebnis / Log |
| --- | --- |
| `godot --headless --path . --import` | [Exit 0, keine Script-/Importfehler](evidence/p2b-fidelity/import.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite presentation` | [539 Assertions, 0 Fehler](evidence/p2b-fidelity/presentation.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite integration` | [238 Assertions, 0 Fehler](evidence/p2b-fidelity/integration.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite all` | [1089 Assertions, 0 Fehler](evidence/p2b-fidelity/all.txt) |
| `godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe` | [Exit 0](evidence/p2b-fidelity/export-windows.txt) |
| `godot --headless --path . --export-release "Web" build/web/index.html` | [Exit 0](evidence/p2b-fidelity/export-web.txt) |

[Exitübersicht](evidence/p2b-fidelity/check-exits.json), [fehlende/unbekannte Suite: erwarteter Exit 1](evidence/p2b-fidelity/negative-exits.json). Beide Node-Prüfhelfer bestehen `node --check`. Zusätzliche Regressionen prüfen echte gebündelte Vertex-/Normaldaten, Figurenbauteile, die zwei SSIL-Profile und die Frequenzbegrenzung einschließlich ungültiger Metadaten. Bestehende Identitäts-, Hub-, Status-, Eingabe-/Zeit-, Speicher-, Rang- und Routenprüfungen bleiben erhalten. Hochfrequenzregression: maximal 2,738 / durchschnittlich 0,459 Welteinheiten Restweg, kein Restaufholen und keine Figurenkorrektur; 60 Eingaben ohne Renderfortschritt bleiben wirksam. Headless ist kein Grafiktest und Export kein Spieltest.

## Reale Release-Render- und Leistungsnachweise

Je Konfiguration vier synthetische Vollrouten mit echten Viewport-Ereignissen und monotoner Uhr, danach 15 Sekunden am Entscheidungsfeld: insgesamt rund 32 Sekunden gemessene Anwendungsframeabstände nach Aufwärmen. Screenshot-Readback liegt außerhalb der Messfenster. **Alle zwanzig Routen fehlerfrei beendet, unveränderte Identität, null Messframes ohne Fokus.** Keine persönliche Spielabnahme.

| Profil | Reale Bildgröße | Frames / Messzeit | Ø FPS | p95 / p99 ms | Maximum ms | >20 / >33,334 ms |
| --- | --- | --- | --- | --- | --- | --- |
| Windows 1080p, 144-Hz-Monitor / Auto-144-Limit | 1920×1080 | 4596 / 32,237 s | 142,57 | 8,525 / 9,269 | 35,424 | 1 / 1 |
| Windows 1440p, 144-Hz-Monitor / Auto-144-Limit | 2560×1440 | 4525 / 32,221 s | 140,44 | 8,420 / 9,825 | 17,935 | 0 / 0 |
| Windows 1080p, 60-Hz-Monitor / Auto-60-Limit | 1920×1080 | 1942 / 32,365 s | 60,00 | 16,775 / 16,884 | 29,417 | 4 / 0 |
| Windows 1440p, 60-Hz-Monitor / Auto-60-Limit | 2560×1440 | 1944 / 32,399 s | 60,00 | 16,782 / 17,007 | 28,235 | 4 / 0 |
| Chrome / Compatibility | 1751×985 | 1940 / 32,360 s | 59,95 | 16,900 / 17,000 | 20,100 | 1 / 0 |

Die ursprüngliche dauernde FIFO-Unruhe (574/1940 Frames >20 ms) tritt in diesen normalen Läufen nicht mehr auf. Am 60-Hz-Monitor liegen jeweils vier Spitzen im Zeitbereich der vier Ziel-/Ergebnisübergänge; Speicher-/UI-Anteile wurden nicht separat profiliert. Das sind rund 0,21 % der Messframes, kein durchgehend harter 20-ms-Maximalwert. Auch die einzelne 35,424-ms-Spitze am schnellen Monitor und 20,100 ms in Chrome bleiben im Bericht. Die p95-/p99-Verteilung erfüllt das Render-Pacing-Ziel deutlich überzeugender als der Vorstand; einzelne Übergangs-/Systemspitzen und sichtbares Spielgefühl werden nicht verschwiegen.

Chrome 152.0.7977.76 (UA 152.0.0.0), echtes sichtbares Desktopfenster mit separatem lokalen Prüfprofil, kein Headless-Browser. Canvas 1904×985, tatsächlicher Spielviewport/PNGs 1751×985. Beide Entscheidungen, W/E, besuchter Rückweg, Fehlerreaktion, Figur/Kappen und Ergebnis/F3 wurden anhand der echten Bilder geprüft. Web bleibt bei Licht und Kantenglättung sichtbar einfacher; die Pflichtzeichen sind erhalten.

Erstes Bild ab Engine-Start: Windows am 144-Hz-Monitor 1080p **2,853 s**, 1440p **2,768 s**; am 60-Hz-Monitor **2,723 / 2,797 s**. Chrome ab Navigation **2,891 s**, vollständiger Browserablauf **50,100 s**. Lokaler Transfer: WASM 39.515.054 Bytes / 135,9 ms, PCK 11.389.992 Bytes / 23,8 ms. Der erste Chrome-Zwischenstand benötigte 21,877 s bis zum Bild; gemeinsame unveränderliche Grundmeshes vermeiden inzwischen wiederholte Aufbauarbeit. Zwischen den Läufen war außerdem der Browser-/Shadercache aufgewärmt, daher keine isolierte Geschwindigkeitszusage für diese Änderung. Loopback-Werte sind keine Internetlade- oder Mindesthardwarezusage.

### Zusätzliche Present-Belege

Die separaten finalen ETW-Reihen `normal-present-144hz` und `normal-present-60hz` starten ohne den Evidence-Helfer, nur mit Fenstergröße/-position und automatischem Prozessende. Roh-CSV, Startargumente und Auswertung bleiben zusammen versioniert. Die vorherigen Reihen `startup-mailbox-*` gehören ausdrücklich zum verworfenen direkten Mailbox-Start und sind keine finalen Default-Nachweise.

| Normaler Release, 30 s ETW, 1080p | Presents | Present-p95 / p99 / max ms | Presents >20 ms | GPU-p99 ms | Present-Pfad |
| --- | --- | --- | --- | --- | --- |
| [144 Hz](evidence/p2b-fidelity/normal-present-144hz/present-summary.json) | 4297 | 7,620 / 8,215 / 9,230 | 0 | 8,248 | 4168 Hardware Composed Independent Flip, 129 Independent Flip |
| [60 Hz](evidence/p2b-fidelity/normal-present-60hz/present-summary.json) | 1798 | 17,010 / 17,254 / 18,453 | 0 | 9,173 | Composed Flip |

Die separat gemeldete Display-Change-Spalte hat am schnellen Monitor p99/max **13,907 / 20,932 ms** (1 >20 ms), am langsamen **34,402 / 34,815 ms** (413 >20 ms). Diese Werte bleiben vollständig erhalten und werden wegen der folgenden bekannten Grenze nicht als physische Bildwechsel interpretiert. Beide finalen Traces melden `AllowsTearing=0`; frühere Diagnosen melden teils 1.

**Messgrenze statt erfundener Scanout-Freigabe:** [PresentMon #108](https://github.com/GameTechDev/PresentMon/issues/108) dokumentiert unzuverlässige Display-Zeitstempel auf gemischten Monitorfrequenzen. Das ist hier relevant: die [60-Hz-/288-FPS-Gegenprobe](evidence/p2b-fidelity/diagnostics/mailbox-60hz-centered-cap288/present-summary.json) meldet etwa 93 Display-Updates/s auf einem physischen 60-Hz-Monitor. Auch die [monitorbezogene DXGI-Gegenprobe](evidence/p2b-fidelity/diagnostics/output-probe-60hz/output-timing.json) beschreibt Desktop-Aktualisierungen und verändert durch die Capture-Schnittstelle den beobachteten Present-Pfad; sie liest keine Bildpixel und ist kein normaler Erfolgsnachweis. Aus diesen Zusatzwerten folgt weder ein gesicherter Bildausgabefehler noch ein erfolgreicher optischer Scanout. `AllowsTearing` ist ebenfalls nur ein API-Erlaubnisflag, kein beobachteter Bildriss.

Der ursprüngliche Blocker ungleichmäßiger **Anwendungsframezeiten** wird deshalb anhand derselben Messgröße und voller Routen unter normaler Konfiguration beurteilt. Beide vom Nutzer verwendeten Monitore sind erfasst. Die zusätzliche Beurteilung wahrnehmbaren Stotterns/Bildreißens auf beiden Bildschirmen bleibt in der ausdrücklich offenen persönlichen Windows-Abnahme; eine allgemeine Treiber-/Compositor-Garantie wird nicht erteilt.

### Versionierte Belege

[Quellmanifest](evidence/p2b-fidelity/source-manifest.json): UTF-8/LF-SHA-256 für Laufzeit-/Prüfquellen und textliche Nachweise, Binärhashes für Assets, Exporte und echte PNGs mit geprüften Pixelmaßen. Die frühen Iterationen sind Zwischenstände; finale Bildordner gehören zum manifestierten Stand. Die alten Belege unter `evidence/p2b` bleiben historische Nachweise von 5659242. Kein nachbearbeitetes Ersatzbild, kein erfundener Hash des externen Anhangs.

Rohdaten: [Windows 1080p](evidence/p2b-fidelity/windows-1080/metrics.json), [Windows 1440p](evidence/p2b-fidelity/windows-1440/metrics.json), [Chrome](evidence/p2b-fidelity/web-chrome/metrics.json). Native Laufprotokolle: [1080p](evidence/p2b-fidelity/windows-1080/render.txt), [1440p](evidence/p2b-fidelity/windows-1440/render.txt).

Zusätzliche vollständige Reihen am **60-Hz-Monitor**: [1080p-Metriken](evidence/p2b-fidelity/windows-60hz-1080/metrics.json), [1440p-Metriken](evidence/p2b-fidelity/windows-60hz-1440/metrics.json), jeweils acht unveränderte PNG-Zustände im selben Ordner. Beispiele: [erste Entscheidung 1440p](evidence/p2b-fidelity/windows-60hz-1440/alpha.png), [zweite Entscheidung 1080p](evidence/p2b-fidelity/windows-60hz-1080/beta.png), [Ergebnis 1440p](evidence/p2b-fidelity/windows-60hz-1440/result.png). Insgesamt **40 finale echte Renderbilder** sowie 16 native Iterationsbilder und zwei Chrome-Zwischenbilder.

| Zustand | Windows 1080p | Windows 1440p | Chrome |
| --- | --- | --- | --- |
| Bereit | [PNG](evidence/p2b-fidelity/windows-1080/ready.png) | [PNG](evidence/p2b-fidelity/windows-1440/ready.png) | [PNG](evidence/p2b-fidelity/web-chrome/ready.png) |
| Erste Entscheidung | [PNG](evidence/p2b-fidelity/windows-1080/alpha.png) | [PNG](evidence/p2b-fidelity/windows-1440/alpha.png) | [PNG](evidence/p2b-fidelity/web-chrome/alpha.png) |
| Besuchter Rückweg | [PNG](evidence/p2b-fidelity/windows-1080/visited_return.png) | [PNG](evidence/p2b-fidelity/windows-1440/visited_return.png) | [PNG](evidence/p2b-fidelity/web-chrome/visited_return.png) |
| Fehlerreaktion | [PNG](evidence/p2b-fidelity/windows-1080/error.png) | [PNG](evidence/p2b-fidelity/windows-1440/error.png) | [PNG](evidence/p2b-fidelity/web-chrome/error.png) |
| Zweite Entscheidung | [PNG](evidence/p2b-fidelity/windows-1080/beta.png) | [PNG](evidence/p2b-fidelity/windows-1440/beta.png) | [PNG](evidence/p2b-fidelity/web-chrome/beta.png) |
| W / schmale Formate | [PNG](evidence/p2b-fidelity/windows-1080/beta_long.png) | [PNG](evidence/p2b-fidelity/windows-1440/beta_long.png) | [PNG](evidence/p2b-fidelity/web-chrome/beta_long.png) |
| Ergebnis | [PNG](evidence/p2b-fidelity/windows-1080/result.png) | [PNG](evidence/p2b-fidelity/windows-1440/result.png) | [PNG](evidence/p2b-fidelity/web-chrome/result.png) |
| Entwickleransicht | [PNG](evidence/p2b-fidelity/windows-1080/debug.png) | [PNG](evidence/p2b-fidelity/windows-1440/debug.png) | [PNG](evidence/p2b-fidelity/web-chrome/debug.png) |

## Offene manuelle Abnahmegates

**Subjektive Nutzerabnahme von Look, Figur, Animation, Lesbarkeit und Spielgefühl sowie ein persönlich gespielter vollständiger Windows-Lauf bleiben ausdrücklich offen.** Dabei auch wahrnehmbares Stottern prüfen; synthetische Routen und ETW sind keine menschliche Spielprüfung. PR #18 bleibt Draft, kein Merge. Die ältere physische P1b-Chrome-Eingabeabnahme bleibt separat offen. Mindesthardware ist ohne schwächere reale Testmaschine unbestimmt.

Nächster abgegrenzter Schritt: den normalen Windows-Release persönlich spielen, beide Entscheidungen/Rückweg, Press/Halten/Loslassen, Fehler, Timer/F3 und Ziel prüfen. [Reproduktion](development.md#p2b-grafikprüfung-reproduzieren).

Technische Primärquellen, geprüft 2026-09-06; tatsächliche lokale Nachweise haben Vorrang: [DisplayServer / VSync](https://docs.godotengine.org/en/stable/classes/class_displayserver.html), [räumliche Shader / OUTPUT_IS_SRGB](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html), [Environment](https://docs.godotengine.org/en/stable/classes/class_environment.html), [PresentMon 2.5.1](https://github.com/GameTechDev/PresentMon/releases/tag/v2.5.1).
