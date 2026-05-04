-- Enable Skirmish in setup screens; modifying the map script directly doesn't seem to
-- update SupportsSinglePlayer/SupportsMultiplayer in the database
UPDATE MapScripts
SET SupportsSinglePlayer = 1,
    SupportsMultiplayer = 1
WHERE lower(FileName) = 'assets\maps\skirmish.lua';

-- Hide water-heavy maps
UPDATE MapScripts
SET SupportsSinglePlayer = 0,
    SupportsMultiplayer = 0
WHERE lower(FileName) IN (
  'assets\maps\archipelago.lua',
  'assets\maps\inland_sea.lua',
  'assets\maps\tiny_islands.lua',
--   'assets\maps\atlantean.lua',
--   'assets\maps\protean.lua',
--   'assets\maps\terran.lua',
  'assets\dlc\dlc_sp_maps\maps\oceania.lua'
);
