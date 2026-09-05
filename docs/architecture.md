# Technische Architektur

Stand: 2026-09-05. P0 implementiert die gemeinsame Godot-/GDScript-Grundlage, Renderprofil-Diagnose, Export-Presets und Eingabenormalisierung auf seinem Draft-Branch. Spielkern, Streckendaten, Speicherung und Generator bleiben Planungsstand. Godot und Windows-Fokus sind bestätigt; konkrete Sprache, Module und Exportprofile sind Vorschläge P-001/P-002/P-009 im [Entscheidungsregister](decisions.md).

## Ein Projekt, zwei Darstellungsprofile

Vorgesehen ist ein Godot-4-Projekt mit typisiertem GDScript. Der Spielkern, Streckendaten und grundsätzlich auch Szenen/Assets werden geteilt. Windows verwendet ein hochwertiges Forward+-Profil; Web verwendet Compatibility und passende reduzierte Grafik-/Audioeinstellungen. Material- oder Umgebungsvarianten dürfen nötig sein, sollen aber keine zweite Spielimplementierung erzeugen.

Die offizielle Windows-Downloadseite weist bei der Recherche am 2026-09-05 Godot **4.7.2** aus. Das ist der vorgeschlagene Ausgangspunkt für P0, noch kein im Projekt vorhandener Versionspin. P0 muss die genaue Standard-Editorversion und dazu passende Export-Templates gemeinsam fixieren und durch echte Exporte prüfen. Keine stillen Engine-Upgrades über eine bewegliche `latest`-Angabe.

Aktuelle technische Grundlage: Godot 4 kann im Web nur den Compatibility-Renderer mit WebGL 2.0 verwenden; Forward+/Mobile stehen dort nicht zur Verfügung. C#-Projekte können derzeit nicht als Godot-4-Web-Projekt exportiert werden. Deshalb ist GDScript hier die vorgeschlagene gemeinsame Sprache. Quellen siehe unten.

Plattformbezogene Projektsettings und Darstellungsmerkmale werden über Godots Feature-Tags/Overrides und eine kleine Profilkonfiguration getrennt. Die Web-Darstellung ist früh zu testen: Ein Rendererwechsel kann Anpassungen an Beleuchtung, Materialien und Umgebung benötigen. Windows darf zusätzliche Effekte haben, die grundlegende Erkennbarkeit eines Weges darf davon aber nicht abhängen.

## Gemeinsamer Spielkern ist zunächst kein Server

Das gemeinsame Backend im Sinne dieses Projekts ist zunächst die geteilte Spiellogik innerhalb der Anwendung. Für einen spielbaren lokalen PoC werden kein Webservice, Login und keine zentrale Datenbank benötigt.

Ein späterer Online-Ranglistendienst kann dieselbe API für beide Exporte anbieten. Er wäre ein zusätzlicher Baustein, kein Ersatz für den lokalen unmittelbaren Eingabepfad. Ein Schritt darf nicht auf eine Netzwerkbestätigung warten. Lokale Windows- und Browser-Ergebnisse sind ohne einen solchen Dienst nicht automatisch synchronisiert.

## Vorgeschlagene Verantwortlichkeiten

| Bereich | Verantwortung | Darf nicht entscheiden |
| --- | --- | --- |
| `CourseData` / Validator | Felder, Buchstaben, Verbindungen, Start/Ziel, Identität; Gültigkeitsprüfungen | Animationen und Grafikqualität |
| `RunSession` | Aktuelles Feld, Laufstatus, Eingabevalidierung, Fehlerfrist, Start/Ziel, Ergebnis | Kameraführung und Schrittanimationsdauer |
| Eingabeadapter | Echte Tastendrücke normalisieren und geordnet mit Zeitwerten an den Kern übergeben | Vorab raten, welche zukünftigen Eingaben irgendwann passen |
| Darstellung | Figur, Strecke, Kamera, HUD, Fehlerfeedback; visuell aufholen | Ob ein Schritt gültig ist und wann das Ziel erreicht wurde |
| Ergebnisablage | Lokale Speicherung und Laden gewerteter Resultate | Nachträgliche Änderung einer bereits bestimmten Zielzeit |
| Generator, später | Reproduzierbare Erstellung geprüfter `CourseData` | Rendererabhängige Regeln oder Dekoration als Gameplay-Zufall |

Der Kern soll ohne gerenderte 3D-Szene testbar sein, etwa durch kleine GDScript-Klassen auf `RefCounted`-Basis. Keine Pflicht zu einem separaten Service-Framework. Die Kernbewegung ist ein Wechsel zwischen erlaubten Feldern, keine physikalische Kollisionssimulation.

## Ereignisse und Zeit

Echte Tastendruckereignisse werden einzeln und in ihrer empfangenen Reihenfolge behandelt, nicht durch einmaliges Abfragen einer Taste pro Frame ersetzt. Godots `InputEventKey` unterscheidet `pressed`, `echo`, den erzeugten Unicode-Wert und physische Tastenpositionen. Für die anfänglichen lateinischen Buchstaben muss der Eingabeadapter das aktuelle Layout respektieren und Groß-/Kleinschreibung normalisieren. Gedrückthalten, UI-Shortcuts und reine Modifier werden getrennt behandelt.

Für die Laufzeit ist eine injizierbare monotone Uhr vorgesehen; im Godot-Adapter bietet sich `Time.get_ticks_usec()` an. Start-, Fehler- und Zielzeit verwenden dieselbe Zeitbasis und Integerwerte. Tests übergeben eine kontrollierte Uhr. Die Fehlerfrist wird beim nächsten Eingabeereignis direkt geprüft, nicht nur bei einem Animationssignal oder Physiktick.

Die Uhr garantiert keine identische Ende-zu-Ende-Eingabelatenz auf Windows und im Browser. In P0/P1 wird dokumentiert, an welcher Stelle Eingabezeiten erfasst werden. Künstliche Testereignisse können exakte Regelparität zeigen; reale Hardware-, OS- und Browserlatenzen müssen zusätzlich untersucht werden. Keine Behauptung einer hardwareübergreifend garantierten Millisekundengenauigkeit.

P0 erfasst beim Eintritt in Foundation._unhandled_input mit Time.get_ticks_usec() den Zeitpunkt, zu dem die Anwendung das Ereignis entgegennimmt, und zeigt ihn nur als captured_usec an. Dieser Wert ist weder ein behaupteter OS-/Browserzeitstempel noch ein Renntimer. Die Normalisierung verarbeitet den vom Layout erzeugten Unicodewert (A–Z), Shift, Key-up, Echo und Shortcut-Modifier sichtbar; sie enthält keine RunSession- oder Fehlerregel. P1a darf diesen Empfangspunkt erst mit dem dann beauftragten Uhr- und Regelvertrag verbinden.

## Streckenmodell und Reproduzierbarkeit

`CourseData` enthält stabile Feld-IDs, ganzzahlige Rasterkoordinaten, normalisierte Buchstaben, explizite Verbindungen sowie Start/Ziel. Wo zwei Felder räumlich als begehbare Nachbarn erscheinen, müssen Daten und Geometrie dieselbe Aussage machen. Rückverbindungen sind im vorgeschlagenen ersten Modell symmetrisch.

Die spätere Streckenidentität berücksichtigt Seed, Generatorversion, Regelversion, beschriftungsrelevantes Layout-/Schwierigkeitsprofil und Topologiekonfiguration. Ein Hash der kanonisch serialisierten fertigen Streckendaten dient als zusätzliche Prüfung. Kosmetische Daten gehören nicht in diese Identität.

Determinismus muss nachgewiesen werden: stabile Iterationsreihenfolge, kontrollierte Zufallsquelle und getrennte Zufallsströme für Topologie, Buchstaben und Dekoration. Nicht pauschal unterstellen, dass ein Engine-RNG über alle Versionen und Plattformen identische Resultate liefert. Feste Seeds und erwartete Ausgaben werden als plattformübergreifende Referenzfälle getestet. Die Versionierung schützt alte Ranglisten vor veränderten Strecken.

## Ablage, Builds und Online-Perspektive

Vorgeschlagene Projektstruktur nach P0: `project.godot` im Repository-Root; `scenes/`, `scripts/core/`, `scripts/input/`, `scripts/presentation/`, `scripts/storage/`, `data/`, `assets/` und `tests/`. Verzeichnisse entstehen erst bei tatsächlichem Bedarf. Importcaches, Buildausgaben und lokale Secrets werden nicht versioniert; notwendige Quellassets, Szenen und Godot-UID-Dateien schon.

P0 liefert zwei Export-Presets und reproduzierbare Buildbefehle. P1 ergänzt Kernregeltests; CI soll Tests und Exporte automatisieren, sobald diese lokal reproduzierbar sind. Ein tatsächlich gestarteteter Windows-Build und ein im Browser gestarteter HTTP(S)-Export bleiben eigenständige Abnahmen. Ein erfolgreiches Headless-Exportkommando ersetzt sie nicht.

Lokale Ergebnisse brauchen ein versioniertes Datenformat, verlässliches Laden und eine verständliche Behandlung fehlgeschlagener Speicherung. Browserpersistenz, Reload und eingeschränkte Speicherumgebungen werden gesondert geprüft. Die Offline-Spielbarkeit darf nicht von einer späteren Online-Rangliste abhängen.

Für Onlinewertungen können Eingabeverläufe gegen Strecke und Regeln validiert werden. Das prüft die Plausibilität eines Laufs, beweist aber nicht, dass ein Mensch statt eines Bots getippt hat. Ein Anti-Cheat- und Plattformvergleichskonzept ist daher eine spätere eigene Aufgabe.

## Primärquellen

Alle folgenden Quellen wurden am **2026-09-05** geprüft. Die `stable`-Dokumentation ist beweglich; beim Versionspin in P0 sind die relevanten Aussagen erneut gegen die gewählte Version zu prüfen.

- Windows-Download und Version: https://godotengine.org/download/windows/
- Web-Export, C#-Grenze und Renderer: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Renderer und Wechselwirkungen: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Plattform-Overrides: https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
- Tastaturereignisse: https://docs.godotengine.org/en/stable/classes/class_inputeventkey.html
- Monotone Zeitmessung: https://docs.godotengine.org/en/stable/classes/class_time.html
