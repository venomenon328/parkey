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

**P2a / Issue #5 ist abgenommen und über PR #15 nach `main` gemergt** (`a12cb8f148e6c90d66c6c198b7d923eee9d5eebc`). Der 30-Feld-Referenzkurs enthält zwei handgestaltete Entscheidungen mit gemeinsamem Finale, datenbasierte Abschnittsports/-geometrie, vorausschauende Kamera, auf der Keycap gedrehte Hauptbeschriftungen und eine rein lokale Abschnittsmessung. Die großen weißen P1b-Callouts sind entfernt. Vier menschliche Routenkombinationen wurden funktional fehlerfrei gespielt; die Kamera wird für diesen Referenzkurs akzeptiert. Besuchsstatus hat visuell Vorrang vor erneuter Erreichbarkeit. Die finale PR-CI und der anschließende `main`-CI-Lauf `34028827332` waren erfolgreich. Die kleine Stichprobe belegt keine allgemeine Heuristik „länger = leichter/schneller“. Die physische P1b-Chrome-Eingabeabnahme bleibt separat offen und ist kein P2a-Mergeblocker.

Für P1 gilt: Start durch den ersten Bewegungsbuchstaben, kein Countdown; Backspace als Quick Restart zurück in Bereitschaft; Escape als getrennte Pausemenü-Anforderung. 200 ms Fehlerpause ohne Puffer/Verlängerung, A–Z, Rückwege und Fokusinvalidierung sind als PoC-Regeln freigegeben. Details und Randfälle stehen zentral im [P1-Regelprofil](docs/p1-rule-profile.md).

**P2b / Issue #6 ist visuell nachgearbeitet; erneute subjektive Nutzerabnahme offen.** Die Tastatur-Werkstatt zeigt geschlossene gerundete Keycaps mit formatgerecht eingepasster Druckschrift, rein visuellem Hub, animierter Figur, Wolkenhimmel und mittigem Stoppuhr-HUD mit F3-Diagnosen. P2a-Geometrie und Kernregeln bleiben erhalten. `presentation` 298, `integration` 233 und `all` 843 Assertions sowie beide Releaseexporte sind erfolgreich. Reale Windows-1080p-/1440p- und Desktop-Chrome-Läufe, Bilder, Leistungsdaten und Assetquellen stehen im [P2b-Bericht](docs/p2b-visual-slice.md). Der PR bleibt Draft.

## Dokumentation

| Datei | Inhalt |
| --- | --- |
| [Entscheidungen](docs/decisions.md) | Bestätigte Anforderungen, PoC-Freigaben, Vorschläge und offene Entscheidungen |
| [P1-Regelprofil](docs/p1-rule-profile.md) | Verbindlicher Start-/Eingabe-/Fehler-/Restart-/Menü-/Fokusvertrag |
| [P1b-Integration](docs/p1b-implementation.md) | Szenen-/Eingabe-/Darstellungsvertrag und Abnahme des ersten Spielparcours |
| [P1c-Ergebnisspeicher](docs/p1c-local-results.md) | Implementierter Speicher-, Gleichstands-, UI- und Abnahmevertrag |
| [P2b-Visual-Slice](docs/p2b-visual-slice.md) | Gestaltungsvertrag, Profile, Assetquellen und Render-/Leistungsnachweise |
| [P2a-Routenentscheidungen](docs/p2a-route-decisions.md) | Abschnittsports, Referenzkurs, Tipp-Hypothesen, Messung und Abnahmegrenzen |
| [P1b-Spielbarkeit](docs/p1b-playability.md) | Reaktionsgefühl, Feldstatus, Windows-Abnahme und visuelle Folgearbeit |
| [Spieldesign](docs/game-design.md) | Spielschleife, Bewegung, Kamera und Parcours |
| [Architektur](docs/architecture.md) | Gemeinsamer Spielkern und Windows-/Web-Profile |
| [Roadmap](docs/roadmap.md) | Meilensteine und tatsächlicher Fortschritt |
| [Umsetzungspakete](docs/implementation-plan.md) | Issues, Abhängigkeiten, Branches und Liefervertrag |
| [Teststrategie](docs/testing.md) | Testvertrag, automatisierte Regeln und reale Plattformabnahme |
| [Entwicklung](docs/development.md) | Gepinnter Editor/Templates, lokale Befehle und P0-Diagnose |
| [Arbeitsregeln](AGENTS.md) | Änderungs-, Dokumentations- und Übergaberegeln |

## Nächster Arbeitsschritt

**P2b / Issue #6 nach der visuellen Nacharbeit erneut abnehmen.** Das bestätigte Briefing ist als Tastatur-Werkstatt mit gegliederter Figur, Keycap-Hub und neuem HUD/Debug-Modus umgesetzt. Technische Nachweise und offene Nutzerabnahme stehen im [P2b-Bericht](docs/p2b-visual-slice.md). P3-Inhalte sind nicht vorgezogen; kein automatischer Merge.


## Zusammenarbeit

Festlegungen gehören ins Repository, nicht ausschließlich in Chats oder Issue-Kommentare. Änderungen an Regeln, Technik oder Umfang aktualisieren im selben PR die betroffenen Dokumente. Freigabe, Implementierung und Abnahme sind unterschiedliche Zustände. Implementierungen laufen über Arbeitsbranches und Draft-PRs; kein automatischer Merge.
