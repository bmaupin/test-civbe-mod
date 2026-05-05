UPDATE Civilizations
SET
    Description = 'TXT_KEY_CIV_ROBOT3_DESC',
    ShortDescription = 'TXT_KEY_CIV_ROBOT3_SHORT_DESC',
    Adjective = 'TXT_KEY_CIV_ROBOT3_ADJECTIVE'
WHERE Type = 'CIVILIZATION_ARC';



UPDATE Civilizations
SET
    Description = 'TXT_KEY_CIV_ROBOT1_DESC',
    ShortDescription = 'TXT_KEY_CIV_ROBOT1_SHORT_DESC',
    Adjective = 'TXT_KEY_CIV_ROBOT1_ADJECTIVE'
WHERE Type = 'CIVILIZATION_CHUNGSU';



UPDATE Civilizations
SET
    Description = 'TXT_KEY_CIV_ALIEN3_DESC',
    ShortDescription = 'TXT_KEY_CIV_ALIEN3_SHORT_DESC',
    Adjective = 'TXT_KEY_CIV_ALIEN3_ADJECTIVE'
WHERE Type = 'CIVILIZATION_FRANCO_IBERIA';



UPDATE Civilizations
SET
    Description = 'TXT_KEY_CIV_ROBOT2_DESC',
    ShortDescription = 'TXT_KEY_CIV_ROBOT2_SHORT_DESC',
    Adjective = 'TXT_KEY_CIV_ROBOT2_ADJECTIVE'
WHERE Type = 'CIVILIZATION_INTEGR';



UPDATE Civilizations
SET
    Description = 'TXT_KEY_CIV_ALIEN1_DESC',
    ShortDescription = 'TXT_KEY_CIV_ALIEN1_SHORT_DESC',
    Adjective = 'TXT_KEY_CIV_ALIEN1_ADJECTIVE'
WHERE Type = 'CIVILIZATION_POLYSTRALIA';



UPDATE Civilizations
SET
    Description = 'TXT_KEY_CIV_ALIEN2_DESC',
    ShortDescription = 'TXT_KEY_CIV_ALIEN2_SHORT_DESC',
    Adjective = 'TXT_KEY_CIV_ALIEN2_ADJECTIVE'
WHERE Type = 'CIVILIZATION_RUSSIA';



-- TODO: Make alien civilisations unplayable for now
UPDATE Civilizations
SET
  AIPlayable = 0,
  Playable = 0
WHERE Type = 'CIVILIZATION_FRANCO_IBERIA'
  OR Type = 'CIVILIZATION_POLYSTRALIA'
  OR Type = 'CIVILIZATION_RUSSIA';


-- Disable planetary survey for all civs; it only has water-related features
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, 'TECH_PLANETARY_SURVEY'
FROM Civilizations
WHERE Civilizations.Playable = 1;


-- Prevent non-alien factions from researching harmony techs
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
WHERE Civilizations.Playable = 1
  AND Civilizations.Type NOT IN
  (
    'CIVILIZATION_FRANCO_IBERIA',
    'CIVILIZATION_POLYSTRALIA',
    'CIVILIZATION_RUSSIA'
  )
  AND AffinityType = 'AFFINITY_TYPE_HARMONY'
  AND AffinityValue >= 20;

-- Prevent non-human factions from researching purity techs
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
WHERE Civilizations.Playable = 1
  AND Civilizations.Type NOT IN
  (
    'CIVILIZATION_AFRICAN_UNION',
    'CIVILIZATION_BRASILIA',
    'CIVILIZATION_PAN_ASIA',
    'CIVILIZATION_KAVITHAN',
    'CIVILIZATION_AL_FALAH',
    'CIVILIZATION_NORTH_SEA_ALLIANCE'
  )
  AND AffinityType = 'AFFINITY_TYPE_PURITY'
  AND AffinityValue >= 20;

-- Prevent non-robot factions from researching supremacy techs
INSERT INTO Civilization_DisableTechs (CivilizationType, TechType)
SELECT Civilizations.Type, Technology_Affinities.TechType
FROM Civilizations
CROSS JOIN Technology_Affinities
WHERE Civilizations.Playable = 1
  AND Civilizations.Type NOT IN
  (
    'CIVILIZATION_ARC',
    'CIVILIZATION_INTEGR',
    'CIVILIZATION_CHUNGSU'
  )
  AND AffinityType = 'AFFINITY_TYPE_SUPREMACY'
  AND AffinityValue >= 20;
