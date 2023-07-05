
-- Worldmap.lua: worldmap vendor plotting code
-- $Id: Worldmap.lua 1031 2008-03-27 05:41:46Z jnmiller $

-- Initializes the state of the worldmap overlays and settings.
function RecipeRadar_Worldmap_Init()

   for i = 1, RECIPERADAR_MAPPED_VENDORS_MAX do
      getglobal("RecipeRadarWorldmapIcon" .. i):Hide()
   end
   
end

-- Map the given icon to the given vendor.
function RecipeRadar_Worldmap_AddVendor(id, vendor, region, continent)

   local button = getglobal("RecipeRadarWorldmapIcon" .. id)
   button.Vendor = vendor
   button.Continent = continent
   button.RegionID = RecipeRadar_RegionNameToID(region, continent)
   button.IsMapped = true

   RecipeRadar_Worldmap_UpdateButton(button)
   
end

-- Resets and unmaps the given icon.
function RecipeRadar_Worldmap_RemoveVendor(id)

   local button = getglobal("RecipeRadarWorldmapIcon" .. id)
   button.Vendor = nil
   button.RegionID = nil
   button.Continent = nil
   button.IsMapped = false
   button:Hide()

end

-- Draw the supplied button on the world map.
function RecipeRadar_Worldmap_UpdateButton(button)

   local Astrolabe = DongleStub("Astrolabe-0.4")
   Astrolabe:PlaceIconOnWorldMap(getglobal("WorldMapDetailFrame"),
         button, button.Continent, button.RegionID,
         button.Vendor.Coordinates[1].x, button.Vendor.Coordinates[1].y)

end

-- Redraw buttons on the current world map.
function RecipeRadar_Worldmap_UpdateButtons()

   for i = 1, RECIPERADAR_MAPPED_VENDORS_MAX do
      local button = getglobal("RecipeRadarWorldmapIcon" .. i)
      if (button.IsMapped) then
         RecipeRadar_Worldmap_UpdateButton(button)
      end
   end

end
