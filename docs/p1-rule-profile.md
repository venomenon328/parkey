# Freigegebenes P1-Regelprofil

Stand: 2026-09-05. **Für den PoC freigegeben, noch nicht implementiert.** Profilkennung: `p1-input-start-v1`. Grundlage sind die Nutzerentscheidungen D-014 bis D-018 im [Entscheidungsregister](decisions.md); D-001 bis D-013 bleiben unverändert. Diese Datei ist die maßgebliche Detailspezifikation für P1a und seine Folgepakete. Die früheren Vorschläge eines Enter-Starts, Countdowns und Escape-Abbruchs mit Rücksetzen sind ersetzt.

## 1. Bereitschaft und Start durch den ersten Buchstaben

Eine geladene und erfolgreich validierte Strecke beginnt im Bereitschaftszustand auf dem Startfeld. Die Anzeige steht auf null; noch kein Laufzeitbeginn. Der Spieler darf die sichtbare Strecke ansehen und selbst entscheiden, wann er beginnt. Es gibt weder Start-Countdown noch eine erforderliche Enter-Bestätigung.

Der erste neue, normalisierte A–Z-Key-down im aktiven Spielkontext setzt den Startzeitpunkt auf seinen Empfangszeitwert. **Dasselbe Ereignis wird anschließend sofort als erster Bewegungsversuch verarbeitet**, nicht nur als Startsignal verbraucht. Bei gültigem Nachbarn erfolgt der erste logische Schritt zu diesem Zeitpunkt.

Konkretisierung von „erster Buchstabe“: Gemeint ist der erste zugelassene Bewegungsbuchstabe, nicht erst der erste korrekte Zielfeldbuchstabe. Ein falscher erster Buchstabe startet daher ebenfalls den Timer und löst die reguläre Fehlerpause aus. Vor dem Start gibt es keine kostenlosen falschen A–Z-Versuche. Modifier, Shortcuts, Key-up, Echo und Nicht-A–Z-Zeichen starten dagegen keinen Lauf. In einem Menü/Textfeld, bei fehlendem Fokus oder vor abgeschlossener Streckenvalidierung wird nicht gestartet; dortige Eingaben werden nicht für später gepuffert.

Startzeit und erster Schritt bzw. Fehler verwenden exakt denselben Zeitwert. Ein direkt benachbartes Ziel kann in einem synthetischen Ein-Schritt-Test deshalb regulär eine Laufzeit von null ergeben; keine künstliche Mindestzeit ergänzen. Die gewählte echte Teststrecke ist davon unabhängig zu gestalten.

## 2. Quick Restart ist nicht Menüöffnung

| Aktion | Bedeutung und Vertrag |
| --- | --- |
| **Backspace / Quick Restart** | Aktuellen Versuch verwerfen und dieselbe Strecke in den Bereitschaftszustand zurücksetzen: Startfeld, null Zeit, null Fehler, keine Sperre und keine alten Eingaben. Erst der nächste neue Bewegungsbuchstabe startet den neuen Versuch. Kein Countdown. Bereits abgeschlossene Ergebnisse bleiben erhalten; kein zweiter Abschluss des alten Versuchs. |
| **Escape / Pausemenü** | Eigenständige Menü-/Pause-Anforderung, **kein Quick Restart und kein Rücksetzen auf das Startfeld**. Die aktuelle Position und der bisherige Versuch dürfen nicht durch einen Reset-Handler überschrieben werden. Die Menüoberfläche ist noch nicht Teil von P1a. |

Beide Steuertasten sind keine Bewegungsbuchstaben und verursachen keine Fehlerstrafe. Sie sind auch während einer Fehlerpause bedienbar. Wiederholungsereignisse dürfen keine Restart-/Menükaskade auslösen; Texteingaben in UI-Feldern haben Vorrang, insbesondere Backspace zum Löschen im Textfeld.

P1a benötigt für Escape nur einen eigenen testbaren Menüanforderungsvertrag bzw. ein Signal, nicht bereits ein vollständiges Menü oder eine Fortsetzungsoberfläche. Quick Restart und Menüanforderung dürfen nicht auf dieselbe Reset-Funktion abgebildet werden. Solange eine Menüunterbrechung angenommen ist, gehen keine Bewegungsereignisse in den Lauf. Eine Menüöffnung vor dem ersten Buchstaben startet keinen Timer; nach Rückkehr bleibt der Versuch bereit.

Wertungskonkretisierung: Die bestätigte Regel „keine gewertete Pause mit anschließendem Fortsetzen“ bleibt erhalten. Wird ein bereits gestarteter Lauf über das Pausemenü unterbrochen, ist er nicht mehr ranglistenfähig; Escape löscht ihn dennoch nicht wie Backspace. Ein späteres Fortsetzen zu Übungszwecken kann separat ergänzt werden und darf die Wertbarkeit nicht wiederherstellen. Diese Fortsetzungsfunktion ist kein Lieferumfang von P1a. Ein neuer gewerteter Versuch benötigt Quick Restart. Menüöffnung nach Zieleingang entwertet ein bereits abgeschlossenes gültiges Ergebnis nicht.

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

P1a implementiert und testet Daten-/Validierungsverträge, RunSession, Beginn durch Eingabe, Fehlerfrist, Quick Restart, getrennte Menüanforderung, Fokusinvalidierung und einmaliges Ergebnis. Kein Countdown-Zustand erforderlich. Konkrete Klassennamen und interne Zustände sind technische Entscheidungen, müssen aber die obigen Unterschiede erhalten.

P1b integriert diese Regeln in den spielbaren Parcours. Menügestaltung, umfangreiche Pause-/Fortsetzungslogik, persistente Speicherung und Generator werden nicht vorgezogen. Verbindliche Grenz- und Regressionstests stehen in [docs/testing.md](testing.md) und Issue #2. Die Freigabe des Profils ist kein Nachweis bereits ausgeführter P1-Tests.
