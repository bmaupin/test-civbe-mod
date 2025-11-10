# Assets

#### Leader portrait

- 1600x900
- DDS
  - Format: _RGBA8_
  - Compression: _DXT5_
- Leader should be centred on left of image
  - i.e. centre of leader should be about pixel 400
  - Image can have a background or have a transparent background; transparent background matches the other leaders but it's not necessary
- 3 files total to create
  - DDS image
  - Environment XML that links to DDS
  - Scene XML that links to DDS and environment XML
- Leader's `ArtDefineTag` needs to point to scene XML
  - ⚠️ Leader, not Civilization

## Game assets

- Extract using Dragon Unpacker
- Models in Resource/Common
  - .dge
    - Granny state files?
  - .fsmxml
    - XML configuration for state machine
  - .fxsxml
    - XML configuration for mesh, animation, texture
  - .gr2
    - Granny files for mesh, animation,
- Textures in Resource/DX11
  - .dds
    - Direct Draw texture files
