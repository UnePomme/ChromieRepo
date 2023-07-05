local mod	= DBM:NewMod("Ouro", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(15517)

mod:SetModelID(15517)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 26615",
	"SPELL_CAST_START 26102 26103",
	"SPELL_CAST_SUCCESS 26058",
	"UNIT_HEALTH mouseover focus target",
	"SPELL_SUMMON 26058"
)


local warnSubmerge		= mod:NewAnnounce("WarnSubmerge", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerge		= mod:NewAnnounce("WarnEmerge", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local warnSweep			= mod:NewSpellAnnounce(26103, 2, nil, "Tank", 3)
local warnBerserk		= mod:NewSpellAnnounce(26615, 3)
local warnBerserkSoon	= mod:NewSoonAnnounce(26615, 2)

local specWarnBlast		= mod:NewSpecialWarningSpell(26102, nil, nil, nil, 2, 2)

local timerSubmerge		= mod:NewTimer(30, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6)
local timerEmerge		= mod:NewTimer(30, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)
local timerSweepCD		= mod:NewNextTimer(22, 26103, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerBlastCD		= mod:NewNextTimer(20, 26102, nil, nil, nil, 2)
local timerMounds		= mod:NewTimer(20, "Mounds", 26058)

mod.vb.prewarn_Berserk = false
mod.vb.Berserked = false

function mod:OnCombatStart(delay)
	self.vb.prewarn_Berserk = false
	self.vb.Berserked = false
	timerSweepCD:Start(22-delay)--22-25
	timerBlastCD:Start(20-delay)--20-26
	timerSubmerge:Start(90-delay)
end

function mod:Emerge()
	warnEmerge:Show()
	timerSweepCD:Start(22)
	timerBlastCD:Start(20)
	timerSubmerge:Start(90)
end

do
	local Berserk = DBM:GetSpellInfo(26615)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 26615 then
		if args.spellName == Berserk and args:IsDestTypeHostile() then
			self.vb.Berserked = true
			warnBerserk:Show()
			timerSubmerge:Stop()
			timerMounds:Start()
		end
	end
end

do
	local SandBlast, Sweep = DBM:GetSpellInfo(26102), DBM:GetSpellInfo(26103)
	function mod:SPELL_CAST_START(args)
		--if args.spellId == 26102 then
		if args.spellName == SandBlast then
			specWarnBlast:Show()
			specWarnBlast:Play("stunsoon")
			timerBlastCD:Start()
		--elseif args.spellId == 26103 then
		elseif args.spellName == Sweep and args:IsSrcTypeHostile() then
			warnSweep:Show()
			timerSweepCD:Start()
		end
	end
end

do
	local SummonOuroMounds = DBM:GetSpellInfo(26058)
	function mod:SPELL_CAST_SUCCESS(args)
		--if args.spellId == 26058 and self:AntiSpam(3) and not self.vb.Berserked then
		if args.spellName == SummonOuroMounds and not self.vb.Berserked and DBM:AntiSpam(1) then
			timerBlastCD:Stop()
			timerSweepCD:Stop()
			timerSubmerge:Stop()
			warnSubmerge:Show()
			timerEmerge:Start()
			self:ScheduleMethod(30, "Emerge")
		end
	end
	mod.SPELL_SUMMON = mod.SPELL_CAST_SUCCESS
end

function mod:UNIT_HEALTH(uId)
	if self:GetUnitCreatureId(uId) == 15517 and UnitHealthMax(uId) and UnitHealthMax(uId) > 0 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.23 and not self.vb.prewarn_Berserk then
		self.vb.prewarn_Berserk = true
		warnBerserkSoon:Show()
	end
end
