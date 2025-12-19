UPDATE Reactions
SET
  -- Without this, the game will wait a bit before allowing another AI to send the same
  -- reaction
  MinTurnsBetween = 0,
  RespectChange = CAST(RespectChange * 1.5 AS INTEGER)
WHERE Type = 'REACTION_AFFINITY_DIFFERS_CONFRONTATION'
  OR Type = 'REACTION_AFFINITY_DIFFERS_WARNING';
