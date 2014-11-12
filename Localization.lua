------------------------------------------------------
-- Localization.lua
-- English strings by default, localizations override with their own.
------------------------------------------------------
--

-- Rewritten by GopherYerguns from the original Status Bars by Wesslen. Mist of Pandaria updates by ???? on Wow Interface (integrated with permission) and EricTheDad

local addonName, addonTable = ... --Pulls back the Addon-Local Variables and stores them locally

local L =
{
	INTERFACEPANEL_CREDITS_TEXT_1 = "Original Addon by Wesslen",
	INTERFACEPANEL_CREDITS_TEXT_2 = "Version 2 rewrite by GopherYerguns",
	INTERFACEPANEL_CREDITS_TEXT_3 = "Mists of Pandaria updates by 堂吉先生 and EricTheDad",
	INTERFACEPANEL_CREDITS_TEXT_4 = "Warlords of Draenor update and ongoing maintenance by EricTheDad",
	INTERFACEPANEL_CREDITS_TEXT_5 = "Translations provided by:",
	INTERFACEPANEL_CREDITS_TEXT_6 = "deDE: EricTheDad\nfrFR: available\nitIT: available\nesES: available\nesMX: available\nptBR: available\nruRU: available\nzhCN: available\nkoKR: available\nzhTW: available",
	INTERFACEPANEL_HELP_TEXT_1 = "Show this screen by typing \"/statusbars2\" or \"/sb2\" in the chat input.",
	INTERFACEPANEL_HELP_TEXT_2 = "Enable configuration mode by typing in \"/statusbars2 config\" or \"/sb2 config\" or by clicking the button below.",
	INTERFACEPANEL_TRANSLATORS_NEEDED = "Translators needed!  Go to http://wow.curseforge.com/addons/statusbars2/localization or message EricTheDad if you'd like to help!",
}

local addonName, addonTable = ...; -- Let's use the private table passed to every .lua file to store our locale
---[[
local function defaultFunc(L, key)
 -- If this function was called, we have no localization for this key.
 -- We could complain loudly to allow localizers to see the error of their ways, 
 -- but, for now, just return the key as its own localization. This allows you to 
 -- avoid writing the default localization out explicitly.
 return key;
end
setmetatable(L, {__index=defaultFunc});
--]]

addonTable.strings = L;

print(GetLocale())
------------------------------------------------------

if (GetLocale() == "deDE") then

L["INTERFACEPANEL_CREDITS_TEXT_1"] = "Ursprüngliches Addon von Wesslen" -- Needs review
L["INTERFACEPANEL_CREDITS_TEXT_2"] = "Version 2 Umschreibung von GopherYerguns" -- Needs review
L["INTERFACEPANEL_CREDITS_TEXT_3"] = "Mists of Pandaria Neufassung von 堂吉先生 und EricTheDad" -- Needs review
L["INTERFACEPANEL_CREDITS_TEXT_4"] = "Warlords of Draenor Neufassung und laufende Wartung von EricTheDad" -- Needs review
L["INTERFACEPANEL_CREDITS_TEXT_5"] = "Übersetzungen bereitgestellt von:" -- Needs review
L["INTERFACEPANEL_CREDITS_TEXT_6"] = "deDE: EricTheDad\nfrFR: verfügbar\nitIT: verfügbar\nesES: verfügbar\nesMX: verfügbar\nptBR: verfügbar\nruRU: verfügbar\nzhCN: verfügbar\nkoKR: verfügbar\nzhTW: verfügbar" -- Needs review
L["INTERFACEPANEL_HELP_TEXT_1"] = "Tippe \"/statusbars2\" oder \"/sb2\" im Chat ein um dieses Fenster zu zeigen" -- Needs review
L["INTERFACEPANEL_HELP_TEXT_2"] = "Um Konfigurationsmodus zu aktivieren, tippe \"/statusbars2 config\" oder \"/sb2 config\" im Chat ein oder klicke auf die Taste hierunter." -- Needs review
L["INTERFACEPANEL_TRANSLATORS_NEEDED"] = "Übersetzer gesucht!  Geh nach http://wow.curseforge.com/addons/statusbars2/localization oder sende eine Nachricht an EricTheDad um auszuhelfen!" -- Needs review
	
end

------------------------------------------------------

if (GetLocale() == "frFR") then

end

------------------------------------------------------

if (GetLocale() == "itIT") then

end

------------------------------------------------------

if (GetLocale() == "esES" or GetLocale() == "esMX") then

end

------------------------------------------------------

if (GetLocale() == "ptBR") then

end

------------------------------------------------------

if (GetLocale() == "ruRU") then

end

------------------------------------------------------

if (GetLocale() == "zhCN") then

end

------------------------------------------------------

if (GetLocale() == "koKR") then

end

------------------------------------------------------

if (GetLocale() == "zhTW") then

end

------------------------------------------------------

-------------------------------------------------------------------------------
--
--  Name:           StatusBars2_CreateHealthBar
--
--  Description:    Create a health bar
--
-------------------------------------------------------------------------------
--
function StatusBars2_GetLocalizedText( key )
    return L[key];
end
