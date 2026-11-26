ServerEvents.recipes(event => {
  // Keep the vertical pattern for the Brass Chute. TFMG still has its horizontal pipe recipe.
  event.remove({ id: 'tfmg:crafting/materials/brass_pipe_vertical' })

  // The vanilla bamboo planks recipe already accepts Regions Unexplored bamboo logs.
  event.remove({ id: 'regions_unexplored:bamboo_planks' })

  // Match the Diesel Generators Hammer output. All three sheets share c:plates/zinc.
  event.remove({ id: 'createcasing:pressing/zinc' })
  event.remove({ id: 'createdeco:pressing/zinc_sheet' })
})
