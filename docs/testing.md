# Teststrategie und Abnahme

Stand: 2026-09-06. P0/P1 sind abgenommen und gemergt. P1b umfasst 189 historische Integrations- und 350 Gesamtassertions; finale PR-CI `34001773894` und Merge-CI `34001879727` sind erfolgreich. Die physische Windows-Abnahme ist bestanden, die physische Chrome-Abnahme aus P1b ausdrücklich verschoben. P2a ergänzt im Draft `routes`; technische Tests sind kein Ersatz für die offene menschliche P2a-Spielabnahme. Maßgeblich sind [P1-Regeln](p1-rule-profile.md), [P2a-Routenvertrag](p2a-route-decisions.md), [Spieldesign](game-design.md), [Architektur](architecture.md), [Entscheidungen](decisions.md) und [Umsetzungsplan](implementation-plan.md).

## P0-Teststand

Dokumentierter Nachweis unter Windows 11 Pro 10.0.26200 mit Godot 4.7.2.stable.official.ed1daf0bf:

- Import, `--suite all` mit 31 Smoke-Assertions und beide Release-Exporte erfolgreich; unbekannte Suite geprüft mit Exitcode 1.
- Windows außerhalb des Editors gestartet, Diagnose `Windows / Forward+ | aktiv: forward_plus`, Taste/Buchstabe, Figur/Kopf und erhöhte Kamera sichtbar.
- Web über lokalen HTTP-Server unter 127.0.0.1:8000 in Chrome 152.0.7977.76 geladen. HTML, JavaScript, WASM und PCK über HTTP; `Web / Compatibility | aktiv: gl_compatibility`, Canvas/WebGL 2 aktiv.
- Automatisierte Browserereignisse prüften zusätzlich Unicode-Z bei `code=KeyY`, Shift, Echo und Key-up. Die abschließende Hardwaretastaturabnahme wurde vom Nutzer als vollständig bestanden bestätigt: Y/Z, Shift, echtes Echo, Überlappung und Modifier unter Windows sowie Browser-Shortcuts/Fokus im interaktiven Webexport.

P0 belegt technische Grundlage und reale Tastaturereignisse, keinen Parcours, Renntimer oder P1-Regeln. Die Regeldokumentation erweitert diesen Nachweis nicht rückwirkend.

## P1a-Teststand und Abnahme

Issue #2 / PR #12 ist nach gezielter Review-Nacharbeit auf `617015da51edb6ef9df85a450ff16a478e0fbe64` abgenommen. Der Implementierungsnachweis unter Windows mit Godot 4.7.2 nennt erfolgreichen Import, `core` mit **127 Assertions / 0 Failures**, `all` mit **158 Assertions / 0 Failures** und beide erfolgreichen Release-Exporte. CI-Lauf `33972097170` auf diesem Head erfolgreich.

Der Re-Review prüfte insbesondere den gültigen 30°-Großfeld-/Mehrfachanschluss und die typfeste Validierung von `neighbors = 42`. Merge-Commit: `5ddf921fdf3736f9e521b8e37b833139beee636f`. Auch der anschließende `main`-CI-Lauf `33972595464` war erfolgreich. Dies sind Kern-/Buildnachweise; kein sichtbarer P1b-Parcours und kein P1b-Spielgefühl wurden damit abgenommen.

## P1b-Teststand und Abschluss

Lokaler Nacharbeitsnachweis unter Windows 11 Pro 10.0.26200 mit Godot 4.7.2.stable.official.ed1daf0bf: `git diff --check`, Import, `integration` mit **189 Assertions / 0 Failures**, `all` mit **350 Assertions / 0 Failures** sowie beide Release-Exporte erfolgreich. Die Szenenfolge misst bei 60-Hz-Renderfortschritt und 500/200/125/80-ms-Prüfabständen samt Tempowechsel, Rückweg und Stopp maximal **2,314**, im Mittel **0,407 Welteinheiten** Restweg, **0,000 s** Restlauf und **0** Figurenkorrekturen; das sind kontrollierte Darstellungswerte, kein Mensch-/Hardwarelatenzversprechen. CI `33987533119` auf `8d18dc0` war erfolgreich. Der anschließende technische Re-Review und die physische Windows-Abnahme sind bestanden; finale PR-CI `34001773894` und Merge-CI `34001879727` ergänzen den Abschlussnachweis.

Historischer technischer Nachweis vor der abschließenden Nutzerabnahme: Die verpackten Zwischenstände des vorherigen Nacharbeitsstands wurden auf AMD Ryzen 7 5800X, NVIDIA GeForce RTX 3070, 32 GB RAM und 2560 × 1440 Desktopauflösung tatsächlich gestartet. Dieser Nachweis bleibt als Grundlage erhalten, ersetzt aber keine Sicht-/Eingabeprüfung der N1–N3-Änderung. Auf dem korrigierten Arbeitsstand startet `build/windows/parkey.exe` als natives Fenster mit Titel `Parkey`; eine verlässliche Vordergrund-/Eingabeprüfung war in der belegten Umgebung nicht möglich, weil eine fremde bereits offene Anwendung den Vordergrund behielt. Dieser Start ist kein neuer Windows-Spielnachweis. Der HTTP-Webexport wurde mit isoliertem Chrome (headless, Compatibility/WebGL) geladen; CDP-synthetische `A → Z → K → Q`-Eingaben bei 125 ms und Bildprüfung bei 1280 × 720 und 960 × 620 belegen aktuelle/direkte Zusatzbuchstaben und die Statusoberflächen unter `build/evidence/chrome-n1n3-ready-1280x720.png`, `build/evidence/chrome-n1n3-fork-1280x720.png` und `build/evidence/chrome-n1n3-fork-960x620.png`. Browser-CDP ist synthetisch, nicht physisch.

**Abgeschlossen:** Technischer Re-Review sowie physische/manuelle Windows-Abnahme von beiden Routen/Rückweg, Reaktionsgefühl, Kamera, Feldstatus, Fehlerpause, Y/Z/Shift, Echo/Überlappung, Restart, Escape, Textfeld→Canvas und Fokusverlust. PR #13 ist gemergt. **Offen bleibt die physische Chrome-Abnahme**, ausdrücklich auf später verschoben und kein rückwirkender P1b-Mergeblocker. Automatisierte Browserereignisse bleiben synthetische Nachweise. P1c erhält zusätzlich eigene verpflichtende Browserpersistenztests.

## Verbindlicher Test-/Exportvertrag

`tests/run_tests.gd`, `smoke`/`all`, Export-Presets und minimale CI existieren seit P0; `core` seit P1a. `godot` bezeichnet den gepinnten Standardeditor mit passenden Export-Templates. Ausgabeordner `build/windows` und `build/web` anlegen; Buildausgaben nicht mit Quellcode verwechseln.

```sh
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite routes
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
```

Windows: den stabilen PATH-Shim oder vollständigen Editorpfad aus [development.md](development.md) verwenden. Import/Export brauchen den Editor, nicht allein Templates. `--suite` ist unser Benutzerargument nach `--`, kein eingebauter Godot-Testbefehl. CLI-Quelle: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html (Prüfung der Grundlage: 2026-09-05).

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

Die echte GDScript-Suite `core` prüft Graph/Layout, Identität, Eingabeadapter, Start, Sperrgrenzen, Restart, Menü, Fokus und einmalige Ergebnisse mit einer injizierten Uhr. P1b ergänzt `integration` mit echter Szeneninstanziierung und Viewport-Eingaben. P2a ergänzt `routes` für Abschnittsports, Layout-/Anschlussdaten, alle vier Referenzrouten, QWERTZ-Beschreibungen, Identität und flüchtige Abschnittszeiten/-fehler. `all` führt immer alle vorhandenen Suites aus. Unbekannte/fehlende Suite, null ausgewählte Tests und Lade-/Assertion-/Laufzeitfehler dürfen nicht grün enden. Testanzahl und Ergebnis ausgeben; einen absichtlich fehlschlagenden Fall zur Runnerprüfung verwenden. Alte Tests nicht entfernen, um grün zu werden.

Beide Exporte bleiben in jedem Paket Pflicht, bei Kernänderungen auch über erfolgreiche CI auf aktuellem Head nachweisbar. Tests führen den wirklichen GDScript-Code aus, keine Python-/JavaScript-Ersatzimplementierung. Reale Plattformtests gemäß jeweiligem Issue zusätzlich durchführen.

Für P0/P1 ist Web ohne Threads vorgesehen:

```sh
python -m http.server 8000 --bind 127.0.0.1 --directory build/web
```

`http://127.0.0.1:8000/` im Browser öffnen, Server danach beenden. Python 3 erforderlich. Doppelklick auf HTML ist kein Webnachweis. Bei späterem Threading Serving-Rezept/Header erneut prüfen; Quelle: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html (Grundlage geprüft 2026-09-05).

## Kernregeln ab P1a

Die folgenden Fälle bilden den dauerhaften Regel-/Regressionstestvertrag. Der konkrete P1a-Nachweis steht oben; Szenen-, UI- und Darstellungsfälle sind zusätzlich durch P1b zu beweisen. Die frühere Countdown-Testanforderung ist ersetzt.

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

P1b ergänzt die tatsächliche Start-/Quick-Restart-Verdrahtung, den Timer und UI-Kontext. Ein Backspace im späteren Seed-Textfeld löscht Text und startet keinen Lauf neu. Escape darf dort nicht versehentlich den Quick-Restart-Pfad verwenden. Vollständige Menüoberfläche/Übungsfortsetzung werden durch diese Testanforderungen nicht vorgezogen.

## P1b: Szenenintegration und reale Spielabnahme

Issue #3 und [p1b-implementation.md](p1b-implementation.md) beschreiben die abgeschlossene Integration und ihren fortbestehenden Regressionstestvertrag. Die physische Chrome-Prüfung bleibt gemäß dokumentierter Ausnahme offen. Zusätzlich zum gemeinsamen Vertrag:

```sh
godot --headless --path . --script res://tests/run_tests.gd -- --suite integration
```

Die Suite instanziiert `scenes/playable_course.tscn` im SceneTree, wartet auf `_ready` und Prozessframes und führt vollständige Läufe über den Viewport-Eingabepfad aus. Direkte Kernproben ergänzen, ersetzen diesen Pfad aber nicht. Der Runner beendet sich erst nach den ausstehenden Szenentests.

Zu prüfen sind beide Routen und Rückwege, richtige/falsche Ersteingabe, Fehlerfrist, mindestens 50 schnelle Ereignisse bei unterschiedlichen Renderfortschritten, `LineEdit`-Fokus, Menü/Fokusverlust, Restart während Bewegungs-/Fehlerfeedback und einmalige Zielzeit. Standpunkte/Drehung/Übergänge entsprechen den Kursdaten; Szenenaufbau und Renderprofil ändern die Identität nicht. Vorhandene P0-Diagnose erhalten; nur die absichtlich geänderte Hauptszenen-Assertion anpassen.

Darstellungsgrenzen sind zentral zu dokumentieren und zu testen: keine anwachsende Animationswarteschlange, Aufholen innerhalb des erklärten Budgets, kein Abschneiden über falsche Wege, keine alten Callbacks nach Restart. Die Sperranzeige endet nach Fristablauf auch ohne neue Eingabe; sie darf nicht allein an einem alten `LOCKED`-Enum hängen. Ein gespeichertes `last_result` erzeugt nach Restart keinen falschen erneuten Abschluss.

HUD-Grenztests: `59.999.999 µs → 00:59.999` und `60.000.000 µs → 01:00.000`; ganzzahlige Anzeige, Originalzeit unverändert. Ein Zieleingang während noch laufender Grafik friert Ergebnis und Anzeige zum logischen Zeitpunkt ein.

Reale Abnahme: Windows-Export mit Forward+ und über HTTP gestarteter Chrome-Web-Export mit Compatibility jeweils tatsächlich durchspielen. Beide Routen, Rückweg, Fehler/Restart/Menü/Fokus, Y/Z, Shift, Echo/Überlappung und ein schneller Burst mit physischer Tastatur prüfen. Lesbarkeit auch beim Fenstergrößenwechsel kontrollieren. Commit, Engine, OS/Browser, Hardware/Auflösung, ausgeführte Schritte und offene Befunde dokumentieren. Firefox bleibt verpflichtend bei P4, nicht zusätzliches P1b-Gate.

Keine Persistenz- oder Generatorabnahme vorziehen. Die P1b-Übergabe liefert die konkrete Bedien-/Testanleitung und Artefaktpfade. Ein fehlender echter Spieltest bleibt offen; grüne CI ersetzt ihn nicht.

## P1c: Ergebnisablage und Persistenzabnahme

Issue #4 ergänzt den Runner um die echte `storage`-Suite; er kennt nun `smoke`, `core`, `storage`, `integration` und `all`. `storage` nutzt echte isolierte Dateien plus injizierte I/O-Fehler. `integration` setzt seinen Store vor dem Szenen-`_ready` auf einen eigenen Testpfad und prüft die reale Viewportfolge Abschluss→Restart ohne Renderframe→neuer Lauf mit verspätetem Speichern. Damit greifen weder `integration` noch `all` auf Benutzerbestzeiten zu.

```sh
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite storage
godot --headless --path . --script res://tests/run_tests.gd -- --suite integration
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
```

Echte temporäre Dateien und gezielt injizierte I/O-Fehler verwenden. Auch bestehende Szenentests müssen ihre Speicherabhängigkeit vor `_ready` isolieren, damit `integration`/`all` keine Benutzerbestzeiten verändern. Der Paketvertrag konkretisiert einmalige IDs, verzögerte Speicherantworten nach Restart, tatsächliche Ranglistentrennung, Gleichstände, Aufbewahrung sowie beschädigte/unbekannte Formate und sichere Ersetzung. Tests des echten Szenen-/Viewport-Pfads ergänzen die Storetests.

Zusätzlich im exportierten Windows-Spiel Abschluss→Schließen→Neustart und im tatsächlichen Desktop-Chrome-Webexport derselben Origin Abschluss→Reload sowie Tab schließen→erneut öffnen prüfen. Temporäre Speicherung bei eingeschränktem Browser-Speicher muss verständlich angezeigt werden. Commit, Engine, Plattform/Browser, Origin/Testpfad und beobachteter Speicherstatus gehören in den Nachweis. Die P1b-Verschiebung der physischen Chrome-Tastaturabnahme hebt diese neuen Persistenzprüfungen nicht auf; ein Dateisystem-Mock und ein Export allein erfüllen sie nicht. Firefox bleibt P4. Diese P1c-Gates sind über PR #14 abgeschlossen; der P2a-Draft hat eigene offene Abnahmen.

### P1c-Nachweis auf dem Implementierungsstand

Godot `4.7.2.stable.official.ed1daf0bf` auf Windows 11 Pro, Build `26200`: Import, `storage` mit **67**, `integration` mit **218** und `all` mit **446 Assertions** sowie beide Release-Exporte bestanden. Die Suite prüft tatsächliche isolierte Dateien sowie die echte Spielszene; neu abgedeckt sind Backup-only-Recovery mit anschließendem Ersetzungsfehler und zwei unterschiedlich gerankte Rohzeiten (`1.234.000`/`1.234.999` µs) mit gleicher Millisekundenanzeige im echten Ergebnispanel. Die eingeschränkte Speicheranzeige wird dabei mit deaktivierter Dauerhaftigkeit als `Nur temporaer: dauerhafter Speicher nicht verfuegbar.` geprüft.

Der native Windows-Release wurde tatsächlich gestartet. Ein vollständiger Oberroutenlauf über Win32-Nachrichten erzeugte eine Ergebnisdatei unter `%APPDATA%\Godot\app_userdata\Parkey\parkey-results\results-v1.json`; nach Prozessende und Neustart enthielt sie unverändert einen Eintrag. Die Nachrichten sind ein synthetischer Eingabenachweis, keine erneute physische Tastaturabnahme.

Der Web-Release lief in Google Chrome `152.0.7977.76` unter `http://127.0.0.1:8123` mit einem frischen Browserprofil und CDP-Eingaben. Ein Abschluss wurde in Chromes IndexedDB unter `/userfs/godot/app_userdata/Parkey/parkey-results/results-v1.json` geschrieben. Nach Reload ergab ein zweiter gleicher Lauf zwei verschiedene IDs; nach Tab-Schließen und Neuöffnen unter derselben Origin bestanden beide weiter, ohne Duplikat. Ein separates Chrome-Profil mit blockierter Site-Datenspeicherung meldete beim IndexedDB-Öffnen `UnknownError` („user denied permission“); der Export blieb dabei startbar und erzeugte keine beweisbare dauerhafte Datei. Die verständliche temporäre Panelmeldung ist in der Szenenintegration nachgewiesen und wurde am 2026-09-06 zusätzlich im exportierten Chrome-Spiel unter `http://127.0.0.1:8134` visuell geprüft: Nach kontrollierter Oberrouten-Eingabe zeigte das gerenderte Zielpanel `Nur temporaer: dauerhafter Speicher nicht verfuegbar.` Der Browser-IndexedDB-Probe lieferte dabei `UnknownError`; eine dauerhafte Speicherung wurde nicht angezeigt. Die verschobene P1b-Hardwaretastaturabnahme in Chrome bleibt offen.

## P2a: Routen- und Kameranachweis

Auf `codex/p2a-route-decisions` mit Godot `4.7.2.stable.official.ed1daf0bf` unter Windows 11 Pro Build `26200` bestanden Import, `routes` mit **51 Assertions** und `all` mit **511 Assertions**; beide Release-Exporte waren erfolgreich. `routes` prüft die vier Kombinationen der zwei Entscheidungen, Übergangsports und -geometrie, Identitätstrennung, die beschreibenden QWERTZ-Hypothesen sowie Abschnittsdauer und Fehlerzahl mit kontrollierter Uhr. Der gesamte Eingabepfad bleibt im echten Szenentest erhalten.

Der native Windows-Release wurde als sichtbares `Parkey`-Fenster bei 2560 × 1440 tatsächlich gestartet. Screenshots unter `build/evidence/windows-p2a-ready-foreground.png` und `build/evidence/windows-p2a-alpha-decision-synthetic.png` zeigen Bereitschaft und die erste Entscheidung nach synthetischem `A → Z → K`: aktuelles Feld, direkte Rückwege sowie `F` und `A` als erste Alternativen liegen ohne schwebende P1b-Callouts auf den Keycaps vor der Wahl. Die Sequenz und die Bildprüfung sind technische, synthetische Nachweise, keine physische Tastatur- oder menschliche Spielabnahme.

Der Web-Release wurde über `python -m http.server 8125 --bind 127.0.0.1 --directory build/web` bereitgestellt; eine HTTP-Abfrage lieferte `200`. Eine isolierte grafische Chrome-Prüfung konnte in dieser Ausführungsumgebung nicht gestartet werden und ist daher **offen**. Die physische P1b-Chrome-Eingabeabnahme bleibt ebenfalls offen. Für P2a stehen außerdem der menschliche Spieltest mit unterschiedlichen Tippmethoden, möglichst zwei Personen, sowie die getrennte Erfassung von Tippfehlern, Entscheidungszeit und Sichtproblemen noch aus; der Draft-PR bleibt deshalb offen.

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
