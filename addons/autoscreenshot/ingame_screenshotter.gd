extends Timer

@export var target_directory: String
@export var format_string: String

func _ready() -> void:
	# do not take automatic screenshots in exported builds
	if OS.has_feature("debug"):
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
	DirAccess.make_dir_recursive_absolute(target_directory)
	var err := save_image_by_extension(texture, target_directory.path_join(filename))
	if err != OK:
		print("Failed to save screen shot :'( ", filename)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and event.keycode == KEY_F12:
			take_a_screenshot()


static func save_image_by_extension(img: Image, path: String) -> Error:
	var extension := path.get_extension().to_lower()
	if not extension in ["png", "jpg", "webp"]:
		print("Screenshot extension %s unrecognized, using png" % extension)
		extension = "png"
	var image_save_call: String = "save_%s" % extension

	return img.call(image_save_call, path)

