
---------------------------------------------------------
-- Addon declaration
HandyNotes_Vendors = LibStub("AceAddon-3.0"):NewAddon("HandyNotes_Vendors","AceEvent-3.0")
local HV = HandyNotes_Vendors
local Astrolabe = DongleStub("Astrolabe-0.4")
local L = LibStub("AceLocale-3.0"):GetLocale("HandyNotes_Vendors")


---------------------------------------------------------
-- Our db upvalue and db defaults
local CURRENT_DB_VERSION = 2   -- added npcID
local db
local defaults = {
	profile = {
		icon_scale = 1.0,
		icon_alpha = 1.0,
		worldmapfilter = { ["*"] = true },
		minimapfilter = { ["*"] = true },
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
--local iconN = "Interface\\Minimap\\Tracking\\Food"
--local iconN = "Interface\\Minimap\\Tracking\\Banker"
--local iconR = "Interface\\Minimap\\Tracking\\Repair"
--local iconI = "Interface\\Minimap\\Tracking\\Innkeeper"

local defkey = {}
local iconDB = {
	["N"] = "Interface\\Minimap\\Tracking\\Food",
	["R"] = "Interface\\Minimap\\Tracking\\Repair",
	["I"] = "Interface\\Minimap\\Tracking\\Innkeeper",

	-- Default
	[defkey] = "Interface\\Minimap\\Tracking\\Banker", -- for DB errors??
		}

setmetatable(iconDB, {__index = function (t, k)
					local v = t[defkey]
					rawset(t, k, v) -- cache the value for next retrievals
					return v
				end})

local IgnoredVendors = {
	-- Traveler's Tundra Mammoth (Alliance mount): http://www.wowdb.com/npc.aspx?id=32633, http://www.wowdb.com/item.aspx?id=44235
	[32638] = true, -- "Hakmud of Argus <Traveling Trader>" http://www.wowdb.com/npc.aspx?id=32638
	[32639] = true, -- "Gnimo <Adventurous Tinker>" http://www.wowdb.com/npc.aspx?id=32639
	
	-- Traveler's Tundra Mammoth (Horde mount): http://www.wowdb.com/npc.aspx?id=32640, http://www.wowdb.com/item.aspx?id=44234
	[32641] = true, -- "Drix Blackwrench <The Fixer>" http://www.wowdb.com/npc.aspx?id=32641
	[32642] = true, -- "Mojodishu <Traveling Trader>" http://www.wowdb.com/npc.aspx?id=32642
	}

---------------------------------------------------------
-- Plugin Handlers to HandyNotes

local HVHandler = {}

local function deletePin(button, mapFile, coord)
	local x, y = HandyNotes:getXY(coord)
	db.factionrealm.nodes[mapFile][coord] = nil
	HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
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

local clickedVendors, clickedVendorsZone
local info = {}
local function generateMenu(button, level)
	if (not level) then return end
	for k in pairs(info) do info[k] = nil end
	if (level == 1) then
		-- Create the title of the menu
		info.isTitle      = 1
		info.text         = L["HandyNotes - Vendors"]
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
			info.arg1 = clickedVendorsZone
			info.arg2 = clickedVendors
			UIDropDownMenu_AddButton(info, level);
		end

		-- Delete menu item
		info.disabled     = nil
		info.isTitle      = nil
		info.notCheckable = nil
		info.text = L["Delete vendor"]
		info.icon = nil
		info.func = deletePin
		info.arg1 = clickedVendorsZone
		info.arg2 = clickedVendors
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
local HV_Dropdown = CreateFrame("Frame", "HandyNotes_VendorsDropdownMenu")
HV_Dropdown.displayMode = "MENU"
HV_Dropdown.initialize = generateMenu

function HVHandler:OnClick(button, down, mapFile, coord)
	if button == "RightButton" and not down then
		clickedVendorsZone = mapFile
		clickedVendors = coord
		ToggleDropDownMenu(1, nil, HV_Dropdown, self, 0, 0)
	end
end

function HVHandler:OnEnter(mapFile, coord)
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then -- compare X coordinate
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	local vType, vName, vGuild = strsplit(":", db.factionrealm.nodes[mapFile][coord])
	tooltip:AddLine("|cffe0e0e0"..vName.."|r")
	if (vGuild ~= "") then tooltip:AddLine(vGuild) end
--	tooltip:AddLine(L["Vendor"])
	tooltip:Show()
end

function HVHandler:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

do
	-- This is a custom iterator we use to iterate over every node in a given zone
	local function worlditer(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			if value then
				local vType, vName, vGuild = strsplit(":", value)
				if db.profile.worldmapfilter[vType] then
					local icon = iconDB[vType]
					return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
				end
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil
	end
	local function miniiter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			if value then
				local vType, vName, vGuild = strsplit(":", value)
				if db.profile.minimapfilter[vType] then
					local icon = iconDB[vType]
					return state, nil, icon, db.profile.icon_scale, db.profile.icon_alpha
				end
			end
			state, value = next(t, state)
		end
		return nil, nil, nil, nil
	end

	function HVHandler:GetNodes(mapFile, minimap)
		if minimap then
			return miniiter, db.factionrealm.nodes[mapFile], nil
		else
			return worlditer, db.factionrealm.nodes[mapFile], nil
		end
	end
end


local function GetVFilters()
	local vnds = {
	["N"] = L["TYPE_Vendor"],
	["R"] = L["TYPE_Repair"],
	["I"] = L["TYPE_Innkeeper"],
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
	name = "Vendors",
	desc = "Vendors",
	get = function(info) return db.profile[info.arg] end,
	set = function(info, v)
		db.profile[info.arg] = v
		HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
	end,
	args = {
		desc = {
			name = L["These settings control the look and feel of the Vendors icons."],
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
		worldmapfilters = {
			type = "multiselect",
			name = L["World Map Filter"],
			desc = nil,
			order = 30,
			width = "full",
			get = function(info, k) return db.profile.worldmapfilter[k] end,
			set = function(info, k, v)
				db.profile.worldmapfilter[k] = v
				HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
			end,
			values = GetVFilters(),
		},
		minimapfilters = {
			type = "multiselect",
			name = L["Minimap Filter"],
			desc = nil,
			order = 40,
			width = "full",
			get = function(info, k) return db.profile.minimapfilter[k] end,
			set = function(info, k, v)
				db.profile.minimapfilter[k] = v
				HV:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
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

function HV:OnInitialize()
	-- Set up our database
	db = LibStub("AceDB-3.0"):New("HandyNotes_VendorsDB", defaults)
	self.db = db

	if db.factionrealm.dbversion > CURRENT_DB_VERSION then
		print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Unknown database version. Please update to newer version.")
		print("|cff6fafffHandyNotes_Vendors:|r |cffff4f00Warning:|r Addon has been disabled to protect your database.")
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
	HandyNotes:RegisterPluginDB("Vendors", HVHandler, options)
end

function HV:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("GOSSIP_SHOW")     -- for better tracking of Innkeepers
	self:RegisterEvent("CONFIRM_BINDER")  -- for better tracking of Innkeepers
end


local innkeepers = {}  -- table to store Innkeepers' npcids to not overwrite their icons

function HV:MERCHANT_SHOW()
	local vName = UnitName("npc")
	local canRepair = CanMerchantRepair()
	local vGuild = FigureNPCGuild("npc")

	local vGuid = UnitGUID("npc")
	local vNpcid = tonumber(vGuid:sub(-12, -7), 16)

	if innkeepers[vNpcid] then
		return  -- is already added as Innkeeper
	end

	local vType = canRepair and "R" or "N"

	self:AddVendorNote(vNpcid, vName, vGuild, vType)
end

-- This is helper function for working with variable number of return values from GetGossipOptions()
local function IsBinder(...)
	for i=2, select("#", ...), 2 do      -- just iterate over even items as these contain the type name
		if select(i, ...) == "binder" then
			return true -- found, no need to continue
		end
	end
	return false
end

-- This is tail recursion version of helper function for working with variable number of return values from GetGossipOptions()
local function IsBinderTail(x, t, ...)
	if not x then return false end
	--return t == "binder" or IsBinderTail(...)
	if t == "binder" then return true end
	return IsBinderTail(...)
end

function HV:GOSSIP_SHOW()
	if IsBinder(GetGossipOptions()) then
		local vName = UnitName("npc")
		local vGuild = FigureNPCGuild("npc")

		local vGuid = UnitGUID("npc")
		local vNpcid = tonumber(vGuid:sub(-12, -7), 16)

		innkeepers[vNpcid] = true

		self:AddVendorNote(vNpcid, vName, vGuild, "I")
	end
end

function HV:CONFIRM_BINDER()
	local vName = UnitName("npc")
	local vGuild = FigureNPCGuild("npc")

	local vGuid = UnitGUID("npc")
	if not vGuid then
		return   -- weird, we didn't get Innkeeper's GUID?
	end
	local vNpcid = tonumber(vGuid:sub(-12, -7), 16)

	if innkeepers[vNpcid] then
		return  -- is already added as Innkeeper
	end

	self:AddVendorNote(vNpcid, vName, vGuild, "I")
end

local thres = 5 -- in yards
function HV:AddVendorNote(vNpcid, vName, vGuild, vType)

	if IgnoredVendors[vNpcid] then
		return -- this vendor is ignored
	end

	local continent, zone, x, y = Astrolabe:GetCurrentPlayerPosition()
	if not vName or not continent then
		return
	end

	local vInfo1 = vType .. ":" .. vName .. ":" .. vGuild
	local vInfo2 = vInfo1 .. ":" .. vNpcid

	local coord = HandyNotes:getCoord(x, y)
	local map = HandyNotes:GetMapFile(continent, zone)
	if map then
		for coords, name in pairs(db.factionrealm.nodes[map]) do
			if vInfo1 == name or vInfo2 == name then
				local cx, cy = HandyNotes:getXY(coords)
				local dist = Astrolabe:ComputeDistance(continent, zone, x, y, continent, zone, cx, cy)
				if dist <= thres then -- Vendor already exists here
					coord = coords  -- let's not move, just update vInfo
--					return
				else -- Vendor exists on different location = has moved -> delete old info
					db.factionrealm.nodes[map][coords] = nil
				end
			end
		end

		db.factionrealm.nodes[map][coord] = vInfo2
		self:SendMessage("HandyNotes_NotifyUpdate", "Vendors")
	end
end
