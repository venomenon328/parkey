# Spieldesign

Stand: 2026-09-05. Verbindlichkeit und Status aller Festlegungen stehen im [Entscheidungsregister](decisions.md). Die folgenden Detailregeln sind, soweit nicht durch D-001 bis D-013 abgedeckt, vorgeschlagene PoC-Regeln.

## Spielkern

Parkey verbindet räumliches Lesen, Routenentscheidung und präzises Tippen. Der Spieler erkennt erreichbare Buchstabenfelder, wählt einen Weg und setzt ihn unmittelbar in Bewegung um. Wiederholungen sollen bessere Linien, flüssigere Eingaben und persönliche Bestzeiten ermöglichen.

Die im Gespräch gezeigte Bildreferenz dient als visuelle Orientierung: große plastische Tastenkappen, kleine Figur, warme Materialien und eine übersichtliche 3D-Welt. Sie ist keine verbindliche Kameraposition und legt weder die Figur noch alle Materialien endgültig fest. Die Bilddatei selbst ist nicht Bestandteil des Repositorys.

## Bewegung und Eingabe

Vorgeschlagener Eingabeumfang für P1: A–Z, normalisierte Großschreibung und beidseitige Verbindungen. Die Strecke verwendet explizite Nachbarschaften, keine festen Richtungsslots. Orthogonale und schräg angeordnete Übergänge sind möglich, sofern ihre Erreichbarkeit eindeutig ist; es gibt keinen allgemeinen Raster- oder festen Nachbarzahlzwang (D-010/D-011). Für jeden akzeptierten Tastendruck wird gegen die aktuelle **logische** Position geprüft. Gültige Eingaben können mehrere aufeinanderfolgende Schritte auslösen, bevor das nächste Bild gezeichnet wird. Es gibt keinen Schritt-Cooldown für korrektes Tippen.

Die sichtbare Figur folgt diesem Verlauf ohne stetig anwachsenden Rückstand. Sie darf Animationen verkürzen oder zusammenführen, statt jeden alten Einzelschritt vollständig nachzuspielen. Die Rückmeldung für das aktuelle Feld muss zur logisch gültigen Nachbarschaft passen. Bei hoher Geschwindigkeit ist diese Konsistenz wichtiger als eine vollständige Schrittanimation. Auch unterschiedlich große Felder zählen pro gültigem Übergang genau einen Eingabeschritt. Feldgröße und Entfernung dürfen keine zusätzliche Laufzeit, Eingabe oder Sperre erzwingen. Die Darstellung verkürzt/verdichtet nötigenfalls Bewegungen entlang des gewählten Wegs, statt das Tippen zu drosseln (D-012).

Ein gültiger Buchstabe auf der unerwünschten Route ist eine Abzweigung, kein vom Spiel erkennbarer Tippfehler. Rückwärtsgehen ist im vorgeschlagenen Anfangsmodell möglich. Es gibt keine automatische Rücknahme einer subjektiv falschen Entscheidung.

Automatische Tastenwiederholung durch Gedrückthalten löst keine Schritte aus. Überlappende echte Tastendrücke bleiben erlaubt; der Spieler muss nicht vor jeder Eingabe alle Tasten loslassen. Reine Modifier- und UI-Eingaben sind keine falschen Bewegungsbuchstaben. Für Neustart und Menü dürfen keine normalen A–Z-Eingaben ohne eindeutigen Kontext zweckentfremdet werden.

## Fehlerpause

Bestätigt ist eine kurze Bewegungssperre. Der vorläufige Wert steht unter T-001, die optionale Kopfschüttelrückmeldung unter T-002. Vorgeschlagene Detailsemantik:

1. Im laufenden Zustand löst ein Bewegungsbuchstabe ohne gültiges Nachbarziel einen Fehler aus. Das aktuelle Feld bleibt unverändert; ein Fehler wird gezählt und eine feste Sperrfrist beginnt.
2. Während der Sperre werden Bewegungsversuche ignoriert: kein Puffern, kein nachträglicher automatischer Schritt, keine zusätzlichen Fehlerzählungen und kein Neustart der Sperrfrist.
3. Der Renntimer läuft weiter. Der reale Stillstand ist die Strafe; es wird nicht noch einmal derselbe Betrag auf die Ergebniszeit addiert.
4. Die erste neue Eingabe ab Ende der Sperrfrist wird normal geprüft, ohne auf ein Animationsende oder einen späteren Physiktick zu warten. Ein dann neuer Fehler kann eine neue Sperre auslösen.
5. Neustart, Menü und erforderliche UI-Reaktionen dürfen weiterhin funktionieren. Nicht die gesamte Engine oder Zeitmessung pausieren.

Die sichtbare Figur soll während der Sperre stillstehen bzw. den Kopf schütteln, nicht vorher gepufferte Vorwärtsschritte abarbeiten. Der Übergang von einer eventuell nachlaufenden Darstellung zum unveränderten logischen Feld wird gezielt getestet. Die Fehlerdarstellung darf weder einen anderen vermeintlichen Standort suggerieren noch einen zusätzlichen Stillstand nach Ablauf der Frist erzwingen.

Zu testen ist insbesondere, ob verworfene Eingaben unmittelbar vor Sperrende nachvollziehbar wirken. Ein eventueller begrenzter Eingabepuffer wäre eine neue, ausdrücklich zu dokumentierende Regel, keine unbemerkte Komfortänderung.

## Start, Ziel und Ergebnis

Vorgeschlagen: explizites Bereitmachen und ein kurzer Countdown. Ab dem Startsignal läuft die Zeit; Countdown-Eingaben bewegen die Figur nicht. Die Zielzeit entsteht bei der gültigen Eingabe zum Zielfeld und wird genau einmal gespeichert. Eine anschließende Zielanimation verändert sie nicht.

Der Timer zeigt während des Rennens durchgehend Minuten, Sekunden und drei Nachkommastellen. Anzeigeauflösung ist nicht mit identischer realer Eingabelatenz auf jedem Gerät gleichzusetzen. Zeitmessung und Sortierung verwenden numerische Zeitwerte, keine formatierten Zeichenketten.

Erste Ranglisten sind lokal und gelten jeweils für dieselbe Strecken- und Regelidentität. Fokusverlust, Abbruch oder ein für Trainingszwecke pausierter Lauf erzeugen nach dem vorgeschlagenen Modell keinen gewerteten Abschluss. Detailregeln für Zeitgleichstände werden vor einer Onlinewertung festgelegt.

## Kamera und Lesbarkeit

Die vorgeschlagene Kamera ist erhöht, nach unten geneigt und automatisch geführt. Die Figur und das aktuelle Feld bleiben sichtbar; an Kreuzungen werden beide Optionen rechtzeitig erkennbar. Keine notwendigen Mausbewegungen und keine abrupten Kamerasprünge bei jedem Richtungswechsel.

Erreichbare Nachbarfelder erhalten eine zurückhaltende, nicht ausschließlich farbliche Markierung. Buchstaben müssen auch im Web-Profil sowie ohne teure Effekte lesbar bleiben. Schatten, die Figur, Schärfentiefe und die Benutzeroberfläche dürfen sie nicht verdecken. Gegebenenfalls helfen dezente zusätzliche Buchstabenanzeigen.

Während des Laufs genügen Timer, persönliche Bestzeit und Fehlerfeedback. Die ausführliche Rangliste erscheint vorzugsweise nach dem Lauf. Pflichtinformationen dürfen nicht allein durch Windows-exklusive Grafikmerkmale vermittelt werden.

## Strecken und Generation

### Feldgeometrie und erkennbare Übergänge

Das endgültige Streckendesign darf unregelmäßig sein: variable Grundformen, Ausrichtungen, Anordnungen, moderate Größenunterschiede und wechselnde Nachbarzahlen statt bloß eines anderen regelmäßigen Vierer-/Sechser-/Achterrasters. Übermäßig große Felder sind nicht das Ziel. Übersichtliche Passagen und markante Entscheidungspunkte bleiben wichtiger als möglichst viel Zufall. Eine größere Fläche darf beispielsweise entlang eines Randes mehrere kleinere Nachbarn haben; nicht jedes Feld muss gleich viele Ausgänge besitzen.

Ein deutlich erkennbarer gemeinsamer Randabschnitt kann einen direkten Übergang bilden; dafür muss nicht eine vollständige Feldseite übereinstimmen. Bloße Eckberührung, diagonale Lage im gedachten Raster oder optische Nähe allein erzeugen keinen Übergang. Kleine Fugen sind als konsistentes Gestaltungsmittel möglich, wenn die Begehbarkeit trotzdem klar ist. Sichtbar begehbare Anschlüsse und gespeicherte Verbindungen müssen übereinstimmen; keine unsichtbaren Verbote und keine willkürlichen Fernverbindungen. Größere Sprünge, gesonderte Brückenmechaniken oder Höhenparcours sind damit nicht beschlossen.

Verbindungen werden beim Erstellen/Validieren festgelegt und im Rennen nicht anhand wechselnder Mesh-Kontakte neu erraten. Alle tatsächlich erreichbaren Nachbarn brauchen verschiedene Buchstaben; aus dem verwendeten Alphabet ergibt sich eine sachliche Grenze, aber keine feste Produktvorgabe von vier, sechs oder acht Nachbarn. Ein einzelner Abschnitt darf aus Gründen der Lesbarkeit weniger Optionen haben.

Für die sichtbare Figur ist ein geeigneter Stand-/Landepunkt innerhalb jedes Felds und ein plausibler Übergangsverlauf vorzusehen. Unterschiedliche Größen ändern die Zahl der nötigen Eingaben pro Übergang nicht. Optisch längere Wege können deshalb weniger Felder haben; die Unterteilung und ersten Optionen müssen vor einer Entscheidung lesbar sein. Größe, Distanz und Animation dürfen den logischen Fortschritt niemals durch Mindestbewegungszeiten verzögern. Konkrete Größen- und Anschlussgrenzen werden an Beispielen geprüft, nicht hier numerisch vorweggenommen.

### PoC und Generierung

Frühe Handstrecken dürfen einfach sein, ohne den gemeinsamen Kern auf dieses Layout festzulegen. P1a prüft die allgemeine Nachbarschaft unter anderem mit fünf eindeutig beschrifteten Nachbarn; P1b enthält mindestens eine überschaubare unregelmäßige Stelle mit moderat verschiedenen Größen und einem klar lesbaren nicht rechtwinkligen Übergang. Dafür genügen wenige einfache Feldformen; ein beliebiger Polygon-Generator ist noch nicht nötig.

Zunächst werden bewusst entworfene Abschnitte geprüft: flüssiger Korridor, gut einsehbare Gabelung, kurze schwierige Route gegen längere flüssige Route und ein gemeinsames Finale. Alternativwege sollen im ersten Test überwiegend wieder zusammenführen. Sackgassen, Schleifen, Sprünge und Sonderfelder sind keine Pflicht für den ersten PoC.

Eine Routenwahl braucht vorab genügend Information über Verlauf und erste Buchstabensequenzen. Die Länge allein ist nicht die Schwierigkeit: Die Tippbarkeit einer Folge hängt unter anderem von Layout, Eingabemethode und Spielerfahrung ab. Ein anfängliches QWERTZ-Modell ist eine zu prüfende Hypothese, keine allgemeingültige Bewertung menschlichen Tippens.

Die Eindeutigkeitsprüfung betrachtet immer die ganze erreichbare Nachbarschaft. Bereits **A–B–A** ist bei beidseitigen Verbindungen vom mittleren B aus ungültig. An Gabelungen und Zusammenführungen gilt dieselbe Regel. Sichtbare Anordnung und erlaubte Verbindungen müssen übereinstimmen; keine unsichtbaren Verbote zwischen scheinbar begehbaren Nachbarfeldern.

Der spätere Generator kombiniert geprüfte Abschnittstypen und variiert Topologie, räumliche Anordnung und Beschriftung kontrolliert. Er prüft Zielerreichbarkeit, eindeutige Nachbarschaften, beabsichtigte Verbindungen und brauchbare Alternativen. Die beste Route darf vom Können des Spielers abhängen; sie muss nicht für jeden Menschen dieselbe sein.

### Streckenidentität

Die räumliche Gestaltung beeinflusst das Lesen und die Routenwahl und ist deshalb nicht pauschal Kosmetik. Bei gleichen Buchstaben und Verbindungen, aber anderen relativen Positionen, Grundflächen, Größen, Ausrichtungen oder Übergängen ist die Streckenidentität entsprechend anzupassen. Reine Materialwechsel, Oberflächendetails und nicht spielrelevante Dekoration verändern sie dagegen nicht. Die Trennung gilt bereits für handgebaute Strecken und wird beim Generator fortgeführt; eine andere Identität ist kein Anlass für eine andere Eingabe- oder Zeitregel.

## Bewusst später

Eigener Bestzeit-Ghost, geteilte Seeds, Tagesparcours und Abschnittstraining bleiben Erweiterungsideen. Onlinekonten, Echtzeit-Mehrspieler, Inventar, Power-ups, Ausdauer und Geschwindigkeitsboni gehören nicht zum vorgeschlagenen ersten PoC.
