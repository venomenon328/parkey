# Entscheidungsregister

Stand: 2026-09-05. Quelle ist die Projektabstimmung einschließlich freier Streckengeometrie, P1-Regelfreigabe und der manuellen P1b-Rückmeldung zu Erreichbarkeit, Feldstatus und Kamera. Implementierungsstand: [Roadmap](roadmap.md). Paketplan: [Umsetzungsplan](implementation-plan.md). Verbindliche P1-Details: [P1-Regelprofil](p1-rule-profile.md), [P1b-Integration](p1b-implementation.md) und [P1b-Spielbarkeitsnacharbeit](p1b-playability.md).

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

Die folgenden Entscheidungen wurden am 2026-09-05 nach der Paketklärung ausdrücklich freigegeben. Das Profil `p1-input-start-v1` konkretisiert die Randfälle. Der testbare P1a-Kern ist über PR #12 abgenommen und gemergt; der sichtbare P1b-Spielablauf und die erste Review-Nacharbeit sind im Draft-PR #13 implementiert, aber noch nicht vollständig abgenommen.

| ID | Entscheidung |
| --- | --- |
| D-014 | Der Spieler startet selbst mit dem ersten Bewegungsbuchstaben. Kein Countdown und kein Enter-Start. Derselbe Tastendruck setzt den Zeitbeginn und wird als erster Bewegungsversuch verarbeitet. Im Profil bedeutet dies den ersten zugelassenen A–Z-Key-down, auch wenn dessen Zielfeld ungültig ist; dann beginnen Zeit und reguläre Fehlerpause gemeinsam. |
| D-015 | Backspace ist Quick Restart: derselbe Parcours zurück auf Start, null Zeit/Fehler, keine Sperre; erst der nächste neue Bewegungsbuchstabe startet. Escape bedeutet dagegen klassisches Pausemenü bzw. eine eigenständige Menüanforderung, nicht Reset oder Quick Restart. Eine fertige Menüoberfläche ist noch nicht beauftragt. |
| D-016 | Die Fehlerpause wird für P1 mit 200 ms erprobt. Der Timer läuft; Eingaben während der Frist werden verworfen, nicht gepuffert, nicht nachgezählt und verlängern die Sperre nicht. Keine doppelte Zeitaddition; neue Eingaben ab exakt Fristende normal prüfen. |
| D-017 | P1 verwendet A–Z ohne Groß-/Kleinschreibungsunterschied, beidseitige explizite Verbindungen und Rückwege. Neue Key-downs zählen in Empfangsreihenfolge, Echo/Key-up nicht; Überlappung ist erlaubt. Modifier-/Shortcut-/UI-Eingaben und Nicht-A–Z-Zeichen starten oder bewegen nicht und verursachen keine Fehler. |
| D-018 | Fokusverlust bricht einen gestarteten Versuch ab und macht ihn nicht wertbar; keine gewertete Pause mit anschließendem Fortsetzen. Vor dem ersten Buchstaben gibt es noch keinen laufenden Versuch. Bereits gültig abgeschlossene Ergebnisse bleiben von späterem Fokusverlust unberührt. |

Die getrennte Menü-/Wertungsbehandlung, Start-/Zielgrenzen und Paketabgrenzung stehen verbindlich in [p1-rule-profile.md](p1-rule-profile.md). Technische Auslegungen sind dort als Konkretisierung kenntlich gemacht; Menüoberfläche und Übungsfortsetzung sind kein neuer Pflichtumfang.

## Bestätigte Darstellungsentscheidungen aus dem P1b-Review

| ID | Entscheidung |
| --- | --- |
| D-019 | Bereits betretene Felder und aktuell über die gespeicherten Verbindungen erreichbare Nachbarfelder haben einen klar erkennbaren visuellen Status gegenüber dem Standard. Auch das aktuelle Feld bleibt eindeutig. Besuchsstatus und Erreichbarkeit sind kombinierbare Informationen: Ein besuchter Nachbar darf weiterhin als erreichbar erkennbar sein. Die Helligkeitsrichtung ist durch D-022 festgelegt; genaue Faktoren und dezente Zusatzsignale bleiben zu erproben. |
| D-020 | Die Kamera bewegt sich innerhalb eines Versuchs kontinuierlich und flüssig, ohne Jump-Cuts, schlagartiges Neuausrichten oder Reset bei Tastendrücken. Position und Blickrichtung/Blickziel müssen gemeinsam berücksichtigt werden. Auch Fehler, Rückwege, Gabelungen und schnelles Aufholen dürfen keinen Kameraschnitt auslösen. Eine notwendige Figurenkorrektur darf nicht die Kamera hart versetzen. Initiale Aufstellung und ausdrücklich ausgelöster Quick Restart sind getrennte Lebenszyklusvorgänge, keine Ausnahme für normale Eingaben. |
| D-021 | Bevorzugte Gestaltungsrichtung ist eine perspektivische Third-Person-Rückansicht wie im ursprünglichen Mock-Screenshot: Kamera hinter der Figur mit Blick auf den vorausliegenden Parcours, nicht die seitlich erhöhte, isometrisch wirkende Draufsicht des P1b-Prüfstands. Diese Richtung ist in der aktuellen P1b-Nacharbeit umgesetzt; genaue Höhe, Abstand, Neigung, Sichtfeld und Kurven-/Rückwegführung bleiben zu erproben. Eine moderate Erhöhung für lesbare Feldoberflächen ist zulässig. D-020 sowie die Lesbarkeit des aktuellen Felds, aller erreichbaren Nachbarn und der Routenoptionen bleiben verbindlich. |
| D-022 | Statusfarben bleiben Varianten der jeweiligen Grundfarbe eines Tiles: bereits besucht dunkler, aktuell betretbar etwas heller als der Standard. Keine eigenständige bunte Statuspalette und kein vollständiger Farbtonwechsel für besucht/erreichbar/aktuell. D-019 bleibt kombinierbar; für besucht und zugleich erreichbar hat die helle Erreichbarkeitsdarstellung Vorrang, eine dezente Formmarkierung erhält den Besuchshinweis. Das aktuelle Feld bleibt durch einen dezenten Rand oder Positionsmarker eindeutig. Exakte Helligkeitsfaktoren und Details sind noch keine endgültigen Werte. |

Konkretisierung für P1b: Besuchsstatus wird aus akzeptierten logischen Feldwechseln je Versuch geführt, nicht aus einer nachlaufenden Figur oder gedrückten, aber verworfenen Tasten. Das besetzte Startfeld ist bereits besucht; Quick Restart setzt die Besuchshistorie auf diesen Ausgangszustand zurück. Rückwege verlieren die Information nicht. Der Status verändert weder Streckendaten/-identität noch Kanten, Buchstaben oder Wertungsregeln. D-022 bestimmt die Helligkeitsgestaltung; zusätzliche Formsignale müssen zurückhaltend bleiben. Eigene Grundfarben von Start/Ziel werden durch diese Regel nicht verboten, aber ebenfalls nicht durch fremde Statusfarben ersetzt.

D-012 wird durch die Rückmeldung zu `9641675` präzisiert: Ein lediglich begrenzter, aber deutlich wahrnehmbarer Darstellungsrückstand reicht nicht. Die Figur soll dem tatsächlichen Tipprhythmus eng folgen; Kameraführung, sichtbare Figur und logischer Standort werden gemeinsam beurteilt. Die bisher implementierten 350/450 ms sind keine freigegebenen Normalverzögerungen. Neue Zielwerte sind Darstellungsparameter und werden mit Einzelinput, getakteten Folgen und Extrembursts getestet; keine Änderungen an Eingabe- oder Fehlerregeln.

D-021 bleibt eine Präferenz mit offenen Parametern, keine endgültig freigegebene Perspektive. Der Nutzer hat die Verdeckung der nächsten Buchstaben gemeldet und eine andere Perspektive als Möglichkeit genannt, aber keine konkrete neue Ansicht beschlossen. Für die P1b-Abnahme ist eine begrenzte Lösung für aktuelle und unmittelbar erreichbare Buchstaben erforderlich; ein fertiges Kamerasystem für jede künftige Strecke ist nicht verlangt. Details und Umsetzungsvorschläge: [P1b-Spielbarkeitsnacharbeit](p1b-playability.md).

D-011 wird durch den manuellen Befund am W-Feld bekräftigt: Eine als normal begehbar erscheinende Seitenverbindung zu F ist nicht durch eine fehlende Datenkante gerechtfertigt. Die Lösung ist ein konsistenter Graph mit passenden Übergängen oder eine räumlich eindeutig getrennte Streckenführung. Bloß etwas anders große, perspektivisch kaum unterscheidbare Fugen oder ein HUD-Hinweis ersetzen diese Konsistenz nicht. Kein automatisches Hinzufügen aller nahen Felder zur Laufzeit.

## Parameter und Rückmeldungen

| ID | Wert/Idee | Einordnung |
| --- | --- | --- |
| T-001 | Fehlerpause zunächst **200 ms** | Durch D-016 für das erste Profil freigegeben; weiterhin kein endgültiges Balancing. Zentral konfigurieren und wertungsrelevante Änderungen versionieren. |
| T-002 | Kleine Kopfschüttelanimation bei einem Fehler | Für P1b mit asymmetrischem Kopfsignal und gemeinsamem Pivot nachgearbeitet; technische Auslösung ist geprüft, menschliche Wahrnehmbarkeit bleibt manuell abzunehmen. Die Rückmeldung verlängert die definierte Sperrdauer nicht und darf spielrelevante Zeichen nicht verdecken. |

## Umsetzungsvorschläge und abgelöste Einträge

| ID | Vorschlag / Status | Begründung / Spezifikation |
| --- | --- | --- |
| P-001 | Ein Godot-4-Projekt mit typisiertem GDScript; P0-Grundlage bereits abgenommen | Gemeinsamer Windows-/Web-Spielkern; siehe [Architektur](architecture.md). |
| P-002 | Windows Forward+, Web Compatibility; P0-Profile bereits abgenommen | Unterschiedliche Darstellung, identische Regeln. Weitere Darstellung wird paketweise geprüft. |
| P-003 | **Für P1 freigegeben durch D-016** | Fehlerfrist, Verwerfen ohne Puffer/Verlängerung und weiterlaufender Timer. |
| P-004 | **Für P1 freigegeben durch D-017** | A–Z, beidseitige explizite Verbindungen. Frühere Viererraster-Einschränkung bleibt durch D-010 ersetzt. |
| P-005 | **Abgelöst durch D-014/D-015/D-018** | Früherer Enter-/Countdown-Start gilt nicht mehr. Zieleingang bleibt logisch bestimmt; Fokus-/Menübehandlung gemäß P1-Profil. |
| P-006 | Zunächst lokale Ranglisten je Strecken-/Regelidentität, noch kein Online-Dienst | Geplanter Lieferumfang von P1c; Speicher-/Onlinefragen blockieren den P1a-Kern nicht. Keine automatische Windows-/Web-Synchronisierung. |
| P-007 | Automatische perspektivische Third-Person-Rückansicht gemäß D-021; lesbare Nachbarn und rechtzeitig sichtbare Verzweigungen | Die bisherigen direkten Kameraresets sind nachgearbeitet. Tile-eigene, kameragerichtete Zusatzbuchstaben oberhalb der Kopfmitte beheben die gemeldete Nahbereichsverdeckung im Handkurs; finale Kameraparameter und menschliche Abnahme bleiben offen. |
| P-008 | Zuerst handgebaute Teststrecken, danach modulbasierte Seed-Generierung | Erst gute Abschnittstypen finden, dann reproduzierbar kombinieren. |
| P-009 | Unabhängige logische Position und aufholende visuelle Bewegung; keine unbeschränkte Animationswarteschlange | Endliche Wegpunktgrenze und kurze 50-/80-ms-Aufholbudgets sind implementiert. Neue Schritte verdichten einen laufenden Verlauf, statt dessen Frist zurückzusetzen. Die kontrollierte P1b-Folge misst maximal 2,314 und im Mittel 0,407 Welteinheiten Rückstand; menschliche Abnahme bleibt offen. D-003/D-012/D-020 bleiben verbindlich. |

Nicht freigegebene Vorschläge werden nicht stillschweigend zu endgültigen Entscheidungen. Statusänderungen erfolgen nachvollziehbar.

## Offene Entscheidungen und Zeitpunkt

**P1a / Issue #2:** Abgeschlossen. Regelprofil, Datenformat, kleines ebenes Layoutprofil, Zahlenpräzision und Toleranzen sind dokumentiert und technisch abgenommen. Merge über PR #12: `5ddf921fdf3736f9e521b8e37b833139beee636f`. Keine neue Freigabe des Kernprofils erforderlich.

**P1b / Issue #3:** `9641675` behebt die bisherigen technischen Ursachen für enge Asttrennung, Kamera-Snaps und fehlenden Canvas-Rückfokus. N1–N3 aus Re-Review 5122577064 verdichten normales Nachlaufen in kurze laufende Budgets, ergänzen tile-eigene Zusatzbuchstaben und leiten Statusfarben aus den jeweiligen Grundfarben ab. Die kontrollierte P1b-Folge misst maximal 2,314 und im Mittel 0,407 Welteinheiten Rückstand ohne Figurenkorrektur. CI und reale Exportläufe werden auf dem korrigierten Commit erneut nachgewiesen. Kein Merge und keine vollständige manuelle Abnahme. Escape, Timing, Fehlerfrist und Paketgrenzen bleiben unverändert.

**Vor P2/P3:** Zielhardware, Auflösung und Leistungsbudget für #6; Kamera-/Routenlesbarkeit sowie Tippbarkeit in #5 erproben. Nur geeignete Bausteine für #7 freigeben. Weitere Tastaturlayouts und endgültige Streckenlängen bleiben offen. Größenbereiche, Mindestbreiten lesbarer Randübergänge und Fugentoleranzen sind an Testabschnitten zu erproben. Höhenwechsel, Sprung-/Brückenmechaniken und ein beliebiger Polygon-Generator sind nicht mitbeauftragt.

**Vor einer öffentlichen Onlinewertung:** Windows-/Web-Pool, Gleichstände, Konten/Identität, Validierungs-/Missbrauchskonzept und Eingabedatenspeicherung klären. P1c benötigt lediglich einen dokumentierten lokalen Gleichstands-/Aufbewahrungsvertrag.

**Vor Veröffentlichung:** Projekt- und Asset-Lizenzen, Name/Branding, Vertriebsweg und gegebenenfalls Hosting. P4 bereitet Testartefakte vor, veröffentlicht nicht automatisch.

## Änderungshistorie

- 2026-09-05: Initiale Anforderungen, Fehlerpause mit vorläufigen 200 ms/Kopfschütteln, Godot und Windows-Fokus dokumentiert; Empfehlungen getrennt erfasst.
- 2026-09-05: Neun Umsetzungspakete vorbereitet. Start-/Steuertastendetails zunächst nur als Experiment vorgeschlagen, keine Produktfreigabe behauptet.
- 2026-09-05: D-010 bis D-013 nach Nutzerbestätigung ergänzt; P-004, Spezifikation, Tests und Pakete angepasst. P0 bleibt abgenommen.
- 2026-09-05: D-014 bis D-018 und `p1-input-start-v1` nach Nutzerfreigabe dokumentiert. Start per erstem Buchstaben ersetzt Countdown/Enter; Quick Restart und Escape-Menü getrennt. Fehler-, Rückweg-, Eingabe- und Fokusregeln für P1 freigegeben. Vorbereitung auf P1a-Branch, damals noch keine Implementierungsabnahme.
- 2026-09-05: P1a-Kern auf `codex/p1a-run-core` implementiert: getrennte Graph-/Layoutvalidierung, versionierte Strecken-/Regelidentität, monotone Zeit, Eingabeadapter und RunSession.
- 2026-09-05: Nacharbeit `617015d` geprüft; P1a über PR #12 abgenommen und gemergt, CI auf Merge-Commit erfolgreich. P1b auf dieser Grundlage vorbereitet; bestehende Regeln unverändert. Integration und echte Spiel-/Grafikabnahme noch ausstehend.
- 2026-09-05: P1b-Handkurs, Spielszene, HUD, begrenztes visuelles Aufholen und `integration`-Suite im Draft-PR #13 umgesetzt. Das Regelprofil bleibt unverändert; Review und vollständige manuelle Plattformabnahme stehen getrennt aus.
- 2026-09-05: Manuelle P1b-Rückmeldung erfasst. D-019 ergänzt den sichtbaren Besuchsstatus und bekräftigt die Nachbarmarkierung; D-020 präzisiert durchgehend flüssige Kameraführung. D-011 gilt auch für optisch irreführende Seitenfugen. Dokumentation und Review sind noch keine Fehlerbehebung oder Abnahme.
- 2026-09-05: D-021 hält die Nutzerpräferenz für eine perspektivische Rückansicht nach dem ursprünglichen Mock fest, statt der isometrisch wirkenden seitlichen Draufsicht. Kameranacharbeit in P1b berücksichtigt diese Richtung zusammen mit D-020; konkrete Parameter und manuelle Abnahme bleiben offen.
- 2026-09-05: Review-Nacharbeit in PR #13 implementiert: klare Asttrennung samt enger P1-Negativprüfung, kombinierbare Feldzustände/Besuchsspur, kontinuierliche Rückkamera, echter Canvas-Rückfokus und sichtbarer Kopfhinweis. OS-synthetische Exportläufe ersetzen weiterhin keine physische Nutzerabnahme.
- 2026-09-05: Re-Review von `9641675`: bisherige technische Korrekturen nachvollzogen, CI geprüft. D-022 übernimmt die neue Helligkeitsvorgabe; zu träges Nachlaufen und Verdeckung unmittelbar nötiger Buchstaben bleiben gezielt nachzuarbeiten. Keine endgültige neue Kameraperspektive beschlossen, kein Spielcode durch diesen Dokumentationsnachtrag verändert.
- 2026-09-05: N1–N3 aus Re-Review 5122577064 im selben Draft umgesetzt: 50-/80-ms-Budgets werden während eines Aufholens nicht zurückgesetzt, tile-eigene Zusatzbuchstaben lösen die Nahbereichsverdeckung im Handkurs und Statusmaterialien bleiben Varianten der jeweiligen Grundfarbe. Automatisierte Messung und Tests sind ergänzt; Re-Review, CI und physische/menschliche Abnahme bleiben offen.
