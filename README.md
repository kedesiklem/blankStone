# Blank Stone by Kedesiklem

![BlankStone Preview Image](workshop_preview_image.png)


This mod add the possibility to purify and infuse stone to use the liquid at there maximum potential.


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
│   │   │   ├── level_requirements.lua
│   │   │   ├── stone_factory.lua
│   │   │   └── stone_registry.lua                  # <--- If you want to add new stone, don't forget to put them here
│   │   ├── stone_specific_script/
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
- purifying stone into blank_stone
- infusing stone with liquid
- compatibility with vanilla stone
- stain_effect.lua (thanks GrahamBurger)
- Stone factory
    - different level stone
- VFX
- infusing stone from tags
- sur-infusion/mixed liquid stone
- infusion with powder
- Forgeable stone
- quintessence (forged and use for high level stone)
- hintMessage for infusion fail
- hint for condition
- opus magnum
- purify into anything
- stone fuser spell
- purify with spell


## ONGOING
- Make a stone for (almost) every liquid
    - [x] Alcool Stone
    - [x] Blood Stone
    - [x] Bone Stone
    - [ ] BlackHole Stone (dig and attract enemies)
    - [ ] Silver Stone
    - [ ] Fungal Stone (see Apotheosis)

## TODO
- Translation stones messages
- Mimic stone -> stone fuse spell make it copy nearby stone (need more reflexion)
- make steve(1%)/scott(2%) drop bonesStone 
--- V2
- Apotheosis liquid stone (V2)
- Animation for stone_poly eye ?


### special thanks to
- lamia_zamia for the help
- zerupo for the feedback
- krapouchnouille for the memes
