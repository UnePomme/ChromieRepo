
---------------------------------------------------------
-- Addon declaration
HandyNotes_Trainers = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_Trainers","AceEvent-3.0")
local HT = HandyNotes_Trainers
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_Trainers")


---------------------------------------------------------
-- Our db upvalue and db defaults
local CURRENT_DB_VERSION = 2   -- added npcID
local db
local defaults = {
	profile = {
		icon_scale = 1.0,
		icon_alpha = 1.0,
	},
	factionrealm = {
		dbversion = 0,
		nodes = {
			["*"] = {},
		}
	},
}


---------------------------------------------------------
-- Localize some globals
local next = next
local select = select
local string_find = string.find
local GameTooltip = GameTooltip
local WorldMapTooltip = WorldMapTooltip
local HandyNotes = HandyNotes


---------------------------------------------------------
-- Constants
local iconpath = "Interface\\AddOns\\HandyNotes_Trainers\\Artwork\\"

local iconU = "Interface\\Minimap\\Tracking\\Profession"

local defkey = {}


local tsNameDB = {
-- Primary
		(GetSpellInfo(2259)),	--Alchemy
		(GetSpellInfo(3100)),	--Blacksmithing
		(GetSpellInfo(7411)),	--Enchanting
		(GetSpellInfo(4036)),	--Engineering
		(GetSpellInfo(25229)),	--Jewelcrafting
		(GetSpellInfo(2108)),	--Leatherworking
		(GetSpellInfo(3908)),	--Tailoring
		(GetSpellInfo(45357)),	--Inscription
-- Gathering:
		(GetSpellInfo(2575)),	--Mining
		(GetSpellInfo(8613)),	--Skinning
	--	(GetSpellInfo(2366)),	--Herb Gathering !!! != Herbalism
		(GetSpellInfo(9134)),	--Herbalism !!! Enchantment
	--	(GetSpellInfo(2656)),	--Smelting
-- Secondary:
		(GetSpellInfo(2550)),	--Cooking
		(GetSpellInfo(3273)),	--First Aid
		(GetSpellInfo(7620)),	--Fishing
}

setmetatable(tsNameDB, {__index = function (t, k)
					local v = k
					print("HandyNotes_Trainers: Untranslated tradeskill name found! Please report to the addon author.")
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})

local translatedTSDB = {
-- Primary professions
	[L["Alchemy"]]        = "Alchemy",
	[L["Blacksmithing"]]  = "Blacksmithing",
	[L["Enchanting"]]     = "Enchanting",
	[L["Engineering"]]    = "Engineering",
	[L["Inscription"]]    = "Inscription",
	[L["Jewelcrafting"]]  = "Jewelcrafting",
	[L["Leatherworking"]] = "Leatherworking",
	[L["Tailoring"]]      = "Tailoring",

	[L["Herbalism"]]      = "Herbalism",
	[L["Mining"]]         = "Mining",
	[L["Skinning"]]       = "Skinning",


-- Secondary professions
	[L["Cooking"]]        = "Cooking",
	[L["First Aid"]]      = "First Aid",
	[L["Fishing"]]        = "Fishing",
}


local iconDB = {

	-- Classes
	["DRUID"]   = iconpath .. "Druid",
	["HUNTER"]  = iconpath .. "Hunter",
	["MAGE"]    = iconpath .. "Mage",
	["PALADIN"] = iconpath .. "Paladin",
	["PRIEST"]  = iconpath .. "Priest",
	["ROGUE"]   = iconpath .. "Rogue",
	["SHAMAN"]  = iconpath .. "Shaman",
	["WARLOCK"] = iconpath .. "Warlock",
	["WARRIOR"] = iconpath .. "Warrior",
	["DEATHKNIGHT"]  = iconpath .. "Deathknight",

	-- Primary
	["Alchemy"]        = iconpath .. "Alchemy",
	["Blacksmithing"]  = iconpath .. "Blacksmithing",
	["Enchanting"]     = iconpath .. "Enchanting",
	["Engineering"]    = iconpath .. "Engineering",
	["Inscription"]    = iconpath .. "Inscription",
	["Jewelcrafting"]  = iconpath .. "Jewelcrafting",
	["Leatherworking"] = iconpath .. "Leatherworking",
	["Tailoring"]      = iconpath .. "Tailoring",

	["Herbalism"]      = iconpath .. "Herbalism",
	["Mining"]         = iconpath .. "Mining",
	["Skinning"]       = iconpath .. "Skinning",

	-- Secondary
	["Cooking"]        = iconpath .. "Cooking",
	["First Aid"]      = iconpath .. "Firstaid",
	["Fishing"]        = iconpath .. "Fishing",

	-- Special
	["WeaponMaster"]  = iconpath .. "Weaponmaster",
	["Riding"]        = iconpath .. "Riding",
	["ColdFlying"]    = iconpath .. "Riding",

	["Portal"]  = iconpath .. "Portal",

	["Pet"]     = iconpath .. "Pet",      -- TODO: is this needed in WoTLK?

	-- UNUSED
	["Demon"]   = iconpath .. "Demon",    -- REMOVED in WoW 3.0.2
	["Poison"]  = iconpath .. "Poison",   -- never used

	-- Default
	[defkey]    = iconpath .. "Misc", -- for any trainers without icon definition

}
setmetatable(iconDB, {__index = function (t, k)
					local v = nil
					if translatedTSDB[k] then
						v = rawget(t, translatedTSDB[k])
					end
					v = v or t[defkey]
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})

local trainerGuilds = {
	[L["Weapon Master"]] = "WeaponMaster",
	[L["Portal Trainer"]] = "Portal",
	[L["Riding Trainer"]] = "Riding",
	[L["Mechanostrider Pilot"]] = "Riding",
	[L["Cold Weather Flying Trainer"]] = "ColdFlying",
}

local trainerGuildsFemale = {
	[L["Weapon Master - Female"]] = "WeaponMaster",
	[L["Portal Trainer - Female"]] = "Portal",
	[L["Riding Trainer - Female"]] = "Riding",
	[L["Mechanostrider Pilot - Female"]] = "Riding",
	[L["Cold Weather Flying Trainer - Female"]] = "ColdFlying",
}

local gossipGuilds = {
	-- General trainers
	[L["Weapon Master"]] = "WeaponMaster",
	[L["Portal Trainer"]] = "Portal",
	[L["Pet Trainer"]] = "Pet",
	[L["Riding Trainer"]] = "Riding",
	[L["Mechanostrider Pilot"]] = "Riding",
	[L["Cold Weather Flying Trainer"]] = "ColdFlying",

	-- Class trainers
	[L["Paladin Trainer"]] = "PALADIN",
	[L["Mage Trainer"]] = "MAGE",
	[L["Druid Trainer"]] = "DRUID",
	[L["Hunter Trainer"]] = "HUNTER",
	[L["Priest Trainer"]] = "PRIEST",
	[L["Rogue Trainer"]] = "ROGUE",
	[L["Shaman Trainer"]] = "SHAMAN",
	[L["Warlock Trainer"]] = "WARLOCK",
	[L["Warrior Trainer"]] = "WARRIOR",
	[L["Deathknight Trainer"]] = "DEATHKNIGHT",

	-- TODO: Specialized trainers
--	[L["Goblin Engineering Trainer"]] = "Engineering",
}

local gossipGuildsFemale = {
	-- General trainers
	[L["Weapon Master - Female"]] = "WeaponMaster",
	[L["Portal Trainer - Female"]] = "Portal",
	[L["Pet Trainer - Female"]] = "Pet",
	[L["Riding Trainer - Female"]] = "Riding",
	[L["Mechanostrider Pilot - Female"]] = "Riding",
	[L["Cold Weather Flying Trainer - Female"]] = "ColdFlying",

	-- Class trainers
	[L["Paladin Trainer - Female"]] = "PALADIN",
	[L["Mage Trainer - Female"]] = "MAGE",
	[L["Druid Trainer - Female"]] = "DRUID",
	[L["Hunter Trainer - Female"]] = "HUNTER",
	[L["Priest Trainer - Female"]] = "PRIEST",
	[L["Rogue Trainer - Female"]] = "ROGUE",
	[L["Shaman Trainer - Female"]] = "SHAMAN",
	[L["Warlock Trainer - Female"]] = "WARLOCK",
	[L["Warrior Trainer - Female"]] = "WARRIOR",
	[L["Deathknight Trainer - Female"]] = "DEATHKNIGHT",

	-- TODO: Specialized trainers
--	[L["Goblin Engineering Trainer - Female"]] = "Engineering",
}

---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local HTHandler = {}

local function deletePin(button, mapFile, coord)
	local x, y = HandyNotes:getXY(coord)
	db.factionrealm.nodes[mapFile][coord] = nil
	HT:SendMessage("HandyNotes_NotifyUpdate", "Trainers")
end
local function createWaypoint(button, mapFile, coord)
	local c, z = HandyNotes:GetCZ(mapFile)
	local x, y = HandyNotes:getXY(coord)
	local vType, vName, vGuild = strsplit(":", db.factionrealm.nodes[mapFile][coord])
	if TomTom then
		TomTom:AddZWaypoint(c, z, x*100, y*100, vName)
	elseif Cartographer_Waypoints then
		Cartographer_Waypoints:AddWaypoint(NotePoint:new(HandyNotes:GetCZToZone(c, z), x, y, vName))
	end
end

local clickedNote, clickedNoteZone
local info = {}
local function generateMenu(button, level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		-- Create the title of the menu
		info.isTitle      = 1
		info.text         = L["HandyNotes - Trainers"]
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		if TomTom or Cartographer_Waypoints then
			-- Waypoint menu item
			info.disabled     = nil
			info.isTitle      = nil
			info.notCheckable = nil
			info.text = L["Create waypoint"]
			info.icon = nil
			info.func = createWaypoint
			info.arg1 = clickedNoteZone
			info.arg2 = clickedNote
			UIDropDownMenu_AddButton(info, level);
		end

		-- Delete menu item
		info.disabled     = nil
		info.isTitle      = nil
		info.notCheckable = nil
		info.text = L["Delete trainer"]
		info.icon = nil
		info.func = deletePin
		info.arg1 = clickedNoteZone
		info.arg2 = clickedNote
		UIDropDownMenu_AddButton(info, level);

		-- Close menu item
		info.text         = L["Close"]
		info.icon         = nil
		info.func         = function() CloseDropDownMenus() end
		info.arg1         = nil
		info.arg2         = nil
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level);
	end
end
local HT_Dropdown = CreateFrame("Frame", "HandyNotes_TrainersDropdownMenu")
HT_Dropdown.displayMode = "MENU"
HT_Dropdown.initialize = generateMenu

function HTHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		clickedNoteZone = mapFile
		clickedNote = coord
		ToggleDropDownMenu(1, nil, HT_Dropdown, self, 0, 0)
	end
end

function HTHandler:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	local vType, vName, vGuild = strsplit(":", db.factionrealm.nodes[mapFile][coord])
	tooltip:AddLine("|cffe0e0e0"..vName.."|r")
	if (vGuild ~= "") then tooltip:AddLine(vGuild) end
--	if (vType ~= "") then tooltip:AddLine("|cffe0e0e0"..vType.."|r") end
--	tooltip:AddLine(L["Trainer"])
	tooltip:Show()
end

function HTHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

do
	-- This is a custom iterator we use to iterate over every node in a given zone
	local function iter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			if value then
				local vType, vName, vGuild = strsplit(":", value)
				local icon = iconDB[vType]
				return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil
	end
	function HTHandler:GetNodes(mapFile)
		return iter, db.factionrealm.nodes[mapFile], nil
	end
end


---------------------------------------------------------
-- Options table

local options = {
	type = "group",
	name = "Trainers",
	desc = "Trainers",
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HT:SendMessage("HandyNotes_NotifyUpdate", "Trainers")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the Trainers icons."],
			type = "description",
			order = 0,
		},
		icon_scale = {
			type = "range",
			name = L["Icon Scale"],
			desc = L["The scale of the icons"],
			min = 0.25, max = 2, step = 0.01,
			arg = "icon_scale",
			order = 10,
		},
		icon_alpha = {
			type = "range",
			name = L["Icon Alpha"],
			desc = L["The alpha transparency of the icons"],
			min = 0, max = 1, step = 0.01,
			arg = "icon_alpha",
			order = 20,
		},
	},
}


---------------------------------------------------------
-- NPC info tracking - TT handling

local tt = CreateFrame("GameTooltip")
tt:SetOwner(UIParent, "ANCHOR_NONE")
tt.left = {}
tt.right = {}

for i = 1, 30 do
	tt.left[i] = tt:CreateFontString()
	tt.left[i]:SetFontObject(GameFontNormal)
	tt.right[i] = tt:CreateFontString()
	tt.right[i]:SetFontObject(GameFontNormal)
	tt:AddFontStrings(tt.left[i], tt.right[i])
end


local LEVEL_start = "^" .. (type(LEVEL) == "string" and LEVEL or "Level")
local function FigureNPCGuild(unit)
	tt:ClearLines()
	tt:SetUnit(unit)
	if not tt:IsOwned(UIParent) then
		tt:SetOwner(UIParent, "ANCHOR_NONE")
	end
	local left_2 = tt.left[2]:GetText()
	if not left_2 or left_2:find(LEVEL_start) then
		return ""
	end
	return left_2
end

---------------------------------------------------------
-- Addon initialization, enabling and disabling

function HT:OnInitialize()
	-- Set up our database
	db = LibStub("AceDB-3.0"):New("HandyNotes_TrainersDB", defaults)
	self.db = db

	if db.factionrealm.dbversion > CURRENT_DB_VERSION then
		print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Unknown database version. Please update to newer version.")
		print("|cff6fafffHandyNotes_Trainers:|r |cffff4f00Warning:|r Addon has been disabled to protect your database.")
		self:Disable()
		return
	end

	if db.factionrealm.dbversion ~= CURRENT_DB_VERSION then
		if db.factionrealm.dbversion == 0 then 
			-- addon was just installed or using pre-versioned DB 
			if next(db.factionrealm.nodes, nil) then -- DB not empty -> first version
				db.factionrealm.dbversion = 1
			else
				db.factionrealm.dbversion = CURRENT_DB_VERSION 
			end
		end

		if db.factionrealm.dbversion == 1 then
			db.factionrealm.dbversion = 2 -- just adds npcID to the end of info string
		end
	end

	-- Initialize our database with HandyNotes
	HandyNotes:RegisterPluginDB("Trainers", HTHandler, options)
end

function HT:OnEnable()
	self:RegisterEvent("TRAINER_SHOW")
	self:RegisterEvent("GOSSIP_SHOW")
end

do
	local filters = {"available", "unavailable", "used"}
	local filtersrestore = {}

	-- this table is for fixing Blizzard's IsTradeskillTrainer() failure for some tradeskill trainers :(
	local TradeskillTrainers = { 
		[19186] = true, --Kylene <Barmaid> http://www.wowhead.com/?npc=19186
	}

function HT:TRAINER_SHOW()
	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")
	local vType = nil

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -7), 16)

	if IsTradeskillTrainer() or TradeskillTrainers[vNpcid] then

		for i,f in ipairs(filters) do
			if GetTrainerServiceTypeFilter(f) ~= 1 then
				SetTrainerServiceTypeFilter(f, 1)
				filtersrestore[f] = true
			else
				filtersrestore[f] = nil
			end
		end

		ExpandTrainerSkillLine(1)  -- TODO: Find out, if the previous state can be saved

		vType = GetTrainerServiceSkillLine(2)

		for f,v in pairs(filtersrestore) do
			if v then
				SetTrainerServiceTypeFilter(f, 0)
			end
		end

	elseif trainerGuilds[vGuild] then
		vType = trainerGuilds[vGuild]
	elseif trainerGuildsFemale[vGuild] then
		vType = trainerGuildsFemale[vGuild]
	else
		vType = select(2, UnitClass("player"))
	end

	if vType then self:AddTrainerNote(vNpcid, vName, vGuild, vType) end

end --function HT:TRAINER_SHOW()
end --do

function HT:GOSSIP_SHOW()
	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")
	local vType = nil

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -7), 16)

	if gossipGuilds[vGuild] then
		vType = gossipGuilds[vGuild]
	elseif gossipGuildsFemale[vGuild] then
		vType = gossipGuildsFemale[vGuild]
	end

	if vType then self:AddTrainerNote(vNpcid, vName, vGuild, vType) end
end


local thres = 5 -- in yards
function HT:AddTrainerNote(vNpcid, vName, vGuild, vType)

	local continent, zone, x, y = Astrolabe:GetCurrentPlayerPosition()
	if not vName or not continent then
		return
	end

	local vInfo1 = vType .. ":" .. vName .. ":" .. vGuild
	local vInfo2 = vType .. ":" .. vName .. ":" .. vGuild .. ":" .. vNpcid

	local coord = HandyNotes:getCoord(x, y)
	local map = HandyNotes:GetMapFile(continent, zone)
	if map then
		for coords, name in pairs(db.factionrealm.nodes[map]) do
			if vInfo1 == name or vInfo2 == name then
				local cx, cy = HandyNotes:getXY(coords)
				local dist = Astrolabe:ComputeDistance(continent, zone, x, y, continent, zone, cx, cy)
				if dist <= thres then -- Trainer already exists here
					coord = coords  -- let's not move, just update vInfo
--					return
				else -- Trainer exists on different location = has moved -> delete old info
					db.factionrealm.nodes[map][coords] = nil
				end
			end
		end
		
		db.factionrealm.nodes[map][coord] = vInfo2
		self:SendMessage("HandyNotes_NotifyUpdate", "Trainers")
	end
end
