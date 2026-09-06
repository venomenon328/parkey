# Parkey

Ein 3D-Speedrun-Spiel über Tippgeschwindigkeit, räumliche Orientierung und Routenwahl.

Eine Spielfigur bewegt sich in Third-Person-Ansicht über einen Parcours aus beschrifteten Feldern. Der Buchstabe eines erreichbaren Nachbarfelds ist die Taste für den nächsten Schritt. Korrekte Eingaben sollen ohne künstliche Geschwindigkeitsbegrenzung verarbeitet werden. Tippfehler verursachen dagegen eine kurze Bewegungssperre. Unterschiedliche Wege können kürzer und schwieriger oder länger und flüssiger tippbar sein.

Das Streckenmodell ist nicht auf ein regelmäßiges Raster oder eine feste Nachbarzahl beschränkt. Unterschiedlich angeordnete, geformte und moderat verschieden große Felder müssen klar erkennbare direkte Übergänge haben. Die Darstellung folgt dem Tipptempo, nicht umgekehrt; spielrelevante räumliche Layoutänderungen gehören zur Streckenidentität.

**Hauptziel:** eine grafisch hochwertige Windows-Anwendung mit Godot. Eine zusätzliche Browserversion soll möglichst dieselbe Codebasis und Spiellogik verwenden.

## Aktueller Stand

Stand: 2026-09-06. P0 / Issue #1 ist implementiert und vollständig abgenommen: gemeinsames Godot-Projekt, zwei Export-Presets, kleine 3D-Diagnoseszene, Smoke-Runner und CI. Windows-/Web-Starts und manuelle Hardwaretastaturtests für Y/Z, Shift, Echo, Überlappung, Modifier/Browser-Shortcuts und Fokus sind bestanden.

**P1a / Issue #2 ist abgenommen und über PR #12 nach `main` gemergt** (`5ddf921fdf3736f9e521b8e37b833139beee636f`). Der testbare Kern enthält `CourseData`, getrennte Graph-/Layoutvalidierung, versionierte Identität, `RunSession`, monotone Uhr und den Eingabeadapter. Nach Review-Nacharbeit: `core` mit 127 und `all` mit 158 Assertions, beide Exporte und CI erfolgreich.

**P1b / Issue #3 ist abgenommen und über PR #13 nach `main` gemergt** (`e8e947e4100c8f3e534ae425752ac2c30c7fee7a`). Der reguläre Einstieg ist ein validierter 26-Feld-Handparcours mit zwei Routen, Rückwegen, grundfarbrelativem Besuchs-/Nachbarstatus, Figur, kontinuierlicher Rückkamera, Timer, Fehlerfeedback, Quick Restart und minimaler Escape-Rückmeldung. `integration` umfasst 189 Assertions, `all` 350; beide Exporte, PR-CI und `main`-CI sind erfolgreich. Die physische/manuelle Windows-Spielabnahme ist bestanden. Die physische Chrome-Abnahme wird aufgrund der bestätigten Windows-Priorität später nachgeholt und war ausdrücklich kein Mergeblocker für P1b.

**P1c / Issue #4 ist abgenommen und über PR #14 nach `main` gemergt** (`63f1851dc9e3cf2ee72412b1a352ce5a191cbac2`). Der lokale versionierte Ergebnisspeicher hält Bestzeiten und Top 10 je vollständiger Strecken-/Regelidentität, bewahrt bis zu 100 Läufe, behandelt exakte Gleichstände deterministisch und zeigt die Originalzeit zusätzlich in Mikrosekunden. Backup-only-Recovery bleibt auch bei einem Ersetzungsfehler lesbar. Auf dem finalen PR-Stand bestanden Import, `storage` mit 67, `integration` mit 218 und `all` mit 446 Assertions sowie Windows- und Web-Releaseexport; Windows-/Chrome-Persistenz und der eingeschränkte Chrome-Speicherfall wurden tatsächlich geprüft. Die separat verschobene physische P1b-Chrome-Eingabeabnahme bleibt offen.

Die P1b-Kamera-/Beschriftung ist noch nicht als endgültige Darstellung festgelegt. Die großen weißen Nahbereichs-Callouts sollen in P2a möglichst entfallen; die Tile-Beschriftungen selbst sollen aus der üblichen Third-Person-Perspektive gut lesbar orientiert werden. Für den aktuellen Handkurs ist gegenüber dem P1b-Stand eine 90°-Drehung der Beschriftung im Uhrzeigersinn als konkrete Folgearbeit dokumentiert.

Für P1 gilt: Start durch den ersten Bewegungsbuchstaben, kein Countdown; Backspace als Quick Restart zurück in Bereitschaft; Escape als getrennte Pausemenü-Anforderung. 200 ms Fehlerpause ohne Puffer/Verlängerung, A–Z, Rückwege und Fokusinvalidierung sind als PoC-Regeln freigegeben. Details und Randfälle stehen zentral im [P1-Regelprofil](docs/p1-rule-profile.md).

## Dokumentation

| Datei | Inhalt |
| --- | --- |
| [Entscheidungen](docs/decisions.md) | Bestätigte Anforderungen, PoC-Freigaben, Vorschläge und offene Entscheidungen |
| [P1-Regelprofil](docs/p1-rule-profile.md) | Verbindlicher Start-/Eingabe-/Fehler-/Restart-/Menü-/Fokusvertrag |
| [P1b-Integration](docs/p1b-implementation.md) | Szenen-/Eingabe-/Darstellungsvertrag und Abnahme des ersten Spielparcours |
| [P1c-Ergebnisspeicher](docs/p1c-local-results.md) | Implementierter Speicher-, Gleichstands-, UI- und Abnahmevertrag |
| [P1b-Spielbarkeit](docs/p1b-playability.md) | Reaktionsgefühl, Feldstatus, Windows-Abnahme und visuelle Folgearbeit |
| [Spieldesign](docs/game-design.md) | Spielschleife, Bewegung, Kamera und Parcours |
| [Architektur](docs/architecture.md) | Gemeinsamer Spielkern und Windows-/Web-Profile |
| [Roadmap](docs/roadmap.md) | Meilensteine und tatsächlicher Fortschritt |
| [Umsetzungspakete](docs/implementation-plan.md) | Issues, Abhängigkeiten, Branches und Liefervertrag |
| [Teststrategie](docs/testing.md) | Testvertrag, automatisierte Regeln und reale Plattformabnahme |
| [Entwicklung](docs/development.md) | Gepinnter Editor/Templates, lokale Befehle und P0-Diagnose |
| [Arbeitsregeln](AGENTS.md) | Änderungs-, Dokumentations- und Übergaberegeln |

## Nächster Arbeitsschritt

**P2a / Issue #5: lesbare Routenentscheidungen und erprobte Parcours-Bausteine.** Die Abhängigkeiten sind erfüllt: P1c ist abgenommen/gemergt und der echte P1-Spieltest auf Windows ist bestanden. P2a soll handgestaltete Entscheidungsabschnitte, ihre Anschluss-/Geometrieverträge, vorausschauende Kamera und die Tile-Beschriftung praktisch erproben. Die großen weißen P1b-Callouts sollen möglichst entfallen; die bekannten 90°-Beschriftungsfolgearbeit und D-023/D-024 sind verbindlich.

Erst auf Grundlage dieser real erprobten Bausteine werden P2b-Grafikgestaltung und P3a-Generator fortgesetzt. P2a zieht weder Generator noch finale Assetproduktion vor.

## Zusammenarbeit

Festlegungen gehören ins Repository, nicht ausschließlich in Chats oder Issue-Kommentare. Änderungen an Regeln, Technik oder Umfang aktualisieren im selben PR die betroffenen Dokumente. Freigabe, Implementierung und Abnahme sind unterschiedliche Zustände. Implementierungen laufen über Arbeitsbranches und Draft-PRs; kein automatischer Merge.
