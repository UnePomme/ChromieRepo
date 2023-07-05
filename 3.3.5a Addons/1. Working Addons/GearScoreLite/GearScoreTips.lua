-- Tooltip system by Leo

GS_ToolTips = {
	-- ["Name"] = { ["Realm"] = "Ragnaros x20", ["Tip"] = "Some tooltip", ["Expiration"] = 0 },
}

GS_DefaultMyTip = {};

function GearScoreTips_PlayerKey()
	return GS_Self.."-"..GS_Realm;
end

-- SendAddonMessage to player as whisper
function GearScoreToolTip_Request(Name)
	-- lvl19 check
	if UnitLevel("player") >= 19 then
		GearScoreToolTip_Set(Name, nil);
		
		SendAddonMessage("GS_ToolTips_Request", "x", "WHISPER", Name);
	end
end

-- SendAddonMessage to player with tip to be shown
function GearScoreToolTip_Reply(Name, Tip)
	SendAddonMessage("GS_ToolTips_Reply", Tip, "WHISPER", Name);
end

-- SendAddonMessage to RAID/PARTY/GUILD/BATTLEGROUND with tip to be shown
function GearScoreToolTip_Broadcast(Tip)
	SendAddonMessage("GS_ToolTips_Reply", Tip, "RAID");
	SendAddonMessage("GS_ToolTips_Reply", Tip, "PARTY");
	SendAddonMessage("GS_ToolTips_Reply", Tip, "GUILD");
	SendAddonMessage("GS_ToolTips_Reply", Tip, "BATTLEGROUND");
end

-- Add to GS_ToolTips table
function GearScoreToolTip_Set(Name, Tip)
	GS_ToolTips[Name] = {
		["Realm"] = GS_Realm,
		["Tip"] = Tip,
		["Expiration"] = time() + 60
	};
end

-- Check if name is already in table
function GearScoreToolTip_Exists(Name)
	if GS_ToolTips[Name] and (GS_ToolTips[Name].Realm == GS_Realm) then
		
		-- Also check if the Tip is == nil
		-- This happens when a request has been sent but not received
		if GS_ToolTips[Name].Tip ~= nil then
			
			-- Request new tip if expired
			if GS_ToolTips[Name].Expiration <= time() then
				GearScoreToolTip_Request(Name);
			end
			
			return true;
		end
		
	end
	
	return false;
end

-- Handle OnEvent
function GearScoreToolTip_OnEvent(Nil, Event, Prefix, Message, Type, Sender)
	-- Don't spam self with shit.
	if Sender == GS_Self then
		return;
	end
	
	-- Read tooltip updates
	if Event == "CHAT_MSG_ADDON" then
		
		-- Handle tooltip requests
		if Prefix == "GS_ToolTips_Request" then
			GearScoreToolTip_Reply(Sender, GS_MyTip[GearScoreTips_PlayerKey()]);
		end
		
		-- Handle tooltip reply
		if Prefix == "GS_ToolTips_Reply" then
			GearScoreToolTip_Set(Sender, Message);
		end
		
	end
	
	-- Clear GS_ToolTips table on exit
	if Event == "PLAYER_LEAVING_WORLD" then
		GS_ToolTips = {};
	end
end

local t = CreateFrame("Frame", "GearScoreTips", UIParent);
t:SetScript("OnEvent", GearScoreToolTip_OnEvent);
t:RegisterEvent("CHAT_MSG_ADDON");
t:RegisterEvent("PLAYER_LEAVING_WORLD");
