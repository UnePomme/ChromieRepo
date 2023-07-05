local _
local RaidTargetReference = {
	STAR = 0x00100000,
	CIRCLE = 0x00200000,
	DIAMOND = 0x00400000,
	TRIANGLE = 0x00800000,
	MOON = 0x01000000,
	SQUARE = 0x02000000,
	CROSS = 0x04000000,
	SKULL = 0x08000000
}

-------------------------------------------------------------------------
-- Spell Cast Event Watcher.
-------------------------------------------------------------------------
local CombatCastEventWatcher
local CombatEventHandlers = {}

-- If you don't define a local reference,
-- the Tidy Plates table will get passed to the function.
local StartCastAnimationOnNameplate = TidyPlates.StartCastAnimationOnNameplate

local function SearchNameplateByGUID(SearchFor)
	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
		local UnitGUID = VisiblePlate.extended.unit.guid
		if UnitGUID and UnitGUID == SearchFor then
			return VisiblePlate
		end
	end
end

local function SearchNameplateByName(NameString)
	local SearchFor = strsplit("-", NameString)
	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.name == SearchFor then
			return VisiblePlate
		end
	end
end

local function SearchNameplateByIcon(UnitFlags)
	local UnitIcon
	for iconname, bitmask in pairs(RaidTargetReference) do
		if bit.band(UnitFlags, bitmask) > 0 then
			UnitIcon = iconname
			break
		end
	end

	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.isMarked and (VisiblePlate.extended.unit.raidIcon == UnitIcon) then -- BY Icon
			return VisiblePlate
		end
	end
end

--------------------------------------
-- OnSpellCast
-- Sends cast event to an available nameplate
--------------------------------------
local function OnSpellCast(...)
	local sourceGUID, sourceName, sourceFlags, spellid, spellname = ...
	local FoundPlate = nil

	-- Gather Spell Info
	local spell, _, icon, castTime
	spell, _, icon, _, _, _, castTime, _, _ = GetSpellInfo(spellid)
	if castTime <= 0 then
		return
	end

	if bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
		if bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 then
			--	destination plate, by name
			FoundPlate = SearchNameplateByName(sourceName)
		elseif bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_NPC) > 0 then
			--	destination plate, by GUID
			FoundPlate = SearchNameplateByGUID(sourceGUID)
			if not FoundPlate then
				FoundPlate = SearchNameplateByIcon(sourceFlags)
			end
		else
			return
		end
	else
		return
	end

	-- If the unit's nameplate is visible, show the cast bar
	if FoundPlate then
		local FoundPlateUnit = FoundPlate.extended.unit
		if not FoundPlateUnit.isTarget then
			StartCastAnimationOnNameplate(FoundPlate, spell, spellid, icon, false, false)
		end
	end
end

function CombatEventHandlers.SPELL_CAST_START(...)
	OnSpellCast(...)
end

--------------------------------------
-- Watch Combat Log Events
--------------------------------------

local function OnCombatEvent(self, event, ...)
	local _, combatevent, sourceGUID, sourceName, sourceFlags, _, _, _, spellid, spellname = ...
	if CombatEventHandlers[combatevent] and sourceGUID ~= UnitGUID("player") and sourceGUID ~= UnitGUID("target") and spellid then
		CombatEventHandlers[combatevent](sourceGUID, sourceName, sourceFlags, spellid, spellname)
	end
end

-----------------------------------
-- External control functions
-----------------------------------

local function StartSpellCastWatcher()
	if not CombatCastEventWatcher then
		CombatCastEventWatcher = CreateFrame("Frame")
	end
	CombatCastEventWatcher:SetScript("OnEvent", OnCombatEvent)
	CombatCastEventWatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function StopSpellCastWatcher()
	if CombatCastEventWatcher then
		CombatCastEventWatcher:SetScript("OnEvent", nil)
		CombatCastEventWatcher:UnregisterAllEvents()
		CombatCastEventWatcher = nil
	end
end

TidyPlates.StartSpellCastWatcher = StartSpellCastWatcher
TidyPlates.StopSpellCastWatcher = StopSpellCastWatcher

-- The spell ID number of Fireball is 133
-- To test spell cast: /run TestTidyPlatesCastBar("Boognish", 133, true)
function TidyPlates.TestCastBar(SearchFor, SpellID, Shielded, ForceChanneled)
	local FoundPlate
	local spell, _, icon = GetSpellInfo(SpellID)
	local channel

	-- Search for the nameplate, by name (you could also search by GUID)
	for VisiblePlate in pairs(TidyPlates.NameplatesByVisible) do
		if VisiblePlate.extended.unit.name == SearchFor or VisiblePlate.extended.unit.guid == SearchFor then
			FoundPlate = VisiblePlate
			break
		end
	end

	-- If found, display the cast bar
	if FoundPlate then
		print("Testing Spell Cast on", SearchFor, "(no cast animation)")
		StartCastAnimationOnNameplate(FoundPlate, spell, spell, icon, Shielded, ForceChanneled)
	end
end