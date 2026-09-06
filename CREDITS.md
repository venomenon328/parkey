# Assetquellen und Credits

Stand/Prüfung: 2026-09-06. P2b / Issue #6 legt **keine Projektlizenz** fest.

| Bestandteil | Herkunft | Lizenz / Verwendung |
| --- | --- | --- |
| Kappen, Sockel, Legendenplatzierung, rein visueller Hub | Eigene parametrisierte Meshes in `keycap_visual.gd` und `playable_course_scene.gd` | Im Auftrag für dieses Repository erstellt; keine Fremdmodelle. |
| Figur, Kleidung, Haar und Posen | Eigene Mesh-Komposition in `runner_visual.gd` | Keine fremden Charakter-/Animationspakete. |
| Werkstatt, Möbel, Regale, Drehknöpfe, Kabel, Pflanzen und Portal | Eigene Geometrie in `workshop_world.gd` | Keine Assetstore- oder Fremdspielmodelle. |
| Kunststoff-/Matten-Mikrostruktur und Werkstatt-Dielenboden | Eigene deterministische Farb-/Rauheits-/Normaltexturen, Godot FastNoiseLite | Keine externen Materialtexturen. |
| HUD, Ergebnisliste und Stoppuhr | Eigener UI-/Vektorcode | Der Nutzer-Mock ist nur Gestaltungsreferenz, kein Runtime-Asset. |
| Barlow Medium: Keycap-Legenden und UI | [Google Fonts / Barlow](https://github.com/google/fonts/tree/main/ofl/barlow), unveränderte `Barlow-Medium.ttf` | © 2017 The Barlow Project Authors ([Originalprojekt](https://github.com/jpt/barlow)), SIL OFL 1.1. Versionierte [Lizenz](assets/fonts/OFL.txt). |
| Barlow Semi Condensed SemiBold: Timer, Ergebniszeiten, Weltbeschriftung | [Google Fonts / Barlow Semi Condensed](https://github.com/google/fonts/tree/main/ofl/barlowsemicondensed), unveränderte `BarlowSemiCondensed-SemiBold.ttf` | Dieselben Autoren und SIL OFL 1.1; keine künstliche Schriftverfettung. |
| Kloofendal 48d Partly Cloudy (Pure Sky), 2048×1024 HDR | [Poly Haven](https://polyhaven.com/a/kloofendal_48d_partly_cloudy_puresky); Greg Zaal (Original), Jarod Guest (Sky Edits) | [CC0](https://polyhaven.com/license), versionierter [Lizenztext](assets/environment/CC0-1.0.txt). Unveränderte HDR-Datei; `atelier_sky.gdshader` hebt die abgetastete Wolkenhemisphäre für die schwebende Werkstatt an und konvertiert die lineare HDR-Ausgabe im Compatibility-Profil nach sRGB. |
| Godot Engine 4.7.2 und eingebettete Fallback-Schriften | Bestehende gepinnte Engine | [Godot-Lizenz und Drittanbieterhinweise](https://godotengine.org/license/), Engine unter MIT. `Engine.get_copyright_info()` / `Engine.get_license_info()` liefern die vollständigen eingebetteten Hinweise. |

Downloads: [Barlow Medium](https://raw.githubusercontent.com/google/fonts/main/ofl/barlow/Barlow-Medium.ttf), [Barlow Semi Condensed SemiBold](https://raw.githubusercontent.com/google/fonts/main/ofl/barlowsemicondensed/BarlowSemiCondensed-SemiBold.ttf), [Himmel 2K HDR](https://dl.polyhaven.org/file/ph-assets/HDRIs/hdr/2k/kloofendal_48d_partly_cloudy_puresky_2k.hdr). SHA-256 und Dateigrößen stehen im [Quellmanifest](docs/evidence/p2b/source-manifest.json). Alle drei Assets sind lokal versioniert und benötigen im Spiel kein Netzwerk. Die kleinen statischen OFL-Schriften ersetzen die bisherige Fallback-Abhängigkeit; das 2K-HDR ersetzt die Laufzeit-Wolkenberechnung in beiden Profilen. Keine neue Laufzeitbibliothek, kein Dienst und keine KI-Bitmapassets.

Die Export-Presets nehmen diese Credits sowie OFL-/CC0-Lizenztexte mit ins Paket auf. Der vorhandene Engine-Fallback Open Sans SemiBold (© 2020 The Open Sans Project Authors, OFL 1.1) kann weiterhin für technische/ältere Diagnosen verwendet werden; [Original-Lizenz](https://github.com/godotengine/godot/blob/master/thirdparty/fonts/LICENSE.OpenSans.txt). Vor öffentlicher Verteilung die vollständigen Engine-/Drittanbieterhinweise und die dann ausdrücklich festgelegte Projektlizenz beilegen.
