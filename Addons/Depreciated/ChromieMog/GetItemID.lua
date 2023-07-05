--Credit to SnorlaxHF for the base macro
--https://www.ownedcore.com/forums/world-of-warcraft/world-of-warcraft-guides/219114-guide-find-itemid-of-any-item.html
SLASH_CHROMIEMOG1="/chromiemog"
SLASH_CHROMIEMOG2="/cm"
SLASH_CHROMIEMOG3="/itemid"
SlashCmdList["CHROMIEMOG"]=function(msg)
    local _,link=GetItemInfo(msg)
    if link
    then ChatFrame1:AddMessage(
        msg .. " has item ID: " ..
        link:match("item:(%d+):")
    )
    end
end