# Blank Stone by Kedesiklem

![BlankStone Preview Image](workshop_preview_image.png)

```md
This mod allows you to purify and infuse elemental stones to maximize the alchemical potential of Noita liquids. Discover all the secrets scattered around the world, decipher the hints, and achieve the Magnum Opus.

[A message apears before you]
    Hey! Thanks you for playing BlankStone.
    The mod is still in Alpha version, so expect many changes (mainly in the endgame content).
    Hope you'll have as much fun discovering the mod as I had creating it.
- Ked

```

# README

```csv
This is where the actual README file begins. If you are a player, Noita is a knowledge-based game, and blankStone follows this philosophy. If you want to enjoy the mod, don't spoil your experience by directly accessing the mod files.

If, despite this message, you still want to proceed, have fun! It means you're either a modder or just curious. In either case, welcome to blankStone's back room.

PS: Also, feel free to contact me if you have any suggestion.
```

```ini
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
│   │   ├── spawn_stone.lua                     # Spawn stone entities
│   │   ├── inject_stones.lua                   # Add stones to the spawn pool
│   │   ├── necromancer_loot.lua
│   │   ├── stain_immunity.lua
│   │   ├── status_effect_immunity.lua
│   │   ├── stain_effect.lua
│   │   ├── enable_children.lua                 # Because fuck me I guess
│   │   ├── nxml_tools.lua
│   │   ├── utils.lua
│   │   ├── stone_factory/                      ══╗ Current core of the mod
│   │   │   ├── craft_pipeline.lua                ║
│   │   │   ├── craft_registry.lua                ║
│   │   │   ├── craft_registry/                   ║ ╗
│   │   │   │   ├── forge_registry.lua            ║ ║ If you want to add new craft
│   │   │   │   ├── fuse_registry.lua             ║ ║
│   │   │   │   └── infuse_registry.lua           ║ ╝
│   │   │   ├── activation/                       ║
│   │   │   │   ├── forge_activation.lua          ║
│   │   │   │   └── infuse_activation.lua         ║
│   │   │   ├── effects/                          ║
│   │   │   │   ├── fuse_shield_effect.lua        ║
│   │   │   │   └── storage_upgrade_effect.lua    ║
│   │   │   ├── executors/                        ║
│   │   │   │   ├── forge_executor.lua            ║
│   │   │   │   ├── spawn_executor.lua            ║
│   │   │   │   └── upgrade_executor.lua          ║
│   │   │   ├── feedback/                         ║
│   │   │   │   └── game_feedback.lua             ║
│   │   │   ├── validators/                       ║
│   │   │   │   └── condition_validator.lua       ║
│   │   │   ├── hint_registry.lua                 ║ < If you add hint craft (that doesn't produce or consume anything)
│   │   │   ├── stone_factory.lua                 ║
│   │   │   ├── stone_registry.lua                ║ < If you want to add new stone, don't forget to put them here
│   │   │   └── ...                             ══╝
│   │   ├── stone_specific_script/              # For the scripts that concerns only a handful of stones
│   │   ├── biomes
│   │   │   └── hint_spawn_list.lua             # Define where to spawn the tablettes
│   │   ├── buildings
│   │   │   └── anvil_appends.lua
│   │   ├── magic/                              # Spells
│   │   ├── mod_compatibility
│   │   │   ├── apotheosis_appends.lua
│   │   │   └── vanilla_appends.lua             # Add abstract_stone property to vanilla stone and in_inventory effect (from apotheosis)
│   │   ├── status_effects/                     # material/damage_type/custom immunity : check poisonStone
│   │   │   ├── effect_registry/
│   │   │   ├── custom_effect_stone.lua
│   │   │   ├── damage_type_multiplier_stone.lua
│   │   │   ├── material_immunity_stone.lua
│   │   │   ├── status_effects_utils.lua
│   │   │   └── ...
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
│   └── VFX/                                    # Glyphs
├── lib/
│   └── nxml.lua
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
- stain immunity
- custom effect system
- stone duplication
- magnum opus
- Gods Secrets
- stone generator
- glyphs
- hammer (anvil forge system)
- EasyMod settings

### VanillaChange

- vanilla stone infusion and purification
- vanilla stone passive effect in inventory (same as Apotheosis)
- Steve and Skoude drop
- Forgeable stone

## Special thanks to

- lamia_zamia for the early help and guidance
- zerupo for the feedback and testing
- jobslesssteve for the feedback and testing
- krapouchnouille for the memes
- All the noita modding community
