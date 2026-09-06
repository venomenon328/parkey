# Freigegebenes P1-Regelprofil

Stand: 2026-09-06. **Für den PoC freigegeben; P1a über PR #12 und P1b über PR #13 abgenommen und gemergt.** P1b ist auf Windows physisch/manuell abgenommen, die physische Chrome-Abnahme ausdrücklich verschoben. Profilkennung: `p1-input-start-v1`. Grundlage sind D-014 bis D-018 im [Entscheidungsregister](decisions.md); D-001 bis D-013 bleiben unverändert. Diese Datei ist die maßgebliche Regelspezifikation für P1 und seine Folgepakete. P1c ergänzt den [Ergebnis-/Speichervertrag](p1c-local-results.md), ohne Start, Fehler oder Zeitmessung zu ändern. Die früheren Vorschläge eines Enter-Starts, Countdowns und Escape-Abbruchs mit Rücksetzen sind ersetzt.

## 1. Bereitschaft und Start durch den ersten Buchstaben

Eine geladene und erfolgreich validierte Strecke beginnt im Bereitschaftszustand auf dem Startfeld. Die Anzeige steht auf null; noch kein Laufzeitbeginn. Der Spieler darf die sichtbare Strecke ansehen und selbst entscheiden, wann er beginnt. Es gibt weder Start-Countdown noch eine erforderliche Enter-Bestätigung.

Der erste neue, normalisierte A–Z-Key-down im aktiven Spielkontext setzt den Startzeitpunkt auf seinen Empfangszeitwert. **Dasselbe Ereignis wird anschließend sofort als erster Bewegungsversuch verarbeitet**, nicht nur als Startsignal verbraucht. Bei gültigem Nachbarn erfolgt der erste logische Schritt zu diesem Zeitpunkt.

Konkretisierung von „erster Buchstabe“: Gemeint ist der erste zugelassene Bewegungsbuchstabe, nicht erst der erste korrekte Zielfeldbuchstabe. Ein falscher erster Buchstabe startet daher ebenfalls den Timer und löst die reguläre Fehlerpause aus. Vor dem Start gibt es keine kostenlosen falschen A–Z-Versuche. Modifier, Shortcuts, Key-up, Echo und Nicht-A–Z-Zeichen starten dagegen keinen Lauf. In einem Menü/Textfeld, bei fehlendem Fokus oder vor abgeschlossener Streckenvalidierung wird nicht gestartet; dortige Eingaben werden nicht für später gepuffert.

Startzeit und erster Schritt bzw. Fehler verwenden exakt denselben Zeitwert. Ein direkt benachbartes Ziel kann in einem synthetischen Ein-Schritt-Test deshalb regulär eine Laufzeit von null ergeben; keine künstliche Mindestzeit ergänzen. Die gewählte echte Teststrecke ist davon unabhängig zu gestalten.

## 2. Quick Restart ist nicht Menüöffnung

| Aktion | Bedeutung und Vertrag |
| --- | --- |
| **Backspace / Quick Restart** | Aktuellen Versuch verwerfen und dieselbe Strecke in den Bereitschaftszustand zurücksetzen: Startfeld, null Zeit, null Fehler, keine Sperre und keine alten Eingaben. Erst der nächste neue Bewegungsbuchstabe startet den neuen Versuch. Kein Countdown. Bereits abgeschlossene Ergebnisse bleiben erhalten; kein zweiter Abschluss des alten Versuchs. |
| **Escape / Pausemenü** | Eigenständige Menü-/Pause-Anforderung, **kein Quick Restart und kein Rücksetzen auf das Startfeld**. Die aktuelle Position und der bisherige Versuch dürfen nicht durch einen Reset-Handler überschrieben werden. Die Menüoberfläche war nicht Teil von P1a; P1b benötigt nur eine minimale sichtbare Rückmeldung. |

Beide Steuertasten sind keine Bewegungsbuchstaben und verursachen keine Fehlerstrafe. Sie sind auch während einer Fehlerpause bedienbar. Wiederholungsereignisse dürfen keine Restart-/Menükaskade auslösen; Texteingaben in UI-Feldern haben Vorrang, insbesondere Backspace zum Löschen im Textfeld.

P1a liefert für Escape einen eigenen testbaren Menüanforderungsvertrag, nicht bereits ein vollständiges Menü oder eine Fortsetzungsoberfläche. Quick Restart und Menüanforderung dürfen nicht auf dieselbe Reset-Funktion abgebildet werden. Solange eine Menüunterbrechung angenommen ist, gehen keine Bewegungsereignisse in den Lauf. Eine Menüöffnung vor dem ersten Buchstaben startet keinen Timer; nach Rückkehr bleibt der Versuch bereit.

Wertungskonkretisierung: Die bestätigte Regel „keine gewertete Pause mit anschließendem Fortsetzen“ bleibt erhalten. Wird ein bereits gestarteter Lauf über das Pausemenü unterbrochen, ist er nicht mehr ranglistenfähig; Escape löscht ihn dennoch nicht wie Backspace. Ein späteres Fortsetzen zu Übungszwecken kann separat ergänzt werden und darf die Wertbarkeit nicht wiederherstellen. Diese Fortsetzungsfunktion ist kein Lieferumfang von P1a/P1b. Ein neuer gewerteter Versuch benötigt Quick Restart. Menüöffnung nach Zieleingang entwertet ein bereits abgeschlossenes gültiges Ergebnis nicht.

## 3. Fehlerpause

Für dieses Profil gelten **200 ms = 200000 µs**, zentral konfiguriert. Dies ist der freigegebene Anfangswert, keine endgültige Balancinggarantie.

Ein falscher Bewegungsbuchstabe im laufenden Zustand verändert die Position nicht, zählt genau einen Fehler und setzt die Sperrfrist. Der Renntimer läuft weiter. Während der Frist werden weitere Bewegungsversuche verworfen: keine Bewegung, keine Warteschlange, keine weiteren Fehler und keine Verlängerung der Frist. Ab exakt Fristende wird ein neuer Tastendruck wieder normal geprüft. Ein dann falscher Buchstabe kann erneut sperren.

Die reale Pause ist die Strafe; keine zusätzliche Zeitaddition. Eine spätere Kopfschüttelanimation darf weder Sperrbeginn noch Sperrende bestimmen. Eingaben unmittelbar vor Fristende bleiben verworfen und werden nicht nachträglich ausgeführt.

## 4. Eingaben und Nachbarschaft

A–Z, Groß-/Kleinschreibung gleich; das erzeugte Zeichen zählt, nicht seine physische US-Tastenposition. Nur neue Key-down-Ereignisse sind Bewegungsversuche. Echo und Key-up werden ignoriert, echte überlappende Tastendrücke bleiben möglich. Empfangsreihenfolge entscheidet auch bei gleichen Zeitwerten; kein künstliches Warten auf vollständig losgelassene Tasten und kein Schritt-pro-Frame-Limit.

Ctrl-/Alt-/Meta-Kombinationen, reine Modifier, Nicht-A–Z-Zeichen und UI-Texteingaben sind keine Bewegungsversuche. Shift/Caps dürfen die Großschreibung verändern, ohne die Buchstabenbedeutung zu ändern.

Verbindungen sind in diesem PoC beidseitig begehbar. Rückweg per Buchstabe des vorherigen Felds ist erlaubt. Ein gültiger Schritt auf einen subjektiv unerwünschten Weg ist keine strafbare Falscheingabe. Alle erreichbaren Nachbarn tragen eindeutige Buchstaben. Freie Geometrie und variable Nachbarzahlen aus D-010 bis D-013 bleiben verbindlich.

## 5. Fokus, Ende und einmaliges Ergebnis

Fokusverlust während eines gestarteten Laufs bricht diesen ab und macht ihn nicht wertbar; Rückkehr setzt ihn nicht fort und startet keinen neuen Versuch. Backspace bereitet einen neuen Versuch vor. Vor dem ersten Buchstaben existiert noch kein laufender Versuch: kein künstlicher Fehlstart und kein Ergebnis; ohne Fokus sind Eingaben gesperrt, nach Rückkehr kann aus Bereitschaft begonnen werden.

Ein gültiger Zieleingang hält die Zeit beim logischen Schritt fest und erzeugt höchstens ein Ergebnis. Animationsende, Dateischreiben und spätere Eingaben ändern es nicht. Fokusverlust, Menüöffnung oder Quick Restart nach einem bereits gültigen Abschluss entwerten bzw. duplizieren dieses Ergebnis nicht.

Laufzeitbasis sind monotone Integer-Mikrosekunden. Die spätere HUD-Anzeige hat drei Nachkommastellen. Profilkennung und wertungsrelevante Parameter einschließlich Fehlerpause gehören zur Regelidentität; relevante räumliche Layoutdaten zur Streckenidentität. Regeländerungen vermischen keine alten Ranglisten.

## 6. Paketgrenze und Nachweis

P1a implementiert und testet Daten-/Validierungsverträge, RunSession, Beginn durch Eingabe, Fehlerfrist, Quick Restart, getrennte Menüanforderung, Fokusinvalidierung und einmaliges Ergebnis. Kein Countdown-Zustand erforderlich. Der Kern wurde nach Review-Nacharbeit auf `617015d` abgenommen und über PR #12 nach `main` gemergt (`5ddf921fdf3736f9e521b8e37b833139beee636f`).

P1b integriert diese Regeln in den spielbaren Parcours; konkrete Integrationsvorgaben stehen in [p1b-implementation.md](p1b-implementation.md). Vollständige Menügestaltung, umfangreiche Pause-/Fortsetzungslogik, persistente Speicherung und Generator werden nicht vorgezogen. Verbindliche Grenz- und Regressionstests stehen in [testing.md](testing.md) und den jeweiligen Issues. Die Kernabnahme ersetzt nicht den Nachweis der sichtbaren Integration und ihrer echten Spielabnahme.

## 7. Technische Festlegungen der P1a-Implementierung

`CourseData` verwendet `course-data-v1`: stabile Feld-IDs aus ASCII-Buchstaben, Ziffern, `_` und `-`, einen A–Z-Buchstaben je Feld, explizite Nachbar-IDs sowie getrennte `layouts` und `transitions`. Start und Ziel sind vorhandene, verschiedene IDs. Der Graph bleibt frei von Richtungs-Slots und Nachbarzahlgrenzen; P1 verlangt beidseitig eingetragene Kanten.

Das kleine Layoutprofil `p1-layout-v1` beschreibt eine ebene relative `[x, z]`-Koordinate. Unterstützt sind `rectangle` (Mitte, Breite/Tiefe, Drehung und Anker) und `circle` (Mitte, Radius und Anker). Alle Lage-, Größen-, Anker- und Drehwerte liegen auf einem Raster von **0,001** Einheiten. Rechteckseiten liegen zwischen **0,5** und **12,0** Einheiten, Kreisradien zwischen **0,25** und **6,0**; das sind P1-Gültigkeitsgrenzen für moderate Beispiele, kein späteres Weltmaß.

Ein Anker muss höchstens 0,001 Einheiten außerhalb der Grundfläche liegen. Jede logische Kante benötigt genau einen Übergang mit `from`/`to` und je zwei Randpunkten. Die Punkte müssen höchstens 0,01 Einheiten vom Feldrand liegen, die Randabschnitte mindestens 0,2 Einheiten lang sein und die beiden Abschnitte dürfen — auch bei umgekehrter Punktreihenfolge — höchstens 0,15 Einheiten auseinanderliegen. Übergänge ohne Datenkante, doppelte Übergänge, Datenkanten ohne Übergang und Flächenüberlappungen sind ungültig; reiner Eckkontakt erzeugt keine Kante.

Zusätzliche kleine P1-Trennungsprüfung: Gleich ausgerichtete Rechtecke mit mindestens 0,2 Einheiten überlappender Seitenprojektion gelten bei weniger als 0,4 Einheiten freier Seitenfuge als scheinbarer Randanschluss. Ohne explizite beidseitige Graphkante ist dieses Layout ungültig; ab 0,4 Einheiten erzeugt der Validator daraus keine Verbindung. Diese konservative Negativprüfung erfasst den P1-Rechteckfall, ist weder allgemeine Polygon-/Sichtbarkeitsmetrik noch Laufzeit-Nachbarschaft. Manuelle Lesbarkeit bleibt zusätzlich erforderlich.

`course-identity-v1` bildet einen SHA-256 über kanonisch sortierte Graph-, Layout- und Profilwerte. Zahlen werden mit drei Nachkommastellen serialisiert; Übergangsrichtung und Punktreihenfolge werden für die Identität normalisiert. `material`, `surface`, `decoration` und `display_name` sind ausdrücklich kosmetisch und gehen nicht ein. Relevante Lage, Form, Größe, Drehung, Anker, Übergang sowie `p1-input-start-v1` mit Fehlerfrist dagegen schon. Damit bleiben Grafik und Bewegung vom Kern getrennt, Wertungen aber nicht versehentlich vermischt.

`RunSession` akzeptiert nur bereits vollständig validierte Daten. Sie verwendet injizierbare monotone Integer-Mikrosekunden und verarbeitet gleichzeitige Ereignisse in Aufruf-/Empfangsreihenfolge. Der Eingabeadapter nutzt den P0-`KeyInputNormalizer`, behandelt Backspace und Escape getrennt und übergibt UI-, Fokus- und Kontextereignisse nicht als Bewegungsversuche an die Session. Fokusverlust meldet die Szenenintegration separat an den Kern. Die Session speichert keine Dateien; ihr einmaliges Ergebnis ist ein Kernereignis für P1c.
