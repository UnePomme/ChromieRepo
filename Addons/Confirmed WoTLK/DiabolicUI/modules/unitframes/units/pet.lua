local Addon, Engine = ...
local Module = Engine:GetModule("UnitFrames")
local UnitFrameWidget = Module:SetWidget("Unit: Pet")

local UnitFrame = Engine:GetHandler("UnitFrame")
local StatusBar = Engine:GetHandler("StatusBar")

-- Lua API
local unpack, pairs = unpack, pairs

-- WoW API
local CreateFrame = CreateFrame

local UpdateLayers = function(self)
	if self:IsMouseOver() then
		self.BorderNormalHighlight:Show()
		self.PortraitBorderNormalHighlight:Show()
		self.BorderNormal:Hide()
		self.PortraitBorderNormal:Hide()
	else
		self.BorderNormal:Show()
		self.PortraitBorderNormal:Show()
		self.BorderNormalHighlight:Hide()
		self.PortraitBorderNormalHighlight:Hide()
	end
end

local Style = function(self, unit)
	local config = Module:GetStaticConfig("UnitFrames").visuals.units.pet
	local db = Module:GetConfig("UnitFrames") 

	
	self:Size(unpack(config.size))
	self:Place(unpack(config.position))


	-- Artwork
	-------------------------------------------------------------------
	local Backdrop = self:CreateTexture(nil, "BACKGROUND")
	Backdrop:SetSize(unpack(config.backdrop.texture_size))
	Backdrop:SetPoint(unpack(config.backdrop.texture_position))
	Backdrop:SetTexture(config.backdrop.texture)

	-- border overlay frame
	local Border = CreateFrame("Frame", nil, self)
	Border:SetFrameLevel(self:GetFrameLevel() + 3)
	Border:SetAllPoints()
	
	local BorderNormal = Border:CreateTexture(nil, "BORDER")
	BorderNormal:SetSize(unpack(config.border.texture_size))
	BorderNormal:SetPoint(unpack(config.border.texture_position))
	BorderNormal:SetTexture(config.border.textures.normal)
	
	local BorderNormalHighlight = Border:CreateTexture(nil, "BORDER")
	BorderNormalHighlight:SetSize(unpack(config.border.texture_size))
	BorderNormalHighlight:SetPoint(unpack(config.border.texture_position))
	BorderNormalHighlight:SetTexture(config.border.textures.highlight)
	BorderNormalHighlight:Hide()


	-- Health
	-------------------------------------------------------------------
	local Health = StatusBar:New(self)
	Health:SetSize(unpack(config.health.size))
	Health:SetPoint(unpack(config.health.position))
	Health:SetStatusBarTexture(config.health.texture)
	Health.frequent = 1/120

	
	-- Power
	-------------------------------------------------------------------
	local Power = StatusBar:New(self)
	Power:SetSize(unpack(config.power.size))
	Power:SetPoint(unpack(config.power.position))
	Power:SetStatusBarTexture(config.power.texture)
	Power.frequent = 1/120
	

	-- CastBar
	-------------------------------------------------------------------
	local CastBar = StatusBar:New(Health:GetScaffold())
	CastBar:Hide()
	CastBar:SetAllPoints()
	CastBar:SetStatusBarTexture(1, 1, 1, .25)
	CastBar:SetSize(Health:GetSize())
	--CastBar:SetSparkTexture(config.castbar.spark.texture)
	--CastBar:SetSparkSize(unpack(config.castbar.spark.size))
	--CastBar:SetSparkFlash(unpack(config.castbar.spark.flash))
	CastBar:DisableSmoothing(true)


	-- Portrait
	-------------------------------------------------------------------
	local PortraitHolder = CreateFrame("Frame", nil, self)
	PortraitHolder:SetSize(unpack(config.portrait.size))
	PortraitHolder:SetPoint(unpack(config.portrait.position))
	
	local PortraitBackdrop = PortraitHolder:CreateTexture(nil, "BACKGROUND")
	PortraitBackdrop:SetSize(unpack(config.portrait.texture_size))
	PortraitBackdrop:SetPoint(unpack(config.portrait.texture_position))
	PortraitBackdrop:SetTexture(config.portrait.textures.backdrop)
	
	local Portrait = CreateFrame("PlayerModel", nil, PortraitHolder)
	Portrait:SetFrameLevel(self:GetFrameLevel() + 1)
	Portrait:SetAllPoints()
	
	local PortraitBorder = CreateFrame("Frame", ni, PortraitHolder)
	PortraitBorder:SetFrameLevel(self:GetFrameLevel() + 2)
	PortraitBorder:SetAllPoints()

	local PortraitBorderNormal = PortraitBorder:CreateTexture(nil, "ARTWORK")
	PortraitBorderNormal:SetSize(unpack(config.portrait.texture_size))
	PortraitBorderNormal:SetPoint(unpack(config.portrait.texture_position))
	PortraitBorderNormal:SetTexture(config.portrait.textures.border)

	local PortraitBorderNormalHighlight = PortraitBorder:CreateTexture(nil, "ARTWORK")
	PortraitBorderNormalHighlight:SetSize(unpack(config.portrait.texture_size))
	PortraitBorderNormalHighlight:SetPoint(unpack(config.portrait.texture_position))
	PortraitBorderNormalHighlight:SetTexture(config.portrait.textures.highlight)
	PortraitBorderNormalHighlight:Hide()

	
	-- Threat
	-------------------------------------------------------------------
	local Threat = {}
	
	Threat.Border = self:CreateTexture(nil, "BACKGROUND")
	Threat.Border:Hide()
	Threat.Border:SetSize(unpack(config.border.texture_size))
	Threat.Border:SetPoint(unpack(config.border.texture_position))
	Threat.Border:SetTexture(config.border.textures.threat)

	Threat.Portrait = Portrait:CreateTexture(nil, "BACKGROUND")
	Threat.Portrait:Hide()
	Threat.Portrait:SetSize(unpack(config.portrait.texture_size))
	Threat.Portrait:SetPoint(unpack(config.portrait.texture_position))
	Threat.Portrait:SetTexture(config.portrait.textures.threat)
	
	Threat.Hide = function(self)
		self.Border:Hide()
		self.Portrait:Hide()
	end

	Threat.Show = function(self)
		self.Border:Show()
		self.Portrait:Show()
	end
	
	Threat.SetVertexColor = function(self, ...)
		self.Border:SetVertexColor(...)
		self.Portrait:SetVertexColor(...)
	end


	-- Texts
	-------------------------------------------------------------------
	local Name = Border:CreateFontString(nil, "OVERLAY")
	Name:SetFontObject(config.name.font_object)
	Name:SetPoint(unpack(config.name.position))
	Name:SetSize(unpack(config.name.size))
	Name:SetJustifyV("MIDDLE")
	Name:SetJustifyH("CENTER")
	Name:SetIndentedWordWrap(false)
	Name:SetWordWrap(true)
	Name:SetNonSpaceWrap(false)


	self.CastBar = CastBar
	self.Health = Health
	self.Name = Name
	self.Portrait = Portrait
	self.Power = Power
	self.Threat = Threat

	self.BorderNormal = BorderNormal
	self.BorderNormalHighlight = BorderNormalHighlight
	self.PortraitBorderNormal = PortraitBorderNormal
	self.PortraitBorderNormalHighlight = PortraitBorderNormalHighlight

	self:HookScript("OnEnter", UpdateLayers)
	self:HookScript("OnLeave", UpdateLayers)
	
	--self:SetAttribute("toggleForVehicle", true)

end

UnitFrameWidget.OnEnable = function(self)
	local config = self:GetStaticConfig("UnitFrames").visuals.units.player
	local db = self:GetConfig("UnitFrames") 

	self.UnitFrame = UnitFrame:New("pet", Engine:GetFrame(), Style) 
	
	-- Disable Blizzard's castbars for pet 
	self:GetHandler("BlizzardUI"):GetElement("CastBars"):Remove("pet")
end

UnitFrameWidget.GetFrame = function(self)
	return self.UnitFrame
end
