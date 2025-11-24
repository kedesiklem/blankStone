# Blank Stone by Kedesiklem

This mod add the possibility to purify and infuse stone to use the liquid at there maximum potential.


```
.
├── CREDIT.txt
├── files
│   ├── entities
│   │   ├── abstract_stone.xml          # Base for every stone that can be purify
│   │   ├── blank_stone.xml
│   │   ├── elemental_stone.xml         # Base for every elemental stone other than vanilla ones 
│   │   └── stone_toxic.xml
│   ├── items_gfx
│   │   ├── blank_stone.png
│   │   └── stone_toxic.png
│   ├── scripts
│   │   ├── infuse_stone.lua            # Define how to turn blank stone into elemental_stone 
│   │   ├── inject_stones.lua           # Define what stone will spawn ingame
│   │   ├── mod_compatibility
│   │   │   └── vanilla_appends.lua     # Add abstract_stone property to vanilla stone
│   │   └── purify_stone.lua            # Define how elemental stone turn into blank stone
│   └── ui_gfx
│       ├── blank_stone.png
│       └── stone_toxic.png
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
- purifying stone into blank_stone
- infusing stone with liquid
- compatibility with vanilla stone


## TODO
- more conditionnal ritual
- different level stone
- mixed liquid stone ?

### special thanks to
- lamia_zamia for the help
- zerupo for the feedback
- krapouchnouille for the memes