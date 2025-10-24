-- Prevent human players from being able to research supremacy technologies
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
-- The default is 1 so explicitly check against 0 in case it's null, e.g. in another mod
WHERE Civilizations.Playable != 0
  AND AffinityType = 'AFFINITY_TYPE_SUPREMACY'
  AND AffinityValue > 0;