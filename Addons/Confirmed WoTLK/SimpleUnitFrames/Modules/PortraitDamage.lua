--[[ ---------------------------------------------------------------------------
Name:	SimpleUnitFrames
Author:	Pneumatus
About:	An extension to the default WoW Unit Frames. Rather than a complete 
		unitframe replacement, this addon adds further information and features
		to the existing frames and allows a greater degree of customization to 
		enhance their usability.
----------------------------------------------------------------------------- ]]

local SUF = LibStub("AceAddon-3.0"):GetAddon("SimpleUnitFrames")
local PD = SUF:NewModule("PortraitDamage")

local frames = {}

PD.frameSettings = {}

function PD:OnInitialize()
	SUF.db.RegisterCallback(self, "OnProfileChanged", function() self:RefreshSettings() end)
	SUF.db.RegisterCallback(self, "OnProfileCopied", function() self:RefreshSettings() end)
	SUF.db.RegisterCallback(self, "OnProfileReset", function() self:RefreshSettings() end)
end

function PD:OnEnable()
	self:RefreshSettings()
end

function PD:OnDisable()
end

local function OnEvent(frame, event, unit, ...)
	if unit == frame.unit then
		CombatFeedback_OnCombatEvent(frame, ...)
	end
end

function PD:RefreshSettings(unit)
	if unit then
		local mappedUnit = SUF.unitMap[unit] or unit
		if SUF.db.profile[mappedUnit].portraitdamage then
			if not frames[unit] and self.frameSettings[unit] then
				frames[unit] = self:CreateDamageFrame(unit, unpack(self.frameSettings[unit]))
			end
			if frames[unit] then
				frames[unit]:RegisterEvent("UNIT_COMBAT")
				frames[unit]:SetScript("OnUpdate", CombatFeedback_OnUpdate)
			end
		elseif frames[unit] then
			frames[unit]:UnregisterAllEvents()
			frames[unit]:SetScript("OnUpdate", nil)
			frames[unit].fontString:Hide()
		end
	else
		for unit, _ in pairs(self.frameSettings) do
			self:RefreshSettings(unit)
		end
	end
end

function PD:CreateDamageFrame(unit, parent, size, points)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetFrameLevel(parent:GetFrameLevel()+3)
	frame:SetScript("OnEvent", OnEvent)
	frame.unit = unit
	
	local font = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalHuge")
	frame.fontString = font
	font:SetPoint(unpack(points))
	font:Hide()
	
	CombatFeedback_Initialize(frame, font, size)
	
	return frame
end
