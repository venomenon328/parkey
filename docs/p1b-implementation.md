# P1b: Integration des ersten spielbaren Parcours

Stand: 2026-09-05. **Umsetzung vorbereitet, noch nicht implementiert oder abgenommen.** Arbeitspaket: Issue #3. Voraussetzung P1a / Issue #2 ist über PR #12 abgenommen und mit `5ddf921fdf3736f9e521b8e37b833139beee636f` nach `main` gemergt. Arbeitsbranch: `codex/p1b-playable-course`.

Diese Datei konkretisiert die Integration des freigegebenen [P1-Regelprofils](p1-rule-profile.md), ohne neue Spielregeln einzuführen. Umfang und Abnahmekriterien stehen in Issue #3, allgemeine Prüfungen in [testing.md](testing.md). Es fehlt keine weitere Start-, Eingabe-, Fehler- oder Geometriefreigabe.

## 1. Ergebnis und Paketgrenze

Eine vollständige kleine Spielschleife aus Bereitschaft, Eingabe, Bewegung/Fehler, Zieleingang und Quick Restart. Ein handgebauter, versionierter Parcours mit etwa 20–40 Feldern, einer Gabelung samt Zusammenführung und mindestens einer überschaubaren unregelmäßigen Stelle. Moderate Größenvariation und ein lesbarer schräger Übergang gehören dazu. Beide Routen erreichen das Ziel; Rückwege bleiben erreichbar und lesbar. Y und Z in erreichbaren Testpassagen vorsehen, damit die reale Tastaturabnahme nicht nur eine Diagnoseoberfläche prüft.

Die neue Spielszene wird regulärer Einstieg beider Exporte. Die vorhandene `scenes/foundation.tscn` bleibt als separat startbare P0-Diagnose erhalten; nicht zusätzlich als zweiter aktiver Eingabeempfänger in den Parcours einbetten. Die bisherige Smoke-Assertion auf die alte Hauptszene gezielt auf den neuen Einstieg aktualisieren, die übrigen P0-Prüfungen erhalten.

Beschriftete Keycaps, eine einfache Figur mit unterscheidbarem Kopf, klare Beleuchtung und automatische erhöhte Kamera genügen. Lesbarkeit und reaktionsfähige Bewegung sind Pflicht; finale Assets und die hochwertige Beispielwelt folgen P2b. Kein Download ungeklärter oder kostenpflichtiger Fremdassets. Nach dem Ziel Zeit und Fehlerzahl anzeigen, aber keine Ergebnisdateien oder Rangliste vorziehen. P1c bleibt ein eigenes Paket.

## 2. Daten bleiben maßgeblich

Die Handstrecke hat genau eine versionierte Datenquelle. `CourseData` und der vorhandene vollständige Graph-/Layoutvalidator werden vor Freigabe des Spiels verwendet. Ungültige Daten führen zu einer verständlichen Fehlermeldung, nicht zu einem teilweise spielbaren Lauf oder stillen Ersatzlayout.

Feldgrundflächen, Buchstaben, Standpunkte und Übergänge werden aus diesen Daten aufgebaut, nicht unabhängig in Szenen nochmals definiert. Den Übergang von relativen `[x, z]`-Werten und `rotation_deg` zu 3D-Koordinaten ausdrücklich testen, insbesondere Drehsinn und gedrehte Randpunkte. Keine Spiegelung, die im symmetrischen Grundfall unbemerkt bleibt. Kanonische Streckendaten werden durch Meshaufbau, Kamerabewegung oder Grafikprofil nicht verändert.

Nachbarschaft entsteht niemals aus Laufzeitkollisionen oder bloßer räumlicher Nähe. Sichtbar begehbare Randanschlüsse dürfen keine unsichtbar verbotenen Wege suggerieren. Ein kleiner eben gestalteter Parcours innerhalb des abgenommenen Layoutprofils reicht; kein Polygonframework, Höhenparcours oder Generator. Notwendige kleine Integrationskorrekturen am Kern sind mit Regressionstests erlaubt, nicht jedoch das Abschwächen seiner Regeln, nur damit eine Szene lädt.

## 3. Ein Eingang für Spieleingaben

Die Spielszene verbindet den vorhandenen `RunInputAdapter` mit genau einer `RunSession`. Jedes reale Key-down wird höchstens einmal weitergegeben. Empfangszeit am Eingang des zuständigen Event-Callbacks erfassen und für Start, Schritt und Fehler unverändert verwenden. Für Tests wird dieselbe Uhr kontrolliert injiziert. Kein Polling je Frame, kein Warten auf Tween, Physiktick oder vollständiges Loslassen aller Tasten.

GUI-Verbrauch, Textfokus, Spielfokus und Menüstatus werden tatsächlich an der Szenengrenze berücksichtigt. `_unhandled_input` ist dafür ein geeigneter Ausgangspunkt, kein zusätzlicher zweiter Pfad neben unkontrolliertem `_input`. Ein im Test ergänztes `LineEdit` muss Buchstaben und Backspace konsumieren können, ohne Start, Bewegung oder Restart auszulösen; dafür wird kein Seed-Eingabemenü als Produktfeature vorgezogen.

Fenster-/Browserfokusverlust muss den Kernvertrag erreichen, nicht nur die sichtbare Animation pausieren. Den realen Web-Fokuspfad interaktiv prüfen. Bei Rückkehr keine alten Tastendrücke nachspielen oder selbsttätig starten. OS-/Browserlatenzen nicht als identisch behaupten.

## 4. Darstellung folgt dem logischen Zustand

Aktuelles Feld und erreichbare Nachbarn werden aus der Session markiert, nicht aus der noch nachlaufenden Figurposition. Eine Umrandung oder ein Positionsmarker ergänzt Farben. Figur, Schatten und HUD dürfen die benötigten Buchstaben nicht verdecken; auch Rückwege und beide Äste sind ohne Mausbedienung erkennbar.

Die Bewegung folgt Standpunkten und Übergängen entlang der tatsächlich gewählten Route. Bei schneller Eingabe Animationen verkürzen oder zusammenführen, ohne über nicht begehbare Lücken oder den falschen Ast abzukürzen. Zeitlicher Rückstand und gespeicherter Darstellungsverlauf erhalten explizite endliche Grenzen. Werte und Aufhol-/Notkorrekturstrategie bei der Implementierung zentral dokumentieren und testen; es sind Darstellungsparameter, keine Schritt-Cooldowns. Nach Ende eines Eingabebursts müssen Figur und Kamera innerhalb der dokumentierten Grenze aufholen, statt alte Einzelschritte unbegrenzt abzuarbeiten.

Beim Fehler wird die Darstellung eindeutig auf das unveränderte logische Feld abgeglichen; anschließend keine alten Vorwärtsbewegungen während der Sperre. Eine kurze Kopfbewegung signalisiert den Fehler, bestimmt aber weder Sperrfrist noch Eingabefreigabe. Auch bei starker vorheriger Eingaberate und einem neuen gültigen Tastendruck exakt am Fristende prüfen.

**Vorhandener Kernvertrag:** `RunSession.State.LOCKED` wird erst bei einem späteren Bewegungsereignis in `RUNNING` überführt. Eine sichtbare Sperranzeige darf deshalb nicht unbegrenzt allein an diesem Enum hängen: Frist und aktuelle monotone Zeit auswerten. Den nächsten Buchstaben nicht vorab wegen eines alten Darstellungszustands verwerfen; die Session entscheidet über seine Gültigkeit.

Quick Restart beendet alte Tweens, Kameraübergänge, Fehlerfeedback und verzögerte Rückmeldungen. Kein Callback des vorherigen Versuchs darf Position, Markierungen oder Ergebnis des neuen Versuchs überschreiben. Gleicher Kurs und gleiche Identität bleiben erhalten.

## 5. HUD und minimale Menüreaktion

Timer dauerhaft sichtbar: `MM:SS.mmm`, in Bereitschaft null, bei Fehlern weiterlaufend, beim logischen Zieleingang eingefroren. Zur Anzeige Mikrosekunden ganzzahlig auf Millisekunden abschneiden; nicht vor dem Zieleingang runden oder den gespeicherten Mikrosekundenwert verändern. Grenzfälle: 59.999.999 µs ergeben `00:59.999`, 60.000.000 µs `01:00.000`. Ergebnis und Fehlerzahl stammen aus dem fertigen Kernresultat, nicht aus der letzten gezeichneten HUD-Zahl.

`last_result` kann im vorhandenen Kern nach Quick Restart das vorherige Resultat weiterhin enthalten. Bereitschaft/Abschluss daher nicht aus einem bloß gefüllten Dictionary ableiten. Die Ansicht des neuen Versuchs zurücksetzen, ohne ein schon erzeugtes Resultat zu entwerten, erneut zu erzeugen oder durch aktuelle Werte zu überschreiben.

Escape erhält für den Testlauf nur eine schlichte sichtbare Menü-/Unterbrechungsrückmeldung. Das ist kein fertiges Pausemenü. Vor Laufbeginn kann sie geschlossen werden und lässt Bereitschaft bestehen; nach Unterbrechung eines gestarteten Laufs bleiben Position und abgebrochener Versuch erhalten, aber es gibt keine gewertete Fortsetzung. Ein Hinweis auf Backspace als neuen Versuch genügt. Nach gültigem Ziel bleibt das Ergebnis erhalten. Erneutes Escape oder eine eindeutig bezeichnete Schließen-Aktion kann die Rückmeldung schließen; nie als impliziten Restart behandeln.

Backspace bleibt als getrennte Quick-Restart-Aktion verfügbar, auch aus der Unterbrechungsansicht; Textfokus hat weiterhin Vorrang. Es gibt keine globale Pause des gesamten SceneTree, die den Eingabe-/Zeitvertrag oder die Bedienbarkeit verhindert. Einstellungsseiten, Konten, Ranglisten und Übungsfortsetzung gehören nicht hierher.

## 6. Automatisierte Integration

Die neue Suite `integration` instanziiert die tatsächliche Spielszene im SceneTree einschließlich `_ready`, UI, Adapter und Darstellung. Mindestens einen vollständigen Lauf über den realen Szenen-/Viewport-Eingabepfad prüfen, nicht alle Tests durch direkte Kernaufrufe ersetzen. Kontrollierte Uhren und expliziter Renderfortschritt machen die Fälle reproduzierbar; Testhilfen dürfen keine unkontrollierten Eingaben im normalen Export erzeugen.

Pflichtfälle sind in Issue #3 aufgeführt. Besonders: beide Routen und Rückweg, falscher Erstbuchstabe, Sperrgrenzen, mindestens 50 schnelle Ereignisse mit verschiedenen Renderfortschritten, UI-Textfokus, Menü/Fokus, Reset während Nachlauf/Fehler, einmaliger Zieleingang, Timerübertrag sowie unveränderte Identität beim Szenenaufbau. Die sichtbare Sperre endet auch ohne weiteren Tastendruck; die Darstellung holt innerhalb ihres dokumentierten Budgets auf.

Der Runner muss auf asynchrone Szeneninitialisierung bzw. ausstehende Tests warten, bevor er Erfolg meldet und beendet. Keine übersprungenen Tests durch vorzeitiges `quit(0)`; neue Suites in `all` aufnehmen. Unbekannte/fehlende/leere Suite sowie Testfehler müssen einen Fehlerstatus liefern. Tests zu gültiger vorhandener Funktion nicht entfernen, um grün zu werden.

## 7. Reale Abnahme und Übergabe

Pflicht sind ein tatsächlich durchgespielter nativer Windows-Export mit Forward+ sowie ein über HTTP gestarteter Web-Export in Desktop-Chrome mit Compatibility. Jeweils Commit, Engine, OS/Browser, Hardware/Auflösung und Ergebnis dokumentieren. Firefox-Gesamtabnahme bleibt P4; mehr Tests sind willkommen, werden aber nicht stillschweigend Voraussetzung dieses Pakets.

Manuell beide Routen, Rückweg, erster korrekter/falscher Buchstabe, Fehlerpause, schneller Eingabeburst, Y/Z, Shift, Echo/Überlappung, Backspace, Escape und Fokusverlust prüfen. Figur, Markierungen, Kopfbewegung und Kamera dürfen weder dauerhaft zurückbleiben noch benötigte Zeichen verdecken. Fenstergrößenwechsel als Lesbarkeits-Sanity-Check ergänzen. Screenshots oder Clips helfen bei der Beurteilung, ersetzen den realen Tastatur-/Spieltest aber nicht.

Die Übergabe enthält eine kurze konkrete Bedien- und Abnahmeanleitung mit tatsächlichem Streckenverlauf, Startbuchstaben und erreichbaren Teststellen sowie den Buildpfaden. Fehlende reale Nutzerprüfung bleibt offen und der PR Draft, auch wenn alle Headless-Tests grün sind. Dieses Paket ist erst nach technischem Review und echter Spielabnahme abgeschlossen.

## Technische Primärquellen

Geprüft am 2026-09-05; bei Umsetzung gegen den gepinnten Editor abgleichen. Keine Engine-Aktualisierung mitbeauftragt.

- Eingabereihenfolge und GUI-Vorrang: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html
- Control-Fokus und Ereignisverbrauch: https://docs.godotengine.org/en/stable/classes/class_control.html
- Viewport-Eingabepfad für Integrationstests: https://docs.godotengine.org/en/stable/classes/class_viewport.html
