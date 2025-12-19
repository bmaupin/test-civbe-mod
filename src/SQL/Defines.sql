-- This is the percentage of max affinity at which the game will start comparing
-- affinities in order to determine if AI factions should give a negative reaction and
-- decrease respect. The default value is 25, and max affinity is 18, so that's affinity
-- level 4.5. There's an 'aligned' value as well but I'm not sure if it's actually used.
UPDATE Defines
-- 10 is affinity level ~2
SET Value = 10
WHERE Name IN
(
  'OPINION_WEIGHT_AFFINITY_ALIGNED_MIN_PERCENT_TOWARDS_MAX_LEVEL',
  'OPINION_WEIGHT_AFFINITY_DIFFERS_MIN_PERCENT_TOWARDS_MAX_LEVEL'
);
