--[[

	Quest Completist - Core.lua
	Written by: Alistair Maxwell
	Last Updated: 14/11/2010

--]]

-- Tables --
qcZoneQuests = {}
qcQuestHistory = {}
qcOptions = {}
qcUnknownQuests = {}
qcNPC = {}
qcQuest = {}

-- Declare local vars --
local npcGUID = ""
local npcID = ""
local npcName = ""
local currentZone = 0
local questCount = 0
local currentScrollPosition = 1
local playerEnglishClass = ""
local playerLocalizedClass = ""
local playerEnglishFaction = ""
local playerLocalizedFaction = ""
local qcShowDebugInformation = false

local ADDON_MSG_PREFIX = "QCOMPLETIST"
local ADDON_VERSION = 0.3
local ADDON_DELIMITER = ":"
local COLOUR_QC = "|cFF9482C9"

--	Constants for the Key Bindings & Slash Commands --
BINDING_HEADER_QCQUESTCOMPLETIST = "Quest Completist";
BINDING_NAME_QCTOGGLEFRAME = "Toggle Frame";
SLASH_QUESTCOMPLETIST1 = "/qc"

SlashCmdList["QUESTCOMPLETIST"] = function(msg, editbox)
	ShowUIPanel(frameQuestCompletist)
end

local function SaveTargetNPCInformation()

	-- Do we already know about this NPC? --
	if (qcNPC[npcID] == nil) then

		-- We have never seen this NPC before --
		qcNPC[npcID] = {}

		-- Identification --
		qcNPC[npcID]["npcI"] = {}
		qcNPC[npcID]["npcI"]["npcN"] = npcName
		qcNPC[npcID]["npcI"]["npcG"] = npcGUID

		-- Census --
		qcNPC[npcID]["npcC"] = {}
		qcNPC[npcID]["npcC"]["npcC"] = UnitClassification("target")
		qcNPC[npcID]["npcC"]["npcT"] = UnitCreatureType("target")
		qcNPC[npcID]["npcC"]["npcL"] = UnitLevel("target")
		qcNPC[npcID]["npcC"]["npcR"] = UnitRace("target")
		qcNPC[npcID]["npcC"]["npcS"] = UnitSex("target")

		-- Stats --
		qcNPC[npcID]["npcS"] = {}
		qcNPC[npcID]["npcS"]["npcH"] = UnitHealthMax("target")
		npcMaxPower, npcPowerType = UnitPowerMax("target")
		qcNPC[npcID]["npcS"]["npcP"] = npcMaxPower
		qcNPC[npcID]["npcS"]["npcT"] = npcPowerType

		-- Location --
		qcNPC[npcID]["npcL"] = {}
		-- qcNPC[npcID]["RealZoneText"] = GetRealZoneText()
		-- qcNPC[npcID]["SubZoneText"] = GetSubZoneText()
		pX, pY = GetPlayerMapPosition("player")
		qcNPC[npcID]["npcL"]["entryPlayersXMapPosition"] = (pX*100)
		qcNPC[npcID]["npcL"]["entryPlayersYMapPosition"] = (pY*100)

		-- Gossip --
		qcNPC[npcID]["npcG"] = {}

		-- Quests --
		qcNPC[npcID]["npcQ"] = {}

		return true

	else

		-- We know about this NPC already --
		-- TODO: Check everything exists just incase of addon update --
		return true

	end

end

local function GetBasicNPCData() -- Returns true if data was collected, and false otherwise --

	-- Get the NPC data --
	npcGUID = UnitGUID("target")
	if (npcGUID == nil) then
		return false
	end
	npcID = tonumber(strsub(npcGUID, 7, 10), 16)
	npcName = UnitName("target")

	-- Check it was collected, and return false if it wasn't --
	if (npcGUID == nil) or (npcGUID == "") then	return false end
	if (npcID == nil) or (npcID == "") then	return false end
	if (npcName == nil) or (npcName == "") then	return false end

	return true

end

local function initiateTargetNPC() -- Returns true if NPC exists or is created, and false otherwise --

	-- Update local vars with target NPC data --
	if (not GetBasicNPCData()) then
		return false
	end

	-- Save out the NPC information --
	if (not SaveTargetNPCInformation()) then
		return false
	end

	return true

end

local function addGossip(gossipText) -- Adds NPC gossip to file. Returns true or false if successful --

	-- TODO: Strip gossip text of player name, race, class, etc --

	local gossipIndex = 1

	-- Initiate NPC --
	if (not initiateTargetNPC()) then
		return false
	end

	-- NPC has been initiated --
	while (qcNPC[npcID]["npcG"][gossipIndex] ~= nil) do
		if (qcNPC[npcID]["npcG"][gossipIndex]["npcT"] == gossipText) then
			-- This gossip already exists for this NPC --
			return true
		end
		gossipIndex = gossipIndex + 1
	end

	-- This gossip is not on file. Add it. --
	qcNPC[npcID]["npcG"][gossipIndex] = {}
	qcNPC[npcID]["npcG"][gossipIndex]["npcT"] = gossipText

	return true

end

local function addQuest(questLogIndex, questID) -- Adds a quest to file. Returns true or false if successful --

	local entryTitle					-- Title of the entry --
	local entryRecommendedLevel			-- Recommended level --
	local entryClassification			-- Dungeon, Elite, Group, Heroic, PVP, Raid, nil --
	local entrySuggestedGroupSize		-- Suggested number of people --
	local entryIsHeader					-- 1 or nil --
	local entryIsCollapsed				-- 1 or nil --
	local entryIsComplete				-- Failed = -1, Completed = 1, Neither = nil --
	local entryIsDaily					-- 1 or nil --
	local entryQuestID					-- Quest ID for entry --
	local entryQuestDescription			-- Description of the entry --
	local entryQuestObjectivesSummary	-- Objectives summary for the entry --
	local playerCurrentLevel			-- Holds the current players level --

	-- Get the players current level --
	playerCurrentLevel = UnitLevel("player")

	-- Get quest information --
	SelectQuestLogEntry(questLogIndex)
	entryTitle, entryRecommendedLevel, entryClassification, entrySuggestedGroupSize, entryIsHeader, entryIsCollapsed, entryIsComplete, entryIsDaily, entryQuestID  = GetQuestLogTitle(questLogIndex)
	entryQuestDescription, entryQuestObjectivesSummary = GetQuestLogQuestText()

	-- Make sure the information is about the same quest we accepted by comparing quest IDs --
	if (entryQuestID == questID) then
		-- Check if the quest already exists. If not, create it --
		if (qcQuest[questID] == nil) then
			qcQuest[questID] = {}
			-- Fill the quest sturcture --
			qcQuest[questID]["entryTitle"] = entryTitle
			qcQuest[questID]["entryRecommendedLevel"] = entryRecommendedLevel
			qcQuest[questID]["entryClassification"] = entryClassification
			qcQuest[questID]["entrySuggestedGroupSize"] = entrySuggestedGroupSize
			qcQuest[questID]["entryIsDaily"] = entryIsDaily
			qcQuest[questID]["entryQuestDescription"] = entryQuestDescription
			qcQuest[questID]["entryQuestObjectivesSummary"] = entryQuestObjectivesSummary
			qcQuest[questID]["playerCurrentLevel"] = playerCurrentLevel
			return true
		else
			-- Quest already exists --
			return true
		end
	else
		print("Crosscheck was not successful.")
		-- Crosscheck was not successful --
		return false
	end

end

local function getQuestIDFromTitle(questTitle) -- Returns the questID, and the questLogIndex. If it fails it returns nil, nil. --

local questLogIndex = 1

	-- Look through each entry in the quest log --
	while (questLogIndex >= 1) and (questLogIndex <= GetNumQuestLogEntries()) do

		local entryTitle					-- Title of the entry;
		local entryLevel					-- Recommended level;
		local entryTag						-- Dungeon, Elite, Group, Heroic, PVP, Raid, nil
		local entrySuggestedGroupSize		-- Suggested number of people;
		local entryIsHeader					-- 1 or nil
		local entryIsCollapsed				-- 1 or nil
		local entryIsComplete				-- Failed = -1, Completed = 1, Neither = nil
		local entryIsDaily					-- 1 or nil
		local entryQuestID					-- Quest ID for entry;

		-- Get information for the entry --
		entryTitle, entryLevel, entryTag, entrySuggestedGroupSize, entryIsHeader, entryIsCollapsed, entryIsComplete, entryIsDaily, entryQuestID = GetQuestLogTitle(questLogIndex)

		-- Provided this entry isn't a header, check to see if it is the quest we are looking for --
		if (entryIsHeader == nil) then
			if (entryTitle == questTitle) then
				-- This is the quest we were looking for --
				return entryQuestID, questLogIndex
			end
		end

		-- Increment the index in prep for next loop --
		questLogIndex = questLogIndex + 1

	end

	-- Quest with questTitle isn't in the quest log --
	return nil, nil

end

local function addProgress() -- Adds progress text to a quest. Returns true or false if successful  --

	local questID					-- Holds the quest ID --
	local questLogIndex				-- Holds the index of the entry in the quest log --
	local questTitle				-- Holds the quests title --
	local questProgress				-- Holds the progress text for the quest --
	local questDescription			-- Holds the description of the quest --
	local questObjectivesSummary	-- Holds the summary of the quests objectives --

	-- Get the quest title and the progress text --
	questTitle = GetTitleText()
	questProgress = GetProgressText()

	-- Get the quest ID based on the quests title --
	questID, questLogIndex = getQuestIDFromTitle(questTitle)

	if (qcQuest[questID] == nil) then
		-- The quest doesn't yet exist. Addon might have been installed after quest was picked up --
		return false
	else
		-- The quest exists --
		if (qcQuest[questID]["entryQuestDescription"] ~= nil) then
			-- The description for this quest exists, compare this to the quest from the quest log to see if they match --
			SelectQuestLogEntry(questLogIndex)
			questDescription, questObjectivesSummary = GetQuestLogQuestText()
			if (qcQuest[questID]["entryQuestDescription"] == questDescription) then
				-- The two descriptions match, this must be the right quest --
				qcQuest[questID]["questProgress"] = questProgress
				return true
			else
				-- The two descriptions do not match. Might be more than one quest with this title, but this one isnt the one we want --
				return false
			end
		else
			-- Even though the quest exists, the quest description does not. We cant double check we have the right questID --
			return false
		end
	end

end

local function qcQuestHistory_Complete() -- Adds quest to the Quest History DB --

	local questTitle
	local questCompletionText -- TODO: Do i need to crosscheck the description? --
	local questID
	local questLogIndex

	questTitle = GetTitleText()
	questCompletionText = GetRewardText()
	questID, questLogIndex = getQuestIDFromTitle(questTitle)

	if (questID == nil) or (questLogIndex == nil) then
		print("Unable to get Quest ID from quest log. Quest not saved in Quest History database.")
		return false
	end

	if (qcQuestHistory[questID] == nil) then
		qcQuestHistory[questID] = true
		return true
	end

end

local function addComplete() -- Adds completion text to a quest. Returns true or false if successful --

	local questTitle				-- Holds the quests title --
	local questComplete				-- Holds the completion text for the quest --
	local questID					-- Holds the quest ID --
	local questLogIndex				-- Holds the index of the entry in the quest log --

	-- Get the quest title and the completion text --
	questTitle = GetTitleText()
	questComplete = GetRewardText()

	-- Get the quest ID based on the quests title --
	questID, questLogIndex = getQuestIDFromTitle(questTitle)

	if (qcQuest[questID] == nil) then
		-- The quest doesn't exist. Addon might have been installed after quest was picked up --
		return false
	else
		-- The quest exists already --
		if (qcQuest[questID]["entryQuestDescription"] ~= nil) then
			-- The description for this quest exists, compare this to the quest from the quest log to see if they match --
			SelectQuestLogEntry(questLogIndex)
			questDescription, questObjectivesSummary = GetQuestLogQuestText()
			if (qcQuest[questID]["entryQuestDescription"] == questDescription) then
				-- The two descriptions match, this must be the right quest --
				qcQuest[questID]["questComplete"] = questComplete
				return true
			else
				-- The two descriptions do not match. Might be more than one quest with this title, but this one isnt the one we want --
				return false
			end
		else
			-- Even though the quest exists, the quest description does not. We cant double check we have the right questID --
			return false
		end
	end

end

local function GossipShowEvent()

	addGossip(GetGossipText())

end

local function QuestGreetingEvent()

	addGossip(GetGreetingText())

end

local function QuestCompleteEvent()

	local questTitle = GetTitleText()
	local rewardText = GetRewardText()

	if (not initiateQuestGiver(questTitle)) then
		return;
	end

	AddProgressCompleted(qcQuestText[npcName][title], "Completed", text)

end

function qcScrollUpdate(value)

	--[[
	Do this to make sure we are not pointlessly doing extra work when the
	Slider value hasn't changed.
	--]]

	if (currentScrollPosition == value) then
	else
		currentScrollPosition = value
		qcUpdateMenu(nil, value, true)
	end

end

function qcUpdateMenu(zoneID, startItem, noNewZoneQuery)

	-- TODO: Possible use of parentKey rather than _G?

	local offsetIndex
	local qcOpenLevel = "["
	local qcCloseLevel = "] "

	if (not noNewZoneQuery) then
		currentZone = zoneID -- Set the current zoneID for other methods --
		qcGetZoneQuests(zoneID)
		questCount = (#qcZoneQuests)
		frameQuestCompletist.questCount:SetText(questCount .. " Quests Found")
		if (questCount <= 0) then
			-- Didnt find any quests for that zone in the DB --
			qcMenuSlider:SetMinMaxValues(1, 1)
		elseif (questCount < 16) then
			qcMenuSlider:SetMinMaxValues(1, 1)
		else
			qcMenuSlider:SetMinMaxValues(1, questCount - 15)
		end
		qcMenuSlider:SetValue(startItem)
	end

	for menuIndex = 1, 16 do
		offsetIndex = ((menuIndex + startItem) - 1)
		if (questCount >= offsetIndex) then
			_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetText(qcOpenLevel .. qcZoneQuests[offsetIndex][4] .. qcCloseLevel .. qcZoneQuests[offsetIndex][5])
			_G["qcMenuButton" .. menuIndex .. "_QuestTag"]:SetText(qcZoneQuests[offsetIndex][2])
			_G["qcMenuButton" .. menuIndex]:Show()
			_G["qcMenuButton" .. menuIndex]:Enable()
			if (qcZoneQuests[offsetIndex][3] == 1) then -- Quest Type is Normal --
				_G["qcMenuButton" .. menuIndex .. "_RepeatableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_DailyIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_SpecialIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_CompleteIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_AvailableIcon"]:Show()
				_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetTextColor(1.0, 1.0, 1.0, 1.0)
			elseif (qcZoneQuests[offsetIndex][3] == 2) then -- Quest Type is Repeatable --
				_G["qcMenuButton" .. menuIndex .. "_AvailableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_DailyIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_SpecialIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_CompleteIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_RepeatableIcon"]:Show()
				_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetTextColor(0.0941176470588235, 0.6274509803921569, 0.9411764705882353, 1.0)
			elseif (qcZoneQuests[offsetIndex][3] == 3) then -- Quest Type is Daily --
				_G["qcMenuButton" .. menuIndex .. "_AvailableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_RepeatableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_SpecialIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_CompleteIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_DailyIcon"]:Show()
				_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetTextColor(0.0941176470588235, 0.6274509803921569, 0.9411764705882353, 1.0)
			elseif (qcZoneQuests[offsetIndex][3] == 4) then -- Quest Type is Special --
				_G["qcMenuButton" .. menuIndex .. "_AvailableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_RepeatableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_DailyIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_CompleteIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_SpecialIcon"]:Show()
				_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetTextColor(1.0, 0.6156862745098039, 0.0862745098039216, 1.0)
			else -- Quest Type Unknown --
				_G["qcMenuButton" .. menuIndex .. "_AvailableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_RepeatableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_DailyIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_SpecialIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_CompleteIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetTextColor(1.0, 1.0, 1.0, 1.0)
			end
			if (qcZoneQuests[offsetIndex][6] == 1) then -- Alliance Only Quest --
				_G["qcMenuButton" .. menuIndex .. "_HordeIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_AllianceIcon"]:Show()
			elseif (qcZoneQuests[offsetIndex][6] == 2) then -- Horde Only Quest --
				_G["qcMenuButton" .. menuIndex .. "_AllianceIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_HordeIcon"]:Show()
			elseif (qcZoneQuests[offsetIndex][6] == 3) then -- Both Sides --
				_G["qcMenuButton" .. menuIndex .. "_AllianceIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_HordeIcon"]:Hide()
			elseif (qcZoneQuests[offsetIndex][6] == 4) then -- No Side Data --
				_G["qcMenuButton" .. menuIndex .. "_AllianceIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_HordeIcon"]:Hide()
			else -- Unknown Side --
				_G["qcMenuButton" .. menuIndex .. "_AllianceIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_HordeIcon"]:Hide()
			end

			--[[
			Now that the basic colours for the quest types have been applied,
			go through the quest history DB for the character to see what
			has been completed, and colour green.
			--]]

			if (qcQuestHistory[qcZoneQuests[offsetIndex][2]] == nil) then
				-- Quest doesn't exist in quest history DB --
			else
				_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetTextColor(0.0, 1.0, 0.0, 1.0)
				_G["qcMenuButton" .. menuIndex .. "_AvailableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_RepeatableIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_DailyIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_SpecialIcon"]:Hide()
				_G["qcMenuButton" .. menuIndex .. "_CompleteIcon"]:Show()
			end

		else
			_G["qcMenuButton" .. menuIndex .. "_QuestName"]:SetText("-")
			_G["qcMenuButton" .. menuIndex]:Hide()
			_G["qcMenuButton" .. menuIndex]:Disable()
		end
	end

end

function questQueryCompleted()

	local weekday
	local month
	local day
	local year
	local recievedQuestCount = 0
	local addedToQuestHistory = 0
	local unknownQuest = 0
	local qcCompletedTable = {}

	weekday, month, day, year = CalendarGetDate()

	wipe(qcCompletedTable)
	wipe(qcUnknownQuests)
	GetQuestsCompleted(qcCompletedTable)

	for qcCompletedTableIndex, qcCompletedQuest in pairs(qcCompletedTable) do
		recievedQuestCount = (recievedQuestCount + 1)
		if (qcQuestHistory[qcCompletedTableIndex] == nil) then
			-- Completed quest is not flagged as completed. Add it to Quest History.
			addedToQuestHistory = (addedToQuestHistory + 1)
			qcQuestHistory[qcCompletedTableIndex] = true
		end
		for qcQuestDatabaseIndex, qcQuestDatabase in ipairs(qcQuestDatabases) do
			if (qcQuestDatabase[2] == qcCompletedTableIndex) then
				-- This quest is already in our database --
				break
			else
				if (qcQuestDatabaseIndex == #qcQuestDatabases) then -- We have checked the entire database --
					table.insert(qcUnknownQuests, qcCompletedTableIndex)
					unknownQuest = (unknownQuest + 1)
				end
			end
		end
	end

	qcUpdateMenu(nil, qcMenuSlider:GetValue(), true)
	print("Recieved " .. recievedQuestCount .. " quests from the server. " .. addedToQuestHistory .. " were added to your quest history and " .. unknownQuest .. " were unknown to the addon.")
	if (unknownQuest > 0) then
		print("The addon does not know about some of the quests you have completed. To help me fix this, please concider sending your SavedVariables file to viduus.wow@gmail.com")
		print("It can be found at: <World of Warcraft Folder>\\WTF\\Account\\<ACCOUNT NAME>\\SavedVariables\\QuestCompletist.lua")
	end

end

function qcGetZoneQuests(zoneID)

	wipe(qcZoneQuests)

	for qcQuestDatabaseIndex, qcQuestDatabase in ipairs(qcQuestDatabases) do
		if (qcQuestDatabase[1] == zoneID) then -- This is a quest from the required zone --
			if (_G["qcFactionCheckButton"]:GetChecked() == 1) then -- We only want players faction quests (Including quests set as Both, etc) --
				if (playerEnglishFaction == "Alliance") then
					if (qcQuestDatabase[6] == 1) or (qcQuestDatabase[6] == 3) or (qcQuestDatabase[6] == 4) then
						if (_G["qcClassCheckButton"]:GetChecked() == 1) then -- We dont want to includes quests that are for other classes --
							if (qcQuestDatabase[7] == 1) then -- This is a class specific quest --
								if (string.find(qcQuestDatabase[8], string.upper(playerEnglishClass), 1, true) ~= nil) then -- This quest is for the players class --
									table.insert(qcZoneQuests, qcQuestDatabase)
								end
							else
								table.insert(qcZoneQuests, qcQuestDatabase)
							end
						else
							table.insert(qcZoneQuests, qcQuestDatabase)
						end
					end
				elseif (playerEnglishFaction == "Horde") then
					if (qcQuestDatabase[6] == 2) or (qcQuestDatabase[6] == 3) or (qcQuestDatabase[6] == 4) then
						if (_G["qcClassCheckButton"]:GetChecked() == 1) then -- We dont want to includes quests that are for other classes --
							if (qcQuestDatabase[7] == 1) then -- This is a class specific quest --
								if (string.find(qcQuestDatabase[8], string.upper(playerEnglishClass), 1, true) ~= nil) then -- This quest is for the players class --
									table.insert(qcZoneQuests, qcQuestDatabase)
								end
							else
								table.insert(qcZoneQuests, qcQuestDatabase)
							end
						else
							table.insert(qcZoneQuests, qcQuestDatabase)
						end
					end
				end
			else -- Get all factions quests --
				if (_G["qcClassCheckButton"]:GetChecked() == 1) then -- We dont want to includes quests that are for other classes --
					if (qcQuestDatabase[7] == 1) then -- This is a class specific quest --
						if (string.find(qcQuestDatabase[8], string.upper(playerEnglishClass), 1, true) ~= nil) then -- This quest is for the players class --
							table.insert(qcZoneQuests, qcQuestDatabase)
						end
					else
						table.insert(qcZoneQuests, qcQuestDatabase)
					end
				else
					table.insert(qcZoneQuests, qcQuestDatabase)
				end
			end
		end
	end

end

function qcMenuMouseWheel(self, delta)

	local currentPosition = qcMenuSlider:GetValue()

	if (delta < 0) and (currentPosition < questCount) then
		qcMenuSlider:SetValue(currentPosition + 1)
	elseif (delta > 0) and (currentPosition > 1) then
		qcMenuSlider:SetValue(currentPosition - 1)
	end

end

function qcZoneDropdown_Initialize(self, level)

local dropdownInfo

	if (level == 1) then

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Continents"
		dropdownInfo.isTitle = 1
		dropdownInfo.notCheckable = true
		UIDropDownMenu_AddButton(dropdownInfo, level)

		for qcContinentIndex, qcContinent in ipairs(qcContinents) do
			dropdownInfo = UIDropDownMenu_CreateInfo()
			dropdownInfo.text = qcContinent[2]
			dropdownInfo.notCheckable = true
			dropdownInfo.hasArrow = true
			dropdownInfo.value = qcContinent[1]
			UIDropDownMenu_AddButton(dropdownInfo, level)
		end

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Dungeons & Raids"
		dropdownInfo.isTitle = 1
		dropdownInfo.notCheckable = true
		UIDropDownMenu_AddButton(dropdownInfo, level)

		for qcDungeonCategoryIndex, qcDungeonCategory in ipairs(qcDungeonCategories) do
			dropdownInfo = UIDropDownMenu_CreateInfo()
			dropdownInfo.text = qcDungeonCategory[2]
			dropdownInfo.notCheckable = true
			dropdownInfo.hasArrow = true
			dropdownInfo.value = qcDungeonCategory[1]
			UIDropDownMenu_AddButton(dropdownInfo, level)
		end

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Class Quests"
		dropdownInfo.isTitle = 1
		dropdownInfo.notCheckable = true
		UIDropDownMenu_AddButton(dropdownInfo, level)

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Classes"
		dropdownInfo.notCheckable = true
		dropdownInfo.hasArrow = true
		dropdownInfo.value = 30
		UIDropDownMenu_AddButton(dropdownInfo, level)

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Miscellaneous"
		dropdownInfo.isTitle = 1
		dropdownInfo.notCheckable = true
		UIDropDownMenu_AddButton(dropdownInfo, level)

		for qcMiscellaneousCategoriesIndex, qcMiscellaneousCategory in ipairs(qcMiscellaneousCategories) do
			dropdownInfo = UIDropDownMenu_CreateInfo()
			dropdownInfo.text = qcMiscellaneousCategory[2]
			dropdownInfo.notCheckable = true
			dropdownInfo.hasArrow = true
			dropdownInfo.value = qcMiscellaneousCategory[1]
			UIDropDownMenu_AddButton(dropdownInfo, level)
		end

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Options"
		dropdownInfo.isTitle = 1
		dropdownInfo.notCheckable = true
		UIDropDownMenu_AddButton(dropdownInfo, level)

		dropdownInfo = UIDropDownMenu_CreateInfo()
		dropdownInfo.text = "Perform Server Query..."
		dropdownInfo.notCheckable = true
		dropdownInfo.colorCode = COLOUR_DRUID
		dropdownInfo.arg1 = "SERVERQUERY"
		function dropdownInfo.func(button, arg1)
			print(COLOUR_QC .. "Quest Completist: " .. FONT_COLOR_CODE_CLOSE .. "A server query has been requested. This will likely freeze your game for a few seconds - depending on how many quests you have completed in the past.")
			frameQuestCompletist:RegisterEvent("QUEST_QUERY_COMPLETE")
			QueryQuestsCompleted()
		end
		UIDropDownMenu_AddButton(dropdownInfo, level)

	elseif (level == 2) then

		if (UIDROPDOWNMENU_MENU_VALUE == 1) then -- Kalimdor
			for qcZoneIndex, qcZone in ipairs(qcZones) do
				if (qcZone[1] == 1) then -- This is a zone in Kalimdor
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcZone[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcZone[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcZone[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 2) then -- Eastern Kingdoms
			for qcZoneIndex, qcZone in ipairs(qcZones) do
				if (qcZone[1] == 2) then -- This is a zone in Eastern Kingdoms
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcZone[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcZone[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcZone[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 3) then -- Outland
			for qcZoneIndex, qcZone in ipairs(qcZones) do
				if (qcZone[1] == 3) then -- This is a zone in Outland
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcZone[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcZone[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcZone[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 4) then -- Northrend
			for qcZoneIndex, qcZone in ipairs(qcZones) do
				if (qcZone[1] == 4) then -- This is a zone in Northrend
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcZone[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcZone[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcZone[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 5) then -- Elsewhere in Azeroth --
			for qcZoneIndex, qcZone in ipairs(qcZones) do
				if (qcZone[1] == 5) then -- This is a zone Elsewhere in Azeroth
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcZone[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcZone[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcZone[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 10) then -- Classic Dungeon Period
			for qcDungeonIndex, qcDungeon in ipairs(qcDungeons) do
				if (qcDungeon[1] == 10) then -- This is a Classic Dungeon
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcDungeon[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcDungeon[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcDungeon[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 11) then -- The Burning Crusade Dungeon Period
			for qcDungeonIndex, qcDungeon in ipairs(qcDungeons) do
				if (qcDungeon[1] == 11) then -- This is a The Burning Crusade Dungeon
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcDungeon[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcDungeon[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcDungeon[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 12) then -- Wrath of the Lich King Dungeon Period
			for qcDungeonIndex, qcDungeon in ipairs(qcDungeons) do
				if (qcDungeon[1] == 12) then -- This is a Wrath of the Lich King Dungeon
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcDungeon[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcDungeon[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcDungeon[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 13) then -- Cataclysm Dungeon Period
			for qcDungeonIndex, qcDungeon in ipairs(qcDungeons) do
				if (qcDungeon[1] == 13) then -- This is a Cataclysm Dungeon
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcDungeon[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcDungeon[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcDungeon[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 14) then -- Raid
			for qcDungeonIndex, qcDungeon in ipairs(qcDungeons) do
				if (qcDungeon[1] == 14) then -- This is a Raid
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcDungeon[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcDungeon[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcDungeon[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 30) then -- Class Quests
			for qcClassIndex, qcClass in ipairs(qcClasses) do
				if (qcClass[1] == 30) then -- This is a Class Quest
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcClass[3]
					dropdownInfo.notCheckable = false
					dropdownInfo.colorCode = qcClass[4]
					if (currentZone == qcClass[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcClass[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 20) then -- Professions
			for qcProfessionIndex, qcProfession in ipairs(qcProfessions) do
				if (qcProfession[1] == 20) then -- This is a Profession
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcProfession[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcProfession[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcProfession[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 21) then -- World Events
			for qcWorldEventIndex, qcWorldEvent in ipairs(qcWorldEvents) do
				if (qcWorldEvent[1] == 21) then -- This is a World Event
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcWorldEvent[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcWorldEvent[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcWorldEvent[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 22) then -- Battlegrounds
			for qcBattlegroundIndex, qcBattleground in ipairs(qcBattlegrounds) do
				if (qcBattleground[1] == 22) then -- This is a Battleground
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcBattleground[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcBattleground[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcBattleground[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		elseif (UIDROPDOWNMENU_MENU_VALUE == 23) then -- Specials
			for qcSpecialIndex, qcSpecial in ipairs(qcSpecials) do
				if (qcSpecial[1] == 23) then -- This is a Special
					dropdownInfo = UIDropDownMenu_CreateInfo()
					dropdownInfo.text = qcSpecial[3]
					dropdownInfo.notCheckable = false
					if (currentZone == qcSpecial[2]) then
						dropdownInfo.checked = true
					end
					dropdownInfo.arg1 = qcSpecial[2]
					function dropdownInfo.func(button, arg1)
						qcUpdateMenu(arg1, 1, false)
						CloseDropDownMenus()
					end
					UIDropDownMenu_AddButton(dropdownInfo, level)
				end
			end
		end

	end

end

function qcZoneDropdownButton_OnClick(self, button, down)

	local name = self:GetName()
	ToggleDropDownMenu(1, nil, qcZoneDropdownMenu, name, 0, 0)

end

function qcZoneDropdownOnLoad(self)

	UIDropDownMenu_Initialize(self, qcZoneDropdown_Initialize)

end

function qcFactionCheckButton_OnClick()

	qcUpdateMenu(currentZone, qcMenuSlider:GetValue(), false)

end

function qcClassCheckButton_OnClick()

	qcUpdateMenu(currentZone, qcMenuSlider:GetValue(), false)

end

local function qcGetPlayerClassFaction()

	playerLocalizedClass, playerEnglishClass = UnitClass("player")
	playerEnglishFaction, playerLocalizedFaction = UnitFactionGroup("player")

	_G["qcFactionCheckButtonText"]:SetText("Hide Opposing Forces Quests")
	_G["qcClassCheckButtonText"]:SetText("Hide Quests for Other Classes")

end

local function qcGetZoneIDFromName(zoneName, zoneContinent)

	for qcZoneIndex, qcZone in ipairs(qcZones) do
		if (qcZone[1] == zoneContinent) then
			if (qcZone[3] == zoneName) then -- This seems to be the right one --
				return qcZone[2]
			end
		end
	end

	return nil

end

local function qcZoneChangedNewArea()

	local currentContinent = nil

	-- Only try to detect the current zone if the map is not open --
	if not WorldMapFrame:IsShown() then
		currentContinent = GetCurrentMapContinent()
	else
		return nil
	end

	zoneID = qcGetZoneIDFromName(GetRealZoneText(), currentContinent)

	if zoneID ~= nil then
		qcUpdateMenu(zoneID, 1, false)
	end

end

local function qcRecievedAddonMessage(...)

local qcPrefix
local qcMessage
local qcChannel
local qcSender
local qcCleanedMessage
local qcCleanedArgument

	qcPrefix, qcMessage, qcChannel, qcSender = ...
	if (qcPrefix == "QCOMPLETIST") then
		qcCleanedMessage = string.sub(qcMessage, 1, (string.find(qcMessage, ADDON_DELIMITER, 1, true) - 1))
		qcCleanedArgument = string.sub(qcMessage, (string.find(qcMessage, ADDON_DELIMITER, 1, true) + 1), #qcMessage)

		if (qcCleanedMessage == "VERSIONCASCADE") then
			if (tonumber(qcCleanedArgument) > ADDON_VERSION) then
				print(COLOUR_QC .. "Quest Completist: " .. FONT_COLOR_CODE_CLOSE .. "A new version has been detected! You are currently using version " .. ADDON_VERSION .. ", but " .. qcSender .. " is using version " .. qcCleanedArgument .. ".")
			end
		elseif (qcCleanedMessage == "Other Messages") then
			-- 
		else
			print(COLOUR_QC .. "Quest Completist: " .. FONT_COLOR_CODE_CLOSE .. "Unknown addon message recieved from " .. qcSender .. ". It is possible you are running an old version of this addon.")
		end
	end

end

function qcUpdateTooltip(button)

local questID = _G["qcMenuButton" .. button .. "_QuestTag"]:GetText()

	GameTooltip:SetOwner(frameQuestCompletist, "ANCHOR_BOTTOMRIGHT", -30, 500)
	GameTooltip:ClearLines()
	GameTooltip:SetHyperlink("quest:" .. _G["qcMenuButton" .. button .. "_QuestTag"]:GetText())
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Quest ID: " .. questID, 0.58, 0.51, 0.79)
	GameTooltip:Show()

end

function qcCloseTooltip()

	GameTooltip:Hide()

end

local function qcVersionCascade()

local inGuild

	-- Initiate version cascade --
	inGuild = IsInGuild()
	if (inGuild == 1) then
		SendAddonMessage(ADDON_MSG_PREFIX, "VERSIONCASCADE:" .. ADDON_VERSION, "GUILD")
	end

end

local function qcEventHandler(self, event, ...) -- The event handler --

	if (event == "QUEST_GREETING") then
		QuestGreetingEvent()
	elseif (event == "GOSSIP_SHOW") then
		GossipShowEvent()
	elseif (event == "QUEST_COMPLETE") then
		addComplete()
		qcQuestHistory_Complete()
		qcUpdateMenu(nil, qcMenuSlider:GetValue(), true)
	elseif (event == "QUEST_PROGRESS") then
		addProgress()
	elseif (event == "QUEST_DETAIL") then
	elseif (event == "QUEST_ACCEPTED") then
		addQuest(...)
	elseif (event == "UNIT_QUEST_LOG_CHANGED") then
	elseif (event == "QUEST_QUERY_COMPLETE") then
			questQueryCompleted()
			frameQuestCompletist:UnregisterEvent("QUEST_QUERY_COMPLETE")
	elseif (event == "PLAYER_ENTERING_WORLD") then
		qcGetPlayerClassFaction()
		qcZoneChangedNewArea()
		qcVersionCascade()
	elseif (event == "ZONE_CHANGED_NEW_AREA") then
		qcZoneChangedNewArea()
	elseif (event == "CHAT_MSG_ADDON") then
		qcRecievedAddonMessage(...)
	end

end

function frameQuestCompletist_OnLoad(self)

	-- Correct the portrait icon --
	SetPortraitToTexture("frameQuestCompletist_Portrait", "Interface\\ICONS\\TRADE_ARCHAEOLOGY_DRAENEI_TOME")

	-- Register the frame so it can be moved --
	self:RegisterForDrag("LeftButton")

	-- Register for events --
	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_COMPLETE")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("CHAT_MSG_ADDON")

	-- Send events to the event handler --
	self:SetScript("OnEvent", qcEventHandler)

end