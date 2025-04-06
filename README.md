# Auto Screenshot

Automatically take in-development screenshots of the full editor, the 2D or 3D
viewport, even in-game testing at regular intervals. Uses history to skip some
screenshots where presumably no visual work elapsed.

## Editor Settings

Options assigned as editor settings

|        Option          | Description |
| ---------------------- | ----------- |
| Enable 2D              | Take 2D viewport screenshots |
| Enable 3D              | Take 3D viewport screenshots |
| Enable Editor          | Take full screenshots of the Godot editor |
| Minutes per Screenshot | Minute interval to take screenshots |
| Skip by History        | Only screenshot if detected a change in history |
| Target Folder          | Which directory to store screenshots |
| File Format String     | [Read more](#file-format-string) |
| Enable in Game         | Creates autoload to take in-game screenshots, not in exported games |
| Minutes per in Game_   | Minute interval to take screenshots in-game |
| Show Manual Button     | Press a button to manually take in-dev screenshots |

I recommend changing the target folder outside of the project's "user://"
directory. The default setting intends to work on any device, not a suitable
location for managing content.


## File Format String

Takes several options. Classic datetime with `year`, `month`, `day`, `hour`,
`minute`, and `second`, and options for the `project` name, the open `scene` of
which the screenshot captures, and the `mode` of the capture i.e. the 2d
viewport (canvas), 3d viewport, full-editor, or in-game.

Default value: `{year}-{month}-{day}_{hour}.{minute}.{second}_{project}_{scene}_{mode}.png`

Always saves in `png` format.
