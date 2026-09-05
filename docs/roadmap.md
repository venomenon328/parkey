# PoC-Roadmap

Stand: 2026-09-05. Die Reihenfolge ist ein Vorschlag; nur die Dokumentationsinitialisierung ist abgeschlossen. Ein Meilenstein gilt erst mit tatsächlichen Nachweisen als abgenommen. Siehe [Entscheidungen](decisions.md) und [Teststrategie](testing.md).

## Statusübersicht

| Schritt | Ergebnis | Status |
| --- | --- | --- |
| D0 | Initiale Anforderungen, Architekturvorschlag, Roadmap und Arbeitsregeln | Dokumentiert |
| P0 | Ein Godot-Grundprojekt exportiert nach Windows und Web | Nicht begonnen |
| P1 | Spielbarer handgebauter Testparcours mit Timer, Fehlerpause und lokaler Rangliste | Nicht begonnen |
| P2 | Routenwahl und Kameralesbarkeit funktionieren in einer gestalteten Beispielumgebung | Nicht begonnen |
| P3 | Reproduzierbarer, validierter Seed-Generator auf Basis geprüfter Abschnitte | Nicht begonnen |

## P0 — Gemeinsame technische Grundlage

**Ziel:** Die gewünschte gemeinsame Codebasis früh praktisch nachweisen, bevor Spielsysteme auf ungeprüften Exportannahmen aufbauen.

Umfang: Godot-Standardprojekt mit typisiertem GDScript, genau fixierter Editor-/Template-Version, einer kleinen 3D-Testszene, einer beschrifteten Testtaste, Platzhalterfigur und Kamera. Windows-Forward+- und Web-Compatibility-Profil. Ein einfacher Diagnosebereich zeigt Build/Profil und empfangene Buchstaben; noch keine fertige Spiellogik.

**Abnahme:** Beide Builds kommen aus demselben Commit und Projekt. Die Windows-Anwendung startet außerhalb des Editors. Der Web-Export läuft über HTTP(S), nicht nur als lokal doppelt angeklickte HTML-Datei. Figur, Taste und Beschriftung sind in beiden Profilen sichtbar. Reale Tastendrücke einschließlich QWERTZ-Y/Z werden protokolliert; Renderer und Eingabezeitpunkt sind dokumentiert. Build- und Startbefehle sind reproduzierbar. Nicht getestete Betriebssysteme/Browser werden ausdrücklich als offen ausgewiesen.

Nicht enthalten: vollständiger Generator, Onlinekonto, Ranglistenserver, finale Figur und finale Materialien. Der konkrete technische Entwurf bleibt bis zum Test ein Vorschlag.

## P1 — Spielbarer Kern

**Ziel:** Ein kurzer vollständiger Lauf fühlt sich unmittelbar an und lässt sich zuverlässig messen und wiederholen.

Umfang: handgebauter, kleiner Parcours mit Start/Ziel und einer einfachen Gabelung; als Richtgröße etwa 20–40 Felder. Datenbasierte Nachbarschaftsvalidierung, unmittelbare logische Bewegung, aufholende Darstellung, Fehlerpause mit vorläufigem Testwert, Timer, schneller Neustart, Ergebnisschirm und lokale Rangliste. Die vorgeschlagenen Start-/Fehler-/Fokusregeln müssen zu Beginn dieses Schritts bestätigt oder ausdrücklich als PoC-Experiment freigegeben werden.

**Abnahme:** Korrekte schnelle Eingabefolgen gehen nicht verloren und werden nicht durch eine Schrittdauer gedeckelt. Falsche Buchstaben sperren Bewegung, nicht Renntimer oder gesamte Anwendung. Keine Bewegungen aus während der Sperre gepufferten Eingaben. Zieleinlauf zählt beim logischen Schritt, genau einmal. Bestzeiten bleiben nach Neustart erhalten. Automatisierte Regeltests und ein tatsächlich durchgespielter Windows-Build liegen vor; Web wird mindestens mit denselben Kernfällen geprüft.

Die Platzhaltergestaltung ist nur eine Zwischenstufe. Bereits hier müssen Beschriftung, aktuelles Feld und erreichbare Felder lesbar sein.

## P2 — Routenwahl und visuelle Beispielstrecke

**Ziel:** Nicht nur das Tippen, sondern auch das Spielprinzip aus Routenwahl und Tippbarkeit funktioniert.

Umfang: mehrere handgestaltete Abschnittstypen mit Zusammenführungen; kurzer schwieriger gegen längeren flüssigen Weg; verbesserte vorausschauende Kamera. Eine konsistente Umgebung mit geeigneten Materialien, Beleuchtung, Figur und dezenter Bewegungs-/Fehlerrückmeldung. Windows-Grafik zuerst ausarbeiten, Web-Fallbacks parallel kontrollieren.

**Abnahme:** Ein Spieler kann vor der Abzweigung eine begründete Wahl treffen. Spieler mit verschiedenen Tippmethoden probieren die Wege; Zeiten und stockende Passagen werden getrennt erfasst. Die als leichter gedachte Route wird nicht ohne Messung so bezeichnet. Häufige Stillstände durch Kameraverdeckung werden behoben. Zielhardware, Auflösung und ein erstes Leistungsbudget sind festgelegt. Beide Grafikprofile bewahren dieselben spielrelevanten Informationen.

An diesem Punkt wird entschieden, welche Abschnittstypen tatsächlich in den Generator gehören. Nicht jede entworfene Gabelung muss erhalten bleiben.

## P3 — Reproduzierbare Strecken

**Ziel:** Geprüfte Inhalte werden zuverlässig und abwechslungsreich aus Seeds erzeugt.

Umfang: kontrollierte Kombination der P2-Abschnitte, Buchstabenvergabe, getrennte Zufallsquellen für Gameplay und Dekoration, Strecken-/Regelversionen, Seed-Eingabe und passende lokale Bestenlisten. Automatisierte Validierung jeder Strecke und feste Referenz-Seeds für beide Plattformen.

**Abnahme:** Gleicher Seed und gleiche relevante Version/Konfiguration ergeben dieselben kanonischen Streckendaten auf beiden Zielplattformen. Alle generierten Strecken sind erreichbar und lokal eindeutig. Tests über viele Seeds finden keine unzulässigen Nachbarschaften oder unbeabsichtigten Verbindungen. Eine reine Dekorationsänderung lässt den Gameplay-Hash unverändert. Stichproben mit echten Spielern ergänzen die strukturellen Tests.

## Abschluss des vorgeschlagenen ersten PoC

Ein kleiner, gestalteter Windows-Build und ein aus demselben Projekt stammender Web-Build enthalten: Start/Ziel, lesbaren Third-Person-Parcours, unbegrenzt schnelle korrekte Schritte im Rahmen der Eingabeverarbeitung, definierte Fehlerpause, millisekundige Timeranzeige, lokale Ranglisten und reproduzierbare Seed-Strecken mit Routenalternativen.

Noch nicht notwendig: öffentliche Online-Ranglisten, Accounts, Ghosts, Tagesparcours, Mehrspieler, Editor, Shop oder mehrere Themenwelten. Diese Punkte sind Erweiterungsideen, keine verdeckten Abnahmekriterien.

## Arbeitsweise

Je Arbeitspaket ein klar begrenztes Issue mit Abnahmekriterien, danach ein kleiner Arbeitsbranch und Pull Request. Dokumentation und Implementierung ändern sich zusammen. Nach einem spielbaren Zwischenstand folgt ein kurzer echter Spieltest, bevor der nächste Ausbau beginnt. Die Roadmap enthält bewusst keine unbelegten Zeitversprechen.
