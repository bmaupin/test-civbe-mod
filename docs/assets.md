# Assets

#### Leader portrait

- 1600x900
- DDS with DXT5 compression
- Leader on transparent background
  - Leader should start at X pixel ~250 and be ~366 pixels wide
- 3 files total to create
  - DDS image
  - Environment XML that links to DDS
  - Scene XML that links to DDS and environment XML
- Leader's `ArtDefineTag` needs to point to scene XML
  - ⚠️ Leader, not Civilization
