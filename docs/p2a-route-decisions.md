# P2a: Lesbare Routenentscheidungen und Referenzbausteine

Stand: 2026-09-06. Issue [#5](https://github.com/venomenon328/parkey/issues/5) ist abgenommen und über PR #15 nach `main` gemergt (`a12cb8f148e6c90d66c6c198b7d923eee9d5eebc`). Verbindlich bleiben D-010 bis D-013 und D-019 bis D-024 aus [Entscheidungen](decisions.md), der P1-Eingabevertrag sowie [testing.md](testing.md). Dieses Paket ist ein Handstrecken- und Erprobungsschritt: Es enthält keinen Generator, keine finale Assetproduktion und keine Ergonomiebehauptung.

## Referenzkurs und Abschnittsvertrag

`scripts/course/handcrafted_course.gd` ist die einzige Quelle des 30-Feld-Referenzkurses. Der Kurs hat zwei Entscheidungen und ein gemeinsames Finale:

| Entscheidung | Kurzer Kandidat | Längerer Kandidat | Zusammenführung |
| --- | --- | --- | --- |
| Alpha | `FJK` (3 Eingaben) | `ASDFGH` (6 Eingaben) | `merge_one` |
| Beta | `PLM` (3 Eingaben) | `QWERT` (5 Eingaben) | `merge_two` |

Die vier Datenverträge enthalten je Abschnitt eine stabile ID, Entscheidungsfeld, Ein-/Ausgangsport, Reihenfolge der Felder, Grundflächenreferenzen, zulässigen Übergangsspalt (`≤ 0,15`) und Kamera-Vorschaufelder. `RouteSectionContract` prüft diese Ports gegen die vorhandenen expliziten Graphkanten und die vorhandenen Übergangssegmente. Er berechnet keine Nachbarn aus Distanz, Rasterposition oder Meshkontakt.

Alle Felder bleiben Rechtecke innerhalb des vorhandenen kleinen Layoutprofils, der Gesamtkurs ist um 18° gedreht. Die Alternativen sind asymmetrisch: Alpha verwendet Tiefen 1,5/1,9 und Breiten 1,45–3,2, Beta Tiefen 1,5/1,7 und ebenfalls unterschiedliche Feldbreiten. Die tatsächlichen Anschlussfugen betragen 0,1, während die repräsentativen parallelen Alternativen mindestens 2,3 Einheiten sichtbar getrennt sind. Eckkontakt oder optische Nähe erzeugen keine Kante; jeder sichtbare Anschluss wird durch eine Transition und eine bidirektionale Graphkante belegt.

Die Daten- und Grafiktrennung bleibt erhalten. Material, Dekoration, Kamera- und Beschriftungsmetadaten zählen nicht zur Streckenidentität; Änderungen von Position, Grundfläche, Anker, Rotation oder Transition schon. Die `routes`-Suite prüft beide Fälle.

## Kamera, Beschriftung, Feldstatus und Messung

Die Rückkamera bleibt kontinuierlich geführt. An den beiden Entscheidungsfeldern übernimmt ihr Blickziel den Mittelpunkt der je zwei im Abschnittsvertrag benannten Vorschaufelder, damit beide ersten Routenabschnitte vor der nächsten Wahl vor der Kamera liegen. Die Kamera ändert weder Nachbarschaften noch Zeiten.

Die großen schwebenden P1b-Callouts sind entfernt. Der kontrastreiche Hauptbuchstabe verbleibt auf der Keycap und wird gegenüber dem alten P1b-Bodenbuchstaben um 90° im Uhrzeigersinn gedreht. Die Umsetzung nutzt keine globale Regel für künftige frei gedrehte Tiles: Orientierung und Kameraführung sind Präsentationsdaten und für spätere Bausteine erneut zu prüfen.

Die P2a-Nutzerabnahme präzisiert den Feldstatus: Besuchshistorie hat visuell Vorrang vor erneuter Erreichbarkeit. Ein bereits betretenes Feld bleibt dunkel/besucht, auch wenn es wieder ein gültiger Nachbar ist; die helle Erreichbarkeitsoberfläche, ein Erreichbarkeitsrand und ein kombinierter Marker werden dort unterdrückt. Das aktuelle Feld bleibt separat eindeutig markiert. Die logische Nachbarschaft bleibt davon unberührt.

`RouteMeasurement` speichert nur im Arbeitsspeicher: gewählte Abschnitts-ID, Abschnittsdauer auf derselben empfangenen monotonen Zeitbasis und Fehlerzahl des Abschnitts. Escape oder Fokusverlust während eines laufenden Versuchs invalidieren und verwerfen dessen Abschnittsmessungen; ein bereits gültig beendeter Lauf behält seine Messungen auch bei anschließendem Escape/Fokusereignis. Quick Restart beginnt wieder mit leerer Messung. Es gibt weder Datei-I/O noch Upload, und die Resultatansicht zeigt ausschließlich die abgeschlossenen Abschnittsproben des zugehörigen gültigen Laufs.

## QWERTZ-Hypothesen und Testbericht

`QwertzTypingHypotheses` bildet alle Gameplay-Buchstaben A–Z auf die physischen Positionen einer deutschen QWERTZ-Tastatur ab und legt Hand, Finger und Reihe transparent offen; insbesondere liegen `Z` oben rechts an der QWERTY-Y-Position und `Y` unten links an der QWERTY-Z-Position. `X` und `C` sind ebenfalls explizit enthalten. Daraus werden nur Eingabeschritte, Finger-/Hand- und Reihenwechsel gezählt. `ASDFGH` und `QWERT` sind als **Hypothesen bekannter Folgen** markiert; `FJK` als kurze Folge mit Handwechseln und `PLM` als kurze Folge mit Reihenwechseln. Diese Beschreibungen sagen nicht voraus, welche Route für eine Person schneller, angenehmer oder ergonomisch besser ist.

Der kontrollierte Test deckt alle vier Kombinationen der beiden Entscheidungen ab. Er misst beispielsweise `alpha_short_fjk` mit einem absichtlich erzeugten Fehler und prüft die Abschnittszeit inklusive der vorhandenen 200-ms-Fehlerpause. Regressionen decken zusätzlich die vollständige A–Z-QWERTZ-Zuordnung sowie den Messungslebenszyklus bei Escape, Fokusverlust und Quick Restart ab. Der Fokuspfad wird dabei auch über eine tatsächlich instanziierte `PlayableCourseScene` geprüft. Damit sind Zeit, Tippfehler und Entscheidungsweg getrennt auswertbar; Entscheidungszeit und Sichtprobleme benötigen weiterhin reale Spielbeobachtungen.

Die Szenenregression misst bei den bestehenden kontrollierten 500/200/125/80-ms-Folgen auf dem neuen variierenden Referenzkurs maximal 2,738 und im Mittel 0,459 Welteinheiten visuellen Restweg, 0,000 s Restaufholen und keine Figurenkorrektur. Die P2a-Grenze `≤ 3,0` berücksichtigt die bewusst breiteren Referenzfelder; sie ist ein Darstellungswert, keine Eingabesperre und keine Aussage über menschliche Latenz.

## Menschliche P2a-Abnahme

Der Nutzer spielte alle vier Kombinationen vollständig und meldete die Mechanik als funktional fehlerfrei. Die aktuelle Kamera ist für diesen Referenzkurs ausreichend; für spätere komplexere, nicht überwiegend gerade Strecken kann eine erneute Kameraanpassung erforderlich werden.

| Alpha | Beta | Gesamtzeit | Fehler |
| --- | --- | ---: | ---: |
| kurz | lang | 7.437.978 µs | 1 |
| kurz | kurz | 5.743.097 µs | 1 |
| lang | kurz | 6.903.868 µs | 0 |
| lang | lang | 8.705.214 µs | 2 |

Diese vier Läufe sind eine sehr kleine, nicht kontrollierte Stichprobe. Sie belegen keine allgemeine Ergonomie- oder Tippbarkeitsaussage. In dieser Stichprobe waren die kurzen Varianten jeweils schneller; daraus folgt insbesondere **keine** Freigabe einer Generatorheuristik „länger = leichter bzw. schneller“. Freigegeben wird der getestete Entscheidungs-/Geometriebaustein, nicht eine universelle Bewertung der Buchstabenfolgen.

Bei der Abnahme wurde zusätzlich die visuelle Priorität von „besucht“ gegenüber „erreichbar“ festgelegt und als letzte P2a-Nacharbeit umgesetzt. Die zunächst gewünschte zweite Tippmethode bzw. möglichst zweite Person und eine separate grafische Web-Kamerawiederholung wurden vom Nutzer für diese P2a-Abnahme ausdrücklich nicht mehr als erforderlich angesehen. Sie werden deshalb **nicht** als durchgeführt behauptet. Die separat verschobene physische P1b-Chrome-Eingabeabnahme bleibt weiterhin offen und ist kein P2a-Mergeblocker.

## Abnahmestand

Automatisierte Nachweise prüfen Graph, Layout, Ports, Anschlüsse, alle vier Routen, Identität, Kamera-Vorschau, Oberflächenbeschriftung, vollständige A–Z-QWERTZ-Beschreibungen, Feldstatus-Priorität sowie die in-memory Messung einschließlich ihres Zustandslebenszyklus. Review-Nacharbeit `de9f8ee` ist durch GitHub-CI `34024281152` mit Import, kompletter `all`-Suite und beiden Release-Exporten erfolgreich verifiziert. Die letzte Feldstatus-Nacharbeit ist durch GitHub-CI `34027294353` auf `b0270b4` ebenfalls vollständig bestätigt: Import, Tests sowie Windows- und Web-Releaseexport waren erfolgreich. Der tatsächliche Windows-Release wurde auf dem vorherigen P2a-Implementierungsstand unter Windows 11 Pro Build 26200 bei 2560 × 1440 sichtbar gestartet und an Bereitschaft sowie erster Entscheidung nach synthetischem `A → Z → K` geprüft. Die späteren vier menschlichen Vollroutenläufe liefern die eigentliche P2a-Spielabnahme.

P2a ist vollständig abgenommen und über PR #15 nach `main` gemergt (`a12cb8f148e6c90d66c6c198b7d923eee9d5eebc`). Der anschließende `main`-CI-Lauf `34028827332` war erfolgreich. Eine gesonderte physische Chrome-Abnahme aus P1b bleibt unabhängig davon offen.

## Nachfolgender P2b-Slice

[P2b](p2b-visual-slice.md) behält diesen Kurs samt Identität und Statuspriorität bei. Die neueste #6-Entscheidung erlaubt präsentationsseitiges Kamera-/Kompositionstuning unter den bestehenden Lesbarkeitsbedingungen; die Mittelpunkte der Entscheidungsvorschau bleiben erhalten. Die flüchtige Abschnittsmessung erscheint dort nach gültigem Abschluss ausschließlich in der F3-Entwickleransicht; sie bleibt dem jeweiligen Versuch zugeordnet. Die P2a-Hypothesen und historischen menschlichen Zeiten werden dadurch nicht neu bewertet.
