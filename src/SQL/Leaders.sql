UPDATE Leaders
SET
  AffinityDevotion = 12,
  AntiAlien = 12,
  WarmongerHate = 0
WHERE Type != 'LEADER_ALIEN';

-- Remove all condemnation biases by default
UPDATE Leader_CondemnationBiases
SET Bias = 0
WHERE LeaderType != 'LEADER_ALIEN';

UPDATE Leader_Flavors
SET Flavor = CASE FlavorType
  -- AI should build equal numbers of offence and defence units
  WHEN 'FLAVOR_DEFENSE' THEN 8
  WHEN 'FLAVOR_EXPANSION' THEN 8
  WHEN 'FLAVOR_OFFENSE' THEN 8
  -- Science is super important; set to max for everybody
  WHEN 'FLAVOR_SCIENCE' THEN 12
  ELSE Flavor
END
WHERE LeaderType != 'LEADER_ALIEN';



UPDATE Leaders
SET
  Description = 'TXT_KEY_LEADER_ROBOT3_DESC'
WHERE Type = 'LEADER_ARC';



UPDATE Leaders
SET
  ArtDefineTag = 'Robot1_Scene.xml',
  Description = 'TXT_KEY_LEADER_ROBOT1_DESC',
  IconAtlas = 'ROBOT1_LEADER_ATLAS',
  PortraitIndex = 0,
  Chattiness = 5,
  CoopWillingness = 0,
  Meanness = 12,
  Neediness = 0
WHERE Type = 'LEADER_CHUNGSU';

-- https://civilization.fandom.com/wiki/AI_trait_(Civ5)
-- https://forums.civfanatics.com/threads/community-ideas-diplomacy-flavors-for-ai-leaders.666737/
UPDATE Leader_MajorCivApproachBiases
SET Bias = CASE MajorCivApproachType
  WHEN 'MAJOR_CIV_APPROACH_AFRAID' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_DECEPTIVE' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_FRIENDLY' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_GUARDED' THEN 8
  WHEN 'MAJOR_CIV_APPROACH_HOSTILE' THEN 12
  WHEN 'MAJOR_CIV_APPROACH_NEUTRAL' THEN 4
  ELSE Bias
END
WHERE LeaderType = 'LEADER_CHUNGSU';



UPDATE Leaders
SET
  Description = 'TXT_KEY_LEADER_ALIEN3_DESC',
  AntiAlien = 0
WHERE Type = 'LEADER_FRANCO_IBERIA';

UPDATE Leader_CondemnationBiases
SET Bias = 12
WHERE LeaderType = 'LEADER_FRANCO_IBERIA'
  AND CondemnationType = 'CONDEMNATION_ALIEN_APPROACH';



UPDATE Leaders
SET
  ArtDefineTag = 'Robot2_Scene.xml',
  Description = 'TXT_KEY_LEADER_ROBOT2_DESC',
  IconAtlas = 'ROBOT2_LEADER_ATLAS',
  PortraitIndex = 0,
  Chattiness = 0,
  CoopWillingness = 0,
  Neediness = 0
WHERE Type = 'LEADER_INTEGR';

UPDATE Leader_MajorCivApproachBiases
SET Bias = CASE MajorCivApproachType
  WHEN 'MAJOR_CIV_APPROACH_AFRAID' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_DECEPTIVE' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_FRIENDLY' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_GUARDED' THEN 8
  WHEN 'MAJOR_CIV_APPROACH_HOSTILE' THEN 4
  WHEN 'MAJOR_CIV_APPROACH_NEUTRAL' THEN 12
  ELSE Bias
END
WHERE LeaderType = 'LEADER_INTEGR';



UPDATE Leaders
SET
  ArtDefineTag = 'Alien1_Scene.xml',
  Description = 'TXT_KEY_LEADER_ALIEN1_DESC',
  IconAtlas = 'ALIEN1_LEADER_ATLAS',
  PortraitIndex = 0,
  AntiAlien = 0,
  Chattiness = 0,
  CoopWillingness = 0,
  Neediness = 0
WHERE Type = 'LEADER_POLYSTRALIA';

UPDATE Leader_MajorCivApproachBiases
SET Bias = CASE MajorCivApproachType
  WHEN 'MAJOR_CIV_APPROACH_AFRAID' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_DECEPTIVE' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_FRIENDLY' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_GUARDED' THEN 8
  WHEN 'MAJOR_CIV_APPROACH_HOSTILE' THEN 4
  WHEN 'MAJOR_CIV_APPROACH_NEUTRAL' THEN 12
  ELSE Bias
END
WHERE LeaderType = 'LEADER_POLYSTRALIA';

UPDATE Leader_CondemnationBiases
SET Bias = 12
WHERE LeaderType = 'LEADER_POLYSTRALIA'
  AND CondemnationType = 'CONDEMNATION_ALIEN_APPROACH';



UPDATE Leaders
SET
  ArtDefineTag = 'Alien2_Scene.xml',
  Description = 'TXT_KEY_LEADER_ALIEN2_DESC',
  IconAtlas = 'ALIEN2_LEADER_ATLAS',
  PortraitIndex = 0,
  AntiAlien = 0,
  Chattiness = 0,
  CoopWillingness = 0,
  Neediness = 0
WHERE Type = 'LEADER_RUSSIA';

UPDATE Leader_MajorCivApproachBiases
SET Bias = CASE MajorCivApproachType
  WHEN 'MAJOR_CIV_APPROACH_AFRAID' THEN 0
  WHEN 'MAJOR_CIV_APPROACH_DECEPTIVE' THEN 7
  WHEN 'MAJOR_CIV_APPROACH_FRIENDLY' THEN 2
  WHEN 'MAJOR_CIV_APPROACH_GUARDED' THEN 6
  WHEN 'MAJOR_CIV_APPROACH_HOSTILE' THEN 12
  WHEN 'MAJOR_CIV_APPROACH_NEUTRAL' THEN 3
  ELSE Bias
END
WHERE LeaderType = 'LEADER_RUSSIA';

UPDATE Leader_CondemnationBiases
SET Bias = 12
WHERE LeaderType = 'LEADER_RUSSIA'
  AND CondemnationType = 'CONDEMNATION_ALIEN_APPROACH';




DELETE FROM Leader_Flavors
WHERE LeaderType != 'LEADER_ALIEN'
  AND FlavorType IN (
    'FLAVOR_EMANCIPATION',
    'FLAVOR_HARMONY',
    'FLAVOR_PROMISED_LAND',
    'FLAVOR_PURITY',
    'FLAVOR_SUPREMACY',
    'FLAVOR_TRANSCENDENCE'
  );

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT
  leaders.LeaderType,
  flavours.FlavorType,
  flavours.Flavor
FROM (
  SELECT 'LEADER_ARC' AS LeaderType UNION ALL
  SELECT 'LEADER_CHUNGSU' AS LeaderType UNION ALL
  SELECT 'LEADER_INTEGR' AS LeaderType
) AS leaders
CROSS JOIN (
  SELECT 'FLAVOR_EMANCIPATION' AS FlavorType, 9 AS Flavor UNION ALL
  SELECT 'FLAVOR_HARMONY' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_PROMISED_LAND' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_PURITY' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_SUPREMACY' AS FlavorType, 12 AS Flavor UNION ALL
  SELECT 'FLAVOR_TRANSCENDENCE' AS FlavorType, -2 AS Flavor
) AS flavours;

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT
  leaders.LeaderType,
  flavours.FlavorType,
  flavours.Flavor
FROM (
  SELECT 'LEADER_FRANCO_IBERIA' AS LeaderType UNION ALL
  SELECT 'LEADER_POLYSTRALIA' AS LeaderType UNION ALL
  SELECT 'LEADER_RUSSIA' AS LeaderType
) AS leaders
CROSS JOIN (
  SELECT 'FLAVOR_EMANCIPATION' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_HARMONY' AS FlavorType, 12 AS Flavor UNION ALL
  SELECT 'FLAVOR_PROMISED_LAND' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_PURITY' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_SUPREMACY' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_TRANSCENDENCE' AS FlavorType, 9 AS Flavor
) AS flavours;

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT
  leaders.LeaderType,
  flavours.FlavorType,
  flavours.Flavor
FROM (
  SELECT 'LEADER_AFRICAN_UNION' AS LeaderType UNION ALL
  SELECT 'LEADER_AL_FALAH' AS LeaderType UNION ALL
  SELECT 'LEADER_BRASILIA' AS LeaderType UNION ALL
  SELECT 'LEADER_INDIA' AS LeaderType UNION ALL
  SELECT 'LEADER_NORTH_SEA_ALLIANCE' AS LeaderType UNION ALL
  SELECT 'LEADER_PAN_ASIA' AS LeaderType
) AS leaders
CROSS JOIN (
  SELECT 'FLAVOR_EMANCIPATION' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_HARMONY' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_PROMISED_LAND' AS FlavorType, 9 AS Flavor UNION ALL
  SELECT 'FLAVOR_PURITY' AS FlavorType, 12 AS Flavor UNION ALL
  SELECT 'FLAVOR_SUPREMACY' AS FlavorType, -2 AS Flavor UNION ALL
  SELECT 'FLAVOR_TRANSCENDENCE' AS FlavorType, -2 AS Flavor
) AS flavours;
