const $LivingDropsEvent = Java.loadClass('net.neoforged.neoforge.event.entity.living.LivingDropsEvent')
const $LootTagKey = Java.loadClass('net.minecraft.tags.TagKey')
const $LootBuiltInRegistries = Java.loadClass('net.minecraft.core.registries.BuiltInRegistries')
const $LootRegistries = Java.loadClass('net.minecraft.core.registries.Registries')
const $LootResourceLocation = Java.loadClass('net.minecraft.resources.ResourceLocation')
const $LootWeakHashMap = Java.loadClass('java.util.WeakHashMap')

const protectedMobLootId = 'kubejs:protected_mob_loot'
const protectedMobLootTag = $LootTagKey.create(
  $LootRegistries.ENTITY_TYPE, $LootResourceLocation.parse(protectedMobLootId)
)
const protectedMobDropsInProgress = new $LootWeakHashMap()

// Vanilla rolls the original loot before posting LivingDropsEvent.
// Scavenger captures a second roll during that event. Discard that roll only.
NativeEvents.onEvent('HIGHEST', $LivingDropsEvent, event => {
  const mob = event.getEntity()
  const mobType = $LootBuiltInRegistries.ENTITY_TYPE.get($LootResourceLocation.parse(mob.getType()))
  if (mobType['is(net.minecraft.tags.TagKey)'](protectedMobLootTag)) {
    protectedMobDropsInProgress.put(mob, true)
  }
})

NativeEvents.onEvent('LOWEST', $LivingDropsEvent, event => {
  protectedMobDropsInProgress.remove(event.getEntity())
})

LootJS.modifiers(event => {
  event.addEntityModifier('#' + protectedMobLootId).customAction((context, loot) => {
    const mob = context.getEntity()
    if (protectedMobDropsInProgress.containsKey(mob) && mob.captureDrops() != null) {
      loot.clear()
    }
  })
})
