# Entscheidungsregister

Stand: 2026-09-05. Quelle der bestätigten Produktentscheidungen ist die Projektabstimmung einschließlich der Präzisierung zu unregelmäßigen Strecken am 2026-09-05. Implementierungsstand: [Roadmap](roadmap.md). Die angelegten Arbeitspakete und ihr experimentelles Startprofil stehen im [Umsetzungsplan](implementation-plan.md).

## Statusdefinitionen

**Bestätigt:** ausdrücklich festgelegte Anforderung. **Vorläufig:** ausdrücklich genannter Testwert oder Gestaltungsvorschlag, noch zu erproben. **Vorgeschlagen:** Empfehlung für die Umsetzung, noch keine bestätigte Produktentscheidung. **Offen:** vor dem jeweiligen Meilenstein zu entscheiden.

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

## Vorläufige Parameter und Rückmeldungen

| ID | Wert/Idee | Einordnung |
| --- | --- | --- |
| T-001 | Fehlerpause zunächst **200 ms** | Vom Nutzer genannter ungefährer Testwert, nicht endgültiges Balancing. Bei Implementierung zentral konfigurieren, nicht mehrfach hart codieren. |
| T-002 | Kleine Kopfschüttelanimation bei einem Fehler | Vom Nutzer vorgeschlagene visuelle Rückmeldung. Sie darf die definierte Sperrdauer nicht verlängern oder spielrelevante Zeichen verdecken. |

## Vorgeschlagene Umsetzung

| ID | Vorschlag | Begründung / Spezifikation |
| --- | --- | --- |
| P-001 | Ein Godot-4-Projekt mit typisiertem GDScript | Gemeinsamer Windows-/Web-Spielkern; aktuelle C#-Web-Grenze berücksichtigen. Siehe [Architektur](architecture.md). |
| P-002 | Windows-Qualitätsprofil mit Forward+, Web-Profil mit Compatibility | Unterschiedliche Darstellung, identische Regeln. Früh durch zwei Exporte prüfen. |
| P-003 | Während der Fehlerpause Eingaben verwerfen, nicht puffern und die Sperre nicht verlängern; Timer läuft weiter | Verhindert nachträgliche automatische Schritte und Strafketten. Keine zusätzliche pauschale Zeitstrafe neben dem Stillstand. Siehe [Spieldesign](game-design.md). |
| P-004 | Erster Spieltest mit A–Z, ohne Groß-/Kleinschreibungsunterscheidung und mit beidseitig begehbaren expliziten Verbindungen | Die frühere Viererraster-Einschränkung entfällt gemäß D-010. Ein übersichtliches Handlayout bleibt möglich; angezeigter Buchstabe statt fest codierter US-Tastenposition. |
| P-005 | Expliziter Start mit Countdown; Zielzeit beim gültigen Zieleingang; Fokusverlust macht gewertete Läufe ungültig | Reproduzierbare Start-/Enderegeln ohne kostenlose Denkpause. Konkrete Countdownlänge noch offen. |
| P-006 | Zunächst lokale Ranglisten je Strecken-/Regelidentität, noch kein Online-Dienst | Spielgefühl vor Infrastruktur; Windows- und Browser-Speicher sind dadurch nicht automatisch synchronisiert. |
| P-007 | Automatische, erhöhte Third-Person-Kamera; lesbare Nachbarn und rechtzeitig sichtbare Verzweigungen | Keine Mausbedienung nötig; Informationsverlust durch Kamera darf nicht zur Hauptschwierigkeit werden. |
| P-008 | Zuerst handgebaute Teststrecken, danach modulbasierte Seed-Generierung | Erst gute Abschnittstypen finden, dann reproduzierbar kombinieren. |
| P-009 | Unabhängige logische Position und aufholende visuelle Bewegung; keine unbeschränkte Animationswarteschlange | Schnelle Eingaben dürfen weder verloren gehen noch lange vorauslaufen. |

Diese Vorschläge können nach ausdrücklicher Bestätigung oder im Rahmen eines entsprechend beauftragten, klar als experimentell ausgewiesenen PoC umgesetzt werden. Sie dürfen nicht stillschweigend als endgültige Entscheidungen umetikettiert werden.

## Offene Entscheidungen und Zeitpunkt

**Vor P1a / Issue #2:** Das im [Umsetzungsplan](implementation-plan.md) konkret vorgeschlagene experimentelle Regelprofil beauftragen oder anpassen. Es umfasst als neue Testvorschläge drei Sekunden Countdown, Enter/Backspace/Escape, Modifier-/UI-Verhalten und Ereignisreihenfolge. Diese Konkretisierung ist noch kein bestätigter Nutzerwunsch. Die Freigabe von D-010 bis D-013 betrifft Streckenmodell, Erreichbarkeit, Bewegung und Identität, nicht pauschal dieses übrige Regelprofil. Sichtbarer Bewegungsrückstand beim Fehler wird in #3 praktisch geprüft.

**Vor P2/P3:** Zielhardware, Auflösung und Leistungsbudget für #6; Kamera-/Routenlesbarkeit sowie Tippbarkeit in #5 erproben. Nur tatsächlich geeignete Bausteine für #7 freigeben. Weitere Tastaturlayouts und endgültige Streckenlängen bleiben offen. Konkrete Größenbereiche, Mindestbreiten lesbarer Randübergänge und Fugentoleranzen sind an den Testabschnitten zu erproben; noch keine pauschalen Zahlenwerte festlegen. Höhenwechsel, Sprung-/Brückenmechaniken und ein beliebiger Polygon-Generator sind dadurch nicht mitbeauftragt.

**Vor einer öffentlichen Onlinewertung:** gemeinsamer oder getrennter Windows-/Web-Pool; Regelung für Zeitgleichstände; Konten/Identität; Validierungs-/Missbrauchskonzept; Speicherung von Eingabedaten. P1c braucht lediglich einen dokumentierten lokalen Gleichstands-/Aufbewahrungsvertrag, keine vorgezogene Onlinearchitektur.

**Vor Veröffentlichung:** Projekt- und Asset-Lizenzen, endgültiger Name/Branding, Vertriebsweg und gegebenenfalls Hosting. P4 bereitet Testartefakte vor, veröffentlicht nicht automatisch.

## Änderungshistorie

- 2026-09-05: Initiale Anforderungen dokumentiert. Fehlerpause ergänzt; 200 ms und Kopfschütteln ausdrücklich als vorläufig eingeordnet. Godot und Windows-Fokus bestätigt. Technische und spielerische Empfehlungen getrennt erfasst. Noch keine Implementierungsabnahme.
- 2026-09-05: Auf Nutzerauftrag neun Umsetzungspakete vorbereitet: bestehendes Issue #1 geschärft, #2–#9 angelegt. Abhängigkeiten, Testvertrag, Modell-/Reasoningempfehlungen und Branchvorgaben dokumentiert. Neue Start-/Steuertastendetails ausschließlich als vorgeschlagenes Experiment erfasst; keine zusätzliche Produktfreigabe und keine Spielimplementierung behauptet.
- 2026-09-05: Auf ausdrückliche Nutzerbestätigung D-010 bis D-013 ergänzt: nicht rastergebundene variable Feldgeometrie, lesbare explizite Übergänge, moderater Größenunterschied ohne Einfluss auf logisches Tempo und räumliche Streckenidentität. P-004 sowie Spezifikation, Tests und offene Pakete angepasst; keine Spielimplementierung und keine pauschale Freigabe anderer P1-Regeln.
