// Both presses use the same seeds and produce 100 mB. Keep one recipe.
ServerEvents.recipes(event => {
  event.remove({ id: 'createaddition:compacting/seed_oil' })
})
