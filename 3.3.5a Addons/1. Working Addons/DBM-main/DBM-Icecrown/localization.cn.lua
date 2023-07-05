if GetLocale() ~= "zhCN" then return end
local L
----------------------
--  Lord Marrowgar  --
----------------------
L = DBM:GetModLocalization("LordMarrowgar")

L:SetGeneralLocalization({
	name = "玛洛加尔领主"
})

-------------------------
--  Lady Deathwhisper  --
-------------------------
L = DBM:GetModLocalization("Deathwhisper")

L:SetGeneralLocalization({
	name = "亡语者女士"
})

L:SetTimerLocalization({
	TimerAdds = "新的小怪"
})

L:SetWarningLocalization({
	WarnReanimating = "小怪再活化",
	WarnAddsSoon = "新的小怪即将到来",
	SpecWarnVengefulShade = "Vengeful Shade attacking you - Run Away", --creatureid 38222 --Needs translating
	WeaponsStatus = "Auto Unequipping enabled" --Needs translating
})

L:SetOptionLocalization({
	WarnAddsSoon = "为新的小怪出现显示预先警告",
	WarnReanimating = "当小怪再活化时显示警告",
	TimerAdds = "为新的小怪显示计时器",
	SpecWarnVengefulShade = "Show special warning when you are attacked by Vengeful Shade", --creatureid 38222
	WeaponsStatus = "Special warning at combat start if unequip/equip function is enabled",
	ShieldHealthFrame = "Show boss health with a health bar for $spell:70842",
	SoundWarnCountingMC = "Play a 5 second audio countdown for Mind Control",
--	RemoveDruidBuff = "Remove $spell:48469 / $spell:48470 24 seconds into the fight",
	RemoveBuffsOnMC = "当$spell:71289对你施法时，移除BUFF。每个选项都是累积的。",
	Gift = "移除$spell:48469 / $spell:48470。防止$spell:33786抵制的最简单方法。",
	CCFree = "+ 删除$spell:48169 / $spell:48170。考虑到阴影学派中法术的抵抗。",
	ShortOffensiveProcs = "+ 删除持续时间短的攻击性程序。建议在不影响突击队伤害输出的情况下保证突击队的安全。",
	MostOffensiveBuffs = "+ 移除大部分攻击性BUFF（主要针对施法者和|cFFFF7C0A野性德鲁伊|r）。在损失伤害输出和需要自我补血/移形换影的情况下，最大限度地保证了突击队的安全！",
	EqUneqWeapons = "Unequip/equip weapons if $spell:71289 is cast on you. For equipping to work, create a COMPLETE (with the weapons of choice that will be equipped) equipment set named \"pve\".", --Needs Translating
	EqUneqTimer = "Remove weapons by timer ALWAYS, not on cast (if ping is high). The option above must be enabled." --Needs Translating
})

L:SetMiscLocalization({
	YellReanimatedFanatic = "来吧，为纯粹的形态欢喜吧！",
--	Fanatic1 = "教派狂热者",
--	Fanatic2 = "畸形的狂热者",
--	Fanatic3 = "被复活的狂热者",
	setMissing = "注意力！ 在您创建名为 pve 的装备集之前，DBM 自动武器卸载/装备将不起作用",
	EqUneqLineDescription	= "自动装备/取消装备"
})

----------------------
--  Gunship Battle  --
----------------------
L = DBM:GetModLocalization("GunshipBattle")

L:SetGeneralLocalization({
	name = "冰冠炮舰战斗"
})

L:SetWarningLocalization({
	WarnAddsSoon = "新的小怪即将到来"
})

L:SetOptionLocalization({
	WarnAddsSoon = "为新的小怪出现显示预先警告",
	TimerAdds = "为新的小怪显示计时器"
})

L:SetTimerLocalization({
	TimerAdds = "新的小怪"
})

L:SetMiscLocalization({
	PullAlliance = "启动引擎！小伙子们，向命运之战前进！",
	PullHorde = "来吧！部落忠诚勇敢的儿女们！今天是部落仇敌灭亡的日子！LOK'TAR OGAR！",
	AddsAlliance = "将士们，给我进攻！",
	AddsHorde = "将士们，给我进攻！",
	MageAlliance = "我们的船体受损了，赶快叫个战斗法师来轰掉那些大炮！",
	MageHorde = "我们的船体受伤了，赶快叫个法师来干掉那些大炮！",
	KillAlliance = "我早就警告过你，恶棍！兄弟姐妹们，前进！",
	KillHorde = "联盟不行了。向巫妖王进攻！",
})

-----------------------------
--  Deathbringer Saurfang  --
-----------------------------
L = DBM:GetModLocalization("Deathbringer")

L:SetGeneralLocalization({
	name = "死亡使者萨鲁法尔"
})

L:SetOptionLocalization({
	RunePowerFrame = "显示首领血量及$spell:72371条",
--	RemoveDI = "如果用于阻止 $spell:72293 施法，则清除 $spell:19752"
})

L:SetMiscLocalization({
	RunePower = "鲜血能量",
	PullAlliance = "你每消灭一名部落士兵，或是杀死一只联盟狗。巫妖王的军力就会增长一分。瓦格里正在把你们的阵亡者变为天灾战士。",
	PullHorde = "库卡隆，行动！勇士们，提高警惕。天灾军团已经……"
})

-----------------
--  Festergut  --
-----------------
L = DBM:GetModLocalization("Festergut")

L:SetGeneralLocalization({
	name = "烂肠"
})

L:SetOptionLocalization({
	AnnounceSporeIcons = "公布$spell:69279目标设置的标记到团队频道<br/>(需要团队队长)",
	AchievementCheck = "公布 '流感疫苗短缺' 成就失败到团队频道<br/>(需助理权限)"
})

L:SetMiscLocalization({
	SporeSet = "气体孢子{rt%d}: %s",
	AchievementFailed = ">> 成就失败: %s中了%d层孢子 <<"
})

---------------
--  Rotface  --
---------------
L = DBM:GetModLocalization("Rotface")

L:SetGeneralLocalization({
	name = "腐面"
})

L:SetWarningLocalization({
	WarnOozeSpawn = "小软泥怪出现了",
	SpecWarnLittleOoze = "你被小软泥怪盯上了 - 快跑开"
})

L:SetOptionLocalization({
	WarnOozeSpawn = "为小软泥的出现显示警告",
	SpecWarnLittleOoze = "当你被小软泥怪盯上时显示特別警告",
	TankArrow = "Show DBM arrow for Big Ooze kiter (Experimental)" --Needs translating
})

L:SetMiscLocalization({
	YellSlimePipes1 = "好消息！各位！我修好了毒性软泥管道！",
	YellSlimePipes2 = "重大喜讯！各位！软泥又开始流动啦！"
})

---------------------------
--  Professor Putricide  --
---------------------------
L = DBM:GetModLocalization("Putricide")

L:SetGeneralLocalization({
	name = "普崔塞德教授"
})

----------------------------
--  Blood Prince Council  --
----------------------------
L = DBM:GetModLocalization("BPCouncil")

L:SetGeneralLocalization({
	name = "血王子议会"
})

L:SetWarningLocalization({
	WarnTargetSwitch = "转换目标到: %s",
	WarnTargetSwitchSoon = "转换目标即将到来"
})

L:SetTimerLocalization({
	TimerTargetSwitch = "转换目标"
})

L:SetOptionLocalization({
	WarnTargetSwitch = "为转换目标显示警告",
	WarnTargetSwitchSoon = "为转换目标显示预先警告",
	TimerTargetSwitch = "为转换目标显示冷却计时器",
	ActivePrinceIcon = "设置标记在強化的亲王身上(头颅)",
	ShadowPrisonMetronome = "播放一个重复的1秒钟的点击声，以避免$spell:72999"
})

L:SetMiscLocalization({
	Keleseth = "凯雷塞斯王子",
	Taldaram = "塔达拉姆王子",
	Valanar = "瓦拉纳王子",
	FirstPull = "愚蠢的凡人。你以为能轻易打败我们？萨莱因是巫妖王永生的战士！现在他们将合力撕碎你！",
	EmpoweredFlames = "强能烈焰飞快地冲向(%S+)！"
})

-----------------------------
--  Blood-Queen Lana'thel  --
-----------------------------
L = DBM:GetModLocalization("Lanathel")

L:SetGeneralLocalization({
	name = "鲜血女王兰娜瑟尔"
})

L:SetMiscLocalization({
	SwarmingShadows = "蜂拥的阴影在(%S+)的四周积聚！",
	YellFrenzy = "我该去咬人啦!"
})

-----------------------------
--  Valithria Dreamwalker  --
-----------------------------
L = DBM:GetModLocalization("Valithria")

L:SetGeneralLocalization({
	name = "踏梦者瓦莉瑟瑞娅"
})

L:SetWarningLocalization({
	WarnPortalOpen = "传送门开启"
})

L:SetTimerLocalization({
	TimerPortalsOpen = "传送门开启",
	TimerPortalsClose = "Portals close", --Needs translating
	TimerBlazingSkeleton = "下一次炽热骷髅",
	TimerAbom = "下一次憎恶体 (%s)"
})

L:SetOptionLocalization({
	WarnPortalOpen = "当梦魇之门开启时显示警告",
	TimerPortalsOpen = "当梦魇之门开启时显示计时器",
	TimerPortalsClose = "Show timer when Nightmare Portals are closed", --Needs translating
	TimerBlazingSkeleton = "为下一次炽热骷髅出现显示计时器"
})

L:SetMiscLocalization({
	YellPull = "入侵者闯入了内室。加紧毁掉那条绿龙！留下龙筋龙骨用来复生！",
	YellPortals = "我打开了进入梦境的传送门。英雄们，救赎就在其中……",
})

------------------
--  Sindragosa  --
------------------
L = DBM:GetModLocalization("Sindragosa")

L:SetGeneralLocalization({
	name = "辛达苟萨"
})

L:SetWarningLocalization({
	WarnAirphase = "空中阶段",
	WarnGroundphaseSoon = "辛达苟萨 即将着陆"
})

L:SetTimerLocalization({
	TimerNextAirphase = "下一次空中阶段",
	TimerNextGroundphase = "下一次地上阶段",
	AchievementMystic = "清除秘能连击叠加"
})

L:SetOptionLocalization({
	WarnAirphase = "提示空中阶段",
	WarnGroundphaseSoon = "为地上阶段显示预先警告",
	TimerNextAirphase = "为下一次 空中阶段显示计时器",
	TimerNextGroundphase = "为下一次 地上阶段显示计时器",
	AnnounceFrostBeaconIcons = "公布$spell:70126目标设置的标记到团队频道<br/>(需要团队队长)",
	ClearIconsOnAirphase = "空中阶段前清除所有标记",
	AssignWarnDirectionsCount = "为 $spell:70126 目标分配方向并在第 2 阶段进行计数",
	AchievementCheck = "公布 '吃到饱' 成就警告到团队频道<br/>(需助理权限)",
	RangeFrame = "根据最后首领使用的技能跟玩家减益显示动态距离框(10/20码)"
})

L:SetMiscLocalization({
	YellAirphase = "你们的入侵结束了！无人可以生还！",
	YellPhase2 = "绝望吧，体会主人那无穷无尽的力量吧！",
	YellAirphaseDem = "Rikk zilthuras rikk zila Aman adare tiriosh ", --Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	YellPhase2Dem = "Zar kiel xi romathIs zilthuras revos ruk toralar ", --Demonic, since curse of tonges is used by some guilds and it messes up yell detection.
	BeaconIconSet = "冰霜道标{rt%d}: %s",
	AchievementWarning = "警告: %s中了5层秘法打击",
	AchievementFailed = ">> 成就失败: %s中了%d层秘法打击 <<"
})

---------------------
--  The Lich King  --
---------------------
L = DBM:GetModLocalization("LichKing")

L:SetGeneralLocalization({
	name = "巫妖王"
})

L:SetWarningLocalization({
	ValkyrWarning = "%s >%s< %s 被抓住了!",
	SpecWarnYouAreValkd = "你被抓住了",
	WarnNecroticPlagueJump = "亡域瘟疫跳到>%s<身上",
	SpecWarnValkyrLow = "瓦基里安血量低于55%"
})

L:SetTimerLocalization({
	TimerRoleplay = "角色扮演",
	PhaseTransition = "转换阶段",
	TimerNecroticPlagueCleanse = "净化亡域瘟疫"
})

L:SetOptionLocalization({
	TimerRoleplay = "为角色扮演事件显示计时器",
	WarnNecroticPlagueJump = "提示$spell:73912跳跃后的目标",
	TimerNecroticPlagueCleanse = "为净化第一次堆叠前的亡域瘟疫显示计时器",
	PhaseTransition = "为转换阶段显示计时器",
	ValkyrWarning = "提示谁给瓦基里安影卫抓住了",
	SpecWarnYouAreValkd = "当你给瓦基里安影卫抓住时显示特別警告",
	AnnounceValkGrabs = "提示谁被瓦基里安影卫抓住到团队频道<br/>(需开启团队广播及助理权限)",
	SpecWarnValkyrLow = "当瓦基里安血量低于55%时显示特別警告",
	AnnouncePlagueStack = "提示$spell:73912层数到团队频道 (10层, 10层后每5层提示一次)<br/>(需开启助理权限)",
	ShowFrame = "Show Val'Kyr Targets frame", --Needs translating
	FrameClassColor = "Use Class Colors in Val'Kyr Targets frame", --Needs translating
	FrameUpwards = "Expand Val'Kyr target frame upwards", --Needs translating
	FrameLocked = "Lock Val'Kyr Targets frame", --Needs translating
	RemoveImmunes = "Remove immunity spells before exiting Frostmourne room" --Needs translating
})

L:SetMiscLocalization({
	LKPull = "怎么，自诩正义的圣光终于来了？我是不是该丢下霜之哀伤，恳求您的宽恕呢，弗丁？",
	LKRoleplay = "真的是正义在驱使你吗？我很好奇……",
	ValkGrabbedIcon = "瓦格里影卫{rt%d}抓住了%s",
	ValkGrabbed = "瓦格里影卫抓住了%s",
	PlagueStackWarning = "警告: %s中了%d层亡域瘟疫",
	AchievementCompleted = ">> 成就成功: %s中了%d层亡域瘟疫 <<",
	FrameTitle = "Valkyr targets", --Needs translating
	FrameLock = "Frame Lock", --Needs translating
	FrameClassColor = "Use Class Colors", --Needs translating
	FrameOrientation = "Expand upwards", --Needs translating
	FrameHide = "Hide Frame", --Needs translating
	FrameClose = "Close", --Needs translating
	FrameGUIDesc = "瓦格里框架",
	FrameGUIMoveMe = "移动瓦格里框架"
})

-------------
--  Trash  --
-------------
L = DBM:GetModLocalization("ICCTrash")

L:SetGeneralLocalization({
	name = "Icecrown Trash"
})

L:SetWarningLocalization({
	SpecWarnTrapL = "触发陷阱! - 亡缚守卫被释放了",
	SpecWarnTrapP = "触发陷阱! - 复仇的血肉收割者到来",
	SpecWarnGosaEvent = "辛达苟萨夹道攻击开始!"
})

L:SetOptionLocalization({
	SpecWarnTrapL = "当触发陷阱时显示特別警告",
	SpecWarnTrapP = "当触发陷阱时显示特別警告",
	SpecWarnGosaEvent = "为辛达苟萨夹道攻击显示特別警告"
})

L:SetMiscLocalization({
	WarderTrap1 = "那里是谁？",
	WarderTrap2 = "我醒了!",
	WarderTrap3 = "有人闯进了主人的房间！",
	FleshreaperTrap1 = "快点，我们会在背后伏击他们！",
	FleshreaperTrap2 = "你逃不出我们的手心！",
	FleshreaperTrap3 = "这里有活人？！",
	SindragosaEvent = "绝不能让他们靠近冰霜女王。快，阻止他们！"
})