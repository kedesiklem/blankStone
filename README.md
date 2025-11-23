# Blank Stone by Kedesiklem

This mod add the possibility to purify and infuse stone to use the liquid at there maximum potential.


## File structure
```
.
├── files
│   ├── entities
│   │   ├── abstract_stone.xml      # base for every stone
│   │   ├── blank_stone.xml         
│   │   ├── elemental_stone.xml     # base for every stone that can be purify
│   │   ├── stone_toxic.xml         
│   │   └ ...
│   ├── items_gfx
│   │   ├── blank_stone.png
│   │   └── stone_toxic.png
│   ├── scripts
│   │   ├── infuse_stone.lua        # Define how to turn blank stone into elemental_stone
│   │   ├── inject_stones.lua       # Define what stone will be add ingame
│   │   └── purify_stone.lua        # Define how elemental stone turn into blank stone
│   └── ui_gfx
│       ├── blank_stone.png
│       └── stone_toxic.png
├── init.lua
├── mod.xml
├── README.md                       # You're reading it
├── utils                           # useful stuff for debugging / adding new stone
│   ├── generation.log
│   ├── logger.lua
│   ├── sprites
│   │   ├── blank_stone_item.png
│   │   └── blank_stone_ui.png
│   └── sprits_generator.sh         # To quickly create sprite for stone from material
└── workshop.xml
```

## TODO
- more conditionnal ritual
- different level stone


### special thanks to
lamia_zamia for the help