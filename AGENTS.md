# Arbeitsregeln für Parkey

## Vor Änderungen lesen

Lies `README.md`, `docs/decisions.md` und die für den Auftrag relevanten Design-, Architektur-, Roadmap- und Testabschnitte vollständig. Prüfe den tatsächlichen Repository-Stand; ein Plan oder eine frühere Chat-Aussage ist kein Nachweis einer Implementierung.

## Entscheidungen und Umfang

- Bestätigte Anforderungen, vorläufige Testwerte, Vorschläge und offene Fragen sind verschiedene Kategorien. Schweigen zu einem Vorschlag ist keine Freigabe.
- Eine neu ausdrücklich getroffene Nutzerentscheidung aktualisiert zuerst das Entscheidungsregister und die betroffenen Spezifikationen. Ändere bestehende Entscheidungen nachvollziehbar, statt widersprüchliche Ergänzungen anzuhängen.
- Implementiere nur den beauftragten Umfang. Roadmap-Einträge sind keine pauschale Erlaubnis zur Umsetzung sämtlicher Features.
- Godot und Windows als Hauptplattform sind bestätigt. Ein gemeinsamer Spielkern mit Web-Unterstützung ist das Architekturziel; praktisch nicht geprüfte Plattformunterstützung darf nicht als erfolgreich bezeichnet werden.

## Dokumentation gehört zur Änderung

Jeder Pull Request, der Verhalten, Konfiguration, Technik oder Umfang ändert, aktualisiert im selben PR die betroffenen Dokumente. Prüfe insbesondere `docs/decisions.md`, die Fachspezifikation, die Abnahmetests sowie Statusangaben in README und Roadmap. Reine Implementierungsdetails benötigen keinen neuen Grundsatzbeschluss.

Entscheidungsstatus und Begründung werden im Entscheidungsregister gepflegt. Issues enthalten ausführbare Arbeitspakete und verlinken auf die Spezifikation; sie ersetzen diese nicht. Zukünftige Implementierungen erfolgen vorzugsweise auf Arbeitsbranches mit kleinen Pull Requests. Das leere Repository wurde einmalig mit der Dokumentationsbasis auf `main` initialisiert.

Schreibe die Projektdokumentation auf Deutsch und Code-Bezeichner auf Englisch. Halte Texte knapp genug, dass sie tatsächlich gepflegt werden können. Quellen für zeitabhängige Engine-Aussagen enthalten URL und Prüfdatum.

## Technische Leitplanken

- Korrekte Eingaben nicht durch Animationsdauer, Physikticks oder einen pauschalen Schritt-Cooldown begrenzen. Die explizite Fehlerpause ist davon getrennt.
- Renderer, Animationen und Netzwerkantworten entscheiden nicht über gültige Wege oder Zielankunft.
- Änderungen an gewerteten Regeln oder generierten Strecken müssen deren Identität/Versionierung berücksichtigen; kosmetische Änderungen dürfen nicht versehentlich andere Strecken erzeugen.
- Keine doppelte Windows-/Web-Spielimplementierung ohne dokumentierte neue Entscheidung.
- Neue Abhängigkeiten, Dienste und Assets auf Notwendigkeit, Plattformverträglichkeit und Lizenz prüfen. Keine Secrets, lokalen Zugangsdaten oder ungeklärten Fremdassets committen. Keine Lizenz für das Projekt eigenmächtig festlegen.

## Tests und Übergabe

Führe verfügbare relevante Tests aus. Nenne exakt, was tatsächlich ausgeführt wurde und auf welcher Plattform. Ein erfolgreicher Export ist kein erfolgreicher Spieltest; ein Headless-Test ist kein Grafiktest. Bei fehlender Testumgebung bleibt die entsprechende Abnahme offen.

Eine Übergabe beschreibt Änderungen, Testnachweise, verbleibende Einschränkungen und den nächsten klar abgegrenzten Schritt. Das Aktualisieren dieser Dateien erzeugt keine automatische Hintergrundpflege; die Pflege erfolgt jeweils mit der nächsten tatsächlichen Änderung.
