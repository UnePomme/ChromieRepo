--[[ ---------------------------------------------------------------------------
Name:	SimpleUnitFrames
Author:	Pneumatus
About:	An extension to the default WoW Unit Frames. Rather than a complete 
		unitframe replacement, this addon adds further information and features
		to the existing frames and allows a greater degree of customization to 
		enhance their usability.
----------------------------------------------------------------------------- ]]

local SUF = LibStub("AceAddon-3.0"):GetAddon("SimpleUnitFrames")
local L = LibStub("AceLocale-3.0"):GetLocale("SimpleUnitFrames")
local TO = SUF:GetModule("TextOverlay")
local CS = SUF:NewModule("CustomStyle")

CS.customStyles = {
	[0] = L["Select a style to edit"],
}

local selectedStyle = 0

SUF.defaults.global.customstyle = {}

SUF.options.args.customstyle = {
	type = 'group',
	name = L["Custom Text Style"],
	args = {
		new = {
			type = 'execute',
			name = L["New Style"],
			desc = L["Create a new Custom Style"],
			func = function(info)
				local i = #CS.customStyles + 1
				CS.customStyles[i] = "Temp Style Name "..i
				SUF.db.global.customstyle[i] = {
					type = "HP",
					desc = "Temp Style Name "..i,
					dt = "",
				}
				info.handler.options.args.customstyle.args.stylebox.name = CS.customStyles[i]
				info.handler.options.args.customstyle.args.stylebox.hidden = false
				selectedStyle = i
			end,
		},
		selctor = {
			type = 'select',
			name = L["Edit Style"],
			desc = L["Select a style to edit"],
			get = function(info) return 0 end,
			set = function(info, val)
				info.handler.options.args.customstyle.args.stylebox.name = CS.customStyles[val]
				info.handler.options.args.customstyle.args.stylebox.hidden = false
				selectedStyle = val
			end,
			values = CS.customStyles,
			order = 110,
		},
		stylebox = {
			type = 'group',
			name = "",
			args = {
				desc = {
					type = 'input',
					name = L["Style Description"],
					desc = L["Descriptive name for the style, used in style dropdowns"],
					get = function(info) 
						return info.handler.db.global.customstyle[selectedStyle].desc
					end,
					set = function(info, val)
						TO.formatList[info.handler.db.global.customstyle[selectedStyle].type][tostring(selectedStyle)] = val
						CS.customStyles[selectedStyle] = val
						info.handler.db.global.customstyle[selectedStyle].desc = val
						info.handler.options.args.customstyle.args.stylebox.name = val
					end,
					order = 100,
				},
				type = {
					type = 'select',
					name = L["Style Type"],
					desc = L["Type of style, making it specific to either HP or MP dropdowns"],
					get = function(info)
						return info.handler.db.global.customstyle[selectedStyle].type
					end,
					set = function(info, val)
						TO.formatList[info.handler.db.global.customstyle[selectedStyle].type][tostring(selectedStyle)] = nil
						TO.formatList[val][tostring(selectedStyle)] = info.handler.db.global.customstyle[selectedStyle].desc
						info.handler.db.global.customstyle[selectedStyle].type = val
					end,
					values = { HP = L["HP"], MP = L["MP"], MPD = L["MP (Druid)"] },
					order = 110,
				},
				dt = {
					type = 'input',
					name = L["DogTag String"],
					desc = L["Style string in DogTag format. Use /dog for full info"],
					get = function(info)
						return info.handler.db.global.customstyle[selectedStyle].dt
					end,
					set = function(info, val)
						TO.activeStyles[tostring(selectedStyle)] = val
						info.handler.db.global.customstyle[selectedStyle].dt = val
						TO:RefreshFontStrings()
					end,
					order = 120,
				},
				del = {
					type = 'execute',
					name = L["Delete"],
					desc = L["Delete this style"],
					func = function(info)
						CS.customStyles[selectedStyle] = nil
						TO.activeStyles[tostring(selectedStyle)] = nil
						TO.formatList[info.handler.db.global.customstyle[selectedStyle].type][tostring(selectedStyle)] = nil
						info.handler.db.global.customstyle[selectedStyle] = nil
						info.handler.options.args.customstyle.args.stylebox.hidden = true
						TO:RefreshFontStrings()
					end,
					order = 130,
				},
			},
			hidden = true,
			inline = true,
			order = 120,
		}
	},
	order = 105,
}

function CS:OnInitialize()
	for k, v in pairs(SUF.db.global.customstyle) do
		self.customStyles[k] = v.desc
		TO.activeStyles[tostring(k)] = v.dt
		TO.formatList[v.type][tostring(k)] = v.desc
	end
end

function CS:OnEnable()
end

function CS:OnDisable()
end
