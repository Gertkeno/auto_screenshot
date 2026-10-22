extends Timer

@export var target_directory: String
@export var format_string: String
@export var toggle_capture_shortcut: Shortcut = make_shortcut(KEY_F12, true, true)
@export var manual_capture_shortcut: Shortcut = make_shortcut(KEY_F12)

func _ready() -> void:
	# do not take automatic screenshots in exported builds
	if OS.has_feature("editor"):
		timeout.connect(take_a_screenshot)
	else:
		self.queue_free()


func take_a_screenshot() -> void:
	var viewport: Viewport = get_viewport()
	var texture := viewport.get_texture().get_image()

	var datetime: Dictionary = Time.get_datetime_dict_from_system()
	datetime["month"] = "%02d" % datetime["month"]
	datetime["day"] = "%02d" % datetime["day"]
	datetime["hour"] = "%02d" % datetime["hour"]
	datetime["minute"] = "%02d" % datetime["minute"]
	datetime["second"] = "%02d" % datetime["second"]
	var filename: String = format_string.format(datetime)

	print("Taking a in-game screen shot: ", filename)
	if not DirAccess.dir_exists_absolute(target_directory):
		DirAccess.make_dir_absolute(target_directory)
	texture.save_png(target_directory.path_join(filename))


func _input(event: InputEvent) -> void:
	if is_shortcut_pressed(event, toggle_capture_shortcut):
		if is_stopped():
			start()
			print("Auto Screenshot: in-game capture started")
		else:
			stop()
			print("Auto Screenshot: in-game capture stopped")
		get_viewport().set_input_as_handled()
	elif is_shortcut_pressed(event, manual_capture_shortcut):
		take_a_screenshot()
		get_viewport().set_input_as_handled()


static func is_shortcut_pressed(event: InputEvent, shortcut: Shortcut) -> bool:
	return shortcut != null and event.is_pressed() and not event.is_echo() \
		and shortcut.matches_event(event)


static func make_shortcut(keycode: Key, ctrl: bool = false, shift: bool = false) -> Shortcut:
	var key := InputEventKey.new()
	key.keycode = keycode
	key.ctrl_pressed = ctrl
	key.shift_pressed = shift
	var shortcut := Shortcut.new()
	shortcut.events = [key]
	return shortcut
