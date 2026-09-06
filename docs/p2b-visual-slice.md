# P2b: große visuelle Näherungsrunde

Stand: 2026-09-06. Umsetzung der [neuesten verbindlichen Nacharbeit in Issue #6](https://github.com/venomenon328/parkey/issues/6#issuecomment-5560268276), ausgehend von `26551462312a8518d43268d6bf66b5bd5e20a310`, auf `codex/p2b-visual-slice` im bestehenden [Draft-PR #18](https://github.com/venomenon328/parkey/pull/18). **Die subjektive Nutzerabnahme ist weiterhin offen.**

## Referenzvergleich und echte Iteration

Die [Referenzeinordnung](reference/p2b/README.md), der im Auftrag erneut lesbar angehängte Original-Mock und die bisherigen P2b-Bilder wurden visuell geprüft. Die versionierte JPEG-Kopie ist weiterhin beschädigt; sie wurde weder als repariert noch als tatsächlich decodierte Referenz ausgegeben. Der Anhang ist der geprüfte Mock. Er bestimmt die Qualitätsrichtung: zusammenhängende gerundete Kappen, oberflächengebundene Schrift, heller Wolkenraum, räumliche Tiefe und dominanter Timer. Bestätigter warmer matter Kunststoff, Werkstattwelt und kanonischer Kurs bleiben erhalten; Holz und Mock-Streckenanordnung sind keine Pflicht.

Die Nacharbeit umfasst acht Windows-Entwicklungsiterationen, zusätzliche Compatibility-/Chrome-Farbprüfung und anschließende Releaseprüfungen. Sie wurde nach grünen Geometrietests mehrfach erneut geändert:

| Bildprüfung | Befund und folgende Korrektur |
| --- | --- |
| Erster neuer Pass: [Bereitschaft](evidence/p2b/iterations/iteration-1/ready.png), [erste Entscheidung](evidence/p2b/iterations/iteration-1/alpha.png), [Ergebnis](evidence/p2b/iterations/iteration-1/result.png) | Neue Schale, Schriften und HUD waren sichtbar; der erste Himmel war überbelichtet und die Umgebung zu teuer. Auf Tages-HDR umgestellt, Belichtung/Abtastrichtung abgestimmt und statische Möbel nach Material gebündelt. |
| Zweiter/dritter Pass | Die Bildprüfung entdeckte fehlende Möbel beim Zusammenführen gemischt indizierter Meshes. Einheitliches Deindizieren vor dem Zusammenführen korrigiert die Geometrie. Der sichtbare Wolkenraum ersetzt die unpassende dunkle Panorama-Unterseite. |
| Vierter Pass: [W/E-Abschnitt](evidence/p2b/iterations/iteration-4/beta_long.png) | Verbessertes Licht und weichere Kappen, aber die Figur berührte eine folgende Legende. Reine Legendverschiebung im fünften Pass verschlechterte die Verdeckung und wurde verworfen. |
| Sechster Pass: [höhere Kamera](evidence/p2b/iterations/iteration-6/beta_long.png) | Höhere Sicht allein beseitigte die Berührung nicht ausreichend. Der siebte Pass kombiniert moderate Höhe mit kleinem Schulterversatz und korrigiertem Druckbereich. |
| Finaler Windows-1440p-Release | [Bereitschaft](evidence/p2b/windows-1440/ready.png), [erste Entscheidung](evidence/p2b/windows-1440/alpha.png), [W/E](evidence/p2b/windows-1440/beta_long.png) und [Ergebnis](evidence/p2b/windows-1440/result.png) erneut geprüft. A sowie E/W sind unterscheidbar, beide Entscheidungen vollständig lesbar, Ergebnis rechts neben der Figur. Abschließend HUD-Flächen für ruhigeren Kontrast verdichtet. Die achte Iteration setzt die ergänzende Nutzerentscheidung um: durchgehender texturierter Werkstattboden unter den Stationen, Pflanzen auf den Schrankplatten statt frei daneben sowie keine zusätzlichen Start-/Ziel-/Bodenschriftzüge. |

Direkter Vergleich zum **unmittelbaren Vorstand `2655146`**: [Bereitschaft vorher](https://github.com/venomenon328/parkey/blob/2655146/docs/evidence/p2b/windows-1440/ready.png), [Entscheidung vorher](https://github.com/venomenon328/parkey/blob/2655146/docs/evidence/p2b/windows-1440/alpha.png), [Ergebnis vorher](https://github.com/venomenon328/parkey/blob/2655146/docs/evidence/p2b/windows-1440/result.png). Die aktuellen Gegenstücke stehen in der letzten Tabellenzeile. Die Kappen besitzen jetzt einen glatten gemeinsamen Schulterverlauf statt sichtbarer Materialringe, die explizite Schrift wirkt ruhiger, die niedrigere Kamera gibt den Kappen mehr Vordergrundpräsenz und der größere Timer bestimmt die UI-Hierarchie. Der Abstand zum aufwendig illustrierten Mock bleibt bei Figurdetail und Umgebungsdichte sichtbar; Gleichwertigkeit oder Nutzerfreigabe wird nicht behauptet.

## Umsetzung und erhaltene Verträge

- **Kappen:** durchgehend gesampelte Form mit verjüngten Wänden, runder Schulter und flacher Mulde. Gemeinsame Normalen entstehen vor der Materialtrennung am unteren Rand. Standard-, schmale, lange und Spacebar-artige Formate behalten exakt ihre kanonischen Grundflächen. Kontrollierte Rauheit und dezente 128×128-Normalstruktur ergänzen die matte Materialantwort.
- **Legenden:** versioniertes Barlow Medium, dunkle beleuchtete Druckfarbe ohne Outline. Tatsächliche Glyphenmaße bestimmen Skalierung und Randabstand innerhalb der flachen Topfläche; keine schwebenden Callouts. Punkte, Haken und Rauten sind vollständig entfernt. Material, Figur und Hub erhalten `besucht > erreichbar`.
- **Kamera:** Höhe 4,7 statt 6,2, Abstand 7,4, normaler Vorblick 3,4, Schulterversatz 1,0. An Entscheidungen bleibt der Mittelpunkt der bestehenden Vorschauabschnitte maßgeblich. Keine Mauspflicht; unveränderte 50-/80-ms-Aufholbudgets.
- **Welt/Licht:** versioniertes 2K-CC0-HDR, abgestimmter Himmels-Shader, Werkstattschränke, Regale, Messinggeländer, Drehknöpfe/Kabel, Pflanzen und Zielportal. Ein zusammenhängender Dielenboden trägt die Seitenstationen, die Pflanzen stehen auf den Schrankplatten. Keine freien Start-/Zieltexte oder Boden-Schriftzüge. Dekoration liegt außerhalb beziehungsweise unterhalb der kanonischen Strecke und unterliegt keiner Begehbarkeit. Gegliederte Figur mit feineren Rundungen, Kragen, Ärmel- und Schuhdetails; Posenvertrag unverändert.
- **HUD:** eigener Barlow-Semi-Condensed-Timer mit Stoppuhr; Ergebnis-/Top-10-Zeilen mit getrenntem Rang, Zeit und Fehlerzahl. Normale Zeiten ausschließlich `MM:SS.mmm`; exakte Mikrosekunden bleiben in Sortierung, Persistenz und F3. Speicherstatus und Hinweis auf nicht aufbewahrte Läufe bleiben sichtbar.

Unverändert: 30-Feld-P2a-Kurs, explizite Nachbarn/Transitionen, Größen/Positionen/Drehungen/Standpunkte, Kernzeiten und Eingabeannahme. Identität weiterhin `course-identity-v1:4dff5df394060f3ce5ffc236f6a9bef0a7e9d0a174b8f4d34308063c73e18e1a`. Keine Änderung in `scripts/core`, `scripts/input`, `scripts/course` oder `scripts/storage`. Der rein visuelle Hub bleibt 0,13 Einheiten innerhalb 45 ms, Halten bis zum logischen Verlassen und sofortiger Reset. Eine laufende Fehleranimation blockiert keine nach der 200-ms-Kernfrist gültige Eingabe. Keine P3-Inhalte oder zusätzliche Spielimplementierung.

## Profile, Assets und Budget

Forward+: 4× MSAA, ein weich gefilterter Schattenwerfer, schattenloses Fülllicht, ACES und SSAO mit Radius 0,85/Intensität 1,35. Compatibility: dieselbe Geometrie, Schrift, Statusmaterialien und derselbe Himmel, ohne Schatten/SSAO/MSAA und mit linearem Tonemapping. Kein Glow, DOF, SSR, volumetrischer Nebel oder Partikelsystem; Pflichtinformationen hängen nicht von optionalen Effekten ab.

Barlow Medium und Barlow Semi Condensed SemiBold stehen unter OFL 1.1; das unveränderte Poly-Haven-HDR „Kloofendal 48d Partly Cloudy Pure Sky“ unter CC0. Die kleinen Fontdateien und das 2048×1024-HDR sind versioniert. Der Sky-Shader passt die Abtastrichtung für die schwebende Werkstatt an und konvertiert im Compatibility-Profil die lineare HDR-Ausgabe nach sRGB. Die echte Compatibility-/Chrome-Prüfung entdeckte vorher einen zu dunklen Himmel ([Zwischenbild](evidence/p2b/iterations/compatibility-before/ready.png)); die Farbtexturkennzeichnung allein genügte nicht. Die abschließende Farbkonvertierung behebt diesen Profilunterschied. Keine Laufzeit-Wolkenmalerei, Downloads, Dienste oder Bibliotheken. Eigene Modelle, deterministische Dielentextur und Materialstrukturen; Quellen, Autoren und mitexportierte Lizenztexte: [CREDITS.md](../CREDITS.md). Die Projektlizenz bleibt unbestimmt.

Der in #6 erlaubte Forward+-Headroom wird für feinere Meshes, Kontaktwirkung und Kantenglättung genutzt. Der frühere 100.000-Primitiven-Richtwert wird deshalb bewusst ersetzt: Arbeitsbudget dieses Slices **unter 600 Draw Calls / 450.000 gerenderten Primitiven** im Windows-Entscheidungsbild, bei unverändertem 60-FPS-Ziel. Die Zähler enthalten Render-/Schattenpässe, nicht nur eindeutige Meshdreiecke. Statische Möbel teilen Materialmeshes; bewegliche Kappen bleiben unabhängig. Gemessene Zahlen stehen unten. 144 FPS werden nicht zum Produktziel.

## Technische Prüfungen

Tatsächlich unter Windows 11 Pro Build 26200 mit Godot `4.7.2.stable.official.ed1daf0bf` ausgeführt:

| Pflichtbefehl | Ergebnis / Log |
| --- | --- |
| `godot --headless --path . --import` | [Exit 0, keine Import-/Scriptfehler](evidence/p2b/import.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite presentation` | [485 Assertions, 0 Fehler](evidence/p2b/presentation.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite integration` | [238 Assertions, 0 Fehler](evidence/p2b/integration.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite all` | [1035 Assertions, 0 Fehler](evidence/p2b/all.txt) |
| `godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe` | [Exit 0](evidence/p2b/export-windows.txt) |
| `godot --headless --path . --export-release "Web" build/web/index.html` | [Exit 0](evidence/p2b/export-web.txt) |

[Exitübersicht](evidence/p2b/check-exits.json). Fehlende/unbekannte Suite: erwarteter [Exit 1](evidence/p2b/negative-exits.json). `node --check tests/serve_web_evidence.mjs` erfolgreich. Der vollständige vorgemerkte Diffcheck meldet ausschließlich ein bereits im unverändert übernommenen OFL-Lizenztext enthaltenes Schlussleerzeichen (Zeile 21); ohne diese Fremdtextdatei ist er sauber.

Neue Regressionen prüfen symbolfreie Felder, explizite Fontressourcen, reale gedrehte Glyphen innerhalb der Topflächen und vollständige Projektion des aktuellen Felds sowie aller direkten Nachbarn an allen 30 Kamerapositionen. Das ist kein Verdeckungstest; die tatsächlichen W/E-Bilder haben deshalb zusätzliche Korrekturen ausgelöst. Die volle Top-10-Tabelle einschließlich Bestzeitmeldung passt in den Viewport. Unterschiedliche Originalzeiten 1.234.000/1.234.999 µs behalten trotz gleicher Anzeige `00:01.234` ihre korrekten Ränge und F3-Werte. Bestehende Identitäts-, Hub-, Status-, Eingabe-/Timing-, Speicher- und Routenprüfungen bleiben erhalten. Hochfrequenzregression: maximal 2,738, durchschnittlich 0,459 Welteinheiten Restweg, 0,000 s Restaufholen, keine Figurenkorrektur; 60 Eingaben ohne Renderfortschritt bleiben wirksam.

## Reale Render- und Leistungsnachweise

Gemessen am 2026-09-06 auf Windows 11 Pro Build 26200, Ryzen 7 5800X, RTX 3070, Treiber 32.0.15.9649. Native Releasefenster verwenden Forward+ auf Bildschirm 0 bei gemeldeten 143,973 Hz; zusätzlich ist ein 60-Hz-Bildschirm angeschlossen. Chrome 152.0.7977.76 (UA 152.0.0.0) verwendet WebGL Compatibility. Der Browser wurde durch den Nutzer geöffnet und für den korrigierten Export neu geladen. Sein Canvas misst 2560×1305, der tatsächlich gerenderte Spielviewport und alle acht PNGs 2320×1305.

Vier synthetische Vollrouten mit echten Viewport-Ereignissen und monotoner Laufzeituhr, anschließend 15 Sekunden am Entscheidungsfeld: je rund 32 Sekunden Anwendungsframeabstände nach Aufwärmen, einschließlich Bewegung und Ergebnis-I/O. Screenshot-Readback liegt außerhalb der Messfenster. Alle vier Routen in allen finalen Messreihen erreichen das Ziel mit null Fehlern und derselben kanonischen Identität; **null Messframes ohne Fokus**. Ein vorheriger Fokusverlust invalidierte einen Wiederholungslauf; dieser wurde verworfen und nicht als Leistungsnachweis verwendet. Keine externe Scanout-/Hardwarelatenzmessung und kein persönlich gespielter Lauf.

| Profil | Spielviewport | Frames / Messzeit | Ø FPS | p95 / p99 ms | Maximum ms | Frames >20 / >33,334 ms |
| --- | --- | --- | --- | --- | --- | --- |
| Windows 1080p / normal | 1920x1080 | 1940 / 32,35 s | 59,97 | 20,941 / 21,310 | 30,725 | 574 / 0 |
| Windows 1440p / normal | 2560x1440 | 4623 / 32,32 s | 143,06 | 8,289 / 8,666 | 18,406 | 0 / 0 |
| Chrome / Compatibility | 2320x1305 | 1940 / 32,36 s | 59,95 | 16,900 / 17,000 | 20,200 | 1 / 0 |
| Windows 1080p / VSync-Diagnose | 1920x1080 | 4654 / 32,32 s | 144,01 | 7,094 / 7,299 | 19,066 | 0 / 0 |

Windows zählt am ersten Entscheidungsfeld 477 Draw Calls / 395.094 gerenderte Primitive, Chrome 200 / 126.710; die Budgets sind eingehalten. Die hohe native Bildrate ist gemessener Headroom, kein neues Produktziel.

**1080p-Taktungsgrenze:** Mit unverändertem Standard-VSync erreicht das Fenster im Mittel etwa 60 FPS, zeigt aber deutlich ungleichmäßigere Frameabstände als 1440p und Chrome. Ein gleichmäßiger 16,7-ms-Takt ist damit für diese Fensterkonfiguration nicht belegt. Derselbe Export ohne VSync und mit explizitem 144-FPS-Diagnoselimit erreicht 144,01 FPS bei p99 7,299 ms. Das spricht für einen Einfluss der Fenster-/Displaysynchronisation; es beweist keine alleinige Ursache. Keine VSync-Projekteinstellung wurde geändert und die Diagnose ersetzt den normalen Nachweis nicht. [Diagnoserohdaten](evidence/p2b/windows-1080-vsync-diagnostic/metrics.json), [Laufprotokoll](evidence/p2b/windows-1080-vsync-diagnostic/render.txt). Diese Grenze bleibt bei der persönlichen Windows-Abnahme zu prüfen.

Erstes tatsächlich gerendertes Bild ab Engine-Start: Windows 1080p 2,258 s, 1440p 2,354 s. Chrome ab Navigation 3,094 s; gesamte Browserprüfung einschließlich Aufwärmen, PNG-Übertragung und Messung 49,66 s. Lokaler HTTP-Transfer: WASM 39.515.054 Bytes in 97,5 ms, PCK 9.227.956 Bytes in 18,4 ms. Das sind Loopback-Ladebeobachtungen dieses Rechners, keine Internetladezeit oder Mindesthardwarezusage.

### Versionierte Belege

[Quellmanifest](evidence/p2b/source-manifest.json): SHA-256 über UTF-8/LF für Laufzeit-/Prüfquellen, Binärhashes für Assets, Releaseartefakte und finale PNGs. Die frühen Iterationsbilder sind ausdrücklich Zwischenstände; die drei folgenden finalen Bildordner gehören zum manifestierten Quellstand. PNG-Größen werden aus den Bildheadern kontrolliert; keine nachbearbeiteten Ersatzbilder.

Rohdaten: [Windows 1080p](evidence/p2b/windows-1080/metrics.json), [Windows 1440p](evidence/p2b/windows-1440/metrics.json), [Chrome](evidence/p2b/web-chrome/metrics.json). Native Laufprotokolle: [1080p](evidence/p2b/windows-1080/render.txt), [1440p](evidence/p2b/windows-1440/render.txt).

| Zustand | Windows 1080p | Windows 1440p | Desktop-Chrome |
| --- | --- | --- | --- |
| Bereitschaft | [PNG](evidence/p2b/windows-1080/ready.png) | [PNG](evidence/p2b/windows-1440/ready.png) | [PNG](evidence/p2b/web-chrome/ready.png) |
| Erste Entscheidung | [PNG](evidence/p2b/windows-1080/alpha.png) | [PNG](evidence/p2b/windows-1440/alpha.png) | [PNG](evidence/p2b/web-chrome/alpha.png) |
| Besuchter Rückweg | [PNG](evidence/p2b/windows-1080/visited_return.png) | [PNG](evidence/p2b/windows-1440/visited_return.png) | [PNG](evidence/p2b/web-chrome/visited_return.png) |
| Fehlerreaktion | [PNG](evidence/p2b/windows-1080/error.png) | [PNG](evidence/p2b/windows-1440/error.png) | [PNG](evidence/p2b/web-chrome/error.png) |
| Zweite Entscheidung | [PNG](evidence/p2b/windows-1080/beta.png) | [PNG](evidence/p2b/windows-1440/beta.png) | [PNG](evidence/p2b/web-chrome/beta.png) |
| W und schmale Formate | [PNG](evidence/p2b/windows-1080/beta_long.png) | [PNG](evidence/p2b/windows-1440/beta_long.png) | [PNG](evidence/p2b/web-chrome/beta_long.png) |
| Ergebnis | [PNG](evidence/p2b/windows-1080/result.png) | [PNG](evidence/p2b/windows-1440/result.png) | [PNG](evidence/p2b/web-chrome/result.png) |
| Entwickleransicht | [PNG](evidence/p2b/windows-1080/debug.png) | [PNG](evidence/p2b/windows-1440/debug.png) | [PNG](evidence/p2b/web-chrome/debug.png) |

Die Sichtprüfung umfasst alle acht Zustände: Kappenform, Standard-/schmale/lange Legenden, Alternativen vor beiden Entscheidungen, besuchten Rückweg, Hub, Fehler, Ergebnis/F3 und Himmel-/Timer-Hierarchie. Die reduzierte Webbeleuchtung bleibt bewusst einfacher. Referenznahe Qualitätsmerkmale wurden umgesetzt; die eigene Sichtprüfung ist keine ästhetische Freigabe durch den Nutzer.

## Offene Abnahmegates

**Subjektive Nutzerabnahme von Look, Figur, Animation, Lesbarkeit und Spielgefühl sowie ein persönlich gespielter vollständiger Windows-Lauf bleiben ausdrücklich offen.** Synthetische Vollrouten ersetzen beides nicht. PR #18 bleibt Draft, kein automatischer Merge. Die ältere physische P1b-Chrome-Eingabeabnahme bleibt separat offen. Ohne reale schwächere Testmaschine bleibt die Mindesthardware unbestimmt.

Nächster klar begrenzter Schritt: `build/windows/parkey.exe` ohne Prüfargument starten, beide Entscheidungen/Rückweg, Press/Halten/Loslassen, Fehler, Timer/F3 und einen vollständigen Lauf persönlich prüfen. Technische Reproduktion: [development.md](development.md#p2b-grafikprüfung-reproduzieren).

Technische Primärquellen, geprüft 2026-09-06; ausgeführt mit der lokal gepinnten Engine: [SurfaceTool](https://docs.godotengine.org/en/stable/classes/class_surfacetool.html), [Environment](https://docs.godotengine.org/en/stable/classes/class_environment.html), [Sky-Shader](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/sky_shader.html). Tatsächliche Profil-/Laufbelege haben Vorrang vor allgemeinen Enginebeschreibungen.
