knownCompanions = { };

function CollectMePanel_OnLoad (panel)
    panel.name = "Collect Me";
    InterfaceOptions_AddCategory(panel);
end

function CollectMePanel_OnShow ()
    if (CollectMeSavedVars.Options == nil) then
        CollectMeSavedVars.Options = { };
    end
    getglobal(this:GetName().."CheckButton1"):SetChecked(CollectMeSavedVars.Options["preview"]);
    getglobal(this:GetName().."CheckButton2"):SetChecked(CollectMeSavedVars.Options["moving"]);
    getglobal(this:GetName().."CheckButton3"):SetChecked(CollectMeSavedVars.Options["button_hide"]);
    getglobal(this:GetName().."CheckButton4"):SetChecked(CollectMeSavedVars.Options["button_lock"]);
    getglobal(this:GetName().."CheckButton5"):SetChecked(CollectMeSavedVars.Options["disableonpvp"]);
end

function CollectMePanel_OnClick (id)
    CollectMeSavedVars.Options[id] = this:GetChecked();
    if(id == "button_hide") then
        if(this:GetChecked() == 1) then
            CollectMeButtonFrame:Hide();
        else
            CollectMeButtonFrame:Show();
        end
    end
end

function CollectMePanelFilter_OnLoad (panel)
    panel.name = "Filters";
    panel.parent = "Collect Me";
    InterfaceOptions_AddCategory(panel);
end 

function CollectMePanelFilter_OnShow ()
    if (CollectMeSavedVars.Filters == nil) then
        CollectMeSavedVars.Filters = { };
    end
    getglobal(this:GetName().."CheckButton1"):SetChecked(CollectMeSavedVars.Filters["ComNlo"]);
    getglobal(this:GetName().."CheckButton2"):SetChecked(CollectMeSavedVars.Filters["ComChi"]);
    getglobal(this:GetName().."CheckButton3"):SetChecked(CollectMeSavedVars.Filters["ComTcg"]);
    getglobal(this:GetName().."CheckButton4"):SetChecked(CollectMeSavedVars.Filters["ComPvp"]);
    getglobal(this:GetName().."CheckButton5"):SetChecked(CollectMeSavedVars.Filters["MouNlo"]);
    getglobal(this:GetName().."CheckButton6"):SetChecked(CollectMeSavedVars.Filters["MouPvp"]);
    getglobal(this:GetName().."CheckButton7"):SetChecked(CollectMeSavedVars.Filters["MouTcg"]);
    getglobal(this:GetName().."CheckButton8"):SetChecked(CollectMeSavedVars.Filters["ComCol"]);
end

function CollectMePanelFilterOption_OnClick (id, update)
    CollectMeSavedVars.Filters[id] = this:GetChecked();

    PanelTemplates_SetTab(CollectMeFrame, update);
    if(update == COLLECTME_CRITTER) then
        CollectMe_InitCompanionTable();
    else
        CollectMe_InitMountTable();
    end;    
    CollectMe_Update(update);
end

function CollectMePanelRndCom_OnLoad (panel)
    panel.name = "Random Companion";
    panel.parent = "Collect Me";
    InterfaceOptions_AddCategory(panel);
end 

function CollectMePanelRndCom_OnShow (self)
    if (CollectMeSavedVars.RndCom == nil) then
        CollectMeSavedVars.RndCom = { };
    end
    for i=1, GetNumCompanions("CRITTER") do
        local creatureID = GetCompanionInfo("CRITTER", i);
        table.insert(knownCompanions, i, creatureID);
    end
    for k,v in pairs(knownCompanions) do
        if(CollectMeSavedVars.RndCom[v] == nil) then
            CollectMeSavedVars.RndCom[v] = 5;
        end
    end 
    CollectMePanelScrollFrameUpdate();
end 

function CollectMePanelScrollFrameUpdate()
    if(knownCompanions ~= { } ) then
        local line;
        local linepulseoffset;
        local maxvalue = GetNumCompanions("CRITTER")+1;
        FauxScrollFrame_Update(CollectMePanelRndComScrollFrame,maxvalue,8,50);
        for line=1,8 do
            lineplusoffset = line + FauxScrollFrame_GetOffset(CollectMePanelRndComScrollFrame);
            if lineplusoffset < maxvalue then
                local creatureID, creatureName = GetCompanionInfo("CRITTER", lineplusoffset);
                if( CollectMeSavedVars.RndCom[creatureID] ~= nil ) then
                    getglobal("CollectMePanelRndComScrollFrameSlider"..line.."Text"):SetText(creatureName);
                    getglobal("CollectMePanelRndComScrollFrameSlider"..line.."CreatureID"):SetText(creatureID);
                    getglobal("CollectMePanelRndComScrollFrameSlider"..line):SetValue( CollectMeSavedVars.RndCom[creatureID] );
                    getglobal("CollectMePanelRndComScrollFrameSlider"..line):Show();
                end
            else
                getglobal("CollectMePanelRndComScrollFrameSlider"..line):Hide();
            end
        end
    end
end

function CollectMeSlider_Change(id, value)
    local pid = tonumber(id);
    if(CollectMeSavedVars.RndCom[pid] ~= value) then
        CollectMeSavedVars.RndCom[pid] = value;
    end
end