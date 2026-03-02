# Blank Stone by Kedesiklem

![BlankStone Preview Image](workshop_preview_image.png)

```
This mod allows you to purify and infuse elemental stones to maximize the alchemical potential of Noita liquids. Discover all the secrets scattered around the world, decipher the hints, and achieve the Magnum Opus.

[A message apears before you]
    Hey! Thanks you for playing BlankStone.
    The mod is still in Alpha version, so expect many changes (mainly in the endgame content).
    Hope you'll have as much fun discovering the mod as I had creating it.
- Ked

```

# README

```
This is where the actual README file begins. If you are a player, Noita is a knowledge-based game, and blankStone follows this philosophy. If you want to enjoy the mod, don't spoil your experience by directly accessing the mod files.

If, despite this message, you still want to proceed, have fun! It means you're either a modder or just curious. In either case, welcome to blankStone's back room.

PS: Also, feel free to contact me if you have any suggestion.
```

```
.
├── CREDIT.txt
├── files
│   ├── actions.lua
│   ├── entities
│   │   ├── base_stone.xml                      # Base for every stone (define basic physical property)
│   │   ├── blank_stone.xml                     # Main Stone
│   │   ├── elemental_stone.xml                 # Base for every elemental stone (make them purifiable)
│   │   ├── elemental_stone/                    # Stones
│   │   ├── infusable.xml                       # Interface
│   │   ├── purifiable.xml                      # Interface
│   │   ├── items/                              # Mainly books
│   │   ├── magnum_opus/                        # Advanced stones
│   │   ├── misc/
│   │   └── ...
│   ├── items_gfx/                              # InWorld Sprites
│   ├── scripts
│   │   ├── purify_stone.lua                    # Define how elemental stone turn into blank stone (or something else)
│   │   ├── infuse_stone.lua                    # Original core of the mod
│   │   ├── stone_factory/                      ══╗ Current core of the mod
│   │   │   ├── craft_registry.lua                ║
│   │   │   │   ├── craft_registry                ║ ╗
│   │   │   │   │   ├── forge_registry.lua        ║ ║ If you want to add new craft
│   │   │   │   │   ├── fuse_registry.lua         ║ ║
│   │   │   │   │   └── infuse_registry.lua       ║ ╝
│   │   │   ├── craft_requirements.lua            ║
│   │   │   ├── hint_registry.lua                 ║ < If you add hint craft (that doesn't produce or consume anything)
│   │   │   ├── stone_factory.lua                 ║
│   │   │   └── stone_registry.lua              ══╝ < If you want to add new stone, don't forget to put them here
│   │   ├── stone_specific_script/              # For the scripts that concerns only a handful of stones
│   │   ├── biomes
│   │   │   └── hint_spawn_list.lua             # Define where to spawn the tablettes
│   │   ├── buildings
│   │   │   └── anvil_appends.lua
│   │   ├── enable_children.lua                 # Because fuck me I guess
│   │   ├── inject_stones.lua                   # Add stones to the spawn pool
│   │   ├── magic/                              # Spells
│   │   ├── mod_compatibility
│   │   │   ├── apotheosis_appends.lua
│   │   │   └── vanilla_appends.lua             # Add abstract_stone property to vanilla stone and in_inventory effect (from apotheosis)
│   │   ├── status_effects/                     # Mainly for material/damage_type immunity : check poisonStone
│   │   ├── storage_stone/                      # Bags of Many
│   │   └── ...
│   ├── ui_gfx                                  # Inventory Sprites
│   │   ├── elemental_stone/
│   │   ├── gun_actions/                        # Spells
│   │   ├── items/
│   │   ├── magnum_opus/
│   │   ├── settings/
│   │   ├── status_indicators/
│   │   ├── inventory/                          # Bags of Many
│   │   └── ...
│   └── VFX/
├── lib/
├── utils
│   └── logger.lua
├── mod_id.txt
├── mod.xml
├── README.md                                   # You're reading it
├── compatibility.xml
├── settings.lua
├── translations.csv
├── workshop_id.txt
├── workshop_preview_image.png
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
- material immunity / damage_type immunity (thanks Spoopy Magic Boi)
- magnum opus
- Gods Secrets

### VanillaChange

- vanilla stone infusion and purification
- vanilla stone passive effect in inventory (same as Apotheosis)
- Steve and Skoude drop
- Forgeable stone

## ONGOING

- Make a stone for (almost) every liquid
  - [ ] Silver Stone
  - [ ] Fungal Stone (see Apotheosis)

## TODO

secret message when quintessence inhand ?

### V2

- Apotheosis liquid stone (V2)

## Special thanks to

- lamia_zamia for the early help and guidance
- zerupo for the feedback and testing
- jobslesssteve for the feedback and testing
- krapouchnouille for the memes
- All the noita modding community
