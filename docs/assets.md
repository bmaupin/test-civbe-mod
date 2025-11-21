# Assets

## Leader portraits

#### Specs

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

## Leader icons

#### Game assets

- Leader entry points to this atlas: `<IconAtlas>LEADER_ATLAS_XP1</IconAtlas>`
- Seems to be in this file: `<Filename>LeaderPortraitsXP1_256.dds</Filename>`

#### Specs

- Size: 256 x 256
- Image contains a centred circular icon surrounded by transparency
- Size of circular icon within image: 212 x 212
  - This includes a 3-pixel black outline inside the icon
- Image contains the top of the leader's torso from the base of the neck up to the top of their head
  - Leader's head fills about 85% of the image
- The leader is outlined in a 3-pixel black line
- Background has a gradient style
  - Top of gradient: `0a0f19`
  - Bottom of gradient differs
    - Greyish: `3d2d2d`
    - Bluish: `3b2459`
    - Greenish: `1d3f37`

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

#### Find which package an asset is in

Grep seems to work:

```
Sid Meier's Civilization Beyond Earth$ grep -i LeaderPortraitsXP1_256.dds -r
grep: steamassets/resource/dx11/expansion1uitextures.fpk: binary file matches
```
