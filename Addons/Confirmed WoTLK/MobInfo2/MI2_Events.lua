--
-- MI2_Events.lua
--
-- Handlers for all WoW events that MobInfo subscribes to. This includes
-- the main MobInfo OnEvent handler called "MI2_OnEvent()". Event handling
-- is based on a global table of event handlers called "MI2_EventHandlers[]".
-- For each event that MobInfo supports the corresponding handler function
-- is available in the table.
--
-- (this is code restructering work in progress, it has not yet been completed ... )
--

-- global variables initialisation
MI2_Target = {}
MI2_CurZone = 0

-- miscellaneous other event related global vairables 
MI2_IsNonMobLoot = nil

-- local variables declaration and initialisation
local MI2_EventHandlers = { }
local MI2_TT_SetItem, MI2_Scan_SelfBuff
local MI2_LootFrameOpen = false


-----------------------------------------------------------------------------
-- MI2_CheckForSeparateMobHealth()
--
-- Detect the presence of separate MobHelath AddOns and disable the internal
-- MobHealth functionality if found
--
local function MI2_CheckForSeparateMobHealth()
	MobInfoConfig.DisableHealth = 0
	if  MobHealth_OnLoad  then
		MobInfoConfig.DisableHealth = 2
		UIErrorsFrame:AddMessage( MI_TXT_MH_DISABLED, 0.0, 1.0, 1.0, 1.0, 20 )
	end
end  -- MI2_CheckForSeparateMobHealth


-----------------------------------------------------------------------------
-- MI2_VariablesLoaded()
--
-- main global initialization function, this is called as the handler
-- for the "VARIABLES_LOADED" event
--
local function MI2_VariablesLoaded()
	-- initialize "MobInfoConfig" data structure (main MobInfo config options)
	MI2_InitOptions()

	-- register with all AddOn managers that MobInfo attempts to support
	-- currently that is: myAddons, KHAOS (mainly for Cosmos), EARTH (originally for Cosmos)
	MI2_RegisterWithAddonManagers()

	-- check for presence of separate interferring MobHealth AddOn
	-- initialize built-in MobHealth if not disabled
	MI2_CheckForSeparateMobHealth()
	--MI2_MobHealth_SetPos()
	MI2_OptionParse( "", {}, nil )

	-- ensure that MobHealthFrame get set correctly (if we have to set it for compatibility)
	if  MobHealthFrame == "MI2"  then
		MobHealthFrame = MI2_MobHealthFrame
	end

	-- setup a confirmation dialog for critical configuration options
	StaticPopupDialogs["MOBINFO_CONFIRMATION"] = {
		button1 = TEXT(OKAY),
		button2 = TEXT(CANCEL),
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		interruptCinematic = 1
	}
	StaticPopupDialogs["MOBINFO_SHOWMESSAGE"] = {
		button1 = TEXT(OKAY),
		showAlert = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
		interruptCinematic = 1
	}

	-- checking and cleanup for all databases
	MI2_CheckAndCleanDatabases()

	-- initialize slash commands processing
	MI2_SlashInit()
	-- build cross reference table for fast item tooltips
	MI2_BuildXRefItemTable()
	
	-- extend the spell school table to list both schools and schortcuts
	local newSchools = {}
	local school, schortcut
	for school, schortcut in pairs(MI2_SpellSchools) do
		newSchools[school] = schortcut
		newSchools[schortcut] = school
	end
	MI2_SpellSchools = newSchools

	-- from this point onward process events
	MI2_InitializeEventTable()

	MI2_UpdateOptions()
	MI2_InitializeTooltip()
	MI2_SetupTooltip() 

	-- register for catching tooltip events
	MI2_TT_SetItem = GameTooltip:GetScript("OnTooltipSetItem")
	GameTooltip:SetScript( "OnTooltipSetItem", MI2_OnTooltipSetItem )
end -- MI2_VariablesLoaded()


-----------------------------------------------------------------------------
-- MI2_EventLootOpened()
--
-- WoW event notification that loot frame has been opened
--
local function MI2_EventLootOpened( )
	local mobIndex = MI2_Target.mobIndex or MI2_LastTargetIdx
	local numItems = GetNumLootItems()

	MI2_CurrentCorpseIndex = nil
	MI2_LootFrameOpen = true

	-- if there is a target it must be a dead one, the loot must be mob loot
	-- reject non empty loots without target (empty loots opened by "QuickLoot" have no target)
	if (not MI2_Target.mobIndex and numItems > 0)
			or (MI2_Target.mobIndex and not UnitIsDead("target")) or MI2_IsNonMobLoot then
		MI2_IsNonMobLoot = false
		return
	end

    -- detect and prevent errors caused by mysterious missing
    -- looting targets 
	if not mobIndex and not ERR_NO_LOOT_TARGET_SHOWN then
		chattext( "MobInfo Warning: loot window opened without valid target" )
		ERR_NO_LOOT_TARGET_SHOWN = 1
		return
	end

	-- check if this is a known corpse being reopened, reopened corpses
	-- can (and must) be ignored because they have already been fully processed
	if MI2_CheckForCorpseReopen(mobIndex) then
		midebug( "corpse REOPEN detected", 1 )
		return
	end	

	-- record all loot found on the corpse (called each time to catch skinning))
	MI2_RecordAllLootItems( mobIndex, numItems )
end -- MI2_EventLootOpened()


-----------------------------------------------------------------------------
-- MI2_EventLootSlotCleared()
--
-- WoW event notification that one loot item has been looted.
-- This results in a new corpse ID which must be stored for corpse reopen
-- detection
--
local function MI2_EventLootSlotCleared( )
	MI2_StoreCorpseId( MI2_GetCorpseId(MI2_Target.mobIndex) )
end -- MI2_EventLootSlotCleared


-----------------------------------------------------------------------------
-- MI2_EventLootClosed()
--
-- Event handler for WoW event that the loot window has been closed.
-- This is used to catch empty loots when using auto-loot (Shift+RightClick)
-- In this case "LOOT_CLOSED" is the only loot event that fires
--
local function MI2_EventLootClosed( )
	local mobIndex = MI2_Target.mobIndex
	if mobIndex and not MI2_LootFrameOpen then
		MI2_RecordAllLootItems( mobIndex, 0 )
	end
	MI2_LootFrameOpen = false
end -- MI2_EventLootClosed


-----------------------------------------------------------------------------
-- MI2_EventUnitCombat()
--
-- Event handler for the "UNIT_COMBAT" event. This handler will
-- accumulate all damage done to the current target, and will record all
-- damage done to the player by the current target.
--
local function MI2_EventUnitCombat()
	if arg1 == "target" then
		if MI2_Target.index and arg4 > 0 then
			MI2_RecordTargetCombat( arg4, arg2 == "HEAL" )
		end
	elseif arg1 == "player" then
		if arg3 ~= "CRITICAL" and arg2 ~= "HEAL" and MI2_Target.mobIndex then 
			MI2_RecordDamage( MI2_Target.mobIndex, tonumber(arg4) )
		end
	end
end  -- MI2_EventUnitCombat()


-----------------------------------------------------------------------------
-- MI2_EventUnitHealth()
--
-- Event handler for the "UNIT_HEALTH" event. This handler will
-- process health number that WoW gives us for the current target. Combining
-- the health value with the damage done to the current target and with the
-- current health percentage of the target allows us to calculate the PPP
-- value (Point Per Percent) for the current target. The PPP value can then
-- be used to calculate a health value from a given health percentage.
--
-- if health value has changed update game tooltip
--
local function MI2_EventUnitHealth()
	if arg1 == "target" then
		MI2_RecordTargetHealth( UnitHealth("target") )
	end
end -- MI2_EventUnitHealth()


-----------------------------------------------------------------------------
-- MI2_EventUnitMana()
--
-- Event handler for the "UNIT_MANA" event.
-- This handler will update the mana shown in the target frame and also
-- update mana shown in the game tooltip.
--
local function MI2_EventUnitMana()
	if arg1 == "target" then
		MobHealth_Display( )
	end
end -- MI2_EventUnitMana()


-----------------------------------------------------------------------------
-- MI2_OnTargetChanged()
--
-- Event handler for the "PLAYER_TARGET_CHANGED" event. This handler will
-- fill the global variable "MI2_Target" with all the data that MobInfo
-- needs to know about the current target.
--
function MI2_OnTargetChanged()
	local name = UnitName("target")
	local level = UnitLevel("target")

	MI2_IsNonMobLoot = false -- to reset non Mob loot detection

	-- previous target post processing: update targets HP in database,
	-- remember last targets mob index, update DPS if recorded
	if  MI2_Target.mobIndex then
		MI2_SaveTargetHealthData()
		MI2_LastTargetIdx = MI2_Target.mobIndex
		if MI2_Target.FightStartTime then
			MI2_RecordDps( MI2_LastTargetIdx, MI2_Target.FightEndTime - MI2_Target.FightStartTime, MI2_Target.FightDamage )
		end
		if MobInfoConfig.SaveResist == 1 then
			MI2_StoreResistData( MI2_LastTargetIdx )
		end
	end

	if name and level and (UnitCanAttack("player","target") or UnitIsPlayer("target")) then
		MI2_Target = { name=name, level=level }

		-- set index to either player or mob and store matching health database
		if  UnitIsPlayer("target")  then
			MI2_Target.index = name
			MI2_Target.healthDB = MobHealthPlayerDB
		else
			MI2_Target.index = name..":"..level
			MI2_Target.healthDB = MobHealthDB
			MI2_Target.mobIndex = MI2_Target.index
			local mobData = MI2_FetchMobData( MI2_Target.index, "target" )
			MI2_RecordLocationAndType( MI2_Target.index, mobData )
			if level < (UnitLevel("player") + 5) then MI2_Target.ResOk = true end
			mobData.killed = nil
		end
	else
		MI2_Target = {}
	end

--***************************
-- update mob health display with health for new target
MI2_HpSetNewTarget()
--***************************

	-- update options dialog if shown
    if  MI2_OptionsFrame:IsVisible()  then
		MI2_DbOptionsFrameOnShow()
	end

	if MI2_DebugEvents > 0 then if MI2_Target then midebug( "new target: idx=["..(MI2_Target.index or "nil").."], last=["..(MI2_LastTargetIdx or "nil").."]" )
	else midebug( "new target: idx=[nil], last=["..(MI2_LastTargetIdx or "nil").."]" ) end end
end  -- MI2_OnTargetChanged()


-----------------------------------------------------------------------------
-- MI2_EventSelfMelee()
--
-- handler for event CHAT_MSG_COMBAT_SELF_HITS
-- handles normal and critical melee damage
--
local function MI2_EventSelfMelee( )
	-- process event only for Mobs
	if not MI2_Target.mobIndex then return end

	local s,e, mob, damage = string.find(arg1, MI2_ChatScanStrings[4])
--if damage then chattext( "DBG: COMBATHITSELFOTHER: dmg="..damage ) end
	if not damage then
		s,e, mob, damage = string.find(arg1, MI2_ChatScanStrings[5])
--if damage then chattext( "DBG: COMBATHITCRITSELFOTHER: dmg="..damage ) end
	end

	if damage then
		MI2_RecordHit( tonumber(damage) )
	end
end  -- MI2_EventSelfMelee()


-----------------------------------------------------------------------------
-- MI2_EventSelfSpell()
--
-- handler for event "CHAT_MSG_SPELL_SELF_DAMAGE"
-- handles normal and critical spell damage and damage done by bows/guns
--
local function MI2_EventSelfSpell( )
	local isResist = false

	-- process event only for Mobs
	if not MI2_Target.mobIndex then return end

	local s,e, spell, mob, damage, school = string.find(arg1, MI2_ChatScanStrings[17])
--if damage then chattext( "DBG: SPELLLOGCRITSCHOOLSELFOTHER: dmg="..damage..", spell="..spell..", school="..school ) end
	if not damage then
		s,e, spell, mob, damage, school = string.find(arg1, MI2_ChatScanStrings[7])
--if damage then chattext( "DBG: SPELLLOGSCHOOLSELFOTHER: dmg="..damage..", spell="..spell..", school="..school ) end
		if not damage then
			s,e, spell, mob, damage = string.find(arg1, MI2_ChatScanStrings[6])
--if damage then chattext( "DBG: SPELLLOGSELFOTHER: dmg="..damage..", spell="..spell ) end
			if not damage then
				s,e, spell, mob, damage = string.find(arg1, MI2_ChatScanStrings[8])
--if damage then chattext( "DBG: SPELLLOGCRITSELFOTHER: dmg="..damage..", spell="..spell ) end
				if not damage then
					s,e, mob, spell = string.find(arg1, MI2_ChatScanStrings[14])
--if spell then chattext( "DBG: IMMUNESPELLSELFOTHER: spell="..spell ) end
					if not spell then
						s,e, spell, mob = string.find(arg1, MI2_ChatScanStrings[15])
--if mob then chattext( "DBG: SPELLIMMUNESELFOTHER: spell="..(spell or "nil")..", mob="..(mob or "nil") ) end
						if not mob then
							s,e, spell, mob = string.find(arg1, MI2_ChatScanStrings[16])
							isResist = true
--if mob then chattext( "DBG: SPELLRESISTSELFOTHER: spell="..(spell or "nil")..", mob="..(mob or "nil") ) end
	end end end end end end

	if damage then
		MI2_RecordHit( tonumber(damage), spell, school )
	elseif mob and spell then
		MI2_RecordImmunResist( mob, spell, isResist )
	end
end -- MI2_EventSelfSpell()


-----------------------------------------------------------------------------
-- MI2_EventPetMelee()
--
-- handler for event "CHAT_MSG_COMBAT_PET_HITS" and "CHAT_MSG_SPELL_PET_DAMAGE"
-- handles normal and critical melee/spell damage done by players pet
--
local function MI2_EventPetMelee( )
	-- process event only for Mobs
	if not MI2_Target.mobIndex then return end

	local s,e, pet, mob, damage = string.find(arg1, MI2_ChatScanStrings[10])
--if damage then chattext( "DBG: pet COMBATHITOTHEROTHER: dmg="..damage ) end
	if not damage then
		s,e, pet, mob, damage = string.find(arg1, MI2_ChatScanStrings[11])
--if damage then chattext( "DBG: pet COMBATHITCRITOTHEROTHER: dmg="..damage ) end
	end

	if damage then
		MI2_RecordHit( tonumber(damage) )
	end
end -- MI2_EventPetMelee()


-----------------------------------------------------------------------------
-- MI2_EventPetSpell()
--
-- handler for event "CHAT_MSG_COMBAT_PET_HITS" and "CHAT_MSG_SPELL_PET_DAMAGE"
-- handles normal and critical melee/spell damage done by players pet
--
local function MI2_EventPetSpell( )
	-- process event only for Mobs
	if not MI2_Target.mobIndex then return end

	local s,e, pet, spell, mob, damage = string.find(arg1, MI2_ChatScanStrings[12])
--if damage then chattext( "DBG: pet SPELLLOGOTHEROTHER: dmg="..damage ) end
	if not damage then
		s,e, pet, spell, mob, damage = string.find(arg1, MI2_ChatScanStrings[13])
--if damage then chattext( "DBG: pet SPELLLOGCRITOTHEROTHER: dmg="..damage ) end
	end

	if damage then
		MI2_RecordHit( tonumber(damage) )
	end
end -- MI2_EventPetSpell()


-----------------------------------------------------------------------------
-- MI2_EventSpellPeriodic()
--
-- handler for event "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE"
-- handles periodic damage done by spells
--
local function MI2_EventSpellPeriodic()
	-- process event only for Mobs
	if not MI2_Target.mobIndex then return end

	local s,e, mob, damage, school, spell = string.find(arg1, MI2_ChatScanStrings[9])
--if damage then chattext( "DBG: PERIODICAURADAMAGESELFOTHER: dmg="..damage..", spell="..spell..", school="..school ) end
	if not damage then
		s,e, mob, spell = string.find(arg1, MI2_ChatScanStrings[18])
--if spell then chattext( "DBG: AURAADDEDOTHERHARMFUL: mob="..mob..", spell="..spell ) end
	end

	if damage then
		MI2_RecordHit( damage, spell, school, true )
	else
		MI2_RecordHit( 0, spell, school )
	end
end -- MI2_EventSpellPeriodic()


-----------------------------------------------------------------------------
-- MI2_EventSpellPeriodic_ZHTW()
--
-- Special processing of periodic events for the Chinese localisation.
-- This function was kindly submitted by Andyca Chiou.
--
local function MI2_EventSpellPeriodic_ZHTW()
	-- process event only for Mobs
	--*** 2006/10/4 Modified by zhTW DOT message parsing
	if not MI2_Target.mobIndex then return end
	
	--local s,e, mob, damage, school, spell = string.find(arg1, MI2_ChatScanStrings[9])
	local s,e, spell, mob, damage, school = string.find(arg1, MI2_ChatScanStrings[9])
--if damage then chattext( "DBG: PERIODICAURADAMAGESELFOTHER: dmg="..damage..", spell="..spell..", school="..school ) end

  if not damage then
		s,e, mob, spell = string.find(arg1, MI2_ChatScanStrings[18])
--if spell then chattext( "DBG: AURAADDEDOTHERHARMFUL: mob="..mob..", spell="..spell ) end
	end

	--if damage then
	--	MI2_RecordHit( tonumber(damage) )
	--end
	if damage then
		MI2_RecordHit( damage, spell, school, true )
	else
		MI2_RecordHit( 0, spell, school )
	end
  --*** End Modification
end -- MI2_EventSpellPeriodic()



-----------------------------------------------------------------------------
-- MI2_EventSelfBuff()
--
-- event handler for the WoW "CHAT_MSG_SPELL_SELF_BUFF" event
-- This event is called for lots of miscellaneous reasons. The reason I
-- subscribe to it is to detect the opening of chest loot or collecting
-- loot (chests, barrels, mining, herbs)
--
local function MI2_EventSelfBuff()
	local s,e, lootAction, lootType = string.find( arg1, MI2_ChatScanStrings[1] )

	-- set global flag that a non Mob loot window is being opened
	if lootAction and lootType then
		if MI2_DebugEvents > 0 then midebug("non mob loot event: action="..lootAction..", type="..lootType ) end
		MI2_IsNonMobLoot = true
	end
end -- MI2_EventSelfBuff()


-----------------------------------------------------------------------------
-- MI2_EventSelfBuff_ZHTW()
--
-- zhTW Chinese version parsing function for MI2_EventSelfBuff()
-- This function was kindly submitted by Andyca Chiou.
--
local function MI2_EventSelfBuff_ZHTW()
	local s,e, lootType, lootAction  = string.find( arg1, MI2_ChatScanStrings[1] )

	-- set global flag that a non Mob loot window is being opened
	if lootAction and lootType then
		if MI2_DebugEvents > 0 then midebug("non mob loot event: action="..lootAction..", type="..lootType ) end
		MI2_IsNonMobLoot = true
	end
end -- MI2_EventSelfBuff()


-----------------------------------------------------------------------------
-- MI2_EventHostileDeath()
--
-- Event handler for chat message telling me that a hostile mob has
-- died.
--
local function MI2_EventHostileDeath()

-- This function and event appears to have disappeared with WoW 2.4
-- after some further testing and investigation it can most likely
-- be removed from the code

	local s,e, creatureName = string.find( arg1, MI2_ChatScanStrings[2] )
	if creatureName then
		if MI2_DebugEvents > 0 then midebug("no XP kill event: mob="..creatureName ) end
		MI2_RecordKill( creatureName )
	end
end -- MI2_EventHostileDeath()

-----------------------------------------------------------------------------
-- MI2_UnitDied()
--
-- Combat log event handler : a unit has died in your vicinity
-- This is the replacement for the no longer functioning "MI2_EventHostileDeath()"
--
local function MI2_UnitDied()

--midebug("event="..tostring(event)..", a1="..tostring(arg1)..", a2="..tostring(arg2)..", a3="..tostring(arg3)..", a4="..tostring(arg4))
--midebug("event="..tostring(event)..", a5="..tostring(arg5)..", a6="..tostring(arg6)..", a7="..tostring(arg7)..", a8="..tostring(arg8))

	local creatureName = arg7
	if creatureName then
		if MI2_DebugEvents > 0 then midebug("no XP kill event: mob="..creatureName ) end
		MI2_RecordKill( creatureName )
	end

end -- MI2_UnitDied()



-----------------------------------------------------------------------------
-- MI2_EventCreatureDiesXP()
--
-- event handler for the chat message telling us that a mob died
-- and gave us XP points
--
function MI2_EventCreatureDiesXP()

	local s,e, creature, xp = string.find( arg1, MI2_ChatScanStrings[3] )
	if creature and xp then
		if MI2_DebugEvents > 0 then midebug("kill event with XP: mob="..creature..", xp="..xp ) end
		MI2_RecordKill( creature, tonumber(xp) )
	end
end -- MI2_EventCreatureDiesXP()

-----------------------------------------------------------------------------
-- MI2_EventMonsterEmote()
--
-- event handler for the WoW "CHAT_MSG_MONSTER_EMOTE" event
--
local function MI2_EventMonsterEmote()
	local s,e = string.find( arg1, MI2_CHAT_MOBRUNS )
	if s then
		MI2_RecordLowHpAction( arg2, 1 )
	end
end -- MI2_EventMonsterEmote()


-----------------------------------------------------------------------------
-- MI2_EventZoneChanged()
--
-- event handler for "ZONE_CHANGED_NEW_AREA" and "ZONE_CHANGED_INDOORS"
-- this is processed for mob location tracking so that we know the zone
--
local function MI2_EventZoneChanged()
	MI2_SetNewZone( GetZoneText() )
end -- MI2_EventZoneChanged()


-----------------------------------------------------------------------------
-- MI2_Player_Login()
--
-- register the GameTooltip:OnShow event at player login time. This ensures
-- that MobInfo is the (hopefully) last AddOn to hook into this event.
--
local function MI2_Player_Login()
	-- set current zone
	MI2_EventZoneChanged()

	-- scan spellbook to fill spell to school conversion table
	MI2_ScanSpellbook()

	if not (myAddOnsFrame_Register or EarthFeature_AddButton or Khaos) then
		chattext( "MobInfo  v"..miVersionNo.."  Loaded,  ".."enter /mi2 or /mobinfo for interface")
	end
	
	-- collect all the garbage caused by loading the AddOn
	collectgarbage( "collect" )
end -- MI2_Player_Login()


-----------------------------------------------------------------------------
-- MI2_OnTooltipSetItem
--
-- OnTooltipSetItem event handler for the GameTooltip frame
-- This handler will :
--   * if a known item is hovered add the corresponding item data
--   * call the original handler which it replaces
--
function MI2_OnTooltipSetItem( ... )
	-- call original WoW event for OnTooltipSetItem
	if MI2_TT_SetItem then
		MI2_TT_SetItem(...)
	end

	if MobInfoConfig.KeypressMode == 1 and not IsAltKeyDown() then  return  end
	if MobInfoConfig.ShowItemInfo == 1 then
		-- add item loot info to item tooltip
		MI2_BuildItemDataTooltip( getglobal("GameTooltipTextLeft1"):GetText() )
	end
end -- MI2_OnTooltipSetItem()


-----------------------------------------------------------------------------
-- MI2_InitializeEventTable()
--
-- This function enables (ie. registers) only those events that are
-- needed for the current MobInfo recording options. The general rule is
-- that we only register events if we want to record the data of the event.
--
function MI2_InitializeEventTable()
	-- reset all events to their always on flag state
	for eventName, eventInfo in pairs(MI2_EventHandlers) do
		local eventEnabled = eventInfo.always or MobInfoConfig.SaveBasicInfo == 1 
			and (eventInfo.basic
				or MobInfoConfig.SaveCharData == 1 and eventInfo.char
				or MobInfoConfig.SaveItems == 1 and eventInfo.items)
		if eventEnabled then
			this:RegisterEvent( eventName )
		else
			this:UnregisterEvent( eventName )
		end
	end
end -- MI2_InitializeEventTable()


-----------------------------------------------------------------------------
-- MI2_OnEvent()
--
-- MobInfo main event handler function, gets called for all registered events
-- uses table with event handler info
--
function MI2_OnEvent()	
	--midebug("event="..event..", a1="..(arg1 or "<nil>")..", a2="..(arg2 or "<nil>")..", a3="..(arg3 or "<nil>")..", a4="..(arg4 or "<nil>"))
	MI2_EventHandlers[event].f()
end -- MI2_OnEvent


-----------------------------------------------------------------------------
-- MI2_OnCombatLogEvent()
--
-- MobInfo main event handler function, gets called for all registered events
-- uses table with event handler info
--
function MI2_OnCombatLogEvent()	
	--midebug("event="..event..", a1="..(arg1 or "<nil>")..", a2="..(arg2 or "<nil>")..", a3="..(arg3 or "<nil>")..", a4="..(arg4 or "<nil>"))
	local realEvent = MI2_EventHandlers[arg2]
	if realEvent then
		realEvent.f()
	end
end -- MI2_OnCombatLogEvent


-----------------------------------------------------------------------------
-- MI2_OnLoad()
--
-- Set up main event handler table and do stuff that must be done before
-- "VARIABLES_LOADED" is called.
--
function MI2_OnLoad()
	-- main MobInfo event handler table
	-- "f"=function to call, "always"=event always on flag, "basic"=mob basic info event, 
	-- "items"=item tracking event, "loc"=mob location event, "char"=char specific event
	MI2_EventHandlers = {
		VARIABLES_LOADED = {f=MI2_VariablesLoaded},
		COMBAT_LOG_EVENT_UNFILTERED = {f=MI2_OnCombatLogEvent, always=1},
		UNIT_COMBAT = {f=MI2_EventUnitCombat, always=1},
		UNIT_HEALTH = {f=MI2_EventUnitHealth, always=1},
		UNIT_MANA = {f=MI2_EventUnitMana, always=1},
		PLAYER_TARGET_CHANGED = {f=MI2_OnTargetChanged, always=1},
		PLAYER_LOGIN = {f=MI2_Player_Login, always=1},

		CHAT_MSG_COMBAT_XP_GAIN = {f=MI2_EventCreatureDiesXP, basic=1},
		ZONE_CHANGED_NEW_AREA = {f=MI2_EventZoneChanged, basic=1},
		ZONE_CHANGED_INDOORS = {f=MI2_EventZoneChanged, basic=1},
		CHAT_MSG_MONSTER_EMOTE = {f=MI2_EventMonsterEmote, basic=1},
		LOOT_OPENED = {f=MI2_EventLootOpened, basic=1, items=1},
		LOOT_CLOSED = {f=MI2_EventLootClosed, basic=1, items=1},
		LOOT_SLOT_CLEARED = {f=MI2_EventLootSlotCleared, basic=1, items=1},
		CHAT_MSG_SPELL_SELF_BUFF = {f=MI2_EventSelfBuff, basic=1, items=1},

		CHAT_MSG_COMBAT_HOSTILE_DEATH = {f=MI2_EventHostileDeath, char=1},
		UNIT_DIED = {f=MI2_UnitDied, char=1},
		CHAT_MSG_COMBAT_SELF_HITS = {f=MI2_EventSelfMelee, char=1},
		CHAT_MSG_SPELL_SELF_DAMAGE = {f=MI2_EventSelfSpell, char=1},
		CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE = {f=MI2_EventSpellPeriodic, char=1},
		CHAT_MSG_COMBAT_PET_HITS = {f=MI2_EventPetMelee, char=1},
		CHAT_MSG_SPELL_PET_DAMAGE = {f=MI2_EventPetSpell, char=1},
	}

	-- event table modification required for chinese localisation
	if ( MI2_Locale == "zhTW" ) then
		MI2_EventHandlers.CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE.f = MI2_EventSpellPeriodic_ZHTW
		MI2_EventHandlers.CHAT_MSG_SPELL_SELF_BUFF.f = MI2_EventSelfBuff_ZHTW

	end

	MI2_ChatScanStrings = {
		[1] = OPEN_LOCK_SELF,
		[2] = SELFKILLOTHER,
		[3] = COMBATLOG_XPGAIN_FIRSTPERSON,
		[4] = COMBATHITSELFOTHER,
		[5] = COMBATHITCRITSELFOTHER,
		[6] = SPELLLOGSELFOTHER,
		[7] = SPELLLOGSCHOOLSELFOTHER,
		[8] = SPELLLOGCRITSELFOTHER,
		[9] = PERIODICAURADAMAGESELFOTHER,
		[10] = COMBATHITOTHEROTHER,
		[11] = COMBATHITCRITOTHEROTHER,
		[12] = SPELLLOGOTHEROTHER,
		[13] = SPELLLOGCRITOTHEROTHER,
		[14] = IMMUNESPELLSELFOTHER,
		[15] = SPELLIMMUNESELFOTHER,
		[16] = SPELLRESISTSELFOTHER,
		[17] = SPELLLOGCRITSCHOOLSELFOTHER,
		[18] = AURAADDEDOTHERHARMFUL, }

	for idx, scanString in pairs(MI2_ChatScanStrings) do
		scanString = string.gsub(scanString, "%(", "%%%(")
		scanString = string.gsub(scanString, "%)", "%%%)")
		scanString = string.gsub(scanString, "(%%s)", "%(%.%+%)")
		scanString = string.gsub(scanString, "(%%%d$s)", "%(%.%+%)")
		scanString = string.gsub(scanString, "(%%d)", "%(%%%d%+%)")
		scanString = string.gsub(scanString, "(%%%d$d)", "%(%%%d%+%)")
		MI2_ChatScanStrings[idx] = scanString
	end

	-- process no other events until "VARIABLES_LOADED"
	this:RegisterEvent("VARIABLES_LOADED")

	-- prepare for importing external database data
	-- this must be done before "VARIABLES_LOADED" overwrites import data
	MI2_PrepareForImport()
	MI2_DeleteAllMobData()
	MobHealthDB	= {}
	MobHealthPlayerDB = {}

	-- set some stuff that is needed (only) for improved compatibility
	-- to other AddOns wanting to use MobHealth info
	if  not MobHealth_OnEvent  then
		MobHealthFrame = "MI2"
		MobHealth_OnEvent = MI2_OnEvent
	end
end -- MI2_OnLoad()
