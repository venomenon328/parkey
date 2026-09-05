# PoC-Roadmap

Stand: 2026-09-05. Die Initialdokumentation und die Paketplanung sind erstellt. **P0 ist implementiert und vollständig abgenommen.** Issues enthalten den konkreten Lieferumfang, [Umsetzungsplan](implementation-plan.md) und [Teststrategie](testing.md) die gemeinsamen Arbeitsverträge. Die ursprünglichen Meilensteine P0–P3 bleiben erhalten und werden in kleine Pakete zerlegt; P4 ist die abschließende Integrationsabnahme, keine zusätzliche Featurephase.

## Meilensteine und Pakete

| Meilenstein | Pakete | Überprüfbares Ergebnis | Status |
| --- | --- | --- | --- |
| D0 | Dokumentation/Planung | Anforderungen, Architekturvorschlag, neun Issues, Abhängigkeiten, Testvertrag | Dokumentiert |
| P0 | [#1](https://github.com/venomenon328/parkey/issues/1) | Gemeinsames Godot-Projekt; Windows/Web gestartet; minimale Tests/Export-CI | Abgenommen: automatisierte Prüfungen, native Windows-/Web-Starts und manuelle Hardwaretastaturtests bestanden |
| P1 | [#2](https://github.com/venomenon328/parkey/issues/2), [#3](https://github.com/venomenon328/parkey/issues/3), [#4](https://github.com/venomenon328/parkey/issues/4) | Getesteter Kern, handgebauter Third-Person-Lauf, Timer, Fehlerpause, dauerhafte lokale Bestzeiten | Nicht begonnen |
| P2 | [#5](https://github.com/venomenon328/parkey/issues/5), [#6](https://github.com/venomenon328/parkey/issues/6) | Erprobte Routenentscheidungen und gestaltete Beispielwelt mit Web-Fallback | Nicht begonnen |
| P3 | [#7](https://github.com/venomenon328/parkey/issues/7), [#8](https://github.com/venomenon328/parkey/issues/8) | Validierter Seed-Generator, integrierter Spielablauf und nachgewiesene Export-Regelparität | Nicht begonnen |
| P4 | [#9](https://github.com/venomenon328/parkey/issues/9) | Geprüfte Windows-/Web-Testpakete aus einem Commit samt Bedienung und Abnahmematrix | Nicht begonnen |

## Reihenfolge und sinnvolle Zwischenstände

`#1 → #2 → #3 → #4 → #5 → (#6 und #7) → #8 → #9`

P0 ist abgeschlossen; nächstes Paket ist **#2 / P1a**, nach ausdrücklicher Beauftragung oder Anpassung des experimentellen PoC-Regelprofils. Nach **#3** kann man erstmals einen kompletten handgebauten Lauf spielen, aber Bestzeiten noch nicht dauerhaft speichern. Nach **#4** ist der erste vollständige handgebaute Spielkern da. Jetzt folgt ein echter Spieltest, bevor Routen und Grafik ausgebaut werden.

Nach **#5** sind die Abschnittsverträge und ihre spielerische Eignung überprüft. **#6 und #7** können dann parallel arbeiten, sofern Darstellung und Generator ihre Zuständigkeiten einhalten. #8 integriert erst nach beiden Merges. Alle anderen Pakete werden standardmäßig nacheinander begonnen; keine monatelang vorab angelegten, veraltenden Arbeitsbranches.

## Abnahme-Gates

**P0:** Abgeschlossen. Editor und Export-Templates sind gemeinsam gepinnt; beide Ziele wurden aus demselben Projekt tatsächlich gestartet. Die manuelle Hardwaretastaturabnahme für Windows und Web ist bestanden.

**P1:** Vorgeschlagene Start-/Fehler-/Fokusregeln vor #2 ausdrücklich als PoC-Experiment beauftragen oder ändern. Schnelle korrekte Ereignisse ohne Animationsdeckel, genau definierte Fehlerfrist, einmalige Zielzeit, lesbare Nachbarschaft und Neustart-/Persistenztests prüfen.

**P2:** Vor der Routenwahl genügend Informationen zeigen. Unterschiedliche Tippmethoden praktisch testen, statt nur ein theoretisches Ergonomiemodell zu behaupten. Zielhardware, Auflösung, Leistungsbudget und eine repräsentative visuelle Nutzerabnahme gehören zu #6.

**P3:** Gültigkeit jeder erzeugten Strecke prüfen, begrenzte Suchversuche, versionierte Identität und feste Referenz-Seeds. Wirkliche Windows-/Web-Konformitätsläufe in #8, nicht zwei native Läufe als Browserbeweis verkaufen.

**P4:** Gleicher geprüfter Commit für beide Pakete; vollständige Plattformmatrix, bekannte Einschränkungen, Credits und tatsächliche Nutzerabnahme. Kein automatischer öffentlicher Release.

## Abschlussumfang

Der vorgeschlagene erste PoC enthält eine gestaltete Windows-Anwendung und eine Web-Version aus demselben Projekt: lesbarer Third-Person-Parcours, Start/Ziel, schnelle korrekte Eingaben, definierte Fehlerpause, Timer mit drei Nachkommastellen, lokale Ranglisten und reproduzierbare Seed-Strecken mit Routenalternativen.

Nicht Bestandteil: Onlinekonten/-Ranglisten, Cloud-Sync, Ghosts, Tagesparcours, Echtzeit-Mehrspieler, Editor, Shop, automatische Updates oder mehrere Themenwelten. Diese Ideen sind kein verdeckter Zusatzumfang der neun Pakete.

Statusänderungen nur mit Nachweisen. Wenn Spieltests andere Regeln oder Bausteine nahelegen, die betroffenen Entscheidungen und noch nicht begonnenen Issues aktualisieren, statt am überholten Plan festzuhalten. Es gibt keine unbelegten Zeitversprechen.
