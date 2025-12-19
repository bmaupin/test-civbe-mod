This is a mod for Sid Meier's Civilization: Beyond Earth. The goal of the mod is to replace the three affinities in the game with species, so that each player will pick a specific species and that species will be limited to the technologies, buildings, and units that previously would have been accessible to a specific affinity.

Here are some instructions:

- Please remember this is a video game
- Use British spelling
- Beyond Earth is very similar to Civilization V, so sometimes code from Civ V will work
- Beyond Earth has a SQLite database that can be modded with SQL scripts in .sql files
- Prefer simpler, clearer solutions even if they're less concise
  - The code should be prioritised for readability
- When possible, try to come up with a solution that does not involve overriding any existing game UI code (Lua or XML) as this increases the likelihood of incompatibility with other mods

For Lua code specifically:

- Beyond Earth uses the Havok Script Lua engine
  - In particular, Havok Script adds types to Lua which aren't compatible with the Lua language server used by the vscode extension, so please remove types from Lua code
- Please add semicolons to the end of lines where appropriate
- Please add logging via print statements for debugging during development
