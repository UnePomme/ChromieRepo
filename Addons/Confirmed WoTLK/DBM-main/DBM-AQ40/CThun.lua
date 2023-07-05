local mod	= DBM:NewMod("CThun", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(15589, 15727)

mod:SetUsedIcons(1)

mod:RegisterCombat("combat")
mod:SetWipeTime(25)

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 26134",
--	"SPELL_CAST_SUCCESS 26586",
	"SPELL_CAST_SUCCESS 26478 26139",
	"SPELL_AURA_APPLIED 26476",
	"SPELL_AURA_APPLIED_DOSE 26476",
	"SPELL_AURA_REMOVED 26476",
	"CHAT_MSG_MONSTER_EMOTE",
	"UNIT_DIED"
)

local warnEyeTentacle			= mod:NewAnnounce("WarnEyeTentacle", 2, 126)
local warnClawTentacle			= mod:NewAnnounce("WarnClawTentacle2", 2, 26391, false)
local warnGiantEyeTentacle		= mod:NewAnnounce("WarnGiantEyeTentacle", 3, 126)
local warnGiantClawTentacle		= mod:NewAnnounce("WarnGiantClawTentacle", 3, 26391)
local warnPhase2				= mod:NewPhaseAnnounce(2)

local specWarnDarkGlare			= mod:NewSpecialWarningDodge(26029, nil, nil, nil, 3, 2)
local specWarnWeakened			= mod:NewSpecialWarning("SpecWarnWeakened", nil, nil, nil, 2, 2, nil, 28598)
local specWarnEyeBeam			= mod:NewSpecialWarningYou(26134, nil, nil, nil, 1, 2)
local yellEyeBeam				= mod:NewYell(26134)

local timerDarkGlareCD			= mod:NewNextTimer(39 + 46, 26029)
local timerDarkGlare			= mod:NewBuffActiveTimer(39, 26029)
local timerEyeTentacle			= mod:NewTimer(45, "TimerEyeTentacle", 126, nil, nil, 1)
local timerGiantEyeTentacle		= mod:NewTimer(60, "TimerGiantEyeTentacle", 126, nil, nil, 1)
local timerClawTentacle			= mod:NewTimer(8, "TimerClawTentacle", 26391, nil, nil, 1) -- every 8 seconds
local timerGiantClawTentacle	= mod:NewTimer(60, "TimerGiantClawTentacle", 26391, nil, nil, 1)
local timerWeakened				= mod:NewTimer(45, "TimerWeakened", 28598)

mod:AddRangeFrameOption("12") -- Blizz 10, AzerothCore +2 for regular chars, or 4 for male tauren/draenei
mod:AddSetIconOption("SetIconOnEyeBeam", 26134, true, false, {1})
mod:AddInfoFrameOption(nil, true)

local firstBossMod = DBM:GetModByName("AQ40Trash")
local playersInStomach = {}
local fleshTentacles, diedTentacles = {}, {}

local updateInfoFrame
do
	local twipe, tsort = table.wipe, table.sort
	local lines = {}
	local sortedLines = {}
	local function addLine(key, value)
		-- sort by insertion order
		lines[key] = value
		sortedLines[#sortedLines + 1] = key
	end
	updateInfoFrame = function()
		twipe(lines)
		twipe(sortedLines)
		--First, process players in stomach and gather tentacle information and debuff stacks
		for i = 1, #playersInStomach do
			local name = playersInStomach[i]
			local uId = DBM:GetRaidUnitId(name)
			if uId then
				--First, display their stomach debuff stacks
				local spellName, _, _, count = DBM:UnitDebuff(uId, 26476)
				if spellName and count then
					addLine(name, count)
				end
				--Also, process their target information for tentacles
				local targetuId = uId.."target"
				local guid = UnitGUID(targetuId)
				if guid and (mod:GetCIDFromGUID(guid) == 15802) and not diedTentacles[guid] then--Targetting Flesh Tentacle
					fleshTentacles[guid] = math.floor(UnitHealth(targetuId) / UnitHealthMax(targetuId) * 100)
				end
			end
		end
		--Now, show tentacle data after it's been updated from player processing
		local nLines = 0
		for _, health in pairs(fleshTentacles) do
			nLines = nLines + 1
			addLine(L.FleshTent .. " " .. nLines, health .. '%')
		end
		return lines, sortedLines
	end
end

function mod:OnCombatStart(delay)
	table.wipe(playersInStomach)
	table.wipe(fleshTentacles)
	table.wipe(diedTentacles)
	self:SetStage(1)
	self.vb.phase = 1
	timerClawTentacle:Start(8-delay)
	timerEyeTentacle:Start(45-delay)
	timerDarkGlareCD:Start(46-delay)
	self:ScheduleMethod(46-delay, "DarkGlare")
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10+2) -- Blizz 10, AzerothCore +2 for regular chars, or 4 for male tauren/draenei
	end
end

function mod:OnCombatEnd(wipe, isSecondRun)
	table.wipe(diedTentacles)
	timerEyeTentacle:Stop()
	timerGiantClawTentacle:Stop()
	timerGiantEyeTentacle:Stop()
	timerWeakened:Stop()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if self.Options.InfoFrame then
		DBM.InfoFrame:Hide()
	end
	--Only run on second run, to ensure trash mod has had enough time to update requiredBosses
	if not wipe and isSecondRun and firstBossMod.vb.firstEngageTime and firstBossMod.Options.SpeedClearTimer then
		if firstBossMod.vb.requiredBosses < 5 then
			DBM:AddMsg(L.NotValid:format(5 - firstBossMod.vb.requiredBosses .. "/4"))
		end
	end
end

function mod:DarkGlare()
	--ghost check, because if someone releases during encounter, this loop continues until they zone back in
	--We don't want to spam dark glare warnings while they are a ghost outside running back on a wipe
	if not UnitIsDeadOrGhost("player") then
		specWarnDarkGlare:Show()
		specWarnDarkGlare:Play("laserrun")--Or "watchstep" ?
	end
	timerDarkGlare:Start()
	timerDarkGlareCD:Start()
	self:ScheduleMethod(39 + 46, "DarkGlare")
	timerEyeTentacle:Start(39 + 45)
end

do
	local EyeBeam = DBM:GetSpellInfo(26134)
	function mod:EyeBeamTarget(targetname, uId)
		if not targetname then return end
		if self.Options.SetIconOnEyeBeam then
			self:SetIcon(targetname, 1, 3)
		end
		if targetname == UnitName("player") then
			specWarnEyeBeam:Show()
			specWarnEyeBeam:Play("targetyou")
			yellEyeBeam:Yell()
		end
	end

	function mod:SPELL_CAST_START(args)
		local spellName = args.spellName
		if spellName == EyeBeam and args:IsSrcTypeHostile() then
			-- the eye target can change to the correct target a tiny bit after the cast starts
			self:ScheduleMethod(0.1, "BossTargetScanner", args.sourceGUID, "EyeBeamTarget", 0.1, 3)
		end
	end
end

--do
--	local Birth = DBM:GetSpellInfo(26586)
--	function mod:SPELL_CAST_SUCCESS(args)
--		local spellName = args.spellName
--		if spellName == Birth then
--			 local cid = self:GetCIDFromGUID(args.sourceGUID)
--			 if self:AntiSpam(5, cid) then--Throttle multiple spawn within 5 seconds
--				if cid == 15726 then--Eye Tentacle
--					timerEyeTentacle:Stop()
--					warnEyeTentacle:Show()
--					timerEyeTentacle:Start(self.vb.phase == 2 and 30 or 45)
--				elseif cid == 15725 then -- Claw Tentacle
--					timerClawTentacle:Stop()
--					warnClawTentacle:Show()
--					timerClawTentacle:Start()
--				elseif cid == 15334 then -- Giant Eye Tentacle
--					timerGiantEyeTentacle:Stop()
--					warnGiantEyeTentacle:Show()
--					timerGiantEyeTentacle:Start()
--				elseif cid == 15728 then -- Giant Claw Tentacle
--					timerGiantClawTentacle:Stop()
--					warnGiantClawTentacle:Show()
--					timerGiantClawTentacle:Start()
--				end
--			end
--		end
--	end
--end

do
	function mod:SPELL_CAST_SUCCESS(args)
		local cid = self:GetCIDFromGUID(args.sourceGUID)
		if self:AntiSpam(5, cid) and self.vb.phase == 2 then
			if args:IsSpellID(26478) and cid == 15728 then --Giant Claw Tentacle
				warnGiantClawTentacle:Show()
				timerGiantClawTentacle:Restart(59.5)
			elseif args:IsSpellID(26478) and cid == 15334 then -- Giant Eye Tentacle
				warnGiantEyeTentacle:Show()
				timerGiantEyeTentacle:Restart(59.5)
			elseif args:IsSpellID(26139) and cid == 15726 then--Eye Tentacle
				warnEyeTentacle:Show()
				timerEyeTentacle:Restart(29.5)
			end
		end
	end
end
	
do
	local DigestiveAcid = DBM:GetSpellInfo(26476)
	function mod:SPELL_AURA_APPLIED(args)
		if args.spellName == DigestiveAcid then
			--I'm aware debuff stacks, but it's a context that doesn't matter to this mod
			if not tContains(playersInStomach, args.destName) then
				table.insert(playersInStomach, args.destName)
			end
			if self.Options.InfoFrame and not DBM.InfoFrame:IsShown() then
				DBM.InfoFrame:SetHeader(L.Stomach)
				DBM.InfoFrame:Show(42, "function", updateInfoFrame, false, false)
				DBM.InfoFrame:SetColumns(1)
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:SPELL_AURA_REMOVED(args)
		if args.spellName == DigestiveAcid then
			tDeleteItem(playersInStomach, args.destName)
		end
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L.Weakened or msg:find(L.Weakened) then
		self:SendSync("Weakened")
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 15589 then -- Eye of C'Thun
		self:SetStage(2)
		self.vb.phase = 2
		warnPhase2:Show()
		timerDarkGlare:Stop()
		timerDarkGlareCD:Stop()
		timerEyeTentacle:Stop()
		timerClawTentacle:Stop() -- Claw Tentacle never respawns in phase2
		timerEyeTentacle:Start(33) -- 40.5
		timerGiantClawTentacle:Start(11)
		timerGiantEyeTentacle:Start(41)
		self:UnscheduleMethod("DarkGlare")
		if self.Options.InfoFrame and not DBM.InfoFrame:IsShown() then
			DBM.InfoFrame:SetHeader(L.Stomach)
			DBM.InfoFrame:Show(42, "function", updateInfoFrame, false, false)
			DBM.InfoFrame:SetColumns(1)
		end
	elseif cid == 15802 then -- Flesh Tentacle
		fleshTentacles[args.destGUID] = nil
		diedTentacles[args.destGUID] = true
	end
end

function mod:OnSync(msg)
	if not self:IsInCombat() then return end
	if msg == "Weakened" then
		table.wipe(fleshTentacles)
		specWarnWeakened:Show()
		specWarnWeakened:Play("targetchange")
		timerWeakened:Start()
		timerEyeTentacle:Restart(75)
		timerGiantClawTentacle:Restart(53)
		timerGiantEyeTentacle:Restart(83)
		if self.Options.InfoFrame then
			DBM.InfoFrame:Hide()
		end
	end
end
