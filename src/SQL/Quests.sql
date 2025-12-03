-- Delete affinity choice quests
DELETE FROM Quests
WHERE QuestSetType = 'QUEST_SET_CHOICE_QUESTS';

-- Delete quests that reference units we modify
DELETE FROM Quests
WHERE Type IN (
  -- These quests have hard-coded references to UNIT_MARINE
  'QUEST_AN_ELEMENTAL_FATE',
  'QUEST_FOUND_OUTPOST',
  'QUEST_PAY_DAY',
  'QUEST_THE_BEATING_HEART_SOCIETY',
  -- These quests have hard-coded references to UNIT_RANGED_MARINE
  'QUEST_VANISHERS'
  );
