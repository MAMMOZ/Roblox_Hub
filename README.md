# Mammoz Hub Script UI

Reusable MAMMOZ HUB UI plus converted copies of the Lua scripts in the parent workspace.
The original files are not overwritten.

## Use the standalone library

```lua
local UI = loadstring(readfile("Mammoz-Hub-Script/MammozUI.standalone.lua"), "MammozUI")()

local Window = UI:CreateWindow({ Title = "MAMMOZ HUB" })
local Tab = Window:CreateTab({ Title = "Farm", Icon = "home" })
local Section = Tab:CreateSection("Farm controls")

Section:CreateToggle({
    Name = "Auto farm",
    CurrentValue = false,
    Callback = function(enabled)
        print(enabled)
    end,
})
```

`MammozUI.standalone.lua` is the only runtime file needed. It embeds the visual
backend, legacy-layout adapter, virtual-instance proxy, and compatibility API.
`MammozCompat.lua` supports the common Rayfield, WindUI, Fluent, Luna,
Obsidian-style, and older Mammoz APIs. All controls route to one Mammoz window.

For GitHub deployment, give the converter your raw file URL once. Every
converted game script will then fetch the same UI file when no local copy is
present:

```powershell
& .\Mammoz-Hub-Script\convert-all.ps1 -StandaloneUrl "https://raw.githubusercontent.com/USER/REPO/refs/heads/main/Mammoz-Hub-Script/MammozUI.standalone.lua"
```

Alternatively, set `getgenv().__MAMMOZ_STANDALONE_URL` (or
`getgenv().__MAMMOZ_RAW_BASE`) before executing a converted script.

## Files

- `MammozUI.standalone.lua`: deploy this single self-contained runtime file.
- `build-standalone.ps1`: regenerates the standalone file from the source modules.
- `MammozUI.lib.lua`, `MammozCompat.lua`, `MammozLegacyLayout.lua`, `MammozLegacyProxy.lua`: editable source modules used to build it.
- `init.lua`: optional loader that prefers the standalone file.
- `scripts/Peter Hub v2/loader.lua`: key loader and `PlaceId` router for JNKiE-hosted game scripts.
- `example.lua`: runnable API example.
- `scripts/`: converted copies preserving the source directory structure.
- `conversion-manifest.csv`: conversion status for every source file.
- `convert-all.ps1`: repeatable converter.
- `verify.ps1`: Luau compile and API contract checks.

## Deploy with JNKiE game routes

1. Upload these files to GitHub raw:
   - `MammozUI.standalone.lua`
   - `scripts/Peter Hub v2/PeterHubV2.lib.lua` (only when using the Peter Hub loader)

2. Obfuscate each game script separately, upload each one to JNKiE, then copy its
   `/download` URL into `GAME_ROUTES` inside `scripts/Peter Hub v2/loader.lua`.

3. Set `RAW_BASE_URL` in `scripts/Peter Hub v2/loader.lua` to the GitHub raw folder:

```lua
local RAW_BASE_URL = "https://raw.githubusercontent.com/USER/REPO/refs/heads/main/Mammoz-Hub-Script/"
```

4. Put each route URL into the matching entry:

```lua
{
    Key = "mm2",
    Name = "Murder Mystery 2",
    PlaceIds = { 142823291 },
    Url = "https://api.jnkie.com/api/v1/luascripts/public/<id>/download",
}
```

After key verification, the loader checks `game.PlaceId`, finds the matching route,
preloads the Mammoz UI core from raw, then executes the matching JNKiE script.

## Convert and verify

```powershell
& .\Mammoz-Hub-Script\build-standalone.ps1
& .\Mammoz-Hub-Script\convert-all.ps1
& .\Mammoz-Hub-Script\verify.ps1
& .\Mammoz-Hub-Script\tests\test.ps1
```

Framework-based scripts are redirected to Mammoz controls. In custom `Instance.new`
scripts, GUI constructors are replaced with an in-memory virtual tree and rebuilt as
Mammoz pages and controls. Menu `ScreenGui` objects are not instantiated, hidden, or
nested. Functional cursor, overlay, ESP, HUD, and similar auxiliary screens are detected
separately and materialized as Roblox UI so their visual behavior is not removed.
Callbacks connect directly to virtual button/input signals, so the original farm,
teleport, key, dropdown, and action logic remains attached to the Mammoz controls.

Mammoz uses one popup manager per window, supports controls added after initial startup,
captures callback failures in an `ERRORS` page, and persists configuration under
`Mammoz-Hub-Script/configs/<PlaceId>/` when the executor supports file APIs.

Current conversion coverage:

- 71 framework scripts use the Mammoz compatibility API.
- 54 custom `ScreenGui` scripts use the full Mammoz layout adapter.
- 8 logic-only scripts preload Mammoz but do not create an interface.
- 4 infrastructure files are preserved as converter inputs.

Non-UI instances continue to use Roblox's real `Instance.new`. Tween calls are routed
through a delegating service that handles virtual controls and forwards game-object
tweens to Roblox normally.
