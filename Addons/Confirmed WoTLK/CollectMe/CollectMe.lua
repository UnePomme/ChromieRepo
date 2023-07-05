COLLECTME_NUM_ITEMS_TO_DISPLAY = 9;

COLLECTME_CRITTER = 1;
COLLECTME_MOUNT   = 2;

COLLECTME_VERSION = "1.1.14";

local PotentialCompanionsTable = { };
local OverallCompanionsTable = { };
local PotentialMountsTable = { }; 
local OverallMountsTable = { };
local MissingItemsTable = { };
local PlayerFaction = nil;
local LocalizedPlayerFaction = nil;
local PlayerRace = nil;
local LocalizedPlayerRace = nil;
local PlayerClass = nil;
local LocalizedPlayerClass = nil;
local PlayerIsEngineer = false;
-- local PlayerIsGnomeEngineer = false;
-- local PlayerIsGoblinEngineer = false;
local PlayerIsTailor = false;
local ClickedScrollItem = "";
local nextCompanion = nil;
local is_entered = false;

CollectMeSavedVars = { IgnoredCompanionsTable = { }, IgnoredMountsTable = { }, Filters = { }, RndCom = { }, Options = { }, };

function CollectMe_OnLoad()
	this:RegisterForDrag("LeftButton");
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	
	SLASH_COLLECTME1 = "/collectme";
	SLASH_COLLECTME2 = "/cm";
 	SlashCmdList["COLLECTME"] = CollectMe_SlashHandler;
 	
 	COLLECTME_LIST_ITEM_HEIGHT = floor(CollectMeFrameScrollFrameButton1:GetHeight());
 	upperLeft:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1);
 	tinsert(UISpecialFrames, CollectMeFrame:GetName());
 	PanelTemplates_SetTab(CollectMeFrame, COLLECTME_CRITTER);
 	getglobal("CollectMeFrameHeaderFrameText"):SetText("Collect Me "..COLLECTME_VERSION);
end

function CollectMe_OnEvent(event)
    if(event == "ADDON_LOADED") then
        if(arg1 == "CollectMe") then
            hooksecurefunc("MoveForwardStart",CollectMe_SummonOnMoving);
            hooksecurefunc("ToggleAutoRun",CollectMe_SummonOnMoving);
            if(CollectMeSavedVars.Options["button_hide"] ~= nil) then
                CollectMeButtonFrame:Hide();
            end
            if(is_entered == true) then
                CollectMe_Initialize(CollectMeFrame);
                CollectMe_CheckSavedVars();
                CollectMe_NextCompanion();
            end
        end 
    end
    if(event == "PLAYER_ENTERING_WORLD") then
        CollectMe_Initialize(CollectMeFrame);
        CollectMe_CheckSavedVars();
        CollectMe_NextCompanion();
        is_entered = true;
    end
end

function CollectMe_SummonOnMoving()
    if(CollectMeSavedVars.Options == nil) then
        CollectMeSavedVars.Options = { };
    end
    if(IsMounted() == nil and IsStealthed() == nil) then
        if(CollectMeSavedVars.Options["moving"] ~= nil) then
            if(not(UnitIsPVP("player") == 1 and CollectMeSavedVars.Options["disableonpvp"] == 1)) then
                local companionActive = CollectMe_checkActive();
                if(companionActive ~= true) then
                    if(nextCompanion == nil) then
                        CollectMe_NextCompanion();
                        if(nextCompanion ~= nil) then
                            CallCompanion("CRITTER", nextCompanion);
                        end
                    else
                        CallCompanion("CRITTER", nextCompanion);
                    end
                    CollectMe_NextCompanion();
                end
            end
        end
    end
    if(UnitIsPVP("player") == 1 and CollectMeSavedVars.Options["disableonpvp"] == 1) then
        CollectMe_Dismisser();
    end
end

function CollectMe_checkActive()
    for i=1, GetNumCompanions("CRITTER") do
        local _, _, _, _, issummoned = GetCompanionInfo("CRITTER", i);
        if(issummoned ~= nil) then
            return true;
        end
    end
    return false;
end

function CollectMe_NextCompanion()
    local summonableCompanions = { };
    local pointer = 1;
    for i=1, GetNumCompanions("CRITTER") do
        local creatureID = GetCompanionInfo("CRITTER", i);
        if(CollectMeSavedVars.RndCom[creatureID] ~= nil and CollectMeSavedVars.RndCom[creatureID] ~= 0) then
            for j=1, CollectMeSavedVars.RndCom[creatureID] do
                table.insert(summonableCompanions, pointer, i);
                pointer = pointer + 1;
            end
        end
    end
    if (pointer ~= 1) then
        local call = math.random(1, pointer-1);
        nextCompanion = summonableCompanions[call];
        
        local _, _, _, texture = GetCompanionInfo("CRITTER", nextCompanion);
    
        getglobal("CollectMeButtonFrame"):SetBackdrop({bgFile = texture, 
                                            edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
                                            tile = false, tileSize = 0, edgeSize = 16, 
                                            insets = { left = 4, right = 4, top = 4, bottom = 4 }});
    else
        CollectMeButtonFrame:Hide();
    end
end

function CollectMe_SkipCompanion()
    CollectMe_NextCompanion();
end

function CollectMe_SummonCompanion()
    CallCompanion("CRITTER", nextCompanion);
    CollectMe_NextCompanion();
end

function CollectMe_SlashHandler(msg)
    PanelTemplates_SetTab(CollectMeFrame, CollectMeFrame.selectedTab); -- reset to pet window since :(
  --  CollectMe_Initialize(CollectMeFrame);
    CollectMe_Update(CollectMeFrame.selectedTab);
    if(msg == "options" or msg == "config") then
        InterfaceOptionsFrame_OpenToCategory(CollectMePanel);
    elseif (msg == "randomcompanion") then
        if(nextCompanion ~= nil) then
            CallCompanion("CRITTER", nextCompanion);
        end
        CollectMe_NextCompanion();
    else
        CollectMeFrame:Show();    
    end
end

function CollectMe_CheckSavedVars()
    if(CollectMeSavedVars.RndCom == nil) then
        CollectMeSavedVars.RndCom = { };
    end
    for i=1, GetNumCompanions("CRITTER") do
        local creatureID = GetCompanionInfo("CRITTER", i);
        if(CollectMeSavedVars.RndCom[creatureID] == nil) then
            CollectMeSavedVars.RndCom[creatureID] = 5;
        end
    end
end

function CollectMe_OpenFromButton (id)
    local open = 0;
    if (id == "CRITTER" ) then
        open = COLLECTME_CRITTER;
    else
        open = COLLECTME_MOUNT;
    end
    PanelTemplates_SetTab(CollectMeFrame, open);
    CollectMe_Initialize(CollectMeFrame);
    CollectMe_Update(open);
    CollectMeFrame:Show();
end

function CollectMe_Initialize(self)

    PlayerFaction, LocalizedPlayerFaction = UnitFactionGroup("player");
    LocalizedPlayerRace, PlayerRace = UnitRace("player");
    LocalizedPlayerClass, PlayerClass = UnitClass("player");

    local spellName;
    _, _, _, numSpells = GetSpellTabInfo(1);
    for index=1, numSpells do
        spellName = GetSpellName(index, BOOKTYPE_SPELL)

        if ( spellName == GetSpellInfo(4036) ) then
            PlayerIsEngineer = true;
        end

--        if ( spellName == GetSpellInfo(20219) ) then
--            PlayerIsGnomeEngineer = true;
--        end

--        if ( spellName == GetSpellInfo(20222) ) then
--            PlayerIsGoblinEngineer = true;
--        end

        if ( spellName == GetSpellInfo(3908) ) then
            PlayerIsTailor = true;
        end
    end

    CollectMe_InitCompanionTable();
    CollectMe_InitMountTable();

    CollectMe_Update(CollectMeFrame.selectedTab);
end

function CollectMe_Update(id)
    for k,v in pairs(MissingItemsTable) do
        MissingItemsTable[k] = nil;
    end

    local totalItems, totalKnownItems = 0, 0;

    if ( id == COLLECTME_CRITTER ) then
        COLLECTME_CURRENT_FILTERS = PotentialCompanionsFilters;
        totalItems, totalKnownItems = CollectMe_CompanionUpdate();
    elseif ( id == COLLECTME_MOUNT ) then
        COLLECTME_CURRENT_FILTERS = PotentialMountsFilters;
        totalItems, totalKnownItems = CollectMe_MountUpdate();
    end
    
    local knownItemPercentage = floor((totalKnownItems/totalItems)*100);
    CollectMeFrameStatusBar:SetValue(knownItemPercentage);
    CollectMeFrameStatusBarText:SetText(totalKnownItems.." / "..totalItems.." - "..knownItemPercentage.."\%");

    if ( CollectMeFrame:IsVisible() ) then
        CollectMeScrollFrameUpdate();
    end
end

function CollectMe_CompanionUpdate()
    CollectMe_ApplyCompanionFilter();
    local totalKnownCompanions = 0;
    local totalSpecialCompanions = 0;
    local knownCompanionsTable = { };
    local extraCompanionsTable = { };
    for i=1, GetNumCompanions("CRITTER") do
        local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("CRITTER", i);
        if ( OverallCompanionsTable[spellID] == nil ) then
            DEFAULT_CHAT_FRAME:AddMessage("WARNING - CollectMe didn't have Companion SpellID:"..spellID.." name:"..creatureName.." in its database. Please contact the mod author.");  -- Was Disabled
        end

        local name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellID);
        
        totalKnownCompanions = totalKnownCompanions + 1;
        knownCompanionsTable[spellID] = 1;
        
        if ( CollectMeSavedVars.IgnoredCompanionsTable[name] ) then
            CollectMeSavedVars.IgnoredCompanionsTable[name] = nil;
        end
    end

    local totalDBCompanions = 0;
    local t = { };
    local name, icon;
    local ignoredCompanionsTable = { };
    local totalIgnoredCompanions = 0;
    for k,v in pairs(PotentialCompanionsTable) do
        totalDBCompanions = totalDBCompanions + 1;

        if ( knownCompanionsTable[k] == nil ) then
            name, _, icon, _, _, _, _, _, _ = GetSpellInfo(k);

            t = { };
            t.itemID = v;
            t.name = name;
            t.icon = icon;

            if ( CollectMeSavedVars.IgnoredCompanionsTable[name] ) then
                totalIgnoredCompanions = totalIgnoredCompanions + 1;
                t.isIgnored = true;
                table.insert(ignoredCompanionsTable, t);
            else
                table.insert(MissingItemsTable, t);
            end
        end
    end

   table.sort(MissingItemsTable, CollectMe_SortTableByName);

   t = { };
   t.name = "Missing Companions ("..#MissingItemsTable..")";
   t.isHeader = true;
   t.isExpanded = true;
   table.insert(MissingItemsTable, 1, t);

    if ( totalIgnoredCompanions > 0 ) then
        table.sort(ignoredCompanionsTable, CollectMe_SortTableByName);

        t = { };
        t.name = "Inactive Companions ("..totalIgnoredCompanions..")";
        t.isHeader = true;
        t.isExpanded = true;
        table.insert(MissingItemsTable, t);

        for k,v in pairs(ignoredCompanionsTable) do
            table.insert(MissingItemsTable, v);
        end
    end

    return (totalDBCompanions-totalIgnoredCompanions), totalKnownCompanions;
end

function CollectMe_MountUpdate()
    CollectMe_ApplyMountFilter();
    local totalKnownMounts = 0;
    local totalSpecialMounts = 0;
    local knownMountsTable = { };
    local extraMountsTable = { };
    for i=1, GetNumCompanions("MOUNT") do
        local creatureID, creatureName, spellID, icon, active = GetCompanionInfo("MOUNT", i);
        if ( OverallMountsTable[spellID] == nil ) then
            DEFAULT_CHAT_FRAME:AddMessage("WARNING - CollectMe didn't have Mount SpellID:"..spellID.." name:"..creatureName.." in its database. Please contact the mod author.");  -- Was Disabled
        end

        local name, _, icon, _, _, _, _, _, _ = GetSpellInfo(spellID);

        totalKnownMounts = totalKnownMounts + 1;
        knownMountsTable[spellID] = 1;

        if ( CollectMeSavedVars.IgnoredMountsTable[name] ) then
            CollectMeSavedVars.IgnoredMountsTable[name] = nil;
        end
    end

    local totalDBMounts = 0;
    local name, icon;
    local t = { };
    local ignoredMountsTable = { };
    local totalIgnoredMounts = 0;
    for k,v in pairs(PotentialMountsTable) do
        totalDBMounts = totalDBMounts + 1;

        if ( knownMountsTable[k] == nil ) then
            name, _, icon, _, _, _, _, _, _ = GetSpellInfo(k);

            t = { };
            t.itemID = v;
            t.name = name;
            t.icon = icon;

            if ( CollectMeSavedVars.IgnoredMountsTable[name] ) then
                    totalIgnoredMounts = totalIgnoredMounts + 1;
                    t.isIgnored = true;
                    table.insert(ignoredMountsTable, t);
            else
                table.insert(MissingItemsTable, t);
            end
        end
    end

    table.sort(MissingItemsTable, CollectMe_SortTableByName);
    
    t = { };
    t.name = "Missing Mounts ("..#MissingItemsTable..")";
    t.isHeader = true;
    t.isExpanded = true;
    table.insert(MissingItemsTable, 1, t);

    if ( totalIgnoredMounts > 0 ) then
        table.sort(ignoredMountsTable, CollectMe_SortTableByName);

        t = { };
        t.name = "Inactive Mounts ("..totalIgnoredMounts..")";
        t.isHeader = true;
        t.isExpanded = true;
        table.insert(MissingItemsTable, t);

        for k,v in pairs(ignoredMountsTable) do
            table.insert(MissingItemsTable, v);
        end
    end
    return (totalDBMounts-totalIgnoredMounts), totalKnownMounts;
end

function CollectMe_InitCompanionTable()
    PotentialCompanionsTable = { };
    OverallCompanionsTable = { };
    local t = CollectMeCommonCompanionTable;
    for k,v in pairs(t) do
        table.insert(PotentialCompanionsTable, k, v);
        table.insert(OverallCompanionsTable, k, v);
    end

    t = { };
    if ( PlayerFaction == "Alliance" ) then
          t = CollectMeAllianceCompanionTable;
    else
          t = CollectMeHordeCompanionTable;
    end

    for k,v in pairs(t) do
        table.insert(PotentialCompanionsTable, k, v);
        table.insert(OverallCompanionsTable, k, v);
    end

    t = { };
    if ( PlayerIsEngineer ) then
        t = CollectMeEngineerCompanionTable;
    end

--    if ( PlayerIsGnomeEngineer ) then
--        t = CollectMeGnomeEngineerCompanionTable;
--    end

--    if ( PlayerIsGoblinEngineer ) then
--        t = CollectMeGoblinEngineerCompanionTable;
--    end

    for k,v in pairs(t) do
        table.insert(PotentialCompanionsTable, k, v);
        table.insert(OverallCompanionsTable, k, v);
    end
    
end

function CollectMe_ApplyCompanionFilter()
    local t = { };
    if (CollectMeSavedVars.Filters ~= nil)  then
        if (CollectMeSavedVars.Filters.ComPvp ~= nil) then
            t = CollectMeCompanionFilter.pvp;
            for k,v in pairs(t) do
               PotentialCompanionsTable[k] = nil;
            end
        end
        
        if (CollectMeSavedVars.Filters.ComNlo ~= nil) then
            t = CollectMeCompanionFilter.nlo;
            for k,v in pairs(t) do
               PotentialCompanionsTable[k] = nil;
            end
        end
        
        if (CollectMeSavedVars.Filters.ComChi ~= nil) then
            t = CollectMeCompanionFilter.chi;
            for k,v in pairs(t) do
               PotentialCompanionsTable[k] = nil;
            end
        end
        
        if (CollectMeSavedVars.Filters.ComCol ~= nil) then
            t = CollectMeCompanionFilter.col;
            for k,v in pairs(t) do
               PotentialCompanionsTable[k] = nil;
            end
        end
        
        if (CollectMeSavedVars.Filters.ComTcg ~= nil) then
            t = CollectMeCompanionFilter.tcg;
            for k,v in pairs(t) do
               PotentialCompanionsTable[k] = nil;
            end
        end
    end
    
end

function CollectMe_InitMountTable()
    PotentialMountsTable = { };
    OverallMountsTable = { };
    local t = CollectMeCommonMountTable;
    for k,v in pairs(t) do
        table.insert(PotentialMountsTable, k, v);
        table.insert(OverallMountsTable, k, v);
    end

    t = { };
    if ( PlayerFaction == "Alliance" ) then
          t = CollectMeAllianceMountTable;
    else
          t = CollectMeHordeMountTable;
    end

    for k,v in pairs(t) do
        table.insert(PotentialMountsTable, k, v);
        table.insert(OverallMountsTable, k, v);
    end

    t = { };
    if ( PlayerClass == "PALADIN" ) then
        if ( PlayerFaction == "Alliance" ) then
            t = CollectMeAlliancePaladinMountTable;
        else
            t = CollectMeHordePaladinMountTable;
        end
    end

    if ( PlayerClass == "WARLOCK" ) then
        t = CollectMeWarlockMountTable;
    end
    
    if ( PlayerClass == "DEATHKNIGHT" ) then
        t = CollectMeDeathknightMountTable;
    end

    for k,v in pairs(t) do
        table.insert(PotentialMountsTable, k, v);
        table.insert(OverallMountsTable, k, v);
    end

    t = { };
    if ( PlayerIsEngineer ) then
        t = CollectMeEngineerMountTable;
    end

    for k,v in pairs(t) do
        table.insert(PotentialMountsTable, k, v);
        table.insert(OverallMountsTable, k, v);
    end

    t = { };
    if ( PlayerIsTailor ) then
        t = CollectMeTailorMountTable;
    end

    for k,v in pairs(t) do
        table.insert(PotentialMountsTable, k, v);
        table.insert(OverallMountsTable, k, v);
    end
    
end

function CollectMe_ApplyMountFilter()
    local t = { };
    if (CollectMeSavedVars.Filters ~= nil)  then
        if (CollectMeSavedVars.Filters.MouPvp ~= nil) then
            t = CollectMeMountFilter.pvp;
            for k,v in pairs(t) do
               PotentialMountsTable[k] = nil;
            end
        end
        
        if (CollectMeSavedVars.Filters.MouNlo ~= nil) then
            t = CollectMeMountFilter.nlo;
            for k,v in pairs(t) do
               PotentialMountsTable[k] = nil;
            end
        end
        
        if (CollectMeSavedVars.Filters.MouTcg ~= nil) then
            t = CollectMeMountFilter.tcg;
            for k,v in pairs(t) do
               PotentialMountsTable[k] = nil;
            end
        end
    end
end

function CollectMeScrollFrameUpdate()
    local displayTable = { };
    for k,v in ipairs(MissingItemsTable) do
        table.insert(displayTable, k, v);
    end

    local index = 1;
    while index <= #displayTable do
        if ( displayTable[index].isHeader and (not displayTable[index].isExpanded) ) then
            local i = index + 1;
            while ( i <= #displayTable and (not (displayTable[i].isHeader)) ) do
                table.remove(displayTable, i);
            end
        end
        index = index + 1;
    end

    local totalItemsToShow = #displayTable;
    local index, button, buttonText, buttonIcon, buttonModel, header, headerText;

    for line=1, COLLECTME_NUM_ITEMS_TO_DISPLAY do
        index = line + FauxScrollFrame_GetOffset(CollectMeFrameScrollFrame);
        button = getglobal("CollectMeFrameScrollFrameButton"..line);
        buttonText = getglobal("CollectMeFrameScrollFrameButton"..line.."Text");
        buttonIcon = getglobal("CollectMeFrameScrollFrameButton"..line.."Icon");
        buttonItemID = getglobal("CollectMeFrameScrollFrameButton"..line.."ItemID");
        header = getglobal("CollectMeFrameScrollFrameHeader"..line);
        headerText = getglobal("CollectMeFrameScrollFrameHeader"..line.."Text");

        if index <= totalItemsToShow then
             if ( displayTable[index].isHeader ) then
                button:Hide();
                headerText:SetText(displayTable[index].name);
                header:Show();

                if ( displayTable[index].isExpanded ) then
                    header:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
                else
                    header:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
                end
            else
                header:Hide();
                buttonText:SetText(displayTable[index].name);
                buttonItemID:SetText(displayTable[index].itemID);
                buttonIcon:SetNormalTexture(displayTable[index].icon);
                button:Show();
                if ( displayTable[index].name == ClickedScrollItem ) then
                    button:LockHighlight();
                else
                    button:UnlockHighlight();
                end
            end
        else
            button:Hide();
            header:Hide();
        end
    end
    FauxScrollFrame_Update(CollectMeFrameScrollFrame, totalItemsToShow, COLLECTME_NUM_ITEMS_TO_DISPLAY, COLLECTME_LIST_ITEM_HEIGHT);
end

function CollectMe_ScrollItemMouseOver(self)
    local itemName = getglobal(self:GetName().."Text"):GetText();
    local text = "No Info";
    local isCompanion = false;
    for k,v in pairs(CollectMeCompanionInfo) do
        cName = GetSpellInfo(k);
        if(cName == itemName) then
            text = v;
            isCompanion = true;
            break;
        end
    end
    
    if (isCompanion == false) then
        for k,v in pairs(CollectMeMountInfo) do
            cName = GetSpellInfo(k);
            if(cName == itemName) then
                text = v;
                break;
            end
        end
    end
    
    CollectMeInfoFrameText:SetText(text);
    CollectMeInfoFrame:Show();
    CollectMeScrollFrameUpdate();
end

function CollectMe_ScrollItemRightClicked(self)
    local itemName = getglobal(self:GetName().."Text"):GetText();
    for k,v in pairs(MissingItemsTable) do
        if ( v.name == itemName ) then
            if ( not v.isExtra ) then
                if ( v.isIgnored ) then
                    ToggleDropDownMenu(1, nil, getglobal(self:GetName().."DropDownActivateMenu"), self:GetName(), 25, 0);
                else
                    ToggleDropDownMenu(1, nil, getglobal(self:GetName().."DropDownInactivateMenu"), self:GetName(), 25, 0);
                end
            end
            break;
        end
    end
end

function CollectMe_ModelHandler(self)
    if(CollectMeSavedVars.Options["preview"] ~= nil) then 
        local creatureID = getglobal(self:GetName().."ItemID"):GetText();
	    if (creatureID ~= nil) then
            CollectMeModel:Show();
            CollectMeModel:SetModel("Interface\\Buttons\\TalkToMeQuestion_Grey.mdx"); 
			CollectMeModel:RefreshUnit(); 
            CollectMeModel:SetCreature(creatureID);
        end
    end
end

function CollectMe_DropDownInactivateMenuOnClick(self)
    local ignoredTable = { };
    if ( CollectMeFrame.selectedTab == COLLECTME_CRITTER ) then
        ignoredTable = CollectMeSavedVars.IgnoredCompanionsTable;
    elseif ( CollectMeFrame.selectedTab == COLLECTME_MOUNT ) then
        ignoredTable = CollectMeSavedVars.IgnoredMountsTable;
    end

    ignoredTable[self.value] = 1;

    CollectMe_Update(CollectMeFrame.selectedTab);
end

function CollectMe_DropDownActivateMenuOnClick(self)
    local ignoredTable = { };
    if ( CollectMeFrame.selectedTab == COLLECTME_CRITTER ) then
        ignoredTable = CollectMeSavedVars.IgnoredCompanionsTable;
    elseif ( CollectMeFrame.selectedTab == COLLECTME_MOUNT ) then
        ignoredTable = CollectMeSavedVars.IgnoredMountsTable;
    end

    ignoredTable[self.value] = nil;

    CollectMe_Update(CollectMeFrame.selectedTab);
end

function CollectMe_DropDownInactivateMenuOnLoad(self)
    local info = { };
    info.text  = "Mark as Inactive";
    info.value = getglobal(self:GetParent():GetName().."Text"):GetText();
    info.owner = self:GetParent():GetName();
    info.func  = CollectMe_DropDownInactivateMenuOnClick;
       
    UIDropDownMenu_AddButton(info);
end

function CollectMe_DropDownActivateMenuOnLoad(self)
    local info = { };
    info.text  = "Mark as Active";
    info.value = getglobal(self:GetParent():GetName().."Text"):GetText();
    info.owner = self:GetParent():GetName();
    info.func  = CollectMe_DropDownActivateMenuOnClick;
       
    UIDropDownMenu_AddButton(info);
end

function CollectMe_ScrollHeaderClicked(headerName)
    for k,v in ipairs(MissingItemsTable) do
        if ( v.isHeader and v.name == headerName ) then
            v.isExpanded = not (v.isExpanded);
            CollectMeScrollFrameUpdate();
            break;
        end
    end
end

function CollectMe_SortTableByName(a, b)
    return (a.name < b.name);
end

function CollectMe_OnDragStart()
	if(CollectMeSavedVars.Options["button_lock"] == nil) then
        this:StartMoving();
    end
end

function CollectMe_OnDragStop()
    if(CollectMeSavedVars.Options["button_lock"] == nil) then
	   this:StopMovingOrSizing();
	end
end

function CollectMe_Dismisser()
    DismissCompanion("CRITTER");
end
