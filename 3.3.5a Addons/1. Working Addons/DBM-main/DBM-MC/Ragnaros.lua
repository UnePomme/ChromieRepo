local mod	= DBM:NewMod("Ragnaros-Classic", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20220518110528")
mod:SetCreatureID(11502)

mod:SetModelID(11121)

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START 19774",
	"SPELL_CAST_SUCCESS 20566",
	"CHAT_MSG_MONSTER_YELL",
	"SPELL_INSTAKILL 19773"
)

mod:RegisterEventsInCombat(
	"UNIT_DIED"
)

local warnWrathRag		= mod:NewSpellAnnounce(20566, 3)
local warnSubmerge		= mod:NewAnnounce("WarnSubmerge", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerge		= mod:NewAnnounce("WarnEmerge", 2, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")

local timerWrathRag		= mod:NewCDTimer(25, 20566, nil, nil, nil, 2, nil, DBM_COMMON_L.IMPORTANT_ICON, nil, mod:IsMelee() and 1, 4)--25-31.6
local timerSubmerge		= mod:NewTimer(180, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, 6, nil, nil, 1, 5)
local timerEmerge		= mod:NewTimer(90, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6, nil, nil, 1, 5)
local timerCombatStart	= mod:NewTimer(80, "timerCombatStart", "Interface\\Icons\\Ability_Warrior_OffensiveStance", nil, nil, 6, nil, nil) -- 72.5

mod:AddRangeFrameOption("20") -- Blizz 18, AzerothCore +2 for regular chars, or 4 for male tauren/draenei

mod.vb.addLeft = 0
mod.vb.ragnarosEmerged = true
local addsGuidCheck = {}
local firstBossMod = DBM:GetModByName("MCTrash")

function mod:OnCombatStart(delay)
	table.wipe(addsGuidCheck)
	self.vb.addLeft = 0
	self.vb.ragnarosEmerged = true
	timerWrathRag:Start(30-delay)
	timerSubmerge:Start(180-delay)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(18+2) -- Blizz 10, AzerothCore +2 for regular chars, or 4 for male tauren/draenei
	end
end

function mod:OnCombatEnd(wipe)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	if not wipe then
		DBT:CancelBar(DBM_CORE_L.SPEED_CLEAR_TIMER_TEXT)
		if firstBossMod.vb.firstEngageTime then
			local thisTime = time() - firstBossMod.vb.firstEngageTime
			if thisTime and thisTime > 0 then
				if not firstBossMod.Options.FastestClear2 then
					--First clear, just show current clear time
					DBM:AddMsg(DBM_CORE_L.RAID_DOWN:format("MC", DBM:strFromTime(thisTime)))
					firstBossMod.Options.FastestClear2 = thisTime
				elseif (firstBossMod.Options.FastestClear2 > thisTime) then
					--Update record time if this clear shorter than current saved record time and show users new time, compared to old time
					DBM:AddMsg(DBM_CORE_L.RAID_DOWN_NR:format("MC", DBM:strFromTime(thisTime), DBM:strFromTime(firstBossMod.Options.FastestClear2)))
					firstBossMod.Options.FastestClear2 = thisTime
				else
					--Just show this clear time, and current record time (that you did NOT beat)
					DBM:AddMsg(DBM_CORE_L.RAID_DOWN_L:format("MC", DBM:strFromTime(thisTime), DBM:strFromTime(firstBossMod.Options.FastestClear2)))
				end
			end
			firstBossMod.vb.firstEngageTime = nil
		end
	end
end

local function emerged(self)
	self.vb.ragnarosEmerged = true
	timerEmerge:Stop()
	warnEmerge:Show()
	timerWrathRag:Start(30)
	timerSubmerge:Start(180)
end

do
	local summonRag = DBM:GetSpellInfo(19774)
	function mod:SPELL_CAST_START(args)
		--if args.spellId == 20566 then
		if args.spellName == summonRag and self:AntiSpam(5, 4) then
			--This is still going to use a sync event because someone might start this RP from REALLY REALLY far away
			self:SendSync("SummonRag")
		end
	end
end

do
	local Wrath, domoDeath = DBM:GetSpellInfo(20566), DBM:GetSpellInfo(19773)
	function mod:SPELL_CAST_SUCCESS(args)
		--if args.spellId == 20566 then
		if args.spellName == Wrath then
			warnWrathRag:Show()
			timerWrathRag:Start()
		end
	end
	
	function mod:SPELL_INSTAKILL(args)
		if args.spellName == domoDeath then
			--This is still going to use a sync event because someone might start this RP from REALLY REALLY far away
			self:SendSync("DomoDeath")
		end
	end
end


function mod:UNIT_DIED(args)
	local guid = args.destGUID
	local cid = self:GetCIDFromGUID(guid)
	if cid == 12143 then--Son of Flame
		if not addsGuidCheck[guid] then
			addsGuidCheck[guid] = true
			self.vb.addLeft = self.vb.addLeft - 1
			if not self.vb.ragnarosEmerged and self.vb.addLeft == 0 then--After all 8 die he emerges immediately
				self:Unschedule(emerged)
				emerged(self)
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(msg)
	if msg == L.Submerge then
		self:SendSync("Submerge")
--	elseif msg == L.Pull and self:AntiSpam(5, 4) then
--		self:SendSync("SummonRag")
	end
end

function mod:OnSync(msg, guid)
	if msg == "SummonRag" and self:AntiSpam(5, 2) then
		timerCombatStart:Start()
	elseif msg == "Submerge" and self:IsInCombat() then
		self.vb.ragnarosEmerged = false
		self:Unschedule(emerged)
		timerWrathRag:Stop()
		warnSubmerge:Show()
		timerEmerge:Start(90)
		self:Schedule(90, emerged, self)
		self.vb.addLeft = self.vb.addLeft + 8
	elseif msg == "DomoDeath" and self:AntiSpam(5, 3) then
		timerCombatStart:Stop()
		timerCombatStart:Start(7)
	end
end
