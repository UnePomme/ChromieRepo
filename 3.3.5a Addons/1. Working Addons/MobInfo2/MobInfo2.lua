--
-- MobInfo.lua
--
-- Main module of MobInfo-2 AddOn
miVersionNo = 'v3.75'
--
-- MobInfo-2 is a World of Warcraft AddOn that provides you with useful
-- additional information about Mobs (ie. opponents/monsters). It adds
-- new information to the game's Tooltip when you hover with your mouse
-- over a mob. It also adds a numeric display of the Mobs health
-- and mana (current and max) to the Mob target frame.
--
-- MobInfo-2 is the continuation of the original "MobInfo" by Dizzarian,
-- combined with the original "MobHealth2" by Wyv. Both Dizzarian and
-- Wyv sadly no longer play WoW and stopped maintaining their AddOns.
-- I have "inhereted" MobInfo from Dizzarian and MobHealth-2 from Wyv
-- and now continue to update and improve the united result.
--

-- global vars
MI2_Debug = 0  -- 0=no debug info, 1=activate debug info
MI2_DebugItems = 0  -- 0=no item debug info, 1=show item ID and item value in tooltip
MI2_DebugEvents = 0  -- 0=no item event info, 1=show decoded events, 2=show all incoming events

MI2_DB_VERSION = 9
MI2_DB_SV = 2
MI2_IMPORT_DB_VERSION = 7

local MI2_RecentLoots, MI2_MobCache, MI2_MobCacheIdx, MI2_XRefItemTable
local MI2_NewCorpseIdx = 0
local MI2_CurrentCorpseIndex = nil
local MI2_RecentLoots = {}
local MI2_SpellToSchool = {}
local MI2_CACHE_SIZE = 30

-- PTR code
local _, _, _, tocVersion = GetBuildInfo()

-- skinning loot table using localization independant item IDs:
--    Ruined Leather Scraps, Light Leather, Medium Leather, Heavy Leather, Thick Leather, Rugged Leather
--    Chimera Leather, Devilsaur Leather, Frostsaber Leather, Warbear Leather, Core Leather, Thin Kodo Leather, Crystal Infused Leather
--    Knothide Leather Scraps, Knothide Leather, Broken Silithid Chitin, Silithid Chitin, Fel Scales, Fel Hide
--    Light Hide, Medium Hide, Heavy Hide, Thick Hide, Rugged Hide, Shadowcat Hide, Thick Wolfhide
--    Scorpid Scale, Red Whelp Scales, Turtle Scales, Black Whelp Scales, Brilliant Chromatic Scale
--    Black Dragonscale, Blue Dragonscale, Red Dragonscale, Green Dragonscale, Worn Dragonscale, Heavy Scorpid Scale
--    deviate scale, perfect deviate scale, green whelp scale, worn dragonscale
--    Shadow Draenite, Crystalline Fragments, Flame Spessarite
--    Thick Clefthoof Leather, Nether Dragonscales, Cobra Scales, Wind Scales
-- 
-- skinning loot items that you only get with herbalism:
--    Zangar Caps, Mote of Life, Ancient Lichen, Felweed, Small Mushroom, Terocone 
--
-- removed "Shiny Fish Scales" ([17057]=1,) because its also normal loot
--
local miSkinLoot = { [2934]=1, [2318]=1, [2319]=1, [4234]=1, [4304]=1, [8170]=1,
                    [15423]=1,[15417]=1,[15422]=1,[15419]=1,[17012]=1, [5082]=1, [25699]=1,
                    [21887]=1,[25649]=1,[20499]=1,[20498]=1,[25700]=1,[25707]=1,
                      [783]=1, [4232]=1, [4235]=1, [8169]=1, [8171]=1, [7428]=1, [8368]=1,
                     [8154]=1, [7287]=1, [8167]=1, [7286]=1,[12607]=1,
                    [15416]=1,[15415]=1,[15414]=1,[15412]=1, [8165]=1,[15408]=1,
                     [6470]=1, [6471]=1, [7392]=1, [8165]=1,
                    [23107]=1,[24189]=1,[21929]=1,
					[27859]=1,[22575]=1,[22790]=1,[22785]=1,[25813]=1,[22789]=1,
                    [25708]=1,[29548]=1,[29539]=1,[29547]=1 }

-- cloth loot table using localization independant item IDs
-- Linen Cloth, Wool Cloth, Silk Cloth, Mageweave Cloth, Felcloth, Runecloth, Mooncloth, Netherweave
local miClothLoot = { [2589]=1, [2592]=1, [4306]=1, [4338]=1, [14256]=1, [14047]=1, [14342]=1, [21877 ]=1 };

local MI2_CollapseList = { [2725]=2725, [2728]=2725, [2730]=2725, [2732]=2725,
                           [2734]=2725, [2735]=2725, [2738]=2725, [2740]=2725, [2742]=2725,
                           [2745]=2725, [2748]=2725, [2749]=2725, [2750]=2725, [2751]=2725 }

-- global MobInfo color constansts
MI_Red = "|cffff1010"
MI_Green = "|cff00ff00"
MI_Blue = "|cff0000ff"
MI_White = "|cffffffff"
MI_Gray = "|cff888888"
MI_Yellow  = "|cffffff00"
MI_Cyan   = "|cff00ffff"
MI_Orange = "|cffff7000"
MI_Gold = "|cffffcc00"
MI_Mageta = "|cffe040ff"
MI_ItemBlue = "|cff2060ff"
MI_LightBlue = "|cff00e0ff"
MI_LightGreen = "|cff60ff60"
MI_LightRed = "|cffff5050"
MI_SubWhite = "|cffbbbbbb"
MI2_QualityColor = { MI_Gray, MI_White, MI_Green, MI_ItemBlue, MI_Mageta, MI_Orange, MI_Red }


-----------------------------------------------------------------------------
-- MI2_GetMobData( mobName, mobLevel [, unitId] )
--
-- Get and return all the data that MobInfo knows about a given mob.
-- This is an externally available interface function that can be
-- called by other AddOns to access MobInfo data. It should be fast,
-- efficient, and easy to use
--
-- The data describing a Mob is returned in table form as described below.
--
-- To identify the mob you must supply its name and level. You can
-- optionally supply a "unitId" to get additional info:
--   mobName : name of mob, eg. "Forest Lurker"
--   mobLevel : mob level as integer number
--   unitId : optional WoW unit identification, should be either
--            "target" or "mouseover"
--
-- Examples:
--    A.   mobData = MI2_GetMobData( "Forest Lurker", 10 )
--    B.   mobData = MI2_GetMobData( "Forest Lurker", 10, "target" )
--
-- Return Value:
-- The return value is a LUA table with one table entry for each value that
-- MobInfo can know about a Mob. Note that table entries exist ONLY if the
-- corresponding value has actually been collected for the given Mob.
-- Unrecorded values do NOT exist in the table and thus evaluate to a NIL
-- expression.
--
-- Values you can get without "unitId" (as per Example A above):
--    mobData.healthMax  :  health maximum
--    mobData.xp         :  experience value
--    mobData.kills      :  number of times current player has killed this mob
--    mobData.minDamage  :  minimum damage done by mob
--    mobData.maxDamage  :  maximum damage done by mob
--    mobData.dps        :  dps of Mon against current player
--    mobData.loots      :  number of times this mob has been looted
--    mobData.emptyLoots :  number of times this mob gave empty loot
--    mobData.clothCount :  number of times this mob gave cloth loot
--    mobData.copper     :  total money loot of this mob as copper amount
--    mobData.itemValue  :  total item value loot of this mob as copper amount
--    mobData.mobType    :  mob type for special mobs: 1=normal, 2=rare/elite, 3=boss
--    mobData.r1         :  number of rarity 1 loot items (grey)
--    mobData.r2         :  number of rarity 2 loot items (white)
--    mobData.r3         :  number of rarity 3 loot items (green)
--    mobData.r4         :  number of rarity 4 loot items (blue)
--    mobData.r5         :  number of rarity 5 loot items (purple)
--    mobData.itemList   :  table that lists all recorded items looted from this mob
--                          table entry index gives WoW item ID, 
--                          table entry value gives item amount
--
-- Additional values you will get with "unitId" (as per Example B above):
--    mobData.class      :  class of mob as localized text
--    mobData.healthCur  :  current health of given unit
--    mobData.manaCur    :  current mana of given unit
--    mobData.manaMax    :  maximum mana for given unit
--
-- Code Example:
--    
--    local mobData = MI2_GetMobData( "Forest Lurker", 10 )
--    
--    if mobData.xp then
--        DEFAULT_CHAT_FRAME:AddMessage( "XP = "..mobData.xp ) 
--    end
--    
--    if mobData.copper and mobData.loots then
--        local avgLoot = mobData.copper / mobData.loots
--        DEFAULT_CHAT_FRAME:AddMessage( "average loot = "..avgLoot ) 
--    end
--
function MI2_GetMobData( mobName, mobLevel, unitId )
	if not mobName or not mobLevel then return end

	local mobData = {}
	local mobIndex = mobName..":"..mobLevel

	-- decode unit specific mob data that is not recorded in mob database
	if unitId then
		MI2_GetUnitBasedMobData( mobIndex, mobData, unitId, mobLevel )
	end

	-- access Mob database and decode the data
	local mobInfo = MobInfoDB[mobIndex]
	if  mobInfo then
		MI2_GetMobDataFromMobInfo( mobInfo, mobData )
	end

	return mobData
end -- MI2_GetMobData()


-----------------------------------------------------------------------------
-- MI2_InitOptions()
--
-- initialize MobInfo configuration options
-- this takes into account new options that have been added to MobInfo
-- in the course of developement
--
 function MI2_InitOptions()
	-- defaults for all MobInfo config options
	local MI2_OptDefaults = {
		ShowHealth=1, ShowMana=0, ShowXp=1, ShowNo2lev=1, ShowKills=0, ShowLoots=1, ShowTotal=1,
		ShowCoin=0, ShowIV=0, ShowEmpty=0, ShowLowHpAction=1, ShowCloth=1, ShowDamage=1,
		ShowDps=1, ShowLocation=1, ShowQuality=1, ShowResists=1, ShowImmuns=1, ShowItems=1,
		ShowClothSkin=1, MouseTooltip=1, SaveBasicInfo=1, KeypressMode = 0, SavePlayerHp = 0,
		ShowMobInfo=1, ShowItemInfo=1, ShowTargetInfo=1, ShowMMButton=1, MMButtonPos=257,
		TooltipMode=4, SmallFont=1, OtherTooltip=1, ShowLowHpAction=1, ShowItems=1,
		ShowClothSkin=1, TargetFontSize=10, TargetHealth=1, TargetMana=1, HealthPercent=1,
		ManaPercent=1, HealthPosX=-7, HealthPosY=11, ManaPosX=-7, ManaPosY=11, TargetFont=2,
		CompactMode=1, SaveItems=1, SaveCharData=1, ItemsQuality=2, ItemTooltip=1,
		ItemFilter="", ImportOnlyNew=1, SaveResist=1, ShowItemPrice = 0, CombinedMode = 0,
		UseGameTT=0, HideAnchor=0, ShowIGrey=0, ShowIWhite=1, ShowIGreen=1, ShowIBlue=1, ShowIPurple=1 } 

	-- initialize MobInfoConfig 
	if not MobInfoConfig then
		MobInfoConfig = { }
	end

	-- make the 2 column layout active by default 
	if MobInfoConfig.ShowBlankLines then MobInfoConfig.CompactMode = 1 end
	if MobInfoConfig.MMButtonPos == 20 then MobInfoConfig.MMButtonPos = 356 end

	-- config values that no longer exist
	MobInfoConfig.OptStableMax = nil -- removed in 3.20
	MobInfoConfig.DisableMobInfo = nil -- removed in 3.40
	MobInfoConfig.ShowBlankLines = nil -- removed in 3.40
	MobInfoConfig.ShowCombined = nil -- removed in 3.40

	--if  not MobInfoConfig.ShowCombined	then  MobInfoConfig.ShowCombined = 1	end
	--MobInfoConfig.ShowCombined = 0

	-- initial defaults for all config options
	local idx, opt, name
	for idx,def in pairs(MI2_OptDefaults) do
		if not MobInfoConfig[idx] then
			MobInfoConfig[idx] = def
		end
	end
end -- MI2_InitOptions()


-- MI2_GetMobDataFromMobInfo()
--
-- Extract all data describing a specific mob from a given mob database
-- record (called "mobInfo"). The mobInfo data is in a compressed format
-- that requires decoding to make it usable.
--
function MI2_GetMobDataFromMobInfo( mobInfo, mobData )
	MI2_DecodeBasicMobData( mobInfo, mobData )
	MI2_DecodeCharData( mobInfo, mobData, MI2_PlayerName )
	MI2_DecodeQualityOverview( mobInfo, mobData )
	MI2_DecodeMobLocation( mobInfo, mobData )
	MI2_DecodeItemList( mobInfo, mobData )
	MI2_DecodeResists( mobInfo, mobData )
end -- MI2_GetMobDataFromMobInfo()


-----------------------------------------------------------------------------
-- MI2_GetUnitBasedMobData()
--
-- Obtain and store all unit specific mob data.
--
function MI2_GetUnitBasedMobData( mobIndex, mobData, unitId )
    -- get mobs PPP and calculate max health (can be done without unitId)
	local mobPPP = MobHealth_PPP(mobIndex)
	if mobPPP <= 0 then mobPPP = 1 end
	mobData.healthMax = floor(mobPPP * 100 + 0.5)
	if not unitId then 
		mobData.healthText = "0/"..mobData.healthMax
		return
	end

	-- obtain unit specific values if unitId is given
	if UnitHealthMax(unitId) == 100 then
		mobData.healthCur = floor(mobPPP * UnitHealth(unitId) + 0.5)
	else
		mobData.healthCur = UnitHealth(unitId)
	end
	mobData.manaCur = UnitMana( unitId )
	mobData.manaMax = UnitManaMax( unitId )
	mobData.healthText = mobData.healthCur.."/"..mobData.healthMax
	if mobData.manaMax > 0 then
		mobData.manaText = mobData.manaCur.."/"..mobData.manaMax
	end

	local mobType = UnitClassification(unitId)
	if mobType == "rare" or mobType == "elite" then
		mobData.mobType = 2
	elseif mobType == "rareelite" or mobType == "worldboss" then
		mobData.mobType = 3
	else
		mobData.mobType = 1
	end
end -- MI2_GetUnitBasedMobData()


-----------------------------------------------------------------------------
-- MI2_FetchMobData()
--
-- Internal function for accessing a mobData record
-- This function implements a caching mechanism for faster access
-- to database records. The cache stores the last 30 Mob records.
-- Data returned by "MI2_FetchMobData()" should NOT be modified because
-- modifications are written back into the main database file.
--
function MI2_FetchMobData( mobIndex, unit )
	local mobData = MI2_MobCache[mobIndex]
	if mobIndex and not mobData then
		local mobInfo = MobInfoDB[mobIndex]
		mobData = { mobType=1, resists={} }
		if mobInfo then
			MI2_GetMobDataFromMobInfo( mobInfo, mobData )
		end
		MI2_MobCache[mobIndex] = mobData

		local oldMob = MI2_MobCache[MI2_MobCacheIdx]
		if oldMob then
			MI2_MobCache[oldMob] = nil
		end

		MI2_MobCache[MI2_MobCacheIdx] = mobIndex
		MI2_MobCacheIdx = MI2_MobCacheIdx + 1
		if MI2_MobCacheIdx > MI2_CACHE_SIZE then
			MI2_MobCacheIdx = 1
		end
	end

	if mobData then
		MI2_GetUnitBasedMobData( mobIndex, mobData, unit )
	end

	return mobData
end -- MI2_FetchMobData()


-----------------------------------------------------------------------------
-- MI2_FetchCombinedMob()
--
-- handle combined Mob mode : try to find the other Mobs with same
-- name but differing level, add their data to the tooltip data
--
function MI2_FetchCombinedMob( mobName, mobLevel, unit )
	local combined = {}
	local minL, maxL = mobLevel, mobLevel

	if  MobInfoConfig.CombinedMode == 1 and mobLevel > 0 then
		for level = mobLevel-4, mobLevel+4, 1 do
			if level ~= mobLevel  then
				local mobIndex = mobName..":"..level
				if MobInfoDB[mobIndex] then
					local dataToCombine = MI2_FetchMobData( mobIndex )
					MI2_AddTwoMobs( combined, dataToCombine )
					minL = min( minL, level )
					maxL = max( maxL, level )
				end
			end
		end
	end

	local mobIndex = mobName..":"..mobLevel
	local mobData = MI2_FetchMobData( mobName..":"..mobLevel )
	MI2_AddTwoMobs( combined, mobData )
	MI2_GetUnitBasedMobData( mobIndex, combined, unit )

	combined.levelInfo = minL
	if minL ~= maxL then
		combined.levelInfo = minL.."-"..maxL
	end

	return combined
end

-----------------------------------------------------------------------------
-- MI2_DecodeBasicMobData()
--
-- Decode the basic mob data. This function is used by the public
-- "MI2_GetMobData()" and also by the Mob search routines.
--
function MI2_DecodeBasicMobData( mobInfo, mobData, mobIndex )
	if mobIndex then
		mobInfo = MobInfoDB[mobIndex]
	end

	-- decode mob basic info: loots, empty loots, experience, cloth count, money looted, item value looted, mob type
	if mobInfo.bi then
		local _,_,lt,el,cp,iv,cc,_,mt,sc = string.find( mobInfo.bi, "(%d*)/(%d*)/(%d*)/(%d*)/(%d*)/(%d*)/(%d*)/(%d*)")
		mobData.loots		= tonumber(lt)
		mobData.emptyLoots	= tonumber(el)
		mobData.clothCount	= tonumber(cc)
		mobData.copper		= tonumber(cp)
		mobData.itemValue	= tonumber(iv)
		mobData.mobType		= tonumber(mt)
		mobData.skinCount	= tonumber(sc)
	end

	if mobData.mobType and mobData.mobType > 10 then
		mobData.lowHpAction = floor(mobData.mobType / 10)
		mobData.mobType = mobData.mobType - mobData.lowHpAction * 10
	end
end -- MI2_DecodeBasicMobData()


-----------------------------------------------------------------------------
-- MI2_DecodeMobLocation()
--
-- Decode mob location info, skip invalid location data
-- The location is encoded in the mob record entry "ml".
-- The decoded data is stored in the given "mobData" structure.
--
function MI2_DecodeMobLocation( mobInfo, mobData, mobIndex )
	if mobIndex then
		mobInfo = MobInfoDB[mobIndex]
	end

	if mobInfo.ml then
		local a,b,x1,y1,x2,y2,c,z = string.find( mobInfo.ml, "(%d*)/(%d*)/(%d*)/(%d*)/(%d*)/(%d*)")
		mobData.location = {}
		mobData.location.x1	= tonumber(x1)
		mobData.location.y1	= tonumber(y1)
		mobData.location.x2	= tonumber(x2)
		mobData.location.y2	= tonumber(y2)
		mobData.location.c	= tonumber(c)
		mobData.location.z	= (tonumber(z) or 0)
		if not mobData.location.x1 or not mobData.location.x2 or 
				not mobData.location.y1 or not mobData.location.y2 or 
				mobData.location.z == 0 then
			mobData.location = nil
		end
	end
end -- MI2_DecodeMobLocation()


-----------------------------------------------------------------------------
-- MI2_DecodeQualityOverview()
--
-- Decode item quality data: loot count per item rarity category
-- The loot items quality overview is encoded in the mob record entry "qi".
-- The decoded data is stored in the given "mobData" structure.
--
function MI2_DecodeQualityOverview( mobInfo, mobData, mobIndex )
	if mobIndex then
		mobInfo = MobInfoDB[mobIndex]
	end

	if mobInfo.qi then
		local a,b,r1,r2,r3,r4,r5 = string.find( mobInfo.qi, "(%d*)/(%d*)/(%d*)/(%d*)/(%d*)")
		mobData.r1	= tonumber(r1)
		mobData.r2	= tonumber(r2)
		mobData.r3	= tonumber(r3)
		mobData.r4	= tonumber(r4)
		mobData.r5	= tonumber(r5)
	end
end -- MI2_DecodeQualityOverview


-----------------------------------------------------------------------------
-- MI2_DecodeCharData()
--
-- Decode char specific data: number of kills, min damage, max damage, dps, xp
-- Player specific data is encoded in mob record entries starting with
-- the lowercase letter "c" plus a player name index number, eg. "c7",
-- this is called the player ID code. The playerName parameter must give
-- the player ID code for the player data to decode.
-- The decoded data is stored in the given "mobData" structure.
-----------------------------------------------------------------------------
function MI2_DecodeCharData( mobInfo, mobData, playerName, mobIndex )
	if mobIndex then
		mobInfo = MobInfoDB[mobIndex]
	end

	if mobInfo[playerName] then
		local a,b,kl,mind,maxd,dps,xp = string.find( mobInfo[playerName], "(%d*)/(%d*)/(%d*)/(%d*)/*(%d*)")
		mobData.kills		= tonumber(kl)
		mobData.minDamage	= tonumber(mind)
		mobData.maxDamage	= tonumber(maxd)
		mobData.dps			= tonumber(dps)
		if xp then
			mobData.xp		= tonumber(xp)
		end
	end
end -- MI2_DecodeCharData


-----------------------------------------------------------------------------
-- MI2_DecodeResists()
--
-- Decode mob resistances and immunities info
-- The location is encoded in the mob record entry "re".
-- The decoded data is stored in the given "mobData" structure.
--
function MI2_DecodeResists( mobInfo, mobData, mobIndex )
	if mobIndex then
		mobInfo = MobInfoDB[mobIndex]
	end

	if mobInfo.re then
		local a,b,ar,arHits,fi,fiHits,fr,frHits,ho,hoHits,na,naHits,sh,shHits = string.find( mobInfo.re, "(%-?%d*),(%-?%d*)/(%-?%d*),(%-?%d*)/(%-?%d*),(%-?%d*)/(%-?%d*),(%-?%d*)/(%-?%d*),(%-?%d*)/(%-?%d*),(%-?%d*)")
		mobData.resists = {}
		mobData.resists.ar	= tonumber(ar)
		mobData.resists.fi	= tonumber(fi)
		mobData.resists.fr	= tonumber(fr)
		mobData.resists.ho	= tonumber(ho)
		mobData.resists.na	= tonumber(na)
		mobData.resists.sh	= tonumber(sh)
		mobData.resists.arHits	= tonumber(arHits)
		mobData.resists.fiHits	= tonumber(fiHits)
		mobData.resists.frHits	= tonumber(frHits)
		mobData.resists.hoHits	= tonumber(hoHits)
		mobData.resists.naHits	= tonumber(naHits)
		mobData.resists.shHits	= tonumber(shHits)
	end
end -- MI2_DecodeMobLocation()


-----------------------------------------------------------------------------
-- MI2_DecodeItemList()
--
-- Decode the item list encoded in the "il" string of a mobInfo database
-- record. The result is stored in the given mobData record as a new
-- record field called "itemList".
--
function MI2_DecodeItemList( mobInfo, mobData, mobIndex )
	if mobIndex then
		mobInfo = MobInfoDB[mobIndex]
	end

	if mobInfo.il then
		local lootItems = mobInfo.il
		local s,e, item, amount = string.find( lootItems, "(%d+)[:]?(%d*)" )
		if e then mobData.itemList = {} end
		while e do
			mobData.itemList[tonumber(item)] = tonumber(amount) or 1
			s,e, item, amount = string.find( lootItems, "/(%d+)[:]?(%d*)", e+1 )
		end
	end
end -- MI2_DecodeItemList()


-----------------------------------------------------------------------------
-- MI2_StoreBasicInfo()
--
-- Store the mob basic info in the mob database. Basic info includes the
-- mob loot quality overview counters.
--
local function MI2_StoreBasicInfo( mobIndex, mobData )
	local mobInfo = MobInfoDB[mobIndex]
	if not mobInfo then
		mobInfo = {}
		MobInfoDB[mobIndex] = mobInfo
	end

	-- encode the mobs low hp action within the mob type value
	local mobType = mobData.mobType
	if mobData.lowHpAction then
		mobType = (mobType or 1) + mobData.lowHpAction * 10
	end

	-- no need to store a mobType of 1 (normal mobs)
	if mobType == 1 then
		mobType = nil
	end

	local basicInfo = (mobData.loots or "").."/"..(mobData.emptyLoots or "").."/"..(mobData.copper or "").."/"..(mobData.itemValue or "").."/"..(mobData.clothCount or "").."//"..(mobType or "").."/"..(mobData.skinCount or "")
	if basicInfo ~= "///////" then
		mobInfo.bi = basicInfo
	end

	local qualityInfo = (mobData.r1 or "").."/"..(mobData.r2 or "").."/"..(mobData.r3 or "").."/"..(mobData.r4 or "").."/"..(mobData.r5 or "")
	if qualityInfo ~= "////" then
		mobInfo.qi = qualityInfo
	end
end -- MI2_StoreBasicInfo()


-----------------------------------------------------------------------------
-- MI2_StoreLocation()
--
-- Store the mob location data in the mob database.
--
function MI2_StoreLocation( mobIndex, loc )
	if not loc then return end
	local mobInfo = MobInfoDB[mobIndex]
	if not mobInfo then
		mobInfo = {}
		MobInfoDB[mobIndex] = mobInfo
	end

	local locationInfo = (loc.x1 or "").."/"..(loc.y1 or "").."/"..(loc.x2 or "").."/"..(loc.y2 or "").."//"..(loc.z or "")
	if locationInfo ~= "/////" then
		mobInfo.ml = locationInfo
	end
end -- MI2_StoreLocation()


-----------------------------------------------------------------------------
-- MI2_StoreCharData()
--
-- Store the char specific mob data in the mob database.
--
local function MI2_StoreCharData( mobIndex, mobData, playerName )
	local mobInfo = MobInfoDB[mobIndex]
	if not mobInfo then
		mobInfo = {}
		MobInfoDB[mobIndex] = mobInfo
	end

	local playerInfo = (mobData.kills or "").."/"..(mobData.minDamage or "").."/"..(mobData.maxDamage or "").."/"..(mobData.dps or "").."/"..(mobData.xp or "")
	if playerInfo ~= "////" then
		mobInfo[playerName] = playerInfo
	end
end -- MI2_StoreCharData()


-----------------------------------------------------------------------------
-- MI2_StoreLootItems()
--
-- Store a mobs loot items list in mob database.
--
local function MI2_StoreLootItems( mobIndex, mobData )
	local mobInfo = MobInfoDB[mobIndex]
	if not mobInfo then
		mobInfo = {}
		MobInfoDB[mobIndex] = mobInfo
	end

	-- create loot item list string for database
	local itemList = ""
	if mobData.itemList then
		local prefix = ""
		for itemID, amount in pairs(mobData.itemList) do
			itemList = itemList..prefix..itemID
			if amount > 1 then
				itemList = itemList..":"..amount
			end
			prefix = "/"
		end
	end

	if itemList ~= "" then
		mobInfo.il = itemList
	end
end -- MI2_StoreLootItems()


-----------------------------------------------------------------------------
-- MI2_StoreResistData()
--
-- Store resist data for mob in mob database. Data will only be saved if
-- resistances exist.
--
function MI2_StoreResistData( mobIndex )
	local mobData = MI2_FetchMobData( mobIndex )
	resData = mobData.resists

	-- store only if resistances exist
	if resData.ar or resData.fi or resData.fr or resData.ho or resData.na or resData.sh then
		local mobInfo = MobInfoDB[mobIndex]
		if not mobInfo then
			mobInfo = {}
			MobInfoDB[mobIndex] = mobInfo
		end
		local resistString = 
				(resData.ar or "")..","..(resData.arHits or "").."/"..
				(resData.fi or "")..","..(resData.fiHits or "").."/"..
				(resData.fr or "")..","..(resData.frHits or "").."/"..
				(resData.ho or "")..","..(resData.hoHits or "").."/"..
				(resData.na or "")..","..(resData.naHits or "").."/"..
				(resData.sh or "")..","..(resData.shHits or "")
		mobInfo.re = resistString
	end
end -- MI2_StoreResistData()


-----------------------------------------------------------------------------
-- MI2_StoreAllMobData()
--
-- Store all recorded data for a given mob in the mob database.
--
function MI2_StoreAllMobData( mobData, mobName, mobLevel, playerName, mobIndex )
	if not mobIndex then
		mobIndex = mobName..":"..mobLevel
	end

	if MobInfoConfig.SaveBasicInfo == 1 then
		MI2_StoreBasicInfo( mobIndex, mobData )
		MI2_StoreLocation( mobIndex, mobData.location )
	end

	if MobInfoConfig.SaveCharData == 1 then
		MI2_StoreCharData( mobIndex, mobData, MI2_PlayerName )
	end

	if MobInfoConfig.SaveItems == 1 then
		MI2_StoreLootItems( mobIndex, mobData )
	end

	if MobInfoConfig.SaveResist == 1 then
		MI2_StoreResistData( mobIndex )
	end
end -- MI2_StoreAllMobData()


-----------------------------------------------------------------------------
-- MI2_RemoveCharData()
--
-- Remove all char specific data from the given Mob database record.
--
function MI2_RemoveCharData( mobInfo )
	for entryName, entryData in pairs(mobInfo) do
		if entryName ~= "bi" and entryName ~= "qi" and entryName ~= "il" and entryName ~= "ml" and entryName ~= "ver" then
			mobInfo[entryName] = nil
		end
	end
end -- MI2_RemoveCharData()


-----------------------------------------------------------------------------
-- MI2_DeleteMobData()
--
-- Delete data for a specific Mob from database and current target table.
--
function MI2_DeleteMobData( mobIndex, deleteHealth )
	if mobIndex then
		MobInfoDB[mobIndex] = nil
		MI2_MobCache[mobIndex] = nil
		if deleteHealth then
			MobHealthDB[mobIndex] = nil
		end
		if mobIndex == MI2_Target.mobIndex then
			MI2_Target = {}
			MobHealth_Display()
		end
	end
end  -- MI2_DeleteMobData()


-----------------------------------------------------------------------------
-- MI2_DeleteItemFromDB()
--
-- Delete data for a specific Mob from database and current target table.
--
function MI2_DeleteItemFromDB( itemID )
	for mobIndex, mobInfo in pairs(MobInfoDB) do
		local mobData = {}
		MI2_DecodeItemList( mobInfo, mobData )
		if mobData.itemList then
			mobData.itemList[itemID] = nil
			MI2_StoreLootItems( mobIndex, mobData )
		end
	end
	MI2_ItemNameTable[itemID] = nil
end  -- MI2_DeleteItemFromDB()


-----------------------------------------------------------------------------
-- MI2_SetPlayerName()
--
-- Set the global MobInfo player name. This is the abbreviated player name
-- that is just an index into the MobInfo player name table, where the real
-- name of the player is stored.
--
function MI2_SetPlayerName()
	local charName = GetCVar( "realmName" )..':'..UnitName("player")
	if not MI2_CharTable[charName] then
		MI2_CharTable.charCount = MI2_CharTable.charCount + 1
		MI2_CharTable[charName] = "c"..MI2_CharTable.charCount
	end
	MI2_PlayerName = MI2_CharTable[charName]
end -- MI2_SetPlayerName()


-----------------------------------------------------------------------------
-- MI2_ClearMobCache()
--
-- Empty oput the mob data cache
--
function MI2_ClearMobCache()
	MI2_MobCache = {}
	MI2_MobCacheIdx = 1
end -- MI2_ClearMobCache


-----------------------------------------------------------------------------
-- MI2_DeleteAllMobData()
--
-- Delete entire Mob database and all related data tables
--
function MI2_DeleteAllMobData()
	MobInfoDB = { ["DatabaseVersion:0"] = { ver = MI2_DB_VERSION, loc=MI2_Locale, sv=MI2_DB_SV } }
	MI2_CharTable = { charCount = 0 }
	MI2_ItemNameTable = {}
	MI2_XRefItemTable = {}
	MI2_SetPlayerName()
	MI2_ClearMobCache()
	MI2_ZoneTable = { cnt = 1 }
end  -- MI2_DeleteAllMobData()


-----------------------------------------------------------------------------
-- chattext()
--
-- spits out msg to the chat channel.
--
function chattext(txt)
	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage( MI_LightBlue.."<MI2> "..txt)
	end
end -- chattext()


-----------------------------------------------------------------------------
-- midebug()
--
-- add debug message to chat channel, handle debug detail level if given
--
function midebug( txt, dbgLevel )
	if DEFAULT_CHAT_FRAME then
		if dbgLevel then
			if dbgLevel <= MI2_Debug then
				DEFAULT_CHAT_FRAME:AddMessage( MI_LightBlue.."[MI2DBG] "..txt)
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage( MI_LightBlue.."<MI2DBG> "..txt)
		end
	end
end -- midebug()


-----------------------------------------------------------------------------
-- MI2_IndexComponents()
--
-- Return the component parts of a mob index: mob name, mob level
--
function MI2_GetIndexComponents( mobIndex )
	local a, b, mobName, mobLevel = string.find(mobIndex, "(.+):(.+)$")
	mobLevel = tonumber(mobLevel)
	return mobName, mobLevel
end  -- MI2_IndexComponents()


-----------------------------------------------------------------------------
-- MI2_UpdateDatabaseV7ToV8()
--
-- update database from V7 to V8 : add all zones to the MobInfo
-- zone table and give them new zone IDs, index the zone table
-- by ID instead of name
--
local function MI2_UpdateDatabaseV7ToV8()
	local zoneName, zoneId, mobIndex, mobInfo, newZoneTable

	-- swap index with name in zone table
	newZoneTable = {}
	MI2_ZoneTable.cnt = nil
	for zoneName, zoneId in pairs(MI2_ZoneTable) do
		newZoneTable[zoneId] = zoneName
	end
	MI2_ZoneTable = newZoneTable
	MI2_ZoneTable.cnt = 0

	-- add names of ALL zones to zone table and store
	-- the new zone ID in mob data
	for mobIndex, mobInfo in pairs(MobInfoDB) do
		local mobData = {}
		MI2_DecodeMobLocation( mobInfo, mobData )
		if mobData.location then
			local zone = mobData.location.z
			if zone < 100 then
			    -- remove old style V7 zone IDs because after WoW 2.0 it has
				-- become impossible to correctly convert them
				mobInfo.ml = nil
			end
		end
	end
end -- MI2_UpdateDatabaseV7ToV8()


-----------------------------------------------------------------------------
-- MI2_UpdateDatabaseV8ToV9()
--
-- update database from V8 to V9 : health percent values 100 and 200 now
-- have special meaning, so make sure they do not occur in old health data
--
local function MI2_UpdateDatabaseV8ToV9( cleanupMode )
	for idx, hpData in pairs(MobHealthDB) do
	    if type(hpData) == "string" then
			local _,_, pts, pct = string.find( hpData, "^(%d+)/(%d+)$")
			pts = tonumber(pts)
			pct = tonumber(pct)
			if not pct or not pts or pct <= 0 or pts <= 0 then
				MobHealthDB[idx] = nil
			else
			    local newPts = floor( (pts / pct) * 75.0 )
				MobHealthDB[idx] = newPts.."/"..75
			end
		else
		    MobHealthDB[idx] = nil
		end
	end
end


-----------------------------------------------------------------------------
-- MI2_CheckAndCleanDatabases()
--
-- Cleanup for MobInfo database. This function corrects bugs in the
-- MobInfo database and applies changes that have been made to the
-- format of the actual database entires.
--
function MI2_CheckAndCleanDatabases()
	local mobIndex, mobInfo
	local dbVerInfo = MobInfoDB["DatabaseVersion:0"] or { ver=0 }
	local version = dbVerInfo.ver

	-- check : mob database version must exist 
	if MobInfoDB and version == 0 then
		StaticPopupDialogs["MOBINFO_SHOWMESSAGE"].text = MI_Red..MI_TXT_WRONG_DBVER
		local dialog = StaticPopup_Show( "MOBINFO_SHOWMESSAGE", "")
		MI2_DeleteAllMobData()
		return
	end

	-- check mob database locale against WoW client locale (must match)
	if dbVerInfo.loc and dbVerInfo.loc ~= MI2_Locale then
		StaticPopupDialogs["MOBINFO_SHOWMESSAGE"].text = MI_Red..MI_TXT_WRONG_LOC
		local dialog = StaticPopup_Show( "MOBINFO_SHOWMESSAGE", "")
		return
	end

	-- Initialise all database tables that do not exist
	MobInfoDB = MobInfoDB or {}
	MI2_CharTable = MI2_CharTable or { charCount = 0 }
	MI2_ItemNameTable = MI2_ItemNameTable or {}
	MI2_XRefItemTable = MI2_XRefItemTable or {}
	MI2_ZoneTable = MI2_ZoneTable or { cnt = 1 }
	MobHealthDB	= MobHealthDB or {}
	MobHealthPlayerDB =	MobHealthPlayerDB or {}
	MI2_SetPlayerName()
	MI2_ClearMobCache()

	MobInfoDB["DatabaseVersion:0"] = nil
	MobInfoDB.DatabaseVersion = nil

	-- update database to current version
	if version  < 8 then
		MI2_UpdateDatabaseV7ToV8()
	end
	local subver = dbVerInfo.sv or 0
	if version  < 9 or subver < 1 then
		MI2_UpdateDatabaseV8ToV9()
	end
	
	-- for SV 1 remove all mobs without basic info (bi)
	-- this cleans up after a bug that accidentally stored NPCs as mobs without bi
	if subver == 1 then
		for mobIndex, mobInfo in pairs(MobInfoDB) do
			if not mobInfo.bi then
				MobInfoDB[mobIndex] = nil
			end
		end
	end

	-- loop through database and remove mob with invalid name or level
	-- remove empty bi entries with just normal mob type set
	for mobIndex, mobInfo in pairs(MobInfoDB) do
		local mobName, mobLevel = MI2_GetIndexComponents( mobIndex )
		if not mobName or not mobLevel or mobName == "" then
			MobInfoDB[mobIndex] = nil
		end
		if mobInfo.bi == "//////1/" then
			mobInfo.bi = nil
		end
	end
	

	-- IDEAS :
	-- remove XP from all Mob records to store it correctly in the char data
	-- check for and fix bugs in the zone table
	-- check for and remove char entries without link to char table
	-- check for and remove char entries that have only XP entry
	-- check item linkage and remove incorrect item entries

	MobInfoDB["DatabaseVersion:0"] = { ver = MI2_DB_VERSION, loc=MI2_Locale, sv=MI2_DB_SV }
end  -- MI2_CheckAndCleanDatabases()


-----------------------------------------------------------------------------
-- MI2_PrepareForImport()
--
-- Prepare for importing external MobInfo databases into the main database.
--
function MI2_PrepareForImport()
	local mobDbSize, healthDbSize, itemDbSize = 0, 0, 0

	if not MobInfoDB or not MobInfoDB["DatabaseVersion:0"] then return end

	--	external database version number check
	local version = MobInfoDB["DatabaseVersion:0"].ver
	if version and (version < MI2_IMPORT_DB_VERSION or version > MI2_DB_VERSION) then
		MI2_Import_Status = "BADVER"
		return
	end

	local locale = MobInfoDB["DatabaseVersion:0"].loc
	if locale and locale ~= MI2_Locale then
		MI2_Import_Status = "BADLOC"
		return
	end

	-- calculate Mob database size and import signature
	local levelSum, nameSum = 0, 0
	for index in pairs(MobInfoDB) do
		mobDbSize = mobDbSize + 1
		local mobName, mobLevel = MI2_GetIndexComponents( index )
		levelSum = levelSum + mobLevel
		nameSum = nameSum + string.len( mobName )
	end
	for index in pairs(MobHealthDB) do  healthDbSize = healthDbSize + 1  end
	for index in pairs(MI2_ItemNameTable) do  itemDbSize = itemDbSize + 1  end
	MI2_Import_Signature = mobDbSize.."_"..healthDbSize.."_"..itemDbSize.."_"..levelSum.."_"..nameSum

	-- update the health database to be imported
	if version  < 9 then
		MI2_UpdateDatabaseV8ToV9()
	end

	-- store copy of databases to be imported and calculate import status
	MobInfoDB["DatabaseVersion:0"] = nil
	MobInfoDB_Import = MobInfoDB
	MI2_ItemNameTable_Import = MI2_ItemNameTable
	MI2_ZoneTable_Import = MI2_ZoneTable
	MobHealthDB_Import = MobHealthDB
	if mobDbSize > 1 then
		MI2_Import_Status = "[V"..version.."] "..(mobDbSize-1).." Mobs"
	end
	if healthDbSize > 0 then
		if MI2_Import_Status then
			MI2_Import_Status = MI2_Import_Status.." & "
		end
		MI2_Import_Status = (MI2_Import_Status or "")..healthDbSize.." HP values"
	end
end -- MI2_PrepareForImport()


-----------------------------------------------------------------------------
-- MI2_SetNewZone()
--
-- Set a new zone as the MI2 current zone. Add the zone to the MI2 zone
-- name table if zone is unknown.
--
function MI2_SetNewZone( zoneName )
	if not zoneName or zoneName == "" then return end

	-- find zone ID if zone is already known
	local name, id, zoneId
	for id, name in pairs(MI2_ZoneTable) do
		if name == zoneName then
			zoneId = id
			break
		end
	end

	-- add unknown zone to table
	if not zoneId then
		MI2_ZoneTable.cnt = MI2_ZoneTable.cnt + 1
		zoneId = 200 + MI2_ZoneTable.cnt
		MI2_ZoneTable[zoneId] = zoneName
	end

	MI2_CurZone = zoneId
end -- MI2_SetNewZone()


-----------------------------------------------------------------------------
-- MI2_AddItemToXRefTable()
--
-- update the cross reference table for fast item lookup
-- The table is indexed by item name and lists all Mobs that drop the item
--
local function MI2_AddItemToXRefTable( mobIndex, itemName, itemAmount )
	if not MI2_XRefItemTable[itemName] then
		MI2_XRefItemTable[itemName] = {}
	end

	local oldAmount = MI2_XRefItemTable[itemName][mobIndex]
	MI2_XRefItemTable[itemName][mobIndex] = (oldAmount or 0) + itemAmount
end -- MI2_AddItemToXRefTable()


-----------------------------------------------------------------------------
-- MI2_BuildXRefItemTable()
--
-- build the cross reference table for fast item lookup
-- The table is indexed by item name and lists all Mobs that drop the item.
-- It is needed for quickly generating the "Dropped By" list in item tooltips.
--
function MI2_BuildXRefItemTable()
	local mobIndex, mobInfo

	MI2_XRefItemTable = {}
	for mobIndex, mobInfo in pairs(MobInfoDB) do
		local mobData = {}
		MI2_DecodeItemList( mobInfo, mobData )
		if mobData.itemList then 
			for itemID, amount in pairs(mobData.itemList) do
				local itemText = MI2_ItemNameTable[itemID]
				if itemText then
					itemText = string.sub( itemText, 1, -3 )
					MI2_AddItemToXRefTable( mobIndex, itemText, amount )
				end
			end
		end
	end
end -- MI2_BuildXRefItemTable()


-----------------------------------------------------------------------------
-- MI2_CombineLocations()
--
-- Combine the location area of a given Mob with a second (new) location.
-- The "correctWrongZone" flag can be sued to force a correction if wrong
-- zones in mobData.
--
local function MI2_CombineLocations( mobData, loc2, correctWrongZone )
	local loc1 = mobData.location
	if loc1 or loc2 then
		if not loc1 or not loc1.z then
			mobData.location = loc2
		elseif loc2 then
			if loc1.z ~= loc2.z then
				if correctWrongZone then
					mobData.location = loc2
				end
			else
				if loc2.x1 < loc1.x1 then loc1.x1 = loc2.x1 end
				if loc2.x2 > loc1.x2 then loc1.x2 = loc2.x2 end
				if loc2.y1 < loc1.y1 then loc1.y1 = loc2.y1 end
				if loc2.y2 > loc1.y2 then loc1.y2 = loc2.y2 end
			end
		end
	end
end -- MI2_CombineLocations


-----------------------------------------------------------------------------
-- MI2_RecordLocationAndType()
--
-- Record the current player location as the Mob location, record the type
-- of the mob (normal, elite, boss). This function is intended to be called
-- when targetting or hovering a Mob.
--
function MI2_RecordLocationAndType( mobIndex, mobData )
	if MI2_MouseoverIndex == mobIndex then return end

	if MobInfoConfig.SaveBasicInfo == 1 then
		local x, y = GetPlayerMapPosition("player")
		x = floor( x * 100.0 )
		y = floor( y * 100.0 )
		local newLocation = { x1=x, x2=x, y1=y, y2=y, z=MI2_CurZone }
		MI2_CombineLocations( mobData, newLocation, true )
		MI2_StoreLocation( mobIndex, mobData.location )
	end

	if MobInfoConfig.SaveBasicInfo == 1 and mobData.mobType > 1 then
		MI2_StoreBasicInfo( mobIndex, mobData )
	end
end -- MI2_RecordLocationAndType()


-----------------------------------------------------------------------------
-- MI2_RecordLowHpAction()
--
-- Record for a Mob the special action that it performes when low on health.
-- E.g. run away
--
function MI2_RecordLowHpAction( creature, action )
	if MobInfoConfig.SaveBasicInfo == 1 and MI2_Target.mobIndex and MI2_Target.name == creature then
		local mobData = MI2_FetchMobData( MI2_Target.mobIndex )
		mobData.lowHpAction = action
		MI2_StoreBasicInfo( MI2_Target.mobIndex, mobData )
	end
end -- MI2_RecordLowHpAction()


-----------------------------------------------------------------------------
-- MI2_RecordKill()
--
-- record data related to a mob kill
-- attempt to find correct mob DB index based on situation and killed mobs
-- name (kill msg gives only name, not level)
--
function MI2_RecordKill( creatureName, xp )
	-- try to find DB index for mob that was killed
	local mobIndex
	if MI2_Target.name == creatureName then
		mobIndex = MI2_Target.mobIndex
	elseif MI2_LastTargetIdx and string.find(MI2_LastTargetIdx, creatureName) then
		mobIndex = MI2_LastTargetIdx
	else
		for i=1,MI2_CACHE_SIZE do
			local idx = MI2_MobCache[i]
			if idx and string.find(idx, creatureName) then
				mobIndex = idx
				break
			end
		end
	end

	if MobInfoConfig.SaveCharData == 1 and mobIndex then
		local mobData = MI2_FetchMobData( mobIndex )
		if xp then
			mobData.xp = xp
		end
		if (xp and not mobData.killed) or not xp then
			mobData.kills = (mobData.kills or 0) + 1
			mobData.killed = 1
		end
		MI2_StoreCharData( mobIndex, mobData, MI2_PlayerName )
	end
end -- MI2_RecordKill()


-----------------------------------------------------------------------------
-- MI2_RecordDamage()
--
-- record min/max damage value for mob
--
function MI2_RecordDamage( mobIndex, damage )
	if damage > 0 then
		local mobData = MI2_FetchMobData( mobIndex )
		if not mobData.minDamage or mobData.minDamage <= 0 then
			mobData.minDamage, mobData.maxDamage = damage, damage
		elseif damage < mobData.minDamage then
			mobData.minDamage = damage
		elseif damage > mobData.maxDamage then
			mobData.maxDamage = damage
		end
	end
end -- MI2_RecordDamage()


-----------------------------------------------------------------------------
-- MI2_RecordDps()
--
-- record a new dps (damage per second) value for a specific mob
-- dps gets calculated from damage done within a given time
--
function MI2_RecordDps( mobIndex, deltaTime, damage  )
	-- only store dps for fights longer then 4 seconds
	if MobInfoConfig.SaveCharData == 1 and deltaTime > 4 then
		local mobData = MI2_FetchMobData( mobIndex )
		local newDps = damage / deltaTime
		if not mobData.dps then mobData.dps = newDps end
		mobData.dps = floor( ((2.0 * mobData.dps) + newDps) / 3.0 )
		MI2_StoreCharData( mobIndex, mobData, MI2_PlayerName )
	end
end -- MI2_RecordDps()


-----------------------------------------------------------------------------
-- MI2_RecordHit()
--
-- Calculate an updated DPS (damage per second) based on the current target
-- data in "MI2_Target" and the new damage value given as parameter.
--
function MI2_RecordHit( damage, spell, school, isPeriodic )
	if not MI2_Target.FightStartTime then
		MI2_Target.FightStartTime = GetTime() - 1.0
		MI2_Target.FightEndTime = GetTime()
		MI2_Target.FightDamage = damage
	elseif MI2_Target.FightEndTime then
		MI2_Target.FightEndTime = GetTime()
		MI2_Target.FightDamage = MI2_Target.FightDamage + damage
	end

	if spell and school and MI2_SpellSchools[school] then
		MI2_SpellToSchool[spell] = school
	elseif spell then
		school = MI2_SpellToSchool[spell]
	end

	-- record spell hit data (needed for spell resist calculations)
	local acronym = MI2_SpellSchools[school]
	if school and acronym and not isPeriodic then
		local mobData = MI2_FetchMobData( MI2_Target.mobIndex )
		mobData.resists[acronym.."Hits"] = (mobData.resists[acronym.."Hits"] or 0)+ 1
	end
end  -- MI2_RecordHit()


-----------------------------------------------------------------------------
-- MI2_RecordImmunResist()
--
-- Record that the given mob has either resisted a spell or is immune to
-- a spell.
--
function MI2_RecordImmunResist( mobName, spell, isResist )
	if mobName == MI2_Target.name and MI2_Target.ResOk then
		local mobIndex = MI2_Target.mobIndex
		local mobData = MI2_FetchMobData( mobIndex )
		local school = MI2_SpellToSchool[spell]
		if school then
			local acronym = MI2_SpellSchools[school]
			if isResist then
				mobData.resists[acronym] = (mobData.resists[acronym] or 0) + 1
			else
				mobData.resists[acronym] = -1
			end
		end
	end
end -- MI2_RecordImmunResist()


-----------------------------------------------------------------------------
-- MI2_AddTwoMobs()
--
-- add the data for two mobs,
-- the data of the second mob (mobData2) is added to the data of the first
-- mob (mobData1). The result is returned in "mobData1".
--
function MI2_AddTwoMobs( mobData1, mobData2 )
	-- add up basic mob data
	mobData1.loots = (mobData1.loots or 0) + (mobData2.loots or 0)
	mobData1.kills = (mobData1.kills or 0) + (mobData2.kills or 0)
	mobData1.emptyLoots = (mobData1.emptyLoots or 0) + (mobData2.emptyLoots or 0)
	mobData1.clothCount = (mobData1.clothCount or 0) + (mobData2.clothCount or 0)
	mobData1.copper = (mobData1.copper or 0) + (mobData2.copper or 0)
	mobData1.itemValue = (mobData1.itemValue or 0) + (mobData2.itemValue or 0)
	mobData1.skinCount = (mobData1.skinCount or 0) + (mobData2.skinCount or 0)
	mobData1.r1 = (mobData1.r1 or 0) + (mobData2.r1 or 0)
	mobData1.r2 = (mobData1.r2 or 0) + (mobData2.r2 or 0)
	mobData1.r3 = (mobData1.r3 or 0) + (mobData2.r3 or 0)
	mobData1.r4 = (mobData1.r4 or 0) + (mobData2.r4 or 0)
	mobData1.r5 = (mobData1.r5 or 0) + (mobData2.r5 or 0)
	if mobData2.mobType then mobData1.mobType = mobData2.mobType end
	if not mobData1.xp then mobData1.xp = mobData2.xp end
	if not mobData1.lowHpAction then mobData1.lowHpAction = mobData2.lowHpAction end

	MI2_CombineLocations( mobData1, mobData2.location )

	-- combine DPS
	if not mobData1.dps then
		mobData1.dps = mobData2.dps
	else
		if mobData2.dps then
			mobData1.dps = floor( ((2.0 * mobData1.dps) + mobData2.dps) / 3.0 )
		end
	end

	-- combine resist data
	local resdat1 = mobData1.resists or {}
	local resdat2 = mobData2.resists or {}
	resdat1.ar	= (resdat1.ar or 0) + (resdat2.ar or 0)
	resdat1.fi	= (resdat1.fi or 0) + (resdat2.fi or 0)
	resdat1.fr	= (resdat1.fr or 0) + (resdat2.fr or 0)
	resdat1.ho	= (resdat1.ho or 0) + (resdat2.ho or 0)
	resdat1.na	= (resdat1.na or 0) + (resdat2.na or 0)
	resdat1.sh	= (resdat1.sh or 0) + (resdat2.sh or 0)
	resdat1.arHits	= (resdat1.arHits or 0) + (resdat2.arHits or 0)
	resdat1.fiHits	= (resdat1.fiHits or 0) + (resdat2.fiHits or 0)
	resdat1.frHits	= (resdat1.frHits or 0) + (resdat2.frHits or 0)
	resdat1.hoHits	= (resdat1.hoHits or 0) + (resdat2.hoHits or 0)
	resdat1.naHits	= (resdat1.naHits or 0) + (resdat2.naHits or 0)
	resdat1.shHits	= (resdat1.shHits or 0) + (resdat2.shHits or 0)
	mobData1.resists = resdat1

	-- combine minimum and maximum damage	
	if (mobData2.minDamage or 99999) < (mobData1.minDamage or 99999) then
		mobData1.minDamage = mobData2.minDamage
	end
	if (mobData2.maxDamage or 0) > (mobData1.maxDamage or 0) then
		mobData1.maxDamage = mobData2.maxDamage
	end
	
	-- add loot item tables
	if mobData2.itemList then
		if not mobData1.itemList then mobData1.itemList = {} end
		for itemID, amount in pairs(mobData2.itemList) do
			mobData1.itemList[itemID] = (mobData1.itemList[itemID] or 0) + mobData2.itemList[itemID]
		end
	end

	if mobData1.loots == 0 then mobData1.loots = nil end
	if mobData1.kills == 0 then mobData1.kills = nil end
	if mobData1.emptyLoots == 0 then mobData1.emptyLoots = nil end
	if mobData1.clothCount == 0 then mobData1.clothCount = nil end
	if mobData1.copper == 0 then mobData1.copper = nil end
	if mobData1.itemValue == 0 then mobData1.itemValue = nil end
	if mobData1.skinCount == 0 then mobData1.skinCount = nil end
	if mobData1.dps == 0 then mobData1.dps = nil end
	if mobData1.r1 == 0 then mobData1.r1 = nil end
	if mobData1.r2 == 0 then mobData1.r2 = nil end
	if mobData1.r3 == 0 then mobData1.r3 = nil end
	if mobData1.r4 == 0 then mobData1.r4 = nil end
	if mobData1.r5 == 0 then mobData1.r5 = nil end
end  -- MI2_AddTwoMobs


-----------------------------------------------------------------------------
-- MI2_GetMobHealthStr()
--
-- Returns the mobhealth in the form of xx/xx from the mobdb formed by
-- MobHealth mod Pulled from Telo's MobHealth
--
local function MI2_GetMobHealthStr( index, healthPercent )
	local ppp = MobHealth_PPP( index )
	if ppp > 0 and healthPercent then
		return string.format("%d / %d", (healthPercent * ppp) + 0.5, (100 * ppp) + 0.5)
	end
end -- MI2_GetMobHealthStr()


-----------------------------------------------------------------------------
-- copper2text()
--
-- Turns a full copper amount to a readable string, eg. 10340 = 1g 3s 40c
--
function copper2text(copper)
	local g,s,c
		
	g = floor(copper / COPPER_PER_GOLD)
	s = floor(copper / COPPER_PER_SILVER) - g * SILVER_PER_GOLD
	c = copper - g * COPPER_PER_GOLD - s * COPPER_PER_SILVER

	if g > 0 then  
  		--return MI_White..g..MI_Yellow..'g '..MI_White..s ..MI_SubWhite..'s '..MI_White..c..MI_Gold..'c'
  		return MI_White..g..MI_Yellow..'g '..MI_White..s ..MI_SubWhite..'s '..MI_White
	end  

	if s > 0 then  
  		return MI_White..s ..MI_SubWhite..'s '..MI_White..c..MI_Gold..'c'
	end  

	return MI_White..c..MI_Gold..'c'
end


-----------------------------------------------------------------------------
-- lootName2Copper()
--
-- Turns a lootname like 1 Gold 3 Silver 40 Copper to total copper 10340
--
function lootName2Copper(item)
	local i = 0
	local g,s,c = 0
	local money = 0
	  
	i = string.find(item, MI_TXT_GOLD )
	if i then
		g = tonumber( string.sub(item,0,i-1) )
		item = string.sub(item,i+5,string.len(item))
		money = money + ((g or 0) * COPPER_PER_GOLD)
	end
	i = string.find(item, MI_TXT_SILVER )
	if i then
		s = tonumber( string.sub(item,0,i-1) )
		item = string.sub(item,i+7,string.len(item))
		money = money + ((s or 0) * COPPER_PER_SILVER)
	end
	i = string.find(item, MI_TXT_COPPER )
	if i then
		c = tonumber( string.sub(item,0,i-1) )
		money = money + (c or 0)
	end

	return money
end -- lootName2Copper()


-----------------------------------------------------------------------------
-- MI2_FindItemValue()
--
-- Find the item value in either the Auctioneer database or in out own copy
-- of the Auctioneer item value database or by asking KC_Items
--
function MI2_FindItemValue( itemID )
	local price = 0
	
	-- check if KC_Items is available and knows the price
	if KC_Common and KC_Common.GetItemPrices then
		price = KC_Common:GetItemPrices(itemID) or 0
		
	-- check if ItemsSync is installed and knows the price
	elseif ISync and ISync.FetchDB then
		price = tonumber( ISync:FetchDB(itemID, "price") or 0 )
	end

	if price == 0 and ItemDataCache then
		price = (ItemDataCache.Get.ByID_selltovendor(itemID) or 0)
 	end

	-- check if Auctioneer is installed and knows the price
	if price == 0 and Auctioneer_GetVendorSellPrice then
		price = Auctioneer_GetVendorSellPrice(itemID) or 0
	end

	-- check if built-in MobInfo price table knows the price
	if price == 0 then
		price = MI2_BasePrices[itemID] or 0
	end

	return price
end -- MI2_FindItemValue()


-----------------------------------------------------------------------------
-- GetLootId()
--
-- get loot ID code for given loot slot number, also return link object
--
local function GetLootId( slot )
	local itemId = 0
	local link = GetLootSlotLink( slot )

	if link then
		local _, _, idCode = string.find(link, "|Hitem:(%d+):(%d+):(%d+):")
		itemId = tonumber( idCode or 0 )
	end

	return itemId
end -- GetLootId()


-----------------------------------------------------------------------------
-- MI2_RecordLootSlotData()
--
-- Record the data for one loot item. This function is called in turn for
-- each loot item in the loot window.
-- Retiurns 2 values : isSkinningItem, isClamMeat
--
local function MI2_RecordLootSlotData( mobIndex, mobData, slotID )
	local skinningLoot = false

	-- obtain loot slot data from WoW
	-- abort loot processing upon finding clam meat (ie. a clam was opened)
	local texture, itemName, quantity, quality = GetLootSlotInfo( slotID )
	if string.find(itemName, MI_TXT_CLAM_MEAT) ~= nil then  return false,true  end
	local itemID = GetLootId( slotID )
	quality = quality + 1

	-- identify and count money loot, make sure it does not get counted as an item
	if LootSlotIsCoin(slotID) then
		local money = lootName2Copper(itemName)
		mobData.copper = (mobData.copper or 0) + money
		quality = -1
	end

	-- record item data within Mob database and in global item table
	-- update cross reference table accordingly
	if MobInfoConfig.SaveItems == 1 and quality >= MobInfoConfig.ItemsQuality then
		if not mobData.itemList then mobData.itemList = {} end
		mobData.itemList[itemID] = (mobData.itemList[itemID] or 0) + quantity
		MI2_ItemNameTable[itemID] = itemName.."/"..quality
		MI2_AddItemToXRefTable( mobIndex, itemName, quantity )
	end

	-- exit right here if this is a skinning loot window
	if slotID == 1 and miSkinLoot[itemID] then  return true,false  end

	if LootSlotIsItem(slotID) then
		local itemValue = MI2_FindItemValue( itemID )
		mobData.itemValue = (mobData.itemValue or 0) + itemValue
		-- try to skip quest items in quality overview
		if itemValue < 1 and quality == 2 then quality = -1 end
	end

	-- cloth drop couter
	if miClothLoot[itemID] then
		mobData.clothCount = (mobData.clothCount or 0) + miClothLoot[itemID]
	end

	-- record loot item quality (if enabled)
	if quality == 1 then 
		mobData.r1 = (mobData.r1 or 0) + 1
	elseif quality == 2 then
		mobData.r2 = (mobData.r2 or 0) + 1
	elseif quality == 3 then
		mobData.r3 = (mobData.r3 or 0) + 1
	elseif quality == 4 then
		mobData.r4 = (mobData.r4 or 0) + 1
	elseif quality == 5 then
		mobData.r5 = (mobData.r5 or 0) + 1
	end
	
	return false,false
end -- MI2_RecordLootSlotData()


-----------------------------------------------------------------------------
-- MI2_RecordAllLootItems()
--
-- Record the data for all items found in the currently open loot window.
-- Return to the caller whether this loot window represents real mob loot
-- or not. Examples for "not" are: skinning, clam loot
--
function MI2_RecordAllLootItems( mobIndex, numItems )
	local skinningLoot = false
	local mobData = MI2_FetchMobData( mobIndex )
	if not mobData then return end

	-- iterate through all loot slots and record data for each item
	for slotID = 1, numItems, 1 do
		local skin, clam = MI2_RecordLootSlotData( mobIndex, mobData, slotID )
		if clam then return end
		skinningLoot = skinningLoot or skin
	end -- for loop

	if skinningLoot then
		mobData.skinCount = (mobData.skinCount or 0) + 1
	else
		-- update loot and empty loot counter
		mobData.loots = (mobData.loots or 0) + 1
		if numItems < 1 then
			mobData.emptyLoots = (mobData.emptyLoots or 0) + 1
		end
	end

	if MobInfoConfig.SaveBasicInfo == 1 then
		MI2_StoreBasicInfo( mobIndex, mobData )
	end
	if MobInfoConfig.SaveItems == 1 then
		MI2_StoreLootItems( mobIndex, mobData )
	end
end -- MI2_RecordAllLootItems()


-----------------------------------------------------------------------------
-- MI2_GetCorpseId()
--
-- create a (hopefully) unique corpse ID out of the loot items found in 
-- the corpse loot window, return nil if loot is empty
-- WoW Bug: GetNumLootItems() includes emptied loot window slots
--
function MI2_GetCorpseId( index )
	local corpseId
	local numItems = 0 
	local numSlots = GetNumLootItems()

	if index and numSlots > 0 then
		corpseId = index
		for slot = 1, numSlots do
			local texture, item = GetLootSlotInfo( slot )
			if item ~= "" then corpseId = corpseId..item end
		end
	end

	return corpseId
end -- MI2_GetCorpseId()


-----------------------------------------------------------------------------
-- MI2_StoreCorpseId()
--
-- enter given corpse ID into list of all corpse IDs
-- a list of corpse IDs is maintained to allow detecting corpse reopening
--
function MI2_StoreCorpseId( corpseId, isNewCorpse )
	-- store a new corpse ID
	if isNewCorpse then
		MI2_NewCorpseIdx = MI2_NewCorpseIdx + 1
		if MI2_NewCorpseIdx > 10 then
			MI2_NewCorpseIdx = 1
		end
		MI2_CurrentCorpseIndex = MI2_NewCorpseIdx
	end

	if MI2_CurrentCorpseIndex then
		MI2_RecentLoots[MI2_CurrentCorpseIndex] = corpseId
		if not corpseId then
			MI2_CurrentCorpseIndex = nil
		end
	end
end -- MI2_StoreCorpseId()


-----------------------------------------------------------------------------
-- MI2_CheckForCorpseReopen()
--
-- Check if the corpse for the given mob index is being reopened.
-- This is done by calculating a (hopefully) unique corpse ID and adding
-- it to the list if it is a new corpse ID. 
--
function MI2_CheckForCorpseReopen( mobIndex )
	local isReopen = false
	local corpseId = MI2_GetCorpseId( mobIndex )

	-- check if corpse ID is already in the list
	for index, recentCorpseId in pairs(MI2_RecentLoots) do
		if recentCorpseId == corpseId then
			MI2_CurrentCorpseIndex = index
			isReopen = true
			break
		end
	end

	-- add corpse ID the the list if it is a new one
	if corpseId and not isReopen then
		MI2_StoreCorpseId( corpseId, 1 )
	end

	return isReopen
end -- MI2_CheckForCorpseReopen()


-----------------------------------------------------------------------------
-- MI2_GetLootItem()
--
-- Return item name, item qulity color, and quality index
-- for an item given as item ID.
--
function MI2_GetLootItem( itemID )
	local itemString = MI2_ItemNameTable[itemID]
	if itemString then
		local s,e, quality = string.find( itemString, "/(%d+)" )
		if s then
			itemString = string.sub( itemString, 1, s-1 )
			quality = tonumber(quality)
			return itemString, MI2_QualityColor[quality], quality 
		end
	end
	return tostring(itemID), MI_LightRed, 1
end -- MI2_GetLootItem()


-----------------------------------------------------------------------------
-- MI2_AddOneItemToList()
--
-- Add one loot item description line to a given list. Item description
-- texts can optionally be shortened. Skinning loot uses skinned counter
-- instead of looted counter.
--
local function MI2_AddOneItemToList( list, mobData, itemID, amount )
	local text, color, quality = MI2_GetLootItem( itemID )

	if miSkinLoot[itemID] or miClothLoot[itemID] then
		text = "* "..text
	else
		-- apply item quality and item name filter
		local filtered = (quality==1) and (MobInfoConfig.ShowIGrey == 0)
					or (quality==2) and (MobInfoConfig.ShowIWhite == 0)
					or (quality==3) and (MobInfoConfig.ShowIGreen == 0)
					or (quality==4) and (MobInfoConfig.ShowIBlue == 0)
					or (quality>4) and (MobInfoConfig.ShowIPurple == 0)
		if not filtered and MobInfoConfig.ItemFilter ~= ""  then
			filtered = string.find( string.lower(text), string.lower(MobInfoConfig.ItemFilter) ) == nil
		end
		if filtered then return end
	end

	-- shorten item text to keep tooltip reasonably small
	if string.len(text) > 35 then
		text = string.sub(text,1,34).."..."
	end
	text = color..text..": "..amount

	local totalAmount = mobData.loots
	if miSkinLoot[itemID] then
		totalAmount = mobData.skinCount
	end
	if totalAmount and totalAmount > 0 then
		text = text.." ("..ceil(amount/totalAmount*100).."%)"  
	end
	
	table.insert( list, text )
end -- MI2_AddOneItemToList


-----------------------------------------------------------------------------
-- MI2_BuildItemsList()
--
-- Build list of loot items for showing them in the mob tooltip.
--
-- Notoriously similar and numerous items that radically increase tooltip
-- size without being of much (if any) interest will be collapsed into
-- just one item (example: "Green Hills of Stranglethorn" pages).
--
local function MI2_BuildItemsList( mobData )
	mobData.ttItems = {}
	if not mobData.itemList then return end

	local itemID, amount, idx, ok
	local sortList = {}
	local collapsedList = {}

	-- build a sortable list of item IDs
	for itemID, amount in pairs(mobData.itemList) do
		ok = false
		if miSkinLoot[itemID] or miClothLoot[itemID] then 
			if MobInfoConfig.ShowClothSkin == 1 then
				ok = true
			end
		elseif MI2_CollapseList[itemID] then
			-- collapse almost identical items into one item
			itemID = MI2_CollapseList[itemID]
			if not collapsedList[itemID] then
				ok = true
			end
			collapsedList[itemID] = (collapsedList[itemID] or 0) + amount
		else
			ok = true
		end
		if ok then
			table.insert( sortList, itemID )
		end
	end

	-- add collapsed items to sortable list
	for itemID, amount in pairs(collapsedList) do
		mobData.itemList[itemID] = amount
	end

	-- sort items by amount
	table.sort( sortList, function(a,b) return (mobData.itemList[a] > mobData.itemList[b]) end  )

	-- add sorted items to tooltip items list
	for idx, itemID in pairs(sortList) do
		MI2_AddOneItemToList( mobData.ttItems, mobData, itemID, mobData.itemList[itemID], true )
	end
end -- MI2_BuildItemsList


-----------------------------------------------------------------------------
-- MI2_BuildResistString()
--
-- Add the Mob resistances and immunities data to the tooltip.
--
local function MI2_BuildResistString( mobData )
	local resiatances = ""
	local immunities = ""
	local resistData = mobData.resists

	local shortcut, value
	for shortcut, value in pairs(resistData) do
		if string.len(shortcut) < 3 then
			local hits = tonumber(resistData[shortcut.."Hits"]) or 1
			if value < 0 then
				if hits < 1 then
					immunities = immunities.."  "..MI2_SpellSchools[shortcut]
				else
					immunities = immunities.."  "..MI2_SpellSchools[shortcut].."(partial)"
				end
			elseif value > 0 then
				resiatances = resiatances.."  "..MI2_SpellSchools[shortcut]..":"..ceil((value/hits)*100).."%"
			end
		end
	end

	if resiatances ~= "" then
		mobData.resStr = resiatances
	end

	if immunities ~= "" then
		mobData.immStr = immunities
	end
end -- MI2_BuildResistString


-----------------------------------------------------------------------------
-- MI2_BuildQualityString()
--
-- Build a string drepresenting the loot quality overview for the given mob.
--
function MI2_BuildQualityString( mobData )
	local quality, chance, idx
	local rt = mobData.loots or 1
 	local qualityStr = ""
	for idx = 1, 5 do
		quality = mobData["r"..idx]
		if quality then
			chance = ceil( quality / rt * 100.0 )
			if chance > 100 then chance = 100 end
			qualityStr = qualityStr..MI2_QualityColor[idx]..quality.."("..chance.."%) "
		end
	end
	if qualityStr ~= "" then
		mobData.qualityStr = qualityStr
	end
end  -- MI2_BuildQualityString


-----------------------------------------------------------------------------
-- MI2_ColorToText()
--
-- convert a R/G/B color into a a textual WoW excape sequence representation 
--
function MI2_ColorToText( r, g, b, a )
	if not a then a = 1.0 end
	r = 255 * (r+0.0001)
	g = 255 * (g+0.0001)
	b = 255 * (b+0.0001)
	a = 255 * (a+0.0001)
	return string.format ( "|c%.2x%.2x%.2x%.2x", a, r, g, b )
end -- MI2_ColorToText


-----------------------------------------------------------------------------
-- MI2_BuildExtraInfo()
--
-- Extract max 4 extra lines from the standard WoW game tooltip.
-- Extra info is anything listed underneath the level/class line, but without
-- the "skinnable" line and without the mob faction name line.
--
local function MI2_BuildExtraInfo( mobData, mobName, mobLevel )
	local levelLine, previous, checkFaction, isExtraInfo
	local numLines = GameTooltip:NumLines()

	for idx=2,numLines do
		local ttLeft = getglobal( "GameTooltipTextLeft"..idx ):GetText()
		local ttRight = getglobal( "GameTooltipTextRight"..idx ):GetText()
		isExtraInfo = false

		-- check for line with faction name
		if ttLeft and checkFaction then
			checkFaction = nil
			if not string.find(mobName,ttLeft) then
				isExtraInfo = true
			end
		-- find the TT line with level info
		elseif ttLeft and not levelLine then 
			local levelInfo = string.format( TOOLTIP_UNIT_LEVEL, mobLevel )
			if string.find(ttLeft,levelInfo) then
				levelLine = idx
				checkFaction = true
			end
			-- if previous line exists then it is assumed to be the NPC profession
			if previous then
				mobData.classInfo = previous
			end
		elseif ttLeft == UNIT_SKINNABLE_LEATHER then
			-- the skinnable tag gets added to class info and does not count as extra info
			local color = MI2_ColorToText( GameTooltipTextLeft3:GetTextColor() )
			mobData.classInfo = mobData.classInfo..", "..color..UNIT_SKINNABLE_LEATHER
		else
			isExtraInfo = true
		end
		if ttLeft and isExtraInfo then
			local text = MI_LightGreen..ttLeft
			if ttRight then
				text = text.." "..ttRight
			end 
			table.insert( mobData.extraInfo, text )
			if #mobData.extraInfo > 3 then break end
		end
		previous = ttLeft
	end 

--mobData.extraInfo = { "AAA", "BBB", "CCC", "DDD" }

end -- MI2_BuildExtraInfo


-----------------------------------------------------------------------------
-- MI2_AddItemPriceToTooltip()
--
-- Show vendor sell value of item in item tooltip
-- The info is added to the game tooltip.
--
local function MI2_AddItemPriceToTooltip()
	-- optain basic info from WoW UI to know which item is under mouse cursor
	local frame = GetMouseFocus()
	if not frame then return end
	local frameName = frame:GetName()
	if not frameName or string.find(frameName,"QuestLog") then return end
	local parent = frame:GetParent()
	if not parent then return end
	local _,_,parenName, num = string.find( frameName, "(.+)Item(%d+)" )
	if not parenName or not num then return end

	local bagId
	local bagSlot = frame:GetID()
	if parent == BankFrame then
		bagId = BANK_CONTAINER
	else
	    bagId = parent:GetID()
	end
	
	local price = 0
	local priceFound = false
	local link = GetContainerItemLink( bagId, bagSlot )
	local _, amount = GetContainerItemInfo( bagId, bagSlot )
	local _, _, itemID = string.find((link or ""), "|Hitem:(%d+):(%d+):(%d+):")
	if itemID and amount then
	    price = MI2_FindItemValue( tonumber(itemID) ) * amount
	    if price > 0 then
			GameTooltip:AddDoubleLine( MI_LightBlue..MI_TXT_PRICE..MI_White..amount, MI_White..copper2text(price) )
			priceFound = true
	    end
	end

if MI2_DebugItems > 0 then
GameTooltip:AddLine( MI_SubWhite.."[frame="..frame:GetName()..",id="..frame:GetID().."]" )
GameTooltip:AddLine( MI_SubWhite.."[parent="..parent:GetName()..",id="..parent:GetID().."]" )
GameTooltip:AddLine( MI_SubWhite.."[bagId="..bagId..",bagSlot="..bagSlot.."]" )
GameTooltip:AddLine( MI_SubWhite.."link="..link )
GameTooltip:AddLine( MI_SubWhite.."[itemID="..itemID..",price="..price..",amount="..amount.."]" )
end

	return priceFound
end -- MI2_AddItemPriceToTooltip()


-----------------------------------------------------------------------------
-- MI2_BuildItemDataTooltip()
--
-- Build the additional game tooltip content for a given item name.
-- If the item is a known loot item this function will add the names of
-- all Mobs that drop the item to the game tooltip. Each Mob name will
-- appear on its own line.
--
function MI2_BuildItemDataTooltip( itemName )
	local priceFound

	-- add item sell price to item tooltip
	if MobInfoConfig.ShowItemPrice == 1 then
	    priceFound = MI2_AddItemPriceToTooltip()
	end

	if MobInfoConfig.ItemTooltip ~= 1 then return end

	-- get the table of all Mobs that drop the item, exit if none
	local itemFound = MI2_XRefItemTable[itemName]
	if not itemFound then return priceFound end

	-- Create a list of mobs dropping this item that is indexed by only
	-- the base Mob name. For each Mob calculate the chance to drop.
	-- Create a second list referencing the same data that is indexed
	-- numerically so that it can then be sorted by chance to get.
	local numMobs = 0
	local resultList = {}
	local sortList = {}
	local mobIndex, itemAmount
	for mobIndex, itemAmount in pairs(itemFound) do
		local mobData = {}
		MI2_DecodeBasicMobData( nil, mobData, mobIndex )

		local mobName, mobLevel = MI2_GetIndexComponents( mobIndex )
		local itemData = resultList[mobName]
		if not itemData then
			numMobs = numMobs + 1
			itemData = { name = mobName, loots = 0, count = 0 }
			resultList[mobName] = itemData
			sortList[numMobs] = itemData
		end

		itemData.loots = itemData.loots + (mobData.loots or 0)
		itemData.count = itemData.count + itemAmount
		if itemData.loots > 0 then
			itemData.chance = floor(100.0 * itemData.count / itemData.loots + 0.5)
			if itemData.chance > 100 then itemData.chance = 100 end
			if itemData.loots < 6 then
				itemData.rating = itemData.chance + itemData.loots * 1000
			else
				itemData.rating = itemData.chance + 6000
			end
		else
			itemData.chance = itemData.count
			itemData.rating = itemData.chance
		end
	end

	-- sort list of Mobs by chance to get
	table.sort( sortList, function(a,b) return (a.rating > b.rating) end  )

	-- add Mobs to tooltip
	GameTooltip:AddLine( MI_LightBlue..MI_TXT_DROPPED_BY..numMobs.." Mobs:" )
	if numMobs > 8 then numMobs = 8 end
	for idx = 1, numMobs do
		local data = sortList[idx]
		if data.loots > 0 then
			GameTooltip:AddDoubleLine( MI_LightBlue.."  "..data.name, MI_White..data.chance.."% ("..data.count.."/"..data.loots..")" )
		else
			GameTooltip:AddDoubleLine( MI_LightBlue.."  "..data.name, MI_White..data.chance )
		end
	end

	return true
end -- MI2_BuildItemDataTooltip()


-----------------------------------------------------------------------------
-- MI2_BuildMobClassInfo()
--
-- build class info text line for mob tooltip, class info includes the "dead"
-- and the "skinnable" tags
--
local function MI2_BuildMobClassInfo( mobData, isMob )
	local creatureType = UnitCreatureType("mouseover")
	mobData.class = UnitClassBase("mouseover")
	mobData.classInfo = nil
	if UnitIsDead("mouseover") then
		mobData.classInfo = CORPSE
	elseif isMob then
		if mobData.class and creatureType then
			mobData.classInfo = creatureType..", "..mobData.class
		end
		if mobData.lowHpAction then
			mobData.classInfo = (mobData.classInfo or "").."  "..MI_LightRed..MI2_TXT_MOBRUNS
		end
	else
	end 
end -- MI2_BuildMobClassInfo


-----------------------------------------------------------------------------
-- MI2_BuildTooltipMob()
--
-- create the mobData record required for showing mob information in the
-- tooltip
--
function MI2_BuildTooltipMob( mobName, mobLevel, unit, isMob )
	local mobIndex = mobName..":"..mobLevel

	-- combine several mobs into one record if required
	local mobData, levelInfo
	if  MobInfoConfig.CombinedMode == 1 and mobLevel > 0 then
		mobData = MI2_FetchCombinedMob( mobName, mobLevel, unit )
		levelInfo = mobData.levelInfo
	else
		mobData = MI2_FetchMobData( mobIndex, unit )
		levelInfo = mobLevel
	end

	-- calculate kills to next level
	if mobData.xp then
		-- calculate number of mobs to next level based on mob experience
		local xpCurrent = UnitXP("player") + mobData.xp
		local xpToLevel = UnitXPMax("player") - xpCurrent
		mobData.mob2Level = ceil(abs(xpToLevel / mobData.xp))+1
	end

	-- avarage value computation
	local loots = mobData.loots or 1
	if mobData.copper then
		mobData.avgCV = ceil(mobData.copper/loots)
	end
	if mobData.itemValue then
		mobData.avgIV = ceil(mobData.itemValue/loots)
	end
	if mobData.avgCV or mobData.avgIV then
		mobData.avgTV = (mobData.avgCV or 0) + (mobData.avgIV or 0)
	end

	-- build level info
	if mobLevel == -1 then
		levelInfo = "BOSS"
		mobData.mobType = 3
		mobLevel = 99
	elseif mobData.mobType == 2 then
		levelInfo = levelInfo.."+"
	elseif mobData.mobType == 3 then
		levelInfo = levelInfo.."++"
	end

	-- PTR Code
	local col
	if tocVersion >= 30200 then
		col = GetQuestDifficultyColor(mobLevel)
	else
		col = GetDifficultyColor(mobLevel)
	end
		
	mobData.levelInfo = MI2_ColorToText(col.r,col.g,col.b).."["..levelInfo.."] " 

	-- build various content to be shown in the tooltip
	MI2_BuildMobClassInfo( mobData, isMob )
	MI2_BuildQualityString( mobData )
	MI2_BuildItemsList( mobData )
	if MobInfoConfig.ShowResists == 1 then
		MI2_BuildResistString( mobData )
	end
	--if UnitExists(unit) and MobInfoConfig.UseGameTT == 0 then
	mobData.extraInfo = {} 
	if UnitExists(unit) and MobInfoConfig.UseGameTT == 0 then
		MI2_BuildExtraInfo( mobData, mobName, mobLevel )
	end

	return mobData
end -- MI2_BuildTooltipMob()


-----------------------------------------------------------------------------
-- MI2_ScanSpellbook()
--
-- Scan the spellbook to enter all spells and their spell school into
-- the "MI2_SpellToSchool" conversion table that is needed for resistances
-- and immunities recording.
--
function MI2_ScanSpellbook()
	local spellBookPage = 2
	
	while spellBookPage > 0 do
		local pageName, texture, offset, numSpells = GetSpellTabInfo( spellBookPage )
		if pageName and offset and numSpells then
			for spellIndex = (offset+1), (offset + numSpells) do
				local spellName = GetSpellName( spellIndex, BOOKTYPE_SPELL )
				if spellName and (not string.find(spellName,":")) then
					for school in pairs(MI2_SpellSchools) do
						local schoolOK = string.find( pageName, school )
						if schoolOK and string.len(school) > 2 then
							MI2_SpellToSchool[spellName] = school
						end
					end
				end
			end
			spellBookPage = spellBookPage + 1
		else
			spellBookPage = 0
		end
	end
end -- MI2_ScanSpellbook

