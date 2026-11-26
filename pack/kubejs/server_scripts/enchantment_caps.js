const $CapApothicEnchanting = Java.loadClass('dev.shadowsoffire.apothic_enchanting.ApothicEnchanting')
const $CapEnchantHelper = Java.loadClass('net.minecraft.world.item.enchantment.EnchantmentHelper')
const $CapMutableEnchantments = Java.loadClass('net.minecraft.world.item.enchantment.ItemEnchantments$Mutable')
const $CapEnchantmentMenu = Java.loadClass('net.minecraft.world.inventory.EnchantmentMenu')
const $CapPlayerTick = Java.loadClass('net.neoforged.neoforge.event.tick.PlayerTickEvent$Post')
const $CapServerPlayer = Java.loadClass('net.minecraft.server.level.ServerPlayer')

// Use the real stacks instead of menu snapshots so the capped levels persist in saves.
NativeEvents.onEvent($CapPlayerTick, event => {
  const player = event.getEntity()
  if (!(player instanceof $CapServerPlayer) || player.tickCount % 10 !== 0) return

  const inventory = player.getInventory()
  let changed = false
  for (let slot = 0; slot < inventory.getContainerSize(); slot++) {
    if (clampStoredEnchantments(inventory.getItem(slot))) changed = true
  }
  if (changed) inventory.setChanged()

  const menu = player.containerMenu
  clampStoredEnchantments(menu.getCarried())
  if (menu instanceof $CapEnchantmentMenu) {
    clampStoredEnchantments(menu.getSlot(0).getItem())
  }
})

function clampStoredEnchantments(stack) {
  if (stack.isEmpty()) return false
  const stored = $CapEnchantHelper.getEnchantmentsForCrafting(stack)
  if (stored.isEmpty()) return false

  let capped = null
  const enchantments = stored.keySet().iterator()
  while (enchantments.hasNext()) {
    let enchantment = enchantments.next()
    let cap = $CapApothicEnchanting.getEnchInfo(enchantment).levelCap()
    if (cap < 0 || stored.getLevel(enchantment) <= cap) continue

    if (capped == null) capped = new $CapMutableEnchantments(stored)
    capped.set(enchantment, cap)
  }
  if (capped == null) return false

  $CapEnchantHelper.setEnchantments(stack, capped.toImmutable())
  return true
}
