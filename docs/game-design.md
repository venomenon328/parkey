# Spieldesign

Stand: 2026-09-05. Verbindlichkeit steht im [Entscheidungsregister](decisions.md). D-001 bis D-013, das für P1 freigegebene Profil D-014 bis D-018 und die Darstellungsentscheidungen D-019/D-020 sind verbindlich. Die vollständigen Start-, Eingabe-, Fehler-, Restart-, Menü- und Fokusregeln stehen in [p1-rule-profile.md](p1-rule-profile.md). Andere Gestaltungsvorschläge bleiben als solche gekennzeichnet. Der P1a-Kern ist abgenommen und gemergt; der sichtbare P1b-Spielablauf ist im Draft implementiert und nach der manuellen Rückmeldung noch nachzuarbeiten. Details: [p1b-implementation.md](p1b-implementation.md).

## Spielkern

Parkey verbindet räumliches Lesen, Routenentscheidung und präzises Tippen. Der Spieler erkennt erreichbare Buchstabenfelder, wählt einen Weg und setzt ihn unmittelbar in Bewegung um. Wiederholungen sollen bessere Linien, flüssigere Eingaben und persönliche Bestzeiten ermöglichen.

Die Bildreferenz aus der Projektabstimmung dient als visuelle Orientierung: plastische Tastenkappen, kleine Figur, warme Materialien und eine übersichtliche 3D-Welt. Sie legt weder Kameraposition, Figur noch Materialien endgültig fest. Die Bilddatei selbst ist nicht Bestandteil des Repositorys.

## Bewegung und Eingabe

P1 verwendet A–Z, normalisierte Großschreibung und beidseitige explizite Verbindungen. Keine festen Richtungsslots, kein allgemeiner Raster- oder Nachbarzahlzwang. Orthogonale und schräg angeordnete Übergänge sind möglich, sofern ihre Erreichbarkeit eindeutig ist. Jeder Bewegungsversuch wird gegen die aktuelle **logische** Position geprüft. Mehrere gültige Eingaben können vor dem nächsten Renderbild mehrere Schritte auslösen. Kein Schritt-Cooldown für korrektes Tippen.

Die sichtbare Figur folgt ohne stetig anwachsenden Rückstand. Sie darf Animationen verkürzen oder zusammenführen, statt jeden alten Einzelschritt vollständig nachzuspielen. Aktives Feld und angezeigte Nachbarschaft bleiben konsistent. Auch unterschiedlich große Felder zählen pro gültigem Übergang genau einen Eingabeschritt. Größe, Entfernung und Winkel erzwingen keine zusätzliche Laufzeit, Eingabe oder Sperre; die Darstellung passt sich entlang des gewählten Wegs dem Tippen an.

Ein gültiger Schritt auf einen subjektiv unerwünschten Weg ist keine strafbare Falscheingabe. Rückwärtsgehen erfolgt per Buchstabe des vorherigen Felds, ohne automatische Rücknahme einer Entscheidung.

Nur neue Key-downs zählen, Echo/Key-up nicht. Überlappende echte Tastendrücke bleiben erlaubt und werden in Empfangsreihenfolge behandelt. Modifier, Shortcuts, Nicht-A–Z-Zeichen und UI-Texteingaben sind keine Bewegungsversuche. Backspace für Quick Restart und Escape für die Menüanforderung sind von normalen Buchstaben und voneinander getrennt.

## Fehlerpause

Im freigegebenen P1-Profil verursacht ein falscher Bewegungsbuchstabe **200 ms** Stillstand am unveränderten Feld. Der Timer läuft weiter; die tatsächliche Pause ist die Strafe, ohne zusätzliche Zeitaddition. Eingaben während der Frist werden verworfen, nicht gepuffert, nicht zusätzlich gezählt und verlängern die Frist nicht. Neue Eingaben ab Fristende werden unabhängig vom Animationsstatus normal geprüft. Dies gilt auch für einen falschen ersten Bewegungsbuchstaben, der zugleich die Zeitmessung startet.

Die in P1b zu erprobende Kopfschüttelrückmeldung muss tatsächlich sichtbar sein und darf die Frist nicht verlängern. Die Figur soll während der Sperre keine alten Vorwärtsanimationen abarbeiten. Der Übergang einer nachlaufenden Darstellung zum tatsächlichen logischen Feld wird gezielt getestet. Ein dafür nötiger Figurenabgleich darf keinen harten Kamerareset auslösen. Quick Restart und Menüanforderung bleiben während der Fehlerpause bedienbar; nicht die gesamte Engine pausieren.

Ob die verworfenen Eingaben unmittelbar vor Sperrende verständlich wirken, wird im Spieltest geprüft. Spätere Änderungen der Dauer oder Pufferung sind explizite versionierte Regeländerungen, keine unbemerkte Komfortkorrektur.

## Start, Quick Restart, Menü und Ergebnis

Der validierte Parcours beginnt auf dem Startfeld in Bereitschaft, Timer null. **Der erste neue Bewegungsbuchstabe startet die Zeit und ist zugleich der erste Bewegungsversuch.** Es gibt keinen Countdown und keinen Enter-Start. Ein falscher erster A–Z-Versuch startet ebenso und wird regulär bestraft. Die Betrachtung der Strecke vor dem ersten Buchstaben ist erlaubt.

**Backspace** ist Quick Restart: derselbe Parcours, Startfeld, Zeit/Fehler/Sperre zurückgesetzt und Bereitschaft für den nächsten neuen Bewegungsbuchstaben. **Escape** ist dagegen die eigenständige Anforderung eines klassischen Pausemenüs und setzt die Figur nicht auf Start zurück. Die vollständige Menüoberfläche ist nicht Bestandteil von P1a/P1b; für P1b genügt eine minimale sichtbare Menü-/Unterbrechungsrückmeldung. Details und Wertungsabgrenzung stehen im [P1-Profil](p1-rule-profile.md). Eine Menüunterbrechung eines begonnenen Laufs ermöglicht keine gewertete Fortsetzung.

Fokusverlust während eines begonnenen Laufs bricht ihn ab und macht ihn nicht wertbar; Rückkehr startet nichts automatisch. Vor dem ersten Buchstaben existiert noch kein laufender Versuch. Ein schon abgeschlossenes gültiges Ergebnis wird durch späteren Fokusverlust, Menüöffnung oder Restart weder gelöscht noch dupliziert.

Zieleingang beendet die Zeit beim gültigen logischen Schritt, nicht bei der Landung. Genau ein Ergebnis; spätere Animationen oder Speicherantworten ändern es nicht. Timeranzeige während des Rennens in Minuten, Sekunden und drei Nachkommastellen. Numerische monotone Zeitwerte statt Framezählung oder Sortierung formatierter Zeichenketten; Anzeigepräzision ist keine garantierte identische Gerätelatenz.

Lokale Ranglisten je Strecken-/Regelidentität sind der geplante erste Speicherausbau in P1c, nicht Teil des P1a-Kerns oder der P1b-Integration. P1b zeigt das aktuelle Ergebnis ohne Persistenz. Gleichstandsdetails werden im Speicherpaket festgelegt; Onlinewertung bleibt separat.

## Kamera und Lesbarkeit

Die für P1b vorgesehene Testkamera ist erhöht, nach unten geneigt und automatisch geführt. Figur und aktuelles Feld bleiben sichtbar; an Kreuzungen werden Optionen rechtzeitig erkennbar. Keine notwendigen Mausbewegungen. Nach D-020 müssen **Position und Blickrichtung kontinuierlich** geführt werden: kein sprunghaft auf das nächste logische Feld gesetztes Blickziel, kein harter Schnitt bei Einzelinput, Richtungswechsel, Fehler oder Aufholkorrektur. Initiale Aufstellung und ausdrücklicher Quick Restart dürfen einen neuen Ausgangspunkt setzen; normale Eingaben sind keine Resets. Konkrete Glättungsparameter bleiben zu erproben, ohne Eingaben oder Kernzeit zu drosseln.

### Feldzustände

Nach D-019 sind Standard, bereits besucht, aktuell und erreichbar visuell unterscheidbar. Der Besuchsstatus bleibt während desselben Versuchs erhalten, auch nach Rückwegen. Ein besuchter Nachbar ist gleichzeitig besucht und erreichbar; diese Informationen dürfen sich nicht gegenseitig ausblenden. Das aktuelle Feld hat eine eindeutige zusätzliche Kennzeichnung.

Für P1b wird der Status aus logischen Schritten geführt. Das besetzte Startfeld gehört bereits dazu; nach Quick Restart ist nur dieser neue Ausgangszustand markiert. Ungültige, während der Sperre verworfene oder in der UI verwendete Eingaben markieren keine neuen Felder. Besuchsstatus ist lokaler Darstellungszustand und verändert weder Graph noch Streckenidentität.

Die genaue Farb-/Material-/Symbolgestaltung ist offen. Schon der PoC braucht aber gut sichtbare Zustandsunterschiede auf bzw. oberhalb der Keycaps und ergänzende nicht ausschließlich farbliche Signale. Eine unter dem Feld verdeckte Auswahlplatte oder ein kaum sichtbares Symbol reicht nicht. Markierungen erläutern die vorhandene Erreichbarkeit, sie legitimieren keine widersprüchliche Streckengeometrie.

Buchstaben müssen auch im Web-Profil ohne teure Effekte lesbar bleiben. Schatten, Figur, Schärfentiefe und Benutzeroberfläche dürfen sie nicht verdecken; nötigenfalls dezente zusätzliche Buchstabenanzeigen. Insbesondere muss auch der aktuelle Buchstabe erkennbar bleiben.

Während des P1b-Laufs genügen Timer und Fehlerfeedback, nach Abschluss Zeit und Fehlerzahl. Eine persönliche Bestzeit und ausführliche Rangliste kommen mit dem separaten Speicherausbau. Pflichtinformationen dürfen nicht allein durch Windows-exklusive Effekte vermittelt werden. Fenstergrößenwechsel darf keine wichtigen Inhalte außerhalb der sichtbaren Fläche ablegen.

## Strecken und Generation

### Feldgeometrie und erkennbare Übergänge

Das endgültige Streckendesign darf unregelmäßig sein: variable Grundformen, Ausrichtungen, Anordnungen, moderate Größenunterschiede und wechselnde Nachbarzahlen statt bloß eines anderen regelmäßigen Rasters. Übermäßig große Felder sind nicht das Ziel. Übersichtliche Passagen und markante Entscheidungspunkte bleiben wichtiger als maximaler Zufall. Eine größere Fläche darf an einem Rand mehrere kleinere Nachbarn haben.

Ein erkennbarer gemeinsamer Randabschnitt kann einen Übergang bilden, auch ohne vollständige Seitenübereinstimmung. Bloße Eckberührung, diagonale Lage in einem gedachten Raster oder optische Nähe allein erzeugen keine Verbindung. Kleine konsistent lesbare Fugen sind möglich. Sichtbar begehbare Anschlüsse und gespeicherte Kanten müssen übereinstimmen; keine unsichtbaren Verbote oder willkürlichen Fernverbindungen. Größere Sprünge, gesonderte Brücken und Höhenparcours sind nicht beschlossen.

Die P1b-Rückmeldung am W-Feld konkretisiert diese Regel: Zwei fast bündig nebeneinander liegende Routen dürfen nicht wie eine zusammenhängende Fläche aussehen, wenn Querbewegungen verboten sind. Entweder passen Graph und lesbare Übergänge dazu, oder die Routen werden eindeutig räumlich getrennt. Ein minimal anderer Fugenabstand, eine Liste im HUD oder die fehlende Nachbarmarkierung allein ist keine ausreichende Trennung.

Nachbarschaften werden beim Erstellen/Validieren festgelegt, nicht im Rennen aus wechselnden Mesh-Kontakten erraten. Alle erreichbaren Nachbarn tragen unterschiedliche Buchstaben; das Alphabet ergibt eine sachliche Grenze, aber keine feste Produktvorgabe von vier, sechs oder acht Nachbarn. Ein Abschnitt darf für die Lesbarkeit weniger Optionen haben.

Geeignete Stand-/Landepunkte liegen innerhalb der Felder; Übergangsverläufe bleiben plausibel. Optisch längere Wege können weniger Felder haben, daher müssen Unterteilung und erste Optionen vor Entscheidungen lesbar sein. Konkrete Größen-/Anschlussgrenzen werden an Beispielen geprüft und nicht hier als endgültige Zahlenwerte vorweggenommen.

### PoC und Generierung

Frühe Handstrecken dürfen einfach sein, ohne den Kern auf ihr Layout zu beschränken. P1a prüft unter anderem fünf eindeutig beschriftete Nachbarn und einen gedrehten größeren Knoten mit zwei kleineren Nachbarn; P1b enthält mindestens eine überschaubare unregelmäßige Stelle mit moderat verschiedenen Größen und einem nicht rechtwinkligen lesbaren Übergang. Wenige einfache Formen genügen, kein beliebiger Polygon-Generator.

Bewusst entworfene Abschnitte werden zuerst geprüft: flüssiger Korridor, einsehbare Gabelung, kurze schwierige gegen längere flüssige Route, gemeinsames Finale. Alternativen führen zunächst überwiegend wieder zusammen. Sackgassen, Schleifen, Sprünge und Sonderfelder sind keine Pflicht des ersten PoC.

Eine Routenwahl benötigt vorher genügend Information über Verlauf und erste Buchstabenfolgen. Tippbarkeit hängt von Tastaturlayout, Eingabemethode und Spielerfahrung ab; ein anfängliches QWERTZ-Modell ist eine zu prüfende Hypothese, keine universelle Ergonomiebewertung.

Die Eindeutigkeitsprüfung betrachtet die gesamte Nachbarschaft. Bereits **A–B–A** ist bei beidseitigen Verbindungen vom mittleren B aus ungültig. Gabelungen, Rückwege und Zusammenführungen erfüllen dieselbe Regel. Sichtbare Anordnung und erlaubte Verbindungen bleiben konsistent.

Der spätere Generator kombiniert geprüfte Abschnitte und variiert Topologie, räumliche Anordnung und Beschriftung kontrolliert. Er prüft Erreichbarkeit, Eindeutigkeit, Anschlüsse und brauchbare Alternativen. Die beste Route darf vom Können abhängen.

### Streckenidentität

Räumliche Gestaltung beeinflusst Lesen und Routenwahl und ist keine pauschale Kosmetik. Bei gleichen Buchstaben/Verbindungen, aber anderen relevanten relativen Positionen, Grundflächen, Größen, Ausrichtungen oder Übergängen ändert sich die Streckenidentität. Reine Materialwechsel, Oberflächendetails und nicht spielrelevante Dekoration ändern sie nicht. Dies gilt bereits für Handstrecken; eine andere Identität ist kein Anlass für eine andere Eingabe- oder Zeitregel. Dynamische Besuchs-/Nachbarmarkierungen ändern die zugrunde liegenden Streckendaten nicht.

## Bewusst später

Bestzeit-Ghost, geteilte Seeds, Tagesparcours und Abschnittstraining bleiben Erweiterungsideen. Onlinekonten, Echtzeit-Mehrspieler, Inventar, Power-ups, Ausdauer und Geschwindigkeitsboni gehören nicht zum ersten PoC. Eine fertige Pausemenü-/Übungsfortsetzungsoberfläche ist kein versteckter Pflichtumfang von P1a/P1b.
