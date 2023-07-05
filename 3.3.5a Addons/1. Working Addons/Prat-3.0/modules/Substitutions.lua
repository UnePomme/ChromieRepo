﻿---------------------------------------------------------------------------------
--
-- Prat - A framework for World of Warcraft chat mods
--
-- Copyright (C) 2006-2007  Prat Development Team
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to:
--
-- Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor,
-- Boston, MA  02110-1301, USA.
--
--
-------------------------------------------------------------------------------
--[[
Name: PratSubstitutions
Revision: $Revision: 80784 $
Author(s): Sylvanaar
Website: http://files.wowace.com/Prat/
Documentation: http://www.wowace.com/wiki/Prat/Integrated_Modules#Substitutions
Subversion: http://svn.wowace.com/wowace/trunk/Prat/
Discussions: http://groups.google.com/group/wow-prat
Issues and feature requests: http://code.google.com/p/prat/issues/list
Based on: CFE2 by Satrina. (http://www.wowinterface.com/downloads/info6885-ChatFrameExtender2.html
Dependencies: Prat
Description: A module to provide basic chat substitutions. (default=off).
]]

Prat:AddModuleToLoad(function() 


local PRAT_MODULE = Prat:RequestModuleName("Substitutions")

if PRAT_MODULE == nil then 
    return 
end

-- define localized strings
local L = Prat:GetLocalizer({})

--[===[@debug@
L:AddLocale("enUS", {
	["Substitutions"] = true,
	["A module to provide basic chat substitutions."] = true,
	['User defined substitutions'] = true,
	['Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)'] = true,
	['Set substitution'] = true,
	['Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition).'] = true,
	['subname = text after expansion -- NOTE: sub name without the prefix "%"'] = true,
	['List substitutions'] = true,
	['Lists all current subtitutions in the default chat frame'] = true,
	['Delete substitution'] = true,
	['Deletes a user defined substitution'] = true,
	['subname -- NOTE: sub name without the prefix \'%\''] = true,
	['Are you sure?'] = true,
	['Delete all'] = true,
	['Deletes all user defined substitutions'] = true,
	['Are you sure - this will delete all user defined substitutions and reset defaults?'] = true,
	['List of available substitutions'] = true,
	['List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)'] = true,
	["NO MATCHFUNC FOUND"] = true,
	["Current value: '%s'\nClick to paste into the chat."] = true,
	['no substitution name given'] = true,
	['no value given for subtitution "%s"'] = true,
	['|cffff0000warning:|r subtitution "%s" already defined as "%s", overwriting'] = true,
	['defined %s: expands to => %s'] = true,
	['no substitution name supplied for deletion'] = true,
	['no user defined subs found'] = true,
	['user defined substition "%s" not found'] = true,
	["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = true,
	["can't find substitution index for a substitution named '%s'"] = true,
	['removing user defined substitution "%s"; previously expanded to => "%s"'] = true,
	['substitution: %s defined as => %s'] = true,
	['%d total user defined substitutions'] = true,
	['module:buildUserSubsIndex(): warning: module patterns not defined!'] = true,

	["<notarget>"] = true,
	["male"] = true,
	["female"] = true,
	["unknown sex"] = true,
	["<noguild>"] = true,
	["his"] = true,
	["hers"] = true,
	["its"] = true,
	["him"] = true,
	["her"] = true,
	["it"] = true,

	['usersub_'] = true,
	["TargetHealthDeficit"] = true,
	["TargetPercentHP"] = true,
	["TargetPronoun"] = true,
	["PlayerHP"] = true,
	["PlayerName"] = true,
	["PlayerMaxHP"] = true,
	["PlayerHealthDeficit"] = true,
	["PlayerPercentHP"] = true,
	["PlayerCurrentMana"] = true,
	["PlayerMaxMana"] = true,
	["PlayerPercentMana"] = true,
	["PlayerManaDeficit"] = true,
	["TargetName"] = true,
	["TargetTargetName"] = true,
	["MouseoverTargetName"] = true,
	["TargetClass"] = true,
	["TargetHealth"] = true,
	["TargetRace"] = true,
	["TargetGender"] = true,
	["TargetLevel"] = true,
	["TargetPossesive"] = true,
	["TargetManaDeficit"] = true,
	["TargetGuild"] = true,
	["TargetIcon"] = true,
	["MapZone"] = true,
	["MapLoc"] = true,
	["MapPos"] = true,
	["MapYPos"] = true,
	["MapXPos"] = true,
	["RandNum"] = true,
})
--@end-debug@]===]

-- These Localizations are auto-generated. To help with localization
-- please go to http://www.wowace.com/projects/prat-3-0/localization/


--@non-debug@
L:AddLocale("enUS", 
{
	["%d total user defined substitutions"] = true,
	["<noguild>"] = true,
	["<notarget>"] = true,
	["A module to provide basic chat substitutions."] = true,
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = true,
	["Are you sure?"] = true,
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = true,
	["Delete all"] = true,
	["Delete substitution"] = true,
	["Deletes a user defined substitution"] = true,
	["Deletes all user defined substitutions"] = true,
	["List of available substitutions"] = true,
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = true,
	["List substitutions"] = true,
	["Lists all current subtitutions in the default chat frame"] = true,
	MapLoc = true,
	MapPos = true,
	MapXPos = true,
	MapYPos = true,
	MapZone = true,
	MouseoverTargetName = true,
	["NO MATCHFUNC FOUND"] = true,
	["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = true,
	PlayerCurrentMana = true,
	PlayerHP = true,
	PlayerHealthDeficit = true,
	PlayerManaDeficit = true,
	PlayerMaxHP = true,
	PlayerMaxMana = true,
	PlayerName = true,
	PlayerPercentHP = true,
	PlayerPercentMana = true,
	RandNum = true,
	["Set substitution"] = true,
	["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = true,
	Substitutions = true,
	TargetClass = true,
	TargetGender = true,
	TargetGuild = true,
	TargetHealth = true,
	TargetHealthDeficit = true,
	TargetIcon = true,
	TargetLevel = true,
	TargetManaDeficit = true,
	TargetName = true,
	TargetPercentHP = true,
	TargetPossesive = true,
	TargetPronoun = true,
	TargetRace = true,
	TargetTargetName = true,
	["User defined substitutions"] = true,
	["can't find substitution index for a substitution named '%s'"] = true,
	["defined %s: expands to => %s"] = true,
	female = true,
	her = true,
	hers = true,
	him = true,
	his = true,
	it = true,
	its = true,
	male = true,
	["module:buildUserSubsIndex(): warning: module patterns not defined!"] = true,
	["no substitution name given"] = true,
	["no substitution name supplied for deletion"] = true,
	["no user defined subs found"] = true,
	["no value given for subtitution \"%s\""] = true,
	["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = true,
	["subname -- NOTE: sub name without the prefix '%'"] = true,
	["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = true,
	["substitution: %s defined as => %s"] = true,
	["unknown sex"] = true,
	["user defined substition \"%s\" not found"] = true,
	["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = true,
	usersub_ = true,
	["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = true,
}

)
L:AddLocale("frFR",  
{
	["%d total user defined substitutions"] = "%s substitutions personnalisées totales",
	["<noguild>"] = "<pas de guilde>",
	["<notarget>"] = "<pas de cible>",
	["A module to provide basic chat substitutions."] = "Un module qui propose quelques substitutions basiques.",
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "Etes-vous sûr ? Cela supprimera toutes les substitutions personnalisées et réinitialisera les valeurs par défaut.",
	["Are you sure?"] = "Êtes-vous sûr ?",
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = [=[Valeur actuelle : '%s'
Cliquez pour coller dans le chat.]=],
	["Delete all"] = "Tout supprimer",
	["Delete substitution"] = "Supprimer la substitution",
	["Deletes a user defined substitution"] = "Supprime une substitution personnalisée",
	["Deletes all user defined substitutions"] = "Supprime toutes les substitutions personnalisées",
	["List of available substitutions"] = "Liste des substitution disponibles",
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Liste toutes les substitutions disponibles définies par ce module. (NB: l'utilisateur peut définir des valeurs personnalisées pour les substitutions existantes, mais celles-ci seront remisent à leurs valeurs par défaut si les options sont réinitialisées.)",
	["List substitutions"] = "Liste des substitutions",
	["Lists all current subtitutions in the default chat frame"] = "Liste toutes les substitutions dans la fenêtre de discussion",
	MapLoc = "Localisation",
	MapPos = "Position",
	MapXPos = "Position X",
	MapYPos = "Position Y",
	MapZone = "Zone",
	-- MouseoverTargetName = "",
	["NO MATCHFUNC FOUND"] = "PAS DE FONCTION ASSOCIÉE TROUVÉE",
	-- ["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "",
	PlayerCurrentMana = "Mana actuelle",
	PlayerHP = "HP actuel",
	PlayerHealthDeficit = "Déficit de vie",
	PlayerManaDeficit = "Déficit de mana",
	PlayerMaxHP = "HP Max",
	PlayerMaxMana = "Mana Max",
	PlayerName = "Nom joueur",
	PlayerPercentHP = "Pourcentage HP",
	PlayerPercentMana = "Pourcentage Mana",
	RandNum = "Nombre aléatoire",
	-- ["Set substitution"] = "",
	-- ["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "",
	Substitutions = true,
	TargetClass = "Cible Classe",
	TargetGender = "Cible Sexe",
	TargetGuild = "Cible Guilde",
	TargetHealth = "Santé Cible",
	TargetHealthDeficit = "Déficit Vie Cible",
	TargetIcon = "CibleIcone",
	TargetLevel = "CibleNiveau",
	TargetManaDeficit = "CibleManqueDeMana",
	-- TargetName = "",
	-- TargetPercentHP = "",
	-- TargetPossesive = "",
	-- TargetPronoun = "",
	-- TargetRace = "",
	-- TargetTargetName = "",
	-- ["User defined substitutions"] = "",
	-- ["can't find substitution index for a substitution named '%s'"] = "",
	-- ["defined %s: expands to => %s"] = "",
	-- female = "",
	-- her = "",
	-- hers = "",
	-- him = "",
	-- his = "",
	-- it = "",
	-- its = "",
	-- male = "",
	-- ["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "",
	-- ["no substitution name given"] = "",
	-- ["no substitution name supplied for deletion"] = "",
	-- ["no user defined subs found"] = "",
	-- ["no value given for subtitution \"%s\""] = "",
	-- ["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "",
	-- ["subname -- NOTE: sub name without the prefix '%'"] = "",
	-- ["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "",
	-- ["substitution: %s defined as => %s"] = "",
	["unknown sex"] = "sexe inconnue",
	-- ["user defined substition \"%s\" not found"] = "",
	-- ["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "",
	-- usersub_ = "",
	-- ["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "",
}

)
L:AddLocale("deDE", 
{
	["%d total user defined substitutions"] = " %d Gesamte vom Benutzer definierte Ersetzungen",
	["<noguild>"] = " <keinegilde>",
	["<notarget>"] = "<keinziel>",
	["A module to provide basic chat substitutions."] = "Ein Modul, das grundlegende Ersetzungen zur Verfügung stellt.",
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "Bist du sicher - dies wird alle vom Benutzer definierten Ersetzungen löschen und auf Standard zurücksetzen.",
	["Are you sure?"] = "Bist Du sicher?",
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = [=[Gegenwärtiger Wert: '%s'
Anklicken, um in den Chat einzufügen.]=],
	["Delete all"] = "Alle löschen",
	["Delete substitution"] = "Ersetzung löschen",
	["Deletes a user defined substitution"] = "Löscht eine vom Benutzer definierte Ersetzung",
	["Deletes all user defined substitutions"] = "Löscht alle vom Benutzer definierten Ersetzungen",
	["List of available substitutions"] = "Liste der verfügbaren Ersetzungen",
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Die List der verfügbaren Ersetzungen wird von diesem Modul definiert. (NB: Benutzer können gebräuchliche Werte für vorhandene Ersetzungen definieren, aber sie werden auf ihre Standardwerte zurückgesetzt, falls die Definitionen des Benutzers gelöscht wurde.)",
	["List substitutions"] = "Ersetzungen auflisten",
	["Lists all current subtitutions in the default chat frame"] = "Alle gegenwärtigen Ersetzungen im Standard-Chat-Rahmen auflisten.",
	MapLoc = "KarteOrt",
	MapPos = "KartePos",
	MapXPos = "KarteXPos",
	MapYPos = "KarteYPos",
	MapZone = "KarteZone",
	MouseoverTargetName = true,
	["NO MATCHFUNC FOUND"] = true,
	["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Optionen zum Einstellen und Entfernen benutzerdefinierter Ersetzungen. (NB: Benutzer können eigeneWerte für vorhandene Ersetzungen definieren, aber diese werden auf ihre Standardwerte zurückgesetzt, wenn die Definition des Benutzers gelöscht wurde.)",
	PlayerCurrentMana = "SpielerAktuellesMana",
	PlayerHP = "SpielerHP",
	PlayerHealthDeficit = "SpielerGesundheitDefizit",
	PlayerManaDeficit = "SpielerManaDefizit",
	PlayerMaxHP = "SpielerMaxHP",
	PlayerMaxMana = "SpielerMaxMana",
	PlayerName = "SpielerName",
	PlayerPercentHP = "SpielerProzentHP",
	PlayerPercentMana = "SpielerProzentMana",
	RandNum = "ZufNum",
	["Set substitution"] = "Ersetzung einstellen",
	["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "Den Wert für eine benutzerdefinierte Ersetzung einstellen. (NB: dies kann einer vorhandenen Standardersetzung gleichen; um sie auf Standard zurückzusetzen, einfach die vom Benutzer erschaffene Definition entfernen.)",
	Substitutions = "Ersetzungen",
	TargetClass = "ZielKlasse",
	TargetGender = "ZielGeschlecht",
	TargetGuild = "ZielGilde",
	TargetHealth = "ZielGesundheit",
	TargetHealthDeficit = "ZielGesundheitDefizit",
	TargetIcon = "ZielSymbol",
	TargetLevel = "ZielStufe",
	TargetManaDeficit = "ZielManaDefizit",
	TargetName = "ZielName",
	TargetPercentHP = "ZielProzentHP",
	TargetPossesive = "ZielGierig",
	TargetPronoun = "ZielPronomen",
	TargetRace = "ZielVolk",
	TargetTargetName = "ZielZielName",
	["User defined substitutions"] = "Benutzerdefinierte Ersetzungen",
	["can't find substitution index for a substitution named '%s'"] = "Kann Ersetzungsindex für eine Ersetzung mit dem Namen '%s' nicht finden.",
	["defined %s: expands to => %s"] = "definiert %s: erweitert zu => %s",
	female = "weiblich",
	her = "ihr",
	hers = "ihr/ihre",
	him = "ihn/ihm",
	his = "sein/seine",
	it = "es",
	its = "sein",
	male = "männlich",
	["module:buildUserSubsIndex(): warning: module patterns not defined!"] = true,
	["no substitution name given"] = "kein Ersetzungsname vergeben",
	["no substitution name supplied for deletion"] = "kein Ersetzungsname für Löschung geliefert",
	["no user defined subs found"] = "keine benutzerdefinierten Ersetzungen gefunden",
	["no value given for subtitution \"%s\""] = "kein Wert für Ersetzung \"%s\" gegeben",
	["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "Benutzerdefinierte Ersetzung \"%s\" wird entfernt; zuvor erweitert zu => \"%s\"",
	["subname -- NOTE: sub name without the prefix '%'"] = "Subname -- MERKE: Subname ohne den Vorsatz '%'",
	["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "Subname = Text nach Erweiterung -- MERKE: Subname ohne den Vorsatz \"%\"",
	["substitution: %s defined as => %s"] = "Ersetzung: %s definiert als => %s",
	["unknown sex"] = "Geschlecht unbekannt",
	["user defined substition \"%s\" not found"] = "Benutzerdefinierte Ersetzung \"%s\" nicht gefunden",
	["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "Ersetzungsindex des Benutzers (usersubs_idx) existiert nicht! Oh weh!",
	usersub_ = " \009 \009usersub_",
	["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "|cffff0000Warnung:|r Ersetzung \"%s\" wurde bereits definiert als \"%s\", überschreibe",
}

)
L:AddLocale("koKR",  
{
	-- ["%d total user defined substitutions"] = "",
	["<noguild>"] = "<길드없음>",
	["<notarget>"] = "<대상없음>",
	-- ["A module to provide basic chat substitutions."] = "",
	-- ["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "",
	["Are you sure?"] = "동의합니까?",
	--[==[ [ [=[Current value: '%s'
Click to paste into the chat.]=] ] = "", ]==]
	["Delete all"] = "전부 삭제",
	-- ["Delete substitution"] = "",
	-- ["Deletes a user defined substitution"] = "",
	-- ["Deletes all user defined substitutions"] = "",
	-- ["List of available substitutions"] = "",
	-- ["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "",
	-- ["List substitutions"] = "",
	-- ["Lists all current subtitutions in the default chat frame"] = "",
	-- MapLoc = "",
	MapPos = "지도 좌표",
	MapXPos = "지도 X좌표",
	MapYPos = "지도 Y좌표",
	-- MapZone = "",
	MouseoverTargetName = "마우스오버 대상 이름",
	-- ["NO MATCHFUNC FOUND"] = "",
	-- ["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "",
	PlayerCurrentMana = "플레이어 현재마나",
	PlayerHP = "플레이어 체력",
	PlayerHealthDeficit = "플레이어 체력결손치",
	PlayerManaDeficit = "플레이어 마나결손치",
	PlayerMaxHP = "플레이어 최대체력",
	PlayerMaxMana = "플레이어 최대마나",
	PlayerName = "플레이어 이름",
	PlayerPercentHP = "플레이어 체력백분율",
	PlayerPercentMana = "플레이어 마나백분율",
	-- RandNum = "",
	-- ["Set substitution"] = "",
	-- ["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "",
	-- Substitutions = "",
	TargetClass = "대상 직업",
	TargetGender = "대상 성별",
	TargetGuild = "대상 길드",
	TargetHealth = "대상 체력",
	TargetHealthDeficit = "대상 체력결손치",
	TargetIcon = "대상 아이콘",
	TargetLevel = "대상 레벨",
	TargetManaDeficit = "대상 마나결손치",
	TargetName = "대상 이름",
	TargetPercentHP = "대상 체력백분율",
	-- TargetPossesive = "",
	-- TargetPronoun = "",
	TargetRace = "대상 종족",
	TargetTargetName = "대상의 대상 이름",
	-- ["User defined substitutions"] = "",
	-- ["can't find substitution index for a substitution named '%s'"] = "",
	-- ["defined %s: expands to => %s"] = "",
	-- female = "",
	-- her = "",
	-- hers = "",
	-- him = "",
	-- his = "",
	-- it = "",
	-- its = "",
	-- male = "",
	-- ["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "",
	-- ["no substitution name given"] = "",
	-- ["no substitution name supplied for deletion"] = "",
	-- ["no user defined subs found"] = "",
	-- ["no value given for subtitution \"%s\""] = "",
	-- ["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "",
	-- ["subname -- NOTE: sub name without the prefix '%'"] = "",
	-- ["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "",
	-- ["substitution: %s defined as => %s"] = "",
	-- ["unknown sex"] = "",
	-- ["user defined substition \"%s\" not found"] = "",
	-- ["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "",
	-- usersub_ = "",
	-- ["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "",
}

)
L:AddLocale("esMX",  
{
	-- ["%d total user defined substitutions"] = "",
	-- ["<noguild>"] = "",
	-- ["<notarget>"] = "",
	-- ["A module to provide basic chat substitutions."] = "",
	-- ["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "",
	-- ["Are you sure?"] = "",
	--[==[ [ [=[Current value: '%s'
Click to paste into the chat.]=] ] = "", ]==]
	-- ["Delete all"] = "",
	-- ["Delete substitution"] = "",
	-- ["Deletes a user defined substitution"] = "",
	-- ["Deletes all user defined substitutions"] = "",
	-- ["List of available substitutions"] = "",
	-- ["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "",
	-- ["List substitutions"] = "",
	-- ["Lists all current subtitutions in the default chat frame"] = "",
	-- MapLoc = "",
	-- MapPos = "",
	-- MapXPos = "",
	-- MapYPos = "",
	-- MapZone = "",
	-- MouseoverTargetName = "",
	-- ["NO MATCHFUNC FOUND"] = "",
	-- ["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "",
	-- PlayerCurrentMana = "",
	-- PlayerHP = "",
	-- PlayerHealthDeficit = "",
	-- PlayerManaDeficit = "",
	-- PlayerMaxHP = "",
	-- PlayerMaxMana = "",
	-- PlayerName = "",
	-- PlayerPercentHP = "",
	-- PlayerPercentMana = "",
	-- RandNum = "",
	-- ["Set substitution"] = "",
	-- ["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "",
	-- Substitutions = "",
	-- TargetClass = "",
	-- TargetGender = "",
	-- TargetGuild = "",
	-- TargetHealth = "",
	-- TargetHealthDeficit = "",
	-- TargetIcon = "",
	-- TargetLevel = "",
	-- TargetManaDeficit = "",
	-- TargetName = "",
	-- TargetPercentHP = "",
	-- TargetPossesive = "",
	-- TargetPronoun = "",
	-- TargetRace = "",
	-- TargetTargetName = "",
	-- ["User defined substitutions"] = "",
	-- ["can't find substitution index for a substitution named '%s'"] = "",
	-- ["defined %s: expands to => %s"] = "",
	-- female = "",
	-- her = "",
	-- hers = "",
	-- him = "",
	-- his = "",
	-- it = "",
	-- its = "",
	-- male = "",
	-- ["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "",
	-- ["no substitution name given"] = "",
	-- ["no substitution name supplied for deletion"] = "",
	-- ["no user defined subs found"] = "",
	-- ["no value given for subtitution \"%s\""] = "",
	-- ["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "",
	-- ["subname -- NOTE: sub name without the prefix '%'"] = "",
	-- ["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "",
	-- ["substitution: %s defined as => %s"] = "",
	-- ["unknown sex"] = "",
	-- ["user defined substition \"%s\" not found"] = "",
	-- ["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "",
	-- usersub_ = "",
	-- ["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "",
}

)
L:AddLocale("ruRU",  
{
	["%d total user defined substitutions"] = "всего %d пользовательских замен",
	["<noguild>"] = "<без гильдии>",
	["<notarget>"] = "<нет цели>",
	["A module to provide basic chat substitutions."] = "Модуль для простых замен текста в чате.",
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "Вы уверены - будут удалены все пользовательские замены и установлены значения по умолчанию?",
	["Are you sure?"] = "Ты уверен?",
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = [=[Текущее значение: '%s'
Щелкнуть для копирования в чат.]=], -- Needs review
	["Delete all"] = "Удалить все",
	["Delete substitution"] = "Удалить замену",
	["Deletes a user defined substitution"] = "Удаляет пользовательскую замену",
	["Deletes all user defined substitutions"] = "Удалить все замены заданные пользователем",
	["List of available substitutions"] = "Список доступных замен",
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Список доступных подмен, определённых в этом модуле. (Примечание: пользователи могут присваивать собственные значения существующим подменам, но они вернутся в значения по умолчанию, если пользовательское определение будет удалено.",
	["List substitutions"] = "Вывести список замен",
	["Lists all current subtitutions in the default chat frame"] = "Вывести все текущие замены в основное окно чата",
	MapLoc = "Блокировка карты",
	MapPos = "Позиция на карте",
	MapXPos = "Позиция Х на карте",
	-- MapYPos = "",
	-- MapZone = "",
	-- MouseoverTargetName = "",
	-- ["NO MATCHFUNC FOUND"] = "",
	["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Опции для назначения и отмены пользовательских замен. (Внимание: пользователи могут назначать свои значения для существующих замен, однако будет использовано значение по умолчанию если определение пользователя удалено).",
	PlayerCurrentMana = "текушая мана игрока",
	-- PlayerHP = "",
	-- PlayerHealthDeficit = "",
	PlayerManaDeficit = "нехватка маны",
	-- PlayerMaxHP = "",
	-- PlayerMaxMana = "",
	PlayerName = "Имя игрока",
	-- PlayerPercentHP = "",
	-- PlayerPercentMana = "",
	-- RandNum = "",
	["Set substitution"] = "Назначить замену",
	["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "Установить значение для определяемой пользователем замены (Внимание: может совпадать с существующей заменой по умолчанию; чтобы сбросить к первоначальному значению удалите пользовательское определение).",
	Substitutions = "Замены",
	TargetClass = "Класс цели", -- Needs review
	TargetGender = "Пол цели", -- Needs review
	TargetGuild = "показать гильдию",
	TargetHealth = "показать жизнь",
	TargetHealthDeficit = "Деф. здоровья цели", -- Needs review
	TargetIcon = "показать иконку",
	TargetLevel = "показать уровень",
	TargetManaDeficit = "Деф. маны цели", -- Needs review
	TargetName = "показать имя",
	TargetPercentHP = "% здоровья цели",
	TargetPossesive = "Притяжательное цели", -- Needs review
	TargetPronoun = "Местоимение цели", -- Needs review
	TargetRace = "Раса цели", -- Needs review
	TargetTargetName = "Имя цели цели", -- Needs review
	["User defined substitutions"] = "Пользовательские подмены", -- Needs review
	-- ["can't find substitution index for a substitution named '%s'"] = "",
	["defined %s: expands to => %s"] = "определено %s: раскрывается в => %s",
	female = "женский",
	her = "её",
	hers = "ей",
	him = "им",
	his = "его",
	it = "это",
	its = "его",
	male = "мужской",
	["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "module:buildUserSubsIndex(): предупреждение: шаблоны модуля не определены!",
	["no substitution name given"] = "не задано имя замены",
	["no substitution name supplied for deletion"] = "не задано имя замены для удаления",
	["no user defined subs found"] = "не найдено замен определяемых пользователем",
	["no value given for subtitution \"%s\""] = "не задано значение для замены \"%s\"",
	["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "удаляется определяемая пользователем замена \"%s\", раскрывавшаяся в => \"%s\"",
	-- ["subname -- NOTE: sub name without the prefix '%'"] = "",
	-- ["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "",
	-- ["substitution: %s defined as => %s"] = "",
	["unknown sex"] = "неизвестный пол",
	-- ["user defined substition \"%s\" not found"] = "",
	-- ["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "",
	-- usersub_ = "",
	-- ["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "",
}

)
L:AddLocale("zhCN",  
{
	["%d total user defined substitutions"] = "%d 全部用户定义的置换",
	["<noguild>"] = "<无公会>",
	["<notarget>"] = "<无目标>",
	["A module to provide basic chat substitutions."] = "提供基础聊天替换的模块",
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "您确定? - 这样将删除全部用户定义的替换并恢复默认",
	["Are you sure?"] = "您确定？",
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = "当前值: '%s'Click to paste into the chat.",
	["Delete all"] = "删除全部",
	["Delete substitution"] = "删除置换",
	["Deletes a user defined substitution"] = "删除用户定义的置换",
	["Deletes all user defined substitutions"] = "删除所有用户定义的置换",
	["List of available substitutions"] = "列出有效替换",
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "在此模块列出有效替换定义..(注:用户可以为已存在的置换定义自定义值,如果用户定义被删除将恢复默认值)",
	["List substitutions"] = "替换列表",
	["Lists all current subtitutions in the default chat frame"] = "在默认聊天框体列出所有当前替换",
	MapLoc = "地图地点",
	MapPos = "地图坐标",
	MapXPos = "地图X坐标",
	MapYPos = "地图Y坐标",
	MapZone = "地图区域",
	-- MouseoverTargetName = "",
	["NO MATCHFUNC FOUND"] = "未发现匹配函数",
	["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "设置和移除用户定义置换的选项.(注:用户可以为已存在的置换定义自定义值,如果用户定义被删除将恢复默认值)",
	PlayerCurrentMana = "玩家当前法力",
	PlayerHP = "玩家血量",
	PlayerHealthDeficit = "玩家生命不足",
	PlayerManaDeficit = "玩家法力不足",
	PlayerMaxHP = "玩家血量上限",
	PlayerMaxMana = "玩家法力上限",
	PlayerName = "玩家名称",
	PlayerPercentHP = "玩家血量百分比",
	PlayerPercentMana = "玩家法力百分比",
	RandNum = "随机数字",
	["Set substitution"] = "设置置换",
	["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "设置用户定义替换的值(注:这可能与现有的默认替换相同;若重置为默认,仅移除用户创建的定义)",
	Substitutions = "置换",
	TargetClass = "目标等级",
	TargetGender = "目标性别",
	TargetGuild = "目标公会",
	TargetHealth = "目标生命",
	TargetHealthDeficit = "目标生命不足",
	TargetIcon = "目标图标",
	TargetLevel = "目标等级",
	TargetManaDeficit = "目标法力不足",
	TargetName = "目标名称",
	TargetPercentHP = "目标血量百分比",
	TargetPossesive = "目标阵营",
	TargetPronoun = "目标代词",
	TargetRace = "目标种族",
	TargetTargetName = "目标的目标名称",
	["User defined substitutions"] = "用户自定义置换",
	["can't find substitution index for a substitution named '%s'"] = "无法为置换名称 '%s' 找到置换索引",
	["defined %s: expands to => %s"] = "定义 %s: 扩展到 => %s",
	female = "女",
	her = "她",
	hers = "她的",
	him = "他",
	his = "他的",
	it = "它",
	its = "它的",
	male = "男",
	["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "模块:buildUserSubsIndex(): 警告: 模块模板未定义!",
	["no substitution name given"] = "无特定置换名称",
	["no substitution name supplied for deletion"] = "没有删除部分的替换名称支持",
	["no user defined subs found"] = "未发现用户定义置换",
	["no value given for subtitution \"%s\""] = "置换 \"%s\"没有赋值",
	["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "移除用户定义的置换 \"%s\"; 以前扩展到=> \"%s\"",
	["subname -- NOTE: sub name without the prefix '%'"] = "置换名称 -- 注意: 置换名称无前缀 '%'",
	["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "置换名称 = 扩展后文本-- 注意: 置换名称无前缀 \"%\"",
	["substitution: %s defined as => %s"] = "替换: %s 定义为 => %s",
	["unknown sex"] = "未知性别",
	["user defined substition \"%s\" not found"] = "未发现用户定义替换\"%s\" ",
	["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "用户替换指数(子用户_索引) 不存在!哦,亲爱的.",
	usersub_ = "子用户_",
	["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "|cffff0000注意:|r 置换\"%s\"已定义为\"%s\",覆盖",
}

)
L:AddLocale("esES",  
{
	["%d total user defined substitutions"] = "Total de sustituciones definidas por el usuario %d",
	["<noguild>"] = "<sin hermandad>",
	["<notarget>"] = "<sin objetivo>",
	["A module to provide basic chat substitutions."] = "Un módulo que proporciona sustituciones básicas del chat.",
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "¿Está seguro - esto eliminará todas las sustituciones definidas por el usuario y restablece los valores predeterminados?",
	["Are you sure?"] = "¿Está seguro?",
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = [=[Valor actual: '%s'
Click para pegar en el chat.]=],
	["Delete all"] = "Eliminar todo",
	["Delete substitution"] = "Eliminar sustitución",
	["Deletes a user defined substitution"] = "Elimina una sustitución del usuario",
	["Deletes all user defined substitutions"] = "Elimina todas las sustituciones del usuario",
	["List of available substitutions"] = "Listado de sustituciones disponibles",
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Lista de sustituciones definidas por este módulo. (Nota: los usuarios pueden definir valores personalizados para las sustituciones, pero volverá al valor por defecto si la definición del usuario se suprime.)",
	["List substitutions"] = "Listado de sustituciones",
	["Lists all current subtitutions in the default chat frame"] = "Lista todas las sustituciones actuales en el marco de chat por defecto.",
	MapLoc = true,
	MapPos = true,
	MapXPos = true,
	MapYPos = true,
	MapZone = "MapZona",
	-- MouseoverTargetName = "",
	["NO MATCHFUNC FOUND"] = "SIN FUNCIONCOINCIDENCIAS ENCONTRADA",
	["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "Opciones para establecer y eliminar sustituciones definidas por el usuario. (Nota: los usuarios pueden definir valores personalizados para las sustituciones, pero volverán al valor por defecto si las definiciones del usuario son suprimidas.)",
	PlayerCurrentMana = "ManaActualJugador",
	PlayerHP = "VidaJugador",
	PlayerHealthDeficit = "DéficitSaludJugador",
	PlayerManaDeficit = "DéficitManaJugador",
	PlayerMaxHP = "VidaMaxJugador",
	PlayerMaxMana = "ManaMaxJugador",
	PlayerName = "NombreJugador",
	PlayerPercentHP = "PorcentVidaJugador",
	PlayerPercentMana = "PorcentManaJugador",
	RandNum = "NumAleat",
	["Set substitution"] = "Establecer sustitución",
	["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "Establecer el valor de una sustitución definida por el usuario (Nota: puede ser la misma que una sustitución predeterminada, para restablecerla a la predeterminada, sólo quitar la definición de usuario creada).",
	Substitutions = "Sustituciones",
	TargetClass = "ClaseObjetivo",
	TargetGender = "GéneroObjetivo",
	TargetGuild = "HermandadObjetivo",
	TargetHealth = "SaludObjetivo",
	TargetHealthDeficit = "DéficitSaludObjetivo",
	TargetIcon = "IconoObjetivo",
	TargetLevel = "NivelObjetivo",
	TargetManaDeficit = "DéficitManaObjetivo",
	TargetName = "NombreObjetivo",
	TargetPercentHP = "PorcentVidaObjetivo",
	TargetPossesive = "PosesiónObjetivo", -- Needs review
	TargetPronoun = "PronombreObjetivo",
	TargetRace = "RazaObjetivo",
	TargetTargetName = "ObjetivoObjetivoNombre",
	["User defined substitutions"] = "Sustituciones definidas por el usuario",
	["can't find substitution index for a substitution named '%s'"] = "No se encuentra el índice de sustitución para una sustitución con el nombre '%s'",
	["defined %s: expands to => %s"] = "definido %s: se expande a => %s",
	female = "Femenino",
	her = "ella",
	hers = "suya",
	him = "él",
	his = "suyo",
	-- it = "",
	-- its = "",
	male = "Masculino",
	["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "módulo: buildUserSubsIndex(): advertencia: ¡patrones del módulo no definidos!",
	["no substitution name given"] = "ningún nombre de sustitución dado",
	["no substitution name supplied for deletion"] = "ningún nombre de sustitución proporcionado para su eliminación",
	["no user defined subs found"] = "sustituciones definidas por el usuario no encontradas",
	["no value given for subtitution \"%s\""] = "ningún valor dado para sustitución \"%s\"",
	["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "Quitando sustitución definida por el usuario \"%s\"; anteriormente ampliada a => \"%s\"",
	["subname -- NOTE: sub name without the prefix '%'"] = "subnombre -- NOTA: sub nombre sin el prefijo '%'",
	["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "subnombre = texto después de expansión --NOTA: sub nombre sin el prefijo \"%\"",
	["substitution: %s defined as => %s"] = "sustitución: %s definido como => %s",
	["unknown sex"] = "Sexo desconocido",
	["user defined substition \"%s\" not found"] = "sustitución definida por el usuario \"%s\" no encontrada",
	["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "¡no existe un índice de sustituciones de usuario (usersubs_idx)!.",
	usersub_ = true, -- Needs review
	["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "|cffff0000advertencia:|r sustitución \"%s\" ya definida como \"%s\", sobrescribiendo",
}

)
L:AddLocale("zhTW",  
{
	-- ["%d total user defined substitutions"] = "",
	-- ["<noguild>"] = "",
	-- ["<notarget>"] = "",
	["A module to provide basic chat substitutions."] = "提供基本聊天標題的模組",
	["Are you sure - this will delete all user defined substitutions and reset defaults?"] = "你確定嗎 - 這將刪除所有使用者替換且重置至預設值？",
	["Are you sure?"] = "你確定嗎？",
	[ [=[Current value: '%s'
Click to paste into the chat.]=] ] = [=[當前值：%s
點擊以在聊天視窗中貼上]=],
	["Delete all"] = "刪除所有",
	["Delete substitution"] = "刪除標題",
	["Deletes a user defined substitution"] = "刪除一個由使用者自定義的標題",
	["Deletes all user defined substitutions"] = "刪除所有由使用者自定義的標題",
	["List of available substitutions"] = "可用標題清單",
	["List of available substitutions defined by this module. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "由此模組定義的可用標題之清單",
	["List substitutions"] = "標題清單",
	["Lists all current subtitutions in the default chat frame"] = "默認聊天框中所有現用標題清單",
	-- MapLoc = "",
	MapPos = "地圖位置",
	MapXPos = "地圖X軸",
	MapYPos = "地圖Y軸",
	MapZone = "地圖地區",
	-- MouseoverTargetName = "",
	-- ["NO MATCHFUNC FOUND"] = "",
	-- ["Options for setting and removing user defined substitutions. (NB: users may define custom values for existing substitutions, but they will revert to the default value if the user definition is deleted.)"] = "",
	PlayerCurrentMana = "玩家當前法力值",
	PlayerHP = "玩家生命值",
	-- PlayerHealthDeficit = "",
	-- PlayerManaDeficit = "",
	-- PlayerMaxHP = "",
	-- PlayerMaxMana = "",
	-- PlayerName = "",
	-- PlayerPercentHP = "",
	-- PlayerPercentMana = "",
	-- RandNum = "",
	-- ["Set substitution"] = "",
	-- ["Set the value of a user defined substitution (NB: this may be the same as an existing default substitution; to reset it to the default, just remove the user created definition)."] = "",
	-- Substitutions = "",
	TargetClass = "目標職業",
	-- TargetGender = "",
	-- TargetGuild = "",
	-- TargetHealth = "",
	-- TargetHealthDeficit = "",
	-- TargetIcon = "",
	-- TargetLevel = "",
	-- TargetManaDeficit = "",
	-- TargetName = "",
	-- TargetPercentHP = "",
	-- TargetPossesive = "",
	-- TargetPronoun = "",
	-- TargetRace = "",
	-- TargetTargetName = "",
	["User defined substitutions"] = "使用者自定義的替換",
	-- ["can't find substitution index for a substitution named '%s'"] = "",
	["defined %s: expands to => %s"] = "定義 %s：擴張至 => %s",
	female = "女性",
	her = "她",
	hers = "她的",
	him = "他",
	his = "他的",
	it = "它",
	its = "它的",
	male = "男性",
	-- ["module:buildUserSubsIndex(): warning: module patterns not defined!"] = "",
	-- ["no substitution name given"] = "",
	-- ["no substitution name supplied for deletion"] = "",
	-- ["no user defined subs found"] = "",
	-- ["no value given for subtitution \"%s\""] = "",
	-- ["removing user defined substitution \"%s\"; previously expanded to => \"%s\""] = "",
	-- ["subname -- NOTE: sub name without the prefix '%'"] = "",
	-- ["subname = text after expansion -- NOTE: sub name without the prefix \"%\""] = "",
	-- ["substitution: %s defined as => %s"] = "",
	["unknown sex"] = "未知的性別",
	["user defined substition \"%s\" not found"] = "未搜尋到使用者自定義替換 \"%s\"",
	["user substitutions index (usersubs_idx) doesn't exist! oh dear."] = "親愛的使用者自替換索引(usersubs_idx)並不存在。",
	usersub_ = true,
	-- ["|cffff0000warning:|r subtitution \"%s\" already defined as \"%s\", overwriting"] = "",
}

)
--@end-non-debug@




----Chinese Translate by Ananhaid(NovaLOG)@CWDG
----CWDG site: http://Cwowaddon.com

--

--

--

--

--

local module = Prat:NewModule(PRAT_MODULE)

Prat:SetModuleDefaults(module.name, {
	profile = {
		on		= false,
	}
})


local patternPlugins = { patterns={} }

Prat:SetModuleOptions(module.name, {
	name	= L["Substitutions"],
	desc	= L["A module to provide basic chat substitutions."],
	type	= 'group',
	plugins = patternPlugins,
	args = {}
	}
)

local function subDesc(info) return info.handler:GetSubstDescription(info) end


--[[------------------------------------------------
Core Functions
------------------------------------------------]]--
function module:OnModuleEnable()
	self:BuildModuleOptions(patternPlugins.patterns)
end

function module:BuildModuleOptions(args)
	local modulePatterns = Prat.GetModulePatterns(self)

	local order	= 500

	self.buildingMenu = true

	for k,v in pairs(modulePatterns) do
		local name	= v.optname
		local pat	= v.pattern:gsub("%%%%", "%%")

		order	= order + 10

		args[name] = args[name] or {}
		local d = args[name]

		d.name = name.." "..pat
		d.desc = subDesc
		d.type	= "execute"
		d.func	= "DoPat"
		d.order	= order
	end

	self.buildingMenu = false
end


function module:GetSubstDescription(info)
	local val = self:InfoToPattern(info)

	self.buildingMenu = true

	val = val and val.matchfunc and val.matchfunc() or L["NO MATCHFUNC FOUND"]	
	val = L["Current value: '%s'\nClick to paste into the chat."]:format("|cff80ff80"..tostring( val ).."|r"):gsub("%%%%", "%%")

	self.buildingMenu = false

	return val
end

function module:InfoToPattern(info)
	local modulePatterns = Prat.GetModulePatterns(self)
	local name = info[#info] or ""
	
	if modulePatterns then
		for k,v in pairs(modulePatterns) do
			if v.optname == name then
				return v
			end
		end
	end
end		

function  module:DoPat(info)
	local pat = self:InfoToPattern(info)
	pat = pat and pat.pattern or ""
	local e = ChatEdit_GetActiveWindow()
	if not e:IsVisible() then
		return
	end

	e:SetText((e:GetText() or "")..pat:gsub("[%(%)]", ""):gsub("%%%%", "%%"))
end

do
	local function prat_match(text)
		local text = text or ""
	
		if module.buildingMenu then
			return text
		end
	
		return Prat:RegisterMatch(text, "OUTBOUND")
	end
	
	local function Zone(...)
		return prat_match(GetZoneText())
	end
	
	local function Loc(...)
		return prat_match(GetMinimapZoneText())
	end
	
	local function Pos()
		local x,y = GetPlayerMapPosition("player")
		local str = "("..math.floor((x * 100) + 0.5)..","..math.floor((y * 100) + 0.5)..")"
		return prat_match(str)
	end
	
	local function Ypos()
		local x, y = GetPlayerMapPosition("player")
		local y = tostring(math.floor((y * 100) + 0.5))
		return prat_match(y)
	end
	
	local function Xpos()
		local x, y = GetPlayerMapPosition("player")
		local x = tostring(math.floor((x * 100) + 0.5))
		return prat_match(x)
	end
	
	local function PlayerHP(...)
		return prat_match(UnitHealth("player"))
	end
	
	local function PlayerMaxHP(...)
		return prat_match(UnitHealthMax("player"))
	end
	
	local function PlayerPercentHP()
		return prat_match(floor(100 * (UnitHealth("player") / UnitHealthMax("player"))))
	end
	
	local function PlayerHealthDeficit()
		return prat_match(UnitHealthMax("player") - UnitHealth("player"))
	end
	
	local function PlayerCurrentMana()
		return prat_match(UnitMana("player"))
	end
	
	local function PlayerMaxMana()
		return prat_match(UnitManaMax("player"))
	end
	
	local function PlayerPercentMana()
		return prat_match(string.format("%.0f%%%%",
		floor(100 * (UnitMana("player")/UnitManaMax("player")))))
	end
	
	local function PlayerManaDeficit()
		return prat_match(UnitManaMax("player") - UnitMana("player"))
	end
	
	
	
	local function TargetPercentHP()
		local str = L["<notarget>"]
		if UnitExists("target") then
			str = string.format("%.0f%%%%", floor(100 * (UnitHealth("target") / UnitHealthMax("target"))))
		end
	
		return prat_match(str)
	end
	
	local function TargetHealth()
		local str = L["<notarget>"]
		if UnitExists("target") then
			str = UnitHealth("target")
		end
	
		return prat_match(str)
	end
	
	local function TargetHealthDeficit()
		local str = L["<notarget>"]
		if UnitExists("target") then
			str = UnitHealthMax("target") - UnitHealth("target")
		end
	
		return prat_match(str)
	end
	
	local function TargetManaDeficit()
		local str = L["<notarget>"]
		if UnitExists("target") then
			str = UnitManaMax("target") - UnitMana("target")
		end
	
		return prat_match(str)
	end
	
	
	local function TargetClass()
		local class = L["<notarget>"]
		if UnitExists("target") then
			class = UnitClass("target")
		end
	
		return prat_match(class)
	end
	
	local raidiconpfx = ICON_TAG_RAID_TARGET_STAR1:sub(1,-2) or "rt"
	
	local function TargetIcon()
		local icon = ""
		if UnitExists("target") then
			local iconnum = GetRaidTargetIndex("target")
	
			if type(iconnum) ~= "nil" then
				icon = ("{%s%d}"):format(raidiconpfx, tostring(iconnum))
			end
		end
	
		return prat_match(icon)
	end
	
	
	local function TargetRace()
		local race = L["<notarget>"]
		if UnitExists("target") then
			if UnitIsPlayer("target") then
				race = UnitRace("target")
			else
				race = UnitCreatureFamily("target")
				if not race then
					race = UnitCreatureType("target")
				end
			end
		end
		return prat_match(race)
	end
	local function TargetGender()
		local sex = L["<notarget>"]
		if UnitExists("target") then
			s = UnitSex("target")
			if(s == 2) then
				sex = L["male"]
			elseif (s == 3) then
				sex = L["female"]
			else
				sex = L["unknown sex"]
			end
		end
	
		return prat_match(sex)
	end
	
	local function TargetLevel()
		local level = L["<notarget>"]
		if UnitExists("target") then
			level = UnitLevel("target")
		end
		return prat_match(level)
	end
	
	local function TargetGuild()
		local guild = L["<notarget>"]
		if UnitExists("target") then
			guild = L["<noguild>"]
			if IsInGuild("target") then
				guild = GetGuildInfo("target") or ""
			end
		end
		return prat_match(guild)
	end
	
	-- %tps (possesive)
	local function TargetPossesive()
		local p = L["<notarget>"]
		if UnitExists("target") then
			local s = UnitSex("target")
			if(s == 2) then
				p = L["his"]
			elseif (s == 3) then
				p = L["hers"]
			else
				p = L["its"]
			end
		end
	
		return prat_match(p)
	end
	
	-- %tpn (pronoun)
	local function TargetPronoun()
		local p = L["<notarget>"]
		if UnitExists("target") then
			local s = UnitSex("target")
			if(s == 2) then
				p = L["him"]
			elseif (s == 3) then
				p = L["her"]
			else
				p = L["it"]
			end
		end
		return prat_match(p)
	end
	
	-- %tn (target)
	local function TargetName()
		local t = L['<notarget>']
	
		if UnitExists("target") then
			t = UnitName("target")
		end
	
		return prat_match(t)
	end
	
	-- %tt (target)
	local function TargetTargetName()
		local t = L['<notarget>']
	
		if UnitExists("targettarget") then
			t = UnitName("targettarget")
		end
	
		return prat_match(t)
	end
	
	-- %mn (mouseover)
	local function MouseoverName() 
		local t = L['<notarget>']
	
		if UnitExists("mouseover") then
			t = UnitName("mouseover")
		end

		return prat_match(t)
	end

	-- %pn (player)
	local function PlayerName()
		local p = GetUnitName("player") or ""
		return prat_match(p)
	end
	
	local function Rand()
		return math.random(1, 100)
	end
	
	--[[
	* %tn = current target
	* %pn = player name
	* %hc = your current health
	* %hm = your max health
	* %hp = your percentage health
	* %hd = your current health deficit
	* %mc = your current mana
	* %mm = your max mana
	* %mp = your percentage mana
	* %md = your current mana deficit
	* %thp = target's percentage health
	* %th = target's current health
	* %td = target's health deficit
	* %tc = class of target
	* %tr = race of target
	* %ts = sex of target
	* %tl = level of target
	* %ti = raid icon of target
	* %tps = possesive for target (his/hers/its)
	* %tpn = pronoun for target (him/her/it)
	* %fhp = focus's percentage health
	* %fc = class of focus
	* %fr = race of focus
	* %fs = sex of focus
	* %fl = level of focus
	* %fps = possesive for focus (his/hers/its)
	* %fpn = pronoun for focus (him/her/it)
	* %tt = target of target
	* %zon = your current zone (Dun Morogh, Hellfire Peninsula, etc.)
	* %loc = your current subzone (as shown on the minimap)
	* %pos = your current coordinates (x,y)
	* %ypos = your current y coordinate
	* %xpos = your current x coordinate
	* %rnd = a random number between 1 and 100
	--]]
	
	Prat:SetModulePatterns(module, {
			{ pattern = "(%%thd)", matchfunc=TargetHealthDeficit, optname=L["TargetHealthDeficit"], type = "OUTBOUND"},
			{ pattern = "(%%thp)", matchfunc=TargetPercentHP, priority=51, optname=L["TargetPercentHP"],  type = "OUTBOUND"},
			{ pattern = "(%%tpn)", matchfunc=TargetPronoun, optname=L["TargetPronoun"],  type = "OUTBOUND"},
	
			{ pattern = "(%%hc)", matchfunc=PlayerHP, optname=L["PlayerHP"],  type = "OUTBOUND"},
			{ pattern = "(%%pn)", matchfunc=PlayerName, optname=L["PlayerName"], type = "OUTBOUND"},
			{ pattern = "(%%hm)", matchfunc=PlayerMaxHP, optname=L["PlayerMaxHP"],  type = "OUTBOUND"},
			{ pattern = "(%%hd)", matchfunc=PlayerHealthDeficit, optname=L["PlayerHealthDeficit"], type = "OUTBOUND"},
			{ pattern = "(%%hp)", matchfunc=PlayerPercentHP, optname=L["PlayerPercentHP"],  type = "OUTBOUND"},
			{ pattern = "(%%mc)", matchfunc=PlayerCurrentMana, optname=L["PlayerCurrentMana"],  type = "OUTBOUND"},
			{ pattern = "(%%mm)", matchfunc=PlayerMaxMana, optname=L["PlayerMaxMana"],  type = "OUTBOUND"},
			{ pattern = "(%%mp)", matchfunc=PlayerPercentMana, optname=L["PlayerPercentMana"],  type = "OUTBOUND"},
			{ pattern = "(%%pmd)", matchfunc=PlayerManaDeficit, optname=L["PlayerManaDeficit"], type = "OUTBOUND"},
	
			{ pattern = "(%%tn)", matchfunc=TargetName, optname=L["TargetName"], type = "OUTBOUND"},
			{ pattern = "(%%tt)", matchfunc=TargetTargetName, optname=L["TargetTargetName"], type = "OUTBOUND"},
			{ pattern = "(%%tc)", matchfunc=TargetClass, optname=L["TargetClass"], type = "OUTBOUND"},
			{ pattern = "(%%th)", matchfunc=TargetHealth, optname=L["TargetHealth"], type = "OUTBOUND"},
			{ pattern = "(%%tr)", matchfunc=TargetRace, optname=L["TargetRace"],  type = "OUTBOUND"},
			{ pattern = "(%%ts)", matchfunc=TargetGender, optname=L["TargetGender"],  type = "OUTBOUND"},
			{ pattern = "(%%ti)", matchfunc=TargetIcon, optname=L["TargetIcon"],  type = "OUTBOUND"},
			{ pattern = "(%%tl)", matchfunc=TargetLevel, optname=L["TargetLevel"],  type = "OUTBOUND"},
			{ pattern = "(%%tps)", matchfunc=TargetPossesive, optname=L["TargetPossesive"],  type = "OUTBOUND"},
			{ pattern = "(%%tmd)", matchfunc=TargetManaDeficit, optname=L["TargetManaDeficit"], type = "OUTBOUND"},
			{ pattern = "(%%tg)", matchfunc=TargetGuild, optname=L["TargetGuild"], type = "OUTBOUND"},
	
			{ pattern = "(%%mn)", matchfunc=MouseoverName, optname=L["MouseoverTargetName"], type = "OUTBOUND"},
	
			{ pattern = "(%%zon)", matchfunc=Zone, optname=L["MapZone"],  type = "OUTBOUND"},
			{ pattern = "(%%loc)", matchfunc=Loc, optname=L["MapLoc"],  type = "OUTBOUND"},
			{ pattern = "(%%pos)", matchfunc=Pos, optname=L["MapPos"],  type = "OUTBOUND"},
			{ pattern = "(%%ypos)", matchfunc=Ypos, optname=L["MapYPos"],  type = "OUTBOUND"},
			{ pattern = "(%%xpos)", matchfunc=Xpos, optname=L["MapXPos"],  type = "OUTBOUND"},
			{ pattern = "(%%rnd)", matchfunc=Rand, optname=L["RandNum"], type = "OUTBOUND"},
	
			--~	 { pattern = "(%%tn)", matchfunc=TargetName, optname="Target", type = "OUTBOUND"},
			--~	 { pattern = "(%%pn)", matchfunc=PlayerName, optname="Player", type = "OUTBOUND"}
			}
	
			--[[ TODO:
			%%fhp - focus health
			%%fr
			%%fc
			%%fs
			%%fl
			%%fvr
			%%fvn
			]]
		
	)
end


--function module:userSubIdx(subname)
--	if not subname then return false end
--
--	local usersubs_idx	= self.usersubs_idx or {}
--
--	if usersubs_idx[subname] then
--		return usersubs_idx[subname]
--	end
--
--	local tmpsubname
--
--	for idx, pattern in module.modulePatterns do
--		tmpsubname = pattern.optname:gsub('^user_', '')
--
--		if usersubs[tmpsubname] then
--			usersubs_idx[tmpsubname] = idx
--
--			return idx
--		end
--	end
--
--	return false
--end
--
--
--function module:addUserSubs()
--	self.usersubs_idx = {}
--
--	for subname, expandsto in pairs(self.db.profile.usersubs) do
--		local pattable = self:patternTable(subname, expandsto)
--
--		table.insert(self.modulePatterns, pattable)
--
--		self.usersubs_idx = pattable.idx
--	end
--end
--
--function module:buildUserSubsIndex()
--	local usersubs		= self.db.profile.usersubs
--	local modpats		= self.modulePatterns
--
--	self.usersubs_idx = {}
--
--	if not modpats then
--		self:print(L['module:buildUserSubsIndex(): warning: module patterns not defined!'])
--		return false
--	end
--
--	for idx, pattern in ipairs(modpats) do
--		local subname = pattern.optname:gsub('^user_', '')
--
--		if usersubs[subname] then
--			usersubs_idx[subname]				= idx
--			module.usersubs_idx[subname]	= idx
--		end
--	end
--
--	return usersubs_idx
--end


  return
end ) -- Prat:AddModuleToLoad