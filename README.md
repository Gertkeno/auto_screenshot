# Auto Screenshot

Godot 4.3+

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
| Skip by History        | Only screenshot if detected a change in history |
| Target Folder          | Which directory to store screenshots |
| File Format String     | [Read more](#file-format-string) |
| Enable in Game         | Creates autoload to take in-game screenshots, not in exported games |
| Minutes per in Game_   | Minute interval to take screenshots in-game |
| Show Manual Button     | Press a button to manually take in-dev screenshots |
| Timelapse FPS          | How many frames to capture per second during a timelapse |

I recommend changing the target folder outside of the project's "user://"
directory. The default setting intends to work on any device, not a suitable
location for managing content.


## File Format String

Takes several options. Classic datetime with `year`, `month`, `day`, `hour`,
`minute`, and `second`, and options for the `project` name, the open `scene` of
which the screenshot captures, and the `mode` of the capture i.e. the 2d
viewport (canvas), 3d viewport, full-editor, or in-game.

Default value: `{year}-{month}-{day}_{hour}.{minute}.{second}_{project}_{scene}_{mode}.png`

Saves in png, webp, jpg, exr, or dds format (Godot's built in support) by extension.


## Timelapses

A shortcut is defined to start/stop a timelapse, by default Ctrl+F12.

Timelapses create a zip file at the same path as normal screenshots, but with a
`.zip` extension. PNG files are written to the zip as the timelapse is runninng.

Capturing the editor does halt for a little bit, timelapses will produce
consistent suttters.

Timelapses only capture the entire editor, unlike enable 2d/3d modes which only
capture the 2d or 3d viewport

You can create a video from the timelapse using tools like FFmpeg, after
unzipping the image sequence. Here's an example bash script, it takes in the
timelapse zip as argument `$1` with an output 30 frames per second.

```bash
mkdir temp
pushd temp
unzip -qq ../"$1"
ffmpeg -loglevel warning -i '%04d.png' -r 30 "../${1%.*}".mp4
popd
rm -r temp
```

[camera-icon]: https://game-icons.net/1x1/delapouite/photo-camera.html
[time-icon]: https://game-icons.net/1x1/delapouite/backward-time.html
