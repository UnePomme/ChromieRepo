-- Set Global Table
ThreatPlatesWidgets = ThreatPlatesWidgets or {}
local db
local _

TidyPlatesUtility:EnableGroupWatcher()
TidyPlatesWidgets:EnableAuraWatcher()
TidyPlatesWidgets:EnableTankWatch()

local TidyPlatesHubFunctions = TidyPlatesHubFunctions
local DebuffPrefixModes = TidyPlatesHubFunctions.DebuffPrefixModes

local TidyPlatesHubHelpers = TidyPlatesHubHelpers
local PrefixList = TidyPlatesHubHelpers.PrefixList
local PlayerGUID = TidyPlatesHubHelpers.PlayerGUID

local DebuffFilterModes = {}

-- All
DebuffFilterModes.all = function(debuff, list) return true end

-- All mine
DebuffFilterModes.allMine = function(debuff, list) return (debuff.caster == PlayerGUID()) end

-- Whitelist
DebuffFilterModes.whitelist = function(debuff, list)
	for _, name in ipairs(list) do
		if name == debuff.name or tonumber(name) == debuff.spellid then
			return true
		end
	end
end

-- whitelist mine
DebuffFilterModes.whitelistMine = function(debuff, list)
	local found = DebuffFilterModes.whitelist(debuff, list)
	return (found and debuff.caster == PlayerGUID())
end

-- blacklist
DebuffFilterModes.blacklist = function(debuff, list)
	for _, name in ipairs(list) do
		if name == debuff.name or tonumber(name) == debuff.spellid then
			return false
		end
	end
	return true
end

	-- blacklist mine
DebuffFilterModes.blacklistMine = function(debuff, list)
	local found = DebuffFilterModes.blacklist(debuff, list)
	return (found == true and debuff.caster == PlayerGUID())
end

-- prefix
local ParseDebuffString = nil
DebuffFilterModes.prefix = function(debuff, list)
	-- we generate the func only if used
	if ParseDebuffString == nil then
		ParseDebuffString = function(str)
			local func = nil
			local _, _, prefix, suffix = string.find(str, "(%w+)[%s%p]*(.*)")
			if prefix then
				if PrefixList[prefix] then
					str = suffix
					func = DebuffPrefixModes[PrefixList[prefix]]
				else
					str = prefix
					if suffix and suffix ~= "" then
						str = str .. " " .. suffix
					end
					func = DebuffPrefixModes[1]
				end
			end

			return str, func
		end
	end

	for _, deb in ipairs(list) do
		-- no filter?
		if deb == debuff.name or tonumber(deb) == debuff.spellid then
			return true
		end

		local name, func = ParseDebuffString(deb)
		if (name == debuff.name or tonumber(name) == debuff.spellid) and func then
			return func(debuff)
		end
	end
end

--DebuffFilterFunction
local function DebuffFilter(debuff)
	-- Debuffs on Friendly Units
	if debuff.target == 2 then -- AURA_TARGET_FRIENDLY
		return false
	end

	db = TidyPlatesThreat.db.profile
	return DebuffFilterModes[db.debuffWidget.mode](debuff, db.debuffWidget.filter)
end
----------------
-- INITIALIZE --
----------------
local function OnInitialize(plate)
	db = TidyPlatesThreat.db.profile
	local w = plate.widgets
	-- Debuff Widget
	if db.debuffWidget.ON then
		if not w.WidgetDebuff then
			local widget = TidyPlatesWidgets.CreateAuraWidget(plate)
			widget:SetPoint("CENTER", plate, db.debuffWidget.x, db.debuffWidget.y)
			widget:SetScale(db.debuffWidget.scale)
			widget:SetFrameLevel(plate:GetFrameLevel() + 1)
			widget.Filter = DebuffFilter
			w.WidgetDebuff = widget
		end
	elseif w.WidgetDebuff then
		w.WidgetDebuff:Hide()
		w.WidgetDebuff = nil
	end

	-- Social Widget
	if db.socialWidget.ON then
		if not w.SocialArt then
			local widget = ThreatPlatesWidgets.CreateSocialWidget(plate)
			widget:SetFrameLevel(plate:GetFrameLevel() + 2)
			widget:SetHeight(db.socialWidget.scale)
			widget:SetWidth(db.socialWidget.scale)
			widget:SetPoint("CENTER", plate, db.socialWidget.anchor, db.socialWidget.x, db.socialWidget.y)
			w.SocialArt = widget
		end
	elseif w.SocialArt then
		w.SocialArt:Hide()
		w.SocialArt = nil
	end

	-- Totem Widget
	if db.totemWidget.ON then
		if not w.TotemIconWidget then
			local widget = ThreatPlatesWidgets.CreateTotemIconWidget(plate)
			widget:SetHeight(db.totemWidget.scale)
			widget:SetWidth(db.totemWidget.scale)
			widget:SetFrameLevel(plate:GetFrameLevel() + 1)
			widget:SetPoint(db.totemWidget.anchor, plate, (db.totemWidget.x), (db.totemWidget.y))
			w.TotemIconWidget = widget
		end
	elseif w.TotemIconWidget then
		w.TotemIconWidget:Hide()
		w.TotemIconWidget = nil
	end

	-- Unique Widget
	if db.uniqueWidget.ON then
		if not w.UniqueIconWidget then
			local widget = ThreatPlatesWidgets.CreateUniqueIconWidget(plate)
			widget:SetHeight(db.uniqueWidget.scale)
			widget:SetWidth(db.uniqueWidget.scale)
			widget:SetFrameLevel(plate:GetFrameLevel() + 1)
			widget:SetPoint(db.uniqueWidget.anchor, plate, (db.uniqueWidget.x), (db.uniqueWidget.y))
			w.UniqueIconWidget = widget
		end
	elseif w.UniqueIconWidget then
		w.UniqueIconWidget:Hide()
		w.UniqueIconWidget = nil
	end

	-- Target Widget
	if db.targetWidget.ON then
		if not w.TargetArt then
			local widget = ThreatPlatesWidgets.CreateTargetFrameArt(plate)
			widget:SetPoint("CENTER", plate, "CENTER", 0, 0)
			w.TargetArt = widget
		end
	elseif w.TargetArt then
		w.TargetArt:Hide()
		w.TargetArt = nil
	end

	-- Class Icon Widget
	if db.classWidget.ON then
		if not w.ClassIconWidget then
			local widget = ThreatPlatesWidgets.CreateClassIconWidget(plate)
			widget:SetHeight(db.classWidget.scale)
			widget:SetWidth(db.classWidget.scale)
			widget:SetPoint((db.classWidget.anchor), plate, (db.classWidget.x), (db.classWidget.y))
			w.ClassIconWidget = widget
		end
	elseif w.ClassIconWidget then
		w.ClassIconWidget:Hide()
		w.ClassIconWidget = nil
	end

	-- Elite Overlay Widget
	if db.settings.elitehealthborder.show then
		if not w.EliteOverlay then
			local widget = ThreatPlatesWidgets.CreateEliteFrameArtOverlay(plate)
			widget:SetPoint("CENTER", plate, "CENTER", 0, 0)
			w.EliteOverlay = widget
		end
	elseif w.EliteOverlay then
		w.EliteOverlay:Hide()
		w.EliteOverlay = nil
	end

	-- Threat Graphic Widget
	if db.threat.art.ON and db.threat.ON then
		if not w.ThreatArtWidget then
			local widget = ThreatPlatesWidgets.CreateThreatArtWidget(plate)
			widget:SetPoint("CENTER", plate, "CENTER", 0, 0)
			w.ThreatArtWidget = widget
		end
	elseif w.ThreatArtWidget then
		w.ThreatArtWidget:Hide()
		w.ThreatArtWidget = nil
	end

	-- Threat Line Widget
	if db.threatWidget.ON then
		if not w.ThreatLineWidget then
			local widget = TidyPlatesWidgets.CreateThreatLineWidget(plate)
			widget:SetPoint(db.threatWidget.anchor, plate, db.threatWidget.x, db.threatWidget.y)
			widget:SetFrameLevel(plate:GetFrameLevel() + 3)
			w.ThreatLineWidget = widget
		end
	elseif w.ThreatLineWidget then
		w.ThreatLineWidget:Hide()
		w.ThreatLineWidget = nil
	end

	-- Combo Point Widget
	if db.comboWidget.ON then
		if not w.ComboPoints then
			local widget = ThreatPlatesWidgets.CreateComboPointWidget(plate)
			widget:SetPoint("CENTER", plate, (db.comboWidget.x), db.comboWidget.y)
			w.ComboPoints = widget
		end
	elseif w.ComboPoints then
		w.ComboPoints:Hide()
		w.ComboPoints = nil
	end
end
--------------------
-- CONTEXT UPDATE --
--------------------
local function OnContextUpdate(plate, unit)
	db = TidyPlatesThreat.db.profile
	local w = plate.widgets
	-- Debuff Widget
	if db.debuffWidget.ON then
		if not w.WidgetDebuff then
			OnInitialize(plate)
		end
		w.WidgetDebuff:SetScale(db.debuffWidget.scale)
		w.WidgetDebuff:SetPoint(db.debuffWidget.anchor, plate, db.debuffWidget.x, db.debuffWidget.y)
		w.WidgetDebuff:UpdateContext(unit)
	end

	-- Combo Point Widget
	if db.comboWidget.ON then
		if not w.ComboPoints then
			OnInitialize(plate)
		end
		w.ComboPoints:SetPoint("CENTER", plate, (db.comboWidget.x), db.comboWidget.y)
		w.ComboPoints:UpdateContext(unit)
	end

	--Threat Line Widget
	if db.threatWidget.ON and unit.class == "UNKNOWN" then
		if not w.ThreatLineWidget then
			OnInitialize(plate)
		end
		w.ThreatLineWidget:SetPoint("CENTER", plate, (db.threatWidget.x), db.threatWidget.y)
		w.ThreatLineWidget:UpdateContext(unit)
	end
end
-------------------
-- NORMAL UPDATE --
-------------------
local function OnUpdate(plate, unit)
	db = TidyPlatesThreat.db.profile
	local w = plate.widgets
	-- Target Art
	if db.targetWidget.ON then
		if not w.TargetArt then
			OnInitialize(plate)
		end
		w.TargetArt:Update(unit)
	end

	-- Elite Overlay
	if db.settings.elitehealthborder.show then
		if not w.EliteOverlay then
			OnInitialize(plate)
		end
		w.EliteOverlay:Update(unit)
	end

	-- Social Widget Textures
	if db.socialWidget.ON then
		if not w.SocialArt then
			OnInitialize(plate)
		end
		w.SocialArt:SetHeight(db.socialWidget.scale)
		w.SocialArt:SetWidth(db.socialWidget.scale)
		w.SocialArt:SetPoint("CENTER", plate, db.socialWidget.anchor, db.socialWidget.x, db.socialWidget.y)
		w.SocialArt:Update(unit)
	end
	-- Class Icons
	if db.classWidget.ON then
		if not w.ClassIconWidget then
			OnInitialize(plate)
		end
		w.ClassIconWidget:SetHeight(db.classWidget.scale)
		w.ClassIconWidget:SetWidth(db.classWidget.scale)
		w.ClassIconWidget:SetPoint((db.classWidget.anchor), plate, (db.classWidget.x), (db.classWidget.y))
		w.ClassIconWidget:Update(unit)
	end
	-- Totem Icons
	if db.totemWidget.ON then
		if not w.TotemIconWidget then
			OnInitialize(plate)
		end
		w.TotemIconWidget:SetHeight(db.totemWidget.scale)
		w.TotemIconWidget:SetWidth(db.totemWidget.scale)
		w.TotemIconWidget:SetPoint(db.totemWidget.anchor, plate, (db.totemWidget.x), (db.totemWidget.y))
		w.TotemIconWidget:Update(unit)
	end
	-- Unique Icons
	if db.uniqueWidget.ON then
		if not w.UniqueIconWidget then
			OnInitialize(plate)
		end
		w.UniqueIconWidget:SetHeight(db.uniqueWidget.scale)
		w.UniqueIconWidget:SetWidth(db.uniqueWidget.scale)
		w.UniqueIconWidget:SetPoint(db.uniqueWidget.anchor, plate, (db.uniqueWidget.x), (db.uniqueWidget.y))
		w.UniqueIconWidget:Update(unit)
	end
	-- Threat Widget
	if db.threat.ON and db.threat.art.ON then
		if not w.ThreatArtWidget then
			OnInitialize(plate)
		end
		w.ThreatArtWidget:Update(unit)
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local arg1 = ...
		if arg1 == "TidyPlates_ThreatPlates" then
			TidyPlatesThemeList["Threat Plates"].OnInitialize = OnInitialize
			TidyPlatesThemeList["Threat Plates"].OnUpdate = OnUpdate
			TidyPlatesThemeList["Threat Plates"].OnContextUpdate = OnContextUpdate
		end
	end
end)
f:RegisterEvent("ADDON_LOADED")