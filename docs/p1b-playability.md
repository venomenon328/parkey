# P1b: Reaktionsgefühl, Nahbereich und zurückhaltende Feldzustände

Stand: 2026-09-06. Verbindliche Präzisierung für Issue #3 / PR #13 nach Nutzerprüfung der P1b-Nacharbeiten. Grundlage: [Entscheidungen](decisions.md), [P1-Regeln](p1-rule-profile.md) und [Integration](p1b-implementation.md). **N1–N3 sind implementiert, automatisiert regressionsgeprüft und auf Windows physisch/manuell abgenommen. P1b ist damit abgenommen und über PR #13 gemergt (`e8e947e4100c8f3e534ae425752ac2c30c7fee7a`).** Die physische Chrome-Nutzerabnahme wird ausdrücklich auf später verschoben und ist für diesen Merge kein Blocker, da Windows die führende Zielplattform ist. Automatisierte Web-Exporte und Chrome-Sanity-Checks bleiben Bestandteil des vorhandenen Nachweises. Keine neue Spielmechanik und kein vorgezogenes P2-Grafikpaket.

## 1. Abgrenzung zum vorherigen Review

Die Äste sind 2,3 Einheiten getrennt; der kleine Validator erkennt die zuvor missverständlichen engen, gleich ausgerichteten Rechteckseiten ohne Verbindung. Figurenabgleich und Kamerainitialisierung sind getrennt; Position und Blickziel werden gemeinsam geführt. Besuchszustände und echter Maus-Rückfokus sind implementiert und regressionsgeprüft. Diese Korrekturen erhalten, nicht erneut grundlegend umbauen.

Die finale CI auf dem PR-Head führt Smoke/Core/Integration mit zusammen 350 Assertions aus; Import und beide Exporte sind grün. Die lokale Integration umfasst 189 Assertions. Synthetische Windows-/Chrome- bzw. CDP-Läufe bleiben technische Nachweise und werden nicht als physische Nutzerabnahme ausgegeben.

Die Nutzerabnahme des Windows-Exports bestätigt auf dem aktuellen P1b-Stand beide Routen, Rückweg, Reaktionsgefühl, kontinuierliche Kamera, Nahbereichslesbarkeit, Feldstatus, Fehlerpause, Y/Z und Shift, Echo/Überlappung, Quick Restart, Escape, Textfeld→Canvas sowie Fokusverlust. Die Web-Hardwareprüfung wird später nachgeholt; daraus folgt keine Behauptung, dass die Browserfassung bereits manuell vollständig abgenommen sei.

## 2. Darstellung enger an den Tipprhythmus koppeln

Die Nutzerbeobachtung betraf zu träges Nachlaufen. Der frühere Code setzte in `_append_visual_transition()` bei jedem gültigen Schritt das gesamte verbleibende Figurenbudget auf 350 ms und das Kamerabudget auf 450 ms. Das war nicht nur ein Notfalllimit für Extrembursts: Auch normale Einzelereignisse nutzten diese Zeit, und neue Ereignisse verschoben das Ende erneut.

**Soll:** erste sichtbare Bewegungsreaktion im nächsten tatsächlich gerenderten Bild, deutlich geringerer Rückstand bei getakteten Folgen und kurzer Restlauf nach dem letzten Input. Neue Eingaben dürfen vorhandene Bewegungen beschleunigen oder sinnvoll verdichten, aber deren Erledigung nicht immer wieder auf ein langes Standardbudget verschieben. Figur und Kamerarahmung zusammen abstimmen. Weder eine feste Weltgeschwindigkeit noch eine Wartezeit vor der nächsten Eingabe einführen. Fehlerfrist und Zielzeit bleiben ausschließlich beim Kern.

Die Umsetzung verwendet zentral **50 ms** Figuren- und **80 ms** Kamerabudget. Ein gültiger Schritt startet ein Budget nur, wenn keines mehr läuft; während eines aktiven Aufholens werden neue Wegpunkte in dessen verbleibende Frist verdichtet. Damit bleibt sichtbarer Fortschritt erhalten und kein normaler Tastendruck verschiebt das Ende erneut. Die Kamera führt Position und Blickziel weiterhin gemeinsam und wird ebenfalls nicht pro Schritt zurückgesetzt. Diese Zahlen sind vorläufige technische Testparameter, keine neue Eingabe- oder Balancingregel.

**Regression:** echte Szene mit kontrolliertem Ereignis- UND Renderzeitverlauf prüfen. Einzelinput sowie beispielhafte Prüfabstände 500, 200, 125 und 80 ms, Tempowechsel, Richtungswechsel, Stopp und Fehler. Dies sind Testszenarien, keine Behauptungen über menschliche Durchschnittsgeschwindigkeit. Maximalen/typischen Rückstand entlang des gewählten Wegs, Restaufholzeit und Korrekturhäufigkeit messen und die gewählten Grenzen dokumentieren. Bei diesen regulären Prüffolgen keine routinemäßigen Positionssprünge als Ersatz für zeitnahes Folgen. Separate gleichzeitige 50-Ereignis-/Ganzkursbursts prüfen weiterhin vollständige logische Verarbeitung, endlichen Verlauf und Kamera ohne Schnitt; keine Garantie, jedes Zwischenbild eines Nullzeit-Bursts zeigen zu können.

Die Integrationsszene misst mit Renderfortschritt in 60-Hz-Schritten für die Prüfabstände 500/200/125/80 ms samt Tempowechsel, Rückweg und Stopp: maximal **2,314** und im Mittel **0,407 Welteinheiten** Restweg; nach dem letzten Input bleiben **0,000 s** Restlauf und keine Figurenkorrektur. Die Grenzen sind `≤ 2,4`, `≤ 0,7` und `≤ 50 ms` Restlauf. Der separate Nullzeit-50-Ereignis-Burst behält seine endliche Wegpunktgrenze und darf als Überlastschutz die Figur abgleichen; er ist kein Normalfall. Kameraposition und -blickziel bleiben auch bei Fehler und Figurenkorrektur kontinuierlich. Keine Abkürzung durch falsche Routen oder nicht begehbare Lücken.

## 3. Mindestlesbarkeit und spätere Beschriftungsrichtung

Die endgültige Perspektive, perfekte Fernsicht und eine Lösung für jede zukünftige unregelmäßige Strecke sind nicht Gegenstand von P1b. D-021 bleibt eine bevorzugte Rückansicht mit offenen Parametern; die Windows-Abnahme bestätigt die grundsätzliche Spielbarkeit, nicht die endgültige Kamerakomposition.

Für den Handkurs musste der aktuelle Buchstabe samt unmittelbar erreichbaren Zielfeldbuchstaben ohne Raten lesbar sein. P1b erreicht dies derzeit durch eine bodennahe Keycap-Beschriftung plus kontrastreiche, dem jeweiligen Tile gehörende, kameragerichtete Zusatzbeschriftung für aktuelles und direkt erreichbare Tiles. Diese Lösung war ausreichend, um die P1b-Spielbarkeit abzunehmen.

**Sie ist jedoch keine gewünschte Enddarstellung.** Die großen weißen schwebenden Zusatzbuchstaben des aktuellen Builds werden vom Nutzer ausdrücklich als in dieser Form inakzeptabel bewertet. Ziel für die nächste Kamera-/Routenlesbarkeitsphase ist, dass die Beschriftung der Tiles selbst die nötige Lesbarkeit trägt und ein zusätzlicher Overlay-/Callout-Layer möglichst entfällt. Falls Zusatzhilfen später dennoch nötig sind, müssen sie deutlich zurückhaltender und visuell in die Welt integriert sein.

Die eigentliche Tile-Beschriftung soll zur primären Kamerarichtung lesbar ausgerichtet werden. **Für den aktuellen Handkurs bedeutet das gegenüber der jetzigen Bodenbeschriftung eine Drehung um 90° im Uhrzeigersinn.** Für spätere unregelmäßig/gedrehte Tiles ist daraus keine starre globale 90°-Regel abzuleiten: Die allgemeine Gestaltungsaufgabe lautet, Beschriftungsorientierung und Kamera so zusammenzuführen, dass das Tile selbst aus der üblichen Spielansicht gut lesbar bleibt, ohne seine Geometrie oder Streckenidentität zu verändern.

Diese Beschriftungs-/Kameraverfeinerung ist Folgearbeit für P2a / Issue #5 und kein rückwirkender P1b-Mergeblocker. Die kontinuierliche Kameraführung aus D-020 sowie die freie Streckengeometrie bleiben dabei unverändert.

## 4. Status durch Helligkeit, nicht durch neue Farbtöne

D-022 präzisierte im historischen P1b-Stand die Palette: Farben wurden aus der Grundfarbe des jeweiligen Tiles abgeleitet; Standard unverändert, besucht dunkler und erreichbar etwas heller als Standard. Keine separate Blau-/Türkis-/Gelbpalette oder vollständiger Farbtonwechsel.

**Historischer P1b-Stand:** Bei besucht UND erreichbar hatte damals die helle Erreichbarkeitsdarstellung Vorrang; ein dezentes Häkchen erhielt die Besuchsinformation. Die Umsetzung verwendete `Color.darkened(0,28)` für besucht, `Color.lightened(0,18)` für erreichbar und `Color.lightened(0,12)` für den aktuellen Rand. Ein aktiv erreichbarer, bereits besuchter Nachbar erhielt die helle Oberflächenvariante und das Zeichen `◇ ✓`; das aktuelle Feld den zurückhaltenden Rand und `● ✓`. Dieser Zustand war Bestandteil der damaligen P1b-Windows-Abnahme.

**P2a-Präzisierung vom 2026-09-06:** Die Nutzerabnahme ersetzt diese Priorität für den aktuellen Produktstand. Besuchte Felder haben visuell Vorrang: Ist ein bereits betretenes Feld erneut erreichbar, bleibt es ausschließlich als besucht dargestellt. Es erhält weder die helle Erreichbarkeitsoberfläche noch einen Erreichbarkeitsrand oder einen kombinierten Marker. Das aktuelle Feld bleibt separat eindeutig markiert. D-019/D-022 im Entscheidungsregister enthalten die aktuelle Regel; dieser Abschnitt bewahrt nur den historischen P1b-Nachweis.

## 5. P1b-Abschluss und verbleibende Folgearbeit

P1b ist technisch re-reviewt, die finale CI ist grün und die physische/manuelle Windows-Abnahme wurde vom Nutzer als erfolgreich bestätigt. Da Windows gemäß D-008 die führende Zielplattform ist, wurde PR #13 ausdrücklich abgenommen und gemergt, obwohl die physische Chrome-Abnahme erst später erfolgt. Das Web-Artefakt bleibt gebaut und automatisiert/synthetisch geprüft; die offene Browser-Hardwareabnahme darf später nicht rückwirkend als bereits bestanden behauptet werden.

Die noch nicht zufriedenstellende endgültige Perspektive, die 90°-Neuausrichtung der primären Tile-Beschriftung und das Zurückbauen/Ersetzen der großen weißen Callouts werden in P2a weitergeführt. Keine Persistenz, Generatoren, finale Assets oder neue Eingaberegeln in P1b nachziehen.
