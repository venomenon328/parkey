# P1b: Reaktionsgefühl, Nahbereich und zurückhaltende Feldzustände

Stand: 2026-09-05. Verbindliche Präzisierung für Issue #3 / Draft-PR #13 nach Nutzerprüfung von `9641675`. Grundlage: [Entscheidungen](decisions.md), [P1-Regeln](p1-rule-profile.md) und [Integration](p1b-implementation.md). **Nacharbeit spezifiziert, noch nicht implementiert oder abgenommen.** Keine neue Spielmechanik und kein vorgezogenes P2-Grafikpaket.

## 1. Abgrenzung zum vorherigen Review

Die Äste sind jetzt 2,3 Einheiten getrennt; der kleine Validator erkennt die zuvor missverständlichen engen, gleich ausgerichteten Rechteckseiten ohne Verbindung. Figurenabgleich und Kamerainitialisierung sind getrennt; Position und Blickziel werden gemeinsam geführt. Besuchszustände und echter Maus-Rückfokus sind implementiert und regressionsgeprüft. Diese Korrekturen erhalten, nicht erneut grundlegend umbauen.

Die geprüfte CI `33982696600` auf dem PR zu `9641675` führt Smoke/Core/Integration mit zusammen 317 Assertions aus; Import und beide Exporte sind grün. Die separate lokale Integration mit 156 Assertions und OS-synthetische Windows-/Chrome-Läufe sind im PR dokumentiert. Hier wurde keine eigene Godot-/Windows-Spielausführung vorgenommen. Der nur als lokaler Pfad genannte Kameraclip wurde im Review nicht abgespielt.

## 2. Darstellung enger an den Tipprhythmus koppeln

Die Nutzerbeobachtung betrifft zu träges Nachlaufen. Der Code setzt in `_append_visual_transition()` bei jedem gültigen Schritt das gesamte verbleibende Figurenbudget auf 350 ms und das Kamerabudget auf 450 ms. Das ist nicht nur ein Notfalllimit für Extrembursts: Auch normale Einzelereignisse nutzen diese Zeit, und neue Ereignisse verschieben das Ende erneut. Die logische Eingabe bleibt zwar unmittelbar, die Darstellung kann ihr aber mehrere Felder hinterherlaufen.

**Soll:** erste sichtbare Bewegungsreaktion im nächsten tatsächlich gerenderten Bild, deutlich geringerer Rückstand bei getakteten Folgen und kurzer Restlauf nach dem letzten Input. Neue Eingaben dürfen vorhandene Bewegungen beschleunigen oder sinnvoll verdichten, aber deren Erledigung nicht immer wieder auf ein langes Standardbudget verschieben. Figur und Kamerarahmung zusammen abstimmen. Weder eine feste Weltgeschwindigkeit noch eine Wartezeit vor der nächsten Eingabe einführen. Fehlerfrist und Zielzeit bleiben ausschließlich beim Kern.

Eine verkürzte, bei Bedarf adaptive Darstellung genügt; kein universelles Animationsframework. Exakte Zahlen zentral als vorläufige technische Parameter festlegen und anhand von Tests/Spielgefühl begründen. Die bisherigen 350/450 ms sind keine zu bewahrenden Produktanforderungen. Ein kleinerer Zahlenwert allein ersetzt nicht die Prüfung unter fortlaufender Eingabe.

**Regression:** echte Szene mit kontrolliertem Ereignis- UND Renderzeitverlauf prüfen. Einzelinput sowie beispielhafte Prüfabstände 500, 200, 125 und 80 ms, Tempowechsel, Richtungswechsel, Stopp und Fehler. Dies sind Testszenarien, keine Behauptungen über menschliche Durchschnittsgeschwindigkeit. Maximalen/typischen Rückstand entlang des gewählten Wegs, Restaufholzeit und Korrekturhäufigkeit messen und die gewählten Grenzen dokumentieren. Bei diesen regulären Prüffolgen keine routinemäßigen Positionssprünge als Ersatz für zeitnahes Folgen. Separate gleichzeitige 50-Ereignis-/Ganzkursbursts prüfen weiterhin vollständige logische Verarbeitung, endlichen Verlauf und Kamera ohne Schnitt; keine Garantie, jedes Zwischenbild eines Nullzeit-Bursts zeigen zu können.

Bestehende Endpunkttests mit einem einzigen Aufruf über 350/450 ms reichen für diesen Nachweis nicht. Kameraposition und -blickziel weiterhin kontinuierlich, auch bei Fehler und Figurenkorrektur. Keine Abkürzung durch falsche Routen oder nicht begehbare Lücken.

## 3. Mindestlesbarkeit statt endgültigem Kameradesign

Die endgültige Perspektive, perfekte Fernsicht und eine Lösung für jede zukünftige unregelmäßige Strecke sind nicht Gegenstand dieser Nacharbeit. D-021 bleibt eine bevorzugte Rückansicht mit offenen Parametern; die Nutzeräußerung hat keine neue feste Perspektive freigegeben. Eine starre Null-Seitenversatz-Assertion ist kein eigenständiges Produktziel.

**Bereits für den Handkurs erforderlich:** aktueller Buchstabe und alle unmittelbar erreichbaren Zielfeldbuchstaben sind ohne Raten und ohne Blickwechsel in eine unzugeordnete HUD-Liste lesbar. Das gilt vorwärts, seitlich, rückwärts, an Gabel/Merge sowie während der kurzen Nachlaufphase. Die vom Nutzer gemeldete Verdeckung durch den Charakter ist damit ein offener Mindestlesbarkeitspunkt, nicht eine Aufforderung zu einem großen Kamerarewrite.

Mögliche begrenzte Lösungen sind eine etwas höhere oder leicht seitlich versetzte Rückkamera, geeignete Figurengröße/Position oder dezente, eindeutig den Tiles zugeordnete Zusatzbeschriftungen. Das sind Umsetzungsvorschläge, keine kumulative Pflichtliste. Keine neue Mauspflicht, keine Kamera-Jump-Cuts und keine Aufgabe der freien Tile-Geometrie. Die gewählte Lösung soll anhand tatsächlicher Bilder nachgewiesen werden; im Sichtvolumen liegende Nodes beweisen noch keine Unverdecktheit.

Nach Timingkorrektur und Minimalmaßnahme an den benötigten Zeichen den Handkurs in beiden Exporten bei 1280 × 720 und 960 × 620 prüfen. Weitere Feingestaltung kann danach in P2 bleiben. Soweit technische Sichtbarkeits-/Projektionsregressionen möglich sind, diese ergänzen; die menschliche Lesbarkeitsabnahme nicht durch bloße Node-Existenz ersetzen.

## 4. Status durch Helligkeit, nicht durch neue Farbtöne

D-022 präzisiert jetzt die bisher offene Palette. Farben immer aus der Grundfarbe des jeweiligen Tiles ableiten, auch bei eigenen Start-/Zielfarben. Standard bleibt unverändert; besucht ist dunkler; erreichbar etwas heller als Standard. Keine separate Blau-/Türkis-/Gelbpalette auf Statusflächen oder Rändern.

Bei besucht UND erreichbar hat die helle Erreichbarkeitsdarstellung Vorrang; ein dezentes Häkchen oder anderes nichtfarbliches Signal erhält die Besuchsinformation. Aktuell durch zurückhaltenden Rand/Positionsmarker hervorheben, nicht durch einen zusätzlichen fremden Farbton. Konkrete Faktoren bleiben Testwerte. Keine gegenseitige Neutralisierung von Aufhellen/Abdunkeln und keine Verdeckung des eigentlichen Buchstabens durch Marker.

Tests prüfen die tatsächlich zugewiesenen Materialfarben und kombinierten Formsignale, nicht nur `field_visual_state()`-Booleans: Helligkeitsreihenfolge, Ableitung aus mindestens zwei verschiedenen Basisfarben, unveränderter Grundfarbcharakter sowie Kombination besucht/erreichbar. Rückweg, Fehler, UI und Quick Restart erhalten die bestehenden Historienregeln; die Kursidentität ändert sich nicht. Die rein visuelle Palettenanpassung wird nicht rückwirkend als Verstoß gegen eine bereits vor `9641675` festgelegte Farbwahl bewertet.

## 5. Abschluss

Im vorhandenen PR nacharbeiten. Keine Persistenz, Generatoren, finale Assets oder neue Eingaberegeln. Den aktuellen PR-Review, Issue #3 und die Pflichtbefehle aus [testing.md](testing.md) beachten. Betroffene Iststand-/Darstellungsabschnitte mit der tatsächlichen Umsetzung konsistent nachführen; die dort genannten bisherigen Aufholwerte bleiben bis zur Codeänderung historische Implementierungswerte, keine Sollgrenzen.

Vor der vollständigen manuellen Abnahme zuerst kurze Sicht-/Reaktionstests: jeweils ein Schritt mit Pause, getaktete Folge, Burst und Stopp; ein Rückweg; Standard/besucht/erreichbar gleichzeitig im Bild. Danach die unveränderten Funktionsfälle aus der P1b-Anleitung auf demselben korrigierten Commit prüfen. Physische Eingaben, synthetische Läufe, Codeprüfung und CI getrennt nachweisen. PR bleibt bis zur technischen und menschlichen Abnahme Draft; kein Merge durch diesen Review.
