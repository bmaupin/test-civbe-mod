This is a mod for Sid Meier's Civilization: Beyond Earth. The overall goal of the mod is to create a mod that pits the human factions against a robot faction.

Here are some instructions:

- Please remember this is a video game
- Use British spelling
- Beyond Earth is very similar to Civilization V, so sometimes code from Civ V will work
- Beyond Earth has an SQLite database that can be modded with SQL scripts in .sql files
- Prefer simpler, clearer solutions even if they're less concise
  - The code should be prioritised for readability

For Lua code specifically:

- Beyond Earth uses the Havok Script Lua engine
  - In particular, Havok Script adds types to Lua which aren't compatible with the Lua language server used by the vscode extension, so please remove types from Lua code
- Please add semicolons to the end of lines where appropriate
- Avoid nesting functions