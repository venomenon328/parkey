# Umsetzungspakete und Arbeitsablauf

Stand: 2026-09-06. Neun Umsetzungspakete sind als Issues #1–#9 angelegt. **P0 und P1 sind vollständig abgenommen und nach `main` gemergt. P2a / #5 ist fachlich abgenommen und merge-bereit.** Grundlage sind [Entscheidungsregister](decisions.md), [P1-Regelprofil](p1-rule-profile.md), [P1b-Integration](p1b-implementation.md), [P1b-Spielbarkeit](p1b-playability.md), [P1c-Ergebnisspeicher](p1c-local-results.md), [P2a-Routenentscheidungen](p2a-route-decisions.md), [Spieldesign](game-design.md), [Architektur](architecture.md), [Teststrategie](testing.md), [Entwicklung](development.md) und `AGENTS.md`.

## Paketübersicht

| Paket / Issue | Ergebnis | Start erst nach / Stand | Arbeitsbranch |
| --- | --- | --- | --- |
| P0 / [#1](https://github.com/venomenon328/parkey/issues/1) | Ein Projekt, zwei Exporte, Test-/CI-Grundlage | Abgenommen und gemergt | `codex/p0-godot-foundation` |
| P1a / [#2](https://github.com/venomenon328/parkey/issues/2) | CourseData, Validator, RunSession, Zeit und Fehlerfrist | Abgenommen, PR #12 gemergt | `codex/p1a-run-core` |
| P1b / [#3](https://github.com/venomenon328/parkey/issues/3) | Erster spielbarer handgebauter Third-Person-Lauf | Abgenommen, PR #13 gemergt | `codex/p1b-playable-course` |
| P1c / [#4](https://github.com/venomenon328/parkey/issues/4) | Dauerhafte lokale Bestzeiten und Ergebnisschirm | Abgenommen, PR #14 gemergt | `codex/p1c-local-leaderboards` |
| P2a / [#5](https://github.com/venomenon328/parkey/issues/5) | Erprobte Routen und vorausschauende Kamera | **Abgenommen; PR #15 merge-bereit** | `codex/p2a-route-decisions` |
| P2b / [#6](https://github.com/venomenon328/parkey/issues/6) | Hochwertige Windows-Beispielwelt, Web-Fallback | #5-Merge; Zielhardware/Budget klären | `codex/p2b-visual-slice` |
| P3a / [#7](https://github.com/venomenon328/parkey/issues/7) | Deterministischer validierter Generator | #5-Merge; Bausteinfreigabe liegt vor | `codex/p3a-seeded-generator` |
| P3b / [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Spielablauf und Export-Konformitätsnachweis | #6 und #7 | `codex/p3b-seed-game-flow` |
| P4 / [#9](https://github.com/venomenon328/parkey/issues/9) | PoC-Abnahme und reproduzierbare Testpakete | #8 | `codex/p4-poc-acceptance` |

Abhängigkeiten bedeuten **abgenommen und nach `main` gemergt**, nicht nur „ein PR wurde eröffnet“. P0/P1a/P1b/P1c sind abgeschlossen. P1c-Merge: `63f1851dc9e3cf2ee72412b1a352ce5a191cbac2` über PR #14. Auf dem finalen PR-Head `c1eb976` bestanden Import, `storage` 67, `integration` 218, `all` 446 sowie beide Release-Exporte; Windows-/Chrome-Persistenz und der eingeschränkte Chrome-Speicherfall wurden tatsächlich geprüft. P2a ist fachlich abgenommen; die letzte Statusdarstellungs-Nacharbeit wurde durch CI `34027294353` auf `b0270b4` mit Import, vollständigen Tests und beiden Exporten bestätigt. Die physische P1b-Chrome-Eingabeabnahme bleibt offen und darf nicht als bestanden ausgegeben werden. Neue Paketbranches entstehen vom jeweils aktuellen `main`.

Nur #6/#7 sind nach #5 für Parallelität vorgesehen. Gemeinsame Datenverträge dürfen dabei nicht unabhängig geändert werden; #8 wartet auf beide Abnahmen. Standard bleibt ein Paket pro PR.

## Warum dieser Zuschnitt?

P1 trennt Regeln, Darstellung und Dateisystem: erst testbarer Kern, dann spielbarer Lauf, dann dauerhafte Resultate. Dieser Meilenstein ist abgeschlossen. P2 trennt erprobte Routen-/Kameraentscheidungen von hochwertiger Grafikgestaltung. Der Generator vervielfältigt nur geeignete Abschnitte; P3 trennt Algorithmus von UI-/Speicher-/Plattformintegration. P4 prüft die zusammengesetzte Anwendung und ist keine unbegrenzte Restefeatureliste.

## Freigegebenes Regelprofil für P1

Maßgeblich ist [p1-rule-profile.md](p1-rule-profile.md), Kennung `p1-input-start-v1`, auf Basis von D-014 bis D-018. Kein Countdown und kein Enter-Start. Der erste Bewegungsbuchstabe startet und wirkt im selben Ereignis; Backspace bereitet denselben Parcours neu vor, Escape ist eine getrennte Menü-/Pause-Anforderung. Fehler-, Rückweg-, Eingabe- und Fokusregeln sind für P1 freigegeben.

Die vollständige Menüoberfläche und eine spätere Übungsfortsetzung sind nicht Teil von P1a/P1b. P1a liefert den getrennten Menüanforderungsvertrag, P1b eine minimale sichtbare Rückmeldung dafür. Verhaltensänderungen am freigegebenen Profil werden nicht eigenmächtig vorgenommen; Profil-/Balancingänderungen berücksichtigen die Wertungsidentität.

## P1-Abschluss und P2a-Ergebnis

P1b lieferte den validierten 26-Feld-Handparcours mit Gabelung/Zusammenführung, unregelmäßiger Stelle, Figur, kontinuierlicher Kamera, Timer, Fehlerfeedback, Besuchs-/Nachbarstatus und Quick Restart. Die physische/manuelle Windows-Spielabnahme ist bestanden. P1c ergänzt darauf den lokalen versionierten Ergebnisspeicher mit vollständiger Strecken-/Regelidentität, Original-Mikrosekunden, deterministischen Gleichständen, Top-100-Aufbewahrung und Top-10-Ergebnisansicht.

P2a ersetzt den aktiven Referenzkurs durch 30 Felder mit zwei Abschnittsentscheidungen. Vier menschliche Routenkombinationen wurden funktional fehlerfrei gespielt; die Kamera ist für diesen Referenzkurs abgenommen. Die großen weißen P1b-Callouts sind entfernt, die primären Tile-Buchstaben auf den Keycaps ausgerichtet und die visuelle Feldstatus-Hierarchie präzisiert: besucht hat Vorrang vor erneuter Erreichbarkeit. Die kleine Zeitstichprobe belegt keinen Vorteil längerer Folgen; Generatorarbeit darf daher nicht pauschal „länger = leichter/schneller“ annehmen.

Windows ist nach D-008 die führende Zielplattform. Die noch offene physische Chrome-Eingabeabnahme aus P1b war nach ausdrücklicher Nutzerentscheidung kein Mergeblocker und wird später nachgeholt. Automatisierte/synthetische Web-Nachweise und die reale P1c-Browserpersistenz bleiben davon getrennt; die Browser-Hardwareabnahme darf nicht als bereits bestanden ausgegeben werden.

## Nicht rastergebundene Strecken

D-010 bis D-013 bleiben verbindlich. Die P1-Regelfreigabe ändert keine Geometrie- oder Geschwindigkeitsgrundsätze und öffnet abgeschlossene Pakete nicht erneut.

| Paket | Verbindliche Abgrenzung |
| --- | --- |
| P1a / #2 | Explizite Nachbarlisten, getrennte Graph-/Layoutprüfung; kein Orthogonalitäts- oder Vier-Nachbarn-Limit. Fünf-Nachbarn-Test, gedrehter Mehrfachanschluss und Layoutvariation bei gleichen logischen Zeiten abgenommen. |
| P1b / #3 | Handparcours mit unregelmäßiger Stelle, moderaten Größenunterschieden und lesbarem schrägem Übergang; unmittelbare Eingaben und begrenzter Darstellungsrückstand abgenommen. |
| P1c / #4 | Relevante Layoutunterschiede trennen Ranglisten auch bei gleichem Graphen; reine Kosmetik nicht. |
| P2a / #5 | Asymmetrische Routen, variable Anschlüsse, Geometrie, Kamera/Beschriftung und Besuchsstatus-Priorität erprobt; keine feste Nachbarzahl als Produktregel und keine unbelegte Tippbarkeitsheuristik. |
| P2b / #6 | Variable moderate Feldformen/-größen und Übergänge in beiden Profilen erhalten. Kein grafischer Tempodeckel oder heimlich geändertes Layout. |
| P3a / #7 | Generator liefert Graph und räumliches Layout mit kontrollierten Zufallsableitungen. Identität/Golden-Fälle binden beides; kein beliebiger Polygon-Generator. |
| P3b / #8 | Exportvergleich umfasst räumliche Daten/Hashes und Ranglistentrennung. Gleiche Eingabeprotokolle ergeben unabhängig von Darstellungsabständen dieselben Kernzeiten. |
| P4 / #9 | Gesamtabnahme umfasst alle bestätigten und PoC-freigegebenen Entscheidungen, ohne spätere Mechaniken vorwegzunehmen. |

## Gemeinsamer Liefer- und Testvertrag

Jedes Paket liefert Implementierung, passende Tests, gepflegte Dokumentation und konkrete Nachweise. Issues enthalten Abnahmekriterien und Nicht-Ziele; kompakte Arbeitsanweisungen wiederholen den Lieferumfang nicht unnötig.

[testing.md](testing.md) definiert die CLI-Einstiege. P0 hat `smoke`/`all`, Export-Presets und CI geliefert, P1a `core`, P1b `integration`, P1c `storage` und weitere Integrationsregressionen. P2a ergänzt `routes`; sie prüft Verträge/Ports, Geometrie, alle Referenzrouten, Identität, QWERTZ-Beschreibungen und Abschnittsmessung. `integration` deckt zusätzlich die Feldstatus-Priorität ab. `all` führt alle vorhandenen Suites aus. Unbekannte oder leere Suites müssen scheitern.

Reale Grafik, Hardwaretastatur, Browserpersistenz und Spielgefühl bleiben gesonderte Nachweise. Keine erfundene Abnahme bei fehlender Umgebung. P0/P1a/P1c, die Windows-P1b-Abnahme und P2a sind bestanden. Paketbezogene Nutzerentscheidungen können ein Plattformgate ausdrücklich verschieben oder einen ursprünglich geplanten Zusatztest als für das Paket nicht mehr erforderlich einstufen; nicht durchgeführte Prüfungen werden trotzdem nicht als durchgeführt behauptet. Die physische P1b-Chrome-Eingabeabnahme bleibt separat offen.

## Branch, PR und Dokumentationspflege

Vor Änderungen aktuelle Quellen und tatsächlichen Code lesen. Neue Paketbranches von aktuellem `main` erstellen; vorhandene Vorbereitungscommits bei Fortführung erhalten. Code und betroffene Dokumentation gemeinsam committen/pushen, Draft-PR gegen `main` mit Issue-Verknüpfung pflegen. Nicht automatisch mergen. Technische und erforderliche manuelle Abnahme müssen dem Merge vorausgehen.

Statusangaben trennen freigegeben, implementiert und abgenommen. Bei Entscheidungen Register/Spezifikation und betroffene offene Issues gemeinsam pflegen. Umfangreiche neue Erkenntnisse als enges Folgepaket behandeln, nicht in P4 verstecken. Keine öffentliche Veröffentlichung, Hostingkosten oder endgültige Lizenz ohne Auftrag.

## Lokale Werkzeuge

Die verbindliche Windows-Ablage für projektbezogene Tools ist `E:\Zeuch\Coding\Parkey-Tools`; Details stehen in [development.md](development.md). Keine Parkey-spezifischen Toolinstallationen unter `C:\Tools` oder wechselnden ad-hoc-Verzeichnissen anlegen. Godot-eigene Benutzerpfade und `%TEMP%` sind die dokumentierten Ausnahmen.
