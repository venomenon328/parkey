# Assetquellen und Credits

Stand/Prüfung: 2026-09-06. P2b / Issue #6 legt **keine Projektlizenz** fest.

| Bestandteil | Herkunft | Lizenz / Hinweis |
| --- | --- | --- |
| Keycaps, Sockel, Fasen, Press-Reaktion | Eigene parametrisierte Meshes in `scripts/presentation/keycap_visual.gd` und `scripts/playable_course_scene.gd` | Im Auftrag für dieses Repository erstellt; keine Fremdmodelle. Projektlizenz weiterhin offen. |
| Menschliche Figur, Kleidung, Haar, Gesicht und Gliedmaßen; Idle/Bewegung/Reaktion | Eigene Mesh-Komposition und Posen in `scripts/presentation/runner_visual.gd` | Keine übernommenen Charaktere, Motion-Capture-Daten oder Animationspakete. Projektlizenz offen. |
| Werkbank, Matte, Messingdetails, Leuchten, Spulen, Schalterablagen, Start/Ziel, Himmel | Eigene Geometrie/Materialparameter in `scripts/presentation/workshop_world.gd` | Keine Texturen/HDRIs/Modelle fremder Spiele oder Assetstores. Projektlizenz offen. |
| Kunststoff-Mikrostruktur | Eigene deterministische 64×64-Rauheitstextur, zur Laufzeit aufgebaut | Kein externer Download, keine Zufallsabhängigkeit der Streckenidentität. |
| HUD, Ergebnisgestaltung | Eigener Szenen-/UI-Code in `workshop_hud.gd` | Nutzer-Mock nur qualitative Orientierung; kein Bildasset daraus übernommen. |
| Nichtfarbliche Statuszeichen | Eigene Punkt-/Haken-/Rautengeometrie in `scripts/presentation/keycap_status.gd` | Keine zusätzliche Symbolschrift oder Fremdgrafik; unabhängig vom Schrift-Fallback. |
| Godot Engine 4.7.2, PrimitiveMesh/SurfaceTool und Standardschrift | Bestehende gepinnte Engine | [Godot-Lizenz und Drittanbieterhinweise](https://godotengine.org/license/), MIT für die Engine; kein neuer Engine-/Paketdownload. |
| Standardschrift **Open Sans SemiBold** | In der gepinnten Laufzeit durch `ThemeDB.fallback_font.get_font_name()` festgestellt | © 2020 The Open Sans Project Authors, SIL Open Font License 1.1; [Original-Lizenz](https://github.com/godotengine/godot/blob/master/thirdparty/fonts/LICENSE.OpenSans.txt). Die Originalschrift wird über Godot benutzt, nicht verändert oder separat importiert. |

Die tatsächliche Engine meldet ihre vollständigen eingebetteten Drittanbieter-Credits über `Engine.get_copyright_info()` und Lizenztexte über `Engine.get_license_info()`. Darin sind auch mögliche Sprach-Fallbacks enthalten: DroidSans (© 2008 The Android Open Source Project, Apache 2.0), Inter (© 2016 The Inter Project Authors, OFL 1.1), Noto Sans (© 2012 Google Inc., OFL 1.1), JetBrains Mono (© 2020 JetBrains s.r.o., OFL 1.1) und Vazirmatn (© 2015 The Vazirmatn Project Authors, OFL 1.1). [Godot-Drittanbieterregister](https://github.com/godotengine/godot/blob/master/COPYRIGHT.txt). Vor einer späteren öffentlichen Paketverteilung diese Engine-/Schrifthinweise zusammen mit der dann ausdrücklich festgelegten Projektlizenz mitliefern.

Keine neuen Laufzeitabhängigkeiten, Audioassets, KI-Bitmapassets oder erforderlichen Assetstore-Credits. Der optionale lokale Web-Prüfserver verwendet nur Node-24-Bordmittel und ist kein Spielservice.
