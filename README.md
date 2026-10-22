# Auto Screenshot

Godot 4.7

Automatically take in-development screenshots of the full editor, the 2D or 3D
viewport, even in-game testing at regular intervals. Uses history to skip some
screenshots where presumably no visual work elapsed.

Icon modified from [Delapouite](https://delapouite.com/)'s [Photo Camera
Icon][camera-icon] and [Backward Time Icon][time-icon]

## Editor Settings

Options assigned as editor settings

|        Option          | Description |
| ---------------------- | ----------- |
| Enable 2D              | Take 2D viewport screenshots |
| Enable 3D              | Take 3D viewport screenshots |
| Enable Editor          | Take full screenshots of the Godot editor |
| Minutes per Screenshot | Minute interval to take screenshots |
| Start Automatically    | Start capture when the plugin loads or the game starts; disable to wait for the hotkey |
| Skip by History        | Only screenshot if detected a change in history |
| Target Folder          | Which directory to store screenshots |
| File Format String     | [Read more](#file-format-string) |
| Enable in Game         | Creates autoload to take in-game screenshots, not in exported games |
| Minutes per in Game_   | Minute interval to take screenshots in-game |
| Show Manual Button     | Press a button to manually take in-dev screenshots |

I recommend changing the target folder outside of the project's "user://"
directory. The default setting intends to work on any device, not a suitable
location for managing content.


## Start and Stop Shortcut

By default, press **Ctrl+Shift+F12** to start or stop automatic screenshots. In the editor,
this toggles editor/viewport capture. With the running game focused, it toggles
in-game capture instead (requires **Enable in Game**). The two capture sessions
are independent. The Output panel reports when capture starts or stops.

Change either binding in **Editor > Editor Settings > Shortcuts > Auto Screenshot**:
**Start/Stop Capture** toggles automatic capture; **Take Screenshot** saves one
capture (default **F12**). Use Godot's shortcut editor to record your preferred
key combination, add alternatives, clear a binding to disable it, or revert to
the default. Changes apply immediately in the editor and persist across restarts.
Restart a running game to apply the new bindings to playtesting. If both actions
share a binding, Start/Stop Capture takes priority.

To capture only when requested, disable **Start Automatically** under
**Editor > Editor Settings > Editors > Auto Screenshot**, then disable/re-enable
the plugin for the editor, or restart the game for in-game capture. Press the
shortcut once to start and again to finish. Screenshots already saved remain in
the target folder. Capture begins after the configured interval.

Changing screenshot settings keeps a stopped editor session stopped.
The enable switches and **Skip by History** still apply. The manual toolbar
button and **Take Screenshot** shortcut still take a single screenshot while
automatic capture is stopped. Holding a shortcut does not repeatedly toggle capture.

## File Format String

Takes several options. Classic datetime with `year`, `month`, `day`, `hour`,
`minute`, and `second`, and options for the `project` name, the open `scene` of
which the screenshot captures, and the `mode` of the capture i.e. the 2d
viewport (canvas), 3d viewport, full-editor, or in-game.

Default value: `{year}-{month}-{day}_{hour}.{minute}.{second}_{project}_{scene}_{mode}.png`

Always saves in `png` format.

[camera-icon]: https://game-icons.net/1x1/delapouite/photo-camera.html
[time-icon]: https://game-icons.net/1x1/delapouite/backward-time.html
