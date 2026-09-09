# P2b: Tastatur-Werkstatt und Mock-Figur

Stand: 2026-09-06. Nacharbeit auf `codex/p2b-visual-slice`, bestehender [Draft-PR #18](https://github.com/venomenon328/parkey/pull/18), Ausgangspunkt `b236f17d1d77c66736f54b8239d25337265d83ea`. Verbindlich ist der [neueste Fidelity-Auftrag aus #6](https://github.com/venomenon328/parkey/issues/6#issuecomment-5561815307). **Subjektive Nutzerabnahme und persönlich gespielter vollständiger Windows-Lauf bleiben offen.**

## Visuelle Änderungen

Die Werkstatt zeigt jetzt einen zusammengehörigen Arbeitsablauf: offene Switch-Montage mit Gehäuse/Platte, Kreuzstempeln, Teilewanne und Keycap-Puller; Farb-/Profilplatz mit sortierten Mustern und Schnittmodell; Prüfplatz mit bestückter Tastatur, Messgerät und Anschlusskabel. Gemeinsame Schubladenmöbel, seitliche Holzüberdachung, Versorgungsleitung und gebündelte Kartonlagerung verbinden das Set. Wiederholte lose Drehknöpfe, Lampenreihen und vier gleich bestückte Regalschränke entfallen. Möbel und Requisiten bleiben außerhalb der kanonischen Feldhülle; der kompaktere Kulissenboden trägt das gesamte Set.

Die Stationen erhalten auf zusätzlichen Nutzerwunsch eine eigene helle, fein längs gemaserte Leimholztextur mit seidenmattem Finish. Dieser neue prozedurale Shader unterscheidet sich vom dunkleren groben Fotoholz des Dielenbodens.

Die Figur erhält neue Grundproportionen: größerer runder Kopf, heller modellierter Bob mit kleinen runden Haarformen, weicher fliederfarbener Hoodie mit eigener Bärenstickerei, kurze Beine und helle Sneaker. Der Pony ist Teil derselben Haaroberfläche. Idle, Bewegung, Fehlerreaktion und ihre Übergänge verwenden weiterhin die vorhandenen Zustände; keine zusätzliche Bewegungsfrist.

Warmes flacheres Seitenlicht, kühlere Schatten, drei begrenzte Arbeitsleuchten und ein hellerer cyanfarbener Wolkenhimmel verbinden Figur, Kappen und Werkstattpalette. Feinere Kunststoffnormalen beruhigen die Kappen; Holz-Farb-/Normal-/Rauheitsabbildung folgt auch Querstreben und senkrechten Pfosten. Die schmalere, ruhigere Matte hebt den Parcours vom umliegenden Holz ab. Kamera: Abstand **6,8**, Höhe **4,2**, Schulterversatz weiterhin **1,0**, unveränderte Vorschau beider Entscheidungsalternativen.

## Referenz und echte Iteration

Der Nutzer hat den lesbaren Mock in diesem Lauf erneut als Chat-Anhang bereitgestellt. Er wurde tatsächlich als qualitative Referenz betrachtet. Die beschädigte Repo-Kopie wurde gemäß #6 weder repariert noch erneut importiert; [Einordnung](reference/p2b/README.md). Der Mock enthält keine verpflichtende Streckenanordnung oder Holzvorgabe für die Kappen. Bei der Figur ist die enge Annäherung an Proportionen, Haarvolumen, Hoodie und Schuhe ausdrücklich beauftragt.

Vergleichsbasis sind die unveränderten historischen 1440p-Bilder von `b236f17`: [Bereit](https://github.com/venomenon328/parkey/blob/b236f17d1d77c66736f54b8239d25337265d83ea/docs/evidence/p2b-fidelity/windows-1440/ready.png), [Alpha](https://github.com/venomenon328/parkey/blob/b236f17d1d77c66736f54b8239d25337265d83ea/docs/evidence/p2b-fidelity/windows-1440/alpha.png), [Beta](https://github.com/venomenon328/parkey/blob/b236f17d1d77c66736f54b8239d25337265d83ea/docs/evidence/p2b-fidelity/windows-1440/beta.png), [Ergebnis](https://github.com/venomenon328/parkey/blob/b236f17d1d77c66736f54b8239d25337265d83ea/docs/evidence/p2b-fidelity/windows-1440/result.png).

| Tatsächlich gerenderter Pass | Befund und nächste Korrektur |
| --- | --- |
| 1: [Bereit](evidence/p2b-fidelity/iterations/iteration-1/ready.png), [Alpha](evidence/p2b-fidelity/iterations/iteration-1/alpha.png), [Beta](evidence/p2b-fidelity/iterations/iteration-1/beta.png), [Ergebnis](evidence/p2b-fidelity/iterations/iteration-1/result.png) | Neue Silhouette/Kleidung nähert sich dem Mock deutlich an; Arbeitsplätze haben nun erkennbare Funktionen. Schilder waren spiegelverkehrt, Haarfurchen zu gleichmäßig, Kappenstruktur im flacheren Licht zu grob und Himmel zu dunkelblau. |
| 2: [Bereit](evidence/p2b-fidelity/iterations/iteration-2/ready.png) | Schilderausrichtung, feinere Normalen, hellerer Himmel und seitliche Überdachung verbessert. Die Figur blieb im Gesamtbild noch klein; danach Kamera moderat näher/niedriger und Haarfluss weniger regelmäßig. Senkrechte Holzmaserung ergänzt. |
| 3: [Alpha](evidence/p2b-fidelity/iterations/iteration-3/alpha.png) | Mehr Präsenz von Figur und Kappen, beide Alternativen weiterhin sichtbar. Alle 30 Kamerapositionen bestehen die Glyphenprojektion. Zusätzlich zeigt die [erste Front-Nahansicht](evidence/p2b-fidelity/iterations/portrait/character_front.png) aufgesetzte kapselartige Ponysträhnen. |
| Zusätzliche Materialiteration: [vorher](evidence/p2b-fidelity/iterations/iterations-before-worktop/alpha.png), [nachher](evidence/p2b-fidelity/windows-1440/alpha.png) | Gleiche Holztextur auf Boden und Stationen wirkte zu einheitlich. Eine eigene helle Leimholztextur trennt jetzt die Arbeitsflächen vom groben Dielenboden, auch in der normalen Spielkamera. |
| Finaler 1440p-Pass: [Bereit](evidence/p2b-fidelity/windows-1440/ready.png), [Alpha](evidence/p2b-fidelity/windows-1440/alpha.png), [Beta](evidence/p2b-fidelity/windows-1440/beta.png), [Ergebnis](evidence/p2b-fidelity/windows-1440/result.png) | Pony in die zusammenhängende Haaroberfläche integriert, Haarreflexe reduziert. [Front](evidence/p2b-fidelity/character/character_front.png) und [Rücken](evidence/p2b-fidelity/character/character_back.png) belegen die Modellkorrektur mit gesonderter Prüfkamera. Normale Kamera, schmale E-/W-Formate, Rückweg, Fehler und Ergebnis nochmals im Release geprüft. |

Die Figur ist dem Mock jetzt vor allem in Silhouette, Farbigkeit und Kleidung näher. Der Mock bleibt bei organischer Oberflächenmodellierung, Stofffalten, Materialnuancen und dichter Bildinszenierung weiter ausgearbeitet. Die eigene Bewertung ist keine ästhetische Nutzerfreigabe. Windows zeigt in nahen weichen Schatten noch feine Dithermuster; Web hat sichtbar einfachere Kanten-/Kontaktwirkung. Keine Bildretusche oder generiertes Ersatzrender.

## Unveränderte Verträge und Profile

P1-/P2a-Kern, Eingabeadapter, Kursdaten, Persistenz/Ranking, `WindowPacing`, Keycap-Geometrie und HUD-Verhalten bleiben unverändert. `besucht > erreichbar`, symbolfreie Statusdarstellung und rein visueller **0,13-/45-ms-Hub** gelten weiter. 50-/80-ms-Aufholbudgets, 200-ms-Fehlerfrist und exakte interne Mikrosekunden bleiben erhalten. Kamera und neue Dekoration verändern keine gewerteten räumlichen Daten. Identität aller Läufe:

`course-identity-v1:4dff5df394060f3ce5ffc236f6a9bef0a7e9d0a174b8f4d34308063c73e18e1a`

Forward+: Vulkan, 4× MSAA, ein Schattenwerfer (3,5°, Distanz 55), schattenloses Fülllicht, ACES, SSAO (0,65 / 1,5), SSIL (2 / 0,65) und drei kleine schattenlose Arbeitsleuchten. Compatibility: dieselben Modelle, Fonts, Materialkanäle und Pflichtsignale, ohne Schatten/SSAO/SSIL/MSAA, lineares Tonemapping. Kein Glow, DOF, SSR, volumetrischer Nebel oder Partikelsystem. Keine P3-Inhalte, neue Runtime-Abhängigkeit, Fremdmodelle oder neue Projektlizenz. Vorhandene CC0-/OFL-Assets und mitexportierte Lizenztexte bleiben erhalten; [Credits](../CREDITS.md) und [Quellmanifest](evidence/p2b-fidelity/source-manifest.json) sind aktualisiert.

## Technische Pflichtprüfungen

Auf Windows 11 Pro Build 26200 mit Godot `4.7.2.stable.official.ed1daf0bf` nach der finalen Runtime-Änderung tatsächlich ausgeführt:

| Befehl | Ergebnis |
| --- | --- |
| `godot --headless --path . --import` | [Exit 0](evidence/p2b-fidelity/import.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite presentation` | [553 Assertions, 0 Fehler](evidence/p2b-fidelity/presentation.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite integration` | [238 Assertions, 0 Fehler](evidence/p2b-fidelity/integration.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite all` | [1103 Assertions, 0 Fehler](evidence/p2b-fidelity/all.txt) |
| `godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe` | [Exit 0](evidence/p2b-fidelity/export-windows.txt) |
| `godot --headless --path . --export-release "Web" build/web/index.html` | [Exit 0](evidence/p2b-fidelity/export-web.txt) |

[Befehle/Exitcodes](evidence/p2b-fidelity/check-exits.json). [Fehlende](evidence/p2b-fidelity/negative-missing.txt) und [unbekannte](evidence/p2b-fidelity/negative-unknown.txt) Suite: erwarteter Exit 1. `node --check tests/serve_web_evidence.mjs` und `git diff --check` erfolgreich. Bestehende Kern-/Identitäts-/Hub-/Status-/Eingabe-/Rangregressionen bleiben erhalten; Figurenkontaktprüfung an die kürzeren Beine angepasst. Headless ist kein Grafiktest, Export kein Spieltest.

## Reale Renderbilder und normale Performance-Sanity-Prüfung

Ryzen 7 5800X / RTX 3070 auf dem genannten Windows-Rechner. Je Release-Konfiguration vier synthetische vollständige P2a-Routen über echte Viewport-Ereignisse und monotone Uhr, anschließend Entscheidungs-Idle: rund 32 Sekunden nach Aufwärmen. Screenshot-Readback liegt außerhalb der Messfenster. **Zwölf finale Routen fehlerfrei, unveränderte Identität, null Messframes ohne Fokus.** Keine persönlich gespielten Läufe. Normale FIFO-Initialisierung → Mailbox mit automatischem Monitorlimit unverändert; keine VSync-/FPS-/Driver-Diagnoseflags.

| Profil | Rendergröße | Ø FPS | p95 / p99 ms | Maximum ms | Frames >20 ms / gesamt |
| --- | --- | ---: | ---: | ---: | ---: |
| [Windows / Forward+, 1080p, 60-Hz-Monitor](evidence/p2b-fidelity/windows-1080/metrics.json) | 1920x1080 | 60.00 | 16.786 / 16.955 | 29.509 | 4 / 1940 |
| [Windows / Forward+, 1440p, 144-Hz-Monitor](evidence/p2b-fidelity/windows-1440/metrics.json) | 2560x1440 | 144.00 | 7.085 / 7.277 | 19.605 | 0 / 4649 |
| [Chrome / Compatibility](evidence/p2b-fidelity/web-chrome/metrics.json) | 2320x1305 | 59.95 | 16.900 / 17.100 | 20.100 | 1 / 1939 |

Keine offensichtliche massive Regression; die Werte liegen im bestehenden 60-FPS-Zielbereich. Einzelne Spitzen bleiben ausgewiesen, ohne erneute Ursachenforensik. 144 FPS sind kein neues Produktziel, und der Referenzrechner ist keine Mindesthardwarezusage. Windows-1440p: **616 Draw Calls / 983,880 gerenderte Primitive**; Chrome: **251 / 238,432**. Primitive zählen auch zusätzliche Renderpässe, keine eindeutigen Modelldreiecke.

Erstes Bild ab Engine-Start: Windows 1080p **2.354 s**, 1440p **2.415 s**. Chrome **7.217 s** ab Navigation; lokaler HTTP-Transfer, keine Internetladezusage. Chrome-Version **152.0.7977.76** (User-Agent im Bericht), echtes Desktopfenster. Der Nutzer öffnete den vorbereiteten lokalen Prüflauf; Eingaben und Bilder erzeugte danach der opt-in Helfer automatisch. Das ist keine physische Chrome-Eingabeabnahme.

| Zustand | Windows 1080p | Windows 1440p | Chrome |
| --- | --- | --- | --- |
| Bereit | [PNG](evidence/p2b-fidelity/windows-1080/ready.png) | [PNG](evidence/p2b-fidelity/windows-1440/ready.png) | [PNG](evidence/p2b-fidelity/web-chrome/ready.png) |
| Erste Entscheidung | [PNG](evidence/p2b-fidelity/windows-1080/alpha.png) | [PNG](evidence/p2b-fidelity/windows-1440/alpha.png) | [PNG](evidence/p2b-fidelity/web-chrome/alpha.png) |
| Besuchter Rückweg | [PNG](evidence/p2b-fidelity/windows-1080/visited_return.png) | [PNG](evidence/p2b-fidelity/windows-1440/visited_return.png) | [PNG](evidence/p2b-fidelity/web-chrome/visited_return.png) |
| Fehlerreaktion | [PNG](evidence/p2b-fidelity/windows-1080/error.png) | [PNG](evidence/p2b-fidelity/windows-1440/error.png) | [PNG](evidence/p2b-fidelity/web-chrome/error.png) |
| Zweite Entscheidung | [PNG](evidence/p2b-fidelity/windows-1080/beta.png) | [PNG](evidence/p2b-fidelity/windows-1440/beta.png) | [PNG](evidence/p2b-fidelity/web-chrome/beta.png) |
| W / schmale Formate | [PNG](evidence/p2b-fidelity/windows-1080/beta_long.png) | [PNG](evidence/p2b-fidelity/windows-1440/beta_long.png) | [PNG](evidence/p2b-fidelity/web-chrome/beta_long.png) |
| Ergebnis | [PNG](evidence/p2b-fidelity/windows-1080/result.png) | [PNG](evidence/p2b-fidelity/windows-1440/result.png) | [PNG](evidence/p2b-fidelity/web-chrome/result.png) |
| F3 | [PNG](evidence/p2b-fidelity/windows-1080/debug.png) | [PNG](evidence/p2b-fidelity/windows-1440/debug.png) | [PNG](evidence/p2b-fidelity/web-chrome/debug.png) |

## Gezielte Evidenzbereinigung

Das bisherige Set umfasste **325 Dateien / 168,30 MiB**, darunter **27 CSV-Traces und 88 PNGs**. Das aktuelle Set hat **51 Dateien / 92,31 MiB** (überwiegend PNGs): 24 aktuelle Spielbilder, zwei Modellansichten, acht ausgewählte Iterationsbilder, kompakte finale Sanity-Berichte, Pflichtlogs und ein aktuelles Manifest. Keine neuen ETW-/PresentMon-Traces. [Umfang und Aufbewahrungsregel](evidence/p2b-fidelity/retention.json).

[pacing-baseline.json](evidence/p2b-fidelity/pacing-baseline.json) erhält **zwölf ausgewählte historische JSON-Berichte** aus `b236f17`: fünf finale Windows-/Web-Zusammenfassungen, beide normalen Present-Zusammenfassungen und fünf gezielte Gegenproben. Die zusammengefassten Werte sind unverändert; nur Einzel-Frameintervalle und Routenlisten wurden ausgelassen. Die alte FIFO-Unruhe bei vorhandenem GPU-Headroom sowie die Begründung für FIFO-Initialisierung, Mailbox und Monitorlimit bleiben nachvollziehbar. Auch die widersprüchlichen Display-Change-Werte bleiben ausdrücklich erhalten: Sie sind auf diesem gemischten Monitor-Desktop kein optischer Scanoutnachweis. Keine erneute Messung oder Treibergarantie.

Experimentelle Zwischen-CSV/Logs, doppelte ältere Bildreihen und veraltete Manifeste entfallen aus dem aktuellen Baum. Vollständige damalige Rohdaten und Bericht bleiben über den [unveränderten Git-Ausgangspunkt](https://github.com/venomenon328/parkey/tree/b236f17d1d77c66736f54b8239d25337265d83ea/docs/evidence) abrufbar; keine Historienumschreibung. Aktuelles Manifest: normalisierte UTF-8/LF-Quellhashes, Binärhashes von Assets/Exporten und originalen PNGs samt Pixelmaßen. Der externe Mock erhält keinen erfundenen Datei-Hash.

## Offene manuelle Abnahmegates

**Subjektive Nutzerabnahme von Look, Figur, Animation, Lesbarkeit und Spielgefühl sowie ein persönlich gespielter vollständiger Windows-Lauf bleiben ausdrücklich offen.** Auf beiden Monitoren zusätzlich sichtbares Stottern/Bildreißen beurteilen. Die ältere physische P1b-Chrome-Eingabeabnahme bleibt separat offen; schwächere Mindesthardware ist ungeprüft. PR #18 bleibt Draft, kein Merge.

Nächster abgegrenzter Schritt: den normalen Windows-Release persönlich spielen und den neuen Look abnehmen; insbesondere beide Entscheidungen, Rückweg, Press/Halten/Loslassen, Fehler, Timer/F3 und Ziel. [Reproduktion](development.md#p2b-grafikprüfung-reproduzieren).
