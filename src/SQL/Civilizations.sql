-- TODO: (Delete this) make ARC the robot faction for MVP
UPDATE Civilizations
SET
  Playable = 0
WHERE Type = 'CIVILIZATION_ARC';

-- TODO: Delete, put in a separate file
UPDATE Leaders
SET
  ArtDefineTag = 'Robots_Scene.xml'
WHERE Type = 'LEADER_ARC';
