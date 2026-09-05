# Umsetzungspakete und Arbeitsablauf

Stand: 2026-09-05. Neun Umsetzungspakete sind als Issues #1–#9 angelegt. **P0 ist abgenommen; P1a ist vorbereitet und das P1-Regelprofil freigegeben, aber noch nicht implementiert.** Grundlage sind [Entscheidungsregister](decisions.md), [P1-Regelprofil](p1-rule-profile.md), [Spieldesign](game-design.md), [Architektur](architecture.md), [Teststrategie](testing.md) und `AGENTS.md`.

## Paketübersicht

| Paket / Issue | Ergebnis | Start erst nach | Arbeitsbranch | Codex-Empfehlung |
| --- | --- | --- | --- | --- |
| P0 / [#1](https://github.com/venomenon328/parkey/issues/1) | Ein Projekt, zwei Exporte, Test-/CI-Grundlage | Bereits abgenommen | `codex/p0-godot-foundation` | GPT-5.6 Terra · High |
| P1a / [#2](https://github.com/venomenon328/parkey/issues/2) | CourseData, Validator, RunSession, Zeit und Fehlerfrist | Voraussetzungen erfüllt; Profil freigegeben | `codex/p1a-run-core` | GPT-5.6 Terra · High |
| P1b / [#3](https://github.com/venomenon328/parkey/issues/3) | Erster spielbarer handgebauter Third-Person-Lauf | #2 | `codex/p1b-playable-course` | GPT-5.6 Terra · High |
| P1c / [#4](https://github.com/venomenon328/parkey/issues/4) | Dauerhafte lokale Bestzeiten und Ergebnisschirm | #3 | `codex/p1c-local-leaderboards` | GPT-5.6 Terra · Medium |
| P2a / [#5](https://github.com/venomenon328/parkey/issues/5) | Erprobte Routen und vorausschauende Kamera | #4; echter P1-Spieltest | `codex/p2a-route-decisions` | GPT-5.6 Terra · High |
| P2b / [#6](https://github.com/venomenon328/parkey/issues/6) | Hochwertige Windows-Beispielwelt, Web-Fallback | #5; Zielhardware/Budget klären | `codex/p2b-visual-slice` | GPT-6 Astra · Medium |
| P3a / [#7](https://github.com/venomenon328/parkey/issues/7) | Deterministischer validierter Generator | #5; Bausteinfreigabe | `codex/p3a-seeded-generator` | GPT-5.6 Terra · Very High |
| P3b / [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Spielablauf und Export-Konformitätsnachweis | #6 und #7 | `codex/p3b-seed-game-flow` | GPT-5.6 Terra · High |
| P4 / [#9](https://github.com/venomenon328/parkey/issues/9) | PoC-Abnahme und reproduzierbare Testpakete | #8 | `codex/p4-poc-acceptance` | GPT-5.6 Terra · High |

Abhängigkeiten bedeuten **abgenommen und nach main gemergt**, nicht nur „ein PR wurde eröffnet“. P0 ist abgeschlossen. Der P1a-Branch enthält die neue Regelfreigabe als Dokumentationsvorbereitung auf Basis von `main` nach PR #11; die Implementierung setzt auf diesem Branch im selben Draft-PR fort. Die Dokumentationsvorbereitung ist kein separates Implementierungspaket und braucht keinen vorgeschalteten Merge. Spätere Branches werden erst beim jeweiligen Start vom dann aktuellen `main` erstellt.

Nur #6/#7 sind nach #5 für Parallelität vorgesehen. Gemeinsame Datenverträge dürfen dabei nicht unabhängig geändert werden; #8 wartet auf beide Abnahmen. Standard bleibt ein Paket pro PR.

## Warum dieser Zuschnitt?

P1 trennt Regeln, Darstellung und Dateisystem: erst testbarer Kern, dann spielbarer Lauf, dann dauerhafte Resultate. Der erste praktische Lauf ist nach #3 möglich. P2 trennt erprobte Entscheidungen von Grafikgestaltung. Der Generator vervielfältigt nur geeignete Abschnitte; P3 trennt Algorithmus von UI-/Speicher-/Plattformintegration. P4 prüft die zusammengesetzte Anwendung und ist keine unbegrenzte Restefeatureliste.

## Freigegebenes Regelprofil für P1

**Die Startfreigabe ist erfolgt.** Maßgeblich ist [p1-rule-profile.md](p1-rule-profile.md), Kennung `p1-input-start-v1`, auf Basis von D-014 bis D-018. Kein Countdown und kein Enter-Start. Der erste Bewegungsbuchstabe startet und wirkt im selben Ereignis; Backspace bereitet denselben Parcours neu vor, Escape ist eine andere Menü-/Pause-Anforderung. Fehler-, Rückweg-, Eingabe- und Fokusregeln sind für P1 freigegeben. Der frühere Vorschlag eines Countdowns und einer Escape-Rücksetzung ist abgelöst.

Die Menüoberfläche und spätere Übungsfortsetzung sind nicht Teil von P1a. P1a liefert nur den getrennten Menüanforderungsvertrag; keine zusätzliche Featurephase. Die vollständigen Randfälle stehen absichtlich nur im Profil statt in mehreren konkurrierenden Tabellen.

Technische Entscheidungen wie Klassen, internes Zustandsmodell, kanonische Zahlenrepräsentation und Toleranzen des kleinen ebenen Layoutprofils werden im Paket dokumentiert und getestet. Dafür ist keine neue pauschale Nutzerfreigabe nötig. Verhaltensänderungen am freigegebenen Profil werden dagegen nicht eigenmächtig vorgenommen. Profil-/Balancingänderungen berücksichtigen die Wertungsidentität. Weitere Grafik-, Online- und Generatorfragen blockieren P1a nicht.

## Nicht rastergebundene Strecken

D-010 bis D-013 bleiben verbindlich. Die neue Regelfreigabe ändert keine Geometrie- oder Geschwindigkeitsgrundsätze und öffnet P0 nicht erneut.

| Paket | Verbindliche Abgrenzung |
| --- | --- |
| P1a / #2 | Explizite Nachbarlisten, getrennte Graph-/Layoutprüfung; kein Orthogonalitäts- oder Vier-Nachbarn-Limit. Fünf-Nachbarn-Test und Layoutvariation bei gleichen logischen Zeiten. Kleiner Layout-/Identitätsvertrag, kein universelles Geometriesystem. |
| P1b / #3 | Einfacher Handparcours mit unregelmäßiger Stelle, moderaten Größenunterschieden und lesbarem schrägem Übergang. Plausible Anker/Bewegung, kein distanzabhängiges Warten. |
| P1c / #4 | Relevante Layoutunterschiede trennen Ranglisten auch bei gleichem Graphen; reine Kosmetik nicht. |
| P2a / #5 | Asymmetrische Routen, variable Anschlüsse und Geometrie erproben; Größenbereiche/Fugen dokumentieren. Keine feste Nachbarzahl als Produktregel. |
| P2b / #6 | Variable moderate Feldformen/-größen und Übergänge in beiden Profilen erhalten. Kein grafischer Tempodeckel oder heimlich geändertes Layout. |
| P3a / #7 | Generator liefert Graph und räumliches Layout mit kontrollierten Zufallsableitungen. Identität/Golden-Fälle binden beides; kein beliebiger Polygon-Generator. |
| P3b / #8 | Exportvergleich umfasst räumliche Daten/Hashes und Ranglistentrennung. Gleiche Eingabeprotokolle ergeben unabhängig von Darstellungsabständen dieselben Kernzeiten. |
| P4 / #9 | Gesamtabnahme umfasst alle bestätigten und PoC-freigegebenen Entscheidungen, ohne spätere Mechaniken vorwegzunehmen. |

## Gemeinsamer Liefer- und Testvertrag

Jedes Paket liefert Implementierung, passende Tests, gepflegte Dokumentation und konkrete Nachweise. Issues enthalten Abnahme, Nicht-Ziele und kompakte Prompts; der Lieferumfang wird nicht nochmals in Prompts kopiert.

[testing.md](testing.md) definiert die CLI-Einstiege. P0 hat `smoke`/`all`, Export-Presets und CI geliefert. P1a ergänzt `core`; weitere Suites sind noch nicht vorhanden. `all` hält alle bisherigen Tests und beide Exportjobs grün. Unbekannte/leere Suites müssen scheitern.

Reale Grafik, Hardwaretastatur, Browserpersistenz und Spielgefühl bleiben gesonderte Nachweise. Keine erfundene Abnahme bei fehlender Umgebung. P0-Starts und Hardwaretests sind bestanden; die neuen P1-Verhaltenstests sind dadurch nicht bereits nachgewiesen. Fehlende verpflichtende Nachweise halten den jeweiligen PR im Draft.

## Branch, PR und Dokumentationspflege

Vor Änderungen aktuelle Quellen und tatsächlichen Code lesen. Neue Paketbranches von aktuellem `main` erstellen; bei vorbereitetem P1a-Branch dessen Dokumentationscommit erhalten und dort fortfahren. Code und betroffene Dokumentation gemeinsam committen/pushen, Draft-PR gegen `main` mit Issue-Verknüpfung pflegen. Nicht automatisch mergen. Technische und erforderliche manuelle Abnahme müssen dem Review-/Mergeprozess vorausgehen.

Statusangaben trennen freigegeben, implementiert und abgenommen. Bei Entscheidungen Register/Spezifikation und betroffene offene Issues gemeinsam pflegen. Umfangreiche neue Erkenntnisse als enges Folgepaket, nicht in P4 verstecken. Keine öffentliche Veröffentlichung, Hostingkosten oder endgültige Lizenz ohne Auftrag.

## Codex-Auswahl und Eigenumsetzung

Die Auswahl ist eine projektspezifische Empfehlung, keine Garantie für Kosten oder kontospezifische Verfügbarkeit. Terra High für zusammenhängende Mehrdateienpakete; Medium für den isolierten Speicherausbau; Very High gezielt für Generator-/Retry-/Determinismussemantik. Astra Medium für den visuellen Ausschnitt; bei fehlender Verfügbarkeit für #6 Terra High als Ausweichwahl.

**P1a: GPT-5.6 Terra · High.** Zustands-/Zeitgrenzen, Graphinvarianten, Layoutprüfung und Identität rechtfertigen High. Keine vorsorgliche höchste Stufe, solange das Layoutprofil klein bleibt.

**Selbst umsetzbar: Teilweise** für das vollständige P1a-Paket. Code, Tests, Review, Commit und Push sind mit den verfügbaren Werkzeugen bearbeitbar; die aktuelle tatsächliche Godot-Testlaufzeit ist vor Eigenimplementierung zu prüfen. Der Windows-/Chrome-Erfolg der P0-Umsetzung belegt nicht automatisch eine passende Laufzeit jeder Chat-Umgebung. Erstimplementierung bevorzugt in der bereits funktionierenden Codex-/Godot-Umgebung; kleine isolierte Korrekturen bevorzugt direkt. Die Dokumentationsvorbereitung selbst ist direkt umsetzbar.

Bei Nacharbeiten nur Repository/Branch, aktueller PR-Review, Pflichtbefehle und Übergabevorgaben in den Prompt aufnehmen. Modell, Reasoning und Eigenumsetzbarkeit unmittelbar vor dem neuen Auftrag erneut beurteilen.

## Quellen zur Werkzeugwahl

Die bisherigen Primärquellen wurden bei der Planung am 2026-09-05 geprüft; die Paketwahl bleibt eine Einschätzung und beweist keine kontospezifische Verfügbarkeit.

- GPT-5.6-Familie: https://openai.com/index/gpt-5-6/
- Terra-Modell: https://developers.openai.com/api/docs/models/gpt-5.6-terra
- Astra-Modell: https://developers.openai.com/api/docs/models/gpt-6-astra
- Godot-Befehle: https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html
- Web-Export und Threading: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
