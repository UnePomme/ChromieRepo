
---------------------------------------------------------
-- Addon declaration
HandyNotes_CityGuide = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_CityGuide","AceEvent-3.0")
local HC = HandyNotes_CityGuide
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_CityGuide")


---------------------------------------------------------
-- Our db upvalue and db defaults
local CURRENT_DB_VERSION = 2
local db
local defaults = {
	profile = {
		icon_scale = 1.0,
		icon_alpha = 1.0,
		filter = { ["*"] = true },
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

local defkey = {}
local iconDB = {
	["A"] = "Interface\\Minimap\\Tracking\\Auctioneer",
	["B"] = "Interface\\Minimap\\Tracking\\Banker",
	["W"] = "Interface\\Minimap\\Tracking\\BattleMaster",
	["S"] = "Interface\\Minimap\\Tracking\\StableMaster",
	["X"] = "Interface\\Minimap\\Tracking\\TrivialQuests",
	["M"] = "Interface\\Minimap\\Tracking\\Mailbox",
	--["R"] = "Interface\\Minimap\\Tracking\\Banker",  -- Barber

	-- Default
	[defkey] = "Interface\\Minimap\\Tracking\\TrivialQuests", -- for DB errors??
		}

setmetatable(iconDB, {__index = function (t, k)
					local v = t[defkey]
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})

---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local HCHandler = {}

local function deletePin(button, mapFile, coord)
	local x, y = HandyNotes:getXY(coord)
	db.factionrealm.nodes[mapFile][coord] = nil
	HC:SendMessage("HandyNotes_NotifyUpdate", "CityGuide")
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
		info.text         = L["HandyNotes - CityGuide"]
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
		info.text = L["Delete note"]
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
local HC_Dropdown = CreateFrame("Frame", "HandyNotes_CityGuideDropdownMenu")
HC_Dropdown.displayMode = "MENU"
HC_Dropdown.initialize = generateMenu

function HCHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		clickedNoteZone = mapFile
		clickedNote = coord
		ToggleDropDownMenu(1, nil, HC_Dropdown, self, 0, 0)
	end
end

function HCHandler:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	local vType, vName, vGuild = strsplit(":", db.factionrealm.nodes[mapFile][coord])
	tooltip:AddLine("|cffe0e0e0"..vName.."|r")
	if (vGuild ~= "") then tooltip:AddLine(vGuild) end
--	tooltip:AddLine(L["CityGuide"])
	tooltip:Show()
end

function HCHandler:OnLeave(mapFile, coord)
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
				if db.profile.filter[vType] then
					local icon = iconDB[vType]
					return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
				end
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil
	end
	function HCHandler:GetNodes(mapFile)
		return iter, db.factionrealm.nodes[mapFile], nil
	end
end


local function GetVFilters()
	local vnds = {
	["A"] = L["TYPE_Auctioneer"],
	["B"] = L["TYPE_Banker"],
	["W"] = L["TYPE_BattleMaster"],
	["S"] = L["TYPE_StableMaster"],
	["X"] = L["TYPE_SpiritHealer"],
		}

	local res = {}
	for id, text in pairs(vnds) do
		res[id] = "|T"..iconDB[id]..":18|t "..text
	end
	return res
end

---------------------------------------------------------
-- Options table

local options = {
	type = "group",
	name = "CityGuide",
	desc = "CityGuide",
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HC:SendMessage("HandyNotes_NotifyUpdate", "CityGuide")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the CityGuide icons."],
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
		filters = {
			type = "multiselect",
			name = L["Filters"],
			desc = nil,
			order = 30,
			width = "full",
			get = function(info, k) return db.profile.filter[k] end,
			set = function(info, k, v)
				db.profile.filter[k] = v
				HC:SendMessage("HandyNotes_NotifyUpdate", "CityGuide")
			end,
			values = GetVFilters(),

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

function HC:OnInitialize()
	-- Set up our database
	db = LibStub("AceDB-3.0"):New("HandyNotes_CityGuideDB", defaults)
	self.db = db

	if db.factionrealm.dbversion > CURRENT_DB_VERSION then
		print("|cff6fafffHandyNotes_CityGuide:|r |cffff4f00Warning:|r Unknown database version. Please update to newer version.")
		print("|cff6fafffHandyNotes_CityGuide:|r |cffff4f00Warning:|r Addon has been disabled to protect your database.")
		self:Disable()
		return
	end

	if db.factionrealm.dbversion ~= CURRENT_DB_VERSION then
		if db.factionrealm.dbversion == 0 then
			-- addon was just installed
			db.factionrealm.dbversion = CURRENT_DB_VERSION
		end
	end

db.factionrealm.dbversion = CURRENT_DB_VERSION

	-- Initialize our database with HandyNotes
	HandyNotes:RegisterPluginDB("CityGuide", HCHandler, options)
end

function HC:OnEnable()
	self:RegisterEvent("PET_STABLE_SHOW")
	self:RegisterEvent("AUCTION_HOUSE_SHOW")
	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("GUILDBANKFRAME_OPENED")
	self:RegisterEvent("BATTLEFIELDS_SHOW")
--	self:RegisterEvent("CONFIRM_XP_LOSS")
	self:RegisterEvent("BARBER_SHOP_OPEN")
	self:RegisterEvent("MAIL_SHOW")
end


local innkeepers = {}  -- table to store Innkeepers' npcids to not overwrite their icons

function HC:PET_STABLE_SHOW()
	self:AddNPCNote("S")
end

function HC:AUCTION_HOUSE_SHOW()
	self:AddNPCNote("A")
end

function HC:BANKFRAME_OPENED()
	self:AddNPCNote("B")
end

function HC:GUILDBANKFRAME_OPENED()  -- TODO
--	self:AddObjectNote("G")
end

function HC:BATTLEFIELDS_SHOW()
	self:AddNPCNote("W")
end

function HC:CONFIRM_XP_LOSS() -- Spirit Healer tracking moved to HandyNotes_Charon
--	self:AddNPCNote("X")
end

function HC:BARBER_SHOP_OPEN()   -- TODO
--	self:AddObjectNote("R")
end

function HC:MAIL_SHOW()  -- TODO
-- self:AddObjectNote("M")
end

function HC:AddNPCNote(vType)
	if not UnitExists("npc") then
		-- fix for Call Stabled Pet and other cases, where NPC is not a real NPC (mailbox, barber, Guildbank)
		-- for pseudo-NPC use AddObjectNote(type, distance)
		return
	end

	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -7), 16)

	-- ignore Argent Squire pet
	-- http://www.wowdb.com/item.aspx?id=44998
	-- http://www.wowdb.com/npc.aspx?id=33238
	if (vNpcid ~= 33238) then 
		self:AddCityGuideNote(vNpcid, vName, vGuild, vType)
	end
end


local thres = 5 -- in yards
function HC:AddCityGuideNote(vNpcid, vName, vGuild, vType)

	local continent, zone, x, y = Astrolabe:GetCurrentPlayerPosition()
	if not vName or not continent then
		return
	end

	local vInfo = vType .. ":" .. vName .. ":" .. vGuild .. ":" .. vNpcid

	local coord = HandyNotes:getCoord(x, y)
	local map = HandyNotes:GetMapFile(continent, zone)
	if map then
		for coords, name in pairs(db.factionrealm.nodes[map]) do
			if vInfo == name then
				local cx, cy = HandyNotes:getXY(coords)
				local dist = Astrolabe:ComputeDistance(continent, zone, x, y, continent, zone, cx, cy)
				if dist <= thres then -- Note already exists here
--					coord = coords  -- let's not move, just update vInfo
					return
				else -- Note exists on different location = has moved -> delete old info
					db.factionrealm.nodes[map][coords] = nil
				end
			end
		end

		db.factionrealm.nodes[map][coord] = vInfo
		self:SendMessage("HandyNotes_NotifyUpdate", "CityGuide")
	end
end
