local mod	= DBM:NewMod("Moam", "DBM-AQ20", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(15340)

mod:SetModelID(15340)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 25685",
	"SPELL_AURA_REMOVED 25685"
)

local warnEnergize		= mod:NewSpellAnnounce(25685, 3)

local timerEnergize		= mod:NewNextTimer(90, 25685, nil, nil, nil, 6)
local timerEnergizeDur	= mod:NewBuffActiveTimer(90, 25685, nil, nil, nil, 6)

function mod:OnCombatStart(delay)
	timerEnergize:Start(-delay)
end

do
	local Energize = DBM:GetSpellInfo(25685)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 25685 then
		if args.spellName == Energize and args:IsDestTypeHostile() then
			warnEnergize:Show()
			timerEnergizeDur:Start()
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args.spellId == 25685 then
		if args.spellName == Energize and args:IsDestTypeHostile() then
			timerEnergizeDur:Stop()
			timerEnergize:Start()
		end
	end
end
