# Call of Duty — Graphics Settings File Locations (All PC Versions)

> Research compiled: April 1, 2026
> Scope: Video/advanced video settings config files for all major PC CoD titles, Battle.net and Steam installations.

---

## Key Notes

- **Modern titles (2019–present):** Settings files live in the **user profile folder** (`Documents` or `LocalAppData`), completely separate from the game install location. Because of this, the Battle.net and Steam install paths are **the same** for these newer games — both launchers write settings to the same user-profile folder.
- **Classic titles (pre-2019):** Settings files live **inside the game's installation directory** (typically under Steam's `steamapps\common\` folder). These titles are Steam-only.
- **`%USERPROFILE%`** = `C:\Users\YourName`
- **`%LOCALAPPDATA%`** = `C:\Users\YourName\AppData\Local`
- **Steam default root** = `C:\Program Files (x86)\Steam\steamapps\common\`

---

## Modern Era (2019–Present) — Battle.net & Steam use the SAME path

### Call of Duty: Black Ops 7 (2025)
| Item | Detail |
|------|--------|
| **Internal codename** | cod25 |
| **Platform** | Battle.net & Steam |
| **Settings folder** | `%LOCALAPPDATA%\Activision\Call of Duty\Players\` |
| **File names** | `s.1.0.cod25.txt0`  `s.1.0.cod25.txt1` |
| **Full path example** | `C:\Users\USERNAME\AppData\Local\Activision\Call of Duty\Players\s.1.0.cod25.txt0` |

> Note: BO7 moved storage from Documents to LocalAppData — a change from prior titles.

---

### Call of Duty: Black Ops 6 (2024)
| Item | Detail |
|------|--------|
| **Internal codename** | cod24 |
| **Platform** | Battle.net & Steam |
| **Settings folder** | `%USERPROFILE%\Documents\Call of Duty\players\` |
| **File names** | `s.1.0.cod24.txt0`  `s.1.0.cod24.txt1` |
| **Full path example** | `C:\Users\USERNAME\Documents\Call of Duty\players\s.1.0.cod24.txt0` |

---

### Call of Duty: Modern Warfare III (2023)
| Item | Detail |
|------|--------|
| **Internal codename** | cod23 |
| **Platform** | Battle.net & Steam |
| **Settings folder** | `%USERPROFILE%\Documents\Call of Duty\players\` |
| **File name** | `options.4.cod23.cst` |
| **Full path example** | `C:\Users\USERNAME\Documents\Call of Duty\players\options.4.cod23.cst` |

---

### Call of Duty: Modern Warfare II (2022)
| Item | Detail |
|------|--------|
| **Internal codename** | cod22 |
| **Platform** | Battle.net & Steam |
| **Settings folder** | `%USERPROFILE%\Documents\Call of Duty\players\` |
| **File name** | `options.3.cod22.txt` |
| **Full path example** | `C:\Users\USERNAME\Documents\Call of Duty\players\options.3.cod22.txt` |

> Warzone 2.0 / Warzone Resurgence shares this same path as it runs within MW II.

---

### Call of Duty: Vanguard (2021)
| Item | Detail |
|------|--------|
| **Internal codename** | cod21 |
| **Platform** | Battle.net & Steam |
| **Settings folder** | `%USERPROFILE%\Documents\Call of Duty Vanguard\players\` |
| **File name** | `adv_options` (no extension) |
| **Full path example** | `C:\Users\USERNAME\Documents\Call of Duty Vanguard\players\adv_options` |

> ⚠️ Note: Vanguard uses a **separate** Documents subfolder (`Call of Duty Vanguard`) rather than the shared `Call of Duty` folder used by most other modern titles.

---

### Call of Duty: Black Ops Cold War (2020)
| Item | Detail |
|------|--------|
| **Internal codename** | cod20 |
| **Platform** | Battle.net & Steam |
| **Settings folder** | `%USERPROFILE%\Documents\Call of Duty\players\` |
| **File name** | `config.ini` |
| **Full path example** | `C:\Users\USERNAME\Documents\Call of Duty\players\config.ini` |

---

### Call of Duty: Modern Warfare (2019) / Warzone (Original)
| Item | Detail |
|------|--------|
| **Platform** | Battle.net (primary); Steam added later |
| **Settings folder** | Inside game install dir: `\main\players\player\` |
| **Battle.net default install** | `C:\Program Files (x86)\Call of Duty\Modern Warfare\` |
| **Full path example (Battle.net)** | `C:\Program Files (x86)\Call of Duty\Modern Warfare\main\players\player\` |
| **Steam path** | `%STEAM_ROOT%\steamapps\common\Call of Duty Modern Warfare\main\players\player\` |
| **File name** | `config.cfg` (also `config_mp.cfg` for multiplayer) |

> Note: MW 2019 predates the modern `Documents\Call of Duty` convention and stores settings inside the game install directory, similar to classic titles.

---

## Classic Era (Pre-2019) — Steam Only

### Call of Duty: WWII (2017)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty WWII\players2\` |
| **File names** | `user_config_mp.cfg` (multiplayer), `user_config.cfg` (single player) |

---

### Call of Duty: Modern Warfare Remastered (2017)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty Modern Warfare Remastered\players2\` |
| **File name** | `config` (opened via WordPad/text editor) |

---

### Call of Duty: Infinite Warfare (2016)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty - Infinite Warfare\players2\` |
| **File names** | `config_mp.cfg` (multiplayer), `config.cfg` (single player) |

---

### Call of Duty: Black Ops III (2015)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty Black Ops III\players\` |
| **File name** | `config.ini` |

---

### Call of Duty: Advanced Warfare (2014)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty Advanced Warfare\Players2\` |
| **File names** | `config_mp.cfg` (multiplayer), `config.cfg` (single player), `keys.cfg` (key bindings) |

---

### Call of Duty: Ghosts (2013)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty Ghosts\players2\` |
| **File names** | `config_mp.cfg` (multiplayer), `config.cfg` (single player) |

---

### Call of Duty: Black Ops II (2012)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty Black Ops II\players\` |
| **File names** | `hardware_mp.chp` / `hardware_zm.chp` (graphics), `user_*.cgp` (user profile/settings) |

> ⚠️ Note: Black Ops II uses **encrypted** config files. Direct text editing is not possible for most settings. Graphics options must be changed via the in-game menu.

---

### Call of Duty: Modern Warfare 3 (2011)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\call of duty modern warfare 3\players2\` |
| **File names** | `config_mp.cfg` (multiplayer), `config.cfg` (single player) |

---

### Call of Duty: Black Ops (2010)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\Call of Duty Black Ops\players\` |
| **File names** | `config_mp.cfg` (multiplayer), `config.cfg` (campaign/zombies) |

---

### Call of Duty: Modern Warfare 2 (2009)
| Item | Detail |
|------|--------|
| **Platform** | Steam only |
| **Settings folder** | `%STEAM_ROOT%\steamapps\common\call of duty modern warfare 2\players\` |
| **File names** | `config_mp.cfg` (multiplayer), `config.cfg` (single player) |

---

### Call of Duty: Black Ops 4 (2018) — Battle.net Only
| Item | Detail |
|------|--------|
| **Platform** | Battle.net ONLY (never released on Steam) |
| **Settings folder** | Inside game install dir: `\players\` |
| **File name** | `config.ini` |
| **Battle.net default install** | `C:\Program Files (x86)\Call of Duty Black Ops 4\players\` |
| **Full path example** | `C:\Program Files (x86)\Call of Duty Black Ops 4\players\config.ini` |

> Note: BO4 is a transitional title — it uses Battle.net exclusively and keeps its config inside the install directory rather than Documents. The config.ini supports tweaks like `max_fps`, `video_memory`, `worker_threads`, and `threaded_rendering`.

---

## Quick Reference Summary

| Game | Year | Platform | Folder | Key File(s) |
|------|------|----------|--------|-------------|
| Black Ops 7 | 2025 | BNet + Steam | `%LOCALAPPDATA%\Activision\Call of Duty\Players\` | `s.1.0.cod25.txt0/1` |
| Black Ops 6 | 2024 | BNet + Steam | `Documents\Call of Duty\players\` | `s.1.0.cod24.txt0/1` |
| Modern Warfare III | 2023 | BNet + Steam | `Documents\Call of Duty\players\` | `options.4.cod23.cst` |
| Modern Warfare II | 2022 | BNet + Steam | `Documents\Call of Duty\players\` | `options.3.cod22.txt` |
| Vanguard | 2021 | BNet + Steam | `Documents\Call of Duty Vanguard\players\` | `adv_options` |
| Black Ops Cold War | 2020 | BNet + Steam | `Documents\Call of Duty\players\` | `config.ini` |
| Modern Warfare 2019 | 2019 | BNet + Steam | `[InstallDir]\main\players\player\` | `config.cfg` |
| Black Ops 4 | 2018 | BNet ONLY | `[InstallDir]\players\` | `config.ini` |
| WWII | 2017 | Steam | `[InstallDir]\players2\` | `user_config_mp.cfg` |
| MWR | 2017 | Steam | `[InstallDir]\players2\` | `config` |
| Infinite Warfare | 2016 | Steam | `[InstallDir]\players2\` | `config_mp.cfg` |
| Black Ops III | 2015 | Steam | `[InstallDir]\players\` | `config.ini` |
| Advanced Warfare | 2014 | Steam | `[InstallDir]\Players2\` | `config_mp.cfg` |
| Ghosts | 2013 | Steam | `[InstallDir]\players2\` | `config_mp.cfg` |
| Black Ops II | 2012 | Steam | `[InstallDir]\players\` | `hardware_mp.chp` (encrypted) |
| Modern Warfare 3 | 2011 | Steam | `[InstallDir]\players2\` | `config_mp.cfg` |
| Black Ops | 2010 | Steam | `[InstallDir]\players\` | `config_mp.cfg` |
| Modern Warfare 2 | 2009 | Steam | `[InstallDir]\players\` | `config_mp.cfg` |

---

## Sources

- [Black Ops 6 Config File Instructions — JordanTBH.TV](https://jordantbh.tv/title/blackops6/settings/configuration/)
- [Black Ops 7 Config File Instructions — JordanTBH.TV](https://jordantbh.tv/title/blackops7/settings/configuration/)
- [MW II Config File Guide — JordanTBH.TV](https://jordantbh.tv/misc/cod-game-config-guide/)
- [MW3 2023 Save File Location — WhatIfGaming](https://whatifgaming.com/call-of-duty-mw3-save-file-location/)
- [CoD: MW2 2022 File Location — EaseUS](https://www.easeus.com/computer-instruction/call-of-duty-modern-warfare-2-file-location.html)
- [CoD: Warzone File Location — EaseUS](https://www.easeus.com/computer-instruction/call-of-duty-warzone-file-location.html)
- [Black Ops Cold War Save/Config File Location — GameNGuides](https://www.gamenguides.com/call-of-duty-black-ops-cold-war-save-game-data-and-configuration-files-location)
- [WWII Optimizations Guide — Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=1190554703)
- [Infinite Warfare Optimizations — Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=794242251)
- [Black Ops III Config Location — BlinksAndButtons](https://blinksandbuttons.net/where-is-bo3-config/)
- [Advanced Warfare Tweaks — Steam Community](https://steamcommunity.com/sharedfiles/filedetails/?id=353583821)
- [Ghosts Config File — Activision Community](https://community.activision.com/t5/Ghosts-PC/config-mp-cfg-file-is-empty/td-p/9110691)
- [Black Ops 2 Config Files — Se7enSins](https://www.se7ensins.com/forums/threads/release-bo2-profile-setting-config-files.815629/)
- [MWR Config Editor — GitHub](https://github.com/Bluscream/MWR-Config-Editor)
- [Black Ops 4 Optimization Guide — Prima Games](https://primagames.com/gaming/black-ops-4-144-fps-guide)
- [PCGamingWiki — Call of Duty series](https://www.pcgamingwiki.com/wiki/Call_of_Duty)
