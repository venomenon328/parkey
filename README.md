# Parkey

Ein 3D-Speedrun-Spiel über Tippgeschwindigkeit, räumliche Orientierung und Routenwahl.

Eine Spielfigur bewegt sich in Third-Person-Ansicht über einen Parcours aus beschrifteten Feldern. Der Buchstabe eines erreichbaren Nachbarfelds ist die Taste für den nächsten Schritt. Korrekte Eingaben sollen ohne künstliche Geschwindigkeitsbegrenzung verarbeitet werden. Tippfehler verursachen dagegen eine kurze Bewegungssperre. Unterschiedliche Wege können kürzer und schwieriger oder länger und flüssiger tippbar sein.

Das Streckenmodell ist nicht auf ein regelmäßiges Raster oder eine feste Nachbarzahl beschränkt. Unterschiedlich angeordnete, geformte und moderat verschieden große Felder müssen klar erkennbare direkte Übergänge haben. Die Darstellung folgt dem Tipptempo, nicht umgekehrt; spielrelevante räumliche Layoutänderungen gehören zur Streckenidentität.

**Hauptziel:** eine grafisch hochwertige Windows-Anwendung mit Godot. Eine zusätzliche Browserversion soll möglichst dieselbe Codebasis und Spiellogik verwenden.

## Aktueller Stand

Stand: 2026-09-05. P0 / Issue #1 ist implementiert und vollständig abgenommen: gemeinsames Godot-Projekt, zwei Export-Presets, kleine 3D-Diagnoseszene, Smoke-Runner und CI. Windows-/Web-Starts und manuelle Hardwaretastaturtests für Y/Z, Shift, Echo, Überlappung, Modifier/Browser-Shortcuts und Fokus sind bestanden.

**P1a / Issue #2 ist abgenommen und über PR #12 nach `main` gemergt** (`5ddf921fdf3736f9e521b8e37b833139beee636f`). Der testbare Kern enthält `CourseData`, getrennte Graph-/Layoutvalidierung, versionierte Identität, `RunSession`, monotone Uhr und den Eingabeadapter. Nach Review-Nacharbeit: `core` mit 127 und `all` mit 158 Assertions, beide Exporte und CI erfolgreich. Diese Nachweise betreffen den Kern, nicht einen schon sichtbaren Spielablauf.

**P1b / Issue #3 ist im Draft-PR #13 implementiert, aber noch nicht vollständig abgenommen.** Der reguläre Einstieg ist ein validierter 26-Feld-Handparcours mit zwei Routen, Rückwegen, Figur, automatischer Kamera, Timer, Fehlerfeedback, Quick Restart und minimaler Escape-Rückmeldung. Die echte Suite `integration` prüft die Szenen-/UI-/Kernverdrahtung. Physische Windows-/Web-Spielabnahme und Review bleiben eigenständige Gates. Dauerhafte Ranglisten und Generator fehlen weiterhin planmäßig.

Für P1 gilt: Start durch den ersten Bewegungsbuchstaben, kein Countdown; Backspace als Quick Restart zurück in Bereitschaft; Escape als getrennte Pausemenü-Anforderung. 200 ms Fehlerpause ohne Puffer/Verlängerung, A–Z, Rückwege und Fokusinvalidierung sind als PoC-Regeln freigegeben. Details und Randfälle stehen zentral im [P1-Regelprofil](docs/p1-rule-profile.md).

## Dokumentation

| Datei | Inhalt |
| --- | --- |
| [Entscheidungen](docs/decisions.md) | Bestätigte Anforderungen, PoC-Freigaben, Vorschläge und offene Entscheidungen |
| [P1-Regelprofil](docs/p1-rule-profile.md) | Verbindlicher Start-/Eingabe-/Fehler-/Restart-/Menü-/Fokusvertrag |
| [P1b-Integration](docs/p1b-implementation.md) | Szenen-/Eingabe-/Darstellungsvertrag und Abnahme des ersten Spielparcours |
| [Spieldesign](docs/game-design.md) | Spielschleife, Bewegung, Kamera und Parcours |
| [Architektur](docs/architecture.md) | Gemeinsamer Spielkern und Windows-/Web-Profile |
| [Roadmap](docs/roadmap.md) | Meilensteine und tatsächlicher Fortschritt |
| [Umsetzungspakete](docs/implementation-plan.md) | Issues, Abhängigkeiten, Branches und Liefervertrag |
| [Teststrategie](docs/testing.md) | Testvertrag, automatisierte Regeln und reale Plattformabnahme |
| [Entwicklung](docs/development.md) | Gepinnter Editor/Templates, lokale Befehle und P0-Diagnose |
| [Arbeitsregeln](AGENTS.md) | Änderungs-, Dokumentations- und Übergaberegeln |

## Nächster Arbeitsschritt

[**Draft-PR #13 zu P1b / Issue #3**](https://github.com/venomenon328/parkey/pull/13) technisch und manuell abnehmen. Arbeitsbranch ist `codex/p1b-playable-course`; die [Integrationsvorgaben](docs/p1b-implementation.md) enthalten Bedienfolge, Darstellungsgrenzen und offene Nachweise. Kein separater Vorbereitungsmerge und kein zweiter PR.

Nach Abnahme und Merge liefert P1b erstmals einen vollständigen Handlauf. Lokale Bestzeiten folgen in P1c. Erst erprobte Routenbausteine werden zufallsgeneriert. Spätere Branches entstehen nach ihren Abhängigkeiten vom dann aktuellen `main`.

## Zusammenarbeit

Festlegungen gehören ins Repository, nicht ausschließlich in Chats oder Issue-Kommentare. Änderungen an Regeln, Technik oder Umfang aktualisieren im selben PR die betroffenen Dokumente. Freigabe, Implementierung und Abnahme sind unterschiedliche Zustände. Implementierungen laufen über Arbeitsbranches und Draft-PRs; kein automatischer Merge.
