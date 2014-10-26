local L = LibStub("AceLocale-3.0"):NewLocale("PrioRunes", "deDE")
if not L then return end

-- Configuration
L["PrioRunes"] = true

-- Chat Command open config
L["Config"] = true 
L["Opens PrioRunes config."] = "Öffnet die Konfiguration."	

-- General
L["General"] = true
L["Enable"] = "Eingeschaltet"
L["Enables / Disables rune bar."] = "Aktiviert / Deaktiviert das AddOn."
L["Hide Blizzard Runes"] = "Verstecke Blizzard Runen"
L["Enables / Disables default Rune Frames."] = "Aktiviert / Deaktiviert die standart Runen Anzeige."
L["Lock Frame"] = "Fenster Sperren"
L["Locks / Unlocks the Frames."] = "Sperrt / Entsperrt die Fenster."
L["Only in Combat"] = "Nur im Kampf"
L["Disables the bar while not in combat."] = "Deaktiviert das AddOn außerhalb vom Kampf."
L["Update Sequence"] = "Update Frequenz"
L["Lower for smoother updating bars. WARNING: Your framerate could be drastically decreased if you enter too small numbers. If you can't start the game because of this, delete PrioRunes.lua, located in your SavedVariables."] = "Je niedriger, desto fließender updaten die Runen. ACHTUNG: Zu kleine Werte können Auswirkungen auf deine Framerate haben. Wenn dein Spiel dadurch nichtmehr startet, lösche PrioRune.lua in deinen SavedVariables."
L["Reset Settings"] = "Einstellungen zurücksetzen."
L["Resets all user given settings."] = "Setzt all deine Einstellungen auf die Standart-Einstellungen zurück."
L["Are you sure you want to reset ALL the settings you've made?"] = "Bist du dir sicher, dass du all deine Einstellungen zurücksetzen möchtest?"

-- Bar Settings
L["Media Settings"] = true
L["Texture"] = "Texturen"
L["Select a bar texture."] = "Wähle eine Leisten-Textur."
L["Backdrop Alpha"] = "Hintergrund Alpha"
L["Set the Backdrop Alpha of the Runes and the Powerbar."] = "Verändert das Hintergrund Alpha der Runen und der Runenmacht-Leiste."
L["Font Settings"] = "Schrift-Einstellungen"
L["Show Text"] = "Text anzeigen."
L["Shows / Hides the Cooldown Timer."] = "Zeigt / Versteckt die Abklingzeit der Runen."
L["Font"] = "Schriftart"
L["Select a font"] = "Wähle eine Schriftart."
L["Font Outline"] = "Outline"
L["Enables / Disables Font Outline."] = "Aktiviert / Deaktiviert Outlines."
L["Font Size"] = "Schriftgröße"
L["Set font size."] = "Verändert die Schriftgröße."

-- Rune Settings
L["Rune Settings"] = true
L["Enable / Disable Rune Bars."] = "Aktiviert / Deaktiviert Runen Leisten."
L["Height"] = "Höhe"
L["Set Height of the rune bars."] = "Verändert die Höhe der Runen."
L["Width"] = "Breite"
L["Set Width of each rune bar."] = "Verändert die Breite der Runen."
L["Show Decimal"] = "Nachkommastellen"
L["Color Settings"] = "Farb-Einstellungen"
L["Blood Rune Color"] = "Blut-Runen Farbe"
L["Customize rune colors."] = "Verändert die Farbe deiner Runen."
L["Unholy Rune Color"] = "Unheilig-Runen Farbe"
L["Frost Rune Color"] = "Frost-Runen Farbe"
L["Death Rune Color"] = "Todes-Runen Farbe"
L["Customize rune colors."] = "Verändert die Farbe deiner Runen."
L["Reset Colors"] = "Farben zurücksetzen"
L["Resets colors to their defaults."] = "Setzt die Farben auf ihre Ausgangswerte zurück."
L["Order Settings"] = "Reihenfolge"
L["Blood Runes"] = "Blut-Runen"
L["Frost Runes"] = "Frost-Runen"
L["Unholy Runes"] = "Unheilig-Runen"
L["1 = Left, 2 = Middle, 3 = Right."] = "1 = Links, 2 = Mitte, 3 = Rechts"

-- Runic Power Bar Settings
L["Power Bar"] = true
L["Enable / Disable Runic Power Bar."] = "Aktiviert / Deaktiviert Runenmacht Leiste."
L["Snap to Runes"] = "An Runen Leiste"
L["Snap powerbar to runeframe."] = "Runenmacht Leiste an den Runen ausrichten."
L["Set Width of the Runic Power bar."] = "Verändert die Breite der Runenmacht Leiste."
L["Set Height of the Runic Power bar."] = "Verändert die Höhe der Runenmacht Leiste."
L["Rune Power Text"] = "Runenmacht Text"
L["Enables / Disables Rune Power Text."] = "Aktiviert / Deaktiviert den Runenmacht Text."
L["Show Max Runic Power"] = "Zeige Maximale Runenmacht"
L["Enables / Disables Max Runic Power."] = "Aktiviert / Deaktiviert die maximale Runenmacht."
L["Show Indicators"] = "Zeige Indikator"
L["Toggle an indicator for Rune Strike, Frost Strike and Deathcoil."] = "Zeigt / Versteckt einen Anzeiger für Runenstoß, Froststoß und Todesmantel."
L["Runic Power Bar"] = "Runenmacht Leiste"
L["Customize Runic Power colors."] = "Verändert die Farbe deiner Runenmacht Leiste."

-- Positioning Settings
L["Positioning"] = true
L["Manually change the frame positions"] = "Verändere die Positionen der Fenster manuell."
L["Main Frame x"] = "Hauptfenster x"
L["Power Frame x"] = "Runenmacht x"
L["Main Frame y"] = "Hauptfenster y"
L["Rune Frame y"] = "Runenmacht y"