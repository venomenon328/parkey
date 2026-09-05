# Parkey

Ein 3D-Speedrun-Spiel über Tippgeschwindigkeit, räumliche Orientierung und Routenwahl.

Eine Spielfigur bewegt sich in Third-Person-Ansicht über einen Parcours aus beschrifteten Feldern. Der Buchstabe eines erreichbaren Nachbarfelds ist die Taste für den nächsten Schritt. Korrekte Eingaben sollen ohne künstliche Geschwindigkeitsbegrenzung verarbeitet werden. Tippfehler verursachen dagegen eine kurze Bewegungssperre. Unterschiedliche Wege können kürzer und schwieriger oder länger und flüssiger tippbar sein.

**Hauptziel:** eine grafisch hochwertige Windows-Anwendung mit Godot. Eine zusätzliche Browserversion soll möglichst dieselbe Codebasis und Spiellogik verwenden.

## Aktueller Stand

Stand: 2026-09-05. Das Repository enthält die initiale Produkt-, Technik- und PoC-Planung. Es gibt noch kein Godot-Projekt, keinen implementierten Generator, keine automatisierten Spieltests und keine ausführbaren Builds. Die Dokumentation behauptet daher keine bereits nachgewiesene Windows-/Web-Parität.

Bestätigte Anforderungen, vorläufige Testwerte und noch nicht freigegebene Vorschläge sind im Entscheidungsregister getrennt. Insbesondere sind **200 ms Fehlerpause ein vorläufiger Testwert** und das **Kopfschütteln eine vorgeschlagene Rückmeldung**, keine endgültig abgestimmten Balancing- oder Animationsvorgaben.

## Dokumentation

| Datei | Inhalt |
| --- | --- |
| [Entscheidungen](docs/decisions.md) | Verbindliche Anforderungen, Vorschläge und offene Entscheidungen |
| [Spieldesign](docs/game-design.md) | Spielschleife, Eingabe, Fehler, Kamera und Parcours |
| [Architektur](docs/architecture.md) | Gemeinsamer Spielkern, Windows-/Web-Profile und Datenmodell |
| [Roadmap](docs/roadmap.md) | Kleine Umsetzungsschritte mit konkreten Abnahmekriterien |
| [Teststrategie](docs/testing.md) | Regeltests, Plattformprüfungen und Spieltests |
| [Arbeitsregeln](AGENTS.md) | Vorgaben für Änderungen und die Pflege der Dokumentation |

## Nächster Arbeitsschritt

**P0: Gemeinsames Godot-Grundprojekt und Windows-/Web-Export nachweisen.** Danach folgt ein spielbarer, handgebauter Testparcours. Der Zufallsgenerator wird erst auf Basis praktisch geprüfter Streckenbausteine umgesetzt. Details stehen in der Roadmap.

Die vorgeschlagene technische Richtung ist typisiertes GDScript, Forward+ für das hochwertige Windows-Profil und Compatibility für das Web-Profil. Das ist eine zu überprüfende Architektur, noch kein vorhandener Build.

## Zusammenarbeit

Festlegungen und Änderungen an Spielregeln gehören in dieses Repository, nicht ausschließlich in Chats oder Issue-Kommentare. Änderungen an Regeln, Technik oder Umfang müssen im selben Pull Request die betroffenen Dokumente aktualisieren. Ein Plan gilt nicht automatisch als implementiert oder freigegeben.
