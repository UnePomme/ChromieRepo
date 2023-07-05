local mod	= DBM:NewMod("Nefarian-Classic", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(11583)

mod:SetModelID(11380)
mod:RegisterCombat("yell", L.YellP1)--ENCOUNTER_START appears to fire when he lands, so start of phase 2, ignoring all of phase 1
mod:SetWipeTime(50)--guesswork

mod:RegisterEvents(
	"CHAT_MSG_MONSTER_YELL"
)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 22539 22686 22664 22665 22666",
	"SPELL_CAST_SUCCESS 22667",
	"SPELL_AURA_APPLIED 22687",
	"UNIT_DIED",
	"UNIT_HEALTH mouseover target",
	"PARTY_KILL"
)

local WarnAddsLeft			= mod:NewAnnounce("WarnAddsLeft", 2, "136116")
local warnClassCall			= mod:NewAnnounce("WarnClassCall", 3, "136116")
local warnPhase				= mod:NewPhaseChangeAnnounce()
local warnPhase3Soon		= mod:NewPrePhaseAnnounce(3)
local warnShadowFlame		= mod:NewCastAnnounce(22539, 2)
local warnFear				= mod:NewCastAnnounce(22686, 2)
local warnSBVolley			= mod:NewCastAnnounce(22665, 2)

local specwarnShadowCommand	= mod:NewSpecialWarningTarget(22667, nil, nil, 2, 1, 2)
local specwarnVeilShadow	= mod:NewSpecialWarningDispel(22687, "RemoveCurse", nil, nil, 1, 2)
local specwarnClassCall		= mod:NewSpecialWarning("specwarnClassCall", nil, nil, nil, 1, 2)

local timerPhase			= mod:NewPhaseTimer(15)
local timerShadowFlameCD	= mod:NewCDTimer(12, 22539, nil, nil)
local timerClassCall		= mod:NewTimer(30, "TimerClassCall", "136116", nil, nil, 5)

local timerFearNext			= mod:NewCDTimer(25, 22686, nil, nil, 3, 2)--26-42.5
local timerAddsSpawn		= mod:NewTimer(10, "TimerAddsSpawn", 19879, nil, nil, 1)
local timerMindControlCD	= mod:NewCDTimer(24, 22667, nil, nil, nil, 6, nil, nil, true)
local timerSBVolleyCD		= mod:NewCDTimer(19, 22665, nil, nil)

mod.vb.addLeft = 42
local addsGuidCheck = {}
local firstBossMod = DBM:GetModByName("Razorgore")

function mod:OnCombatStart(delay, yellTriggered)
	table.wipe(addsGuidCheck)
	self.vb.addLeft = 42
	self:SetStage(1)
	timerAddsSpawn:Start(15-delay)
	timerMindControlCD:Start(30-delay)
	timerSBVolleyCD:Start(13-delay)
end

do
	local ShadowFlame, BellowingRoar, SBVolley = DBM:GetSpellInfo(22539), DBM:GetSpellInfo(22686), DBM:GetSpellInfo(22665)
	function mod:SPELL_CAST_START(args)
		--if args.spellId == 22539 then
		if args.spellName == ShadowFlame then
			warnShadowFlame:Show()
			timerShadowFlameCD:Start()
		--elseif args.spellId == 22686 then
		elseif args.spellName == BellowingRoar then
			warnFear:Show()
			timerFearNext:Start()
		elseif args.spellName == SBVolley then
			warnSBVolley:Show()
			timerSBVolleyCD:Start(19)
		end
	end
end

do
	local VeilShadow, ShadowCommand = DBM:GetSpellInfo(22687), DBM:GetSpellInfo(22667)
	function mod:SPELL_AURA_APPLIED(args)
		if args.spellName == VeilShadow then
			if self:CheckDispelFilter("curse") then
				specwarnVeilShadow:Show(args.destName)
				specwarnVeilShadow:Play("dispelnow")
				timerMindControlCD:Stop() -- in case phase p2 wasnt recognized properly
			end
		end
	end
	
	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellName == ShadowCommand then
			specwarnShadowCommand:Show(args.destName)
			specwarnShadowCommand:Play("findmc")
			timerMindControlCD:Start(24)
		end
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.25 and self:GetUnitCreatureId(uId) == 11583 and self.vb.phase < 2.5 then
		warnPhase3Soon:Show()
		self:SetStage(2.5)
	end
end

do
	local playerName = UnitName("player")
	local function blizzardAreAssholes(self, msg, arg, sender)
		if sender and self:AntiSpam(5, msg) then
			--Do nothing, this is just an antispam threshold for syncing
		end
		if msg == "Phase" and sender then
			local phase = tonumber(arg) or 0
			if phase == 2 and self.vb.phase < 2 then
				self:SetStage(2)
				timerSBVolleyCD:Stop()
				timerMindControlCD:Stop()
				timerPhase:Start(15) -- phase start are estimates, will have to correct when raiding bwl again.
				timerShadowFlameCD:Start(15+12)
				timerFearNext:Start(15+25)
				timerClassCall:Start(15+30)
			elseif phase == 3 then
				self:SetStage(3)
			end
			warnPhase:Show(DBM_CORE_L.AUTO_ANNOUNCE_TEXTS.stage:format(arg))
		end
		if not self:IsInCombat() then return end
		if msg == "ClassCall" and sender then
			local className = LOCALIZED_CLASS_NAMES_MALE[arg]
			if UnitClass("player") == className then
				specwarnClassCall:Show()
				specwarnClassCall:Play("targetyou")
			else
				warnClassCall:Show(className)
			end
			timerClassCall:Start(30, className)
		end
	end

	function mod:PARTY_KILL(args)
		local guid = args.destGUID
		local cid = self:GetCIDFromGUID(guid)
		if cid == 14264 or cid == 14263 or cid == 14261 or cid == 14265 or cid == 14262 or cid == 14302 then--Red, Bronze, Blue, Black, Green, Chromatic
			if not addsGuidCheck[guid] then
				addsGuidCheck[guid] = true
				self.vb.addLeft = self.vb.addLeft - 1
				--40, 35, 30, 25, 20, 15, 12, 9, 6, 3, 2, 1
				if (self.vb.addLeft >= 15 and (self.vb.addLeft % 5 == 0)) or (self.vb.addLeft >= 1 and (self.vb.addLeft % 3 == 0) and self.vb.addLeft < 15) or (self.vb.addLeft == 2) or (self.vb.addLeft == 1) then
					WarnAddsLeft:Show(self.vb.addLeft)
				end
			end
		end
	end
	
	function mod:CHAT_MSG_MONSTER_YELL(msg)
		if msg == L.YellDK or msg:find(L.YellDK) then--This mod will likely persist all the way til Classic WoTLK, don't remove DK
			self:SendSync("ClassCall", "DEATHKNIGHT")
			blizzardAreAssholes(self, "ClassCall", "DEATHKNIGHT", playerName)
		elseif (msg == L.YellDruid or msg:find(L.YellDruid)) and self:AntiSpam(5, "ClassCall") then
			self:SendSync("ClassCall", "DRUID")
			blizzardAreAssholes(self, "ClassCall", "DRUID", playerName)
		elseif (msg == L.YellHunter or msg:find(L.YellHunter)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "HUNTER")
			blizzardAreAssholes(self, "ClassCall", "HUNTER", playerName)
		elseif (msg == L.YellWarlock or msg:find(L.YellWarlock)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "WARLOCK")
			blizzardAreAssholes(self, "ClassCall", "WARLOCK", playerName)
		elseif (msg == L.YellMage or msg:find(L.YellMage)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "MAGE")
			blizzardAreAssholes(self, "ClassCall", "MAGE", playerName)
		elseif (msg == L.YellPaladin or msg:find(L.YellPaladin)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "PALADIN")
			blizzardAreAssholes(self, "ClassCall", "PALADIN", playerName)
		elseif (msg == L.YellPriest or msg:find(L.YellPriest)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "PRIEST")
			blizzardAreAssholes(self, "ClassCall", "PRIEST", playerName)
		elseif (msg == L.YellRogue or msg:find(L.YellRogue)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "ROGUE")
			blizzardAreAssholes(self, "ClassCall", "ROGUE", playerName)
		elseif (msg == L.YellShaman or msg:find(L.YellShaman)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "SHAMAN")
			blizzardAreAssholes(self, "ClassCall", "SHAMAN", playerName)
		elseif (msg == L.YellWarrior or msg:find(L.YellWarrior)) and self:AntiSpam(5, "ClassCall")  then
			self:SendSync("ClassCall", "WARRIOR")
			blizzardAreAssholes(self, "ClassCall", "WARRIOR", playerName)
		elseif (msg == L.YellP2 or msg:find(L.YellP2)) and self:AntiSpam(5, "Phase") then
			self:SendSync("Phase", 2)
			blizzardAreAssholes(self, "Phase", "2", playerName)
		elseif (msg == L.YellP2CC or msg:find(L.YellP2CC)) and self:AntiSpam(5, "Phase") then
			self:SendSync("Phase", 2)
			blizzardAreAssholes(self, "Phase", "2", playerName)
		elseif (msg == L.YellP2CC2 or msg:find(L.YellP2CC2)) and self:AntiSpam(5, "Phase") then
			self:SendSync("Phase", 2)
			blizzardAreAssholes(self, "Phase", "2", playerName)
		elseif (msg == L.YellP3 or msg:find(L.YellP3)) and self:AntiSpam(5, "Phase") then
			self:SendSync("Phase", 3)
			blizzardAreAssholes(self, "Phase", "3", playerName)
		end
	end

	function mod:OnSync(msg, arg, sender)
		blizzardAreAssholes(self, msg, arg, sender)
	end
end

function mod:OnCombatEnd()
	timerSBVolleyCD:Stop()
	timerMindControlCD:Stop()
	timerClassCall:Stop()
end
