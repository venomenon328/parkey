# Agenteneinstieg für Parkey

## Pflichtquellen

Vor Entwicklungsarbeit vollständig lesen:

1. [Gemeinsamen Workflow](docs/dev-rules/WORKFLOW.md).
2. [Projektprofil](docs/PROJECT_PROFILE.md) mit seiner auftragsbezogenen Quellenführung.
3. Aktuellen vollständigen Issue-/Paket-Body, sofern vorhanden; bei Review/Nacharbeit zusätzlich PR, tatsächlichen Diff und konkret benannten Reviewstand.

Den beauftragten Arbeitsbranch heranziehen, sonst den aktuellen `main`. Geltende Bereichs-/Override-Regeln prüfen. Eine neue Idee setzt kein vorhandenes Issue voraus; Erinnerungen ersetzen keinen Quellenzugriff.

Nur vor noch auszuführender Implementierung oder konkreten technischen Nacharbeiten zusätzlich [Modellauswahl](docs/dev-rules/MODEL_SELECTION.md) und [Modellkatalog](docs/dev-rules/MODEL_CATALOG.md) vollständig lesen. Keine rückblickende Empfehlung nach erledigter Arbeit.

## Unmittelbar wichtige Fach- und Schutzgrenzen

Korrekte Eingaben werden nicht durch Animationen, Physikticks oder einen allgemeinen Schritt-Cooldown begrenzt. Die ausdrücklich definierte Fehlerpause ist davon getrennt. Logische Wege/Zielankunft und spielrelevante Streckenidentität bleiben unabhängig von bloß kosmetischer Darstellung. Maßgeblich sind die im [Projektprofil](docs/PROJECT_PROFILE.md) verlinkten Fachverträge.

Keine echten Benutzerbestzeiten als Testablage verwenden. Die tatsächlichen GDScript-Tests ausführen, keine Ersatzimplementierung in einer anderen Sprache als Nachweis. Export ist kein Spieltest, Headless kein Grafiktest. Keine ungeprüfte Windows-/Web-Unterstützung oder manuelle Nutzerabnahme behaupten.

Lokale Werkzeuge nur gemäß [Entwicklungsumgebung](docs/development.md) einrichten; vorhandene fremde Werkzeugordner oder Benutzerdaten nicht ungefragt löschen. Keine ungeklärten Fremdassets, Secrets, Lizenz- oder Veröffentlichungsentscheidungen einführen.

## Code Review Rules

Insbesondere unmittelbare Eingabeverarbeitung, deterministische Zeit-/Fehlersemantik, Graph-/Layouttrennung, vollständige Strecken-/Regelidentität und sichere Ergebnispersistenz prüfen. Konkrete Paketabhängigkeiten und bewusst offene Plattformabnahmen beachten. Prozess, Modellauswahl und Befugnisse folgen dem gemeinsamen Workflow; der [Regelabgleich](docs/DEV_RULES_ADOPTION.md) bezeichnet die ersetzten Altregeln.
