# Entscheidungsregister

Stand: 2026-09-05. Quelle ist die Projektabstimmung einschließlich freier Streckengeometrie und der anschließenden P1-Regelfreigabe. Implementierungsstand: [Roadmap](roadmap.md). Paketplan: [Umsetzungsplan](implementation-plan.md). Verbindliche P1-Details: [P1-Regelprofil](p1-rule-profile.md).

## Statusdefinitionen

**Bestätigt:** ausdrücklich festgelegte Anforderung. **PoC-freigegeben:** für die anstehende Umsetzung verbindlich, ohne damit endgültiges Balancing festzuschreiben. **Vorläufig:** zu erprobender Wert oder Gestaltungsvorschlag. **Vorgeschlagen:** noch nicht bestätigt. **Offen:** vor dem betreffenden Meilenstein zu entscheiden. Eine Freigabe ist keine Implementierungsabnahme.

## Bestätigte Anforderungen

| ID | Entscheidung |
| --- | --- |
| D-001 | Eine sichtbare Spielfigur durchläuft einen 3D-Parcours in Third-Person-Ansicht mit klarem Start und Ziel. |
| D-002 | Ein Tastendruck auf den Buchstaben eines erreichbaren angrenzenden Felds bewegt die Figur dorthin. Die möglichen Zielfelder müssen von jeder Position aus eindeutig beschriftet sein. |
| D-003 | Korrektes Tippen hat kein künstliches Geschwindigkeitslimit. Animationen dürfen keinen festen Mindestabstand zwischen gültigen Schritten erzwingen. Eine Fehlerpause ist die ausdrücklich gewünschte Ausnahme. |
| D-004 | Falsche Eingaben führen zu einer kurzen Bewegungssperre. Eine bloße nachträgliche Zeitaddition ohne Stillstand ersetzt diese Anforderung nicht. |
| D-005 | Parcours sollen zufallsgeneriert und über Seeds reproduzierbar sein. Ihre Generierung soll gestalterische Logik haben, statt nur beliebige Felder aneinanderzureihen. |
| D-006 | Routenwahl ist Teil des Zielkonzepts: Verzweigungen und ein möglicher Vorteil längerer, leichter tippbarer Wege gegenüber kurzen, schwierigen Wegen. Konkrete Abschnittstypen und das Schwierigkeitsmodell sind noch nicht abschließend festgelegt. |
| D-007 | Der Timer ist während des Laufs stets sichtbar und zeigt Tausendstelsekunden. Erfolgreiche Abschlüsse werden mit ihrer Zeit in einer Rangliste gespeichert. Lokal/online und plattformübergreifende Wertung sind noch offen. |
| D-008 | Godot ist die gewählte Engine. Schwerpunkt ist eine grafisch hochwertige Windows-Anwendung. Eine zusätzliche Browserversion soll nach Möglichkeit auf derselben Codebasis und Spiellogik beruhen. Identische Grafik ist keine Anforderung. |
| D-009 | Festlegungen werden im Repository dokumentiert und bei Änderungen aktuell gehalten. Die Spezifikation darf nicht ausschließlich aus verteilten Chat- oder Issue-Aussagen bestehen. |
| D-010 | Das allgemeine Streckenmodell ist nicht an ein regelmäßiges Raster, orthogonale Richtungen, gleiche Feldformen/-größen oder eine feste Nachbarzahl gebunden. Felder dürfen unterschiedlich angeordnet, geformt, gedreht und moderat unterschiedlich groß sein; übermäßig große Felder sind nicht das Ziel. Ein einfaches PoC-Layout ist nur eine Inhaltsvereinfachung, keine Einschränkung von Kern oder Datenmodell. |
| D-011 | Direkte Übergänge sind explizit festgelegt und räumlich eindeutig lesbar. Erkennbare gemeinsame Randabschnitte können Übergänge bilden, auch von einem größeren zu mehreren kleineren Feldern. Eine bloße Eckberührung oder optische Nähe begründet keine automatische Erreichbarkeit. Kleine konsistent lesbare Fugen sind möglich; weder unsichtbare Übergangsverbote noch Verbindungen über unverständlich große Lücken. |
| D-012 | Ein gültiger Übergang bleibt unabhängig von Feldgröße, Winkel und räumlicher Entfernung ein Eingabeschritt. Für korrekte Eingaben bestimmt das Tippen den logischen Fortschritt; die Darstellung passt sich flüssig und sinnvoll an, nicht umgekehrt. Keine entfernungsabhängige Wartezeit, Mindestlaufdauer oder zusätzliche Eingabe auf größeren Feldern. Die ausdrücklich vereinbarte Fehlerpause bleibt getrennt. |
| D-013 | Spielrelevante räumliche Gestaltung gehört zur Streckenidentität: Anordnung, Grundflächen, Größen, Ausrichtungen und Übergänge dürfen trotz identischer Buchstaben/Topologie keine unbemerkte Ranglistenvermischung erzeugen. Rein dekorative Materialien, Oberflächendetails und Umgebung sind davon getrennt. |

## Für P1 freigegebene Entscheidungen

Die folgenden Entscheidungen wurden am 2026-09-05 nach der Paketklärung ausdrücklich freigegeben. Das Profil `p1-input-start-v1` konkretisiert die Randfälle; noch kein P1-Spielcode ist damit implementiert.

| ID | Entscheidung |
| --- | --- |
| D-014 | Der Spieler startet selbst mit dem ersten Bewegungsbuchstaben. Kein Countdown und kein Enter-Start. Derselbe Tastendruck setzt den Zeitbeginn und wird als erster Bewegungsversuch verarbeitet. Im Profil bedeutet dies den ersten zugelassenen A–Z-Key-down, auch wenn dessen Zielfeld ungültig ist; dann beginnen Zeit und reguläre Fehlerpause gemeinsam. |
| D-015 | Backspace ist Quick Restart: derselbe Parcours zurück auf Start, null Zeit/Fehler, keine Sperre; erst der nächste neue Bewegungsbuchstabe startet. Escape bedeutet dagegen klassisches Pausemenü bzw. eine eigenständige Menüanforderung, nicht Reset oder Quick Restart. Eine fertige Menüoberfläche ist noch nicht beauftragt. |
| D-016 | Die Fehlerpause wird für P1 mit 200 ms erprobt. Der Timer läuft; Eingaben während der Frist werden verworfen, nicht gepuffert, nicht nachgezählt und verlängern die Sperre nicht. Keine doppelte Zeitaddition; neue Eingaben ab exakt Fristende normal prüfen. |
| D-017 | P1 verwendet A–Z ohne Groß-/Kleinschreibungsunterschied, beidseitige explizite Verbindungen und Rückwege. Neue Key-downs zählen in Empfangsreihenfolge, Echo/Key-up nicht; Überlappung ist erlaubt. Modifier-/Shortcut-/UI-Eingaben und Nicht-A–Z-Zeichen starten oder bewegen nicht und verursachen keine Fehler. |
| D-018 | Fokusverlust bricht einen gestarteten Versuch ab und macht ihn nicht wertbar; keine gewertete Pause mit anschließendem Fortsetzen. Vor dem ersten Buchstaben gibt es noch keinen laufenden Versuch. Bereits gültig abgeschlossene Ergebnisse bleiben von späterem Fokusverlust unberührt. |

Die getrennte Menü-/Wertungsbehandlung, Start-/Zielgrenzen und Paketabgrenzung stehen verbindlich in [p1-rule-profile.md](p1-rule-profile.md). Technische Auslegungen sind dort als Konkretisierung kenntlich gemacht; Menüoberfläche und Übungsfortsetzung sind kein neuer Pflichtumfang.

## Parameter und Rückmeldungen

| ID | Wert/Idee | Einordnung |
| --- | --- | --- |
| T-001 | Fehlerpause zunächst **200 ms** | Durch D-016 für das erste Profil freigegeben; weiterhin kein endgültiges Balancing. Zentral konfigurieren und wertungsrelevante Änderungen versionieren. |
| T-002 | Kleine Kopfschüttelanimation bei einem Fehler | Vorgeschlagene visuelle Rückmeldung für den spielbaren Parcours. Sie darf die definierte Sperrdauer nicht verlängern oder spielrelevante Zeichen verdecken. |

## Umsetzungsvorschläge und abgelöste Einträge

| ID | Vorschlag / Status | Begründung / Spezifikation |
| --- | --- | --- |
| P-001 | Ein Godot-4-Projekt mit typisiertem GDScript; P0-Grundlage bereits abgenommen | Gemeinsamer Windows-/Web-Spielkern; siehe [Architektur](architecture.md). |
| P-002 | Windows Forward+, Web Compatibility; P0-Profile bereits abgenommen | Unterschiedliche Darstellung, identische Regeln. Weitere Darstellung wird paketweise geprüft. |
| P-003 | **Für P1 freigegeben durch D-016** | Fehlerfrist, Verwerfen ohne Puffer/Verlängerung und weiterlaufender Timer. |
| P-004 | **Für P1 freigegeben durch D-017** | A–Z, beidseitige explizite Verbindungen. Frühere Viererraster-Einschränkung bleibt durch D-010 ersetzt. |
| P-005 | **Abgelöst durch D-014/D-015/D-018** | Früherer Enter-/Countdown-Start gilt nicht mehr. Zieleingang bleibt logisch bestimmt; Fokus-/Menübehandlung gemäß P1-Profil. |
| P-006 | Zunächst lokale Ranglisten je Strecken-/Regelidentität, noch kein Online-Dienst | Geplanter Lieferumfang von P1c; Speicher-/Onlinefragen blockieren den P1a-Kern nicht. Keine automatische Windows-/Web-Synchronisierung. |
| P-007 | Automatische, erhöhte Third-Person-Kamera; lesbare Nachbarn und rechtzeitig sichtbare Verzweigungen | Keine Mausbedienung nötig; Informationsverlust durch Kamera darf nicht zur Hauptschwierigkeit werden. |
| P-008 | Zuerst handgebaute Teststrecken, danach modulbasierte Seed-Generierung | Erst gute Abschnittstypen finden, dann reproduzierbar kombinieren. |
| P-009 | Unabhängige logische Position und aufholende visuelle Bewegung; keine unbeschränkte Animationswarteschlange | D-003/D-012 sind verbindlich; die konkrete visuelle Umsetzung wird in P1b erprobt. |

Nicht freigegebene Vorschläge werden nicht stillschweigend zu endgültigen Entscheidungen. Statusänderungen erfolgen nachvollziehbar.

## Offene Entscheidungen und Zeitpunkt

**P1a / Issue #2:** Das Regelprofil ist freigegeben; es fehlt keine weitere Start-/Fehler-/Fokusfreigabe. Technische Ausgestaltung von Datenformat, wenigen einfachen ebenen Formen, Zahlenpräzision und vorläufigen Layouttoleranzen erfolgt im Paket mit Dokumentation und Tests. Keine universelle Polygon-Engine. Die Unterlagen liegen als Vorbereitung auf `codex/p1a-run-core`; die Umsetzung setzt dort fort, ohne auf einen separaten Dokumentationsmerge zu warten.

**P1b / Issue #3:** Sichtbarer Bewegungsrückstand beim Fehler und bei hoher Tippgeschwindigkeit praktisch prüfen. Escape bleibt von Quick Restart getrennt; eine vollständige Menü-/Fortsetzungsoberfläche wird nicht vorausgesetzt.

**Vor P2/P3:** Zielhardware, Auflösung und Leistungsbudget für #6; Kamera-/Routenlesbarkeit sowie Tippbarkeit in #5 erproben. Nur geeignete Bausteine für #7 freigeben. Weitere Tastaturlayouts und endgültige Streckenlängen bleiben offen. Größenbereiche, Mindestbreiten lesbarer Randübergänge und Fugentoleranzen sind an Testabschnitten zu erproben. Höhenwechsel, Sprung-/Brückenmechaniken und ein beliebiger Polygon-Generator sind nicht mitbeauftragt.

**Vor einer öffentlichen Onlinewertung:** Windows-/Web-Pool, Gleichstände, Konten/Identität, Validierungs-/Missbrauchskonzept und Eingabedatenspeicherung klären. P1c benötigt lediglich einen dokumentierten lokalen Gleichstands-/Aufbewahrungsvertrag.

**Vor Veröffentlichung:** Projekt- und Asset-Lizenzen, Name/Branding, Vertriebsweg und gegebenenfalls Hosting. P4 bereitet Testartefakte vor, veröffentlicht nicht automatisch.

## Änderungshistorie

- 2026-09-05: Initiale Anforderungen, Fehlerpause mit vorläufigen 200 ms/Kopfschütteln, Godot und Windows-Fokus dokumentiert; Empfehlungen getrennt erfasst.
- 2026-09-05: Neun Umsetzungspakete vorbereitet. Start-/Steuertastendetails zunächst nur als Experiment vorgeschlagen, keine Produktfreigabe behauptet.
- 2026-09-05: D-010 bis D-013 nach Nutzerbestätigung ergänzt; P-004, Spezifikation, Tests und Pakete angepasst. P0 bleibt abgenommen.
- 2026-09-05: D-014 bis D-018 und `p1-input-start-v1` nach Nutzerfreigabe dokumentiert. Start per erstem Buchstaben ersetzt Countdown/Enter; Quick Restart und Escape-Menü getrennt. Fehler-, Rückweg-, Eingabe- und Fokusregeln für P1 freigegeben. Vorbereitung auf P1a-Branch, noch keine Implementierungsabnahme.
