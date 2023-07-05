local hookEnabled = true;
local modifier;
local watchframeHookEnabled = false;

local function POIAnchorToCoord(poiframe)
    local point, relto, relpoint, x, y = poiframe:GetPoint()
    local frame = WorldMapDetailFrame
    local width = frame:GetWidth()
    local height = frame:GetHeight()
    local scale = frame:GetScale() / poiframe:GetScale()
    local cx = (x / scale) / width
    local cy = (-y / scale) / height

    if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
        return nil, nil
    end

    return cx * 100, cy * 100
end

local modTbl = {
    C = IsControlKeyDown,
    A = IsAltKeyDown,
    S = IsShiftKeyDown,
}

local function findQuestFrameFromQuestIndex(questId)
    -- Try to find the correct quest frame
    for i = 1, MAX_NUM_QUESTS do
        local questFrame = _G["WorldMapQuestFrame"..i];
        if ( not questFrame ) then
            break
        elseif ( questFrame.questId == questId ) then
            return questFrame
        end
    end
end

local function setQuestWaypoint(self)
    local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
    local x, y = POIAnchorToCoord(self)

    local qid = self.questId

    local title;
    if self.quest and self.quest.questLogIndex then
        title = GetQuestLogTitle(self.quest.questLogIndex)
    elseif self.questLogIndex then
        title = GetQuestLogTitle(self.questLogIndex)
    else
        title = "Quest #" .. qid .. " POI"
    end

    local uid = TomTom:AddZWaypoint(c, z, x, y, title)
    return uid
end

-- desc, persistent, minimap, world, custom_callbacks, silent, crazy)
local function poi_OnClick(self, button)
    -- Are we enabled?
    if not hookEnabled then
        return
    end

    -- Is this the right button/modifier?
    if button == "RightButton" then
        for i = 1, #modifier do
            local mod = modifier:sub(i, i)
            local func = modTbl[mod]
            if not func() then
                return
            end
        end
    else
        return
    end

    if self.parentName == "WatchFrameLines" then
        local questFrame = findQuestFrameFromQuestIndex(self.questId)
        if not questFrame then
            return
        else
            self = questFrame.poiIcon
        end
    end
   
    return setQuestWaypoint(self)
 end

local hooked = {}
hooksecurefunc("QuestPOI_DisplayButton", function(parentName, buttonType, buttonIndex, questId)
      local buttonName = "poi"..tostring(parentName)..tostring(buttonType).."_"..tostring(buttonIndex);
      local poiButton = _G[buttonName];
      
      if not hooked[buttonName] then
         poiButton:HookScript("OnClick", poi_OnClick)
         poiButton:RegisterForClicks("AnyUp")
         hooked[buttonName] = true
      end
end)

local setPoints = {}

-- This code will enable auto-tracking of closest quest objectives.  To
-- accomplish this, it hooks the WatchFrame_Update function, and when it
-- is called, it sets a waypoint to the closest quest id.
local function updateClosestPOI()
    local questIndex = GetQuestIndexForWatch(1);
    if ( questIndex ) then
        local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(questIndex);
        local playerMoney = GetMoney();
        local requiredMoney = GetQuestLogRequiredMoney(questIndex);			
        numObjectives = GetNumQuestLeaderBoards(questIndex);
        if ( isComplete and isComplete < 0 ) then
            isComplete = false;
        elseif ( numObjectives == 0 and playerMoney >= requiredMoney ) then
            isComplete = true;		
        end			

        -- check filters
        local filterOK = true;
        if ( isComplete and bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_COMPLETED_QUESTS) ~= WATCHFRAME_FILTER_COMPLETED_QUESTS ) then
            filterOK = false;
        elseif ( bit.band(WATCHFRAME_FILTER_TYPE, WATCHFRAME_FILTER_REMOTE_ZONES) ~= WATCHFRAME_FILTER_REMOTE_ZONES and not LOCAL_MAP_QUESTS[questID] ) then
            filterOK = false;
        end			

        if filterOK then
            -- Set a waypoint for this POI, it should be the higehst
            local questFrame = findQuestFrameFromQuestIndex(questID)
            if questFrame then
                for idx, uid in ipairs(setPoints) do
                    TomTom:RemoveWaypoint(uid)
                end
                local uid = setQuestWaypoint(questFrame.poiIcon)
                table.insert(setPoints, uid)
            end
        end
    end
end

hooksecurefunc("WatchFrame_Update", function()
    if watchframeHookEnabled then
        updateClosestPOI()
    end
end)

function TomTom:EnableDisablePOIIntegration()
    hookEnabled = TomTom.profile.poi.enable
    modifier = TomTom.profile.poi.modifier
    watchframeHookEnabled = TomTom.profile.poi.setClosest
end
