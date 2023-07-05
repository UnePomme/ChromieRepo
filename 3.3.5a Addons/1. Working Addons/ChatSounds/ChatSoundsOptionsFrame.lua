local groupmap = {} --- Map chat message types to OptionFrame's Group Numbers
groupmap[1] = "GUILD"
groupmap[2] = "OFFICER"
groupmap[3] = "PARTY"
groupmap[4] = "PARTY_LEADER"
groupmap[5] = "RAID"
groupmap[6] = "RAID_LEADER"
groupmap[7] = "BATTLEGROUND"
groupmap[8] = "BATTLEGROUND_LEADER"
groupmap[9] = "WHISPER"
groupmap[10] = "BNWHISPER"
groupmap[11] = "CHANNEL"

function ChatSoundsDropDown_OnShow ( self )
	UIDropDownMenu_SetSelectedID (self, 1, 0)
	UIDropDownMenu_Initialize (self, ChatSoundsDropDown_Init)
end

function ChatSoundsDropDown_Init ( self )
	local sound = {}
	local i = 1
	for name, value in pairs(ChatSounds_Sound) do
		sound[i] = name
		i = i + 1
	end

	table.sort (sound)

	local entry;
	entry = UIDropDownMenu_CreateInfo();

	entry.text    = "None"
	entry.value   = nil
	entry.func    = ChatSoundsDropDown_OnClick
	entry.checked = false
	entry.owner   = self

	UIDropDownMenu_AddButton (entry)

	for index, value in pairs(sound) do

		entry.text    = value
		entry.value   = value
		entry.func    = ChatSoundsDropDown_OnClick
		entry.checked = false
		entry.owner   = self

		UIDropDownMenu_AddButton (entry)
	end

end

function ChatSoundsDropDown_OnClick ( self )
	UIDropDownMenu_SetSelectedValue (self.owner, self.value, 0);	
	ChatSounds_PlaySound(self.value);
end

function ChatSoundsOptionsFrame_OnLoad ( self )
	self:RegisterEvent("VARIABLES_LOADED");
end

function ChatSoundsOptionsFrame_OnEvent (self, event, ...)
	local arg1 = ...;
	if (event == "VARIABLES_LOADED") then
		local that = self
		self = ChatMenu
		UIMenu_AddButton (self, "ChatSounds", nil, ChatSoundsOptionsFrame_Show)
		self = that	
	end
end

function ChatSoundsOptionsFrame_OnShow ( self )
	for i = 1, 11 do
		local incoming = getglobal ("ChatSoundsOptionsFrameGroup"..i.."Incoming")
		local outgoing = getglobal ("ChatSoundsOptionsFrameGroup"..i.."Outgoing")

		UIDropDownMenu_SetSelectedValue (incoming, ChatSounds_Config[ChatSounds_Player].Incoming[groupmap[i]], 0)
		UIDropDownMenu_SetSelectedValue (outgoing, ChatSounds_Config[ChatSounds_Player].Outgoing[groupmap[i]], 0)		
	end

	ChatSoundsOptionsFrameForceWhispersCheckBox:SetChecked (ChatSounds_Config[ChatSounds_Player].ForceWhispers)
end

function ChatSoundsOptionsFrame_OnOkay ( self )
	for i = 1, 11 do
		local incoming = getglobal ("ChatSoundsOptionsFrameGroup"..i.."Incoming")
		local outgoing = getglobal ("ChatSoundsOptionsFrameGroup"..i.."Outgoing")

		ChatSounds_Config[ChatSounds_Player].Incoming[groupmap[i]] = UIDropDownMenu_GetSelectedValue (incoming)
		ChatSounds_Config[ChatSounds_Player].Outgoing[groupmap[i]] = UIDropDownMenu_GetSelectedValue (outgoing)		
	end

	ChatSounds_Config[ChatSounds_Player].ForceWhispers = ChatSoundsOptionsFrameForceWhispersCheckBox:GetChecked ( )
end

function ChatSoundsOptionsFrame_KeyDown ( key )
	if (key == "ESCAPE") then
		PlaySound ("gsTitleOptionExit");
		ChatSoundsOptionsFrame_OnCancel ( ChatSoundsOptionsFrame );
		HideUIPanel (ChatSoundsOptionsFrame);					
	elseif (key == "PRINTSCREEN") then
		Screenshot ( );
		return; 
	end
end

function ChatSoundsOptionsFrame_OnCancel ( self )
end

function ChatSoundsOptionsFrame_OnDefaults ( self )
	for i = 1, 11 do
		local incoming = getglobal ("ChatSoundsOptionsFrameGroup"..i.."Incoming")
		local outgoing = getglobal ("ChatSoundsOptionsFrameGroup"..i.."Outgoing")

		UIDropDownMenu_SetSelectedValue (incoming, ChatSounds_Defaults.Incoming[groupmap[i]], 0)
		UIDropDownMenu_SetSelectedValue (outgoing, ChatSounds_Defaults.Outgoing[groupmap[i]], 0)	
	end

	ChatSoundsOptionsFrameForceWhispersCheckBox:SetChecked (ChatSounds_Defaults.ForceWhispers)
end

function ChatSoundsOptionsFrame_Show ( self )
	ChatSoundsOptionsFrame:Show ( )
end