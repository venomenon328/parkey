# P2a: Lesbare Routenentscheidungen und Referenzbausteine

Stand: 2026-09-06. Implementierung zu Issue [#5](https://github.com/venomenon328/parkey/issues/5) auf `codex/p2a-route-decisions`. Verbindlich bleiben D-010 bis D-013 und D-019 bis D-024 aus [Entscheidungen](decisions.md), der P1-Eingabevertrag sowie [testing.md](testing.md). Dieses Paket ist ein Handstrecken- und Erprobungsschritt: Es enthält keinen Generator, keine finale Assetproduktion und keine Ergonomiebehauptung.

## Referenzkurs und Abschnittsvertrag

`scripts/course/handcrafted_course.gd` ist die einzige Quelle des 30-Feld-Referenzkurses. Der Kurs hat zwei Entscheidungen und ein gemeinsames Finale:

| Entscheidung | Kurzer Kandidat | Längerer Kandidat | Zusammenführung |
| --- | --- | --- | --- |
| Alpha | `FJK` (3 Eingaben) | `ASDFGH` (6 Eingaben) | `merge_one` |
| Beta | `PLM` (3 Eingaben) | `QWERT` (5 Eingaben) | `merge_two` |

Die vier Datenverträge enthalten je Abschnitt eine stabile ID, Entscheidungsfeld, Ein-/Ausgangsport, Reihenfolge der Felder, Grundflächenreferenzen, zulässigen Übergangsspalt (`≤ 0,15`) und Kamera-Vorschaufelder. `RouteSectionContract` prüft diese Ports gegen die vorhandenen expliziten Graphkanten und die vorhandenen Übergangssegmente. Er berechnet keine Nachbarn aus Distanz, Rasterposition oder Meshkontakt.

Alle Felder bleiben Rechtecke innerhalb des vorhandenen kleinen Layoutprofils, der Gesamtkurs ist um 18° gedreht. Die Alternativen sind asymmetrisch: Alpha verwendet Tiefen 1,5/1,9 und Breiten 1,45–3,2, Beta Tiefen 1,5/1,7 und ebenfalls unterschiedliche Feldbreiten. Die tatsächlichen Anschlussfugen betragen 0,1, während die repräsentativen parallelen Alternativen mindestens 2,3 Einheiten sichtbar getrennt sind. Eckkontakt oder optische Nähe erzeugen keine Kante; jeder sichtbare Anschluss wird durch eine Transition und eine bidirektionale Graphkante belegt.

Die Daten- und Grafiktrennung bleibt erhalten. Material, Dekoration, Kamera- und Beschriftungsmetadaten zählen nicht zur Streckenidentität; Änderungen von Position, Grundfläche, Anker, Rotation oder Transition schon. Die `routes`-Suite prüft beide Fälle.

## Kamera, Beschriftung und Messung

Die Rückkamera bleibt kontinuierlich geführt. An den beiden Entscheidungsfeldern übernimmt ihr Blickziel den Mittelpunkt der je zwei im Abschnittsvertrag benannten Vorschaufelder, damit beide ersten Routenabschnitte vor der nächsten Wahl vor der Kamera liegen. Die Kamera ändert weder Nachbarschaften noch Zeiten.

Die großen schwebenden P1b-Callouts sind entfernt. Der kontrastreiche Hauptbuchstabe verbleibt auf der Keycap und wird gegenüber dem alten P1b-Bodenbuchstaben um 90° im Uhrzeigersinn gedreht. Die Umsetzung nutzt keine globale Regel für künftige frei gedrehte Tiles: Orientierung und Kameraführung sind Präsentationsdaten und für spätere Bausteine erneut zu prüfen.

`RouteMeasurement` speichert nur im Arbeitsspeicher: gewählte Abschnitts-ID, Abschnittsdauer auf derselben empfangenen monotonen Zeitbasis und Fehlerzahl des Abschnitts. Escape oder Fokusverlust während eines laufenden Versuchs invalidieren und verwerfen dessen Abschnittsmessungen; ein bereits gültig beendeter Lauf behält seine Messungen auch bei anschließendem Escape/Fokusereignis. Quick Restart beginnt wieder mit leerer Messung. Es gibt weder Datei-I/O noch Upload, und die Resultatansicht zeigt ausschließlich die abgeschlossenen Abschnittsproben des zugehörigen gültigen Laufs.

## QWERTZ-Hypothesen und Testbericht

`QwertzTypingHypotheses` bildet alle Gameplay-Buchstaben A–Z auf die physischen Positionen einer deutschen QWERTZ-Tastatur ab und legt Hand, Finger und Reihe transparent offen; insbesondere liegen `Z` oben rechts an der QWERTY-Y-Position und `Y` unten links an der QWERTY-Z-Position. `X` und `C` sind ebenfalls explizit enthalten. Daraus werden nur Eingabeschritte, Finger-/Hand- und Reihenwechsel gezählt. `ASDFGH` und `QWERT` sind als **Hypothesen bekannter Folgen** markiert; `FJK` als kurze Folge mit Handwechseln und `PLM` als kurze Folge mit Reihenwechseln. Diese Beschreibungen sagen nicht voraus, welche Route für eine Person schneller, angenehmer oder ergonomisch besser ist.

Der kontrollierte Test deckt alle vier Kombinationen der beiden Entscheidungen ab. Er misst beispielsweise `alpha_short_fjk` mit einem absichtlich erzeugten Fehler und prüft die Abschnittszeit inklusive der vorhandenen 200-ms-Fehlerpause. Regressionen decken zusätzlich die vollständige A–Z-QWERTZ-Zuordnung sowie den Messungslebenszyklus bei Escape, Fokusverlust und Quick Restart ab. Der Fokuspfad wird dabei auch über eine tatsächlich instanziierte `PlayableCourseScene` geprüft. Damit sind Zeit, Tippfehler und Entscheidungsweg getrennt auswertbar; Entscheidungszeit und Sichtprobleme benötigen weiterhin reale Spielbeobachtungen.

Die Szenenregression misst bei den bestehenden kontrollierten 500/200/125/80-ms-Folgen auf dem neuen variierenden Referenzkurs maximal 2,738 und im Mittel 0,459 Welteinheiten visuellen Restweg, 0,000 s Restaufholen und keine Figurenkorrektur. Die P2a-Grenze `≤ 3,0` berücksichtigt die bewusst breiteren Referenzfelder; sie ist ein Darstellungswert, keine Eingabesperre und keine Aussage über menschliche Latenz.

## Abnahme und offene Gates

Automatisierte Nachweise prüfen Graph, Layout, Ports, Anschlüsse, alle vier Routen, Identität, Kamera-Vorschau, Oberflächenbeschriftung, vollständige A–Z-QWERTZ-Beschreibungen sowie die in-memory Messung einschließlich ihres Zustandslebenszyklus. Review-Nacharbeit `de9f8ee` ist durch GitHub-CI `34024281152` mit Import, kompletter `all`-Suite und beiden Release-Exporten erfolgreich verifiziert. Der tatsächliche Windows-Release wurde auf dem vorherigen P2a-Implementierungsstand unter Windows 11 Pro Build 26200 bei 2560 × 1440 sichtbar gestartet und an Bereitschaft sowie erster Entscheidung nach synthetischem `A → Z → K` geprüft. Die gespeicherten, unversionierten Screenshots zeigen die Keycap-Beschriftungen ohne Callouts und beide ersten Alternativen vor der Wahl. Dieser technische Sichtnachweis ersetzt keine menschliche Spielabnahme. Der Web-Release wurde über HTTP bereitgestellt, eine isolierte grafische Browserprüfung war in der Ausführungsumgebung nicht startbar und bleibt offen.

Die erforderliche menschliche P2a-Spielabnahme mit mindestens zwei Tippmethoden, möglichst zwei Personen, ist nicht durch diese Tests ersetzt. Sie bleibt bis zu tatsächlichen Versuchen offen. Dabei sind Route, Zeit, Fehler, Entscheidungszeit und Sichtprobleme getrennt zu protokollieren; erst danach können Abschnitte für P3a empfohlen oder verworfen werden. Die separat verschobene physische P1b-Chrome-Eingabeabnahme bleibt ebenfalls offen.
