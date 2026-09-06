# PoC-Roadmap

Stand: 2026-09-06. **P0 und P1 sind vollständig abgenommen und gemergt. P2a / #5 ist fachlich abgenommen und merge-bereit.** P1b wurde auf Windows physisch/manuell abgenommen; die physische Chrome-Eingabeabnahme wird wegen der bestätigten Windows-Priorität später nachgeholt und war ausdrücklich kein P1b-/P2a-Mergeblocker. P1c wurde über PR #14 mit lokalen Bestenlisten und Persistenz abgeschlossen. Issues beschreiben den Lieferumfang; [Umsetzungsplan](implementation-plan.md), [P1-Regelprofil](p1-rule-profile.md), [P1b-Integration](p1b-implementation.md), [P1b-Spielbarkeit](p1b-playability.md), [P1c-Ergebnisspeicher](p1c-local-results.md) und [Teststrategie](testing.md) enthalten die gemeinsamen Verträge. P4 ist Integrationsabnahme, keine zusätzliche Featurephase.

## Meilensteine und Pakete

| Meilenstein | Pakete | Ergebnis | Status |
| --- | --- | --- | --- |
| D0 | Dokumentation/Planung | Anforderungen, Architektur, neun Issues, Abhängigkeiten und Testvertrag | Dokumentiert; P1-Profil freigegeben |
| P0 | [#1](https://github.com/venomenon328/parkey/issues/1) | Gemeinsames Projekt, Windows/Web, minimale Tests/CI | Abgenommen und gemergt |
| P1 | [#2](https://github.com/venomenon328/parkey/issues/2), [#3](https://github.com/venomenon328/parkey/issues/3), [#4](https://github.com/venomenon328/parkey/issues/4) | Kern, Handparcours, Timer, Fehlerpause, dauerhafte Bestzeiten | Vollständig abgenommen und gemergt |
| P2 | [#5](https://github.com/venomenon328/parkey/issues/5), [#6](https://github.com/venomenon328/parkey/issues/6) | Erprobte Routen und gestaltete Beispielwelt/Web-Fallback | #5 abgenommen/merge-bereit; #6 wartet auf #5-Merge und Zielhardware/Budget |
| P3 | [#7](https://github.com/venomenon328/parkey/issues/7), [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Generator, Integration und Export-Regelparität | #7 wartet auf #5-Merge/Bausteinfreigabe |
| P4 | [#9](https://github.com/venomenon328/parkey/issues/9) | PoC-Abnahme und reproduzierbare Testpakete | Nicht begonnen |

## Reihenfolge und Zwischenstände

`#1 → #2 → #3 → #4 → #5 → (#6 und #7) → #8 → #9`

Nächster Schritt: **PR #15 / P2a mergen.** Der Draft ist technisch re-reviewt, die vier Routenkombinationen wurden menschlich gespielt und als funktional fehlerfrei abgenommen, die Feldstatus-Nacharbeit ist umgesetzt. CI `34027294353` bestätigte den Code-/Teststand `b0270b4`; der abschließende aktuelle PR-Head `0d890c8` wurde durch CI `34027596453` erneut vollständig mit Import, Tests und beiden Release-Exporten verifiziert. Die verschobene physische P1b-Chrome-Eingabeabnahme bleibt separat offen. Keine P2b-/P3a-Inhalte vor dem #5-Merge beginnen.

Nach #5 sind Abschnittsverträge und Eignung geprüft. #6/#7 können dann bei stabilen Verträgen parallel laufen; #8 wartet auf beide Merges. Sonst beginnt ein Paket nach seiner Abhängigkeit vom aktuellen `main`.

## Abnahme-Gates

**P0:** Abgeschlossen. Gemeinsamer Editor-/Template-Pin, beide Ziele tatsächlich gestartet, manuelle Hardwaretastaturprüfung bestanden.

**P1a:** Abgeschlossen nach Review-Nacharbeit auf `617015d`: gedrehter Großfeld-/Mehrfachanschluss und typfeste Behandlung fehlerhafter Nachbarlisten geprüft; 127 `core`-Assertions, 158 insgesamt, Exporte und CI erfolgreich. Ein Grafik-/Spieltest war kein Bestandteil der Kernabnahme.

**P1b:** Abgeschlossen. `integration` mit 189 Assertions, `all` mit 350; Windows-/Web-Exporte und CI erfolgreich. Physische/manuelle Windows-Abnahme bestanden: beide Routen/Rückweg, Reaktionsgefühl, Kamera, Feldstatus, Fehlerpause, Y/Z/Shift, Echo/Überlappung, Restart, Escape, UI-Rückfokus und Fokusverlust. Die physische Chrome-Eingabeabnahme bleibt als späterer Nachweis offen und darf nicht als bereits bestanden ausgegeben werden. Die noch nicht gewünschte Enddarstellung der großen weißen Zusatzbuchstaben sowie die Ausrichtung der primären Tile-Beschriftung wurden in P2a weitergeführt.

**P1c:** Abgeschlossen und über PR #14 gemergt (`63f1851dc9e3cf2ee72412b1a352ce5a191cbac2`). Der versionierte lokale Store trennt Ergebnisse nach vollständiger Identität, sortiert Original-Mikrosekunden numerisch, verwendet gemeinsame Ränge bei exakter Zeitgleichheit, bewahrt maximal 100 Einträge und zeigt Top 10 samt exakter Rohzeit. Die Review-Nacharbeit erhält eine alleinige Recovery-`.bak` auch bei Ersetzungsfehler und macht kollidierende Millisekundenanzeigen im echten Ergebnis-UI nachvollziehbar. Auf `c1eb976` bestanden Import, `storage` 67, `integration` 218, `all` 446 sowie beide Release-Exporte. Windows-/Chrome-Persistenz und der eingeschränkte Chrome-Speicherfall mit sichtbarer temporärer Meldung wurden tatsächlich geprüft. Keine Onlinewertung vorgezogen.

**P2a / #5:** Fachlich abgenommen und merge-bereit. Der Referenzkurs enthält zwei asymmetrische Entscheidungen mit expliziten Ports, moderaten Größen/Formen, Keycap-Beschriftungen und vorausschauender Kamera. Vier menschliche Vollroutenläufe (`kurz/lang`, `kurz/kurz`, `lang/kurz`, `lang/lang`) waren funktional fehlerfrei; die Kamera wird für den Referenzkurs akzeptiert. Die kleine Stichprobe zeigt die kurzen Varianten jeweils schneller, belegt aber keine allgemeine Tippbarkeitsheuristik. Auf Nutzerwunsch hat Besuchsstatus visuell Vorrang vor erneuter Erreichbarkeit; die Umsetzung und Regression sind durch CI `34027294353` bestätigt. Der aktuelle vollständige PR-Head `0d890c8` ist durch CI `34027596453` ebenfalls grün. Die ursprünglich zusätzlich gewünschte zweite Tippmethode bzw. separate Web-Kamerawiederholung wurde für diese P2a-Abnahme ausdrücklich nicht mehr verlangt und wird nicht als durchgeführt dargestellt.

**P2b / #6:** Zielhardware, Auflösung, Leistungsbudget und finale visuelle Nutzerabnahme gehören hierher. Größere gestalterische/ästhetische Kritik am P2a-PoC ist daher nicht rückwirkend P2a-Blocker, sofern sie keine Mechanik-/Lesbarkeitsanforderung verletzt.

**P3:** Graph und Layout gemeinsam validieren und in Identität/Golden-Fällen binden; keine feste Raster-/Nachbarzahlregel. Begrenzte Generierungsversuche, Versionierung und echte Windows-/Web-Konformität in #8. P3a darf die P2a-Entscheidungs-/Geometriebausteine nutzen, aber keine unbelegte Regel „länger = leichter/schneller“ festschreiben.

**P4:** Alle bestätigten und PoC-freigegebenen Anforderungen nachweisen. Gleicher geprüfter Commit, Plattformmatrix, Einschränkungen, Credits und Nutzerabnahme. Die bis dahin noch offene physische Browserprüfung spätestens hier schließen oder transparent als Einschränkung ausweisen. Keine automatische öffentliche Veröffentlichung.

## Abschlussumfang

Gestaltete Windows-Anwendung plus Web-Version aus demselben Projekt: lesbarer Third-Person-Parcours, Start/Ziel, schnelle korrekte Eingaben, freigegebener Start-/Restart-/Fehlervertrag, Timer mit drei Nachkommastellen, lokale Ranglisten und reproduzierbare Seed-Strecken mit Alternativen.

Nicht Bestandteil: Onlinekonten/-Ranglisten, Cloud-Sync, Ghosts, Tagesparcours, Echtzeit-Mehrspieler, Editor, Shop, automatische Updates oder mehrere Themenwelten. Die Menüfunktion ist in ihrer Bedeutung festgelegt; eine vollständige Menü-/Übungsfortsetzungsoberfläche wird dadurch nicht als zusätzliche P1a-/P1b-Abnahme gefordert.

Statusänderungen nur mit Nachweisen. Neue Erkenntnisse in Entscheidungen und offenen Paketen pflegen, statt an einem überholten Plan festzuhalten. Keine unbelegten Zeitversprechen.
