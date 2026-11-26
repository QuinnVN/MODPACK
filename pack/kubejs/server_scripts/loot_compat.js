// Minecraft decodes the datapack tables before LootJS runs. The overrides
// use a valid empty-table reference wherever an item ID was unreadable.
const idasChestPaths = [
  'archmages_tower/archmages_tower',
  'archmages_tower/archmages_tower_library',
  'archmages_tower/archmages_tower_treasure',
  'dread_citadel/dread_citadel',
  'dread_citadel/dread_citadel_library',
  'dread_citadel/dread_citadel_throne',
  'enchantingtower/enchantingtower_basic_ars',
  'enchantingtower/enchantingtower_top_ars',
  'haunted_manor/if_haunted_manor',
  'labyrinth/if_labyrinth_tomb'
]

const tracksDropNames = ['track_drive_wheel', 'suspension_track', 'track_mount']
const lootCompatPlaceholder = 'kubejs:compat/pending_loot_entry'

LootJS.lootTables(event => {
  idasChestPaths.forEach(path => {
    const table = event.getLootTable('idas:chests/' + path)
    if (table == null) return

    table.removeReference(lootCompatPlaceholder)
  })

  tracksDropNames.forEach(name => {
    const table = event.getLootTable('tracks:blocks/' + name)
    if (table == null) return

    table.modifyEntry(entry => {
      return entry.isReference() && String(entry.getLocation()) === lootCompatPlaceholder
        ? LootEntry.of('tracks:' + name)
        : entry
    })
  })
})
