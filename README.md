# Blank Stone by Kedesiklem

This mod add the possibility to purify and infuse stone to use the liquid at there maximum potential.


```
.
├── CREDIT.txt
├── files
│   ├── entities
│   │   ├── base_stone.xml                          # Base for every stone (define basic physical property)
│   │   ├── elemental_stone
│   │   │   └── ...
│   │   ├── elemental_stone.xml                     # Base for every elemental stone (make them purifiable)
│   │   ├── infusable.xml                           # Interface
│   │   ├── purifiable.xml                          # Interface
│   │   ├── staining.xml                            # Interface
│   │   ├── blank_stone.xml                         # Main Stone
│   │   └── quintessence_stone.xml                  # For Advenced craft
│   ├── items_gfx
│   │   ├── blank_stone.png
│   │   ├── elemental_stone
│   │   │   └── ...
│   │   ├── quintessence_stone.png
│   │   └── stone.kra
│   ├── scripts
│   │   ├── infuse_stone.lua                        # Core of the mod
│   │   ├── inject_stones.lua                       # Define what stone will spawn ingame
│   │   ├── purify_stone.lua                        # Define how elemental stone turn into blank stone
│   │   ├── stain_effect.lua                        # Allow stone to apply stain (doesn't work --')
|   |   ├── enable_children.lua                     # Because fuck me I guess
│   │   ├── buildings
│   │   │   └── anvil_appends.lua                   # To fuse different stones
│   │   ├── mod_compatibility
│   │   │   └── vanilla_appends.lua                 # Add abstract_stone property to vanilla stone and in_inventory effect (from apotheosis)
│   │   ├── nxml_tools.lua
│   │   ├── stone_factory                           # Handle collective and specific stone infusion condition
│   │   │   ├── craft_registry.lua                  # <--- If you want to add new craft
│   │   │   ├── level_requirements.lua
│   │   │   ├── stone_factory.lua
│   │   │   └── stone_registry.lua                  # <--- If you want to add new stone, don't forget to put them here
│   │   ├── stone_specific_script
│   │   │   └── enlarge_stone.lua
│   │   └── variableStorage_accessibility.lua
│   ├── ui_gfx
│   │   ├── blank_stone.png
│   │   ├── elemental_stone
│   │   │   └── ...
│   │   ├── quintessence_stone.png
│   │   └── stone.kra
│   └── VFX
│       ├── image_emitters
│       │   └── ...
│       └── ...
├── init.lua
├── lib
│   └── nxml.lua
├── mod.xml
├── README.md                                       # You're reading it
├── utils                                           # useful stuff for debugging / adding new stone
│   └── ...
└── workshop.xml


```

## DONE
- MORE STONE !
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



## ONGOING
- MORE STONE !!!
- lapis philosophorum

## TODO
- Apotheosis liquid stone (V2)
- Animation for stone_poly eye ?

### special thanks to
- lamia_zamia for the help
- zerupo for the feedback
- krapouchnouille for the memes