local mod	= DBM:NewMod("Ossirian", "DBM-AQ20", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(15339)

mod:SetModelID(15339)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 25176 25189 25177 25178 25180 25181 25183",
	"SPELL_AURA_REMOVED 25189",
	"SPELL_CAST_SUCCESS 25188"
)

local warnSupreme		= mod:NewSpellAnnounce(25176, 3)
local warnCyclone		= mod:NewTargetNoFilterAnnounce(25189, 4)
local warnVulnerable	= mod:NewAnnounce("WarnVulnerable", 3, "Interface\\Icons\\INV_Enchant_EssenceMagicLarge")
local warnWarStomp		= mod:NewSpellAnnounce(25188, 2, nil, false)

local timerCyclone		= mod:NewTargetTimer(10, 25189, nil, nil, nil, 3)
local timerVulnerable	= mod:NewTimer(45, "TimerVulnerable", "Interface\\Icons\\INV_Enchant_EssenceMagicLarge", nil, nil, 6)

local timerCycloneCD	= mod:NewCDTimer(20, 25189, nil, false)
local timerWarStompCD	= mod:NewCDTimer(30, 25188, nil, false)

function mod:OnCombatStart()
	timerCycloneCD:Start()
	timerWarStompCD:Start()
end


do
	local StrengthofOssirian, EnvelopingWinds, WarStomp = DBM:GetSpellInfo(25176), DBM:GetSpellInfo(25189), DBM:GetSpellInfo(25188)
	local FireWeak, FrostWeak, NatureWeak, ArcaneWeak, ShadowWeak = DBM:GetSpellInfo(25177), DBM:GetSpellInfo(25178), DBM:GetSpellInfo(25180), DBM:GetSpellInfo(25181), DBM:GetSpellInfo(25183)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 25176 then
		if args.spellName == StrengthofOssirian then
			warnSupreme:Show()
		--elseif args.spellId == 25189 then
		elseif args.spellName == EnvelopingWinds then
			warnCyclone:Show(args.destName)
			timerCyclone:Start(args.destName)
		--elseif args:IsSpellID(25177, 25178, 25180, 25181, 25183) then
		elseif args.spellName == FireWeak or args.spellName == FrostWeak or args.spellName == NatureWeak or args.spellName == ArcaneWeak or args.spellName == ShadowWeak then
			warnVulnerable:Show(args.spellName)
			timerVulnerable:Show(args.spellName)
		end
	end

	function mod:SPELL_AURA_REMOVED(args)
		--if args.spellId == 25189 then
		if args.spellName == EnvelopingWinds then
			timerCyclone:Stop(args.destName)
		end
	end
	
	function mod:SPELL_CAST_SUCCESS(args)
		if args.spellName == WarStomp then
			timerWarStompCD:Start()
		end
	end
end
