LootJS.lootTables(event => {
  const scrollLoot = [
    [0.05, 'basic', [
      'integrated_villages:chests/airship_village/airship_village_library',
      'integrated_villages:chests/clockwork_village/clockwork_village_library',
      'integrated_villages:chests/oasis_village/oasis_village_library'
    ]],
    [0.10, 'low', [
      'idas:chests/castle/castle_library',
      'idas:chests/haunted_manor/haunted_manor_library',
      'idas:chests/labyrinth/labyrinth_library'
    ]],
    [0.12, 'low_to_medium', [
      'idas:chests/archmages_tower/archmages_tower_library',
      'idas:chests/dread_citadel/dread_citadel_library',
      'cataclysm:chests/cursed_pyramid/cursed_pyramid_library'
    ]],
    [0.12, 'ice', ['cataclysm:chests/frosted_prison_treasure']],
    [0.18, 'medium', ['integrated_stronghold:chests/treasure']],
    [0.18, 'fire', ['betterfortresses:chests/puzzle']]
  ]

  scrollLoot.forEach(([chance, scrollTable, chestTables]) => {
    chestTables.forEach(chestTable => {
      const table = event.getLootTable(chestTable)
      if (table == null) {
        console.warn('Structure scroll loot table missing: ' + chestTable)
        return
      }

      table.createPool(pool => {
        pool.addEntry(LootEntry.reference('kubejs:structure_scrolls/' + scrollTable).randomChance(chance))
      })
    })
  })
})
