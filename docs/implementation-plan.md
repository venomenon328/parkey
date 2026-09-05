# Umsetzungspakete und Arbeitsablauf

Stand: 2026-09-05. Neun Umsetzungspakete sind als Issues #1–#9 angelegt. **P0 ist abgenommen; P1a ist in Draft-PR #12 implementiert und wird mit Review/Abnahme abgeschlossen.** Grundlage sind [Entscheidungsregister](decisions.md), [P1-Regelprofil](p1-rule-profile.md), [Spieldesign](game-design.md), [Architektur](architecture.md), [Teststrategie](testing.md), [Entwicklung](development.md) und `AGENTS.md`.

## Paketübersicht

| Paket / Issue | Ergebnis | Start erst nach | Arbeitsbranch |
| --- | --- | --- | --- |
| P0 / [#1](https://github.com/venomenon328/parkey/issues/1) | Ein Projekt, zwei Exporte, Test-/CI-Grundlage | Abgenommen | `codex/p0-godot-foundation` |
| P1a / [#2](https://github.com/venomenon328/parkey/issues/2) | CourseData, Validator, RunSession, Zeit und Fehlerfrist | Implementiert in PR #12; Review/Abnahme | `codex/p1a-run-core` |
| P1b / [#3](https://github.com/venomenon328/parkey/issues/3) | Erster spielbarer handgebauter Third-Person-Lauf | #2 abgenommen und gemergt | `codex/p1b-playable-course` |
| P1c / [#4](https://github.com/venomenon328/parkey/issues/4) | Dauerhafte lokale Bestzeiten und Ergebnisschirm | #3 | `codex/p1c-local-leaderboards` |
| P2a / [#5](https://github.com/venomenon328/parkey/issues/5) | Erprobte Routen und vorausschauende Kamera | #4; echter P1-Spieltest | `codex/p2a-route-decisions` |
| P2b / [#6](https://github.com/venomenon328/parkey/issues/6) | Hochwertige Windows-Beispielwelt, Web-Fallback | #5; Zielhardware/Budget klären | `codex/p2b-visual-slice` |
| P3a / [#7](https://github.com/venomenon328/parkey/issues/7) | Deterministischer validierter Generator | #5; Bausteinfreigabe | `codex/p3a-seeded-generator` |
| P3b / [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Spielablauf und Export-Konformitätsnachweis | #6 und #7 | `codex/p3b-seed-game-flow` |
| P4 / [#9](https://github.com/venomenon328/parkey/issues/9) | PoC-Abnahme und reproduzierbare Testpakete | #8 | `codex/p4-poc-acceptance` |

Abhängigkeiten bedeuten **abgenommen und nach `main` gemergt**, nicht nur „ein PR wurde eröffnet“. P0 ist abgeschlossen. Der P1a-Branch enthält Regelfreigabe und Kernimplementierung im selben Draft-PR auf Basis von `main` nach PR #11. Spätere Branches werden erst beim jeweiligen Start vom dann aktuellen `main` erstellt.

Nur #6/#7 sind nach #5 für Parallelität vorgesehen. Gemeinsame Datenverträge dürfen dabei nicht unabhängig geändert werden; #8 wartet auf beide Abnahmen. Standard bleibt ein Paket pro PR.

## Warum dieser Zuschnitt?

P1 trennt Regeln, Darstellung und Dateisystem: erst testbarer Kern, dann spielbarer Lauf, dann dauerhafte Resultate. Der erste praktische Lauf ist nach #3 möglich. P2 trennt erprobte Entscheidungen von Grafikgestaltung. Der Generator vervielfältigt nur geeignete Abschnitte; P3 trennt Algorithmus von UI-/Speicher-/Plattformintegration. P4 prüft die zusammengesetzte Anwendung und ist keine unbegrenzte Restefeatureliste.

## Freigegebenes Regelprofil für P1

Maßgeblich ist [p1-rule-profile.md](p1-rule-profile.md), Kennung `p1-input-start-v1`, auf Basis von D-014 bis D-018. Kein Countdown und kein Enter-Start. Der erste Bewegungsbuchstabe startet und wirkt im selben Ereignis; Backspace bereitet denselben Parcours neu vor, Escape ist eine getrennte Menü-/Pause-Anforderung. Fehler-, Rückweg-, Eingabe- und Fokusregeln sind für P1 freigegeben.

Die Menüoberfläche und eine spätere Übungsfortsetzung sind nicht Teil von P1a. P1a liefert nur den getrennten Menüanforderungsvertrag. Technische Entscheidungen wie Klassen, internes Zustandsmodell, kanonische Zahlenrepräsentation und Toleranzen des kleinen ebenen Layoutprofils werden im Paket dokumentiert und getestet. Verhaltensänderungen am freigegebenen Profil werden dagegen nicht eigenmächtig vorgenommen; Profil-/Balancingänderungen berücksichtigen die Wertungsidentität.

## Nicht rastergebundene Strecken

D-010 bis D-013 bleiben verbindlich. Die P1-Regelfreigabe ändert keine Geometrie- oder Geschwindigkeitsgrundsätze und öffnet P0 nicht erneut.

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

Jedes Paket liefert Implementierung, passende Tests, gepflegte Dokumentation und konkrete Nachweise. Issues enthalten Abnahmekriterien und Nicht-Ziele; kompakte Arbeitsanweisungen wiederholen den Lieferumfang nicht unnötig.

[testing.md](testing.md) definiert die CLI-Einstiege. P0 hat `smoke`/`all`, Export-Presets und CI geliefert. P1a ergänzt `core`; weitere Suites entstehen erst in ihren Paketen. `all` führt alle bis dahin vorhandenen Suites aus. Unbekannte oder leere Suites müssen scheitern.

Reale Grafik, Hardwaretastatur, Browserpersistenz und Spielgefühl bleiben gesonderte Nachweise. Keine erfundene Abnahme bei fehlender Umgebung. P0-Starts und Hardwaretests sind bestanden; neue P1-Regeltests werden separat nachgewiesen. Fehlende verpflichtende Nachweise halten den jeweiligen PR im Draft.

## Branch, PR und Dokumentationspflege

Vor Änderungen aktuelle Quellen und tatsächlichen Code lesen. Neue Paketbranches von aktuellem `main` erstellen. Code und betroffene Dokumentation gemeinsam committen/pushen, Draft-PR gegen `main` mit Issue-Verknüpfung pflegen. Nicht automatisch mergen. Technische und erforderliche manuelle Abnahme müssen dem Merge vorausgehen.

Statusangaben trennen freigegeben, implementiert und abgenommen. Bei Entscheidungen Register/Spezifikation und betroffene offene Issues gemeinsam pflegen. Umfangreiche neue Erkenntnisse als enges Folgepaket behandeln, nicht in P4 verstecken. Keine öffentliche Veröffentlichung, Hostingkosten oder endgültige Lizenz ohne Auftrag.

## Lokale Werkzeuge

Die verbindliche Windows-Ablage für projektbezogene Tools ist `E:\Zeuch\Coding\Parkey-Tools`; Details stehen in [development.md](development.md). Keine Parkey-spezifischen Toolinstallationen unter `C:\Tools` oder wechselnden ad-hoc-Verzeichnissen anlegen. Godot-eigene Benutzerpfade und `%TEMP%` sind die dokumentierten Ausnahmen.
