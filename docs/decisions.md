# Entscheidungsregister

Stand: 2026-09-06. Quelle ist die Projektabstimmung einschließlich freier Streckengeometrie, P1-Regelfreigabe und der manuellen P1b-/P2a-Abnahmen. Implementierungsstand: [Roadmap](roadmap.md). Paketplan: [Umsetzungsplan](implementation-plan.md). Verbindliche P1-Details: [P1-Regelprofil](p1-rule-profile.md), [P1b-Integration](p1b-implementation.md) und [P1b-Spielbarkeit](p1b-playability.md).

## Statusdefinitionen

**Bestätigt:** ausdrücklich festgelegte Anforderung. **PoC-freigegeben:** für die anstehende Umsetzung verbindlich, ohne endgültiges Balancing festzuschreiben. **Vorläufig:** zu erprobender Wert oder Gestaltungsvorschlag. **Vorgeschlagen:** noch nicht bestätigt. **Offen:** vor dem betreffenden Meilenstein zu entscheiden. Freigabe, Implementierung und Abnahme sind getrennte Zustände.

## Bestätigte Anforderungen

| ID | Entscheidung |
| --- | --- |
| D-001 | Eine sichtbare Spielfigur durchläuft einen 3D-Parcours in Third-Person-Ansicht mit klarem Start und Ziel. |
| D-002 | Ein Tastendruck auf den Buchstaben eines erreichbaren angrenzenden Felds bewegt die Figur dorthin. Die möglichen Zielfelder müssen von jeder Position aus eindeutig beschriftet sein. |
| D-003 | Korrektes Tippen hat kein künstliches Geschwindigkeitslimit. Animationen dürfen keinen festen Mindestabstand zwischen gültigen Schritten erzwingen. Eine Fehlerpause ist die ausdrücklich gewünschte Ausnahme. |
| D-004 | Falsche Eingaben führen zu einer kurzen Bewegungssperre. Eine bloße nachträgliche Zeitaddition ohne Stillstand ersetzt diese Anforderung nicht. |
| D-005 | Parcours sollen zufallsgeneriert und über Seeds reproduzierbar sein. Ihre Generierung soll gestalterische Logik haben, statt nur beliebige Felder aneinanderzureihen. |
| D-006 | Routenwahl ist Teil des Zielkonzepts: Verzweigungen und ein möglicher Vorteil längerer, leichter tippbarer Wege gegenüber kurzen, schwierigen Wegen. Konkrete Abschnittstypen und das Schwierigkeitsmodell sind noch nicht abschließend festgelegt. |
| D-007 | Der Timer ist während des Laufs stets sichtbar und zeigt Tausendstelsekunden. Erfolgreiche Abschlüsse werden mit ihrer Zeit in einer Rangliste gespeichert. Der erste beauftragte Speicherausbau P1c ist lokal; Onlinewertung und plattformübergreifende Synchronisierung bleiben separat offen. |
| D-008 | Godot ist die gewählte Engine. Schwerpunkt ist eine grafisch hochwertige Windows-Anwendung. Eine zusätzliche Browserversion soll nach Möglichkeit dieselbe Codebasis und Spiellogik verwenden. Identische Grafik ist keine Anforderung. |
| D-009 | Festlegungen werden im Repository dokumentiert und bei Änderungen aktuell gehalten. Die Spezifikation darf nicht ausschließlich aus verteilten Chat- oder Issue-Aussagen bestehen. |
| D-010 | Das allgemeine Streckenmodell ist nicht an ein regelmäßiges Raster, orthogonale Richtungen, gleiche Feldformen/-größen oder eine feste Nachbarzahl gebunden. Felder dürfen unterschiedlich angeordnet, geformt, gedreht und moderat unterschiedlich groß sein; übermäßig große Felder sind nicht das Ziel. Ein einfaches PoC-Layout ist nur Inhaltsvereinfachung, keine Einschränkung von Kern oder Datenmodell. |
| D-011 | Direkte Übergänge sind explizit festgelegt und räumlich eindeutig lesbar. Erkennbare gemeinsame Randabschnitte können Übergänge bilden, auch von einem größeren zu mehreren kleineren Feldern. Bloße Eckberührung oder optische Nähe begründet keine automatische Erreichbarkeit. Kleine konsistent lesbare Fugen sind möglich; keine unsichtbaren Übergangsverbote oder unverständlichen Fernverbindungen. |
| D-012 | Ein gültiger Übergang bleibt unabhängig von Feldgröße, Winkel und räumlicher Entfernung ein Eingabeschritt. Für korrekte Eingaben bestimmt das Tippen den logischen Fortschritt; die Darstellung passt sich flüssig und sinnvoll an, nicht umgekehrt. Keine entfernungsabhängige Wartezeit, Mindestlaufdauer oder zusätzliche Eingabe auf größeren Feldern. |
| D-013 | Spielrelevante räumliche Gestaltung gehört zur Streckenidentität: Anordnung, Grundflächen, Größen, Ausrichtungen und Übergänge dürfen trotz identischer Buchstaben/Topologie keine unbemerkte Ranglistenvermischung erzeugen. Rein dekorative Materialien, Oberflächendetails und Umgebung sind davon getrennt. |

## Für P1 freigegebene Regeln

| ID | Entscheidung |
| --- | --- |
| D-014 | Der Spieler startet selbst mit dem ersten Bewegungsbuchstaben. Kein Countdown und kein Enter-Start. Derselbe Tastendruck setzt den Zeitbeginn und wird als erster Bewegungsversuch verarbeitet. Ein falscher erster zugelassener A–Z-Key-down startet Zeit und reguläre Fehlerpause gemeinsam. |
| D-015 | Backspace ist Quick Restart: derselbe Parcours zurück auf Start, null Zeit/Fehler, keine Sperre; erst der nächste neue Bewegungsbuchstabe startet. Escape bedeutet dagegen klassische Menü-/Pauseanforderung, nicht Reset oder Quick Restart. |
| D-016 | Die Fehlerpause wird für P1 mit 200 ms erprobt. Der Timer läuft; Eingaben während der Frist werden verworfen, nicht gepuffert, nicht nachgezählt und verlängern die Sperre nicht. Keine doppelte Zeitaddition; neue Eingaben ab exakt Fristende normal prüfen. |
| D-017 | P1 verwendet A–Z ohne Groß-/Kleinschreibungsunterschied, beidseitige explizite Verbindungen und Rückwege. Neue Key-downs zählen in Empfangsreihenfolge, Echo/Key-up nicht; Überlappung ist erlaubt. Modifier-/Shortcut-/UI-Eingaben und Nicht-A–Z-Zeichen starten oder bewegen nicht und verursachen keine Fehler. |
| D-018 | Fokusverlust bricht einen gestarteten Versuch ab und macht ihn nicht wertbar; keine gewertete Pause mit anschließendem Fortsetzen. Vor dem ersten Buchstaben gibt es noch keinen laufenden Versuch. Bereits gültig abgeschlossene Ergebnisse bleiben von späterem Fokusverlust unberührt. |

Details und Randfälle stehen in [p1-rule-profile.md](p1-rule-profile.md).

## Bestätigte Darstellungsentscheidungen

| ID | Entscheidung |
| --- | --- |
| D-019 | Bereits betretene Felder und aktuell erreichbare, noch nicht betretene Nachbarfelder haben einen klar erkennbaren visuellen Status gegenüber dem Standard. Das aktuelle Feld bleibt eindeutig. Wenn ein bereits betretenes Feld erneut erreichbar ist, hat der Besuchsstatus visuell Vorrang; ein zusätzlicher kombinierter „betreten und betretbar“-Status ist nicht erforderlich. |
| D-020 | Die Kamera bewegt sich innerhalb eines Versuchs kontinuierlich und flüssig, ohne Jump-Cuts, schlagartiges Neuausrichten oder Reset bei Tastendrücken. Position und Blickrichtung/Blickziel werden gemeinsam geführt. Fehler, Rückwege, Gabelungen und schnelles Aufholen dürfen keinen Kameraschnitt auslösen. |
| D-021 | Bevorzugte Gestaltungsrichtung ist eine perspektivische Third-Person-Rückansicht wie im ursprünglichen Mock: Kamera hinter der Figur mit Blick auf den vorausliegenden Parcours. Genaue Höhe, Abstand, Neigung, Sichtfeld und Kurven-/Rückwegführung bleiben zu erproben; eine moderate Erhöhung für lesbare Feldoberflächen ist zulässig. |
| D-022 | Statusfarben bleiben Varianten der jeweiligen Grundfarbe eines Tiles: besucht dunkler, ein aktuell erreichbares **unbesuchtes** Feld etwas heller als Standard. Keine eigenständige bunte Statuspalette oder vollständiger Farbtonwechsel. Bei besucht+erreichbar bleibt die besuchte/dunklere Darstellung bestehen; kein zusätzlicher kombinierter Status oder Erreichbarkeitsrand ist nötig. Das aktuelle Feld erhält weiterhin seine eigene eindeutige Kennzeichnung. |
| D-023 | Die **primäre Beschriftung der Tiles selbst** soll aus der üblichen Spielkamera sinnvoll lesbar orientiert sein. Für den aktuellen P1b-Handkurs ist gegenüber der bisherigen Bodenbeschriftung eine Drehung um **90° im Uhrzeigersinn** als konkrete Folgearbeit festgelegt. Für später frei gedrehte/unregelmäßige Tiles ist dies keine globale Rotationskonstante; Beschriftungsorientierung und Kamera werden gemeinsam auf Lesbarkeit abgestimmt. |
| D-024 | Die großen weißen schwebenden Nahbereichs-Callouts des P1b-Builds sind in dieser Form **keine akzeptierte Enddarstellung**. Ziel ist, dass die Tile-Beschriftung selbst für aktuelle und direkt erreichbare Felder ausreicht. Falls zusätzliche Lesbarkeitshilfen nötig bleiben, müssen sie wesentlich zurückhaltender und visuell in die Welt integriert sein. |

D-019/D-022 sind Darstellungszustände und verändern weder Streckendaten noch -identität. Der Besuchsstatus folgt akzeptierten logischen Feldwechseln je Versuch; Start ist besucht, Rückwege löschen Historie nicht, Quick Restart setzt auf den neuen Startzustand zurück. Ein Feld kann logisch zugleich besucht und erreichbar sein, wird dann aber ausschließlich als besucht dargestellt.

D-012 gilt auch für die sichtbare Reaktionsnähe: ein technisch begrenzter, aber deutlich wahrnehmbarer Rückstand genügt nicht. Der abgenommene P1b-Stand verwendet kurze 50-ms-Figuren- und 80-ms-Kamerabudgets, die während eines laufenden Aufholens nicht durch jeden neuen Schritt neu gestartet werden. Diese Zahlen bleiben vorläufige Darstellungsparameter.

## Parameter und Rückmeldungen

| ID | Wert/Idee | Einordnung |
| --- | --- | --- |
| T-001 | Fehlerpause zunächst **200 ms** | Durch D-016 für P1 freigegeben; weiterhin kein endgültiges Balancing. Wertungsrelevante Änderungen versionieren. |
| T-002 | Kleine Kopfschüttelanimation bei einem Fehler | In P1b technisch umgesetzt und unter Windows spielbar abgenommen. Sie verlängert die Sperrdauer nicht und darf Zeichen nicht verdecken. |

## Umsetzungslinien

| ID | Vorschlag / Status | Begründung / Spezifikation |
| --- | --- | --- |
| P-001 | Ein Godot-4-Projekt mit typisiertem GDScript; P0-Grundlage abgenommen | Gemeinsamer Windows-/Web-Spielkern; siehe [Architektur](architecture.md). |
| P-002 | Windows Forward+, Web Compatibility | Unterschiedliche Darstellung, identische Regeln. |
| P-003 | **Für P1 freigegeben durch D-016** | Fehlerfrist, Verwerfen ohne Puffer/Verlängerung und weiterlaufender Timer. |
| P-004 | **Für P1 freigegeben durch D-017** | A–Z und beidseitige explizite Verbindungen; kein Viererraster. |
| P-005 | **Abgelöst durch D-014/D-015/D-018** | Kein Enter-/Countdown-Start; Start, Restart, Menü und Fokus gemäß P1-Profil. |
| P-006 | Lokale Ranglisten je Strecken-/Regelidentität in P1c abgenommen und gemergt | [P1c-Vertrag](p1c-local-results.md); keine automatische Windows-/Web-Synchronisierung. Gleichstands-/Aufbewahrungsparameter bleiben vorläufige Arbeitsfestlegungen dieses Pakets, keine neue ausdrückliche Produktentscheidung. |
| P-007 | Automatische Third-Person-Rückkamera mit lesbaren Nachbarn und rechtzeitig sichtbaren Verzweigungen | P2a-Nutzerabnahme bestätigt die aktuelle Kamera für den Referenzkurs; komplexere, nicht überwiegend gerade Strecken können spätere Anpassungen verlangen. |
| P-008 | Zuerst handgebaute Teststrecken, danach modulbasierte Seed-Generierung | P2a bestätigt die Entscheidungs-/Geometriebausteine. Die konkrete Hypothese „länger, aber leichter tippbar“ ist durch die kleine Stichprobe nicht belegt und wird nicht als Generatorheuristik festgeschrieben. |
| P-009 | Unabhängige logische Position und aufholende visuelle Bewegung; keine unbeschränkte Animationswarteschlange | In P1b mit kurzen Budgets und begrenztem Überlastschutz abgenommen; D-003/D-012/D-020 bleiben verbindlich. |

## Aktueller Abnahmestand und offene Entscheidungen

**P0 / Issue #1:** Abgeschlossen und gemergt. Gemeinsame Godot-/Export-/CI-Grundlage sowie Windows-/Web-Hardwaretastaturdiagnose abgenommen.

**P1a / Issue #2:** Abgeschlossen und über PR #12 gemergt (`5ddf921fdf3736f9e521b8e37b833139beee636f`). Regelprofil, Datenformat, Graph-/Layoutvalidierung, Identität, monotone Zeit und RunSession sind abgenommen.

**P1b / Issue #3:** Abgeschlossen und über PR #13 gemergt (`e8e947e4100c8f3e534ae425752ac2c30c7fee7a`). `integration` 189 Assertions, `all` 350; beide Exporte, PR-CI und `main`-CI erfolgreich. Die physische/manuelle **Windows-Abnahme ist bestanden**. Wegen D-008 wurde die noch offene physische Chrome-Eingabeabnahme nach ausdrücklicher Nutzerentscheidung auf später verschoben und war kein P1b-Mergeblocker. Sie darf nicht als bereits bestanden dargestellt werden. D-023/D-024 dokumentieren die bewusst verbleibende Kamera-/Beschriftungsfolgearbeit für P2a.

**P1c / Issue #4:** Abgeschlossen und über PR #14 nach `main` gemergt (`63f1851dc9e3cf2ee72412b1a352ce5a191cbac2`). Der [Paketvertrag](p1c-local-results.md) dokumentiert numerische Mikrosekundensortierung, gemeinsame Ränge bei exakter Zeitgleichheit, Top 100 je vollständiger Identität und die Top-10-Ergebnisansicht. Review-Nacharbeit bewahrt eine alleinige Recovery-`.bak` bei Ersetzungsfehler und zeigt exakte Mikrosekunden im Ergebnisdetail und Top 10. Auf dem finalen PR-Head `c1eb976` bestanden Import, `storage` 67, `integration` 218, `all` 446 sowie beide Release-Exporte; reale Windows-/Chrome-Persistenz und der eingeschränkte Chrome-Speicherfall wurden geprüft. Speicherung verändert weder Originalzeit noch Regel-/Streckenidentität. Die Detailparameter bleiben Paketfestlegungen und werden nicht nachträglich als neue ausdrückliche Produktentscheidung ausgegeben.

**P2a / Issue #5:** Technisch implementiert und nach vier manuellen vollständigen Routenkombinationen vom Nutzer als funktional fehlerfrei und für P2a ausreichend abgenommen. Die aktuelle Kamera wird für den Referenzkurs akzeptiert; eine spätere Anpassung für komplexere, nicht überwiegend gerade Strecken bleibt möglich. Die vier Läufe `kurz/lang`, `kurz/kurz`, `lang/kurz`, `lang/lang` ergaben 7.437.978 µs / 1 Fehler, 5.743.097 µs / 1 Fehler, 6.903.868 µs / 0 Fehler und 8.705.214 µs / 2 Fehler. Wegen der sehr kleinen Stichprobe wird daraus keine allgemeine Tippbarkeitsaussage abgeleitet; die kurzen Varianten waren in diesen Läufen jedoch jeweils schneller. Die zunächst zusätzlich geplante zweite Tippmethode/separate Web-Kamerawiederholung wurde ausdrücklich als für diese P2a-Abnahme nicht mehr erforderlich bewertet und wird nicht als durchgeführt behauptet. Die Besuchsstatus-Priorität gemäß D-019/D-022 ist umgesetzt und regressionsgeprüft; GitHub-CI `34027294353` auf `b0270b4` bestand Import, vollständige Tests sowie beide Release-Exporte. Die separat verschobene physische P1b-Chrome-Eingabeabnahme bleibt offen und ist kein P2a-Mergeblocker. P2a ist damit fachlich abgenommen und merge-bereit.

**Vor einer öffentlichen Onlinewertung:** Windows-/Web-Pool, Gleichstände, Konten/Identität, Validierungs-/Missbrauchskonzept und Eingabedatenspeicherung klären.

**Vor Veröffentlichung:** Projekt-/Asset-Lizenzen, Name/Branding, Vertriebsweg und gegebenenfalls Hosting klären. P4 bereitet Testartefakte vor, veröffentlicht nicht automatisch.

## Änderungshistorie

- 2026-09-05: Initiale Anforderungen, Godot/Windows-Fokus und P0-Plan dokumentiert.
- 2026-09-05: D-010 bis D-013 präzisieren freie Streckengeometrie, explizite Übergänge, darstellungsunabhängige Schrittlogik und räumliche Identität.
- 2026-09-05: D-014 bis D-018 geben `p1-input-start-v1` frei: Start per erstem Buchstaben, Quick Restart, Escape-Menü, 200-ms-Fehlerfrist, A–Z/Rückwege und Fokusinvalidierung.
- 2026-09-05: P1a nach Review-Nacharbeit abgenommen und gemergt.
- 2026-09-05: P1b implementiert; manuelle Rückmeldung führt zu D-019 bis D-022, Asttrennung, kontinuierlicher Kamera, Besuchsstatus, kürzerem Aufholen und zurückhaltender Grundfarbpalette.
- 2026-09-06: P1b auf Windows vollständig manuell abgenommen und über PR #13 gemergt; physische Chrome-Abnahme transparent verschoben. D-023/D-024 halten die Folgeentscheidung fest: primäre Tile-Beschriftung zur Kamera ausrichten, aktuelle Handstrecke 90° im Uhrzeigersinn drehen und große weiße P1b-Callouts nicht als Enddarstellung übernehmen.
- 2026-09-06: P1c / #4 vorbereitet: Speicher-/Ergebnisvertrag und vorläufige Gleichstands-/Aufbewahrungsparameter konkretisiert, Arbeitsbranch vom aktuellen `main` angelegt. Veraltete P1b-Statusangaben an den nachgewiesenen Abschluss angeglichen; keine neue Implementierung oder Abnahme.
- 2026-09-06: P1c / #4 implementiert: lokale versionierte Ergebnisse mit einmaliger Lauf-ID, vollständiger Identität, Top-100-Aufbewahrung, Top-10-Ergebnisansicht und getrenntem temporärem/fehlerhaftem Speicherstatus. Keine Onlinewertung, Synchronisierung oder neue Bewegungsregel.
- 2026-09-06: P1c nach Review-Nacharbeit abgenommen und über PR #14 gemergt; P2a / #5 ist durch den abgeschlossenen P1c-Merge und den bereits bestandenen realen P1-Windows-Spieltest startbereit. Die verschobene physische P1b-Chrome-Eingabeabnahme bleibt separat offen.
- 2026-09-06: P2a / #5 implementiert zwei Datenverträge je Entscheidung, einen 30-Feld-Referenzkurs, oberflächengebundene 90°-Beschriftungen, vorausschauende Kamera und flüchtige Abschnittsmessung. Review korrigiert QWERTZ-Zuordnung und Messungslebenszyklus.
- 2026-09-06: Menschliche P2a-Abnahme mit allen vier Routenkombinationen bestätigt funktionale Fehlerfreiheit und ausreichende Kamera für den Referenzkurs. D-019/D-022 werden auf Nutzerwunsch präzisiert: Besuchsstatus hat visuell Vorrang vor erneuter Erreichbarkeit; kein kombinierter Status nötig. Die kleine Zeitstichprobe wird ausdrücklich nicht als Ergonomiebeweis interpretiert.
- 2026-09-06: Letzte P2a-Nacharbeit zur Feldstatus-Priorität umgesetzt und durch CI `34027294353` auf `b0270b4` einschließlich Import, Tests sowie Windows-/Web-Export bestätigt. P2a ist merge-bereit.
