extends Timer

@export var target_directory: String
@export var format_string: String

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
		DirAccess.make_dir_recursive_absolute(target_directory)
	texture.save_png(get_unique_path(target_directory, filename))


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_F12:
			take_a_screenshot()


# Preserve custom formats while preventing rapid captures from overwriting files.
static func get_unique_path(directory: String, filename: String) -> String:
	var path := directory.path_join(filename)
	var index := 1
	while FileAccess.file_exists(path):
		path = directory.path_join("%s_%03d.%s" % [
			filename.get_basename(), index, filename.get_extension()
		])
		index += 1
	return path
