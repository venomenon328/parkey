# PoC-Roadmap

Stand: 2026-09-06. **P0, P1a und P1b sind abgenommen und gemergt.** P1b wurde auf Windows physisch/manuell abgenommen; die physische Chrome-Abnahme wird wegen der bestätigten Windows-Priorität später nachgeholt und war ausdrücklich kein P1b-Mergeblocker. Issues beschreiben den Lieferumfang; [Umsetzungsplan](implementation-plan.md), [P1-Regelprofil](p1-rule-profile.md), [P1b-Integration](p1b-implementation.md), [P1b-Spielbarkeit](p1b-playability.md) und [Teststrategie](testing.md) enthalten die gemeinsamen Verträge. P4 ist Integrationsabnahme, keine zusätzliche Featurephase.

## Meilensteine und Pakete

| Meilenstein | Pakete | Ergebnis | Status |
| --- | --- | --- | --- |
| D0 | Dokumentation/Planung | Anforderungen, Architektur, neun Issues, Abhängigkeiten und Testvertrag | Dokumentiert; P1-Profil freigegeben |
| P0 | [#1](https://github.com/venomenon328/parkey/issues/1) | Gemeinsames Projekt, Windows/Web, minimale Tests/CI | Abgenommen und gemergt |
| P1 | [#2](https://github.com/venomenon328/parkey/issues/2), [#3](https://github.com/venomenon328/parkey/issues/3), [#4](https://github.com/venomenon328/parkey/issues/4) | Kern, Handparcours, Timer, Fehlerpause, dauerhafte Bestzeiten | #2 und #3 abgenommen/gemergt; #4 vorbereitet, nicht implementiert |
| P2 | [#5](https://github.com/venomenon328/parkey/issues/5), [#6](https://github.com/venomenon328/parkey/issues/6) | Erprobte Routen und gestaltete Beispielwelt/Web-Fallback | Nicht begonnen; Kamera-/Beschriftungsfolgearbeit aus P1b in #5 vorgemerkt |
| P3 | [#7](https://github.com/venomenon328/parkey/issues/7), [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Generator, Integration und Export-Regelparität | Nicht begonnen |
| P4 | [#9](https://github.com/venomenon328/parkey/issues/9) | Geprüfte Testpakete aus einem Commit samt Abnahmematrix | Nicht begonnen |

## Reihenfolge und Zwischenstände

`#1 → #2 → #3 → #4 → #5 → (#6 und #7) → #8 → #9`

Nächster Schritt: **P1c / Issue #4 im Draft-PR prüfen und abnehmen.** Basis ist `main` bei `5e60d53f02d6a772677956d23016504d1227bead`; Vertrag: [p1c-local-results.md](p1c-local-results.md). P1b ist über PR #13 mit Merge-Commit `e8e947e4100c8f3e534ae425752ac2c30c7fee7a` abgeschlossen; `main`-CI `34001879727` ist erfolgreich. Keine späteren Pakete vorziehen.

Nach #5 sind Abschnittsverträge und Eignung geprüft. #6/#7 können dann bei stabilen Verträgen parallel laufen; #8 wartet auf beide Merges. Sonst beginnt ein Paket nach seiner Abhängigkeit vom aktuellen `main`.

## Abnahme-Gates

**P0:** Abgeschlossen. Gemeinsamer Editor-/Template-Pin, beide Ziele tatsächlich gestartet, manuelle Hardwaretastaturprüfung bestanden.

**P1a:** Abgeschlossen nach Review-Nacharbeit auf `617015d`: gedrehter Großfeld-/Mehrfachanschluss und typfeste Behandlung fehlerhafter Nachbarlisten geprüft; 127 `core`-Assertions, 158 insgesamt, Exporte und CI erfolgreich. Ein Grafik-/Spieltest war kein Bestandteil der Kernabnahme.

**P1b:** Abgeschlossen. `integration` mit 189 Assertions, `all` mit 350; Windows-/Web-Exporte und CI erfolgreich. Physische/manuelle Windows-Abnahme bestanden: beide Routen/Rückweg, Reaktionsgefühl, Kamera, Feldstatus, Fehlerpause, Y/Z/Shift, Echo/Überlappung, Restart, Escape, UI-Rückfokus und Fokusverlust. Die physische Chrome-Abnahme bleibt als späterer Nachweis offen und darf nicht als bereits bestanden ausgegeben werden. Die noch nicht gewünschte Enddarstellung der großen weißen Zusatzbuchstaben sowie die Ausrichtung der primären Tile-Beschriftung sind Folgearbeit von P2a / #5.

**P1c:** Implementiert im Draft-PR. Ergänzt getrennt Persistenz, lokale Bestzeiten und Ergebnisschirm; Lauf-ID, Gleichstände, Top-100-Aufbewahrung, Speicherfehler und tatsächliche Windows-/Chrome-Persistenz sind im [Paketvertrag](p1c-local-results.md) konkretisiert. Die P1b-Ausnahme verschiebt die neuen Browserpersistenztests nicht. Keine Onlinewertung vorziehen.

**P2:** Einsehbare Routenwahl, asymmetrische Anschlüsse und moderate Größen/Formen in beiden Profilen erproben. In #5 außerdem die P1b-Kamera-/Beschriftungsfolgearbeit bearbeiten: primäre Tile-Buchstaben aus der Spielkamera sinnvoll ausrichten, im aktuellen Handkurs die gewünschte 90°-Drehung gegenüber P1b prüfen und große weiße Callouts möglichst entfernen. Unterschiedliche Tippmethoden statt ungeprüfter Ergonomiebehauptung. Zielhardware, Auflösung, Leistungsbudget und visuelle Nutzerabnahme gehören zu #6.

**P3:** Graph und Layout gemeinsam validieren und in Identität/Golden-Fällen binden; keine feste Raster-/Nachbarzahlregel. Begrenzte Generierungsversuche, Versionierung und echte Windows-/Web-Konformität in #8.

**P4:** Alle bestätigten und PoC-freigegebenen Anforderungen nachweisen. Gleicher geprüfter Commit, Plattformmatrix, Einschränkungen, Credits und Nutzerabnahme. Die bis dahin noch offene physische Browserprüfung spätestens hier schließen oder transparent als Einschränkung ausweisen. Keine automatische öffentliche Veröffentlichung.

## Abschlussumfang

Gestaltete Windows-Anwendung plus Web-Version aus demselben Projekt: lesbarer Third-Person-Parcours, Start/Ziel, schnelle korrekte Eingaben, freigegebener Start-/Restart-/Fehlervertrag, Timer mit drei Nachkommastellen, lokale Ranglisten und reproduzierbare Seed-Strecken mit Alternativen.

Nicht Bestandteil: Onlinekonten/-Ranglisten, Cloud-Sync, Ghosts, Tagesparcours, Echtzeit-Mehrspieler, Editor, Shop, automatische Updates oder mehrere Themenwelten. Die Menüfunktion ist in ihrer Bedeutung festgelegt; eine vollständige Menü-/Übungsfortsetzungsoberfläche wird dadurch nicht als zusätzliche P1a-/P1b-Abnahme gefordert.

Statusänderungen nur mit Nachweisen. Neue Erkenntnisse in Entscheidungen und offenen Paketen pflegen, statt an einem überholten Plan festzuhalten. Keine unbelegten Zeitversprechen.
