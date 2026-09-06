# P1c: Lokale Ergebnisse und Bestzeiten

Stand: 2026-09-06. **Implementiert auf `codex/p1c-local-leaderboards`; Review/Abnahme bleiben Draft-PR-Gates.** Auftrag: [Issue #4](https://github.com/venomenon328/parkey/issues/4), vorbereitet auf `main` bei `5e60d53f02d6a772677956d23016504d1227bead`. P1b ist über PR #13 abgenommen und gemergt. Verbindlich bleiben [Entscheidungen](decisions.md), [P1-Regeln](p1-rule-profile.md), [Architektur](architecture.md) und [Tests](testing.md).

Dieses Dokument konkretisiert den beauftragten lokalen Speicherausbau. Die unten gewählten Gleichstands-, Anzeige- und Aufbewahrungsparameter sind **vorläufige Arbeitsfestlegungen für P1c**, keine behaupteten zusätzlichen Nutzerentscheidungen oder endgültigen Regeln einer Onlinewertung. Sie gelten für diese Umsetzung; begründete Änderungen müssen Spezifikation und Tests gemeinsam aktualisieren.

## 1. Bestehende Verträge und Ergebnisübergabe

`RunSession` erzeugt beim logischen Zieleingang genau ein `finished`-Ereignis. `last_result` enthält aktuell `course_identity`, `rule_profile_id`, `duration_usec`, `error_count` und `ranked`, aber **keine dauerhafte Lauf-ID**. `result_count` zählt nur innerhalb einer Session und ist keine global eindeutige ID. Nach Quick Restart kann `last_result` das alte Ergebnis behalten.

Der Szenencontroller übernimmt ausschließlich einen neuen gültigen Abschluss (`FINISHED`, `ranked == true`) in einen unveränderlichen Ergebnisschnappschuss. Er ergänzt einmalig eine über App-Neustarts kollisionsarme `run_id`; Tests können die ID-Erzeugung kontrollieren. Keine ID aus Dauer, Fehlerzahl, Streckenhash oder allein dem Sessionzähler ableiten: zwei echte identische Läufe bleiben zwei Ergebnisse. Die Identität wird weder beim Zeichnen noch bei einem Speicherretry neu erzeugt.

Speicherauftrag, UI und Wiederholungsversuche verwenden denselben Schnappschuss. Bereitschaft, laufende/gesperrte, abgebrochene, menüunterbrochene oder anderweitig nicht wertbare Versuche erzeugen keinen Eintrag. Ein bloß nicht leeres `last_result` ist kein Abschlussereignis. Gültige Resultate bleiben nach anschließendem Escape, Fokusverlust oder Backspace erhalten.

Dateiarbeit bleibt außerhalb von `RunSession` und der Verarbeitung gültiger Bewegungsereignisse. Ergebnis unmittelbar übernehmen, I/O außerhalb des Eingabecallbacks ausführen; keine neue Threadingpflicht im bestehenden Web-Profil. Auch nach sofortigem Restart bleibt der alte Speicherauftrag erhalten. Aufträge serialisieren; verspätete Rückmeldungen dürfen keinen Ergebnisschirm des neuen Versuchs öffnen oder dessen Daten überschreiben. Kein blockierendes Speichern mitten im nächsten aktiven Rennen; einen noch offenen Auftrag außerhalb aktiver Läufe abarbeiten, ohne den ersten Buchstaben zu verschlucken oder künstlich zu verzögern. Bis zum Abschluss bleibt der Speicherstatus ehrlich offen.

## 2. Wertung, Gleichstände und Aufbewahrung

| Gegenstand | Arbeitsfestlegung für P1c |
| --- | --- |
| Ranglistenschlüssel | Unveränderte vollständige `course_identity` aus `CourseIdentity.build(course, profile)`; kein eigener vereinfachter Hash und kein Schlüssel nur aus Kursname oder Profil-ID. |
| Zeit | Originale nichtnegative Integer-Mikrosekunden speichern und numerisch aufsteigend sortieren. Null ist ein gültiger synthetischer Kernfall. Fehlerzahl ist eine Information, kein zusätzlicher Zeitaufschlag. |
| Exakter Gleichstand | Gleiche `duration_usec` erhalten denselben Rang, z. B. `1, 1, 3`. Keine Entscheidung nach Fehlerzahl und keine künstlichen Mikrosekunden. Innerhalb der Gleichstandsgruppe stabile lexikografische `run_id`-Reihenfolge ausschließlich für Darstellung/Aufbewahrung. |
| Persönliche Bestzeit | Kleinste Originalzeit derselben Identität. „Neue Bestzeit“ nur bei strikt kleinerer Dauer gegenüber dem Stand vor Aufnahme; erster gültiger Lauf begründet die erste Bestzeit. Exakter Gleichstand wird als eingestellt gekennzeichnet. |
| Anzeige | Standard `MM:SS.mmm`, ganzzahlig abgeschnitten wie im vorhandenen HUD. Wenn verschiedene Originalzeiten dieselbe Millisekundenanzeige, aber unterschiedliche Ränge haben, den Unterschied im Ergebnisdetail mit der exakten Mikrosekundenzeit nachvollziehbar machen. Keine Präzision vortäuschen oder Rohzeit überschreiben. |
| Aufbewahrung | Die besten **100 Ergebnisse je vollständiger Identität**, einschließlich gleicher Zeiten als einzelne Läufe. Nach derselben stabilen Ordnung begrenzen; auch Gleichstände an der Grenze erweitern das Limit nicht. Keine automatische Löschung anderer Streckenlisten. |
| Ergebnisschirm | Aktueller Lauf mit Zeit/Fehlern, persönliche Bestzeit und kompakte **Top 10**; aktuelles Ergebnis zusätzlich sichtbar, auch außerhalb der Top 10/100. Keine Spielernamenpflicht. |

`course-identity-v1` bindet bereits Graph, relevantes räumliches Layout und vollständige `RuleProfile.identity_data()` einschließlich Fehlerfrist. Eine bloße `rule_profile_id` reicht deshalb nicht. Dasselbe Profil mit anderer Fehlerfrist sowie gleiche Buchstaben/Verbindungen mit anderem relevanten Layout müssen getrennt bleiben. Kosmetische Materialien, Kamera und Besuchsstatus verändern die Identität nicht. Kein Generator und keine Seed-Oberfläche in diesem Paket.

Ein erneut angebotenes identisches Ergebnis mit derselben `run_id` ist wirkungslos; es erzeugt weder Duplikat noch erneuten Bestzeit-Hinweis. Gleiche ID mit widersprüchlichen Daten ist ein Fehler, kein stilles Update. Dies auch nach Laden eines neuen Store-Objekts prüfen. Aufbewahrung ist kein ewiges Archiv verworfener Lauf-IDs: ein bereits aus der Top 100 ausgeschiedenes identisches Resultat darf bei erneutem Angebot die Liste ebenfalls nicht verändern; die deterministische Auswahl muss das ohne unbegrenzt wachsendes Tombstone-Register gewährleisten.

## 3. Dateivertrag und Fehlerverhalten

Der Store liegt unter **`user://parkey-results/results-v1.json`**; Tests setzen vor `_ready` ausschließlich eigene Pfade unter `user://parkey-test-results/...`. Die temporäre Datei heißt `results-v1.json.tmp`, die kurze Wiederanlaufsicherung `results-v1.json.bak`. Version 1 ist ein JSON-Objekt mit numerischem `format_version: 1` und dem Array `entries`. Jeder Eintrag enthält `run_id`, vollständige `course_identity`, `rule_profile_id`, `duration_usec` und `error_count`. Die beiden ganzzahligen Werte sind kanonische nichtnegative **Dezimalstrings**, damit Mikrosekunden auch in JSON-/Web-Laufzeiten verlustfrei bleiben; im Spiel und beim Sortieren sind sie Integer. Nur wertbare Abschlüsse gelangen in das Dokument. Es gibt weder rohe Eingabeprotokolle noch personenbezogene Daten.

`RunIdGenerator` erzeugt die Lauf-ID aus Zeit-, Sitzungszähler- und Zufallsanteil; Tests können feste IDs vorgeben. Sie entsteht einmal beim Zieleingang und wird weder aus Zeit/Hash noch bei Retry, Rendern oder erneutem Laden abgeleitet. `LocalResultStore` prüft Pflichtfelder, Typen, Wertebereiche, vollständige Identitätsform und doppelte IDs vor der Übernahme. Unbekannte Versionen und beschädigte Dokumente bleiben unangetastet. Vor dem Ersetzen schreibt und liest der Store den vollständigen temporären Stand; bei bestehender Primärdatei wird diese nur kurz nach `.bak` verschoben und bei einem Ersetzungsfehler zurückgestellt. Fehlt allein die Primärdatei, kann eine gültige `.bak` wieder geladen werden; eine vorhandene beschädigte Primärdatei wird nicht still durch eine Sicherung ersetzt.

Typen, Pflichtfelder, Wertebereiche und doppelte IDs validieren, bevor geladene Daten in die Rangliste gelangen. Integerwerte müssen im gewählten Format verlustfrei rundreisen. Bei JSON insbesondere Zahlenparser und exakte Wertebereiche berücksichtigen; gebrochene/negative Zeiten, boolesche Ersatzwerte und unzulässige IDs nicht still konvertieren. Größere Originalzeiten und Minutenüberträge testen. Kein allgemeines Migrationsframework und keine stillschweigende Migration unbekannter Formate.

| Speicherlage | Erwartetes Verhalten |
| --- | --- |
| Datei fehlt tatsächlich | Erster Start, regulär leer; normale Neuanlage möglich. |
| Datei beschädigt, trunkiert oder Schema ungültig | Eigener Fehlerstatus mit verständlichem Hinweis. Bestehende Datei erhalten, keine automatische leere Ersatzdatei. Neue Läufe nur temporär, solange kein sicherer Schreibpfad besteht. |
| Unbekannte, insbesondere neuere Formatversion | Nicht überschreiben, nicht auf ein altes Backup zurückstufen und weiterschreiben. Warnung und temporärer Spielbetrieb. |
| Lese-/Zugriffsfehler | Vom fehlenden Speicher unterscheiden; keine Erfolgsmeldung für einen angeblich leeren Store. |
| Schreib-/Ersetzungsfehler | Letzten lesbaren gespeicherten Stand erhalten. Neues Resultat sichtbar als nicht gespeichert behalten; Wiederholung verwendet denselben Schnappschuss/dieselbe ID. |
| Browser ohne verlässlichen dauerhaften Speicher | Spielen und temporäre Ergebnisse ermöglichen; keine Behauptung dauerhafter Speicherung. |

Vorhandene Ergebnisdatei niemals direkt zum Überschreiben öffnen und dadurch vorab leeren. Einen vollständigen neuen Stand zunächst separat schreiben, schließen und validieren; erst dann mit einem für die Zielplattform geprüften Ersetzungsverfahren übernehmen. Fehler bei Öffnen, Schreiben, Prüfung und Ersetzen getrennt prüfen. Falls dafür eine Sicherung nötig ist, deren Wiederanlaufverhalten klein und eindeutig dokumentieren. Ein abgebrochener Schreibvorgang muss wenigstens den letzten gültigen Stand lesbar lassen; temporäre Reste sind keine automatisch gültigen Ergebnisse. Keine plattformübergreifende Stromausfallsicherheit behaupten.

Speicherzustand und Rennwertung sind getrennt: ein gültig beendeter Lauf wird bei Speicherfehler nicht nachträglich ungültig. Dauerhaft vorhandene und nur temporär vorhandene Ergebnisse/Bestzeiten bleiben erkennbar; ein gescheiterter Schreibversuch darf nicht als neue dauerhaft gespeicherte Bestzeit erscheinen. Ein normaler Lauf außerhalb der Top 100 ist erfolgreich abgeschlossen, aber bewusst nicht aufbewahrt; dies nicht als Schreibfehler oder als gespeicherten Listeneintrag ausgeben.

## 4. UI und Browsergrenzen

Während eines aktiven Rennens bleiben Timer und Strecke frei von einer großen Ranglistentabelle. Nach Ziel darf ein kompaktes Ergebnispanel erscheinen. Backspace bereitet unmittelbar denselben Kurs vor; keine Bestätigungs-, Enter- oder Countdownpflicht. Escape bleibt getrennt. Texteingaben und fokussierte Controls behalten ihren GUI-Vorrang, Buttons dürfen keine zweite Verarbeitung derselben Taste auslösen. Den echten Ergebnis→Restart→nächster Buchstabe-Pfad testen, einschließlich schneller Folgen und ausstehender Speicherantwort.

Der Web-Speicher gehört zum verwendeten Browserprofil und zur Origin. Reload und erneutes Öffnen müssen im **tatsächlichen Export** geprüft werden; ein Erfolg von `FileAccess` oder `OS.is_userfs_persistent()` allein belegt keine überdauernde Speicherung. UI-Status darf nur die tatsächlich beobachtbare Speicherstufe zusagen; wenn die gepinnte Laufzeit keinen sicheren Abschlussnachweis bietet, entsprechend vorsichtig formulieren. Browserdatenlöschung und privater/eingeschränkter Speicher können Ergebnisse verlieren. Windows und Web synchronisieren nicht.

Die verschobene physische Chrome-Tastaturabnahme aus P1b bleibt als solche offen. Sie ist **keine pauschale Befreiung von den neuen P1c-Browserpersistenztests**. Firefox bleibt P4; P1c verlangt einen dokumentierten Desktop-Chrome-Lauf. Kein Hosting, PWA-Ausbau oder zweiter JavaScript-Spielkern. Die lokale Spiellogik braucht keinen Dienst; das initiale Ausliefern des Webpakets über HTTP(S) ist davon getrennt.

## 5. Konkrete Abnahme

`storage` ist im bestehenden GDScript-Runner und in `all` aufgenommen. Es verwendet echte temporäre Dateien und injiziert Lese-, Schreib- und Ersetzungsfehler, weil etwa ein privilegierter Testlauf fehlende Rechte umgehen kann. **Alle** Szenen- und Integrationsprüfungen setzen vor `_ready` eine isolierte Testablage; Benutzerbestzeiten werden weder gelesen noch verändert oder bereinigt. Die Szenenintegration erzeugt den Schnappschuss im Zieleingabepfad, verschiebt Datei-I/O in `_process` und arbeitet offene Aufträge nur außerhalb eines aktiven Laufs ab. Nach einem Schreibfehler bleibt derselbe Schnappschuss mit derselben ID für den späteren Retry erhalten.

| Prüfgruppe | Mindestnachweis |
| --- | --- |
| Abschlussintegration | Vollständiger Lauf über echte Spielszene und Viewport-Eingaben, danach neuen Store laden: genau ein unverändertes Ergebnis. Zweiter echter Lauf mit gleichen Daten hat eine andere ID. |
| Zustandstrennung | Abschluss→Restart ohne Renderframe, verspätetes Speichern, doppelter UI-Aufruf, wiederholter Save, Fokus/Escape nach Ziel; alte Rückmeldung überschreibt keinen neuen Lauf. Bereitschaft, Abbruch und Menüunterbrechung erzeugen keine Resultate. |
| Identität | Gleicher Graph bei relevanter Layoutvariation in getrennten gespeicherten Listen; reine Materialvariation gemeinsam. Gleiche Profil-ID bei geänderter Fehlerfrist ebenfalls getrennt. Vorhandenen Hashvertrag benutzen. |
| Zeit und Auswahl | Numerische statt Stringsortierung, Null, Minutenübertrag, Mikrosekundenrundreise, exakte Gleichstände, unterschiedliche Rohzeiten mit gleicher Millisekundenanzeige, Top 10/100 sowie 101. Eintrag und Gleichstand an der Grenze. |
| Fehlpfade | Fehlende/kaputte/trunkierte Datei, falsche Typen, doppelte/widersprüchliche IDs, unbekannte Version, Lese-/Schreib-/Ersetzungsfehler, abgebrochener Schreibvorgang. Alter gültiger Stand bleibt nach erneutem Öffnen lesbar. |
| Windows-Export | Lauf abschließen, Speicherstatus prüfen, App schließen und neu starten: Bestzeit/Liste unverändert. Ergebnis außerhalb Top 10 und unmittelbaren Restart prüfen. |
| Web-Export | Über HTTP gleiche Origin und dasselbe Profil: Abschluss→Reload sowie Tab schließen→erneut öffnen; erhaltenes Ergebnis und keine Duplikate. Eingeschränkten Speicherfall mit ehrlicher temporärer Anzeige prüfen. Zeitpunkt/Umstände eines Reloads bei noch offenem Speichern dokumentieren. |

Der Implementierungsstand erfüllt die automatisierten Abnahmetabellen mit `storage` (57 Assertions), `integration` (212) und `all` (430). Der Release-Nachweis auf Windows 11 Pro / Godot 4.7.2 umfasst einen nativen Abschluss und Neustart mit unveränderter Datei. Der Chrome-Release lief über HTTP unter gleicher Origin mit zwei erhaltenen unterschiedlichen IDs über Reload sowie Tab-Schließen/Neuöffnen. Eine Chrome-Konfiguration mit blockierter Site-Datenspeicherung ergab den erwarteten IndexedDB-Zugriffsfehler und keinen dauerhaften Ergebniseintrag; die temporäre Resultatmeldung ist zusätzlich in der echten Szenenintegration abgedeckt. Details und verbleibende manuelle Sichtabnahme stehen in [testing.md](testing.md).

Pflichtbefehle stehen in [testing.md](testing.md): Import, `storage`, `integration`, `all` und beide Release-Exporte. Unbekannte/leere Suites bleiben Fehler. Plattformnachweise nennen Commit, Engine, OS/Browser, Origin bzw. Speicherpfad, Schritte und Ergebnis. Fehlende Review-/Abnahme lässt den Implementierungs-PR Draft.

## 6. Technische Quellen und Umfang

Primärdokumentation geprüft am **2026-09-06**; bewegliche `stable`-Seiten bei der Umsetzung gegen den vorhandenen Pin aus `godot-version.txt` abgleichen. Kein Engine-Upgrade beauftragt.

- [Web-Persistenz und Grenzen von `is_userfs_persistent`](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#using-cookies-for-data-persistence)
- [FileAccess: Öffnungsmodi, Fehler und Schreiben](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html)
- [JSON: Parsing und Zahlenrepräsentation](https://docs.godotengine.org/en/stable/classes/class_json.html)

Nicht enthalten: Onlinewertung, Login, Cloud-Sync, Anti-Cheat, Import-/Exportoberfläche für Ergebnisse, universelle Migration, Mehrinstanzen-Synchronisierung, Generator, Kamera-/Beschriftungsumbau oder finale Grafik. Die D-023/D-024-Folgearbeit bleibt P2a / #5. Kleine erforderliche Integrationskorrekturen mit Regressionstest sind erlaubt; P1-Bewegungsregeln und Identität nicht aus Bequemlichkeit ändern.
