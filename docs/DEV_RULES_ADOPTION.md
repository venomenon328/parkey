# Einführung von dev-rules

## Herkunft

| Merkmal | Wert |
| --- | --- |
| Quelle | `venomenon328/dev-rules`, Ordner `rules/` |
| Exakter Quellcommit | `a662d3c2c1ba004de5bb65fbd16f8091c4abcce4` |
| Paketversion | `0.1.0-rc.2` |
| Quell-/Ziel-Tree des Regelpakets | `76f2e0b84f447658b234e1ecb41328cb541ec0ce` |
| Ziel | `docs/dev-rules/`, fünf unveränderte Dateien |
| Auftrag | [Issue #19](https://github.com/venomenon328/parkey/issues/19), zugehöriger Einführungs-PR |
| Projektbasis | `a42e8266ce5f4f7b7fc8fc57b71243fcd1b40eff` |

Eigentümerauftrag vom 9. September 2026: direkte Einführung ohne Pilot; nur fachliche Altregeln automatisch erhalten, nichtfachliche Regeln nach konkretem Nutzen bewerten. Im Einführungsbranch gilt die Struktur für dessen Auftrag, projektweit nach freigegebenem Merge. Der tatsächliche Mergecommit und die Prüfbelege werden im PR festgehalten. Kein Tag oder Release als zusätzliche Voraussetzung.

Die [bereitgestellten Projekteinstellungen](CHATGPT_PROJECT_INSTRUCTIONS.md) nach dem Einführungsmerge separat einsetzen. Ihre Bereitstellung ist keine Änderung der ChatGPT-Oberfläche. Alten Pflichtverweis auf `Codex-Empfehlung.txt` und doppelte allgemeine Vorgaben entfernen, unabhängige Fachquellen erhalten.

## Bewerteter Regelabgleich

| Altregel | Entscheidung und Grund |
| --- | --- |
| D-Entscheidungen, PoC-Regelprofil, Spiel-, Speicher- und Streckenverträge | Fachlich unverändert erhalten; gezielt im Projektprofil verlinkt. |
| Grundsätzlicher Ausschluss von Modell-/Reasoning-Metadaten aus dem Repo | Ersetzt: gemeinsame lokale Modellregeln und optionale belegte PR-Ausführungsdaten sind sinnvoll. Keine Verlagerung einzelner Empfehlungen in Spieldesignverträge. |
| Wiederholte allgemeine Scope-, Dokument-, Branch-, Draft- und Übergaberegeln | Durch den gemeinsamen Workflow ersetzt statt erneut definiert. Bestehende konkret beauftragte Branches/Abhängigkeiten bleiben gültig. |
| Pauschale Lektüre aller Grundlagen bei jeder Änderung | Auftragsbezogen neu zugeschnitten; Fachänderungen müssen weiterhin die relevanten vollständigen Vertragsabschnitte berücksichtigen. |
| Godot-/Template-Pin und echter GDScript-Runner | Technisch begründet fortgeführt: reproduzierbarer gemeinsamer Windows-/Web-Kern. |
| Beide Exporte, Fehler-/Leersuite-Verhalten, getrennte manuelle Nachweise | Fortgeführt: echte Plattform-/Verifikationsgrenzen. Keine zusätzliche identische lokale Vollprüfung neben passender CI. |
| Lokaler Werkzeugpfad | Als bestehende Umgebungskonvention bewusst erhalten; kein neues Installations- oder Bereinigungsprojekt. |
| Sprache Deutsch / englische Code-Bezeichner | Beibehalten für Konsistenz des vorhandenen Projekts, kein allgemeiner Produktzwang. |
| Bereits verschobene Browserabnahme | Status erhalten; weder als bestanden ausgeben noch pauschal wieder blockierend machen. |

Das [Projektprofil](PROJECT_PROFILE.md) ist die aktuelle operative Definition dieser Fortführungen und Ablösungen; der Abgleich erklärt die Gründe und bildet keine parallele technische Spezifikation.

## Übergang und Nachweis

Laufende Issues/PRs nicht zurücksetzen. Beim nächsten Übergabepunkt betroffenen Branchstand, Quellen und neue Regeln abgleichen. Einen benötigten befristeten Altprozess ausdrücklich im betroffenen Issue dokumentieren, nicht frei zwischen widersprüchlichen Varianten wählen. Keine neue fachliche Abnahme oder Scope-Erweiterung ableiten.

Snapshot-Identität, lokale Dateiverweise und vollständigen Dokumentdiff prüfen. Automatisierte CI-Belege gehören zum konkreten Head/Test-Merge-Stand im PR. Fachspezifikationen, Spielcode, Assets, Tests, CI und Pins bleiben unverändert. Erkenntnisse aus regulären Aufgaben fließen bei tatsächlichem Bedarf in Profil oder zentrale Regeln ein; keine separate Pilotabnahme.
