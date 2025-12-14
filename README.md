# Blank Stone by Kedesiklem

This mod add the possibility to purify and infuse stone to use the liquid at there maximum potential.


```
.
├── CREDIT.txt
├── files
│   ├── entities
│   │   ├── base_stone.xml              # Base for every stone (define basic physical property)
│   │   ├── purifiable.xml              # Interface
│   │   ├── infusable.xml               # Interface
│   │   ├── staining.xml                # Interface
│   │   ├── blank_stone.xml
│   │   ├── elemental_stone.xml         # Base for every elemental stone other than vanilla ones
│   │   └── elemental_stone
│   │       └── ...
│   ├── items_gfx
│   │   ├── blank_stone.png
│   │   └── elemental_stone
│   │       └── ...
│   ├── scripts
│   │   ├── infuse_stone.lua            # Core of the mod
│   │   ├── inject_stones.lua           # Define what stone will spawn ingame
│   │   ├── purify_stone.lua            # Define how elemental stone turn into blank stone
│   │   ├── stain_effect.lua            # Allow stone to apply stain (doesn't work --')
|   |   ├── enable_children.lua         # Because fuck me I guess
│   │   ├── stain_effect.lua
│   │   ├── stone_specific_script
│   │   │   └── ...
│   │   ├── stone_factory               # Handle collective and specific stone infusion condition
│   │   │   ├── level_requirements.lua
│   │   │   ├── stone_factory.lua
│   │   │   └── stone_registry.lua      # <--- If you want to add new stone, don't forget to put them here / Define wich material lead to wich stone 
│   │   └── mod_compatibility
│   │       └── vanilla_appends.lua     # Add abstract_stone property to vanilla stone and in_inventory effect from apotheosis
│   └── ui_gfx
│       ├── blank_stone.png
│       └── elemental_stone
│           └── ...
├── init.lua
├── lib
│   └── nxml.lua
├── mod.xml
├── README.md                           # You're reading it
├── utils                               # useful stuff for debugging / adding new stone
│   ├── generation.log
│   ├── logger.lua
│   └── sprits_generator.sh             # To quickly create sprite for stone from material
└── workshop.xml
```

## DONE
- more stone
- purifying stone into blank_stone
- infusing stone with liquid
- compatibility with vanilla stone
- stain_effect.lua (thanks GrahamBurger)
- Stone factory
    - different level stone
- VFX
- gros caillou (ne fonctionne pas comme prevue mais fuck it)
- sur-infusion/mixed liquid stone

## ONGOING

## TODO
- MORE STONE !!!
- gold stone
- more conditionnal ritual
- hint for condition
    - quintessence ?
- Improve description
- Apotheosis liquid stone
- Animation for stone_poly eye ?

### special thanks to
- lamia_zamia for the help
- zerupo for the feedback
- krapouchnouille for the memes