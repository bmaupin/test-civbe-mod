UPDATE Leaders
SET
  ArtDefineTag = 'Robots_Scene.xml'
WHERE Type = 'LEADER_CHUNGSU';

UPDATE Leader_Flavors
SET Flavor = 12
WHERE FlavorType = 'FLAVOR_SUPREMACY'
  AND LeaderType = 'LEADER_CHUNGSU';

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT 'LEADER_CHUNGSU', 'FLAVOR_SUPREMACY', 12
WHERE NOT EXISTS (
  SELECT LeaderType FROM Leader_Flavors
  WHERE LeaderType = 'LEADER_CHUNGSU'
  AND FlavorType = 'FLAVOR_SUPREMACY'
);

UPDATE Leaders
SET
  ArtDefineTag = 'Alien1_Scene.xml'
WHERE Type = 'LEADER_POLYSTRALIA';

UPDATE Leader_Flavors
SET Flavor = 12
WHERE FlavorType = 'FLAVOR_HARMONY'
  AND LeaderType = 'LEADER_POLYSTRALIA';

INSERT INTO Leader_Flavors (LeaderType, FlavorType, Flavor)
SELECT 'LEADER_POLYSTRALIA', 'FLAVOR_HARMONY', 12
WHERE NOT EXISTS (
  SELECT LeaderType FROM Leader_Flavors
  WHERE LeaderType = 'LEADER_POLYSTRALIA'
  AND FlavorType = 'FLAVOR_HARMONY'
);
