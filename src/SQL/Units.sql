INSERT INTO Civilization_UnitClassOverrides (CivilizationType, UnitClassType, UnitType)
VALUES
  -- TODO: Add remaining units
  -- Robots
  ('CIVILIZATION_ARC', 'UNIT_RANGED_MARINE', 'UNIT_GELIOPOD'),
  ('CIVILIZATION_ARC', 'UNIT_MARINE', 'UNIT_NANOHIVE'),
  ('CIVILIZATION_INTEGR', 'UNIT_RANGED_MARINE', 'UNIT_GELIOPOD'),
  ('CIVILIZATION_INTEGR', 'UNIT_MARINE', 'UNIT_NANOHIVE'),
  ('CIVILIZATION_CHUNGSU', 'UNIT_RANGED_MARINE', 'UNIT_GELIOPOD'),
  ('CIVILIZATION_CHUNGSU', 'UNIT_MARINE', 'UNIT_NANOHIVE'),
  -- Aliens
  ('CIVILIZATION_FRANCO_IBERIA', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_FRANCO_IBERIA', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_POLYSTRALIA', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_POLYSTRALIA', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_RUSSIA', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_RUSSIA', 'UNITCLASS_NANOHIVE', NULL),
  -- Humans
  ('CIVILIZATION_AFRICAN_UNION', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_AFRICAN_UNION', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_BRASILIA', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_BRASILIA', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_PAN_ASIA', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_PAN_ASIA', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_KAVITHAN', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_KAVITHAN', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_AL_FALAH', 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_AL_FALAH', 'UNITCLASS_NANOHIVE', NULL),
  ('CIVILIZATION_NORTH_SEA_ALLIANCE' 'UNITCLASS_GELIOPOD', NULL),
  ('CIVILIZATION_NORTH_SEA_ALLIANCE' 'UNITCLASS_NANOHIVE', NULL),
  -- TODO
  ('CIVILIZATION_BRASILIA', 'UNITCLASS_MARINE', 'UNIT_HUMAN_SOLDIER');

-- TODO: Delete quests that reference other units we modify
-- These quests have hard-coded references to UNIT_MARINE
DELETE FROM Quests
WHERE Type IN ('QUEST_AN_ELEMENTAL_FATE', 'QUEST_FOUND_OUTPOST', 'QUEST_PAY_DAY', 'QUEST_THE_BEATING_HEART_SOCIETY');

-- Robots: Use Nanohive as soldier replacement
UPDATE Units
SET Combat = (SELECT Combat FROM Units WHERE Type = 'UNIT_MARINE'),
    RangedCombat = (SELECT RangedCombat FROM Units WHERE Type = 'UNIT_MARINE'),
    Cost = (SELECT Cost FROM Units WHERE Type = 'UNIT_MARINE'),
    PrereqTech = (SELECT PrereqTech FROM Units WHERE Type = 'UNIT_MARINE'),
    -- TODO
    -- Description = (SELECT Description FROM Units WHERE Type = 'UNIT_MARINE'),
    -- Civilopedia = (SELECT Civilopedia FROM Units WHERE Type = 'UNIT_MARINE'),
    -- Help = (SELECT Help FROM Units WHERE Type = 'UNIT_MARINE'),
    Description = 'TXT_KEY_UNIT_ROBOT_SOLDIER',
    Civilopedia = 'TXT_KEY_UNIT_ROBOT_SOLDIER_PEDIA',
    Help = 'TXT_KEY_UNIT_ROBOT_SOLDIER_HELP',
    Moves = (SELECT Moves FROM Units WHERE Type = 'UNIT_MARINE'),
    Range = (SELECT Range FROM Units WHERE Type = 'UNIT_MARINE'),
    -- Which promotions (not upgrades) unit is eligible for
    CombatClass = (SELECT CombatClass FROM Units WHERE Type = 'UNIT_MARINE'),
    DefaultUnitAI = (SELECT DefaultUnitAI FROM Units WHERE Type = 'UNIT_MARINE'),
    IgnoreBuildingDefense = (SELECT IgnoreBuildingDefense FROM Units WHERE Type = 'UNIT_MARINE'),
    AdvancedStartCost = (SELECT AdvancedStartCost FROM Units WHERE Type = 'UNIT_MARINE'),
    Invisibility = (SELECT Invisibility FROM Units WHERE Type = 'UNIT_MARINE'),
    Conscription = (SELECT Conscription FROM Units WHERE Type = 'UNIT_MARINE'),
    -- Movement cost, etc.
    MoveRate = (SELECT MoveRate FROM Units WHERE Type = 'UNIT_MARINE')
WHERE Type = 'UNIT_NANOHIVE';

DELETE FROM Unit_AffinityPrereqs
WHERE UnitType = 'UNIT_NANOHIVE';

DELETE FROM Unit_Flavors
WHERE UnitType = 'UNIT_NANOHIVE';

INSERT INTO Unit_Flavors (UnitType, FlavorType, Flavor)
SELECT 'UNIT_NANOHIVE', FlavorType, Flavor
FROM Unit_Flavors
WHERE UnitType = 'UNIT_MARINE';

DELETE FROM Unit_ResourceQuantityRequirements
WHERE UnitType = 'UNIT_NANOHIVE';

-- Robots: Use Geliopod as ranger replacement
UPDATE Units
SET Combat = (SELECT Combat FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    RangedCombat = (SELECT RangedCombat FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Cost = (SELECT Cost FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    -- TODO
    -- PrereqTech = (SELECT PrereqTech FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    PrereqTech = NULL,
    -- TODO
    -- Description = (SELECT Description FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    -- Civilopedia = (SELECT Civilopedia FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    -- Help = (SELECT Help FROM Units WHERE Type = 'UNIT_RANGED_MARINE'),
    Description = 'TXT_KEY_UNIT_ROBOT_RANGER',
    Civilopedia = 'TXT_KEY_UNIT_ROBOT_RANGER_PEDIA',
    Help = 'TXT_KEY_UNIT_ROBOT_RANGER_HELP',
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
