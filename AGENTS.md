# Modpack maintenance

After adding, removing, or replacing a mod in `pack/mods/`, review both [Lite](profiles/lite/allow.txt) and [Server](profiles/server/allow.txt) allowlists. Add the mod and its required dependencies to each profile that should ship them. Remove or replace entries when their Packwiz paths change. Full includes every mod in `pack/mods/`. Lite and Server include only their listed mods and shader packs.

Keep shared gameplay mods and their dependencies aligned across Full, Lite, and Server so both clients can join the same dedicated server. See [profile goals and compatibility notes](CONTEXT.md#full-lite-and-server-packaging) when deciding where a mod belongs. Verify the affected mod sets against the Packwiz metadata and profile allowlists.

Run `build.ps1` or `build.sh` when the user requests a build or a new `.mrpack`.
