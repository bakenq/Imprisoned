extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	
	if event.is_action_pressed("ui_cancel"): #esc btn
		set_visible(!get_tree().paused)
		get_tree().paused = !get_tree().paused



func _on_Button_pressed():
	get_tree().paused = false
	set_visible(false)
	
	
func set_visible(is_visible):
	for node in get_children():
		node.visible = is_visible


func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen


func _on_Exit_pressed():
	get_tree().quit()

