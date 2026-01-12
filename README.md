# Blank Stone by Kedesiklem

![BlankStone Preview Image](workshop_preview_image.png)

This mod allows you to purify and infuse elemental stones to maximize the alchemical potential of Noita liquids. 
Discover all the secrets scattered around the world, decipher the hints, and achieve the Opus Magnum."


```
.
├── CREDIT.txt
├── files
│   ├── entities
│   │   ├── base_stone.xml                          # Base for every stone (define basic physical property)
│   │   ├── elemental_stone/
│   │   ├── opus_magnum/
│   │   ├── items/
│   │   ├── misc/
│   │   ├── elemental_stone.xml                     # Base for every elemental stone (make them purifiable)
│   │   ├── infusable.xml                           # Interface
│   │   ├── purifiable.xml                          # Interface
│   │   ├── staining.xml                            # Interface
│   │   ├── blank_stone.xml                         # Main Stone
│   │   └── quintessence_stone.xml                  # For Advanced craft
│   ├── items_gfx
│   │   ├── blank_stone.png
│   │   ├── elemental_stone/
│   │   ├── quintessence_stone.png
│   │   └── stone.kra
│   ├── scripts
│   │   ├── infuse_stone.lua                        # Core of the mod
│   │   ├── inject_stones.lua                       # Define what stone will spawn ingame (currently [02/01/2026] only blankStone)
│   │   ├── purify_stone.lua                        # Define how elemental stone turn into blank stone (or something else)
│   │   ├── stain_effect.lua                        # Allow stone to apply stain
|   |   ├── enable_children.lua                     # Because fuck me I guess
│   │   ├── biomes
│   │   │   └── hint_spawn_list.lua                 # Emerald tablets hints
│   │   ├── buildings
│   │   │   └── anvil_appends.lua
│   │   ├── mod_compatibility
│   │   │   └── vanilla_appends.lua                 # Add abstract_stone property to vanilla stone and in_inventory effect (from apotheosis)
│   │   ├── stone_factory                           # Handle collective and specific stone infusion condition
│   │   │   ├── craft_registry.lua                  # <--- If you want to add new craft
│   │   │   ├── craft_requirements.lua
│   │   │   ├── stone_factory.lua
│   │   │   └── stone_registry.lua                  # <--- If you want to add new stone, don't forget to put them here
│   │   ├── stone_specific_script/                  # For the script that concerns only a handful of stones 
│   │   ├── status_effect/                          # For material/damage_type immunity : check poisonStone
│   │   ├── magic/                                  # spell related
│   │   ├── utils.lua
│   │   └── nxml_tools.lua                          # For xml manipulation and injection
│   ├── ui_gfx
│   │   ├── blank_stone.png
│   │   ├── elemental_stone/
│   │   ├── gun_actions/                            # spell related
│   │   ├── quintessence_stone.png
│   │   └── stone.kra
│   └── VFX/
├── init.lua
├── lib
│   └── nxml.lua
├── mod.xml
├── README.md                                       # You're reading it
├── translations.csv
├── utils/                                          # useful stuff (mostly debugging)
└── workshop.xml


```

## DONE
### Mod add
- purifying/infusion stone
- Stone factory
    - different level stone
    - different crafting system
- VFX
- stain_effect.lua (thanks GrahamBurger)
- infusing stone from tags
- sur-infusion/mixed liquid stone
- quintessence (upgrading stone)
- hint (message / book)
- fuser spell
- material immunity / damage_type immunity
- opus magnum
- Gods Secrets

### VanillaChange
- vanilla stone infusion and purification
- vanilla stone passive effect in inventory (same as Apotheosis)
- Steve and Skoude drop
- Forgeable stone


## ONGOING
- Make a stone for (almost) every liquid
    - [x] Alcool Stone
    - [x] Blood Stone
    - [x] Bone Stone
    - [x] Poison Stone
    - [x] Honey Stone
    - [ ] BlackHole Stone (dig and attract enemies)
    - [ ] Silver Stone
    - [x] Invisible Stone
    - [ ] Fungal Stone (see Apotheosis)
- Translation stones messages

## TODO
secret message when quintessence inhand
### V2
- Apotheosis liquid stone (V2)
- Animation (and something else) for stone_poly eye ?


## Special thanks to
- lamia_zamia for the early help and guidance
- zerupo for the feedback
- jobslesssteve for the feedback and testing
- krapouchnouille for the memes
- All the noita modding community