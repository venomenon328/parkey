# Entscheidungsregister

Stand: 2026-09-05. Quelle der bestätigten Produktentscheidungen ist die initiale Projektabstimmung. Der Implementierungsstand wird separat in der [Roadmap](roadmap.md) geführt.

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
| P-004 | Erster Spieltest mit A–Z, ohne Groß-/Kleinschreibungsunterscheidung, maximal vier orthogonalen Nachbarn und beidseitig begehbaren Verbindungen | Kleine, klare Regelmenge. Angezeigter Buchstabe zählt, nicht eine fest codierte US-Tastenposition. |
| P-005 | Expliziter Start mit Countdown; Zielzeit beim gültigen Zieleingang; Fokusverlust macht gewertete Läufe ungültig | Reproduzierbare Start-/Enderegeln ohne kostenlose Denkpause. Konkrete Countdownlänge noch offen. |
| P-006 | Zunächst lokale Ranglisten je Strecken-/Regelidentität, noch kein Online-Dienst | Spielgefühl vor Infrastruktur; Windows- und Browser-Speicher sind dadurch nicht automatisch synchronisiert. |
| P-007 | Automatische, erhöhte Third-Person-Kamera; lesbare Nachbarn und rechtzeitig sichtbare Verzweigungen | Keine Mausbedienung nötig; Informationsverlust durch Kamera darf nicht zur Hauptschwierigkeit werden. |
| P-008 | Zuerst handgebaute Teststrecken, danach modulbasierte Seed-Generierung | Erst gute Abschnittstypen finden, dann reproduzierbar kombinieren. |
| P-009 | Unabhängige logische Position und aufholende visuelle Bewegung; keine unbeschränkte Animationswarteschlange | Schnelle Eingaben dürfen weder verloren gehen noch lange vorauslaufen. |

Diese Vorschläge können nach ausdrücklicher Bestätigung oder im Rahmen eines entsprechend beauftragten, klar als experimentell ausgewiesenen PoC umgesetzt werden. Sie dürfen nicht stillschweigend als endgültige Entscheidungen umetikettiert werden.

## Offene Entscheidungen

**Vor bzw. während P1:** Freigabe der vorgeschlagenen Start-, Eingabe- und Fehlerdetails; konkrete Neustart-/Menütasten ohne Konflikt mit A–Z; Verhalten bei gleichzeitigen Eingaben; Umgang mit sichtbarem Bewegungsrückstand beim Fehler.

**Vor P2/P3:** Zielhardware und Leistungsbudget; endgültige Kameraregeln; gewünschte Streckenlänge; Grenzen des Blicks auf Alternativwege; Modell für Tippbarkeit und Umgang mit weiteren Tastaturlayouts.

**Vor einer öffentlichen Onlinewertung:** gemeinsamer oder getrennter Windows-/Web-Pool; Regelung für Zeitgleichstände; Konten/Identität; Validierungs- und Missbrauchskonzept; Speicherung von Eingabedaten.

**Vor Veröffentlichung:** Projekt- und Asset-Lizenzen, endgültiger Name/Branding, Vertriebsweg und gegebenenfalls Hosting.

## Änderungshistorie

- 2026-09-05: Initiale Anforderungen dokumentiert. Fehlerpause ergänzt; 200 ms und Kopfschütteln ausdrücklich als vorläufig eingeordnet. Godot und Windows-Fokus bestätigt. Technische und spielerische Empfehlungen getrennt erfasst. Noch keine Implementierungsabnahme.
