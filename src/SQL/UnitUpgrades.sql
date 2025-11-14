-- Effectively disable tier 3 and 4 upgrades by setting affinity requirements to an
-- unattainable level; deleting upgrades causes a crash so this is an alternative
-- approach.
UPDATE UnitUpgrades
SET
  HarmonyLevel = 99
WHERE (
    Type LIKE '%_2%'
    OR Type LIKE '%_3%'
  )
  AND HarmonyLevel >= 1;

UPDATE UnitUpgrades
SET
  PurityLevel = 99
WHERE (
    Type LIKE '%_2%'
    OR Type LIKE '%_3%'
  )
  AND PurityLevel >= 1;

UPDATE UnitUpgrades
SET
  SupremacyLevel = 99
WHERE (
    Type LIKE '%_2%'
    OR Type LIKE '%_3%'
  )
  AND SupremacyLevel >= 1;
