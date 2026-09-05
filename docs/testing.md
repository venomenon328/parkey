# Teststrategie und Abnahme

Stand: 2026-09-05. P0 liefert die Suite `smoke`, die beiden Export-Presets und CI; die technische und manuelle P0-Abnahme ist vollständig bestanden. Testfälle zu vorgeschlagenen Regeln werden zusammen mit diesen Regeln freigegeben. Fachliche Grundlage: [Spieldesign](game-design.md), [Architektur](architecture.md), [Entscheidungen](decisions.md) und [Umsetzungsplan](implementation-plan.md).

## P0-Teststand

Technischer Nachweis unter Windows 11 Pro 10.0.26200 mit Godot 4.7.2.stable.official.ed1daf0bf:

- Import, `--suite all` mit 31 Smoke-Assertions sowie beide Release-Exporte liefen erfolgreich. Ein Aufruf mit unbekannter Suite endete geprüft mit Exitcode 1.
- Der Windows-Export wurde außerhalb des Editors gestartet. Die sichtbare Diagnose meldete `Windows / Forward+ | aktiv: forward_plus`; Taste mit Buchstabe, Figur mit Kopf und erhöhte Kamera waren sichtbar.
- Der Web-Export wurde über `python -m http.server` unter 127.0.0.1:8000 in Chrome 152.0.7977.76 geladen. Chrome lud HTML, JavaScript, WASM und PCK über HTTP; die laufende Szene meldete `Web / Compatibility | aktiv: gl_compatibility`. Canvas und WebGL 2 waren aktiv.
- Automatisierte Browser-Ereignisse prüften zusätzlich den Diagnosepfad: ein Ereignis mit `code=KeyY` und erzeugtem `z` wurde als Z akzeptiert, Shift blieb normalisiert, ein Wiederholungsereignis wurde als Echo und Key-up als verworfen angezeigt.
- Die abschließende manuelle Hardwaretastaturabnahme ist ebenfalls bestanden: unter Windows und im interaktiven Chrome-Webexport wurden Y/Z, Shift, echtes Gedrückthalten/Echo und überlappende Tasten erfolgreich geprüft. Modifier erzeugten keine normalen Buchstabeneingaben; Browser-Shortcuts und Fokuswechsel führten nicht zu unerwünschten Spieleingaben.

Damit ist P0 vollständig abgenommen. Diese Abnahme belegt die gemeinsame technische Grundlage und reale Tastaturereignisse, noch keinen Parcours, Renntimer oder spätere Spielregeln.

## Verbindlicher Test-/Exportvertrag ab P0

`tests/run_tests.gd`, die beiden Export-Presets und die minimale CI **existieren seit P0 und bilden die abgenommene Test-/Exportgrundlage**. `godot` bezeichnet den exakt gepinnten Standard-Editor mit passenden Export-Templates. Ausgabeordner `build/windows` und `build/web` vor Exporten anlegen; Quellcode und Buildausgaben getrennt halten.

```sh
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
```

Unter Windows einen passenden PATH-Eintrag oder den vollständigen Pfad zum Standard-Editor verwenden; die konkrete lokale Schreibweise in der Entwicklungsanleitung dokumentieren. Import und Export benötigen den Editor, nicht bloß eine Export-Template-Datei.

Die CLI-Basis ist in der offiziellen [Godot-Anleitung](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html) dokumentiert, geprüft am 2026-09-05. `--suite` ist dagegen **unser in P0 implementiertes Benutzerargument** nach `--`, kein mitgelieferter Godot-Testbefehl.

| Paket | Neue gezielte Suite | Wesentliche automatische Prüfungen |
| --- | --- | --- |
| P0 / #1 | `smoke` | Imports, Szene, Profil-/Eingabegrundlage, Fehler-Exit des Runners |
| P1a / #2 | `core` | Validator, Zustände, Zeitgrenzen und geordnete Eingaben |
| P1b / #3 | `integration` | Instanziierte Spielszene, Input/UI/Kern und Darstellung |
| P1c / #4 | `storage` | Echte temporäre Dateien, Fehlpfade und Wertungstrennung |
| P2a / #5 | `routes` | Modulanschlüsse, Referenzstrecken, Abschnittszeitmessung |
| P2b / #6 | `presentation` | Instanziierte Szenen und Profilreferenzen, keine visuelle Ersatzabnahme |
| P3a / #7 | `generation` | Mindestens 1.000 Seeds, zehn Golden-Fälle und begrenzte Fehlversuche |
| P3b / #8 | `seed_flow` | Seed-/Sitzungs-/Speicherintegration und Konformitätsfälle |
| P4 / #9 | `acceptance` | Vollständige Läufe, Wiederholung und Zustandstrennung |

Gezielter Aufruf: `godot --headless --path . --script res://tests/run_tests.gd -- --suite core` (Suite entsprechend ersetzen). **`all` führt alle bis zum jeweiligen Paket eingeführten Suites aus.** Folgepakete dürfen alte Tests nicht aus der Sammlung entfernen, um grün zu werden. Ein unbekannter Suitename, null ausgewählte Tests sowie Lade-/Assertion-/Laufzeitfehler müssen einen fehlgeschlagenen Testlauf ergeben. Testanzahl und Ergebnis ausgeben; ein einmal absichtlich fehlschlagender Test prüft den Runner selbst.

Beide Exporte bleiben in jedem Paket Pflicht, bei reinen Kernänderungen auch über die vorhandene CI nachweisbar. Reale Plattformprüfungen bleiben dort Pflicht, wo das Issue sie fordert. Keine zweite in Python/JavaScript nachgebaute Kernimplementierung als Testsubstitut; der verwendete GDScript-Code wird getestet.

Für P0/P1 ist Web ohne Threads der Ausgangspunkt. Lokal starten mit:

```sh
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

Dann `http://127.0.0.1:8000/` im Browser öffnen; Server nach dem Test beenden. `python` bezeichnet eine installierte Python-3-Laufzeit. Keine Behauptung, eine doppelt angeklickte lokale HTML-Datei genüge. Bei später aktiviertem Threading muss dieses Serving-Rezept samt nötigen Headern ersetzt und erneut geprüft werden. Siehe [Godot Web-Export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html), geprüft am 2026-09-05.

## Automatisierte Kernregeln ab P1

| Fall | Erwartung im vorgeschlagenen Modell |
| --- | --- |
| Gültiger Nachbarbuchstabe | Genau ein Schritt zum richtigen Feld; neue Nachbarschaft gilt unmittelbar |
| Mehrere schnelle gültige Ereignisse vor dem nächsten Renderbild | Alle geordnet ausführen; kein pauschales Ein-Schritt-pro-Frame-Limit |
| Falscher Bewegungsbuchstabe | Standort unverändert, genau ein Fehler, feste Sperrfrist |
| Gültige und ungültige Eingaben während der Sperre | Keine Bewegung, kein Puffern, keine Verlängerung, keine weiteren Fehler |
| Eingabe knapp vor / genau am / nach Sperrende | Vorher gesperrt; ab Fristende normal verarbeiten, unabhängig von Animationsstatus |
| Neuer Fehler nach Sperrende | Neue reguläre Sperre möglich |
| Zeit während der Sperre | Renntimer läuft; keine doppelte zusätzliche Zeitaddition |
| Gedrückthalten / Echo / Loslassen | Keine zusätzlichen Schritte |
| Überlappende echte Tasten | Kein künstlicher Zwang, erst alle Tasten loszulassen |
| Groß-/Kleinschreibung und QWERTZ-Y/Z | Gleicher sichtbarer Buchstabe erzeugt den vorgesehenen Schritt |
| UI/Modifier und Eingaben außerhalb des Laufs | Keine versehentlichen Spielschritte oder Fehler |
| Ziel mit noch laufender Bewegungsgrafik | Zeit beim logischen Zieleingang festhalten; nur ein Ergebnis speichern |
| Neustart | Position, Laufstatus, Sperre und Zeit sauber zurücksetzen |
| Fokusverlust/Abbruch | Lauf nach freigegebener Regel invalidieren; kein gewerteter Abschluss |
| Lokale Rangliste | Numerische Sortierung, passende Streckenidentität, Laden nach Neustart |

Die Uhr wird für Grenztests kontrolliert injiziert. Bei 200 ms Sperre sind insbesondere 199.999, 200.000 und 200.001 Mikrosekunden nach Fehlerbeginn zu prüfen. Tests warten nicht tatsächlich per Sleep auf jede Fehlerpause. Zusätzlich muss der reale Eingabeadapter getestet werden: Ein perfekter Kern prüft keine im Adapter verlorenen Ereignisse. Unterschiedliche Renderfortschritte dürfen bei denselben normalisierten Eingaben/Zeitwerten keine anderen Kernresultate erzeugen.

## Datenvalidator und Generator

Schon handgebaute P1-Strecken bestehen dieselben Grundprüfungen: eindeutige IDs/Koordinaten, verschiedener vorhandener Start/Zielknoten, gültige symmetrische orthogonale Verbindungen, erreichbare Strecke und verschiedene Buchstaben in jeder erreichbaren Nachbarschaft. Der Negativtest A–B–A muss bei beidseitigen Verbindungen zurückgewiesen werden. Gabelungen, Rückwege und Zusammenführungen sowie optisch begehbare Querverbindungen werden ausdrücklich geprüft.

Ab P3: viele Seeds automatisch generieren/validieren; feste Referenz-Seeds gegen erwartete kanonische Daten/Hashes prüfen; dieselben Fälle in Windows- und Web-Builds ausführen. Gameplay-Daten dürfen sich durch zusätzliche Dekoration, Renderereinstellung oder Kameraposition nicht verändern. Bei Regel-/Generatoränderungen Versions- und Ranglistentrennung prüfen. Ungültige Konfigurationen scheitern mit begrenztem Aufwand und deterministischen Fehlern, nicht mit verdecktem Ersatzseed.

Die Referenzerwartungen nicht zur Testlaufzeit durch denselben ungeprüften Generator neu berechnen. P3a liefert Kernreferenzen; P3b beweist die Ausführung in tatsächlichen Exporten. Erst P3b darf den entsprechenden plattformübergreifenden Nachweis beanspruchen. Kontrollierte Eingaben mit gleicher Zeitbasis prüfen Regelparität, nicht identische reale OS-/Browser-/Hardwarelatenzen.

Strukturelle Gültigkeit ist kein Spielspaßtest. Ob Wege interessant und Buchstabenfolgen unterschiedlich tippbar sind, wird zusätzlich praktisch untersucht.

## Plattformmatrix

| Prüfung | Windows | Browser |
| --- | --- | --- |
| P0-Build | Native Anwendung startet außerhalb des Editors | Export startet über HTTP(S) |
| Darstellung | Gewähltes Forward+-Profil sichtbar und fehlerfrei | Compatibility ohne fehlende Zeichen, Materialien oder Pflichtsignale |
| Eingabe | Echte schnelle Eingaben, Layout, Tastenüberlappung | Dieselben Fälle; Fokus und Browser-Shortcuts zusätzlich |
| Speichern | Ergebnis nach Schließen/Neustart vorhanden | Ergebnis nach Reload/Neustart unter gleicher Origin; eingeschränkten Speicher prüfen |
| Kernregeln/Konformität | Geordnete Ereignisse und kontrollierte Zeitfälle | Gleiche Protokolle und Seeds ergeben gleiche Kernresultate |
| Leistung | Auflösung, Hardware, Framezeiten und Eingabegefühl protokolliert | Browser, Hardware und entsprechende Messbedingungen protokolliert |

P0 ist auf einem tatsächlichen Windows-System und in einem Desktop-Chrome-Browser einschließlich Hardwaretastatur abgenommen. Die abschließende P4-Matrix umfasst Windows sowie Chromium und Firefox mit dokumentierten Versionen. Keine Unterstützung weiterer Browser aus einem einzelnen Export ableiten. Ein headless gestarteter Windows-Build allein ist kein Nachweis der Forward+-Darstellung.

P3b ergänzt die genaue Bedienung seines Export-Konformitätslaufs hier, sobald implementiert. Er soll denselben GDScript-Kern/Generator ausführen und konkrete Hash-/Zustandsberichte liefern. Eine frühere native Headless-Ausführung ist kein Browserlauf.

## Spieltests

Besonders beobachten: verdeckte Buchstaben, schwer erkennbare rückwärtige Nachbarn, Kameraschwenks an Gabelungen, sichtbarer Rückstand der Figur bei schnellen Folgen und Übergang in die Fehlerpause. Zeigt die Figur während der Sperre einen anderen Standort als die logisch gültige Nachbarschaft, ist das ein Problem und nicht bloß kosmetisch.

Fehlerpause zunächst mit T-001 prüfen. Ist die Sperre verständlich? Endet das Feedback rechtzeitig? Fühlen sich Eingaben nahe am Sperrende defekt an? Kann wahlloses Tastendrücken konkurrenzfähige Zeiten erzeugen? Änderungen an Dauer/Puffern explizit dokumentieren.

Routen mit unterschiedlichen Tippmethoden testen. Neben Gesamtzeit auch Fehler, gewählte Route und Entscheidungsstellen betrachten. Langsames Lesen, falsche Routenannahmen und eigentliche Tippfehler nicht in einer einzigen Kennzahl verstecken. Aufzeichnungen zunächst lokal und ohne unnötige personenbezogene Daten. P2a benötigt reale Daten und eine ehrliche Stichprobenbeschreibung, P2b eine visuelle Nutzerabnahme und ein festgelegtes Messbudget.

## Nachweisformat und Status

Eine Abnahme nennt Commit, genaue Godot-Version, Exportprofil, Betriebssystem/Browser, ausgeführte Befehle oder manuelle Schritte und Ergebnis. Nicht ausgeführte Prüfungen bleiben offen. Build-Erfolg, Regeltest, visueller Test und subjektiver Spieltest sind getrennte Nachweise. Bericht/Screenshots nur tatsächlich durchgeführter Tests eintragen.

Fehlt ein verpflichtender Nachweis, bleibt der jeweilige Implementierungs-PR Draft und die Abnahme offen; der Nutzer kann reale Tests ergänzen. Eine README-Änderung oder ein gebautes ZIP ersetzt keine Freigabe. P4 prüft die tatsächlich verpackten Artefakte, nicht nur den Editorzustand.
