-- DKP system by Leo

-- read dkp from roster
function GearScoreDKP_GetDKP()
	local DKP_Net, DKP_Tot, DKP_Spent = 99999, 99999, 0;
	
	local tmp;
	
	-- Check if we're in a guild and can view officer notes
	if IsInGuild() and CanViewOfficerNote() then
		
		-- Update guild roster so info is read correctly
		GuildRoster();
		
		-- find your officer note
		for i = 1, GetNumGuildMembers(0) do
			local Name,_,_,_,_,_,_,OfficerNote = GetGuildRosterInfo(i);
			if Name == GS_Self then
				tmp = OfficerNote;
			end
		end
		
		-- check for valid note
		if GearScoreDKP_QDKP(tmp) then
			
			-- find main's name if on alt
			local tries = 0;
			while GearScoreDKP_IsAlt(tmp) do
				if tries == 2 then
					print("\124cffff0000You have an alt linking loop. (Your character is linked to an alt that is linked to yourself.) FIX IT!\124r");
					break;
				end
				tmp = GearScoreDKP_GetMain(tmp);
				tries = tries + 1;
			end
			
			-- get dkp net
			DKP_Net = GearScoreDKP_ParseNote(tmp, 1);
			
			-- get dkp total and spent
			DKP_Tot = GearScoreDKP_ParseNote(tmp, 2);
			DKP_Spent = DKP_Tot - DKP_Net;
		end
		
		-- display this shit
		PersonalDKP_Net:SetText("DKP: "..DKP_Net);
		PersonalDKP_Tot:SetText("Spent: "..DKP_Spent);
		
		-- move strings if too long
		if (string.len(DKP_Tot) == 5 or string.len(DKP_Net) == 5) and DKP_Tot ~= 99999 then
			PersonalDKP_Tot:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",230,-265)
			PersonalDKP_Net:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",230,-253)
		else
			PersonalDKP_Tot:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",240,-265)
			PersonalDKP_Net:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",240,-253)
		end
		
		-- color this shit
		GearScoreDKP_ColorString(DKP_Net);
		
	end
	
end

-- check that correct DKP string is in note
function GearScoreDKP_QDKP(OfficerNote)
	OfficerNote = strlower(OfficerNote);
	if OfficerNote:find("%w+:-?%d+ %w+:%d+") or OfficerNote:match("%w+") then
		return true;
	else
		return false;
	end
end

-- check if alt
function GearScoreDKP_IsAlt(OfficerNote)
	if OfficerNote:find(":") then
		return false;
	else
		return true;
	end
end

-- get alt's dkp string from main's note
function GearScoreDKP_GetMain(GS_Self)
	local tmp = "Net:99999 Tot:99999 Hrs:99999";
	
	for i = 1, GetNumGuildMembers(1) do
		local Name,_,_,_,_,_,_,OfficerNote = GetGuildRosterInfo(i);
		if Name == GS_Self then
			tmp = OfficerNote;
		end
	end
	
	return tmp;
	
	--return "Net:0 Tot:0 Hrs:0";
end

-- get Net from officer note (OFFSET1 = DKP | OFFSET2 = TOTAL)
function GearScoreDKP_ParseNote(OfficerNote, Offset)
	local DKP = {};
	
	-- extract any numbers between : and space
	for item in string.gmatch(OfficerNote, ":(-?%d+)") do
		table.insert(DKP, item);
	end
	
	return DKP[Offset];
end

-- color dkp text based on value
function GearScoreDKP_ColorString(DKP)
	DKP = tonumber(DKP); -- Probably should have done this sooner, whatever.
	
	if DKP == 0 then
		DKP = 1;
	end
	
	local modGS = 6000; -- This makes your dkp turn red at cap
	local Red, Green, Blue = GearScore_GetQuality(DKP * (modGS / GearScoreDKP_GetCap()));
	
	-- show it
	PersonalDKP_Tot:SetTextColor(Red, Green, Blue, 1);
	PersonalDKP_Net:SetTextColor(Red, Green, Blue, 1);
	
	-- We're disabling dkp if the value is incorrect.
	if DKP == 99999 then
		PersonalDKP_Tot:SetText("");
		PersonalDKP_Net:SetText("");
	end
end

function GearScoreDKP_SetCap(Max)
	local guildName, _ = GetGuildInfo("player");
	
	if IsInGuild() then
		GS_Guilds[guildName] = Max;
	end
end

function GearScoreDKP_GetCap()
	local guildName, _ = GetGuildInfo("player");
	
	if IsInGuild() then
		if GS_Guilds[guildName] == nil then
			return 0;
		else
			return GS_Guilds[guildName];
		end
	else
		return 0;
	end
end