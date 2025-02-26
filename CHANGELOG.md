## v1.10.8

### Other

- Added addon category
- Bumped TOC for patch 11.1.0

## v1.10.7

### Other

- Bumped TOC for patch 11.0.7

## v1.10.6

### Fixes

- Adapt to silent change where pet qualities are now 0…5 instead of 1…6. Scripts using `[ ….quality ]` conditions should work as expected again.

## v1.10.5

### Other

- Replace `InterfaceOptionsFrame_OpenToCategory` with modern API.

## v1.10.4

### Other

- Bumped TOC for patch 11.0.2.

## v1.10.3

### Other

- Adopt to patch 10.2.0 deprecations missed in previous check, update libraries.

## v1.10.2

### Other

- Adopt to patch 10.1.0 deprecation in preparation of TWW.

## v1.10.1

### Other

- Pixel nudging with ElvUI changes while in combat.
- Bumped TOC for patch 10.2.6.

## v1.10

### Fixes

- Import dialog no longer breaks with Rematch 5.
- Import dialog no longer breaks with disabled plugins. If you ever disabled a plugin, please contact us to win a price.

## v1.9.3

### Other

- Compatibility with Rematch 5.1 (in addition to old versions).

## v1.9.2

### Other

- Bumped TOC for patch 10.2.5.

## v1.9.1

### Other

- Bumped TOC for patch 10.2.

## v1.9

### Compatibility with Rematch 5

Together with patch 10.2 Gello releases Rematch 5, which is a major change both under the hood and in the user interface. To properly integrate again we had to make changes to this addon as well. To allow for users updating with a delay, this addon is compatible with Rematch 4 and Rematch 5 at the same time.

Rematch offers `/rematch reset everything` in case anything goes wrong in the update process, which this addon hooks to also save your matching scripts and tries to restore them in a reset case as well. Hopefully, there is no reason to use it though.

One small change you will encounter is that the "script button" in the team list is now non-interactive: It only shows whether there is a script or not, but you can't click it anymore to edit the script. The option to create and edit the script from the right click menu is still there, of course.

### New features

- Added condition `hp.diff` and `hpp.diff` allowing to compare own and enemy pet HP. `hp.diff = self.hp - enemy.hp` and `hpp.diff = self.hpp - enemy.hpp`. This can be used as condition for abilities that do more than one effect but use a condition after a subset of those effects (i.e. "does double damage if health difference is bigger than x after first damage effect").
- An alias `hp.can_be_exploded` has been added which is equivalent to `hp.can_explode` but phrased less confusingly. Prefer this in new scripts for clarity.
- An alias `weather(x).exists` has been added which is equivalent to `weather(x)` but more verbose.

### Breaking Changes

- Conditions that require to specify a pet now correctly check that. `[ hp > 1 ]` was never valid and thus never true, but did not provoke an error to hint users to change it to `[ self.hp > 1 ]`. This change only breaks scripts that are currently silently broken already.
- Plugins that use extra data in import/export strings are now forced to import the data without user choice. The plugin API has changed from `Plugin:OnImport(extra)` to `Plugin:OnImport(script, extra)` to allow for mapping between script and extra data.

### Fixes

- The condition `ability.duration` now correctly also takes lockdowns (not cooldowns!) into account.
- Allow a dynamic number of spaces between action and condition to allow both `do  (x)   [ yes ]` and  `do(x)[yes]`.
- Add missing check that conditions with comparisons compare against numbers.
- Script editor auto completion now correctly offers `weather`, `weather.duration` and `trap` and no longer offers the wrong `self.weather`.
- If the same ability is available multiple times, the instance with the shortest cooldown **and** lockdown is chosen now.
- Correctly import scripts with spaces in their name.
- Correctly refresh the script manager if a script's name or code changes.
- No longer break when Rematch is not loaded and script browser or the share functionality is used.

### Other

- Some localization strings have been adjusted and errors have been fixed. If you find translation issues, please report them.

## v1.8

- Restored the full set of configuration options. They were removed when the tdPetBattleScript and tdPetBattleScript_Rematch addons were merged.
- Updated for Dragonflight 10.1.5
- Auto button now properly fits in the ElvUI theme.

## v1.7.5

- Fixed locale strings

## v1.7

### Breaking Changes

- `change(next)` now skips dead pets as well as pets that can't be swapped in due to debuffs. Previously `change(next)` only skipped to the exactly next pet, and if that was unable to be swapped in did nothing. It now first checks whether the next pet can be swapped in, and if it can't checks the one after the next pet, until it finds a valid pet or loops around to the current pet.

### Other

- Updated for Dragonflight 10.1
- Added an option to have an audible notification once the battle round finished and the "autobattle" button becomes active again. Disabled by default.
- ElvUI detection is now working correctly if the global toggle for "all Blizzard frames" is disabled, rather than just the petbattle one.

## v1.6

- Updated calculation for can_explode, to use "<=" instead of "<".
- ElvUI users no longer have a piece of unused art on top of their screen during pet battles.
- The addon name should no longer show up twice in various tooltips.
- Updated readme to reflect an issue with `Rematch` when uninstalling `tdBattlePetScript`.

## v1.5

- Updated to WoW 10.0.2

## v1.4

- Fixed issue with Test button not correctly disabling during pet battle animations
- Fixed issue where the Test button crashed on if/endif blocks in the script.
- Fixed condition (pet) `type` to correctly handle bad pets (e.g. `self(#4).type`) again.
- Added `collected.count` to the Pets API (the amount of a specific pet you have in your collection).
- Added `collected.max` to the Pets API (the maximum amount of a specific pet you can have in your collection).

## v1.3

- Added script test button (allows you to see the next action that will be taken without having to run the script)
- Updated UI icon in script editor
- Notification boxes now fade out after a few seconds

## v1.2

- Fixed LUA error when attempting to export talents
- Fixed LUA error in the script selector
- Updated the size of some pet battle UI components

## v1.1

- Added addon options menu
- Fixed various localization issues
- Various small bugfixes

## v1.0

- Updated for Dragonflight.
- Added `collected` to the Pets API (`true` if the pet is in your collection).
- Added `trap` to the Status API (`true` if the trap is usable (or potentially usable if enemy hp is low enough)).
- Fixed condition behavior when the condition includes a non-existent pet or ability. This allows (among others) using ability `(Ghostly Bite:654) [enemy.ability (Mudslide:572).duration < 5]`, even if the current pet does not have Mudslide, to be used in generic scripts. See the discussion in [this issue](https://github.com/DengSir/tdBattlePetScript/issues/26) for more detail and exact semantics.
- Merged Rematch addon into main code.
- General bug fixes
