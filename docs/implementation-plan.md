# Umsetzungspakete und Arbeitsablauf

Stand: 2026-09-05. Auf Auftrag wurden Issue #1 präzisiert und #2–#9 angelegt. **P0 ist implementiert und vollständig abgenommen; alle späteren Pakete sind Planungsstand.** Die Issues sind ausführbare Arbeitspakete, keine Freigabe aller bisherigen Produktvorschläge. Maßgeblich bleiben [Entscheidungsregister](decisions.md), [Spieldesign](game-design.md), [Architektur](architecture.md), [Teststrategie](testing.md) und `AGENTS.md`.

## Paketübersicht

| Paket / Issue | Ergebnis | Start erst nach | Arbeitsbranch | Codex-Empfehlung |
| --- | --- | --- | --- | --- |
| P0 / [#1](https://github.com/venomenon328/parkey/issues/1) | Ein Projekt, zwei Exporte, minimale Test-/CI-Grundlage | Beauftragung | `codex/p0-godot-foundation` | GPT-5.6 Terra · High |
| P1a / [#2](https://github.com/venomenon328/parkey/issues/2) | CourseData, Validator, RunSession, Zeit und Fehlerfrist | #1; experimentelles Regelprofil beauftragt | `codex/p1a-run-core` | GPT-5.6 Terra · High |
| P1b / [#3](https://github.com/venomenon328/parkey/issues/3) | Erster spielbarer handgebauter Third-Person-Lauf | #2 | `codex/p1b-playable-course` | GPT-5.6 Terra · High |
| P1c / [#4](https://github.com/venomenon328/parkey/issues/4) | Dauerhafte lokale Bestzeiten und Ergebnisschirm | #3 | `codex/p1c-local-leaderboards` | GPT-5.6 Terra · Medium |
| P2a / [#5](https://github.com/venomenon328/parkey/issues/5) | Erprobte Routen und vorausschauende Kamera | #4; echter P1-Spieltest | `codex/p2a-route-decisions` | GPT-5.6 Terra · High |
| P2b / [#6](https://github.com/venomenon328/parkey/issues/6) | Hochwertige Windows-Beispielwelt, Web-Fallback | #5; Zielhardware/Budget klären | `codex/p2b-visual-slice` | GPT-6 Astra · Medium |
| P3a / [#7](https://github.com/venomenon328/parkey/issues/7) | Deterministischer validierter Generator | #5; Bausteinfreigabe | `codex/p3a-seeded-generator` | GPT-5.6 Terra · Very High |
| P3b / [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Spielablauf und Export-Konformitätsnachweis | #6 und #7 | `codex/p3b-seed-game-flow` | GPT-5.6 Terra · High |
| P4 / [#9](https://github.com/venomenon328/parkey/issues/9) | PoC-Abnahme und reproduzierbare Testpakete | #8 | `codex/p4-poc-acceptance` | GPT-5.6 Terra · High |

Abhängigkeiten bedeuten **abgenommen und nach main gemergt**, nicht nur „ein PR wurde eröffnet“. Sie sind in Issues und dieser Tabelle dokumentiert. Ein offenes Issue kann weiterhin durch diese Bedingungen blockiert sein. Die Branchliste legt Namen fest, behauptet aber nicht, dass alle Branches schon existieren. P0 ist abgeschlossen; spätere Branches werden beim jeweiligen Start vom dann aktuellen `main` erstellt.

Die einzige vorgesehene Parallelität ist #6/#7 nach #5. Darstellung versus Generator sind getrennte Zuständigkeiten; gemeinsame Verträge nicht unabhängig ändern. Standard bleibt ein Paket pro PR. #8 wartet auf beide Ergebnisse, damit die Integration nicht auf zwei beweglichen Grundlagen erfolgt.

## Warum dieser Zuschnitt?

P1 wird nicht als Großauftrag aus Eingabelogik, Animation, Kamera und Dateisystem vergeben. Zunächst werden die Regeln ohne Grafik getestet, dann tatsächlich gespielt, anschließend Resultate zuverlässig gespeichert. Der erste praktische Lauf ist damit bereits nach #3 möglich.

P2 trennt die Spielentscheidung von der Ausarbeitung des Looks. Ein Generator soll nur Abschnitte vervielfältigen, deren Eignung zuvor tatsächlich geprüft wurde. P3 trennt den schwierigen deterministischen Algorithmus von seiner UI-/Speicher-/Plattformintegration. P4 prüft die zusammengesetzte Anwendung und liefert Testpakete, statt eine unbegrenzte Restefeatureliste zu eröffnen.

## Vorgeschlagenes experimentelles Regelprofil für P1

**Noch nicht als endgültige Produktentscheidung bestätigt.** Vor Beginn von #2 dieses Profil ausdrücklich als PoC-Experiment mitbeauftragen oder die Abweichungen dokumentieren. Eine reine Bitte um Issues ersetzt diese Freigabe nicht. Das Profil konkretisiert die vorhandenen Vorschläge P-003 bis P-006, ohne D-001 bis D-013 zu ersetzen. D-010 bis D-013 sind inzwischen bestätigt; die übrigen noch offenen Start-/Fehler-/Fokusdetails bleiben davon getrennt.

| Bereich | Konkreter Vorschlag für den Test |
| --- | --- |
| Bewegung | A–Z, Groß-/Kleinschreibung gleich; explizite beidseitige Verbindungen und Rückwege. Kein allgemeiner Raster-/Richtungs- oder fester Nachbarzahlzwang; ein gültiger Übergang bleibt ein Eingabeschritt. |
| Tastatur | Angezeigter Buchstabe zählt. Nur neue Key-down-Ereignisse; Echo/Key-up ignorieren. Shift/Caps dürfen die Großschreibung ändern; Ctrl/Alt/Meta-Kombinationen und Nicht-A–Z-Zeichen sind keine Bewegungsversuche. UI-Texteingaben nicht ans Spiel durchreichen. |
| Ereignisreihenfolge | Empfangsreihenfolge, auch bei gleichen Zeitwerten; kein künstliches Warten auf alle losgelassenen Tasten. Mehrere gültige Ereignisse ohne Renderfortschritt möglich. |
| Start | Enter aus Bereit startet einen 3-Sekunden-Countdown. Erst ab festem Startzeitpunkt werden neue Bewegungsereignisse gewertet; keine Countdown-Eingaben puffern. |
| Restart/Abbruch | Backspace startet denselben Parcours als neuen Versuch über denselben Countdown; Escape bricht ab. Menü-/Steuertasten sind keine falschen Buchstaben. Fokusverlust invalidiert den aktuellen Versuch, keine kostenlos pausierte Wertung. |
| Fehler | Vorläufig 200 ms Sperre; Timer läuft; währenddessen Bewegungsversuche verwerfen, nicht puffern, nicht nachzählen und Frist nicht verlängern. Ab exakt Fristende neue Eingaben normal prüfen. Keine zusätzliche Zeitaddition. |
| Ziel | Zeit beim gültigen logischen Zieleingang, genau ein gewertetes Ergebnis. Animationen und Speicherantworten verändern die Zeit nicht. |
| Zeit/Identität | Monotone Integer-Mikrosekunden, Anzeige mit drei Millisekundennachkommastellen. Wertungsrelevante Einstellungen einschließlich Sperrdauer gehören zur Regelidentität; relevante räumliche Layoutdaten gemäß D-013 zur Streckenidentität. |

Countdownlänge und Steuertasten sind hier neue **konkrete Vorschläge**, keine rückwirkend behaupteten Nutzerwünsche. Technische Details wie konkrete Klassennamen dürfen im zuständigen Paket begründet angepasst werden. Ein endgültig anderes Spielverhalten benötigt dagegen eine dokumentierte Entscheidung und passende Tests. Spätere Balancingänderungen verändern die betroffenen Regel-/Wertungsprofile.

## Konkretisierung der Pakete: nicht rastergebundene Strecken

D-010 bis D-013 sind auf Nutzerauftrag in die bestehenden Pakete eingearbeitet. P0 bleibt abgeschlossen; diese Dokumentationsänderung implementiert noch keine Geometrie oder neue Tests. Paketgrenzen, Branches und Abhängigkeiten bleiben bestehen.

| Paket | Verbindliche Abgrenzung |
| --- | --- |
| P1a / #2 | Explizite Nachbarlisten und getrennte Graph-/Layoutvalidierung. Kein allgemeines Orthogonalitäts- oder Vier-Nachbarn-Limit. Test mit fünf eindeutigen Nachbarn sowie Layoutvariation bei unveränderten logischen Eingabe-/Zeitresultaten. Kleiner Layout-/Identitätsvertrag, kein universelles Geometriesystem. |
| P1b / #3 | Einfacher Handparcours mit mindestens einer unregelmäßigen Stelle: moderate Größenvariation und klar lesbarer schräger Übergang. Anker/Bewegung sinnvoll anpassen, kein größen-/entfernungsabhängiges Warten. |
| P1c / #4 | Ranglisten auch bei gleichem Graphen mit unterschiedlichen spielrelevanten Layoutdaten trennen. Reine Kosmetik verändert die Identität nicht. |
| P2a / #5 | Asymmetrische Routen, variable Anschlüsse und Geometrie praktisch erproben; Größenbereiche und Fugentoleranzen dokumentieren. Keine feste Nachbarzahl als Produktregel. |
| P2b / #6 | Moderate variable Feldformen/-größen und lesbare Übergänge in beiden Grafikprofilen erhalten. Kein grafisch erzwungenes Bewegungslimit; die Gestaltung darf das gespeicherte Layout nicht heimlich verändern. |
| P3a / #7 | Generator liefert Graph und validiertes räumliches Layout mit eigener kontrollierter Zufallsableitung. Golden-Fälle und Identität binden Layoutdaten; kein willkürlicher vollständiger Polygon-Generator erforderlich. |
| P3b / #8 | Exportvergleich umfasst räumliche Daten/Hashes und deren Ranglistentrennung. Gleiche Ereignisprotokolle bleiben unabhängig von Darstellungsabständen im Kern gleich schnell. |
| P4 / #9 | Gesamtabnahme schließt D-010 bis D-013 ein, ohne P0 erneut zu öffnen oder weitere Spielmechaniken vorwegzunehmen. |

## Gemeinsamer Liefer- und Testvertrag

Ein Paket liefert Implementierung, passende Tests, gepflegte Dokumentation und konkrete Nachweise. In jedem Issue stehen messbare Abnahmekriterien, Nicht-Ziele und ein kompakter Codex-Prompt. Vollständige Issue-Inhalte werden nicht noch einmal in den Prompt kopiert.

[docs/testing.md](testing.md) definiert die verpflichtenden CLI-Einstiege. **P0 hat den Runner, die Export-Presets und die minimale CI angelegt; diese Grundlage ist abgenommen.** Jedes Folgepaket ergänzt seine Testsuite und hält alle bisherigen Tests sowie beide Exportjobs grün. Unbekannte/leere Testsuiten dürfen nicht erfolgreich durchlaufen.

Reale Grafik, Hardwaretastatur, Browserpersistenz und subjektives Spielgefühl sind separate Nachweise. Eine nicht vorhandene Testumgebung rechtfertigt keine erfundene Abnahme. Für P0 wurden native Windows-/Web-Starts sowie die manuelle Hardwaretastaturprüfung vollständig bestanden. In Folgepaketen kann CI die automatisierbaren Teile übernehmen; fehlende echte Windows-/Spieltests ergänzt der Nutzer. Solange ein verpflichtender Nachweis fehlt, bleibt die jeweilige Abnahme offen und der PR Draft.

## Branch, PR und Dokumentationspflege

Vom aktuellen `main` starten, nicht vom alten Planungscommit. Vor Änderungen Issue, Dokumente und tatsächlichen Code lesen. Nach Umsetzung Tests ausführen, Code und zugehörige Dokumentation gemeinsam committen/pushen und einen **Draft-PR gegen main** mit Issue-Verknüpfung erstellen. Nicht automatisch mergen. Erst nach vollständiger technischer und erforderlicher manueller Abnahme in den Review-/Mergeprozess übergehen.

README/Roadmap zeigen die Wahrheit: „implementiert, Test X offen“ ist nicht „abgenommen“. Bei neuen Entscheidungen zuerst Register/Spezifikation, dann betroffene noch offene Issues aktualisieren. Umfangreiche neue Erkenntnisse als eigenes enges Folgepaket, nicht in P4 verstecken. Keine öffentliche Release-Veröffentlichung, Hostingkosten oder endgültige Projektlizenz ohne Auftrag.

## Codex-Auswahl und Eigenumsetzung

Die Auswahl in der Tabelle ist eine projektspezifische Empfehlung, keine Garantie eines bestimmten Tokenverbrauchs. Begründungen stehen zusätzlich in jedem Issue: Terra High für zusammenhängende Mehrdateienpakete; Terra Medium für den nach stabilen Verträgen isolierten lokalen Speicher; Terra Very High nur für die anspruchsvolle Generator-/Retry-/Determinismussemantik. Astra Medium ist gezielt für den visuellen Ausschnitt vorgesehen, nicht pauschal für jede Aufgabe. Wenn im verwendeten Codex noch nicht verfügbar, ist für #6 **GPT-5.6 Terra · High** die Ausweichwahl.

**Selbst umsetzbar: Teilweise** für die vollständigen neun Implementierungspakete mit ihren jeweiligen Abnahmen. GitHub-Änderungen, Codebearbeitung, Reviews und Commit/Push sind mit den verfügbaren Werkzeugen möglich. Für P0 standen Godot 4.7.2, Export-Templates sowie Windows- und Chrome-Laufzeit zur Verfügung; Import, Exporte, technische Render-/Eingabediagnosen und die manuelle Hardwaretastaturabnahme wurden erfolgreich durchgeführt. Größere zusammenhängende Implementierungen gehen bevorzugt an Codex mit geeigneter Laufzeit. Kleine isolierte Fehlerbehebungen, Reviews und Dokumentationsänderungen werden bevorzugt direkt übernommen; deren konkrete Testbarkeit wird unmittelbar vor der Aufgabe erneut geprüft.

Bei späteren Nacharbeiten enthält der Prompt nur Repository/Branch, aktuellen PR-Review, Pflichtbefehle und Übergaberegeln; die Reviewpunkte werden nicht vollständig wiederholt. Modell, Reasoning und Eigenumsetzbarkeit werden unmittelbar vor dem neuen Auftrag erneut beurteilt, nicht nur rückblickend genannt.

## Quellen zur Werkzeugwahl

Primärquellen geprüft am 2026-09-05; kontospezifische Codex-Verfügbarkeit ist damit nicht nachgewiesen. Die Paket-/Reasoningauswahl bleibt unsere Einschätzung.

- GPT-5.6-Familie: https://openai.com/index/gpt-5-6/
- Terra-Modell: https://developers.openai.com/api/docs/models/gpt-5.6-terra
- Astra-Modell: https://developers.openai.com/api/docs/models/gpt-6-astra
- Godot-Befehle: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Web-Export und Threading: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
