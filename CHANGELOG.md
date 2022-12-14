## v1.6

- Updated readme to reflect an issue with `Rematch` when uninstalling `tdBattlePetScript`

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
