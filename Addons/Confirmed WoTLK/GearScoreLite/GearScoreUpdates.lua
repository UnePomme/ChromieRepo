-- Updater by Leo

-- Using a simple boolean to prevent spam
GS_VerCheck = true;

-- Handle OnEvent
function GearScoreUpdates_OnEvent(Nil, Event, Prefix, Message, Type, Sender)
	-- Let's not spam ourself with shit.
	if Sender == GS_Self then
		return;
	end
	
	-- Parse addon messages for updates
	if Event == "CHAT_MSG_ADDON" then
		
		-- Validate the message being read to avoid time wasted
		if (Prefix == "GS_Version_Broadcast") and (Message:match("%d+%.%d+") or Message:match("%?")) then
			
			-- Handle version request from broadcast
			if ((Type == "RAID") or (Type == "GUILD")) and (Message == "?") then
				GSU_BroadCast("RESPONSE", Sender);
				return;
			end
			
			-- If version response was higher than our own, show notification
			-- Also disable version checks until next zone change to prevent spam
			if (tonumber(Message) > GS_Version) and (Type == "WHISPER") then
				
				-- Don't continue if version checks are disabled
				if not GS_VerCheck then
					return;
				end
				
				print("Your version of GearScoreLite is outdated.");
				print("You're running v"..GS_Version.." and v"..Message.." was found.");
				print(GS_UpdateMsg);
				
				GS_VerCheck = false;
				
				return;
			end
		end
	end
	
	-- Request addon versions on entering any raid instance
	if Event == "RAID_INSTANCE_WELCOME" then
		GSU_BroadCast("REQUEST", "RAID");
		GSU_BroadCast("REQUEST", "GUILD");
	end
	
	-- Enable version checks when entering a new map
	if Event == "WORLD_MAP_UPDATE" then
		GS_VerCheck = true;
	end
	
	-- Send an update request on login
	if (Event == "ADDON_LOADED") and (Prefix == "GearScoreLite") then
		GSU_BroadCast("REQUEST", "RAID");
		GSU_BroadCast("REQUEST", "GUILD");
	end
	
end

function GSU_BroadCast(Type, Channel)
	if Type == "REQUEST" then
		if Channel == "GUILD" then
			if IsInGuild() then
				SendAddonMessage("GS_Version_Broadcast", "?", Channel);
			end
		end
		if Channel == "RAID" then
			if GetNumRaidMembers() > 0 then
				SendAddonMessage("GS_Version_Broadcast", "?", Channel);
			end
		end
	end
	
	if Type == "RESPONSE" then
		SendAddonMessage("GS_Version_Broadcast", GS_Version, "WHISPER", Channel);
	end
end

local u = CreateFrame("Frame", "GearScoreTips", UIParent);
u:SetScript("OnEvent", GearScoreUpdates_OnEvent);
u:RegisterEvent("RAID_INSTANCE_WELCOME");
u:RegisterEvent("CHAT_MSG_ADDON");
u:RegisterEvent("WORLD_MAP_UPDATE");
u:RegisterEvent("ADDON_LOADED");