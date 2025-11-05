INSERT INTO Civilization_UnitClassOverrides (CivilizationType, UnitClassType, UnitType)
VALUES
  -- TODO: Add remaining civilisations
  ('CIVILIZATION_ARC', 'UNITCLASS_MARINE', 'UNIT_GELIOPOD'),
  ('CIVILIZATION_BRASILIA', 'UNITCLASS_GELIOPOD', NULL);

UPDATE Units
SET Combat = (SELECT Combat FROM Units WHERE Type = 'UNIT_MARINE'),
    Cost = (SELECT Cost FROM Units WHERE Type = 'UNIT_MARINE'),
    PrereqTech = (SELECT PrereqTech FROM Units WHERE Type = 'UNIT_MARINE'),
    Description = (SELECT Description FROM Units WHERE Type = 'UNIT_MARINE'),
    Civilopedia = (SELECT Civilopedia FROM Units WHERE Type = 'UNIT_MARINE'),
    Help = (SELECT Help FROM Units WHERE Type = 'UNIT_MARINE'),
    Moves = (SELECT Moves FROM Units WHERE Type = 'UNIT_MARINE'),
    Invisibility = (SELECT Invisibility FROM Units WHERE Type = 'UNIT_MARINE'),
    Conscription = (SELECT Conscription FROM Units WHERE Type = 'UNIT_MARINE')
WHERE Type = 'UNIT_GELIOPOD';

DELETE FROM Unit_AffinityPrereqs
WHERE UnitType = 'UNIT_GELIOPOD';

UPDATE Unit_Flavors
SET Flavor = (SELECT Flavor FROM Unit_Flavors WHERE UnitType = 'UNIT_MARINE' AND FlavorType = 'FLAVOR_DEFENSE')
WHERE UnitType = 'UNIT_GELIOPOD' AND FlavorType = 'FLAVOR_DEFENSE';

UPDATE Unit_Flavors
SET Flavor = (SELECT Flavor FROM Unit_Flavors WHERE UnitType = 'UNIT_MARINE' AND FlavorType = 'FLAVOR_OFFENSE')
WHERE UnitType = 'UNIT_GELIOPOD' AND FlavorType = 'FLAVOR_OFFENSE';

DELETE FROM Unit_ResourceQuantityRequirements
WHERE UnitType = 'UNIT_GELIOPOD';

-- These quests have hard-coded references to UNIT_MARINE
DELETE FROM Quests
WHERE Type IN ('QUEST_AN_ELEMENTAL_FATE', 'QUEST_FOUND_OUTPOST', 'QUEST_PAY_DAY', 'QUEST_THE_BEATING_HEART_SOCIETY');
