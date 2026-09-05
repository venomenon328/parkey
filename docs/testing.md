# Teststrategie und Abnahme

Stand: 2026-09-05. **Geplante Tests; noch keine davon sind implementiert oder ausgeführt.** Testfälle zu vorgeschlagenen Regeln werden zusammen mit diesen Regeln freigegeben. Fachliche Grundlage: [Spieldesign](game-design.md), [Architektur](architecture.md) und [Entscheidungen](decisions.md).

## Automatisierte Kernregeln ab P1

| Fall | Erwartung im vorgeschlagenen Modell |
| --- | --- |
| Gültiger Nachbarbuchstabe | Genau ein Schritt zum richtigen Feld; neue Nachbarschaft gilt unmittelbar |
| Mehrere schnelle gültige Ereignisse vor dem nächsten Renderbild | Alle geordnet ausführen; kein pauschales Ein-Schritt-pro-Frame-Limit |
| Falscher Bewegungsbuchstabe | Standort unverändert, genau ein Fehler, feste Sperrfrist |
| Gültige und ungültige Eingaben während der Sperre | Keine Bewegung, kein Puffern, keine Verlängerung, keine weiteren Fehler |
| Eingabe knapp vor / genau am / nach Sperrende | Vorher gesperrt; ab Fristende normal verarbeiten, unabhängig von Animationsstatus |
| Neuer Fehler nach Sperrende | Neue reguläre Sperre möglich |
| Zeit während der Sperre | Renntimer läuft; keine doppelte zusätzliche Zeitaddition |
| Gedrückthalten / Echo / Loslassen | Keine zusätzlichen Schritte |
| Überlappende echte Tasten | Kein künstlicher Zwang, erst alle Tasten loszulassen |
| Groß-/Kleinschreibung und QWERTZ-Y/Z | Gleicher sichtbarer Buchstabe erzeugt den vorgesehenen Schritt |
| UI/Modifier und Eingaben außerhalb des Laufs | Keine versehentlichen Spielschritte oder Fehler |
| Ziel mit noch laufender Bewegungsgrafik | Zeit beim logischen Zieleingang festhalten; nur ein Ergebnis speichern |
| Neustart | Position, Laufstatus, Sperre und Zeit sauber zurücksetzen |
| Fokusverlust/Abbruch | Lauf nach freigegebener Regel invalidieren; kein gewerteter Abschluss |
| Lokale Rangliste | Numerische Sortierung, passende Streckenidentität, Laden nach Neustart |

Die Uhr wird für Grenztests kontrolliert injiziert. Tests warten nicht tatsächlich per Sleep auf jede Fehlerpause. Zusätzlich muss der reale Eingabeadapter getestet werden: Ein perfekter Kern prüft keine im Adapter verlorenen Ereignisse.

## Datenvalidator und Generator

Schon die handgebauten P1-Strecken müssen dieselben Grundprüfungen bestehen: stabile eindeutige IDs, vorhandener Start/Zielknoten, gültige Verbindungseinträge, erreichbares Ziel und verschiedene Buchstaben in jeder erreichbaren Nachbarschaft. Der Negativtest A–B–A muss bei beidseitigen Verbindungen zurückgewiesen werden. Gabelungen, Rückwege und Zusammenführungen werden ausdrücklich geprüft.

Ab P3: viele Seeds automatisch generieren und validieren; feste Referenz-Seeds gegen erwartete kanonische Daten/Hashes prüfen; dieselben Fälle in Windows- und Web-Builds ausführen. Gameplay-Daten dürfen sich durch zusätzliche Dekoration, Renderereinstellung oder Kameraposition nicht verändern. Bei Regel-/Generatoränderungen Versions- und Ranglistentrennung prüfen.

Strukturelle Gültigkeit ist kein Spielspaßtest. Ob Wege interessant und Buchstabenfolgen tatsächlich unterschiedlich tippbar sind, wird zusätzlich praktisch untersucht.

## Plattformmatrix

| Prüfung | Windows | Browser |
| --- | --- | --- |
| P0-Build | Native Anwendung startet außerhalb des Editors | Export startet über HTTP(S) |
| Darstellung | Gewähltes Forward+-Profil sichtbar und fehlerfrei | Compatibility ohne fehlende Zeichen, Materialien oder Pflichtsignale |
| Eingabe | Echte schnelle Eingaben, Layout, Tastenüberlappung | Dieselben Fälle; Fokus und Browser-Shortcuts zusätzlich |
| Speichern | Ergebnis nach Schließen/Neustart vorhanden | Ergebnis nach Reload/Neustart; eingeschränkten Speicher gesondert prüfen |
| P1-Kernregeln | Geordnete Ereignisse und kontrollierte Zeitfälle | Gleiche Eingabeprotokolle ergeben gleiche Kernresultate |
| Leistung | Auflösung, Hardware, Bildrate und Eingabegefühl protokolliert | Browser, Hardware und entsprechende Messbedingungen protokolliert |

Zunächst sind ein tatsächlich verwendetes Windows-System sowie ein Chromium-basierter Browser und Firefox als vorgeschlagene Testziele vorgesehen. Konkrete Versionen und Ergebnisse werden bei Ausführung eingetragen. Keine Unterstützung anderer Browser oder Plattformen aus einem einzelnen erfolgreichen Export ableiten.

## Spieltests

Besonders beobachten: verdeckte Buchstaben, schwer erkennbare rückwärtige Nachbarn, Kameraschwenks an Gabelungen, sichtbarer Rückstand der Figur bei schnellen Folgen und der Übergang in die Fehlerpause. Zeigt die Figur während der Sperre einen anderen Standort als die logisch gültige Nachbarschaft, ist das ein Problem und nicht bloß kosmetisch.

Fehlerpause zunächst mit dem Wert aus T-001 prüfen. Fragen: Ist die Sperre verständlich? Endet das Feedback rechtzeitig? Fühlen sich Eingaben nahe am Sperrende defekt an? Kann wahlloses Tastendrücken konkurrenzfähige Zeiten erzeugen? Veränderungen an Dauer oder Puffern werden als explizite Regeländerungen dokumentiert.

Routen mit unterschiedlichen Tippmethoden testen. Neben Gesamtzeit auch Fehler, gewählte Route und Entscheidungsstellen betrachten. Langsames Lesen, falsche Routenannahmen und eigentliche Tippfehler nicht in einer einzigen Kennzahl verstecken. Aufzeichnungen zunächst lokal und ohne unnötige personenbezogene Daten.

## Nachweisformat

Eine Abnahme nennt Commit, genaue Godot-Version, Exportprofil, Betriebssystem/Browser, ausgeführte Befehle oder manuelle Schritte und Ergebnis. Nicht ausgeführte Prüfungen bleiben offen. Build-Erfolg, automatisierter Regeltest, visueller Test und subjektiver Spieltest sind getrennte Nachweise.
