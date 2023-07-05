--[[-------------------------------------------------------------------------
--  Simple module for TomTom that creates a waypoint for your corse
--  if you happen to die.  No humor, no frills, just straightforward
--  corpse arrow.  Based on code written and adapted by Yssarill.
-------------------------------------------------------------------------]]--

local L = TomTomLocals
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:Hide()

local c,z,x,y,uid
local function GetCorpseLocation()
	-- Cache the result so we don't scan the maps multiple times
	if c and z and x and y then
		return c, z, x, y
	end

	local oc,oz = GetCurrentMapContinent(), GetCurrentMapZone()

	for i=1,select("#", GetMapContinents()) do
		SetMapZoom(i)
		local cx, cy = GetCorpseMapPosition()
		if cx ~= 0 and cy ~= 0 then
			c = i
			break
		end
	end

	-- If we found the corpse on a continent, find out which zone it is in
	if c and c ~= -1 then
		for i=1,select("#", GetMapZones(c)) do
			SetMapZoom(c, i)
			local cx,cy = GetCorpseMapPosition()
			if cx > 0 and cy > 0 then
				x = cx
				y = cy
				z = i
				break
			end
		end
	end

	-- Restore the map to its previous zoom level
	SetMapZoom(oc, oz)

	if c and z and x and y then
		return c,z,x,y
	end
end

local function SetCorpseArrow()
	if c and z and x and y and c > 0 and z > 0 and x > 0 and y > 0 then
		uid = TomTom:AddZWaypoint(c, z, x*100, y*100, L["My Corpse"], false, true, true, nil, true, true)
		return uid
	end
end

local function StartCorpseSearch()
	if not IsInInstance() then
		eventFrame:Show()
	end
end

local function ClearCorpseArrow()
	if uid then
		TomTom:RemoveWaypoint(uid)
		c,z,x,y,uid = nil, nil, nil, nil, nil
	end
end

local counter, throttle = 0, 0.5
eventFrame:SetScript("OnUpdate", function(self, elapsed)
	counter = counter + elapsed
	if counter < throttle then
		return
	else
		counter = 0
		if TomTom.profile.general.corpse_arrow then
			if GetCorpseLocation() then
				if SetCorpseArrow() then
					self:Hide()
				end
			end
		else
			self:Hide()
		end
	end
end)

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
	if event == "ADDON_LOADED" and arg1 == "TomTom" then
		self:UnregisterEvent("ADDON_LOADED")
		if UnitIsDeadOrGhost("player") then
			StartCorpseSearch()
		end
	end

	if event == "PLAYER_ALIVE" then
		if UnitIsDeadOrGhost("player") then
			StartCorpseSearch()
		else
			ClearCorpseArrow()
		end
	elseif event == "PLAYER_DEAD" then
		-- Cheat a bit and avoid the map flipping
		SetMapToCurrentZone()
		c = GetCurrentMapContinent()
		z = GetCurrentMapZone()
		if not IsInInstance() then
			x,y = GetPlayerMapPosition("player")
		end
		StartCorpseSearch()
	elseif event == "PLAYER_UNGHOST" then
		ClearCorpseArrow()
	end
end)

if IsLoggedIn() then
	eventFrame:GetScript("OnEvent")(eventFrame, "ADDON_LOADED", "TomTom")
end
