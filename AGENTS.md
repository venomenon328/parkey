# Arbeitsregeln für Parkey

## Vor Änderungen lesen

Lies `README.md`, `docs/decisions.md`, `docs/implementation-plan.md` und die für den Auftrag relevanten Design-, Architektur-, Roadmap- und Testabschnitte vollständig. Prüfe den tatsächlichen Repository-Stand und das maßgebliche Issue bzw. den aktuellen PR-Review; ein Plan oder eine frühere Chat-Aussage ist kein Nachweis einer Implementierung.

## Entscheidungen und Umfang

- Bestätigte Anforderungen, vorläufige Testwerte, Vorschläge und offene Fragen sind verschiedene Kategorien. Schweigen zu einem Vorschlag ist keine Freigabe.
- Eine neu ausdrücklich getroffene Nutzerentscheidung aktualisiert zuerst das Entscheidungsregister und die betroffenen Spezifikationen. Ändere bestehende Entscheidungen nachvollziehbar, statt widersprüchliche Ergänzungen anzuhängen.
- Implementiere nur den beauftragten Umfang. Roadmap-Einträge und angelegte Issues sind keine pauschale Erlaubnis zur Umsetzung sämtlicher Features.
- Godot und Windows als Hauptplattform sind bestätigt. Ein gemeinsamer Spielkern mit Web-Unterstützung ist das Architekturziel; praktisch nicht geprüfte Plattformunterstützung darf nicht als erfolgreich bezeichnet werden.
- Abhängige Pakete erst nach Abnahme/Merge ihrer Voraussetzungen beginnen. Spätere Branches vom dann aktuellen main erstellen; nicht sämtliche Pakete vom alten Planungsstand abzweigen.

## Dokumentation gehört zur Änderung

Jeder Pull Request, der Verhalten, Konfiguration, Technik oder Umfang ändert, aktualisiert im selben PR die betroffenen Dokumente. Prüfe insbesondere `docs/decisions.md`, Fachspezifikation, Testvertrag, Paketplan und Statusangaben in README/Roadmap. Reine Implementierungsdetails benötigen keinen neuen Grundsatzbeschluss.

Entscheidungsstatus und Begründung stehen im Register. Issues enthalten Arbeitspakete und verlinken auf die Spezifikation; sie ersetzen diese nicht. Die initiale Dokumentation und Paketplanung wurden auf main abgelegt. Implementierungen erfolgen auf den benannten Arbeitsbranches mit kleinen Draft-PRs; nicht automatisch mergen. Bis zur vollständigen Abnahme Draft lassen.

Schreibe Projektdokumentation auf Deutsch und Code-Bezeichner auf Englisch. Halte Texte knapp genug zur Pflege. Quellen für zeitabhängige Engine-Aussagen enthalten URL und Prüfdatum. Planungsdateien behaupten keine vorhandenen Tests oder Builds.

## Technische Leitplanken

- Korrekte Eingaben nicht durch Animationsdauer, Physikticks oder einen pauschalen Schritt-Cooldown begrenzen. Die explizite Fehlerpause ist getrennt.
- Renderer, Animationen und Netzwerkantworten entscheiden nicht über gültige Wege oder Zielankunft.
- Änderungen an gewerteten Regeln/Strecken berücksichtigen Identität/Versionierung; kosmetische Änderungen dürfen nicht versehentlich andere Strecken erzeugen.
- Keine doppelte Windows-/Web-Spielimplementierung ohne dokumentierte neue Entscheidung.
- Neue Abhängigkeiten, Dienste und Assets auf Notwendigkeit, Plattformverträglichkeit und Lizenz prüfen. Keine Secrets, lokalen Zugangsdaten oder ungeklärten Fremdassets committen. Keine Projektlizenz, öffentliche Veröffentlichung oder kostenpflichtigen Dienste eigenmächtig festlegen.
- Pflichtbefehle aus `docs/testing.md` einhalten. P0 erstellt den Test-Runner erst; niemals behaupten, die geplanten Skripte seien schon vorhanden. Unbekannte/leere Suites müssen fehlschlagen.

## Bei Vorbereitung neuer Aufgaben

Unmittelbar vor Entwicklungspaketen oder offenen Nacharbeiten zusätzlich angeben, nicht erst rückblickend:

1. Konkretes GPT-5.6-/GPT-6-Modell und Reasoning-Stufe mit kurzer Abwägung von Komplexität, Risiko und Tokenaufwand. Die Auswahl im Paketplan ist Ausgangspunkt, keine Pflicht zur höchsten Stufe.
2. Explizit `Selbst umsetzbar: Ja`, `Teilweise` oder `Nein`; aktuelle Möglichkeit von Implementierung, Test, Commit und Push ehrlich beurteilen. Kleine isolierte Korrekturen/Reviews bevorzugt direkt, größere Mehrdateienpakete mit längeren Testzyklen bevorzugt Codex.
3. Kompakter Codex-Prompt: Repository/Branch, maßgebliches Issue bzw. aktueller PR-Review und verbindliche Dokumente, vollständiger Umsetzungsauftrag, wenige nicht anderweitig dokumentierte Risiken, Pflichtbefehle, Commit/Push und Draft-/Reviewstatus sowie kurze Abschlussmeldung. Keine vollständigen Lieferumfänge, Akzeptanzkriterien oder Reviewpunkte nochmals kopieren.

## Tests und Übergabe

Führe verfügbare relevante Tests aus und nenne exakt, was tatsächlich auf welcher Plattform ausgeführt wurde. Export ist kein Spieltest; Headless ist kein Grafiktest. Fehlende Testumgebung lässt die entsprechende Abnahme offen und den PR Draft. Nicht durch gefälschte Berichte oder still übersprungene Suites kompensieren.

Übergabe: Änderungen, Testnachweise, verbleibende Einschränkungen, Commit/PR und nächster klar abgegrenzter Schritt. Reale Nutzerabnahmen können technische Tests ergänzen, aber nicht erfunden werden. Dokumentationspflege erfolgt mit der nächsten tatsächlichen Änderung, nicht automatisch im Hintergrund.
