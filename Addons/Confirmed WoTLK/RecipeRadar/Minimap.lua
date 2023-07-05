
-- Minimap.lua: minimap vendor plotting code
-- $Id: Minimap.lua 1031 2008-03-27 05:41:46Z jnmiller $
-- Note: the mapping code in here is from MapNotes, by Sir.Bender, et al.

-- Initializes the state of the minimap overlays and settings.
function RecipeRadar_Minimap_Init()

   for i = 1, RECIPERADAR_MAPPED_VENDORS_MAX do
      local button = getglobal("RecipeRadarMinimapIcon" .. i)
      button.Elapsed = 0
      button:Hide()
   end

end

function RecipeRadar_Minimap_OnNewRegion()

   SetMapToCurrentZone()
   for i = 1, RECIPERADAR_MAPPED_VENDORS_MAX do
      local button = getglobal("RecipeRadarMinimapIcon" .. i)
      if (button.IsMapped and button.Region == GetRealZoneText()) then
         button:Show()
      else
         button:Hide()
      end
   end

end

-- Map the given icon to the given vendor.
function RecipeRadar_Minimap_AddVendor(id, vendor, region)

   local button = getglobal("RecipeRadarMinimapIcon" .. id)

   button.Vendor = vendor
   button.Region = region
   button.Elapsed = RECIPERADAR_MINIMAP_UPDATE
   button.IsMapped = true
   
   local Astrolabe = DongleStub("Astrolabe-0.4")
   local continent = RecipeRadar_RegionData[region].Continent
   Astrolabe:PlaceIconOnMinimap(button, continent,
         RecipeRadar_RegionNameToID(region, continent),
         vendor.Coordinates[1].x, vendor.Coordinates[1].y)

end

-- Resets and unmaps the given icon.
function RecipeRadar_Minimap_RemoveVendor(id)

   local button = getglobal("RecipeRadarMinimapIcon" .. id)

   button.Vendor = nil
   button.Region = nil
   button.IsMapped = false
   
   local Astrolabe = DongleStub("Astrolabe-0.4")
   Astrolabe:RemoveIconFromMinimap(button)

end
