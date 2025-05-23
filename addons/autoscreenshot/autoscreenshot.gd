@tool
extends EditorPlugin

# Get 2D, 3D, and editor viewport, time screenshots every x minutes if visible,
# check history version to prevent superflous extras.

# in-game screenshots as an autoload

# ProjectSettings.add_property_info(hint: Dictionary)
# editor/auto_screenshot/
# `  enable 2d
# `  enable 3d
# `  enable full-editor
# `  enable in-game
# `  minutes per screenshot
# `  skip by history
# `  minutes per in-game screenshot
# `  target folder
# `  file format string YYYY-MM-DD_hh.mm.ss_project_scene_mode.png

const INGAME_AUTOLOAD_NAME = "AutoScreenShotter"
const editor_settings_preface = "editors/auto_screenshot/"
var default_editor_settings: Dictionary = {
	"enable_2d": true,
	"enable_3d": true,
	"enable_editor": true,
	"minutes_per_screenshot": 15,
	"skip_by_history": true,
	"target_folder": "user://auto_screenshot",
	"file_format_string": "{year}-{month}-{day}_{hour}.{minute}.{second}_{project}_{scene}_{mode}.png",
	"enable_in_game": true,
	"minutes_per_in_game_screenshot": 3,
	"show_manual_button": true,
}

var editor_timer: Timer
var editor_manual_button: Button

var ur: EditorUndoRedoManager

func _enter_tree() -> void:
	ur = self.get_undo_redo()
	# Editor settings #
	var ed_settings := EditorInterface.get_editor_settings()
	for key: String in default_editor_settings.keys():
		var default: Variant = default_editor_settings[key]
		if !ed_settings.has_setting(editor_settings_preface + key):
			print("Making editor setting: ", editor_settings_preface + key)
			ed_settings.set(editor_settings_preface + key, default)
		ed_settings.set_initial_value(editor_settings_preface + key, default, false)

	ed_settings.add_property_info({
		"name": editor_settings_preface + "enable_2d",
		"type": TYPE_BOOL,
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "enable_3d",
		"type": TYPE_BOOL,
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "enable_editor",
		"type": TYPE_BOOL,
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "minutes_per_screenshot",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,240,1",
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "skip_by_history",
		"type": TYPE_BOOL,
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "show_manual_button",
		"type": TYPE_BOOL,
	});

	# file access
	ed_settings.add_property_info({
		"name": editor_settings_preface + "target_folder",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_GLOBAL_DIR,
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "file_format_string",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "{year}-{month}-{day}_{hour}.{minute}.{second}_{project}_{scene}_{mode}.png"
	})

	# in game screen shots, via autoload
	ed_settings.add_property_info({
		"name": editor_settings_preface + "enable_in_game",
		"type": TYPE_BOOL,
	})
	ed_settings.add_property_info({
		"name": editor_settings_preface + "minutes_per_in_game_screenshot",
		"type": TYPE_FLOAT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,240,1",
	})
	# Apply editor settings deferred to prevent history writes within commit.
	ed_settings.settings_changed.connect(editor_setting_changed, CONNECT_DEFERRED)

	# Timer Node #
	editor_timer = Timer.new()
	var base := EditorInterface.get_base_control()
	editor_timer.one_shot = false
	var minutes_per_screenshot: float = ed_settings.get_setting(editor_settings_preface + "minutes_per_screenshot") * 60
	editor_timer.wait_time = max(10.0, minutes_per_screenshot)

	base.add_child(editor_timer)

	editor_timer.timeout.connect(take_a_screenshot)
	var enable_2d: bool = ed_settings.get_setting(editor_settings_preface + "enable_2d")
	var enable_3d: bool = ed_settings.get_setting(editor_settings_preface + "enable_3d")
	var enable_editor: bool = ed_settings.get_setting(editor_settings_preface + "enable_editor")
	if enable_2d or enable_3d or enable_editor:
		print("Screenshots every %d minutes" % (editor_timer.wait_time / 60))
		editor_timer.start()
	else:
		print("Editor screenshots disabled")
		editor_timer.stop()

	if ed_settings.get_setting(editor_settings_preface + "enable_in_game"):
		make_in_game_screenshot_scene.call_deferred(ed_settings)

	# manual button
	if ed_settings.get_setting(editor_settings_preface + "show_manual_button"):
		make_manual_button()


func _exit_tree() -> void:
	editor_timer.queue_free()
	if editor_manual_button:
		editor_manual_button.queue_free()
		editor_manual_button = null
	self.remove_autoload_singleton(INGAME_AUTOLOAD_NAME)

	# don't do this lol
	#var ed_settings := EditorInterface.get_editor_settings()
	#for key in default_editor_settings.keys():
		#ed_settings.erase(editor_settings_preface + key)


func make_manual_button() -> void:
	if editor_manual_button:
		return
	editor_manual_button = Button.new()
	#editor_manual_button.text = "Screenshot"
	editor_manual_button.icon = load("res://addons/autoscreenshot/icon_small.png")
	editor_manual_button.tooltip_text = "Capture a screenshot"
	editor_manual_button.expand_icon = true
	editor_manual_button.custom_minimum_size.x = 30
	editor_manual_button.custom_minimum_size.y = 30
	add_control_to_container(CONTAINER_TOOLBAR, editor_manual_button)
	editor_manual_button.pressed.connect(take_a_screenshot)


var last_pics_of_open_scene: Dictionary = {}
func take_a_screenshot() -> void:
	var ed_settings := EditorInterface.get_editor_settings()
	# check history version #
	var edited_scene_root: Node = EditorInterface.get_edited_scene_root()
	var history_id: int = ur.get_object_history_id(edited_scene_root)
	var history_version: int = ur.get_history_undo_redo(history_id).get_version()
	var skip_by_history: bool = ed_settings.get_setting(editor_settings_preface + "skip_by_history")

	if last_pics_of_open_scene.has(edited_scene_root.scene_file_path):
		if skip_by_history and last_pics_of_open_scene[edited_scene_root.scene_file_path] == history_version:
			print("No scene change detected, skipping screenshot")
			return
	last_pics_of_open_scene[edited_scene_root.scene_file_path] = history_version

	# Deduce Screen Shots folder #
	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	var project_name: String = ProjectSettings.get_setting("application/config/name", "no-name")
	var scene_name: String = edited_scene_root.scene_file_path.get_file()
	var dot: int = scene_name.rfind(".")
	scene_name = scene_name.substr(0, dot)

	# formatter payload
	datetime["project"] = project_name
	datetime["scene"] = "unsaved" if scene_name.is_empty() else scene_name
	datetime["month"] = "%02d" % datetime["month"]
	datetime["day"] = "%02d" % datetime["day"]
	datetime["hour"] = "%02d" % datetime["hour"]
	datetime["minute"] = "%02d" % datetime["minute"]
	datetime["second"] = "%02d" % datetime["second"]
	var format_string: String = ed_settings.get_setting(editor_settings_preface + "file_format_string")

	# ensure directory
	var target_directory: String = ed_settings.get_setting(editor_settings_preface + "target_folder")
	DirAccess.make_dir_recursive_absolute(target_directory)

	# 2d/3d viewport
	var enable_2d: bool = ed_settings.get_setting(editor_settings_preface + "enable_2d")
	var enable_3d: bool = ed_settings.get_setting(editor_settings_preface + "enable_3d")
	var enable_editor: bool = ed_settings.get_setting(editor_settings_preface + "enable_editor")

	var filename: String
	var viewport: Viewport
	if (edited_scene_root is Node3D) and enable_3d:
		datetime["mode"] = "spatial"
		filename = format_string.format(datetime)
		viewport = EditorInterface.get_editor_viewport_3d()
	elif enable_2d: # default to 2d for non-3d? ed_setting/project setting for other?
		datetime["mode"] = "canvas"
		filename = format_string.format(datetime)
		viewport = EditorInterface.get_editor_viewport_2d()

	if viewport.size.x > 10 and viewport.size.y > 10:
		var img := viewport.get_texture().get_image()
		print("saving screenshot: ", filename)
		img.save_png(target_directory.path_join(filename))
	else:
		print("viewport too small to screenshot, maybe out of frame?")

	# editor viewport
	if enable_editor:
		datetime["mode"] = "editor"
		var editor_viewport := EditorInterface.get_base_control().get_viewport()
		var editor_img := editor_viewport.get_texture().get_image()
		var editor_filename: String = format_string.format(datetime)
		print("saving screenshot: ", editor_filename)
		editor_img.save_png(target_directory.path_join(editor_filename))


func has_autoload() -> bool:
	var autoload_path: String = ProjectSettings.get_setting("autoload/"+INGAME_AUTOLOAD_NAME, "")
	return not autoload_path.is_empty()


func editor_setting_changed() -> void:
	var ed_settings := EditorInterface.get_editor_settings()

	var enable_in_game: bool = ed_settings.get_setting(editor_settings_preface + "enable_in_game")
	# adding/removing singleton commits history.
	if enable_in_game:
		make_in_game_screenshot_scene(ed_settings)
	elif has_autoload():
		self.remove_autoload_singleton(INGAME_AUTOLOAD_NAME)
		last_timer_settings = {}
	
	var minutes_per_screenshot: float = ed_settings.get_setting(editor_settings_preface + "minutes_per_screenshot")
	var new_wait_time: float = max(10.0, minutes_per_screenshot * 60)

	var enable_2d: bool = ed_settings.get_setting(editor_settings_preface + "enable_2d")
	var enable_3d: bool = ed_settings.get_setting(editor_settings_preface + "enable_3d")
	var enable_editor: bool = ed_settings.get_setting(editor_settings_preface + "enable_editor")
	if enable_2d or enable_3d or enable_editor:
		if editor_timer.wait_time != new_wait_time:
			print("Screenshots every %d minutes" % (new_wait_time / 60))
		editor_timer.wait_time = new_wait_time
		if editor_timer.time_left > new_wait_time:
			editor_timer.start()
	else:
		editor_timer.stop()
	
	if ed_settings.get_setting(editor_settings_preface + "show_manual_button"):
		make_manual_button()
	else:
		if editor_manual_button:
			editor_manual_button.queue_free()
			editor_manual_button = null


var last_timer_settings: Dictionary = {}
func make_in_game_screenshot_scene(ed_settings: EditorSettings) -> void:
	# in-game timer properties
	var minutes: float = ed_settings.get_setting(editor_settings_preface + "minutes_per_in_game_screenshot")
	var target_directory: String = ed_settings.get_setting(editor_settings_preface + "target_folder")
	var format_string: String = ed_settings.get_setting(editor_settings_preface + "file_format_string")

	# The format string will not have editor data available, pre-format some
	var project_name: String = ProjectSettings.get_setting("application/config/name", "no-name")
	var editor_info: Dictionary = {
		"project": project_name,
		"scene": "na", # can't deduce which scene is playing (but probably main)
		"mode": "ingame",
	}
	var editor_info_formatted_string: String = format_string.format(editor_info)

	# deduce if in-game timer settings have updated and require a new autoload
	var skip_set_autoload: bool = not last_timer_settings.is_empty() \
		and last_timer_settings["format_string"] == editor_info_formatted_string \
		and last_timer_settings["wait_time"] == minutes \
		and last_timer_settings["target_directory"] == target_directory
	if skip_set_autoload:
		return

	# set export properties for packed scene
	var timer_script: Script = load("res://addons/autoscreenshot/ingame_screenshotter.gd")
	if timer_script == null:
		push_warning("Failed to load timer autoload script")
		return
	var timer := Timer.new()
	timer.name = "Autoscreenshot"
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	timer.set_script(timer_script)
	timer.wait_time = minutes * 60
	timer.target_directory = target_directory
	timer.format_string = editor_info_formatted_string
	timer.autostart = true

	last_timer_settings = {
		"format_string": editor_info_formatted_string,
		"wait_time": minutes,
		"target_directory": target_directory,
	}

	# save timer as scene to autoload
	const SCENE_PATH = "res://addons/autoscreenshot/ingame_timer.tscn"
	var scene := PackedScene.new()
	var packed_success := scene.pack(timer)
	if packed_success == OK:
		var resource_success := ResourceSaver.save(scene, SCENE_PATH)
		if resource_success == OK and not has_autoload():
			self.add_autoload_singleton(INGAME_AUTOLOAD_NAME, SCENE_PATH)
		else:
			push_warning("Failed to save scene as resource: ", error_string(resource_success))
	else:
		push_warning("Couldn't pack timer scene: ", error_string(packed_success))
	timer.queue_free()
