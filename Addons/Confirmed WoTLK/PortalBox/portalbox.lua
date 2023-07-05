HideMMIcon = "0"
KeepWindowOpen = "0"
MinimapButtonUnbind = "0"

function PortalBox_MinimapButton_Reposition()
local playerClass, englishClass = UnitClass("player");
	PortalBox_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(MinimapPos)),(80*sin(MinimapPos))-52)
	if(englishClass ~= "MAGE") then
		PortalBox_MinimapButton:Hide();
	end
	if (MinimapButtonUnbind == "0") then
		PortalBox_MinimapButtonUnbound:Hide();
	end
end

function PortalBox_MinimapButtonUnbound_Reposition()
	local xpos,ypos = PortalBox_MinimapButton:GetLeft(), PortalBox_MinimapButton:GetBottom()

	PortalBox_MinimapButtonUnbound:ClearAllPoints();
	PortalBox_MinimapButtonUnbound:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT", MinimapPosUnboundX, MinimapPosUnboundY)
	if (MinimapButtonUnbind == "1") then
		PortalBox_MinimapButton:Hide();
	end
	if (MinimapPosUnboundY == NIL) then
		PortalBox_MinimapButtonUnbound:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT", xpos-16, ypos-16)
		MinimapPosUnboundY = ypos-16
		MinimapPosUnboundX = xpos-16
	end
	
end

function PortalBox_LoadPrefsPane(panel)
        panel.name = "PortalBox";

        InterfaceOptions_AddCategory(panel);
end

function portalbox_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("UNIT_SPELLCAST_START");
	out("• PortalBox 0.7 Loaded •");
	SLASH_PORTALBOX1 = "/portalbox";
	SLASH_PORTALBOX2 = "/port";
	SlashCmdList["PORTALBOX"] = function(msg)
					portalbox_SlashCommandHandler(msg);					
	end
	
end

function portalbox_OnEvent()
	if ( event == "VARIABLES_LOADED" ) then
		if (MinimapPos == NIL) then
			MinimapPos = 1
		end
    	PortalBox_MinimapButton_Reposition();
		PortalBox_MinimapButtonUnbound_Reposition();
		if (HideMMIcon == "1") then
			PortalBox_MinimapButton:Hide();
		end
	end
	if (KeepWindowOpen == "0") then
	PortalboxMainFrame:Hide();
	PortalboxHordeFrame:Hide();
	end
	
end

function PortalBox_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	MinimapPos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	PortalBox_MinimapButton_Reposition() -- move the button
end

function PortalBox_MinimapButtonUnbound_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()

	xpos = xpos/UIParent:GetScale()
	ypos = ypos/UIParent:GetScale()

	MinimapPosUnboundY = ypos
	MinimapPosUnboundX = xpos
	PortalBox_MinimapButtonUnbound_Reposition() -- move the button
end

function PortalBox_MinimapButton_OnClick(arg1)
	if (arg1 == "LeftButton") then
		portalbox_toggle(msg);
	else
		InterfaceOptionsFrame_OpenToCategory("PortalBox")
	end
end

function out(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

function portalbox_SlashCommandHandler(msg)
	if msg == "" then
		portalbox_toggle();
	end
	if msg == "config" then
		InterfaceOptionsFrame_OpenToCategory("PortalBox");
	end
end

function portalBox_toggleCollapseState()
	if (windowCollapseState ~= "1") then
		PortalboxMainFrame:SetScale(0.7);
		PortalboxHordeFrame:SetScale(0.7);
		collapseButton:SetNormalTexture("Interface/Buttons/UI-PlusButton-Up");
		collapseButton:SetPushedTexture("Interface/Buttons/UI-PlusButton-Down");
		collapseButtonHorde:SetNormalTexture("Interface/Buttons/UI-PlusButton-Up");
		collapseButtonHorde:SetPushedTexture("Interface/Buttons/UI-PlusButton-Down");
		windowCollapseState = "1";
	else
		PortalboxMainFrame:SetScale(1.0);
		PortalboxHordeFrame:SetScale(1.0);
		collapseButton:SetNormalTexture("Interface/Buttons/UI-MinusButton-Up");
		collapseButton:SetPushedTexture("Interface/Buttons/UI-MinusButton-Down");
		collapseButtonHorde:SetNormalTexture("Interface/Buttons/UI-MinusButton-Up");
		collapseButtonHorde:SetPushedTexture("Interface/Buttons/UI-MinusButton-Down");
		windowCollapseState = "0";
	end
end

function portalbox_toggle(num)
	faction = UnitFactionGroup("player")
	local frame = getglobal("PortalboxMainFrame")
	local hordeFrame = getglobal("PortalboxHordeFrame")
	
	
	if (faction == "Horde") then
		if (hordeFrame) then
			if (hordeFrame:IsVisible()) then
				hordeFrame:Hide();
			else
				hordeFrame:Show();
				end
			end
		else
	if (frame) then
		if (frame:IsVisible()) then
			frame:Hide();
		else
			frame:Show();
			end
		end
	end
end

