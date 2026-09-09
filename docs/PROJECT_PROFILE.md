# Projektprofil: Parkey

## Projekt und Quellen

`venomenon328/parkey` entwickelt ein 3D-Speedrun-Spiel über Tippgeschwindigkeit, Orientierung und Routenwahl. Windows ist die führende Plattform; Web soll denselben Spielkern verwenden. Der [gemeinsame Workflow](dev-rules/WORKFLOW.md) regelt den Prozess, dieses Profil die Projektanwendung. [Herkunft und Regelabgleich](DEV_RULES_ADOPTION.md) dokumentieren die Einführung.

Bei fachlicher Planung und Produktänderungen das [Entscheidungsregister](decisions.md) vollständig sowie die betroffenen vollständigen Abschnitte von [Spieldesign](game-design.md) und [Architektur](architecture.md) lesen. Hinzu kommen auftragsbezogen die folgenden Fachverträge; ausdrücklich als vollständig vorgeschriebene Issue-Quellen bleiben vollständig zu lesen.

| Gegenstand | Pflichtquelle |
| --- | --- |
| Start, Eingaben, Fehlerfrist, Restart, Menü und Fokus | [P1-Regelprofil](p1-rule-profile.md) |
| Spielszene, Kamera, Darstellung und Spielgefühl | [P1b-Integration](p1b-implementation.md), [Spielbarkeit](p1b-playability.md) und [P2a-Routenvertrag](p2a-route-decisions.md) |
| Ranglisten, Ergebnisablage und Recovery | [P1c-Ergebnisvertrag](p1c-local-results.md) |
| Test-/Exportverträge und reale Plattformabnahme | Betroffene Abschnitte von [testing.md](testing.md) |
| Toolchain, Einrichtung und Befehle | [development.md](development.md), [Engine-Pin](../godot-version.txt), [CI](../.github/workflows/ci.yml) |
| Paketplanung und technische Voraussetzungen | Betroffener Eintrag im [Implementierungsplan](implementation-plan.md) und aktuelles Issue/PR |

Für reine Prozessdokumentation genügt die Prüfung der betroffenen Regelquellen; kein erneutes vollständiges Spieldesignreview. Historische Statusabschnitte sind keine laufenden Aufträge. Aktuelle Issues und PRs prüfen; keine neue Regeldatei als fachliche Freigabe offener visueller oder anderer Produktentscheidungen interpretieren.

## Fachliche Verträge bleiben erhalten

Die Einführung ändert keine D-Entscheidung, PoC-Freigabe, Spielregel, Streckenidentität oder Speichersemantik. Bestätigte Anforderungen, vorläufige Werte, Vorschläge und offene Fragen bleiben getrennt. Für fachliche Änderungen das Register und die betroffenen Spezifikationen konsistent mitführen.

Besonders zu schützen sind unmittelbare korrekte Eingaben ohne Darstellungs-Cooldown, die gesonderte Fehlerpause, explizite nicht rastergebundene Nachbarschaft, getrennte Graph-/Layoutvalidierung und die Einbeziehung spielrelevanter Geometrie in die Wertungsidentität. Keine zweite Windows-/Web-Spielimplementierung und keine nachträgliche Umdeutung reiner Kosmetik zu Regeländerungen oder umgekehrt.

## Begründete technische Festlegungen

Den bestehenden Godot-Standardeditor-/Template-Pin und echten GDScript-Prüfpfad beibehalten: Sie sichern die gemeinsame Codebasis und reproduzierbare Exporte. Die tatsächlichen Versionen stehen in den oben verlinkten technischen Quellen; diese Einführung ist kein Engine-Upgrade.

Die lokale Windows-Werkzeugablage aus `development.md` bleibt als bewusst gewählte Umgebungskonvention erhalten. Sie vermeidet weitere verstreute Installationen; sie ist keine fachliche Spielregel und keine Vorschrift für andere Projekte. Keine zusätzliche Pflichtinstallation bei einem reinen Dokumentauftrag. Vorhandene Ordner und Benutzerdaten nicht ohne Auftrag bereinigen.

Tests verwenden die isolierten Testpfade aus `development.md` und dem Speichervertrag, niemals echte Benutzerbestzeiten. Secrets und ungeklärte Fremdassets nicht committen. Plattformverträglichkeit und Nutzungsrechte neuer Abhängigkeiten/Assets vor Aufnahme prüfen. Keine Lizenzfestlegung, öffentliche Veröffentlichung oder kostenpflichtigen Dienste ohne passenden Auftrag.

## Verifikation

Der aktuelle GitHub-Actions-Prüfpfad **Godot verification / verify** bleibt vor Merge verpflichtend. Er importiert das Projekt, führt alle vorhandenen Suites im echten GDScript-Runner aus und erzeugt beide Release-Exporte. Die kanonischen Abschlussbefehle sind:

```sh
godot --headless --path . --import
godot --headless --path . --script res://tests/run_tests.gd -- --suite all
godot --headless --path . --export-release "Windows Desktop" build/windows/parkey.exe
godot --headless --path . --export-release "Web" build/web/index.html
```

Vor Export die Ausgabeordner anlegen. Gezielte vorhandene Suites während der Arbeit nach betroffenem Bereich nutzen. Die Beispielsequenz sämtlicher Einzelsuites in `development.md` ist kein zusätzlicher Pflichtlauf unmittelbar vor oder nach einem vollständig nachgewiesenen `all`. Geplante Suites nicht als vorhanden behaupten; unbekannte oder leere Suites und Laufzeit-/Assertionfehler dürfen nicht erfolgreich enden.

Lokale Prüfungen sind in einer geeigneten vorhandenen Umgebung erlaubt; es wird kein Testverbot aus einem anderen Projekt übernommen. Für denselben unveränderten Stand genügt ein belastbarer passender CI-Nachweis, statt zusätzlich denselben Gesamtbuild lokal zu wiederholen. Welche tatsächliche Plattform geprüft wurde, offen angeben. Produktänderungen benötigen die im Issue und Testvertrag vorgesehenen zusätzlichen Nachweise.

Den vollständigen Paketdiff, neue Dateiverweise und `git diff --check <Basis-SHA> <Head-SHA>` prüfen. Für die reine Regelintegration laufen die bestehenden CI-Prüfungen unverändert; eine erneute manuelle Spiel-/Grafikabnahme unveränderten Verhaltens ist nicht erforderlich.

## Manuelle Abnahme und Mergewirkung

Headless-Tests, Exporte, synthetische Browserereignisse und reale Hardware-/Grafik-/Spielprüfungen bleiben unterschiedliche Nachweise. Bei spielgefühl-, grafik-, eingabe- oder plattformrelevanten Änderungen konkret erforderliche manuelle Szenarien im Issue/PR vor Merge benennen und durchführen, sofern nicht ausdrücklich anders eingeordnet. Eine bereits bewusst verschobene Plattformabnahme bleibt offen, aber wird durch die Einführung nicht rückwirkend zum Blocker anderer Pakete. Insbesondere die separat dokumentierte P1b-Chrome-Abnahme nicht als bestanden ausgeben.

Ein Merge löst die vorhandene Verifikation aus, keinen veröffentlichten Spielrelease oder Produktivbetrieb. Release, Hosting, Tags, Lizenzentscheidungen und manuelle Veröffentlichung benötigen einen eigenen passenden Auftrag.

## Abgelöste Prozessregeln und Branches

Zielbranch `main`. Für neue Aufgaben gemeinsame Branchkonvention verwenden, bereits konkret benannte `codex/...`-Branches und laufende Aufträge nicht umbenennen. Die bestehenden fachlich/technisch begründeten Paketabhängigkeiten des Implementierungsplans bleiben erhalten; künftige Aufteilungen folgen dem gemeinsamen Workflow statt einer pauschalen Projektregel gegen jede andere sichere Arbeitsaufteilung. Vorbereitung erstellt standardmäßig noch keinen Branch/PR, außer dies ist konkret beauftragt. PR bis zur Abnahme Draft, Standardmerge Squash nach Freigabe, keine automatische Branchlöschung. Technischen Branchschutz nicht ungeprüft voraussetzen oder ungefragt ändern.

Allgemeine Vorgaben zu Quellenzuständigkeit, Scope, PRs, Übergaben, Dokumentpflege und Review im alten AGENTS, README und den Abschnitten „Gemeinsamer Liefer- und Testvertrag“ beziehungsweise „Branch, PR und Dokumentationspflege“ des Implementierungsplans werden durch den gemeinsamen Workflow und dieses Profil ersetzt. Fachtests, konkrete Paketgrenzen und technische Voraussetzungen bleiben maßgeblich. Pflichtlektüre wird auf tatsächliche Auftragsrelevanz beschränkt, nicht auf jedes historische Dokument ausgedehnt.

Das frühere pauschale Verbot, Modell-/Reasoning-/Ausführungsmetadaten im Repository abzulegen, ist ausdrücklich aufgehoben. Die lokale Modellheuristik ist zulässig und verbindlich; optionale wahrheitsgemäße Ausführungsangaben im PR folgen ihr. Einzelne Modellempfehlungen gehören weiterhin nicht in die fachlichen Spielverträge. High-Standard und Qualitätsabwägung stehen ausschließlich in [MODEL_SELECTION.md](dev-rules/MODEL_SELECTION.md).

Projektdokumentation auf Deutsch, Code-Bezeichner auf Englisch beibehalten: konsistente Pflege ohne Übersetzungsumbau. Die [neuen ChatGPT-Projekteinstellungen](CHATGPT_PROJECT_INSTRUCTIONS.md) ersetzen nach Einführungsmerge die alten allgemeinen Entwicklungsanweisungen und den Pflichtverweis auf `Codex-Empfehlung.txt`.
