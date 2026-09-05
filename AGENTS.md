# Arbeitsregeln für Parkey

## Vor Änderungen lesen

Lies `README.md`, `docs/decisions.md`, `docs/implementation-plan.md` und die für den Auftrag relevanten Design-, Architektur-, Entwicklungs-, Roadmap- und Testabschnitte vollständig. Prüfe den tatsächlichen Repository-Stand und das maßgebliche Issue bzw. den aktuellen PR-Review; ein Plan oder eine frühere Chat-Aussage ist kein Nachweis einer Implementierung.

## Entscheidungen und Umfang

- Bestätigte Anforderungen, vorläufige Testwerte, Vorschläge und offene Fragen sind verschiedene Kategorien. Schweigen zu einem Vorschlag ist keine Freigabe.
- Eine neu ausdrücklich getroffene Nutzerentscheidung aktualisiert zuerst das Entscheidungsregister und die betroffenen Spezifikationen. Ändere bestehende Entscheidungen nachvollziehbar, statt widersprüchliche Ergänzungen anzuhängen.
- Implementiere nur den beauftragten Umfang. Roadmap-Einträge und angelegte Issues sind keine pauschale Erlaubnis zur Umsetzung sämtlicher Features.
- Godot und Windows als Hauptplattform sind bestätigt. Ein gemeinsamer Spielkern mit Web-Unterstützung ist das Architekturziel; praktisch nicht geprüfte Plattformunterstützung darf nicht als erfolgreich bezeichnet werden.
- Abhängige Pakete erst nach Abnahme und Merge ihrer Voraussetzungen beginnen. Spätere Branches vom dann aktuellen `main` erstellen; nicht sämtliche Pakete vom alten Planungsstand abzweigen.

## Dokumentation gehört zur Änderung

Jeder Pull Request, der Verhalten, Konfiguration, Technik oder Umfang ändert, aktualisiert im selben PR die betroffenen Dokumente. Prüfe insbesondere `docs/decisions.md`, Fachspezifikation, Testvertrag, Paketplan und Statusangaben in README/Roadmap. Reine Implementierungsdetails benötigen keinen neuen Grundsatzbeschluss.

Entscheidungsstatus und Begründung stehen im Register. Issues enthalten Arbeitspakete und verlinken auf die Spezifikation; sie ersetzen diese nicht. Implementierungen erfolgen auf den benannten Arbeitsbranches mit kleinen Draft-PRs; nicht automatisch mergen. Bis zur vollständigen Abnahme Draft lassen.

Schreibe Projektdokumentation auf Deutsch und Code-Bezeichner auf Englisch. Halte Texte knapp genug zur Pflege. Quellen für zeitabhängige Engine-Aussagen enthalten URL und Prüfdatum. Planungsdateien behaupten keine vorhandenen Tests oder Builds.

## Auftragsmetadaten gehören nicht ins Repository

Auswahl eines konkreten KI-Modells, Reasoning-Stufe, Token-/Kostenabwägungen und Einschätzungen wie `Selbst umsetzbar: Ja/Teilweise/Nein` sind Gesprächs- bzw. Auftragsmetadaten. Sie gehören **nicht** in Repository-Dokumentation, Issues, PR-Beschreibungen oder andere Implementierungsspezifikationen. Diese Angaben werden außerhalb des Repositorys unmittelbar vor einem Auftrag beurteilt.

Kompakte Arbeitsanweisungen dürfen Repository, Branch/PR, maßgebliche Quellen, Tests und Übergaberegeln nennen. Sie enthalten jedoch keine Modellwahl oder Einschätzung der Eigenumsetzbarkeit.

## Verbindliche lokale Werkzeugablage unter Windows

Projektbezogene lokale Entwicklungswerkzeuge werden unter **`E:\Zeuch\Coding\Parkey-Tools`** abgelegt. Keine Parkey-Werkzeuge unter `C:\Tools` oder anderen ad-hoc-Stammverzeichnissen neu anlegen.

- Versionierte Installationen liegen direkt unter dem Stammverzeichnis, z. B. `E:\Zeuch\Coding\Parkey-Tools\Godot-4.7.2`.
- Stabile Kommando-Shims für den Benutzer-PATH liegen unter `E:\Zeuch\Coding\Parkey-Tools\bin`; nur dieses `bin`-Verzeichnis soll für Parkey dauerhaft in den PATH aufgenommen werden.
- Von Godot selbst erwartete Benutzerverzeichnisse sind Ausnahmen, insbesondere `%APPDATA%\Godot\export_templates\<version>`. Temporäre Downloads/Entpackstufen dürfen `%TEMP%` verwenden.
- Bereits versehentlich an anderer Stelle vorhandene Werkzeugordner nicht ohne ausdrücklichen Auftrag löschen. Neue Einrichtung und Dokumentation verwenden jedoch ausschließlich die verbindliche Ablage.
- Details und Installationsbefehle stehen in `docs/development.md`.

## Technische Leitplanken

- Korrekte Eingaben nicht durch Animationsdauer, Physikticks oder einen pauschalen Schritt-Cooldown begrenzen. Die explizite Fehlerpause ist getrennt.
- Renderer, Animationen und Netzwerkantworten entscheiden nicht über gültige Wege oder Zielankunft.
- Änderungen an gewerteten Regeln/Strecken berücksichtigen Identität/Versionierung. Spielrelevante räumliche Layoutdaten gehören zur Streckenidentität; nur tatsächlich kosmetische Änderungen bleiben davon getrennt.
- D-010 bis D-013 beachten: explizite Nachbarlisten, kein allgemeiner Raster-/Orthogonalitäts- oder fester Nachbarzahlzwang. Graph-/Layoutvalidierung trennen; moderate Größenvariation darf keinen zusätzlichen Bewegungs-Cooldown erzeugen. PoC-Bauhilfen nicht zu Kernregeln machen.
- Keine doppelte Windows-/Web-Spielimplementierung ohne dokumentierte neue Entscheidung.
- Neue Abhängigkeiten, Dienste und Assets auf Notwendigkeit, Plattformverträglichkeit und Lizenz prüfen. Keine Secrets, lokalen Zugangsdaten oder ungeklärten Fremdassets committen. Keine Projektlizenz, öffentliche Veröffentlichung oder kostenpflichtigen Dienste eigenmächtig festlegen.
- Pflichtbefehle aus `docs/testing.md` einhalten. P0 hat den Runner und die Export-Presets geliefert; P1a ergänzt `core`. Weitere geplante Suites nicht als vorhanden behaupten. Unbekannte/leere Suites müssen fehlschlagen.

## Tests und Übergabe

Führe verfügbare relevante Tests aus und nenne exakt, was tatsächlich auf welcher Plattform ausgeführt wurde. Export ist kein Spieltest; Headless ist kein Grafiktest. Fehlende Testumgebung lässt die entsprechende Abnahme offen und den PR Draft. Nicht durch erfundene Berichte oder still übersprungene Suites kompensieren.

Übergabe: Änderungen, Testnachweise, verbleibende Einschränkungen, Commit/PR und nächster klar abgegrenzter Schritt. Reale Nutzerabnahmen können technische Tests ergänzen, aber nicht erfunden werden. Dokumentationspflege erfolgt mit der tatsächlichen Änderung, nicht automatisch im Hintergrund.
