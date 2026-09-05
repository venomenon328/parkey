# Teststrategie und Abnahme

Stand: 2026-09-05. P0 ist technisch und manuell abgenommen. Das P1-Profil ist freigegeben; P1a implementiert seine `core`-Suite im Draft, die technische Abnahme bleibt offen. Grundlage: [P1-Regelprofil](p1-rule-profile.md), [Spieldesign](game-design.md), [Architektur](architecture.md), [Entscheidungen](decisions.md) und [Umsetzungsplan](implementation-plan.md).

## P0-Teststand

Dokumentierter Nachweis unter Windows 11 Pro 10.0.26200 mit Godot 4.7.2.stable.official.ed1daf0bf:

- Import, `--suite all` mit 31 Smoke-Assertions und beide Release-Exporte erfolgreich; unbekannte Suite geprüft mit Exitcode 1.
- Windows außerhalb des Editors gestartet, Diagnose `Windows / Forward+ | aktiv: forward_plus`, Taste/Buchstabe, Figur/Kopf und erhöhte Kamera sichtbar.
- Web über lokalen HTTP-Server unter 127.0.0.1:8000 in Chrome 152.0.7977.76 geladen. HTML, JavaScript, WASM und PCK über HTTP; `Web / Compatibility | aktiv: gl_compatibility`, Canvas/WebGL 2 aktiv.
- Automatisierte Browserereignisse prüften zusätzlich Unicode-Z bei `code=KeyY`, Shift, Echo und Key-up. Die abschließende Hardwaretastaturabnahme wurde vom Nutzer als vollständig bestanden bestätigt: Y/Z, Shift, echtes Echo, Überlappung und Modifier unter Windows sowie Browser-Shortcuts/Fokus im interaktiven Webexport.

P0 belegt technische Grundlage und reale Tastaturereignisse, keinen Parcours, Renntimer oder P1-Regeln. Die Regeldokumentation erweitert diesen Nachweis nicht rückwirkend.

## Verbindlicher Test-/Exportvertrag

`tests/run_tests.gd`, `smoke`/`all`, Export-Presets und minimale CI existieren seit P0. `godot` bezeichnet den gepinnten Standardeditor mit passenden Export-Templates. Ausgabeordner `build/windows` und `build/web` anlegen; Buildausgaben nicht mit Quellcode verwechseln.

```sh
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
```

Windows: passenden PATH/Alias oder vollständigen Editorpfad aus [development.md](development.md) verwenden. Import/Export brauchen den Editor, nicht allein Templates. `--suite` ist unser Benutzerargument nach `--`, kein eingebauter Godot-Testbefehl. CLI-Quelle: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html (Prüfung der Grundlage: 2026-09-05).

| Paket | Neue Suite | Prüfbereich |
| --- | --- | --- |
| P0 / #1 | `smoke` | Imports, Szene, Profile/Eingaben, Fehler-Exit |
| P1a / #2 | `core` | Graph/Layout, Start durch Eingabe, Zeit/Sperren, Quick Restart, Menüanforderung, Fokus/Ergebnis |
| P1b / #3 | `integration` | Spielszene, Input/UI/Kern, Darstellung |
| P1c / #4 | `storage` | Echte Dateien, Fehlpfade, Wertungstrennung |
| P2a / #5 | `routes` | Module/Anschlüsse, Referenzstrecken, Abschnittszeiten |
| P2b / #6 | `presentation` | Szenen, Profile und Referenzen; kein Ersatz für Grafiktest |
| P3a / #7 | `generation` | Mindestens 1.000 Seeds, zehn Golden-Fälle, begrenzte Fehlversuche |
| P3b / #8 | `seed_flow` | Seed-/Sitzungs-/Speicherintegration und Exportkonformität |
| P4 / #9 | `acceptance` | Komplette Läufe, Wiederholungen und Zustandstrennung |

P1a ergänzt die echte GDScript-Suite `core`. Sie prüft Graph/Layout, Identität, Eingabeadapter, Start, Sperrgrenzen, Restart, Menü, Fokus und einmalige Ergebnisse mit einer injizierten Uhr. `all` führt immer alle bis dahin eingeführten Suites aus. Unbekannte/fehlende Suite, null ausgewählte Tests und Lade-/Assertion-/Laufzeitfehler dürfen nicht grün enden. Testanzahl und Ergebnis ausgeben; einen absichtlich fehlschlagenden Fall zur Runnerprüfung verwenden. Alte Tests nicht entfernen, um grün zu werden.

Beide Exporte bleiben in jedem Paket Pflicht, bei Kernänderungen auch über erfolgreiche CI auf aktuellem Head nachweisbar. Tests führen den wirklichen GDScript-Code aus, keine Python-/JavaScript-Ersatzimplementierung. Reale Plattformtests gemäß jeweiligem Issue zusätzlich durchführen.

Für P0/P1 ist Web ohne Threads vorgesehen:

```sh
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

`http://127.0.0.1:8000/` im Browser öffnen, Server danach beenden. Python 3 erforderlich. Doppelklick auf HTML ist kein Webnachweis. Bei späterem Threading Serving-Rezept/Header erneut prüfen; Quelle: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html (Grundlage geprüft 2026-09-05).

## Kernregeln ab P1a

Die folgenden Fälle sind **verpflichtende neue Tests**, keine bereits bestandenen Prüfungen. Die frühere Countdown-Testanforderung ist ersetzt.

| Fall | Erwartung aus `p1-input-start-v1` |
| --- | --- |
| Beliebig lange Bereitschaft | Startfeld und null Laufzeit; keine Uhr startet allein durch Rendern/Warten |
| Erster gültiger A–Z-Key-down | Startzeit und erster logischer Schritt im selben Ereignis; kein zusätzlich benötigter Starttastendruck |
| Erster falscher A–Z-Key-down | Startzeit gesetzt, Position bleibt, ein Fehler und 200-ms-Sperre beginnen gleichzeitig |
| Echo, Key-up, Modifier, Shortcut, Nicht-A–Z, UI-Eingabe vor Start | Kein Start, Schritt oder Fehler; keine spätere Pufferverarbeitung |
| Noch nicht validierte Strecke / fehlender Fokus / angenommene Menüunterbrechung | Bewegungsereignisse starten keinen Lauf und werden nicht gepuffert |
| Ein-Schritt-Strecke im kontrollierten Test | Gültiger erster Schritt ins Ziel kann null Mikrosekunden ergeben; kein künstlicher Mindestwert |
| Nachfolgender gültiger Nachbarbuchstabe | Genau ein Schritt; neue Nachbarschaft gilt unmittelbar |
| Mindestens 50 gültige Ereignisse ohne Renderfortschritt | Alle geordnet verarbeitet; kein Schritt-pro-Frame-Limit oder Mindestabstand |
| Falscher Buchstabe während des Laufs | Ein Fehler, unveränderte Position und feste Sperrfrist |
| Beliebige Bewegungsversuche während der Sperre | Keine Schritte, Puffer, Verlängerung oder weitere Fehler |
| Neuer Tastendruck vor / genau am / nach Fristende | Vorher gesperrt; ab Fristende normal unabhängig vom Animationsstatus |
| Neuer Fehler nach Sperrende | Neue reguläre Sperre möglich |
| Rennzeit während Fehlerpause | Läuft weiter; keine zweite Zeitaddition |
| Echo/Key-up, überlappende neue Tasten, Shift/Caps, QWERTZ-Y/Z | Profilkonforme Normalisierung und Empfangsreihenfolge ohne Freigabezwang aller Tasten |
| Backspace aus Bereitschaft, Lauf, Fehlerpause oder nach Abschluss | Derselbe Parcours bereit auf Start, null Zeit/Fehler, keine Sperre oder alten Ereignisse; nächster Buchstabe startet, keine Enter-/Countdownphase |
| Wiederholtes gehaltenes Backspace/Escape | Keine durch Echo ausgelösten Restart-/Menükaskaden |
| Escape-Menüanforderung | Eigener Vorgang statt Reset/Quick Restart; Position und Versuch nicht auf Start überschreiben; kein voller Menübau erforderlich |
| Menüanforderung vor / nach Laufbeginn | Vorher kein Zeitstart; angenommene Unterbrechung blockiert Bewegungen. Begonnener unterbrochener Lauf wird nicht gewertet, keine implizite gewertete Fortsetzung |
| Fokusverlust während Lauf/Fehlerpause | Abbruch/Invalidierung, keine automatische Fortsetzung bei Rückkehr; Quick Restart möglich |
| Fokusverlust vor erstem Buchstaben | Kein laufender Versuch/Fehlstart; bei fehlendem Fokus keine Eingaben, danach Bereitschaft möglich |
| Logischer Zieleingang bei laufender Grafik | Zeit sofort einfrieren und höchstens ein gültiges Ergebnis erzeugen |
| Fokusverlust, Menü, Restart oder späte Eingaben nach gültigem Abschluss | Bestehendes Ergebnis weder verändern, entwerten noch duplizieren |
| Gleiche Zeitwerte mehrerer Ereignisse | Reihenfolge des Empfangs entscheidet deterministisch, ohne künstliche Zeitschritte |

Kontrollierte injizierte Uhr statt Sleep. Bei 200 ms insbesondere **199999, 200000 und 200001 µs nach Fehlerbeginn** prüfen, auch wenn der Fehler das erste Laufereignis war. Quick Restart entfernt alte Session-Ereignisse; Tests dürfen nicht nur Kernmethoden korrekt prüfen und den realen Eingabeadapter vergessen.

P1b ergänzt die tatsächliche Start-/Quick-Restart-Verdrahtung, den Timer und UI-Kontext. Ein Backspace im späteren Seed-Textfeld löscht Text und startet keinen Lauf neu. Escape darf dort nicht versehentlich den Quick-Restart-Pfad verwenden. Menüoberfläche/Übungsfortsetzung werden durch diese Testanforderungen nicht vorgezogen.

## Datenvalidator und Generator

Handstrecken trennen Graph- und Layoutprüfung: eindeutige IDs, verschiedener vorhandener Start/Ziel, gültige Kantenreferenzen, keine Selbst-/Doppelkanten, symmetrische P1-Verbindungen, Erreichbarkeit und unterschiedliche Nachbarbuchstaben. Kein allgemeines Raster, Orthogonalitätsgebot oder feste Nachbarzahl. **A–B–A** wird weiterhin zurückgewiesen.

P1a prüft einen gültigen Graphen mit fünf eindeutigen Nachbarn und variable Nachbarzahlen. Unterschiedliche gültige Layouts derselben Topologie erhalten identische Eingabe-/Zeitprotokolle: gleiche Schritte, Fehler-/Sperrgrenzen und Zielzeit; keine Abstand-/Größenwartezeit. Andere relevante relative Positionen, Grundflächen, Größen, Ausrichtungen oder Übergänge ändern dagegen die Identität. Materialwechsel nicht. Profil-/Start-/Fehlerparameter sind ebenfalls wertungsrelevant; keine Zusammenwertung mit dem alten Countdown-Vorschlag.

Layoutfälle: unzulässige Überlappungen, ungültige Formparameter/Anker, lesbare Randabschnitte, größeres Feld neben mehreren kleineren, Eckkontakt ohne automatische Kante, erlaubte/unerlaubte Fugen, sichtbare Anschlüsse ohne Datenkante und Datenkanten ohne erkennbaren Übergang. Toleranzen werden im kleinen Layoutprofil dokumentiert, nicht als universelle Annahme in RunSession. P1b prüft die Darstellung einer unregelmäßigen Stelle, P2a die menschliche Anschlusslesbarkeit.

P1c prüft Ranglistentrennung mit echten gespeicherten Ergebnissen, numerische Sortierung, lokale Gleichstände, Aufbewahrung, Restart/Reload, beschädigte/unbekannte Formate und I/O-Fehler. Abgebrochene oder menüunterbrochene Versuche gelangen nicht in die Wertung. Bereits gültige Ergebnisse bleiben erhalten.

Ab P3 viele Seeds erzeugen/validieren und feste erwartete kanonische Graph-/Layoutdaten/Hashes vergleichen. Dekoration, Renderer und laufende Kamerabewegung dürfen sie nicht verändern; relevante Layoutänderung muss die Identität ändern. Regel-/Generatorversionen trennen Wertungen. Ungültige Konfigurationen scheitern begrenzt und deterministisch, nicht durch stillen Ersatzseed.

Golden-Erwartungen nicht zur Testlaufzeit durch denselben ungeprüften Generator neu erzeugen. P3a liefert Kernreferenzen; erst P3b belegt echte Windows-/Web-Ausführung. Kontrollierte Protokolle prüfen Regelparität, nicht identische menschliche Hardware-/Browserlatenz. Strukturgültigkeit ersetzt keine Spielspaßprüfung.

## Plattformmatrix

| Prüfung | Windows | Browser |
| --- | --- | --- |
| Build | Export außerhalb des Editors startet | Export über HTTP(S) startet |
| Darstellung | Gewähltes Forward+-Profil sichtbar/fehlerfrei | Compatibility ohne fehlende Pflichtsignale |
| Eingabe | Reale schnelle Eingaben, Layout, Überlappung | Dieselben Fälle, zusätzlich Fokus/Shortcuts |
| Speicherung ab P1c | Nach Schließen/Neustart korrekt | Nach Reload/Neustart derselben Origin; eingeschränkten Speicher prüfen |
| Kernkonformität | Kontrollierte Protokolle/Seeds | Gleiche Protokolle/Seeds, gleiche Kernresultate |
| Leistung | Hardware, Auflösung, Framezeiten und Eingabegefühl dokumentiert | Browser/Hardware und Messbedingungen dokumentiert |

P0 ist auf Windows und Desktop-Chrome einschließlich Hardwaretastatur abgenommen. P4 umfasst Windows, Chromium und Firefox mit dokumentierten Versionen. Keine weitere Plattformunterstützung aus einem Export ableiten; Headless-Windows ist kein Forward+-Grafiknachweis. P3b dokumentiert seinen echten Export-Konformitätslauf hier, sobald implementiert.

## Spieltests und Nachweisformat

Moderate Größen, variable Nachbarn und schräge Anschlüsse prüfen: Anker auf Feldern, keine Lücken durchschneiden, keine Distanzpausen/falschen Nachbarschaften. Fünf Nachbarn im Kern sind ein Flexibilitätstest, keine Pflicht jeder sichtbaren Kreuzung. Kamera, rückwärtige Nachbarn, Buchstabenverdeckung und Aufholbewegung bei schnellem Tippen beobachten.

Fehlerfeedback und Fristende müssen verständlich sein. Eingaben nahe Sperrende und wahlloses Tastendrücken praktisch prüfen; Änderungen an Dauer/Puffer explizit versionieren. Routen mit verschiedenen Tippmethoden testen, Zeiten/Fehler/Entscheidungs-/Sichtprobleme getrennt betrachten. Keine unnötigen personenbezogenen Daten; P2a braucht reale Versuche, P2b visuelle Nutzerabnahme und Leistungsbudget.

Jeder Nachweis nennt Commit, Engine, Plattform/Browser, Befehle bzw. manuelle Schritte und Ergebnis. Build-, Regel-, Grafik- und Spieltests getrennt berichten. Neue P1-Freigaben sind kein Testnachweis. Fehlende verpflichtende Tests lassen den PR Draft und Abnahme offen. P4 prüft verpackte Artefakte, nicht nur den Editorstand.
