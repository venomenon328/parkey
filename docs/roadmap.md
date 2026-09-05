# PoC-Roadmap

Stand: 2026-09-05. **P0 ist abgenommen. P1a ist im Draft implementiert; Regelprofil, technische Nachweise und Review sind noch nicht abgenommen.** Issues beschreiben den Lieferumfang; [Umsetzungsplan](implementation-plan.md), [P1-Regelprofil](p1-rule-profile.md) und [Teststrategie](testing.md) enthalten die gemeinsamen Verträge. P4 ist Integrationsabnahme, keine zusätzliche Featurephase.

## Meilensteine und Pakete

| Meilenstein | Pakete | Ergebnis | Status |
| --- | --- | --- | --- |
| D0 | Dokumentation/Planung | Anforderungen, Architektur, neun Issues, Abhängigkeiten und Testvertrag | Dokumentiert; P1-Freigabe auf vorbereitetem P1a-Branch ergänzt |
| P0 | [#1](https://github.com/venomenon328/parkey/issues/1) | Gemeinsames Projekt, Windows/Web, minimale Tests/CI | Abgenommen: automatisierte Prüfungen, native Starts und Hardwaretastaturtests |
| P1 | [#2](https://github.com/venomenon328/parkey/issues/2), [#3](https://github.com/venomenon328/parkey/issues/3), [#4](https://github.com/venomenon328/parkey/issues/4) | Kern, Handparcours, Timer, Fehlerpause, dauerhafte Bestzeiten | #2 im Draft implementiert; Abnahme und Merge offen |
| P2 | [#5](https://github.com/venomenon328/parkey/issues/5), [#6](https://github.com/venomenon328/parkey/issues/6) | Erprobte Routen und gestaltete Beispielwelt/Web-Fallback | Nicht begonnen |
| P3 | [#7](https://github.com/venomenon328/parkey/issues/7), [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Generator, Integration und Export-Regelparität | Nicht begonnen |
| P4 | [#9](https://github.com/venomenon328/parkey/issues/9) | Geprüfte Testpakete aus einem Commit samt Abnahmematrix | Nicht begonnen |

## Reihenfolge und Zwischenstände

`#1 → #2 → #3 → #4 → #5 → (#6 und #7) → #8 → #9`

Nächster Schritt: **#2 / P1a technisch prüfen und abnehmen**, auf `codex/p1a-run-core` im bestehenden Draft-PR. Die Freigabe ist erfolgt; ein zusätzlicher vorgeschalteter Dokumentationsmerge war nicht erforderlich. Erst nach Abnahme und Merge folgt #3. Nach #3 ist ein vollständiger Handlauf spielbar; nach #4 werden Bestzeiten dauerhaft gespeichert. Danach folgt ein echter Spieltest vor weiterem Ausbau.

Nach #5 sind Abschnittsverträge und Eignung geprüft. #6/#7 können dann bei stabilen Verträgen parallel laufen; #8 wartet auf beide Merges. Sonst beginnt ein Paket nach seiner Abhängigkeit vom aktuellen `main`.

## Abnahme-Gates

**P0:** Abgeschlossen. Gemeinsamer Editor-/Template-Pin, beide Ziele tatsächlich gestartet, manuelle Hardwaretastaturprüfung bestanden.

**P1:** D-010 bis D-013 verlangen freien Graph-/Layoutvertrag und räumliche Identität; Fünf-Nachbarn-Test und unregelmäßige Handstelle belegen die Freiheit. D-014 bis D-018 und `p1-input-start-v1` sind freigegeben: Start mit erstem Bewegungsbuchstaben statt Countdown, Quick Restart zurück in Bereitschaft, separate Escape-Menüanforderung, präzise Fehlerfrist und Fokusinvalidierung. Kein voller Menübau in P1a. Zustand, Zeitgrenzen, keine größen-/animationsbedingte Drosselung, einmaliges Ergebnis und später Persistenz/Lesbarkeit nachweisen.

**P2:** Einsehbare Routenwahl, asymmetrische Anschlüsse und moderate Größen/Formen in beiden Profilen erproben. Unterschiedliche Tippmethoden statt ungeprüfter Ergonomiebehauptung. Zielhardware, Auflösung, Leistungsbudget und visuelle Nutzerabnahme gehören zu #6.

**P3:** Graph und Layout gemeinsam validieren und in Identität/Golden-Fällen binden; keine feste Raster-/Nachbarzahlregel. Begrenzte Generierungsversuche, Versionierung und echte Windows-/Web-Konformität in #8.

**P4:** Alle bestätigten und PoC-freigegebenen Anforderungen D-001 bis D-018 nachweisen. Gleicher geprüfter Commit, Plattformmatrix, Einschränkungen, Credits und Nutzerabnahme. Keine automatische öffentliche Veröffentlichung.

## Abschlussumfang

Gestaltete Windows-Anwendung plus Web-Version aus demselben Projekt: lesbarer Third-Person-Parcours, Start/Ziel, schnelle korrekte Eingaben, freigegebener Start-/Restart-/Fehlervertrag, Timer mit drei Nachkommastellen, lokale Ranglisten und reproduzierbare Seed-Strecken mit Alternativen.

Nicht Bestandteil: Onlinekonten/-Ranglisten, Cloud-Sync, Ghosts, Tagesparcours, Echtzeit-Mehrspieler, Editor, Shop, automatische Updates oder mehrere Themenwelten. Die Menüfunktion ist in ihrer Bedeutung festgelegt; eine vollständige Menü-/Übungsfortsetzungsoberfläche wird dadurch nicht als zusätzliche P1a-Abnahme gefordert.

Statusänderungen nur mit Nachweisen. Neue Erkenntnisse in Entscheidungen und offenen Paketen pflegen, statt an einem überholten Plan festzuhalten. Keine unbelegten Zeitversprechen.
