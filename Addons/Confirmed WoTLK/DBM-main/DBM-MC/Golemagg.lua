local mod	= DBM:NewMod("Golemagg", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(11988)--, 11672

mod:SetModelID(11986)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 20553 19798",
	"SPELL_AURA_APPLIED 13880",
	"SPELL_AURA_APPLIED_DOSE 13880"
)

--[[
ability.id = 19798 and type = "cast"
 or ability.id = 13880 and not type = "damage"
--]]
local warnQuake					= mod:NewSpellAnnounce(19798)--Not worth a timer, 14-42 variation
local warnMagmaSplash			= mod:NewStackAnnounce(13880, 2, nil, "Tank|Healer")

local specWarnMagmaSplash		= mod:NewSpecialWarningStack(13880, nil, 3, nil, nil, 1, 6)
local specWarnMagmaSplashTaunt	= mod:NewSpecialWarningTaunt(13880, nil, nil, nil, 1, 2)

do
	local Quake = DBM:GetSpellInfo(19798)
	function mod:SPELL_CAST_SUCCESS(args)
		--if args.spellId == 19798 then
		if args.spellName == Quake then
			warnQuake:Show()
		end
	end
end

do
	local MagmaSplash = DBM:GetSpellInfo(13880)
	function mod:SPELL_AURA_APPLIED(args)
		--if args.spellId == 13880 then
		if args.spellName == MagmaSplash then
			local uId = DBM:GetRaidUnitId(args.destName)
			if self:IsTanking(uId) then--Filter by tanks since it's a frontal cleave attack (meaning idiots in wrong place can get hit too)
				local amount = args.amount or 1
				if amount >= 3 then
					if args:IsPlayer() then
						specWarnMagmaSplash:Show(amount)
						specWarnMagmaSplash:Play("stackhigh")
					else
						if not DBM:UnitDebuff("player", 13880) and not UnitIsDeadOrGhost("player") then
							specWarnMagmaSplashTaunt:Show(args.destName)
							specWarnMagmaSplashTaunt:Play("tauntboss")
						else
							warnMagmaSplash:Show(args.destName, amount)
						end
					end
				else
					warnMagmaSplash:Show(args.destName, amount)
				end
			end
		end
	end
	mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED
end
