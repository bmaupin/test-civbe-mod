UPDATE Reactions
SET
  -- Without this, the game will wait a bit before allowing another AI to send the same
  -- reaction
  MinTurnsBetween = 0,
  RespectChange = CAST(RespectChange * 1.5 AS INTEGER)
WHERE Type = 'REACTION_AFFINITY_DIFFERS_CONFRONTATION';

UPDATE Reactions
SET
  -- Affinity changes can happen a lot until war is unlocked, so dial the frequency down
  -- a bit
  MinTurnsBetween = 10,
  RespectChange = CAST(RespectChange * 1.5 AS INTEGER)
WHERE Type = 'REACTION_AFFINITY_DIFFERS_WARNING';

-- Give one extra level of respect whenever a trade route is established between players
INSERT INTO Reactions (Type, RespectChange)
VALUES
  ('REACTION_TRADE_ROUTE_ESTABLISHED_LIKE', 10);
