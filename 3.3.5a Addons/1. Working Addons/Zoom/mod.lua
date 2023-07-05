local _collectgarbage = _G.collectgarbage

local garbageCount = 0
_G.collectgarbage = function()
	garbageCount = garbageCount + 1
	return 1
end

local start = GetTime()

_collectgarbage("stop")

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	_G.collectgarbage = _collectgarbage
	local usage = collectgarbage("count")
	collectgarbage("collect")
	local total = usage - collectgarbage("count")
	ChatFrame1:AddMessage(("Garbage collected: %2.2f kb, %2.0f attempts were made to collect garbage, loading took %2.2f seconds"):format(total/1024, garbageCount, GetTime() - start))
	collectgarbage("restart")
	f:SetScript("OnEvent", nil)
end)