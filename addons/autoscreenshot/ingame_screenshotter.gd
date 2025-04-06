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
	var filename: String = format_string.format(datetime)

	print("Taking a in-game screen shot: ", filename)
	texture.save_png(target_directory.path_join(filename))
