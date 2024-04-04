extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connecting the data_recieved signal to the _handle_request_data function in the new scene
	get_parent().scene_handler.connect(_on_mouse_entered())
	

func _on_mouse_entered():
	get_parent().scene_handler._highlight_node(self)
