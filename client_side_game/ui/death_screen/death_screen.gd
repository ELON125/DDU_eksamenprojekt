extends Control

# Fetching level select scene 
@onready var next_scene = preload("res://ui/level_selection/level_selection_scene.tscn").instantiate()

func _on_return_to_menu_button_pressed():
	
	# Adding the level selection screen to scene tree
	get_tree().root.add_child(next_scene)
	
	# Deleting own scene
	self.queue_free()
	
