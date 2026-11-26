const $ProgressionAnvilUpdate = Java.loadClass('net.neoforged.neoforge.event.AnvilUpdateEvent')
const $ProgressionEnchantments = Java.loadClass('net.minecraft.world.item.enchantment.Enchantments')
const $ProgressionEnchantHelper = Java.loadClass('net.minecraft.world.item.enchantment.EnchantmentHelper')
const $ProgressionRegistries = Java.loadClass('net.minecraft.core.registries.Registries')
const $ProgressionServerLevel = Java.loadClass('net.minecraft.server.level.ServerLevel')

// The high-power table introduces level VI. Density VII requires two level VI inputs.
NativeEvents.onEvent('LOWEST', $ProgressionAnvilUpdate, event => {
  const level = event.getPlayer().level
  if (!(level instanceof $ProgressionServerLevel) || event.getRight().isEmpty()) return

  const registry = level.registryAccess().registryOrThrow($ProgressionRegistries.ENCHANTMENT)
  const left = $ProgressionEnchantHelper.getEnchantmentsForCrafting(event.getLeft())
  const right = $ProgressionEnchantHelper.getEnchantmentsForCrafting(event.getRight())
  const output = event.getOutput().isEmpty()
    ? null
    : $ProgressionEnchantHelper.getEnchantmentsForCrafting(event.getOutput())
  const density = registry.getHolderOrThrow($ProgressionEnchantments.DENSITY)

  if (createsLevelSix(registry.getHolderOrThrow($ProgressionEnchantments.SHARPNESS), left, right, output) ||
      createsLevelSix(registry.getHolderOrThrow($ProgressionEnchantments.PROTECTION), left, right, output) ||
      createsLevelSix(density, left, right, output) ||
      createsDensitySevenWithoutMerge(density, left, right, output)) {
    event.setCanceled(true)
  }
})

function createsLevelSix(enchantment, left, right, output) {
  const leftLevel = left.getLevel(enchantment)
  const rightLevel = right.getLevel(enchantment)
  if (leftLevel >= 6 || rightLevel >= 6) return false
  return output == null
    ? leftLevel === 5 && rightLevel === 5
    : output.getLevel(enchantment) >= 6
}

function createsDensitySevenWithoutMerge(density, left, right, output) {
  if (output == null || output.getLevel(density) < 7) return false

  const leftLevel = left.getLevel(density)
  const rightLevel = right.getLevel(density)
  return leftLevel < 7 && rightLevel < 7 && !(leftLevel === 6 && rightLevel === 6)
}
