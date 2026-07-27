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
├── init.lua                                    # Mod entry point (OnModPreInit/Init/PostInit, wires everything below)
├── settings.lua                                # EasyMod settings menu
├── mod.xml / compatibility.xml / workshop.xml  # Noita/workshop manifests
├── translations.csv
├── CREDIT.txt
├── lib/
│   └── nxml.lua                                # XML parsing lib
├── utils/                                      # Dev-only
│   ├── logger.lua
│   └── ...
├── README.md                                    # You're reading it
└── files/                                       # Actual mod content, loaded at runtime
    ├── entities/
    │   ├── base_stone.xml                       # Base for every stone (basic physical property)
    │   ├── elemental_stone.xml                  # Base for every elemental stone (make them purifiable)
    │   ├── infusable.xml / purifiable.xml       # Interfaces
    │   ├── blank_stone.xml                      # Main Stone
    │   ├── quintessence_stone.xml / stone_storage.xml / stone_mimic.xml / mimic_stone.xml / staining.xml / spawn_stone.xml
    │   ├── elemental_stone/                     # One xml per elemental stone (apotheosis/ subfolder = apotheosis-specific variants)
    │   ├── magnum_opus/                         # Advanced end-game stones (albedo, nigredo, rubedo, citrinitas, lapis_philosophorum)
    │   ├── items/books/                         # In-game lore books
    │   ├── buildings/                           # Alchemist portal, progress portal
    │   ├── lab/                                 # Crafting lab entities (slots, trash, item display)
    │   ├── progress/                            # Progression trigger/hint scripts + hint tablet sprites (stones/)
    │   ├── hidden_message/                      # Hidden secret all across the map
    │   └── misc/                                # Custom effects, shield, stone_fuser...
    ├── scripts
    │   ├── purify_stone.lua                     # Define how elemental stone turn into blank stone (or something else)
    │   ├── spawn_stone.lua                      # Spawn stone entities
    │   ├── inject_stones.lua                    # Add stones to the spawn pool
    │   ├── utils.lua / nxml_tools.lua
    │   ├── necromancer_loot.lua / stain_immunity.lua / status_effect_immunity.lua / stain_effect.lua / enable_children.lua
    │   ├── stone_factory/                       ══╗ Core of the mod: turns a stone_registry entry into a working craft
    │   │   ├── craft_pipeline.lua                 ║
    │   │   ├── craft_registry.lua                 ║
    │   │   ├── craft_registry/                    ║ ╗
    │   │   │   ├── forge_registry.lua             ║ ║ If you want to add a new craft
    │   │   │   ├── fuse_registry.lua              ║ ║
    │   │   │   └── infuse_registry.lua            ║ ╝
    │   │   ├── activation/                        ║
    │   │   ├── effects/                           ║
    │   │   ├── executors/                         ║
    │   │   ├── feedback/                          ║
    │   │   ├── validators/                        ║
    │   │   ├── compat/                            ║   Cross-mod craft compat (e.g. compat/apotheosis/)
    │   │   ├── hint_registry.lua                  ║
    │   │   ├── stone_factory.lua                  ║
    │   │   └── stone_registry.lua                 ║ < If you want to add a new stone, dont forget to put it here (single source of truth)
    │   │                                        ══╝
    │   ├── infusable/                              # Infusion mechanic (infusable_stone.lua = current core infusion logic)
    │   ├── stone_specific_script/                  # Scripts that concern only a handful of stones
    │   ├── animals/
    │   ├── items/
    │   ├── biomes/
    │   │   └── biome_append.lua                    # Define where to spawn the hint tablets
    │   ├── buildings/
    │   │   ├── anvil_appends.lua                   # Forge system on the vanilla anvil
    │   │   └── lab/                                ╗ Lab based on Purgatory by Priskip
    │   ├── lab/                                    ╝ 
    │   ├── magic/                                  # Spells & Misc: stone_fuser.lua, quest_utils.lua, pw_*_check.lua
    │   ├── mod_compatibility/
    │   │   ├── apotheosis_appends.lua
    │   │   ├── component-explorer_appends.lua
    │   │   └── vanilla_appends.lua                 # Add abstract_stone property to vanilla stones + in_inventory effect (based on apotheosis)
    │   ├── perks/                                  # perk_appends.lua
    │   ├── status_effects/                         # material/damage_type/custom immunity : check poisonStone
    │   │   ├── effect_registry/
    │   │   ├── custom_effect_stone.lua
    │   │   ├── damage_type_multiplier_stone.lua
    │   │   ├── material_immunity_stone.lua
    │   │   └── status_effects_utils.lua
    │   └── storage_stone/                          # Bags of Many from KILLUA
    │       ├── bags/                                # Universal pickup/throw scripts
    │       ├── gui/                                 # Bag inventory UI
    │       └── utils/                               # Inventory, spells lookup, mod state
    ├── actions.lua                              # Spell/card definitions (e.g. the stone fuser)
    ├── materials/materials_appends.xml          # Custom material definitions
    ├── biome_impl/                              # Custom biome assets (e.g. secretbeehive)
    ├── pixelscenes/                             # Map scenes
    └── items_gfx/ ui_gfx/ VFX/                  # In-world sprites / inventory sprites / glyphs

```

## DONE

### Mod add

- +50 Stones
- purifying/infusion mecanism
- Stone factory
   - multiple quest condition
   - multiple crafting system
- stain_effect.lua (thanks GrahamBurger)
- material immunity / damage_type immunity (thanks Spoopy Magic Boi)
- Gods Secrets
- EasyMod settings

### VanillaChange

- vanilla stone infusion and purification
- vanilla stone passive effect in inventory (same as Apotheosis)
- Steve and Skoude drop
- Forgeable stone (change in the forge itself)
- Secret place

## Special thanks to

- lamia_zamia for the early help and guidance
- zerupo for the feedback and testing
- jobslesssteve for the feedback and testing
- krapouchnouille for the memes
- All the noita modding community
- choco le fidèle parmis les fidèles


# TODO

- storage slot (secretBeehive) 
    - fix tablette storage
    - fix shield stone