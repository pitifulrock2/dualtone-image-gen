extends Panel

var save_file_path = "user://save/"
var save_file_name = "save_file.tres"
var image_path : String
var scale_amt = 0.1

func _ready():
	verify_save_dir(save_file_path)
	load_settings()

func verify_save_dir(path : String):
	DirAccess.make_dir_absolute(path)

func save_data():
	
	var save_library = {
		
		"image_scale" = $TextureRect.scale.x,
		"noise_on" = $TextureRect/Noise.visible,
		"shader_on" = $TextureRect/Shader.material.get_shader_parameter("enabled"),
		"image" = image_path
		
	}
	
	return save_library

func load_settings():
	if not FileAccess.file_exists("user://save_file.dat"):
		return
	var save_file = FileAccess.open("user://save_file.dat", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		var node_data = json.get_data()
		
		$TextureRect.scale = Vector2(node_data["image_scale"], node_data["image_scale"])
		$ScaleAmt.text = str("Current Scale: ", "%.2f" % node_data["image_scale"])
		
		$TextureRect/Noise.visible = node_data["noise_on"]
		$TextureRect/Shader.material.set("shader_parameter/enabled", node_data["shader_on"])
		
		var image = Image.new()
		image.load(node_data["image"])
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		$BG.texture = image_texture
		$BG2.texture = image_texture
		$TextureRect/BaseImage.texture = image_texture

func save_settings():
	var save_file = FileAccess.open("user://save_file.dat", FileAccess.WRITE)
	var json_string = JSON.stringify(save_data())
	
	print("saved to ", save_file.get_path_absolute())
	save_file.store_line(json_string)


func _process(delta: float) -> void:
	if Input.is_action_pressed("control"):
		if Input.is_action_just_pressed("mouse_up"):
			$TextureRect.scale += Vector2(scale_amt,scale_amt)
			$ScaleAmt.text = str("Current Scale: ", "%.2f" % $TextureRect.scale.x)
			save_settings()
		if Input.is_action_just_pressed("mouse_down"):
			$TextureRect.scale -= Vector2(scale_amt,scale_amt)
			$ScaleAmt.text = str("Current Scale: ", "%.2f" % $TextureRect.scale.x)
			save_settings()


func _on_noise_pressed() -> void:
	if $TextureRect/Noise.visible:
		$TextureRect/Noise.visible = false
	else:
		$TextureRect/Noise.visible = true
	save_settings()


func _on_dualtone_pressed() -> void:
	if $TextureRect/Shader.material.get_shader_parameter("enabled") == false:
		$TextureRect/Shader.material.set("shader_parameter/enabled",true)
	else:
		$TextureRect/Shader.material.set("shader_parameter/enabled",false)
	save_settings()


func _on_brightness_value_changed(value: float) -> void:
	$TextureRect/Shader.material.set_shader_parameter("brightness", value)
	save_settings()

func _on_bg_toggle_pressed() -> void:
	if $BG.visible:
		$BG.visible = false
		$BG2.visible = false
	else:
		$BG.visible = true
		$BG2.visible = true

func _on_file_pressed() -> void:
	$FileDialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	image_path = path
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	$BG.texture = image_texture
	$BG2.texture = image_texture
	$TextureRect/BaseImage.texture = image_texture
	save_settings()

func _on_palette_swap_pressed() -> void:
	$PaletteDialog.popup()

func _on_palette_dialog_file_selected(path: String) -> void:
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	$TextureRect/Shader.material.set_shader_parameter("PALETTE_TEXTURE", image_texture)
	$PaletteSwap/TextureRect.texture = image_texture


func _on_num_colors_value_changed(value: float) -> void:
	$NumColors/RichTextLabel2.text = str("Number of colors: ", int(value))
	$TextureRect/Shader.material.set_shader_parameter("num_colors", value)


func _on_precision_pressed() -> void:
	if scale_amt == 0.1:
		scale_amt = 0.01
	else:
		scale_amt = 0.1

func _on_minus_pressed() -> void:
	$TextureRect.scale -= Vector2(scale_amt,scale_amt)
	$ScaleAmt.text = str("Current Scale: ", "%.2f" % $TextureRect.scale.x)
	save_settings()

func _on_plus_pressed() -> void:
	$TextureRect.scale += Vector2(scale_amt,scale_amt)
	$ScaleAmt.text = str("Current Scale: ", "%.2f" % $TextureRect.scale.x)
	save_settings()
