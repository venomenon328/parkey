# P1b: Integration des ersten spielbaren Parcours

Stand: 2026-09-06. **P1b / Issue #3 ist über PR #13 mit `e8e947e4100c8f3e534ae425752ac2c30c7fee7a` abgenommen und gemergt.** N1–N3 sind technisch re-reviewt; finale PR-CI `34001773894` und Merge-CI `34001879727` sind erfolgreich. Physische/manuelle Windows-Abnahme bestanden; physische Chrome-Abnahme nach ausdrücklicher Nutzerentscheidung verschoben. Details: [P1b-Spielbarkeit](p1b-playability.md). Die dokumentierte Kamera-/Beschriftungsfolgearbeit bleibt P2a / #5. P1a / #2 ist seit PR #12 gemergt; damaliger P1b-Arbeitsbranch: `codex/p1b-playable-course`.

Diese Datei konkretisiert die Integration des freigegebenen [P1-Regelprofils](p1-rule-profile.md). D-019 bis D-021 aus dem [Entscheidungsregister](decisions.md) ergänzen Feldstatus, durchgehend flüssige Kameraführung und die bevorzugte perspektivische Rückansicht. Umfang und Abnahmekriterien stehen in Issue #3, allgemeine Prüfungen in [testing.md](testing.md). Es fehlt keine weitere Start-, Eingabe-, Fehler-, Geometrie- oder Darstellungsfreigabe; konkrete finale Gestaltung bleibt offen.

## 1. Ergebnis und Paketgrenze

Eine vollständige kleine Spielschleife aus Bereitschaft, Eingabe, Bewegung/Fehler, Zieleingang und Quick Restart. Ein handgebauter, versionierter Parcours mit etwa 20–40 Feldern, einer Gabelung samt Zusammenführung und mindestens einer überschaubaren unregelmäßigen Stelle. Moderate Größenvariation und ein lesbarer schräger Übergang gehören dazu. Beide Routen erreichen das Ziel; Rückwege bleiben erreichbar und lesbar. Y und Z in erreichbaren Testpassagen vorsehen, damit die reale Tastaturabnahme nicht nur eine Diagnoseoberfläche prüft.

Die neue Spielszene wird regulärer Einstieg beider Exporte. Die vorhandene `scenes/foundation.tscn` bleibt als separat startbare P0-Diagnose erhalten; nicht zusätzlich als zweiter aktiver Eingabeempfänger in den Parcours einbetten. Die bisherige Smoke-Assertion auf die alte Hauptszene gezielt auf den neuen Einstieg aktualisieren, die übrigen P0-Prüfungen erhalten.

Beschriftete Keycaps, eine einfache Figur mit unterscheidbarem Kopf, klare Beleuchtung und eine automatische perspektivische Kamera hinter der Figur gemäß D-021 genügen. Eine moderate Erhöhung für lesbare Felder ist möglich; die bisherige isometrisch wirkende seitliche Draufsicht ist nicht die Zielkomposition. Lesbarkeit und reaktionsfähige Bewegung sind Pflicht; finale Assets und die hochwertige Beispielwelt folgen P2b. Kein Download ungeklärter oder kostenpflichtiger Fremdassets. Nach dem Ziel Zeit und Fehlerzahl anzeigen, aber keine Ergebnisdateien oder Rangliste vorziehen. P1c bleibt ein eigenes Paket.

## 2. Daten bleiben maßgeblich

Die Handstrecke hat genau eine versionierte Datenquelle. `CourseData` und der vorhandene vollständige Graph-/Layoutvalidator werden vor Freigabe des Spiels verwendet. Ungültige Daten führen zu einer verständlichen Fehlermeldung, nicht zu einem teilweise spielbaren Lauf oder stillen Ersatzlayout.

Feldgrundflächen, Buchstaben, Standpunkte und Übergänge werden aus diesen Daten aufgebaut, nicht unabhängig in Szenen nochmals definiert. Den Übergang von relativen `[x, z]`-Werten und `rotation_deg` zu 3D-Koordinaten ausdrücklich testen, insbesondere Drehsinn und gedrehte Randpunkte. Keine Spiegelung, die im symmetrischen Grundfall unbemerkt bleibt. Kanonische Streckendaten werden durch Meshaufbau, Kamerabewegung, Besuchsmarkierungen oder Grafikprofil nicht verändert.

Nachbarschaft entsteht niemals aus Laufzeitkollisionen oder bloßer räumlicher Nähe. Sichtbar begehbare Randanschlüsse dürfen keine unsichtbar verbotenen Wege suggerieren. Ein kleiner eben gestalteter Parcours innerhalb des abgenommenen Layoutprofils reicht; kein Polygonframework, Höhenparcours oder Generator. Notwendige kleine Integrationskorrekturen am Kern sind mit Regressionstests erlaubt, nicht jedoch das Abschwächen seiner Regeln, nur damit eine Szene lädt.

**Review-Konkretisierung zu D-011:** Der Kurs aus `c4142a1` hat zwischen den parallelen Ästen nur 0,2 Einheiten Abstand bei 2,0 Einheiten Feldtiefe; normale Längsübergänge haben 0,1 Einheiten Fuge. Der Nutzer erkennt W–F deshalb als normalen möglichen Schritt, obwohl die Kante fehlt. Diese Anordnung ist nicht als lesbar abgenommen. Entweder passende explizite Querübergänge samt erneuter Graph-/Layout-/Buchstabenprüfung vorsehen oder die Äste eindeutig anders führen/trennen. Nicht nur den Schwellenwert minimal verschieben, die fehlende Kante im HUD erklären oder F isoliert hinzupatchen, während der Rest der Seitenanschlüsse unklar bleibt.

Die Layoutprüfung benötigt neben der Kontrolle vorhandener `transitions` auch negative Fälle für einen geometrisch begehbar erscheinenden Randanschluss ohne passende Graphkante bzw. sichtbare Trennung. Das kleine Profil muss dafür seine Erkennungs-/Trennungsbedingungen dokumentieren; es erzeugt keine zusätzlichen Bewegungsnachbarn zur Laufzeit. Die tatsächliche Lesbarkeit nahezu gleicher Fugen bleibt zusätzlich eine manuelle Abnahme. Relevante Kursänderungen verändern die Identität und gegebenenfalls Teststrecken/Bedienfolgen.

## 3. Ein Eingang für Spieleingaben

Die Spielszene verbindet den vorhandenen `RunInputAdapter` mit genau einer `RunSession`. Jedes reale Key-down wird höchstens einmal weitergegeben. Empfangszeit am Eingang des zuständigen Event-Callbacks erfassen und für Start, Schritt und Fehler unverändert verwenden. Für Tests wird dieselbe Uhr kontrolliert injiziert. Kein Polling je Frame, kein Warten auf Tween, Physiktick oder vollständiges Loslassen aller Tasten.

GUI-Verbrauch, Textfokus, Spielfokus und Menüstatus werden tatsächlich an der Szenengrenze berücksichtigt. `_unhandled_input` ist dafür ein geeigneter Ausgangspunkt, kein zusätzlicher zweiter Tastaturpfad neben unkontrolliertem `_input`. Ein im Test ergänztes `LineEdit` muss Buchstaben und Backspace konsumieren können, ohne Start, Bewegung oder Restart auszulösen; dafür wird kein Seed-Eingabemenü als Produktfeature vorgezogen.

Nach Texteingabe muss ein tatsächlicher Klick in die freie Spielfläche den Textfokus zuverlässig verlassen und wieder Spieleingaben ermöglichen. Der Klick selbst startet oder bewegt nicht. Keine Tests, die den fehlenden Nutzerpfad mit einem direkten `release_focus()`-Aufruf ersetzen. Spiel-/UI-Rückfokussierung und OS-/Browserfokus sind getrennt: Die Rückkehr nach echtem Fokusabbruch macht einen alten Versuch nicht wieder wertbar.

Fenster-/Browserfokusverlust muss den Kernvertrag erreichen, nicht nur die sichtbare Animation pausieren. Den realen Web-Fokuspfad interaktiv prüfen. Bei Rückkehr keine alten Tastendrücke nachspielen oder selbsttätig starten. OS-/Browserlatenzen nicht als identisch behaupten.

## 4. Darstellung folgt dem logischen Zustand

### Feldzustände und sichtbares Feedback

Aktuelles Feld und erreichbare Nachbarn werden aus der Session markiert, nicht aus der noch nachlaufenden Figurposition. Nach D-019 wird zusätzlich die Besuchshistorie je Versuch angezeigt. Ein besuchter Nachbar bleibt zugleich als erreichbar erkennbar; aktueller Standort ist ein zusätzlich eindeutiger Zustand. Das besetzte Startfeld ist besucht, jeder akzeptierte logische Zieleingang ergänzt den Status. Fehler, verworfene Eingaben, UI-Eingaben und ausstehende Animationen verändern ihn nicht. Quick Restart setzt auf den Startzustand zurück, Rückwege löschen vorherige Besuche nicht.

Die endgültige Palette ist offen. P1b benötigt deutliche provisorische Zustandsunterschiede auf bzw. oberhalb der Feldoberfläche und zusätzliche Formsignale. Eine unter der Keycap versteckte Auswahlplatte und kleine alleinstehende Glyphen genügen nicht. Die Markierung darf den Buchstaben nicht verdecken. Figur, Schatten und HUD dürfen nötige Zeichen ebenfalls nicht verbergen; auch Rückwege und beide Äste sind ohne Mausbedienung erkennbar.

### Adaptive Figurenbewegung

Die Bewegung folgt Standpunkten und Übergängen entlang der tatsächlich gewählten Route. Bei schneller Eingabe werden Wege innerhalb eines bereits laufenden kurzen Budgets verdichtet, ohne über nicht begehbare Lücken oder den falschen Ast abzukürzen. Zeitlicher Rückstand und gespeicherter Darstellungsverlauf erhalten explizite endliche Grenzen. Werte und Aufhol-/Notkorrekturstrategie sind zentral dokumentiert und getestet; es sind Darstellungsparameter, keine Schritt-Cooldowns. Nach Ende eines Eingabebursts muss die Darstellung aufholen, statt alte Einzelschritte unbegrenzt abzuarbeiten. Zahlenwerte aus einer noch nicht abgenommenen Implementierung sind kein Grund, Jump-Cuts einzubauen.

Beim Fehler wird die Figur eindeutig auf das unveränderte logische Feld abgeglichen; anschließend keine alten Vorwärtsbewegungen während der Sperre. Eine erkennbare Kopfbewegung signalisiert den Fehler, bestimmt aber weder Sperrfrist noch Eingabefreigabe. Eine gleichmäßig gefärbte Kugel nur um ihren eigenen Mittelpunkt zu drehen ist keine verlässlich erkennbare Kopfschüttelrückmeldung; eine einfache Orientierungsform oder geeignete Pivotbewegung genügt, keine finalen Assets nötig. Auch starke vorherige Eingaberate und einen neuen gültigen Tastendruck exakt am Fristende prüfen.

### Rückansicht und kontinuierliche Kamera

D-021 konkretisiert die bevorzugte Perspektive für diese Nacharbeit: Third Person von hinten, Blick entlang des vorausliegenden Parcours und räumliche Tiefe wie im ursprünglichen Mock. Moderate Höhe/Neigung dürfen Feldoberflächen lesbar machen; keine seitliche, isometrisch wirkende Draufsicht als Standard. Die textliche Beschreibung ist auch ohne die nicht im Repository enthaltene Mock-Bilddatei verbindliche Gestaltungsrichtung. Es genügt nicht, nur einen perspektivischen Projektionsmodus nachzuweisen und dieselbe schräge Bildkomposition beizubehalten.

Höhe, Abstand, Neigung, Sichtfeld sowie Kurven-/Rückwegführung als vorläufige Darstellungsparameter erproben. Ergänzend zur Keycap-Oberfläche trägt jedes Tile für aktuelles und direkt erreichbare Felder eine kontrastreiche, zur Kamera ausgerichtete Zusatzbeschriftung oberhalb der Kopfmitte. Sie ist räumlich dem Tile zugeordnet, statt eine unverbundene HUD-Liste zu bilden. Aktuelles Feld, erreichbare Seiten- und Rücknachbarn sowie beide Optionen an einer Gabelung müssen weiterhin ohne Kamerabedienung erkennbar bleiben. Keine automatische harte Kehrtwende bei einem Rückschritt; D-020 bleibt auch bei Richtungswechseln maßgeblich. Für die Abnahme Rückansicht und Lesbarkeit gemeinsam in Windows und Web prüfen, nicht erst in P2b.

D-020 verlangt flüssige Position **und** Blickrichtung. Nicht nur die Position interpolieren und anschließend per `look_at` auf den bereits gesprungenen logischen Anker ausrichten. Ein neues logisches Ziel verändert das Führungsziel, nicht schlagartig den sichtbaren Kameratransform. Schritte, Fehler, Richtungswechsel und große Eingabebursts erhalten die laufende Kameraführung; Figurenabgleich und Kamerainitialisierung sind getrennte Operationen.

Initiale Aufstellung und ausdrücklicher Quick Restart dürfen einen neuen Ausgangspunkt setzen. Innerhalb desselben Versuchs darf weder ein Fehlerpfad noch ein Pufferüberlauf diese Initialisierung wiederverwenden. Auch ein Testaufruf mit `delta = 0` setzt eine bereits initialisierte Kamera nicht plötzlich auf das neue Ziel. Kontinuität mit kleinen Renderzeitschritten, Transform-/Rotationsverlauf und visuellen Clips prüfen, nicht nur die Endposition nach einem großen Zeitschritt. Die Eingabeverarbeitung und Zielzeit bleiben unabhängig davon.

**Vorhandener Kernvertrag:** `RunSession.State.LOCKED` wird erst bei einem späteren Bewegungsereignis in `RUNNING` überführt. Eine sichtbare Sperranzeige darf deshalb nicht unbegrenzt allein an diesem Enum hängen: Frist und aktuelle monotone Zeit auswerten. Den nächsten Buchstaben nicht vorab wegen eines alten Darstellungszustands verwerfen; die Session entscheidet über seine Gültigkeit.

Quick Restart beendet alte Tweens, Kameraübergänge, Fehlerfeedback und verzögerte Rückmeldungen. Kein Callback des vorherigen Versuchs darf Position, Markierungen, Besuchshistorie oder Ergebnis des neuen Versuchs überschreiben. Gleicher Kurs und gleiche Identität bleiben erhalten.

## 5. HUD und minimale Menüreaktion

Timer dauerhaft sichtbar: `MM:SS.mmm`, in Bereitschaft null, bei Fehlern weiterlaufend, beim logischen Zieleingang eingefroren. Zur Anzeige Mikrosekunden ganzzahlig auf Millisekunden abschneiden; nicht vor dem Zieleingang runden oder den gespeicherten Mikrosekundenwert verändern. Grenzfälle: 59.999.999 µs ergeben `00:59.999`, 60.000.000 µs `01:00.000`. Ergebnis und Fehlerzahl stammen aus dem fertigen Kernresultat, nicht aus der letzten gezeichneten HUD-Zahl.

`last_result` kann im vorhandenen Kern nach Quick Restart das vorherige Resultat weiterhin enthalten. Bereitschaft/Abschluss daher nicht aus einem bloß gefüllten Dictionary ableiten. Die Ansicht des neuen Versuchs zurücksetzen, ohne ein schon erzeugtes Resultat zu entwerten, erneut zu erzeugen oder durch aktuelle Werte zu überschreiben.

Escape erhält für den Testlauf nur eine schlichte sichtbare Menü-/Unterbrechungsrückmeldung. Das ist kein fertiges Pausemenü. Vor Laufbeginn kann sie geschlossen werden und lässt Bereitschaft bestehen; nach Unterbrechung eines gestarteten Laufs bleiben Position und abgebrochener Versuch erhalten, aber es gibt keine gewertete Fortsetzung. Ein Hinweis auf Backspace als neuen Versuch genügt. Nach gültigem Ziel bleibt das Ergebnis erhalten. Erneutes Escape oder eine eindeutig bezeichnete Schließen-Aktion kann die Rückmeldung schließen; nie als impliziten Restart behandeln.

Backspace bleibt als getrennte Quick-Restart-Aktion verfügbar, auch aus der Unterbrechungsansicht; Textfokus hat weiterhin Vorrang. Es gibt keine globale Pause des gesamten SceneTree, die den Eingabe-/Zeitvertrag oder die Bedienbarkeit verhindert. Einstellungsseiten, Konten, Ranglisten und Übungsfortsetzung gehören nicht hierher. Größenanpassung darf Pflichttexte nicht abschneiden oder wichtige Buchstaben mit HUD-Flächen verdecken; optionale Diagnoseangaben sind nachrangig.

## 6. Automatisierte Integration

Die Suite `integration` instanziiert die tatsächliche Spielszene im SceneTree einschließlich `_ready`, UI, Adapter und Darstellung. Mindestens einen vollständigen Lauf über den realen Szenen-/Viewport-Eingabepfad prüfen, nicht alle Tests durch direkte Kernaufrufe ersetzen. Kontrollierte Uhren und expliziter Renderfortschritt machen die Fälle reproduzierbar; Testhilfen dürfen keine unkontrollierten Eingaben im normalen Export erzeugen.

Pflichtfälle aus Issue #3 bleiben bestehen: beide Routen und Rückweg, falscher Erstbuchstabe, Sperrgrenzen, mindestens 50 schnelle Ereignisse mit verschiedenen Renderfortschritten, UI-Textfokus, Menü/Fokus, Reset während Nachlauf/Fehler, einmaliger Zieleingang, Timerübertrag sowie unveränderte Identität beim Szenenaufbau. Die sichtbare Sperre endet auch ohne weiteren Tastendruck; die Darstellung holt innerhalb ihres dokumentierten Budgets auf.

Zusätzliche bzw. geschärfte Regressionen nach Review von `c4142a1`:

- Fehlende explizite Kante an einem im Layoutprofil begehbar erscheinenden Randanschluss sowie repräsentative Nachbar-/Nichtnachbarpaare beider Handkursäste; keine Prüfung nur der schon eingetragenen `transitions`.
- Standard-, Besuchs-, Nachbar- und aktueller Status; Kombination besucht/erreichbar; Rückweg, Fehler, UI und Quick Restart; Marker aus logischem statt visuellem Fortschritt. Keine Mutation der Kursidentität.
- Kameraposition und Orientierung vor/nach Einzelinput, bei kleinen Zeitschritten, Rückweg/Gabelung, Fehler, Burst und Ende des Aufholbudgets. Initialisierung/Quick Restart als ausdrücklich getrennte Fälle. Kein positiver Test, der den störenden Kamerasnap zur Sollvorgabe macht. D-021 zusätzlich durch einen reproduzierbaren Rückansichts-Aufbau und manuelle Bildprüfung belegen, nicht nur durch einen Projektionsmodus-Flag.
- Tatsächlicher Klick ins Textfeld, Text/Backspace, Klick in freie Spielfläche und anschließend ein wirksamer Spielbuchstabe. Den Fokusübergang nicht mit Test-Hilfsaufrufen vortäuschen.
- Sichtbarer, nicht nur mathematisch rotierter Fehlerhinweis und Lesbarkeitsprüfung des HUD bei Fenstergrößenwechsel; die abschließende Wahrnehmbarkeit bleibt manuell zu prüfen.

Der Runner muss auf asynchrone Szeneninitialisierung bzw. ausstehende Tests warten, bevor er Erfolg meldet und beendet. Keine übersprungenen Tests durch vorzeitiges `quit(0)`; neue Suites in `all` aufnehmen. Unbekannte/fehlende/leere Suite sowie Testfehler müssen einen Fehlerstatus liefern. Tests zu gültiger vorhandener Funktion nicht entfernen, um grün zu werden.

## 7. Ursprünglicher Abnahmevertrag und erfolgte Teilverschiebung

Der folgende Vertrag beschreibt die P1b-Prüfungen. Windows und technischer Review sind inzwischen bestanden; die physische Chrome-Prüfung wurde ausdrücklich verschoben. Maßgeblich ist der Abschlussstand oben, nicht die historischen offenen Punkte in Abschnitt 8.

Pflicht sind ein tatsächlich durchgespielter nativer Windows-Export mit Forward+ sowie ein über HTTP gestarteter Web-Export in Desktop-Chrome mit Compatibility. Jeweils Commit, Engine, OS/Browser, Hardware/Auflösung und Ergebnis dokumentieren. Firefox-Gesamtabnahme bleibt P4; mehr Tests sind willkommen, werden aber nicht stillschweigend Voraussetzung dieses Pakets.

Manuell beide Routen, Rückweg, erster korrekter/falscher Buchstabe, Fehlerpause, schneller Eingabeburst, Y/Z, Shift, Echo/Überlappung, Backspace, Escape und Fokusverlust prüfen. Figur, Markierungen, Kopfbewegung und Kamera dürfen weder dauerhaft zurückbleiben noch benötigte Zeichen verdecken. Feldzustände auf der Oberfläche, Seitentrennung und kontinuierliche Kamera mit der bevorzugten Rückansicht nach D-021 sind bereits für diesen PoC Abnahmekriterien, keine auf P2b verschobene Grafikpolitur. Fenstergrößenwechsel ergänzen. Screenshots oder Clips helfen bei der Beurteilung, ersetzen den realen Tastatur-/Spieltest aber nicht.

Die Übergabe enthält eine kurze konkrete Bedien- und Abnahmeanleitung mit tatsächlichem Streckenverlauf, Startbuchstaben und erreichbaren Teststellen sowie den Buildpfaden. Nach Kursänderungen die Folgen unten und in PR/Tests gemeinsam aktualisieren. Fehlende reale Nutzerprüfung bleibt offen und der PR Draft, auch wenn alle Headless-Tests grün sind. Dieses Paket ist erst nach technischem Review und echter Spielabnahme abgeschlossen.

## 8. Historischer Nacharbeitsnachweis vor der finalen Nutzerabnahme

Die folgenden Befunde dokumentieren den technischen Zwischenstand. Damals offene Windows-/Reviewpunkte sind durch die spätere Abnahme oben geschlossen; der synthetische Browsernachweis bleibt vom weiterhin offenen physischen Chrome-Test getrennt.

`scripts/course/handcrafted_course.gd` bleibt die einzige Quelle der 26 Felder, Buchstaben, Kanten, Grundflächen, Anker und Übergänge. Der gesamte ebene Kurs ist um 18° gedreht. Die 2,0 Einheiten tiefen Paralleläste liegen nun bei lokal z = ±2,15 und lassen durchgehend 2,3 Einheiten freie Mitte; die 6,3 Einheiten tiefen Gabelungs-/Zusammenführungsfelder schließen beide Äste explizit an. W–F und repräsentative Paare beider Äste sind damit klar getrennte Nichtnachbarn. Die obere Passage wechselt weiterhin von 2,0 auf 2,6 und 1,4 Einheiten Breite.

Der Validator ergänzt dafür eine bewusst enge P1-Rechteckprüfung: Gleich ausgerichtete Seiten mit mindestens 0,2 Einheiten überlappender Projektion und weniger als 0,4 Einheiten Fuge benötigen eine Graphkante. Das erkennt die alte 0,2-Einheiten-Seitenfuge, erzeugt aber weder Laufzeitnachbarn noch ein allgemeines Polygon-/Sichtbarkeitsmodell. Kurs und repräsentative Nachbar-/Nichtnachbarpaare werden zusätzlich integriert geprüft; endgültige räumliche Lesbarkeit bleibt ein menschliches Kriterium.

Die Bedienfolgen bleiben trotz geänderter räumlicher Streckenidentität:

- obere Route: `AZKQWERTYUIMOPLXN`
- untere Route: `AZKDFGHJCVBMOPLXN`
- Rückwegprobe vom oberen Ast bis Start: `AZKQKZAS`

Der Prüfstand speichert höchstens 18 Wegpunkte. Figur und Kamera verwenden vorläufig 50 bzw. 80 ms Aufholbudget. Ein neu akzeptierter Schritt setzt eine noch laufende Frist nicht wieder auf den Höchstwert, sondern verdichtet seinen Verlauf in die verbleibende Frist; ein Figurenüberlauf gleicht nur die Figur an den logischen Anker an. In der kontrollierten 60-Hz-Regressionsfolge mit 500/200/125/80-ms-Abständen, Tempowechsel, Rückweg und Stopp ergaben sich maximal 2,314 und im Mittel 0,407 Welteinheiten Restweg, 0,000 s Restlauf und keine Figurenkorrektur. Kamera und geglättetes Blickziel folgen gemeinsam innerhalb des Kamerabudgets; Fehler, Richtungswechsel und Burst verwenden keinen Kamerareset. Nur Initialisierung und ausdrücklicher Quick Restart setzen den Ausgangstransform. Die Rückansicht verwendet vorläufig 6,4 Einheiten Abstand, 5,4 Einheiten Höhe, 5,2 Einheiten Vorausblick und 56° Sichtfeld ohne seitlichen isometrischen Versatz.

Aktuell, erreichbar, besucht und besucht+erreichbar werden durch sichtbare Oberflächenfarben, vorstehende Ränder und die zusätzlichen Zeichen `●`, `◇` und `✓` kombiniert. Die Materialfarben stammen jeweils von der Tile-Grundfarbe: besucht `darkened(0,28)`, erreichbar `lightened(0,18)`, aktueller Rand `lightened(0,12)`; besucht+erreichbar bleibt hell und behält `◇ ✓`. Ein Materialcache vermeidet pro Ansicht neue gleichartige Materialien. Die Besuchsspur beginnt bei Start und folgt ausschließlich akzeptierten logischen Schritten. Bodennaher Keycap-Buchstabe und tile-eigene, kameragerichtete Zusatzbeschriftung auf 2,65 Einheiten Höhe für aktuelles/direkt erreichbares Tile vermeiden die frühere Charakterverdeckung. Der Kopf hat einen asymmetrischen farbigen Orientierungshinweis an einem gemeinsamen Schwenkpivot. HUD und Fokustest verwenden responsive Verankerungen; ein echter linker Klick in freie Spielfläche gibt `LineEdit`-Fokus frei, ohne selbst eine Spielaktion auszulösen.

Der lokale Nacharbeitsnachweis umfasst nach N1–N3 189 Integrations- und 350 Gesamtassertions ohne Fehler, erfolgreichen Import und beide Release-Exporte. CI `33987533119` auf `8d18dc0` ist erfolgreich. `build/windows/parkey.exe` startet als natives `Parkey`-Fenster; die neue native Vordergrund-/Eingabeprüfung ist wegen einer fremden Vordergrundanwendung nicht verwertbar und bleibt offen. Der Webexport lief isoliert über HTTP in Chrome mit Compatibility/WebGL-Canvas: CDP-synthetisch `A → Z → K → Q` bei 125 ms sowie Sichtprüfungen bei 1280 × 720 und 960 × 620; Screenshots liegen unversioniert unter `build/evidence/chrome-n1n3-ready-1280x720.png`, `build/evidence/chrome-n1n3-fork-1280x720.png` und `build/evidence/chrome-n1n3-fork-960x620.png`. Diese Browserereignisse und Bilder prüfen Paket, Renderer, Canvas und visuelle Sanity, aber nicht physische Hardwaretastatur, menschliche Wahrnehmbarkeit oder Spielgefühl. P0/P1a werden dadurch nicht rückwirkend als ungeprüft bezeichnet.

## 9. Prüfschritte der manuellen Abnahme

Unter Windows abgeschlossen; für die verschobene physische Chrome-Prüfung weiterhin als Anleitung verwendbar.

Windows-Artefakt: `build/windows/parkey.exe`. Web-Einstieg: `build/web/index.html`, ausschließlich über den dokumentierten lokalen HTTP-Server öffnen. Die korrigierten Builds verwenden, nicht den alten Prüfstand.

1. Ohne Eingabe warten: Timer null, Startfeld aktuell/besucht, tatsächlich erreichbare Nachbarn sichtbar anders als Standard. Die Kamera zeigt die Figur von hinten und den Parcours perspektivisch voraus, keine seitliche isometrisch wirkende Draufsicht. Aktuelles Feld und Rücknachbarn bleiben erkennbar.
2. Beide aktuellen Routen bis zum Ziel spielen. An den parallelen Abschnitten prüfen: Jeder wie ein normaler Randübergang aussehende Schritt ist möglich, andernfalls ist die Trennung räumlich eindeutig. Die Markierung allein erklärt keine unsichtbare Wand.
3. Rückweg nehmen: Vorherige Besuche bleiben erkennbar, besuchte Nachbarn zusätzlich erreichbar. Quick Restart löscht die alte Besuchsspur und stellt Bereitschaft her.
4. Einzelne korrekte Buchstaben mit Pausen, dann schnelle Folgen tippen. Kamera bleibt ohne Schnitt in Position und Blickrichtung; ebenso bei Rückweg, Fehler nach schnellem Tippen und langem Burst. Ein Clip über mehrere Schritte und einen Fehler ist als visueller Nachweis geeignet.
5. Nach Quick Restart einen falschen Erstbuchstaben, innerhalb der Sperre weitere Eingaben und ab Fristende einen korrekten Buchstaben verwenden. Keine nachgespielten Eingaben; gut erkennbares Fehlerfeedback ohne zusätzliche Sperre oder Kamerasnap.
6. Y/Z, Shift, gehaltene und überlappende Tasten sowie Backspace während Bewegung/Fehler prüfen. Escape vor Start öffnen/schließen, während Lauf unterbrechen; keine gewertete Fortsetzung.
7. Mit der Maus ins Testtextfeld klicken, Text und Backspace verwenden, dann in freie Spielfläche klicken und einen regulären Spielschritt ausführen. Keine Konsole/Testhilfe zum Freigeben des Fokus nötig.
8. Tatsächlichen Fenster-/Browserfokus während Lauf/Fehler verlieren. Rückkehr setzt nichts fort; gültige Zielergebnisse bleiben erhalten. Bei 1280 × 720 und einer kleineren sinnvollen Fenstergröße aktuelle/nächste/rückwärtige Buchstaben, Status, Timer und Menütexte auf Verdeckung/Abschneiden prüfen.

Für beide Exporte getrennt Engine, OS/Browser, Hardware/Auflösung, physische Eingaben und Befunde protokollieren. Automatisierte oder synthetische Tastaturereignisse ersetzen den letzten Punkt nicht.

## Technische Primärquellen

Geprüft am 2026-09-05; gegen den gepinnten Editor abgleichen. Keine Engine-Aktualisierung mitbeauftragt.

- Eingabereihenfolge und GUI-Vorrang: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html
- Control-Fokus und Ereignisverbrauch: https://docs.godotengine.org/en/stable/classes/class_control.html
- Viewport-Eingabepfad für Integrationstests: https://docs.godotengine.org/en/stable/classes/class_viewport.html
- Node3D-Ausrichtung mit `look_at`: https://docs.godotengine.org/en/stable/classes/class_node3d.html
