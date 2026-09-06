# P2b: Tastatur-Werkstatt – visuelle Nacharbeit

Stand: 2026-09-06. [Issue #6](https://github.com/venomenon328/parkey/issues/6), Branch `codex/p2b-visual-slice`, bestehender [Draft-PR #18](https://github.com/venomenon328/parkey/pull/18). Die erste visuelle Nutzerprüfung hat **keine Abnahme erteilt**. Die verbindliche Nacharbeit ist umgesetzt und technisch/renderseitig geprüft; die erneute subjektive Nutzerabnahme bleibt offen.

## Referenzvergleich und Renderiteration

Vor Änderungen wurden die bisherigen Windows-/Web-Bilder, die [Einordnung der Referenz](reference/p2b/README.md) und der erneut im Auftrag angehängte lesbare Original-Mock visuell miteinander verglichen. Die versionierte JPEG-Kopie ist beschädigt; zwei Decoder scheitern am identischen lokalen/GitHub-Blob. Sie wird nicht als repariert ausgegeben. Der nachgereichte Originalanhang ist die tatsächlich geprüfte Bildreferenz. `.gdignore` schließt Referenzen vom Spielimport aus.

Der Mock zeigt weich gerundete massive Kappen, zurückhaltende oberflächengebundene Legenden, einen hellen bewölkten Himmel und einen dominierenden mittigen Timer mit Stoppuhr. Er ist qualitative Orientierung; Holzmaterial, Streckenanordnung, Figur und Bestenlistenlayout werden nicht kopiert. Die Werkstatt mit Petrol, Messing und warmen matten Kunststoffkappen bleibt die einzige Beispielwelt.

| Kritik / Referenzmerkmal | Nacharbeit und eigene Sichtprüfung |
| --- | --- |
| Zusammengesetzte Blöcke statt Keycaps | Nach außen gewickelte Seitenflächen, verjüngte Kappenschale, weiche Schulter und flache Mulde. Schale und Top teilen die Naht; keine aufgestapelte Deckplatte. Auch Werkstattkörper besitzen jetzt von außen sichtbare Seiten. Die Kappen lesen sich im Render als geformte Tasten einschließlich langer Formate. |
| Überlaufende weiße Overlay-Legenden | Kleinere dunkle Druckfarbe ohne Outline, mit Oberflächenbeleuchtung. Schriftmetriken bestimmen Größe je Format; Platzierung mit Randabstand links vor der Figur. Alle 30 tatsächlichen gedrehten Glyphen-AABBs liegen innerhalb der flachen Topfläche. Nahbilder beider Entscheidungen und des W ergänzen die Startansicht. Kein sichtbarer Überlauf über die Kappenschulter in den geprüften Bildern. |
| Flacher Platzhalterhorizont | Eigenes deterministisches Wolkenpanorama mit Farbverlauf und unterer Dunstzone; die große neutrale Bodenfläche ist ausgeblendet. Die Werkbank steht im hellen Himmelsraum. Distanznebel übermalt das Panorama nicht mehr. |
| Technische Timerwirkung | Timer oben mittig, kräftigere Schrift, eigenes skalierendes Stoppuhr-Symbol, kleinere Status-/Fehlerzeile auf halbtransparenter Fläche. Werkstattname und Bedienhilfe sind nachgeordnet; Diagnosen bleiben F3. |

Direkter Vorher-/Nachher-Vergleich derselben ersten Entscheidung: [bisheriger Stand 792fc39](https://github.com/venomenon328/parkey/blob/792fc39/docs/evidence/p2b/windows-1080/alpha.png) → [neuer Windows-Render](evidence/p2b/windows-1080/alpha.png). Die großen weißen Zeichen, flachen/offenen Seiten und der einfarbige Hintergrund des alten Bildes sind damit konkret vergleichbar.

Die Arbeit erfolgte in echten Renderiterationen: zuerst Schale/Typografie/Timer, anschließend Himmelkorrektur nach noch zu blassem Render und zuletzt ein weiterer Placement-/Größenpass nach den Nahbildern schmaler Tasten. Die eigene technische Sichtprüfung ersetzt ausdrücklich keine ästhetische Freigabe durch den Nutzer.

## Erhaltene Verträge

- Unveränderter 30-Feld-P2a-Kurs, explizite Übergänge, Grundflächen, Größen, Positionen, Drehungen, Standpunkte und Kamera. Fasen/Mulde liegen innerhalb der kanonischen Grundflächen; keine neue Höhenmechanik.
- Kanonische Identität weiterhin `course-identity-v1:4dff5df394060f3ce5ffc236f6a9bef0a7e9d0a174b8f4d34308063c73e18e1a`. Keine Änderungen in `scripts/core`, `scripts/input`, `scripts/course` oder `scripts/storage`.
- Press-/Hold-/Release unverändert: 0,13 Einheiten Hub innerhalb von 45 ms, Halten bis zum logischen Verlassen, gemeinsamer Hub von Kappe/Druckzeichen/Status; fester Sockel und sofortiger Restart. Keine Eingabesperre durch Grafik.
- Besuchte Rückwege bleiben dunkel mit Haken, auch wenn sie erreichbar sind. Das aktuelle Feld hat Punkt/Haken und sichtbaren Hub; nur unbesuchte erreichbare Felder werden heller und zeigen eine Raute. Keine Änderung der Statuspriorität.
- Gegliederte Figur mit Idle/Bewegung/Fehlerreaktion unverändert. 50-ms-Figuren-/80-ms-Kamera-Aufholen und 200-ms-Kernfehlerfrist bleiben erhalten; eine laufende 240-ms-Reaktion blockiert keine danach gültige Eingabe.
- Timer, Original-Mikrosekunden, lokale Bestzeiten/Top 10 und Speicherstatus bleiben verfügbar. Keine Onlinewertung, P3-Inhalte, zusätzliche Welt oder neue Laufzeitabhängigkeit.

## Profile und Assets

Windows Forward+: ein schattenwerfendes Hauptlicht, schattenloses Fülllicht, 2× MSAA und begrenztes SSAO (Radius 0,5, Intensität 0,65). Web Compatibility: dieselbe Geometrie, Legenden, Statuszeichen und Umgebung ohne Schatten/SSAO/MSAA. Kein Bloom, DOF, SSR, volumetrischer Nebel oder Partikelsystem. Pflichtinformationen benötigen keinen Windows-Effekt.

Das 1024×512-Wolkenpanorama wird einmal beim Start aus sphärischem FastNoiseLite-Rauschen erstellt und innerhalb des Prozesses wiederverwendet; kein pro Frame laufender Noise-Shader. Die vorhandene eigene 64×64-Rauheitsstruktur bleibt erhalten. Modelle, Panorama, Materialien und Stoppuhr-Zeichenbefehle sind eigener Repository-Code. Schrift: vorhandenes Open Sans SemiBold mit Laufzeit-Schriftvariation für den Timer; keine neue Fontdatei. Quellen und Lizenzhinweise stehen in [CREDITS.md](../CREDITS.md); die Projektlizenz bleibt offen.

## Technische Prüfungen

Unter Windows 11 Pro Build 26200 mit Godot `4.7.2.stable.official.ed1daf0bf` tatsächlich ausgeführt:

| Prüfung | Ergebnis / Log |
| --- | --- |
| `godot --headless --path . --import` | [Exit 0](evidence/p2b/import.txt), keine Import-/Scriptfehler |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite presentation` | [298 Assertions, 0 Fehler](evidence/p2b/presentation.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite integration` | [233 Assertions, 0 Fehler](evidence/p2b/integration.txt) |
| `godot --headless --path . --script res://tests/run_tests.gd -- --suite all` | [843 Assertions, 0 Fehler](evidence/p2b/all.txt) |
| `godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe` | [Exit 0](evidence/p2b/export-windows.txt) |
| `godot --headless --path . --export-release "Web" build/web/index.html` | [Exit 0](evidence/p2b/export-web.txt) |

[Exitübersicht](evidence/p2b/check-exits.json). Unbekannte Suite und fehlender Suitename scheitern erwartungsgemäß mit [Exit 1](evidence/p2b/negative-exits.json). `node --check tests/serve_web_evidence.mjs` und `git diff --check` sind erfolgreich.

Neue Regressionen prüfen die tatsächlichen gedrehten Glyphenmaße aller Felder, beleuchtete Druckschrift ohne Outline, nach außen gewickelte Seiten mit passenden Normalen und einen vorhandenen, nicht von Nebel übermalten Himmel in beiden Profilen. Die bestehende Szenen-/Hub-/Status-/F3-/Timingprüfung bleibt erhalten. Der Integrationstest folgt der neuen Timer-Hierarchie im tatsächlichen SceneTree. Hochfrequenzregression: maximal 2,738 und im Mittel 0,459 Welteinheiten Restweg, 0,000 s Restaufholen, keine Figurenkorrektur; 60 Eingaben ohne Renderfortschritt bleiben wirksam.

## Reale Render-, Lauf- und Leistungsnachweise

Tatsächlicher Rechner: AMD Ryzen 7 5800X, NVIDIA GeForce RTX 3070, Windows 11 Pro 26200, Treiber `32.0.15.9649`. Native Fenster melden 143,973 Hz. Es wurde keine schwächere Hardware geprüft; der Referenzrechner ist keine Mindestanforderung.

Die Releaseexporte laufen mit echten Renderern und realer Uhr. Der ausdrücklich aktivierte Helfer erzeugt synthetische Viewport-Tastaturereignisse und speichert ausschließlich unter `user://parkey-test-results/`. Pro Plattform/Auflösung werden alle vier P2a-Kombinationen vollständig abgeschlossen. Die acht Bildzustände liegen außerhalb der Leistungsmessfenster; gemessen werden rund 32 Sekunden aus vier Routen bei 160-ms-Eingabeabstand und 15 Sekunden an der ersten Entscheidung nach Aufwärmen. Das sind Anwendungsframeabstände, keine GPU-only-, Scanout- oder Hardwareeingabelatenzen.

Verdeckte native Vorproben liefen nur mit etwa 60 FPS und unruhigeren Frameabständen. Sie werden nicht als Vordergrundleistungsnachweis verwendet. Die folgenden finalen nativen Proben stammen aus sichtbar geöffneten Spielfenstern. Der automatische Chrome-Start über die Shell wurde mit „blocked by policy“ abgelehnt; der Nutzer öffnete den lokalen Prüflink in Desktop-Chrome, anschließend erzeugte der Helfer selbst Bilder und Messwerte. Das Öffnen ist keine subjektive Abnahme.

| Reale Ausführung | Framebuffer | Ø FPS | p95 / p99 / Maximum (ms) | Messdauer | Erster Frame |
| --- | --- | --- | --- | --- | --- |
| Windows Forward+ | 1920×1080 | 143,97 | 8,188 / 8,437 / 18,218 | 32,285 s | 1938,0 ms |
| Windows Forward+ | 2560×1440 | 143,98 | 8,102 / 8,372 / 18,037 | 32,297 s | 2021,0 ms |
| Desktop-Chrome Compatibility | 2320×1305 | 59,95 | 16,900 / 17,000 / 18,900 | 32,360 s | 4795,1 ms |

Alle drei finalen Proben schließen alle vier Routen mit null Fehlern ab. Windows enthält bei beiden Auflösungen keinen Frame über 20 ms; das 60-FPS-Ziel wird unter diesen dokumentierten Bedingungen erfüllt. Windows: 645 Draw Calls / 79.840 Primitive. Chrome: 256 Draw Calls / 28136 Primitive, 0 Frames über 20 ms und 0 über 33,334 ms. Das Szenenbudget von unter 800 Draw Calls / 100.000 Primitiven bleibt eingehalten.

Browserkennung des finalen Laufs: `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36`. Tatsächlicher Canvas: 2560×1305; der Spielviewport ist oben separat angegeben. Der Webadapter meldet nur `WebKit WebGL`. Lokaler HTTP-Transfer mit deaktiviertem HTTP-Cache; Startzeiten enthalten Initialisierung einschließlich Panoramaberechnung, aber keinen behaupteten kalten Treiber-/Dateicache. Keine Aussage über Internetladezeiten oder beliebige Hardware. Einzelne Ressourcengrößen und Transferzeiten stehen vollständig in den Browser-Rohdaten.

### Versionierte Belege

[Quellmanifest](evidence/p2b/source-manifest.json): SHA-256 über UTF-8 mit LF für Laufzeit-/Prüfquellen sowie Binärhashes der erzeugten Releaseartefakte. Die folgenden finalen Bildordner und Rohdaten gehören zu diesem Quellstand. PNG-Pixelmaße wurden aus den Bildheadern gegen die Berichte geprüft; keine nachbearbeiteten Mockups oder Ersatzrenderer.

Rohdaten: [Windows 1080p](evidence/p2b/windows-1080/metrics.json), [Windows 1440p](evidence/p2b/windows-1440/metrics.json), [Desktop-Chrome](evidence/p2b/web-chrome/metrics.json). Native Laufprotokolle: [1080p](evidence/p2b/windows-1080/render.txt), [1440p](evidence/p2b/windows-1440/render.txt).

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

Die Bildprüfung umfasst Kappensilhouette, Randabstand/Integration der Hauptzeichen, schmale und lange Formate, beide Entscheidungen, Besuchs-/Erreichbarkeitspriorität, Fehler, Ergebnis, F3 sowie Himmel-/Timer-Hierarchie. Web zeigt erwartungsgemäß einfachere Beleuchtung; Pflichtzeichen und Route bleiben erhalten. Die Bilder zeigen keine Rückkehr der weißen P1b-Callouts.

## Offene Nutzerabnahme

**Die erneute subjektive Nutzerabnahme von Look, Figur, Animation, Lesbarkeit und Spielgefühl sowie ein persönlich gespielter vollständiger Windows-Lauf im überarbeiteten Slice bleiben offen.** Synthetische Vollroutenläufe ersetzen diesen Schritt nicht. PR #18 bleibt Draft und wird nicht automatisch gemergt. Die ältere physische P1b-Chrome-Eingabeabnahme bleibt separat offen. Mindesthardware bleibt mangels realer schwächerer Testmaschine unbestimmt.

Nächster Schritt: `build/windows/parkey.exe` normal ohne Prüfargument starten, beide Entscheidungen und Rückweg, Press/Halten/Loslassen, Fehler, Timer und F3 betrachten und einen vollständigen Lauf subjektiv abnehmen. Reproduktion der technischen Nachweise: [development.md](development.md#p2b-grafikprüfung-reproduzieren).

Technische Primärquellen, geprüft 2026-09-06; tatsächliche Ausführung mit der gepinnten lokalen Engine: [Label3D](https://docs.godotengine.org/en/4.4/classes/class_label3d.html), [SurfaceTool](https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/surfacetool.html). Kein Engine-Upgrade.
