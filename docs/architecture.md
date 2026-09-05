# Technische Architektur

Stand: 2026-09-05. P0 liefert die abgenommene Godot-/GDScript-Grundlage, Renderdiagnose, Export-Presets und Eingabenormalisierung. P1a ist über PR #12 abgenommen und nach `main` gemergt: testbarer Spielkern, Streckendaten und Validierung. P1b integriert im Draft-PR #13 den sichtbaren Parcours; die Review-Nacharbeit ist implementiert, Re-Review und physische Abnahme bleiben offen. Speicherung und Generator bleiben unimplementiert. [p1-rule-profile.md](p1-rule-profile.md) und D-014 bis D-018 sind zusätzlich zu D-001 bis D-013 verbindlich; die Integration ist in [p1b-implementation.md](p1b-implementation.md) konkretisiert. Siehe [Entscheidungsregister](decisions.md).

## Ein Projekt, zwei Darstellungsprofile

Ein Godot-4-Projekt mit typisiertem GDScript bildet die gemeinsame Windows-/Web-Basis. Spielkern, Streckendaten und grundsätzlich auch Szenen/Assets werden geteilt. Windows verwendet Forward+, Web Compatibility mit passenden Grafik-/Audioeinstellungen. Material-/Umgebungsvarianten dürfen erforderlich sein, erzeugen aber keine zweite Spielimplementierung.

P0 pinnt den Standardeditor auf **4.7.2.stable.official.ed1daf0bf** und die Export-Templates auf **4.7.2.stable**. Beide Zielprofile wurden mit diesem Stand tatsächlich exportiert und gestartet. Keine stillen Engine-Upgrades über `latest`; Versionswechsel sind nachvollziehbare Änderungen mit erneuter Exportprüfung. Einrichtung: [development.md](development.md).

Bei der bisherigen Quellenprüfung konnte Godot 4 im Web nur Compatibility mit WebGL 2.0 verwenden; Forward+/Mobile und C#-Web-Export standen dort nicht zur Verfügung. Das ist die technische Grundlage der bestehenden GDScript-/Profilwahl. Bei Engine-Upgrades erneut prüfen, nicht als zeitlose Eigenschaft behandeln.

Plattformsettings werden über Feature-Tags/Overrides und eine kleine Profilkonfiguration getrennt. Rendererwechsel können Licht-, Material- und Umgebungsanpassungen benötigen. Zusätzliche Windows-Effekte dürfen keine Voraussetzung für das Erkennen von Wegen sein.

## Gemeinsamer Spielkern ist zunächst kein Server

Das gemeinsame Backend ist zunächst die geteilte lokale Spiellogik. Ein lokaler PoC benötigt keinen Webservice, Login und keine zentrale Datenbank. Ein späterer Ranglistenserver kann dieselbe API für beide Exporte anbieten, bleibt aber außerhalb des unmittelbaren Eingabepfads. Kein Schritt wartet auf Netzwerkbestätigung. Lokale Windows-/Web-Ergebnisse synchronisieren sich nicht automatisch.

## Verantwortlichkeiten

| Bereich | Verantwortung | Darf nicht entscheiden |
| --- | --- | --- |
| `CourseData` / Validator | IDs, Buchstaben, explizite Kanten, Layout, Start/Ziel, Identität; getrennte Graph-/Layoutprüfungen | Animationsdauer und Grafikqualität |
| `RunSession` | Bereitschaft, Start durch Eingabe, logisches Feld, Fehlerfrist, Quick Restart, getrennte Menüanforderung, Fokusinvalidierung, Ziel/Ergebnis | Kameraführung oder Schrittanimationsdauer |
| Eingabeadapter | Ereignisse normalisieren und geordnet mit Zeitwerten übergeben; Spiel-/UI-Kontext und separate Steueraktionen | Zukünftige passende Buchstaben vorab herausfiltern |
| Darstellung | Strecke, Figur, Kamera, HUD, Fehlerfeedback und visuelles Aufholen | Gültigkeit eines Schritts und Zeit des Zieleingangs |
| Ergebnisablage | Gewertete Resultate speichern/laden | Nachträgliche Änderung der bestimmten Zielzeit |
| Generator, später | Reproduzierbare geprüfte `CourseData` | Rendererabhängige Regeln oder dekorative Zufälle als Gameplay-Zufall |

P1a liefert `CourseData`, `CourseValidator`, `CourseIdentity`, `RuleProfile`, `MonotonicClock`, `RunSession` und `RunInputAdapter` als kleine GDScript-`RefCounted`-Klassen. Sie sind ohne gerenderte 3D-Szene testbar; ein separates Service-Framework ist nicht erforderlich. Bewegung ist ein Wechsel zwischen verbundenen Feldern, keine physikalische Kollisionssimulation. Details des absichtlich kleinen Layoutformats, der Toleranzen und der Identitätsserialisierung stehen im [P1-Regelprofil](p1-rule-profile.md).

## Ereignisse und Zeit

Neue Tastendrücke werden einzeln und in Empfangsreihenfolge verarbeitet, nicht auf ein einmaliges Polling je Frame reduziert. `InputEventKey` unterscheidet `pressed`, `echo`, Unicode und physische Position. Der vorhandene Normalizer wertet die erzeugten A–Z-Zeichen aus; Groß-/Kleinschreibung, Echo, Key-up und Shortcut-Modifier werden gemäß P1-Profil behandelt. UI-Texteingaben dürfen nicht zugleich Spieleingaben sein.

**Start ist ein Eingabeübergang, kein Countdown-Zustand:** In Bereitschaft setzt das erste zulässige Bewegungsereignis den Startzeitpunkt und durchläuft im selben Aufruf die normale Nachbarprüfung. Ein erster Fehler beginnt Zeit und Fehlerfrist gemeinsam. Backspace ist eine separate Quick-Restart-Aktion zurück in Bereitschaft; Enter ist kein notwendiger Start. Escape liefert eine andere Menüanforderung und darf nicht durch denselben Reset-Pfad umgesetzt werden. Der volle Menü-/Fortsetzungsablauf ist nicht Teil von P1a/P1b; der kleine Vertrag aus [p1-rule-profile.md](p1-rule-profile.md) und eine minimale sichtbare P1b-Rückmeldung genügen.

Eine injizierbare monotone Uhr verwendet Integer-Mikrosekunden; der Godot-Adapter kann `Time.get_ticks_usec()` nutzen. Start, Fehler und Ziel nutzen dieselbe Zeitbasis; Tests liefern kontrollierte Zeitwerte. Fehlerfrist beim nächsten Ereignis direkt prüfen, nicht erst an einem Animation-/Physiksignal. Nach Restart sind alte Ereignisse, Sperren und Sitzungsergebnisse getrennt; kein nachträgliches Ausführen alter Eingaben.

P0 nimmt beim Eintritt in `Foundation._unhandled_input` den Zeitwert als `captured_usec`. Das ist der Anwendungsempfang, kein behaupteter OS-/Browserereigniszeitstempel und noch kein Renntimer. P1a stellt den Adapter- und Uhrvertrag für genau diesen Zeitwert bereit; die Verdrahtung in die sichtbare Spielszene erfolgt in P1b. Unterschiedliche Hardware-, OS- und Browserlatenzen bleiben möglich; Regeltests sind kein Nachweis identischer realer Latenz oder garantierter Millisekundengenauigkeit.

Die Menüanforderung darf keinen automatischen Reset auslösen; eine angenommene Menüunterbrechung lässt keine Bewegungen passieren und keine gewertete Fortsetzung zu. Fokusverlust während eines Laufs ist gesondert als Abbruch/Invalidierung zu behandeln. Vor Beginn existiert kein Lauf zu invalidieren; gültige abgeschlossene Ergebnisse bleiben unverändert. Keine fertige Menüoberfläche zur Voraussetzung der Kernimplementierung machen.

## P1b-Integrationsgrenzen

Die echte Spielszene wird zum gemeinsamen Export-Einstieg; P0 bleibt separat als Diagnose startbar. Ein Szenencontroller verbindet Daten/Validator, einen Eingabepfad, Session und Darstellung. Kein zusätzlich aktiver P0-Empfänger, keine doppelte Regelimplementierung und keine automatische Nachbarschaft aus Meshkontakten. `_ready`, GUI-Fokus und der Viewport-Eingabepfad werden in `integration` tatsächlich durchlaufen.

Darstellung und HUD lesen logischen Zustand, Fristen und Ergebnis. Die Sperranzeige darf nicht allein auf dem bis zum nächsten Bewegungsereignis erhaltenen `LOCKED`-Enum beruhen. `last_result` darf nach Restart nicht versehentlich einen neuen Abschlussbildschirm auslösen. Verzögerte Kamera-/Tween-/Fehlerrückmeldungen eines alten Versuchs werden beim Reset ungültig. Die Details stehen ausschließlich in [p1b-implementation.md](p1b-implementation.md).

## Streckenmodell und Reproduzierbarkeit

**Verbindungsgraph, räumliches Layout und kosmetische Darstellung sind verschiedene Verantwortlichkeiten.** `CourseData` verbindet Feld-IDs, Buchstaben, Nachbar-IDs und Start/Ziel mit Layoutdaten. Keine festen Richtungsslots, Manhattan-Nachbarschaft oder allgemeinen Vier-/Sechs-/Acht-Nachbarn-Limits. Das freigegebene P1-Profil verlangt symmetrische Verbindungen.

Layout beschreibt relative Position, Grundfläche/Formparameter, moderate Größe, Ausrichtung und geeigneten Stand-/Landepunkt je Feld sowie erforderliche Übergangsdaten. Für P1 genügen wenige einfache ebene Formen und ein kleines Format; keine beliebigen Polygone, Höhenparcours oder Brücken. Rasterkoordinaten dürfen Bauhilfen eines Profils sein, nie Feldidentität oder allgemeine Quelle der Erreichbarkeit. Zahlenpräzision und kanonische Darstellung festlegen; Quantisierung erzwingt kein regelmäßiges Tile-Raster.

Graphprüfung: eindeutige IDs, Kantenreferenzen, keine Selbst-/Doppelkanten, Symmetrie, Erreichbarkeit, eindeutige Buchstaben jeder Nachbarschaft. Layoutprüfung: gültige Grundflächen/Anker, keine unzulässigen Überlappungen, verständliche Randanschlüsse bzw. kleine Fugen. Das P1-Profil weist außerdem eng gegenüberliegende, gleich ausgerichtete Rechteckseiten mit lesbarer Überlappung und fehlender Graphkante zurück; die genaue kleine Profilgrenze steht im [P1-Regelprofil](p1-rule-profile.md). Eckkontakt allein reicht nicht. Ein logisch gültiger Graph kann räumlich unbrauchbar sein; spielbare Daten bestehen beide Prüfungen. Nachbarschaft vor dem Start fixieren, nicht während der Eingabe aus Mesh-Kontakten oder Distanzschwellen neu berechnen.

`RunSession` verwendet für Schritte nur Kanten und Buchstaben. Identische normalisierte Eingaben/Zeitwerte ergeben bei unterschiedlichen gültigen Layouts derselben Topologie dieselben logischen Schritte und Zeiten, aber gegebenenfalls andere Streckenidentitäten. Grafik folgt Ankern und Übergängen und holt entlang des richtigen Wegs auf. Keine Mindestdauer durch Abstand, Feldgröße, Renderprofil oder Animationsende.

Die Identität bindet bereits bei Handstrecken Topologie, Buchstaben, Regelprofil/-version, relevante Parameter und **räumliche Gestaltung**: relative Positionen, Grundflächen/Formparameter, Größen, Ausrichtungen, Standpunkte, Übergänge. Bei Generierung kommen Seed, Generator-/Layoutversion und Tastatur-/Schwierigkeitsprofil hinzu. Kanonische Serialisierung, Hashschema und Präzision versionieren. Insbesondere darf ein geänderter Start-/Pausevertrag nicht mit älteren Regeln zusammengewertet werden.

Kosmetische Material-/Oberflächendetails und nicht spielrelevante Dekoration bleiben außerhalb. Kanonisches Layout ist die Quelle beider Renderprofile; kein Hash aus aktuellen Meshes, Physikkontakten oder Kamerapositionen. Dekoration darf weder neue Anschlüsse suggerieren noch Pflichtinformationen verdecken. Eine geänderte Grundfläche wird nicht durch das Etikett „kosmetisch“ irrelevant.

Determinismus braucht stabile Iterationsordnung und getrennte kontrollierte Zufallsquellen für Topologie, Layout, Buchstaben und Dekoration. Engine-RNG-Parität über Versionen/Plattformen nicht ungeprüft voraussetzen. Feste Seeds und erwartete Ausgaben dienen später als plattformübergreifende Referenzen; Versionierung schützt alte Wertungen.

## Ablage, Builds und Online-Perspektive

Projektdatei im Root, Szenen in `scenes/`, Code nach Bedarf in `scripts/core/`, `scripts/input/`, `scripts/presentation/`, `scripts/storage/`, Daten/Assets/Tests in entsprechenden Verzeichnissen. Verzeichnisse erst bei Bedarf anlegen. Caches, Builds und Secrets nicht versionieren; notwendige Quellassets, Szenen und UID-Dateien schon.

P0 liefert Smoke-Runner, zwei Export-Presets, Buildanleitung und CI. P1a hat `core`, P1b `integration` ergänzt und wartet im Runner auf die echten Szenentests. Tatsächliche grafische Windows-/HTTP(S)-Web-Starts bleiben eigene Abnahmen; erfolgreiche Headless-Exporte ersetzen sie nicht.

P1c erhält versionierte lokale Ergebnisdaten und klare Fehlerbehandlung beim Laden/Schreiben; Browserpersistenz/Reload getrennt prüfen. Spielbarkeit bleibt unabhängig von späterer Onlinewertung. Die Kernsession übernimmt keine Dateisystem-/Serverzuständigkeit.

Online kann ein Eingabeverlauf gegen Strecke/Regeln plausibilisiert werden; dies beweist keinen menschlichen Ursprung. Anti-Cheat und Plattformvergleich sind spätere Aufgaben.

## Primärquellen

Historische Prüfung der technischen Grundlage: **2026-09-05**. Bewegliche `stable`-Quellen bei Engine-Upgrades erneut gegen die gewählte Version prüfen.

- Windows-Download: https://godotengine.org/download/windows/
- Web-Export: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Renderer: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Plattform-Overrides: https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
- Tastaturereignisse: https://docs.godotengine.org/en/stable/classes/class_inputeventkey.html
- Monotone Zeit: https://docs.godotengine.org/en/stable/classes/class_time.html
