-- If Mini Beyond Earth is installed, remove the Auto Upgrade Units game option
DELETE FROM GameOptions
WHERE Type = 'GAMEOPTION_AUTO_UPGRADE_UNITS';
