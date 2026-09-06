# P2b: Tastatur-Werkstatt

Stand: 2026-09-06. Beauftragt durch [Issue #6](https://github.com/venomenon328/parkey/issues/6), Branch `codex/p2b-visual-slice` aus `a42e826`. Briefing und Referenzbudget sind bestätigt (D-025–D-028); die subjektive Nutzerabnahme bleibt offen.

## Verbindlicher Umfang

Eine warme Tastatur-Werkstatt mit matten Keycaps, Petrol und Messing bildet die einzige Beispielwelt. Plastische Oberflächen, integrierte Hauptbuchstaben, gegliederter stilisierter Mensch, Idle/Bewegung/Fehlerreaktion und rein visuelles Drücken/Halten/Loslassen der aktuellen Taste. Das HUD hat eine zurückhaltende transparente Informationshierarchie; Diagnosen und der optionale Fokustest sind separat einschaltbar.

Der abgenommene 30-Feld-P2a-Kurs, explizite Übergänge, Anker, Grundflächen, Drehungen, Kamera und die Besuchsstatus-Priorität bleiben erhalten. Kosmetische Fasen liegen innerhalb der vorhandenen Grundflächen. Kein P3-Inhalt, Generator, Charaktereditor, Shop oder zweite Welt. Neue Modelle und Materialien entstehen im Repository; keine ungeklärten Fremdassets und keine Festlegung der Projektlizenz.

Windows Forward+ erhält bewusst begrenzte Effekte; Web Compatibility nutzt dieselben Szenen, Layoutdaten und Regeln mit einfacherer Beleuchtung. Pflichtsignale sind von optionalen Effekten unabhängig. Das Ziel sind stabile 60 FPS bei 1080p und 1440p auf dokumentierter Hardware. Ryzen 7 5800X / RTX 3070 ist Referenz, keine Mindestanforderung; schwächere Hardware ist erst nach realer Prüfung bewertbar.

## Umsetzung und Grenzen

- `KeycapVisual` erhält die unveränderten äußeren P2a-Abmessungen und Feldtransforms. Der Sockel bleibt fest; Kappe, Legende und Statussymbole bewegen sich gemeinsam um 0,13 Einheiten abwärts, erreichen den Anschlag innerhalb von 45 ms und bleiben bis zum logischen Verlassen unten. Quick Restart setzt den Startzustand unmittelbar wieder her. Das sind ausschließlich visuelle Parameter, keine neue Höhenmechanik.
- `RunnerVisual` verbindet proportionierten Kopf mit passender Haarkappe/Nase, Hals, Rumpf, Armen/Händen und Beinen/Schuhen. Idle-Atmung, alternierende Bewegung und Fehlerreaktion mischen ohne Animationswarteschlange. Der Szenencontroller behält unverändert 50 ms Figuren- und 80 ms Kamera-Aufholbudget; die 240-ms-Reaktion verlängert die 200-ms-Kernfehlerfrist nicht.
- Die Hauptbuchstaben bleiben auf den Kappen und in der P2a-Orientierung. Punkt, Haken und Raute sind kleine geometrische Druckzeichen: Der erste Chrome-Vergleich zeigte unzuverlässige Schrift-Fallbacks bei den Symbolen, weshalb der finale Stand dafür keine Font-Glyphen mehr benötigt. Aktuell hat Punkt/Haken; besucht hat ausschließlich Haken und dunklere Oberfläche, auch bei erneuter Erreichbarkeit. Nur unbesuchte erreichbare Felder werden heller und zeigen eine Raute.
- Die Werkbank mit eingelassener Matte, Messingkanten, Leuchten, Spulen und Schalterablagen liegt unterhalb bzw. außerhalb des Kurses. Dekoration erzeugt keine neuen begehbaren Flächen oder Verbindungen. Ein grüner Start und roséfarbenes Ziel bleiben zusätzlich beschriftet.
- Standard-HUD: kompakter halbtransparenter Timer, deutscher Spielerstatus, Fehlerzahl und kurze Bedienhilfe. Ergebnis: Zeit, exakte Mikrosekunden, Fehler/Rang/Bestzeit, Top 10 und ehrlicher Speicherstatus in einer mit dem Inhalt wachsenden Fläche. F3 trennt Rohzustand, Renderprofil, Feld-/Nachbarliste, Abschnittsmessung und Textfokustest; Ausblenden gibt Textfokus frei.

Keine Änderungen in `scripts/core`, `scripts/input`, `scripts/course` oder `scripts/storage`. Die kanonische Identität ist weiterhin `course-identity-v1:4dff5df394060f3ce5ffc236f6a9bef0a7e9d0a174b8f4d34308063c73e18e1a`.

## Profile und Assets

Windows Forward+: ein schattenwerfendes Hauptlicht plus schattenloses Fülllicht, 2× MSAA, SSAO-Radius 0,5/Intensität 0,65 und einfache Distanztrübung. Web Compatibility: dieselbe Geometrie, Oberflächensignale und Umgebung; einfacheres Licht ohne Schatten/SSAO/MSAA. Kein Bloom, DOF, SSR, volumetrischer Nebel oder Partikelsystem. Die Rauheit erhält eine eigene kleine 64×64-Mikrostruktur. Szenenbudget: unter 800 Draw Calls und 100.000 gerenderten Primitiven in der dokumentierten Entscheidungsszene; kein Anspruch auf eine universelle Hardwareuntergrenze.

Alle neuen Modelle/Materialparameter/Animationen sind im Repository entstanden. Verwendet wird die vorhandene Godot-Standardschrift Open Sans SemiBold (OFL 1.1); Engine MIT mit eigenen Drittanbieterhinweisen. Keine Fremdspiel-/Assetstore-Assets, neuen Laufzeitpakete oder Lizenzfestlegung für das Projekt. Vollständige Quellen: [CREDITS.md](../CREDITS.md).

## Technische Prüfungen und Bildnachweise

Die Pflichtprüfungen laufen unter Windows 11 Pro Build 26200 mit Godot `4.7.2.stable.official.ed1daf0bf`: Import, `presentation`, `integration`, `all` sowie beide Release-Exporte. Unbekannte und fehlende Suiteargumente müssen mit Exit 1 enden. `presentation` prüft die instanziierte Szene, kanonische Layoutreferenzen/Identität, Hub und Kindtransforms, Figurenphasen, F3/Fokus, geometrische Statuszeichen, Profilumgebungen und exakt gleiche Kernresultate. Die vorhandene Hochfrequenzregression bleibt erfolgreich; kontrolliert maximal 2,738 und im Mittel 0,459 Welteinheiten Restweg, 0,000 s Restaufholen, keine Figurenkorrektur.

Die Exportläufe verwenden reale Renderer und Uhr, aber **synthetische Viewport-Tastaturereignisse**. Pro Auflösung/Browser werden alle vier P2a-Kombinationen vollständig abgeschlossen. Die Bildfolge zeigt Bereitschaft, Alpha-Entscheidung, besuchten Rückweg, Fehler, Ziel und F3. Die Bilder sind tatsächliche Framebuffer-PNGs; Maße werden aus den PNG-Pixeln geprüft, da die skalierte `WindowTexture`-Breitenangabe davon abweichen kann. Sämtliche Testresultate bleiben unter `user://parkey-test-results/`, getrennt von Benutzerbestzeiten.

Der Chrome-Start über die automatisierte Shell wurde vom Ausführungsprüfer blockiert. Der Nutzer öffnete stattdessen die bereitgestellte lokale URL direkt in Desktop-Chrome; danach erledigte der ausdrücklich aktivierte Prüfhelfer die synthetischen Läufe und lieferte seine eigenen Bilder/Messwerte an den lokalen Node-Bordmittelserver. Dies ist ein echter Desktop-Webexport-Nachweis, keine simulierte Ersatzimplementierung. Ein zusätzlich vorangegangener VS-Code/Electron-Weblauf wird separat geführt.

## Leistung und Laden

Tatsächlicher Rechner: AMD Ryzen 7 5800X, NVIDIA GeForce RTX 3070, Windows 11 Pro 26200; NVIDIA-Treiber `32.0.15.9649`. Native Fenster laufen auf einem nominellen 144-Hz-Desktop. Chrome-Version: `152.0.7977.76`. Keine schwächere CPU/GPU und kein öffentlicher Netzwerkpfad wurden geprüft.

Gemessen werden rund 32 Sekunden Anwendungsframeabstände je Probe: vier vollständige Routen bei 160-ms-Eingabeabstand plus 15 Sekunden an der ersten Entscheidung nach Aufwärmen. Screenshot-Readbacks liegen außerhalb dieser Messfenster. Die angegebenen Perzentile sind keine GPU-only- oder Scanout-Latenzen. First-Frame-Zeiten beinhalten lokalen Start/Initialisierung, jedoch keinen behaupteten kalten Treiber-/Dateicache. Web lädt unkomprimiert über localhost mit deaktiviertem HTTP-Cache; diese Ladezeiten sind kein Internetversprechen.

| Reale Ausführung | Framebuffer | Ø FPS | p95 / p99 / Maximum (ms) | Messdauer | Erster Frame |
| --- | --- | --- | --- | --- | --- |
| Windows Forward+ | 1920×1080 | 143,88 | 8,166 / 8,401 / 16,700 | 32,276 s | 1.720 ms |
| Windows Forward+ | 2560×1440 | 143,88 | 8,149 / 8,308 / 17,084 | 32,297 s | 1.650 ms |
| Desktop-Chrome Compatibility | 2320×1305 | 59,95 | 16,900 / 17,000 / 18,800 | 32,343 s | 1.949,6 ms |

Alle drei Proben schließen alle vier Routen mit null Fehlern ab und enthalten keinen Frame über 20 ms. Das Windows-60-FPS-Ziel wird auf der Referenzmaschine in diesen Proben erfüllt; daraus folgt keine Garantie für beliebige Hardware oder Belastung. Windows rendert in der Entscheidungsszene 675 Draw Calls / 74.730 Primitive, Web 281 / 26.138, jeweils innerhalb des Budgets. Chrome meldet den Adapter nur als `WebKit WebGL`; der Canvas ist 2560×1305 groß und enthält den 2320×1305-Spielviewport mit seitlichen Balken. Der lokale Webtransfer umfasst 39.515.054 Bytes WASM in 85 ms und 647.768 Bytes PCK in 3,2 ms, einschließlich HTTP-Overhead; die Initialisierung bis zum ersten Frame dauert deutlich länger als der reine Transfer.

### Versionierte Belege

Die [Quellhashes](evidence/p2b/source-manifest.json) binden die Renderbelege an die Spielskripte, Szenen, Projekt-/Exportkonfiguration und den Renderprüfhelfer dieses PRs (SHA-256 über UTF-8 mit LF). Die Rohdaten enthalten Engine, Renderer, Bildmaße, Frameverteilung und vollständige Routenresultate: [Windows 1080p](evidence/p2b/windows-1080/metrics.json), [Windows 1440p](evidence/p2b/windows-1440/metrics.json), [Desktop-Chrome](evidence/p2b/web-chrome/metrics.json).

| Zustand | Windows 1080p | Windows 1440p | Desktop-Chrome |
| --- | --- | --- | --- |
| Bereitschaft | [PNG](evidence/p2b/windows-1080/ready.png) | [PNG](evidence/p2b/windows-1440/ready.png) | [PNG](evidence/p2b/web-chrome/ready.png) |
| Erste Entscheidung | [PNG](evidence/p2b/windows-1080/alpha.png) | [PNG](evidence/p2b/windows-1440/alpha.png) | [PNG](evidence/p2b/web-chrome/alpha.png) |
| Besuchter Rückweg | — | [PNG](evidence/p2b/windows-1440/visited_return.png) | [PNG](evidence/p2b/web-chrome/visited_return.png) |
| Fehlerreaktion | — | [PNG](evidence/p2b/windows-1440/error.png) | [PNG](evidence/p2b/web-chrome/error.png) |
| Ergebnis | — | [PNG](evidence/p2b/windows-1440/result.png) | [PNG](evidence/p2b/web-chrome/result.png) |
| Entwickleransicht | — | [PNG](evidence/p2b/windows-1440/debug.png) | [PNG](evidence/p2b/web-chrome/debug.png) |

Die finale Symbolkorrektur ist in beiden Renderern sichtbar: geometrischer Punkt/Haken auf dem aktuellen Feld, ausschließlich Haken auf besuchten Rückwegen und Raute auf unbesuchten erreichbaren Alternativen. Web verzichtet sichtbar auf Windows-Schatten und SSAO; Pflichtinformationen bleiben vorhanden. Der frühere eingebettete VS-Code-Weblauf ist nur eine lokale Diagnose und wird nicht als finaler Chrome-Nachweis verwendet.

Automatisiert bestanden: [presentation: 203 Assertions](evidence/p2b/presentation.txt), [integration: 233](evidence/p2b/integration.txt), [all: 748](evidence/p2b/all.txt), jeweils null Fehler. Import und Windows-/Web-Releaseexport endeten ebenfalls mit [Exit 0](evidence/p2b/check-exits.json). Fehlendes Suiteargument und unbekannte Suite endeten erwartungsgemäß mit [Exit 1](evidence/p2b/negative-exits.json); `node --check tests/serve_web_evidence.mjs` war erfolgreich. Die Belege sind durch `.gdignore` vom Spielimport ausgeschlossen.

## Offene Abnahme

**Die subjektive Nutzerabnahme von Look, Figur, Animation, Lesbarkeit und Spielgefühl sowie ein persönlich gespielter vollständiger Windows-Lauf im neuen Slice bleiben ausdrücklich offen.** Der Nutzer hat die Webseite für den technischen Prüflauf geöffnet, damit aber keine ästhetische Freigabe erteilt. Der PR bleibt Draft und wird nicht automatisch gemergt. Die separat verschobene physische P1b-Chrome-Eingabeabnahme bleibt ebenfalls offen. Konkrete Mindesthardware bleibt mangels realer schwächerer Testmaschine unbestimmt.

Nächster Schritt: den Windows-Release normal ohne Prüfargument starten, beide Entscheidungen, Rückweg, Tastendruck-Hub, Fehler und F3 ansehen und einen vollständigen Lauf subjektiv abnehmen. Keine P3-Implementierung als Teil dieser Übergabe.

Technische Primärquellen, geprüft 2026-09-06: [SurfaceTool](https://docs.godotengine.org/en/stable/classes/class_surfacetool.html), [Environment](https://docs.godotengine.org/en/stable/classes/class_environment.html), [Performance](https://docs.godotengine.org/en/stable/classes/class_performance.html). Maßgeblich für die tatsächliche Ausführung bleibt die gepinnte lokale Engine, kein automatisches Upgrade.
