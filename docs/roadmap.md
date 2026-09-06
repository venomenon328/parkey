# PoC-Roadmap

Stand: 2026-09-06. **P0, P1 und P2a / #5 sind vollständig abgenommen und gemergt.** P1b wurde auf Windows physisch/manuell abgenommen; die physische Chrome-Eingabeabnahme wird wegen der bestätigten Windows-Priorität später nachgeholt und war ausdrücklich kein P1b-/P2a-Mergeblocker. P1c wurde über PR #14 mit lokalen Bestenlisten und Persistenz abgeschlossen. P2a wurde über PR #15 mit Squash-Commit `a12cb8f148e6c90d66c6c198b7d923eee9d5eebc` abgeschlossen; der anschließende `main`-CI-Lauf `34028827332` war erfolgreich. Issues beschreiben den Lieferumfang; [Umsetzungsplan](implementation-plan.md), [P1-Regelprofil](p1-rule-profile.md), [P1b-Integration](p1b-implementation.md), [P1b-Spielbarkeit](p1b-playability.md), [P1c-Ergebnisspeicher](p1c-local-results.md) und [Teststrategie](testing.md) enthalten die gemeinsamen Verträge. P4 ist Integrationsabnahme, keine zusätzliche Featurephase.

## Meilensteine und Pakete

| Meilenstein | Pakete | Ergebnis | Status |
| --- | --- | --- | --- |
| D0 | Dokumentation/Planung | Anforderungen, Architektur, neun Issues, Abhängigkeiten und Testvertrag | Dokumentiert; P1-Profil freigegeben |
| P0 | [#1](https://github.com/venomenon328/parkey/issues/1) | Gemeinsames Projekt, Windows/Web, minimale Tests/CI | Abgenommen und gemergt |
| P1 | [#2](https://github.com/venomenon328/parkey/issues/2), [#3](https://github.com/venomenon328/parkey/issues/3), [#4](https://github.com/venomenon328/parkey/issues/4) | Kern, Handparcours, Timer, Fehlerpause, dauerhafte Bestzeiten | Vollständig abgenommen und gemergt |
| P2 | [#5](https://github.com/venomenon328/parkey/issues/5), [#6](https://github.com/venomenon328/parkey/issues/6) | Erprobte Routen und gestaltete Beispielwelt/Web-Fallback | #5 abgenommen/gemergt; #6 im Draft visuell nachgearbeitet; erneute Nutzerabnahme offen |
| P3 | [#7](https://github.com/venomenon328/parkey/issues/7), [#8](https://github.com/venomenon328/parkey/issues/8) | Seed-Generator, Integration und Export-Regelparität | #7 nach #5 grundsätzlich startfähig, aktuell nicht das aktive Paket |
| P4 | [#9](https://github.com/venomenon328/parkey/issues/9) | PoC-Abnahme und reproduzierbare Testpakete | Nicht begonnen |

## Reihenfolge und Zwischenstände

`#1 → #2 → #3 → #4 → #5 → (#6 und #7) → #8 → #9`

Nächster Schritt: **P2b / #6 anhand des exportierten Slices visuell durch den Nutzer abnehmen.** Briefing und Leistungsziel sind bestätigt; [Umsetzung und technische Nachweise](p2b-visual-slice.md) bleiben von der subjektiven Freigabe getrennt. #8 wartet weiterhin auf #6/#7. Keine P3-Inhalte vorgezogen.

## Abnahme-Gates

**P0:** Abgeschlossen. Gemeinsamer Editor-/Template-Pin, beide Ziele tatsächlich gestartet, manuelle Hardwaretastaturprüfung bestanden.

**P1a:** Abgeschlossen nach Review-Nacharbeit auf `617015d`: gedrehter Großfeld-/Mehrfachanschluss und typfeste Behandlung fehlerhafter Nachbarlisten geprüft; 127 `core`-Assertions, 158 insgesamt, Exporte und CI erfolgreich. Ein Grafik-/Spieltest war kein Bestandteil der Kernabnahme.

**P1b:** Abgeschlossen. `integration` mit 189 Assertions, `all` mit 350; Windows-/Web-Exporte und CI erfolgreich. Physische/manuelle Windows-Abnahme bestanden: beide Routen/Rückweg, Reaktionsgefühl, Kamera, Feldstatus, Fehlerpause, Y/Z/Shift, Echo/Überlappung, Restart, Escape, UI-Rückfokus und Fokusverlust. Die physische Chrome-Eingabeabnahme bleibt als späterer Nachweis offen und darf nicht als bereits bestanden ausgegeben werden. Die noch nicht gewünschte Enddarstellung der großen weißen Zusatzbuchstaben sowie die Ausrichtung der primären Tile-Beschriftung wurden in P2a weitergeführt.

**P1c:** Abgeschlossen und über PR #14 gemergt (`63f1851dc9e3cf2ee72412b1a352ce5a191cbac2`). Der versionierte lokale Store trennt Ergebnisse nach vollständiger Identität, sortiert Original-Mikrosekunden numerisch, verwendet gemeinsame Ränge bei exakter Zeitgleichheit, bewahrt maximal 100 Einträge und zeigt Top 10; seit der neuen P2b-Anzeigeentscheidung sind Rohzeiten ausschließlich in F3 sichtbar. Die Review-Nacharbeit erhält eine alleinige Recovery-`.bak` auch bei Ersetzungsfehler und macht kollidierende Millisekundenanzeigen im echten Ergebnis-UI nachvollziehbar. Auf `c1eb976` bestanden Import, `storage` 67, `integration` 218, `all` 446 sowie beide Release-Exporte. Windows-/Chrome-Persistenz und der eingeschränkte Chrome-Speicherfall mit sichtbarer temporärer Meldung wurden tatsächlich geprüft. Keine Onlinewertung vorgezogen.

**P2a / #5:** Abgeschlossen und über PR #15 gemergt (`a12cb8f148e6c90d66c6c198b7d923eee9d5eebc`). Der Referenzkurs enthält zwei asymmetrische Entscheidungen mit expliziten Ports, moderaten Größen/Formen, Keycap-Beschriftungen und vorausschauender Kamera. Vier menschliche Vollroutenläufe (`kurz/lang`, `kurz/kurz`, `lang/kurz`, `lang/lang`) waren funktional fehlerfrei; die Kamera wird für den Referenzkurs akzeptiert. Die kleine Stichprobe zeigt die kurzen Varianten jeweils schneller, belegt aber keine allgemeine Tippbarkeitsheuristik. Auf Nutzerwunsch hat Besuchsstatus visuell Vorrang vor erneuter Erreichbarkeit; Umsetzung und Regression sind grün. Die ursprünglich zusätzlich gewünschte zweite Tippmethode bzw. separate Web-Kamerawiederholung wurde für diese P2a-Abnahme ausdrücklich nicht mehr verlangt und wird nicht als durchgeführt dargestellt. `main`-CI `34028827332` nach dem Merge war erfolgreich.

**P2b / #6:** Im Draft umgesetzt: eine Tastatur-Werkstatt, plastische Keycaps mit rein visuellem Hub, gegliederter Mensch mit Idle/Bewegung/Fehlerreaktion, transparentes HUD und F3-Entwickleransicht. D-025–D-028 definieren Briefing und Referenzbudget. Reale Nachweise und offene Nutzerabnahme stehen im [Paketbericht](p2b-visual-slice.md); schwächere Mindesthardware ist ungeprüft.

**P3:** Graph und Layout gemeinsam validieren und in Identität/Golden-Fällen binden; keine feste Raster-/Nachbarzahlregel. Begrenzte Generierungsversuche, Versionierung und echte Windows-/Web-Konformität in #8. P3a darf die P2a-Entscheidungs-/Geometriebausteine nutzen, aber keine unbelegte Regel „länger = leichter/schneller“ festschreiben.

**P4:** Alle bestätigten und PoC-freigegebenen Anforderungen nachweisen. Gleicher geprüfter Commit, Plattformmatrix, Einschränkungen, Credits und Nutzerabnahme. Die bis dahin noch offene physische Browserprüfung spätestens hier schließen oder transparent als Einschränkung ausweisen. Keine automatische öffentliche Veröffentlichung.

## Abschlussumfang

Gestaltete Windows-Anwendung plus Web-Version aus demselben Projekt: lesbarer Third-Person-Parcours, Start/Ziel, schnelle korrekte Eingaben, freigegebener Start-/Restart-/Fehlervertrag, Timer mit drei Nachkommastellen, lokale Ranglisten und reproduzierbare Seed-Strecken mit Alternativen.

Nicht Bestandteil: Onlinekonten/-Ranglisten, Cloud-Sync, Ghosts, Tagesparcours, Echtzeit-Mehrspieler, Editor, Shop, automatische Updates oder mehrere Themenwelten. Die Menüfunktion ist in ihrer Bedeutung festgelegt; eine vollständige Menü-/Übungsfortsetzungsoberfläche wird dadurch nicht als zusätzliche P1a-/P1b-Abnahme gefordert.

Statusänderungen nur mit Nachweisen. Neue Erkenntnisse in Entscheidungen und offenen Paketen pflegen, statt an einem überholten Plan festzuhalten. Keine unbelegten Zeitversprechen.

Der weitere Fidelity-Pass aus #6 / PR #18 ergänzt detailliertere Werkstatt-/Figurenmodelle, CC0-Fotoholz mit längsgerichteter Maserung, gewebte Matte, feinere Materialantwort und Kontaktlicht. Vier neue reale 1440p-Iterationen gegen den externen Mock und `5659242`, eine zusätzliche Chrome-Farbraumkorrektur sowie Windows-Pacing- und Present-Messungen sind im [P2b-Bericht](p2b-visual-slice.md) dokumentiert. Die Referenzkopie wird gemäß der neuesten #6-Klarstellung nicht repariert oder erneut importiert. Subjektive Nutzerabnahme und persönlich gespielter Windows-Vollauf bleiben offen; PR #18 bleibt Draft.
