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
| Screenshots per Second | Editor capture rate; positive values override Minutes per Screenshot, 0 keeps the minute interval |
| Skip by History        | Only screenshot if detected a change in history |
| Target Folder          | Which directory to store screenshots |
| File Format String     | [Read more](#file-format-string) |
| Enable in Game         | Creates autoload to take in-game screenshots, not in exported games |
| Minutes per in Game_   | Minute interval to take screenshots in-game |
| In Game Screenshots per Second | In-game capture rate; positive values override Minutes per in Game, 0 keeps the minute interval |
| Show Manual Button     | Press a button to manually take in-dev screenshots |

I recommend changing the target folder outside of the project's "user://"
directory. The default setting intends to work on any device, not a suitable
location for managing content.


## Development Timelapse

For a Krita/Procreate-style timelapse of development, enable **Enable Editor**,
disable **Enable 2D**, **Enable 3D**, and **Enable in Game** if you only want the
full editor, turn **Skip by History** off, and set **Screenshots per Second** to
`1` or `2` as a starting point. Choose a target folder outside the project to
avoid importing the captured images into Godot. This records a PNG image sequence;
assemble it into a video with your preferred video editor. It does not record or
replay individual editing actions.

## Screenshots per Second

Enable the plugin, then open **Editor > Editor Settings > Editors > Auto Screenshot**
(enable **Advanced Settings** if needed). Set **Screenshots per Second** to your
requested editor capture rate, for example `5` for five captures per second.
Set **In Game Screenshots per Second** separately for playtesting, then start or
restart the game to apply in-game settings. Fractional rates such as `0.5` (one
capture every two seconds) are supported. Set a rate to `0` to use its existing
minute interval instead.

Turn **Skip by History** off for regular editor captures even when no edits are
made. The 2D, 3D, Editor, and In Game enable switches still apply. Each editor
capture can save both a viewport image and an editor image when enabled.

Capture rates are best effort: Godot timers run at most once per rendered frame,
and image readback and PNG saving can reduce the achieved rate. Capture timing
ignores game time scale. Screenshots sharing a filename receive numbered suffixes
(`_001`, `_002`, etc.) so multiple captures within a second are kept.

## File Format String

Takes several options. Classic datetime with `year`, `month`, `day`, `hour`,
`minute`, and `second`, and options for the `project` name, the open `scene` of
which the screenshot captures, and the `mode` of the capture i.e. the 2d
viewport (canvas), 3d viewport, full-editor, or in-game.

Default value: `{year}-{month}-{day}_{hour}.{minute}.{second}_{project}_{scene}_{mode}.png`

Always saves in `png` format.

[camera-icon]: https://game-icons.net/1x1/delapouite/photo-camera.html
[time-icon]: https://game-icons.net/1x1/delapouite/backward-time.html
