local mod	= DBM:NewMod("Shazzrah", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(12264)

mod:SetModelID(13032)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 19714",
	"SPELL_AURA_REMOVED 19714",
	"SPELL_CAST_SUCCESS 19713 19715 23138"
)

local warnCurse				= mod:NewSpellAnnounce(19713, 4)
local warnDeadenMagic		= mod:NewTargetNoFilterAnnounce(19714, 2, nil, false, 2)
local warnCntrSpell			= mod:NewSpellAnnounce(19715, 3, nil, "SpellCaster", 2)

local specWarnDeadenMagic	= mod:NewSpecialWarningDispel(19714, false, nil, 2, 1, 2)
local specWarnGate			= mod:NewSpecialWarningTaunt(23138, "Tank", nil, nil, 1, 2)

local timerCurseCD			= mod:NewCDTimer(23, 19713, nil, nil, nil, 3, nil, DBM_COMMON_L.CURSE_ICON)
local timerDeadenMagic		= mod:NewBuffActiveTimer(30, 19714, nil, false, 3, 5, nil, DBM_COMMON_L.MAGIC_ICON)
local timerGateCD			= mod:NewCDTimer(45, 23138, nil, "Tank", 2, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerCounterSpellCD	= mod:NewCDTimer(15, 19715, nil, "SpellCaster", nil, 3)

function mod:OnCombatStart(delay)
	timerCurseCD:Start(9-delay)
	timerCounterSpellCD:Start(9.5-delay)
	timerGateCD:Start(30-delay)
end
do
	local magicDeadenMagic = DBM:GetSpellInfo(19714)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 19714 and not args:IsDestTypePlayer() then
		if args.spellName == magicDeadenMagic and args:IsDestTypeHostile() then
			if self.Options.SpecWarn19714dispel then
				specWarnDeadenMagic:Show(args.destName)
				specWarnDeadenMagic:Play("dispelboss")
			else
				warnDeadenMagic:Show(args.destName)
			end
			timerDeadenMagic:Start()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args.spellId == 19714 then
		if args.spellName == magicDeadenMagic then
			timerDeadenMagic:Stop()
		end
	end
end

do
	local Curse, Counterspell, Gate = DBM:GetSpellInfo(19713), DBM:GetSpellInfo(19715), DBM:GetSpellInfo(23138)
	function mod:SPELL_CAST_SUCCESS(args)
		local spellName = args.spellName
		--if args.spellId == 19713 then
		if spellName == Curse then
			warnCurse:Show()
			timerCurseCD:Start()
		--elseif args.spellId == 19715 then
		elseif spellName == Counterspell and args:IsSrcTypeHostile() then
			warnCntrSpell:Show()
			timerCounterSpellCD:Start()
		--elseif args.spellId == 23138 then
		elseif spellName == Gate then
			specWarnGate:Show(args.sourceName)
			specWarnGate:Play("tauntboss")
			timerGateCD:Start()
		end
	end
end
