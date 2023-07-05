local L = LibStub("AceLocale-3.0"):NewLocale("HandyNotes_CityGuide", "enUS", true)
if not L then return end

-- Options dialog
L["Icon Scale"] = true
L["The scale of the icons"] = true
L["Icon Alpha"] = true
L["The alpha transparency of the icons"] = true
L["These settings control the look and feel of the CityGuide icons."] = true

-- Options - Filters
L["Filters"] = true
L["TYPE_Auctioneer"] = "Auctioneer"
L["TYPE_Banker"] = "Banker"
L["TYPE_BattleMaster"] = "Battle Master"
L["TYPE_StableMaster"] = "Stable Master"
L["TYPE_SpiritHealer"] = "Spirit Healer"

-- Right click menu on note on WorldMap
L["HandyNotes - CityGuide"] = true   -- title for the right-click menu
L["Delete note"] = true
L["Create waypoint"] = true      -- only available with TomTom or Cartoghrapher_Waypoints installed
L["Close"] = true

-- Currently unused
L["CityGuide"] = true

-- These are NPC "guilds"
-- no guild names currently needed