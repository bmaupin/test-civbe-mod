-- TODO: (Delete this) make ARC the robot faction for MVP
UPDATE Civilizations
SET
  Playable = 0
WHERE Type = 'CIVILIZATION_ARC';