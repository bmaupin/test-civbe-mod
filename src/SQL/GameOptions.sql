DELETE FROM GameOptions
WHERE Type = 'GAMEOPTION_ALL_ADJACENT_OR_WATER_STARTS'
  OR Type = 'GAMEOPTION_ALL_IN_WATER_STARTS'
  -- If Mini Beyond Earth is installed, remove the Auto Upgrade Units game option
  OR Type = 'GAMEOPTION_AUTO_UPGRADE_UNITS';
