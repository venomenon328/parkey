# Technische Architektur

Stand: 2026-09-05. P0 implementiert die gemeinsame Godot-/GDScript-Grundlage, Renderprofil-Diagnose, Export-Presets und Eingabenormalisierung. Spielkern, Streckendaten, Speicherung und Generator bleiben Planungsstand. Godot und Windows-Fokus sind bestätigt; konkrete Sprache, Module und Exportprofile sind Vorschläge P-001/P-002/P-009 im [Entscheidungsregister](decisions.md).

## Ein Projekt, zwei Darstellungsprofile

Vorgesehen ist ein Godot-4-Projekt mit typisiertem GDScript. Der Spielkern, Streckendaten und grundsätzlich auch Szenen/Assets werden geteilt. Windows verwendet ein hochwertiges Forward+-Profil; Web verwendet Compatibility und passende reduzierte Grafik-/Audioeinstellungen. Material- oder Umgebungsvarianten dürfen nötig sein, sollen aber keine zweite Spielimplementierung erzeugen.

P0 pinnt den Godot-Standardeditor auf **4.7.2.stable.official.ed1daf0bf** und die passenden Export-Templates auf **4.7.2.stable**. Beide Zielprofile wurden mit diesem Stand tatsächlich exportiert und gestartet. Engine-Upgrades erfolgen nicht still über eine bewegliche `latest`-Angabe, sondern als eigene nachvollziehbare Änderung mit erneuter Exportprüfung.

Aktuelle technische Grundlage: Godot 4 kann im Web nur den Compatibility-Renderer mit WebGL 2.0 verwenden; Forward+/Mobile stehen dort nicht zur Verfügung. C#-Projekte können derzeit nicht als Godot-4-Web-Projekt exportiert werden. Deshalb ist GDScript hier die vorgeschlagene gemeinsame Sprache. Quellen siehe unten.

Plattformbezogene Projektsettings und Darstellungsmerkmale werden über Godots Feature-Tags/Overrides und eine kleine Profilkonfiguration getrennt. Die Web-Darstellung ist früh zu testen: Ein Rendererwechsel kann Anpassungen an Beleuchtung, Materialien und Umgebung benötigen. Windows darf zusätzliche Effekte haben, die grundlegende Erkennbarkeit eines Weges darf davon aber nicht abhängen.

## Gemeinsamer Spielkern ist zunächst kein Server

Das gemeinsame Backend im Sinne dieses Projekts ist zunächst die geteilte Spiellogik innerhalb der Anwendung. Für einen spielbaren lokalen PoC werden kein Webservice, Login und keine zentrale Datenbank benötigt.

Ein späterer Online-Ranglistendienst kann dieselbe API für beide Exporte anbieten. Er wäre ein zusätzlicher Baustein, kein Ersatz für den lokalen unmittelbaren Eingabepfad. Ein Schritt darf nicht auf eine Netzwerkbestätigung warten. Lokale Windows- und Browser-Ergebnisse sind ohne einen solchen Dienst nicht automatisch synchronisiert.

## Vorgeschlagene Verantwortlichkeiten

| Bereich | Verantwortung | Darf nicht entscheiden |
| --- | --- | --- |
| `CourseData` / Validator | IDs, Buchstaben, explizite Verbindungen, räumliches Layout, Start/Ziel und Identität; getrennte Graph-/Layoutprüfungen | Animationsdauer und Grafikqualität |
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

Die bestätigte Trennung aus D-010 bis D-013 ist vor P1a verbindlich: **Verbindungsgraph, räumliches Layout und kosmetische Darstellung sind verschiedene Verantwortlichkeiten.** `CourseData` führt stabile Feld-IDs, normalisierte Buchstaben, explizite Nachbar-IDs sowie Start/Ziel mit den zugehörigen Layoutdaten zusammen. Keine festen Slots wie oben/unten/links/rechts, keine allgemeine Manhattan-Nachbarschaft und kein eingebautes Vier-/Sechs-/Acht-Nachbarn-Limit. Rückverbindungen sind im vorgeschlagenen ersten Modell symmetrisch.

Layoutdaten beschreiben relative Position, Grundfläche/Formparameter, Größe, Ausrichtung und geeigneten Stand-/Landepunkt je Feld sowie erforderliche Übergangsdaten. Für P1 reichen wenige einfache Formen und ein kleines datenbasiertes Format; beliebige Polygone, 3D-Brücken oder neue Generatoren sind nicht Voraussetzung. Optional verwendete Rasterkoordinaten sind Bauhilfen eines Layoutprofils, niemals Feldidentität oder Quelle der allgemeinen Erreichbarkeit. Präzision und kanonische Zahlenrepräsentation sind festzulegen; quantisierte Koordinaten erzwingen kein regelmäßiges Tile-Raster.

Der Graphvalidator prüft IDs, Kantenreferenzen, Selbst-/Doppelkanten, vereinbarte Symmetrie, Erreichbarkeit und eindeutige Buchstaben der gesamten Nachbarschaft. Räumliche Prüfungen beurteilen separat gültige Grundflächen, Überlappungen, geeignete Anker und verständliche Randanschlüsse bzw. kleine Fugen des unterstützten Layoutprofils. Eckberührung allein reicht nicht. Ein Graph kann logisch gültig und trotzdem räumlich unbrauchbar sein; spielbare `CourseData` müssen beide Prüfungen bestehen. Die Nachbarschaft wird vor dem Start festgelegt, nicht während der Eingabe per Distanzschwelle oder Mesh-Kollision neu berechnet.

`RunSession` benötigt für die Schrittentscheidung nur die expliziten Verbindungen und Buchstaben. Bei identischen normalisierten Eingaben/Zeitwerten ergeben unterschiedliche gültige Layouts derselben Topologie dieselben logischen Schritte und Zielzeiten, aber gegebenenfalls verschiedene Streckenidentitäten. Bewegungsgrafik folgt den Layout-Ankern/Übergängen und holt entlang des richtigen Wegs auf; aus Feldgröße, Abstand, Renderprofil oder Animationsende entsteht kein zusätzlicher Schritt-Cooldown.

Die Streckenidentität berücksichtigt bereits bei Handstrecken und später bei Seeds die Topologie, Buchstaben, Regelversion, relevante Konfiguration und **spielrelevante räumliche Gestaltung**. Dazu gehören relative Feldpositionen, Grundflächen/Formparameter, Größen, Ausrichtungen, Standpunkte und Übergänge. Bei generierten Strecken kommen Seed, Generator-/Layoutversion und Tastatur-/Schwierigkeitsprofil hinzu. Ein Hash der kanonisch serialisierten fertigen Daten bindet diese Inhalte; Hashschema und Präzision sind versioniert. Geänderte räumliche Daten dürfen trotz identischem Graphen nicht in dieselbe Rangliste gelangen.

Kosmetische Material-/Oberflächenvarianten und nicht spielrelevante Dekoration bleiben außerhalb dieser Identität. Die kanonischen Layoutdaten sind die Quelle für beide Renderprofile; keine Identitätsableitung aus Renderer-Meshes, Physikkontakten oder aktueller Kameraposition. Dekoration darf weder neue Übergänge suggerieren noch Pflichtinformationen verdecken. Ein bloßes Label „kosmetisch“ macht eine Änderung der Feldgrundfläche nicht zu Kosmetik.

Determinismus muss nachgewiesen werden: stabile Iterationsreihenfolge, kontrollierte Zufallsquelle und getrennte Zufallsströme für Topologie, räumliches Layout, Buchstaben und Dekoration. Nicht pauschal unterstellen, dass ein Engine-RNG über alle Versionen und Plattformen identische Resultate liefert. Feste Seeds und erwartete Ausgaben werden als plattformübergreifende Referenzfälle getestet. Die Versionierung schützt alte Ranglisten vor veränderten Strecken.

## Ablage, Builds und Online-Perspektive

Vorgeschlagene Projektstruktur nach P0: `project.godot` im Repository-Root; `scenes/`, `scripts/core/`, `scripts/input/`, `scripts/presentation/`, `scripts/storage/`, `data/`, `assets/` und `tests/`. Verzeichnisse entstehen erst bei tatsächlichem Bedarf. Importcaches, Buildausgaben und lokale Secrets werden nicht versioniert; notwendige Quellassets, Szenen und Godot-UID-Dateien schon.

P0 liefert zwei Export-Presets, reproduzierbare Buildbefehle, Smoke-Tests und CI. P1 ergänzt Kernregeltests und führt die bestehende Test-/Exportkette fort. Ein tatsächlich gestarteter Windows-Build und ein im Browser gestarteter HTTP(S)-Export bleiben eigenständige Abnahmen. Ein erfolgreiches Headless-Exportkommando ersetzt sie nicht.

Lokale Ergebnisse brauchen ein versioniertes Datenformat, verlässliches Laden und eine verständliche Behandlung fehlgeschlagener Speicherung. Browserpersistenz, Reload und eingeschränkte Speicherumgebungen werden gesondert geprüft. Die Offline-Spielbarkeit darf nicht von einer späteren Online-Rangliste abhängen.

Für Onlinewertungen können Eingabeverläufe gegen Strecke und Regeln validiert werden. Das prüft die Plausibilität eines Laufs, beweist aber nicht, dass ein Mensch statt eines Bots getippt hat. Ein Anti-Cheat- und Plattformvergleichskonzept ist daher eine spätere eigene Aufgabe.

## Primärquellen

Alle folgenden Quellen wurden am **2026-09-05** geprüft. Die `stable`-Dokumentation ist beweglich; bei späteren Engine-Upgrades sind die relevanten Aussagen erneut gegen die gewählte Version zu prüfen.

- Windows-Download und Version: https://godotengine.org/download/windows/
- Web-Export, C#-Grenze und Renderer: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
- Renderer und Wechselwirkungen: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Plattform-Overrides: https://docs.godotengine.org/en/stable/tutorials/export/feature_tags.html
- Tastaturereignisse: https://docs.godotengine.org/en/stable/classes/class_inputeventkey.html
- Monotone Zeitmessung: https://docs.godotengine.org/en/stable/classes/class_time.html
