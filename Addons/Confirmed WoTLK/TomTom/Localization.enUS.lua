--Localization.enUS.lua

TomTomLocals = {
}

setmetatable(TomTomLocals, {__index=function(t,k) rawset(t, k, k); return k; end})
