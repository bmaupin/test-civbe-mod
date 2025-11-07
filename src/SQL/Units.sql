INSERT INTO Civilization_UnitClassOverrides (CivilizationType, UnitClassType, UnitType)
VALUES
  -- TODO: Add remaining civilisations
  ('CIVILIZATION_ARC', 'UNIT_RANGED_MARINE', 'UNIT_GELIOPOD'),
  ('CIVILIZATION_BRASILIA', 'UNITCLASS_GELIOPOD', NULL);

-- These quests have hard-coded references to UNIT_MARINE
DELETE FROM Quests
WHERE Type IN ('QUEST_AN_ELEMENTAL_FATE', 'QUEST_FOUND_OUTPOST', 'QUEST_PAY_DAY', 'QUEST_THE_BEATING_HEART_SOCIETY');

UPDATE Units
SET Combat = (SELECT Combat FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    RangedCombat = (SELECT RangedCombat FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Cost = (SELECT Cost FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    -- TODO
    -- PrereqTech = (SELECT PrereqTech FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    PrereqTech = NULL,
    Description = (SELECT Description FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Civilopedia = (SELECT Civilopedia FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Help = (SELECT Help FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Moves = (SELECT Moves FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Range = (SELECT Range FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    -- Which promotions (not upgrades) unit is eligible for
    CombatClass = (SELECT CombatClass FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    DefaultUnitAI = (SELECT DefaultUnitAI FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    IgnoreBuildingDefense = (SELECT IgnoreBuildingDefense FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    AdvancedStartCost = (SELECT AdvancedStartCost FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Invisibility = (SELECT Invisibility FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Conscription = (SELECT Conscription FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    -- Movement cost, etc.
    MoveRate = (SELECT MoveRate FROM Units WHERE Type = 'UNIT_RANGED_MARINE')
WHERE Type = 'UNIT_GELIOPOD';

DELETE FROM Unit_AffinityPrereqs
WHERE UnitType = 'UNIT_GELIOPOD';

DELETE FROM Unit_Flavors
WHERE UnitType = 'UNIT_GELIOPOD';

INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT 'UNIT_GELIOPOD', FlavorType, Flavor
FROM Unit_Flavors
WHERE UnitType = 'UNIT_RANGED_MARINE';

DELETE FROM Unit_ResourceQuantityRequirements
WHERE UnitType = 'UNIT_GELIOPOD';
