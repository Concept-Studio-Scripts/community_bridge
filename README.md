# Community Bridge

Community Bridge is a modular and extensible compatibility layer for FiveM, designed to unify development across major roleplay frameworks. It provides a consistent API that simplifies integration between popular frameworks such as QBCore, ESX, QBox, and custom solutions.

By bridging core game systems including inventory, dispatch, targeting, door locks, vehicle keys, clothing, fuel, and more, Community Bridge reduces duplicated effort and streamlines script compatibility across servers.

---

![](https://img.shields.io/github/contributors/TheOrderFivem/community_bridge?logo=github)
![](https://img.shields.io/github/v/release/TheOrderFivem/community_bridge?logo=github)


## Features

### Framework Compatibility

* Supports QBCore, ESX, QBox, and custom roleplay frameworks
* Provides a unified API to standardize resource interaction

### Inventory Systems

* Compatible with ox\_inventory, qb-inventory, ps-inventory, codem-inventory, core\_inventory, and others

### Dispatch and MDT

* Integrates with ps-dispatch, cd\_dispatch, lb-tablet, bub\_mdt, and other dispatch systems
* Includes fallback mechanisms to ensure notifications are delivered

### Targeting Systems

* Works with qb-target, ox\_target, sleepless-interact, and similar targeting resources

### Doorlock and Security

* Supports ox\_doorlock, qb-doorlock, rcore\_doorlock, jacksams-doorlock, and other door lock systems

### Vehicle Keys and Locking

* Compatible with all major vehicle key management systems

### Fuel Systems

* Supports all major fuel resources such as legacyfuel, ps-fuel, and more

### Clothing and Appearance

* Integrates with illenium-appearance, fivem-appearance, qb-clothing, esx\_skin, and default fallback clothing systems

### Additional Features

* Progress bars, notifications, weather synchronization, and skill system integration
* Seatbelt providers (qbx\_seatbelt, qb-smallresources, esx\_cruisecontrol, concept\_seatbelt), voice proximity (pma-voice), and normalized current-weapon/ammo reads
* Developer tools including 3D interaction points, cutscene management, particle effects, scaleform UI, DUI system, and advanced object placement

---

## Configuration

### Client (`settings/clientConfig.lua`)

| Key | Values | Notes |
|---|---|---|
| `InputSystem` | `auto` · `ox_lib` · `lation_ui` · `qb-input` | Explicit selection or auto-detect |
| `MenuSystem` | `auto` · `ox_lib` · `wasabi_uikit` · `lation_ui` · `qb-menu` | |
| `ProgressBarSystem` | `auto` · `ox_lib` · `wasabi_uikit` · `lation_ui` · `ZSX_UIV2` · `keep-progressbar` · `progressbar` | |
| `Seatbelt` | `auto` · `qbx_seatbelt` · `qb-smallresources` · `esx_cruisecontrol` · `concept_seatbelt` · `none` | `none` disables buckle events |
| `Voice` | `auto` · `pma-voice` · `none` | `none` falls back to native proximity |
| `Debug` | `true` · `false` | Extra module registration logging |

`Fuel`, `VehicleKey`, `Target` and `Phone` providers are detected from started
resources; they have no config key.

### Shared (`settings/sharedConfig.lua`)

| Key | Values | Notes |
|---|---|---|
| `Lang` | `auto` · locale name (`en`, `fr`, ...) | |
| `DebugLevel` | `0` · `1` · `2` | |
| `Notify` | `auto` · `ox_lib` · `r_notify` · ... | |
| `HelpText` | `auto` · `ox_lib` · ... | |
| `Skills` | `auto` · `OT_skills` · `evolent_skills` · `pickle_xp` | |

### Consumer modules

| Module | API (`exports.community_bridge:<Module>()` or `Bridge.<Module>`) |
|---|---|
| `Framework` | players, job/grade, money, hunger/thirst/stress |
| `Inventory` | items, worth, current weapon, open state, image paths |
| `Seatbelt` | `GetResourceName`, `HasSeatbelt(vehicle)`, `GetState()` |
| `Voice` | `GetResourceName`, `GetProximity()` |
| `Weapons` | `GetCurrentWeapon(ped?)`, `Invalidate(notify?)` |

Normalized events (stable, additive):

| Side | Event | Payload |
|---|---|---|
| client | `community_bridge:Client:OnPlayerLoaded` | — |
| client | `community_bridge:Client:OnPlayerUnload` | — |
| client | `community_bridge:Client:OnPlayerJobUpdate` | `name, label, gradeName, grade` |
| client | `community_bridge:Client:OnNeedsUpdate` | `{ hunger, thirst, stress }?` |
| client | `community_bridge:Client:OnInventoryUpdate` | `{ resource, reason }?` |
| client | `community_bridge:Client:OnInventoryOpenChange` | `open: boolean` |
| client | `community_bridge:Client:OnWeaponUpdate` | weapon pack, or `nil` when holstered |
| client | `community_bridge:Client:OnVoiceUpdate` | `{ index, mode, distance }` |
| client | `community_bridge:Client:OnSeatbeltUpdate` | `buckled: boolean?` |
| client | `community_bridge:Client:OnAccountUpdate` | `{ account: 'bank', action: string, amount: number? }` |
| server | `community_bridge:Server:OnPlayerLoaded` | `src` |
| server | `community_bridge:Server:OnPlayerUnload` | `src` |
| server | `community_bridge:Server:OnPlayerJobChange` | `src, jobName` |

`OnAccountUpdate` is a hint that the local character's own bank account has
changed (ox_core: deposit/withdraw/transfer/balance updates). It carries no
balance — consumers re-read `Framework.GetAccountBalance('bank')`. Adapters
that do not emit it leave consumers on their polling cadence.

### Custom frameworks

Custom frameworks integrate without a bridge config key: register (or extend)
a `Framework` module from your own resource, on the side(s) you need.

```lua
exports.community_bridge:RegisterModule('Framework', {
    GetResourceName = function() return 'my_framework' end,
    GetIsPlayerLoaded = function() return LocalPlayer.state.loaded == true end,
    GetHunger = function() return 100 end,
    -- ... any other Framework functions you support
})
```

Registered functions merge over the `_default` fallbacks, so consumers only ever
talk to community_bridge.

### Tested versions

| Resource | Version |
|---|---|
| ox_core | 1.5.9 |
| ox_inventory | 2.47.9 |
| ox_lib | 3.39.0 |
| pma-voice | 7.0.1 |

QBCore / Qbox / ESX are supported through the same module contracts (their
adapters use each framework's public API); pin the framework version you test
against when releasing. The seatbelt, voice and weapons modules are consumed by
`concept_hud` and are additive — existing framework/inventory consumers are
unaffected.

---

## Documentation

Complete developer documentation is available at:
[Community Bridge Documentation](https://theorderfivem.github.io/docs)
---

## Community and Support

Join the Community Bridge Discord server for support, discussion, and contributions:
[Community Discord](https://discord.gg/MukwBuJjP7)

---

## About Community Bridge

community_bridge is developed by The Order of the Sacred Framework, a collaborative team focused on improving interoperability and reducing development friction in the FiveM ecosystem. The project is open source and licensed under GPLv3.

---

## Why Choose Community Bridge?

* Universal framework compatibility reduces code duplication
* Modular design allows use of only needed components
* Extensive developer utilities for advanced scripting and UI
* Tested in production on hundreds of FiveM servers
* Open source with active community support and regular updates

---

## Frequently Asked Questions

**Q: Will Community Bridge support new frameworks in the future?**
A: Yes, the project actively tracks emerging frameworks and integrates support accordingly.

**Q: Can Community Bridge work with my custom framework?**
A: Community Bridge is designed to be extensible and supports integration with custom frameworks.

**Q: How often is the project updated?**
A: Updates are regularly released to improve compatibility, add features, and fix issues based on community feedback.

**Q: Why is the seo so bad?**
A: Straight up, I have no clue and have tried everything to improve it. If you have tips PLEASE let me know in the discord or pr some changes to the repos dev branch.

---

## Keywords (for SEO)

FiveM framework compatibility, FiveM bridge system, QBCore ESX bridge, FiveM universal inventory, dispatch integration, targeting system, door lock system, vehicle key management, fuel system bridge, clothing system FiveM, FiveM developer tools, roleplay framework integration, Lua scripting FiveM, open source FiveM bridge, cross-framework compatibility, modular FiveM resource

---
