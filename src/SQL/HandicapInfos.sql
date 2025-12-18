-- Apollo gives all AI one free affinity level for all affinities, which we don't want
-- since this mod is based on each faction having only one affinity.
UPDATE HandicapInfos SET AIFreeAffinityLevel = 0;