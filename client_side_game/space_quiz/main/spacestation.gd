extends CharacterBody2D

# Fetching controller node
@onready var space_quiz_controller_node = get_parent()

# Fetching all the shield textures
@onready var shield_textures = [get_node("shield_texture_1"),get_node("shield_texture_2"),get_node("shield_texture_3")]
@onready var health_label = get_node("health_label")
@onready var health_progress_bar = get_node("health_progressbar")

func _physics_process(delta):
	
	# Updating shields on spacestation
	for x in shield_textures:
		x.visible = false
		
	for x in range(0,space_quiz_controller_node.space_station_health):
		shield_textures[x].visible = true 

	# Updating remaining lifelines progressbar and label
	health_progress_bar.value = space_quiz_controller_node.lifelines
	health_label.text = str(space_quiz_controller_node.lifelines)
