# Parkey

Ein 3D-Speedrun-Spiel über Tippgeschwindigkeit, räumliche Orientierung und Routenwahl.

Eine Spielfigur bewegt sich in Third-Person-Ansicht über einen Parcours aus beschrifteten Feldern. Der Buchstabe eines erreichbaren Nachbarfelds ist die Taste für den nächsten Schritt. Korrekte Eingaben sollen ohne künstliche Geschwindigkeitsbegrenzung verarbeitet werden. Tippfehler verursachen dagegen eine kurze Bewegungssperre. Unterschiedliche Wege können kürzer und schwieriger oder länger und flüssiger tippbar sein.

Das Streckenmodell ist nicht auf ein regelmäßiges Raster oder eine feste Nachbarzahl beschränkt. Unterschiedlich angeordnete, geformte und moderat verschieden große Felder müssen klar erkennbare direkte Übergänge haben. Die Darstellung folgt dem Tipptempo, nicht umgekehrt; spielrelevante räumliche Layoutänderungen gehören zur Streckenidentität. Diese Festlegungen sind spezifiziert, noch nicht als Parcours implementiert.

**Hauptziel:** eine grafisch hochwertige Windows-Anwendung mit Godot. Eine zusätzliche Browserversion soll möglichst dieselbe Codebasis und Spiellogik verwenden.

## Aktueller Stand

Stand: 2026-09-05. Die Dokumentationsbasis und **neun abgegrenzte Umsetzungspakete als Issues #1–#9** sind vorbereitet. P0 / Issue #1 ist implementiert und vollständig abgenommen: Es gibt ein gemeinsames Godot-Projekt, zwei Export-Presets, eine kleine 3D-Diagnoseszene, den Smoke-Runner und CI. Windows- und Web-Export wurden tatsächlich gestartet; die manuelle Hardwaretastaturabnahme für Y/Z, Shift, echtes Echo, überlappende Tasten sowie Modifier/Browser-Shortcuts und Fokus ist bestanden. Der erste spielbare Parcours, ein Generator, RunSession, Timer und Ranglisten sind weiterhin nicht implementiert.

Bestätigte Anforderungen, vorläufige Testwerte und Vorschläge sind getrennt. **200 ms Fehlerpause** bleiben ein vorläufiger Testwert; das **Kopfschütteln** eine vorgeschlagene Rückmeldung. Das konkrete PoC-Regelprofil wird vor P1a als Experiment beauftragt oder angepasst, nicht stillschweigend zur endgültigen Produktentscheidung erklärt.

## Dokumentation

| Datei | Inhalt |
| --- | --- |
| [Entscheidungen](docs/decisions.md) | Bestätigte Anforderungen, Vorschläge und offene Entscheidungen |
| [Spieldesign](docs/game-design.md) | Spielschleife, Eingabe, Fehler, Kamera und Parcours |
| [Architektur](docs/architecture.md) | Gemeinsamer Spielkern und Windows-/Web-Profile |
| [Roadmap](docs/roadmap.md) | Meilensteine und tatsächlicher Fortschritt |
| [Umsetzungspakete](docs/implementation-plan.md) | Issues, Abhängigkeiten, Branches, Start-Gates und Codex-Empfehlungen |
| [Teststrategie](docs/testing.md) | Testvertrag, automatisierte Regeln und reale Plattformabnahme |
| [Entwicklung](docs/development.md) | Gepinnter Editor/Templates, lokale Befehle und P0-Diagnose |
| [Arbeitsregeln](AGENTS.md) | Änderungs-, Dokumentations- und Übergaberegeln |

## Nächster Arbeitsschritt

[**Issue #2 — P1a: Testbarer Spielkern mit Streckenvalidierung, Laufzeit und Fehlerpause**](https://github.com/venomenon328/parkey/issues/2) ist das nächste Umsetzungspaket. Vor Beginn wird das in `docs/implementation-plan.md` beschriebene experimentelle PoC-Regelprofil ausdrücklich beauftragt oder angepasst; der Arbeitsbranch entsteht anschließend vom aktuellen `main`.

Danach folgen ein handgebauter spielbarer Parcours und lokale Bestzeiten. Erst erprobte Routenbausteine werden zufallsgeneriert. Die vollständige Reihenfolge steht im Umsetzungsplan. Spätere Branches erst nach ihren Abhängigkeiten vom dann aktuellen `main` erstellen.

## Zusammenarbeit

Festlegungen gehören in dieses Repository, nicht ausschließlich in Chats oder Issue-Kommentare. Änderungen an Regeln, Technik oder Umfang aktualisieren im selben PR die betroffenen Dokumente. Ein Plan ist weder Implementierung noch Abnahme. Implementierungen laufen über die jeweiligen Arbeitsbranches und Draft-PRs.
