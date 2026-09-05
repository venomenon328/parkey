# P1b: Reaktionsgefühl, Nahbereich und zurückhaltende Feldzustände

Stand: 2026-09-05. Verbindliche Präzisierung für Issue #3 / Draft-PR #13 nach Nutzerprüfung von `9641675`. Grundlage: [Entscheidungen](decisions.md), [P1-Regeln](p1-rule-profile.md) und [Integration](p1b-implementation.md). **N1–N3 sind implementiert und automatisiert regressionsgeprüft; CI `33987533119` auf dem Implementierungscommit ist erfolgreich, Re-Review und physische/menschliche Abnahme stehen weiterhin aus.** Keine neue Spielmechanik und kein vorgezogenes P2-Grafikpaket.

## 1. Abgrenzung zum vorherigen Review

Die Äste sind jetzt 2,3 Einheiten getrennt; der kleine Validator erkennt die zuvor missverständlichen engen, gleich ausgerichteten Rechteckseiten ohne Verbindung. Figurenabgleich und Kamerainitialisierung sind getrennt; Position und Blickziel werden gemeinsam geführt. Besuchszustände und echter Maus-Rückfokus sind implementiert und regressionsgeprüft. Diese Korrekturen erhalten, nicht erneut grundlegend umbauen.

Die geprüfte CI `33982696600` auf dem PR zu `9641675` führt Smoke/Core/Integration mit zusammen 317 Assertions aus; Import und beide Exporte sind grün. Die separate lokale Integration mit 156 Assertions und OS-synthetische Windows-/Chrome-Läufe sind im PR dokumentiert. Hier wurde keine eigene Godot-/Windows-Spielausführung vorgenommen. Der nur als lokaler Pfad genannte Kameraclip wurde im Review nicht abgespielt.

## 2. Darstellung enger an den Tipprhythmus koppeln

Die Nutzerbeobachtung betraf zu träges Nachlaufen. Der frühere Code setzte in `_append_visual_transition()` bei jedem gültigen Schritt das gesamte verbleibende Figurenbudget auf 350 ms und das Kamerabudget auf 450 ms. Das war nicht nur ein Notfalllimit für Extrembursts: Auch normale Einzelereignisse nutzten diese Zeit, und neue Ereignisse verschoben das Ende erneut.

**Soll:** erste sichtbare Bewegungsreaktion im nächsten tatsächlich gerenderten Bild, deutlich geringerer Rückstand bei getakteten Folgen und kurzer Restlauf nach dem letzten Input. Neue Eingaben dürfen vorhandene Bewegungen beschleunigen oder sinnvoll verdichten, aber deren Erledigung nicht immer wieder auf ein langes Standardbudget verschieben. Figur und Kamerarahmung zusammen abstimmen. Weder eine feste Weltgeschwindigkeit noch eine Wartezeit vor der nächsten Eingabe einführen. Fehlerfrist und Zielzeit bleiben ausschließlich beim Kern.

Die Umsetzung verwendet nun zentral **50 ms** Figuren- und **80 ms** Kamerabudget. Ein gültiger Schritt startet ein Budget nur, wenn keines mehr läuft; während eines aktiven Aufholens werden neue Wegpunkte in dessen verbleibende Frist verdichtet. Damit bleibt sichtbarer Fortschritt erhalten und kein normaler Tastendruck verschiebt das Ende erneut. Die Kamera führt Position und Blickziel weiterhin gemeinsam und wird ebenfalls nicht pro Schritt zurückgesetzt. Diese Zahlen sind vorläufige technische Testparameter, keine neue Eingabe- oder Balancingregel.

**Regression:** echte Szene mit kontrolliertem Ereignis- UND Renderzeitverlauf prüfen. Einzelinput sowie beispielhafte Prüfabstände 500, 200, 125 und 80 ms, Tempowechsel, Richtungswechsel, Stopp und Fehler. Dies sind Testszenarien, keine Behauptungen über menschliche Durchschnittsgeschwindigkeit. Maximalen/typischen Rückstand entlang des gewählten Wegs, Restaufholzeit und Korrekturhäufigkeit messen und die gewählten Grenzen dokumentieren. Bei diesen regulären Prüffolgen keine routinemäßigen Positionssprünge als Ersatz für zeitnahes Folgen. Separate gleichzeitige 50-Ereignis-/Ganzkursbursts prüfen weiterhin vollständige logische Verarbeitung, endlichen Verlauf und Kamera ohne Schnitt; keine Garantie, jedes Zwischenbild eines Nullzeit-Bursts zeigen zu können.

Die echte Integrationsszene misst mit Renderfortschritt in 60-Hz-Schritten für die Prüfabstände 500/200/125/80 ms samt Tempowechsel, Rückweg und Stopp: maximal **2,314** und im Mittel **0,407 Welteinheiten** Restweg; nach dem letzten Input bleiben **0,000 s** Restlauf und keine Figurenkorrektur. Die Grenzen sind `≤ 2,4`, `≤ 0,7` und `≤ 50 ms` Restlauf. Der separate Nullzeit-50-Ereignis-Burst behält seine endliche Wegpunktgrenze und darf als Überlastschutz die Figur abgleichen; er ist kein Normalfall. Kameraposition und -blickziel bleiben auch bei Fehler und Figurenkorrektur kontinuierlich. Keine Abkürzung durch falsche Routen oder nicht begehbare Lücken.

## 3. Mindestlesbarkeit statt endgültigem Kameradesign

Die endgültige Perspektive, perfekte Fernsicht und eine Lösung für jede zukünftige unregelmäßige Strecke sind nicht Gegenstand dieser Nacharbeit. D-021 bleibt eine bevorzugte Rückansicht mit offenen Parametern; die Nutzeräußerung hat keine neue feste Perspektive freigegeben. Eine starre Null-Seitenversatz-Assertion ist kein eigenständiges Produktziel.

**Bereits für den Handkurs erforderlich:** aktueller Buchstabe und alle unmittelbar erreichbaren Zielfeldbuchstaben sind ohne Raten und ohne Blickwechsel in eine unzugeordnete HUD-Liste lesbar. Das gilt vorwärts, seitlich, rückwärts, an Gabel/Merge sowie während der kurzen Nachlaufphase. Die vom Nutzer gemeldete Verdeckung durch den Charakter ist damit ein offener Mindestlesbarkeitspunkt, nicht eine Aufforderung zu einem großen Kamerarewrite.

Die gewählte begrenzte Lösung ergänzt die bodennahe Keycap-Beschriftung um eine kontrastreiche, dem jeweiligen Tile gehörende, zur Kamera ausgerichtete Zusatzbeschriftung auf 2,65 Einheiten Höhe. Sie erscheint nur für aktuelles und direkt erreichbare Tiles, liegt damit klar über der Kopfmitte, bleibt räumlich zugeordnet und verlangt weder seitlichen Kameraversatz noch Mausbedienung. Automatisierte Szenentests prüfen für aktuelles Feld und ersten erreichbaren Nachbarn die tatsächliche Kameravorderseite und die Höhe über dem Figurenpivot; die verbleibende menschliche Lesbarkeitsprüfung erfolgt anhand echter Bilder/Exporte. Keine neue Kamera-Jump-Cuts und keine Aufgabe der freien Tile-Geometrie.

Nach Timingkorrektur und Minimalmaßnahme an den benötigten Zeichen den Handkurs in beiden Exporten bei 1280 × 720 und 960 × 620 prüfen. Weitere Feingestaltung kann danach in P2 bleiben. Soweit technische Sichtbarkeits-/Projektionsregressionen möglich sind, diese ergänzen; die menschliche Lesbarkeitsabnahme nicht durch bloße Node-Existenz ersetzen.

## 4. Status durch Helligkeit, nicht durch neue Farbtöne

D-022 präzisiert jetzt die bisher offene Palette. Farben immer aus der Grundfarbe des jeweiligen Tiles ableiten, auch bei eigenen Start-/Zielfarben. Standard bleibt unverändert; besucht ist dunkler; erreichbar etwas heller als Standard. Keine separate Blau-/Türkis-/Gelbpalette auf Statusflächen oder Rändern.

Bei besucht UND erreichbar hat die helle Erreichbarkeitsdarstellung Vorrang; ein dezentes Häkchen oder anderes nichtfarbliches Signal erhält die Besuchsinformation. Aktuell durch zurückhaltenden Rand/Positionsmarker hervorheben, nicht durch einen zusätzlichen fremden Farbton. Konkrete Faktoren bleiben Testwerte. Keine gegenseitige Neutralisierung von Aufhellen/Abdunkeln und keine Verdeckung des eigentlichen Buchstabens durch Marker.

Die Umsetzung nutzt `Color.darkened(0,28)` für besucht, `Color.lightened(0,18)` für erreichbar und `Color.lightened(0,12)` für den aktuellen Rand. Ein aktiv erreichbarer, bereits besuchter Nachbar erhält die helle Oberflächenvariante und das Zeichen `◇ ✓`; das aktuelle Feld den zurückhaltenden Rand und `● ✓`. Der Materialcache teilt identische abgeleitete `StandardMaterial3D`-Instanzen. Tests prüfen die tatsächlich zugewiesenen Oberflächen- und Randmaterialien für die Standard-, Besuchs-, Nachbar- und Kombinationsfälle sowie für die verschiedene Start-/Zielfeldgrundfarben; Rückweg, Fehler, UI und Quick Restart erhalten die bestehenden Historienregeln. Die Kursidentität ändert sich nicht. Die rein visuelle Palettenanpassung wird nicht rückwirkend als Verstoß gegen eine bereits vor `9641675` festgelegte Farbwahl bewertet.

## 5. Abschluss

Im vorhandenen PR sind N1–N3 nachgearbeitet. Keine Persistenz, Generatoren, finale Assets oder neue Eingaberegeln. Den aktuellen PR-Review, Issue #3 und die Pflichtbefehle aus [testing.md](testing.md) beachten. Die bisherigen 350/450 ms bleiben ausschließlich historische Werte und keine Sollgrenzen.

Vor der vollständigen manuellen Abnahme zuerst kurze Sicht-/Reaktionstests: jeweils ein Schritt mit Pause, getaktete Folge, Burst und Stopp; ein Rückweg; Standard/besucht/erreichbar gleichzeitig im Bild. Danach die unveränderten Funktionsfälle aus der P1b-Anleitung auf demselben korrigierten Commit prüfen. Physische Eingaben, synthetische Läufe, Codeprüfung und CI getrennt nachweisen. PR bleibt bis zur technischen und menschlichen Abnahme Draft; kein Merge durch diesen Review.
