local mod	= DBM:NewMod("Kurinnaxx", "DBM-AQ20", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(15348)

mod:SetModelID(15348)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CREATE 25648", -- spawn spell differently on CC
	"SPELL_AURA_APPLIED 25646 26527",
	"SPELL_AURA_APPLIED_DOSE 25646",
	"SPELL_AURA_REMOVED 25646",
	"SPELL_CAST_SUCCESS 3391",
	"SPELL_EXTRA_ATTACKS 3391"
)

local warnWound			= mod:NewStackAnnounce(25646, 2, nil, "Tank", 2)
local warnSandTrap		= mod:NewTargetNoFilterAnnounce(25656, 3)
local warnFrenzy		= mod:NewTargetNoFilterAnnounce(26527, 3)

local specWarnSandTrap	= mod:NewSpecialWarningYou(25656, nil, nil, nil, 1, 2)
local specWarnSandTrapNearby = mod:NewSpecialWarningClose(25656, nil, nil, nil, 2, 2)

local yellSandTrap		= mod:NewYell(25656)
local specWarnWound		= mod:NewSpecialWarningStack(25646, nil, 5, nil, nil, 1, 6)
local specWarnWoundTaunt= mod:NewSpecialWarningTaunt(25646, nil, nil, nil, 1, 2)

local timerWound		= mod:NewTargetTimer(15, 25646, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSandTrapCD	= mod:NewCDTimer(5, 25656, nil, nil, nil, 3)
local timerThrashCD		= mod:NewCDTimer(16, 3391, nil, nil, nil, 3)

--mod:AddSpeedClearOption("AQ20", true)

--mod.vb.firstEngageTime = nil

function mod:OnCombatStart(delay)
	timerSandTrapCD:Start(5-delay)
	timerThrashCD:Start(16-delay)
end

do
	local MortalWound, SandTrap, Frenzy, Thrash = DBM:GetSpellInfo(25646), DBM:GetSpellInfo(25648), DBM:GetSpellInfo(26527), DBM:GetSpellInfo(3391)
	function mod:SPELL_CREATE(args)
		--if args.spellId == 25648 then
		if args.spellName == SandTrap then
			timerSandTrapCD:Start()
			if args:IsPlayerSource() then
				specWarnSandTrap:Show()
				specWarnSandTrap:Play("targetyou")
				yellSandTrap:Yell()
			elseif self:CheckNearby(10, args.destName) then
				specWarnSandTrapNearby:Show(args.destName)
				specWarnSandTrapNearby:Play("watchfeet")
			else
				warnSandTrap:Show(args.sourceName)
			end
		end
	end

	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 25646 and not self:IsTrivial(80) then
		if args.spellName == MortalWound then
			local amount = args.amount or 1
			timerWound:Start(args.destName)
			if amount >= 5 then
				if args:IsPlayer() then
					specWarnWound:Show(amount)
					specWarnWound:Play("stackhigh")
				elseif not DBM:UnitDebuff("player", args.spellName) and not UnitIsDeadOrGhost("player") then
					specWarnWoundTaunt:Show(args.destName)
					specWarnWoundTaunt:Play("tauntboss")
				else
					warnWound:Show(args.destName, amount)
				end
			else
				warnWound:Show(args.destName, amount)
			end
		--elseif args.spellId == 26527 then
		elseif args.spellName == Frenzy and args:IsDestTypeHostile() then
			warnFrenzy:Show(args.destName)
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

	function mod:SPELL_AURA_REMOVED(args)
		--if args.spellId == 25646 then
		if args.spellName == MortalWound then
			timerWound:Stop(args.destName)
		end
	end
	
	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellName == Thrash then 
			timerThrashCD:Start()
		end
	end
	mod.SPELL_EXTRA_ATTACKS = mod.SPELL_CAST_SUCCESS
end
