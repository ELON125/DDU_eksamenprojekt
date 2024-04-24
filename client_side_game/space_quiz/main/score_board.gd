extends Panel

# Fetching the game controller
@onready var space_quiz_node = get_parent()

#Fetching the scene handler
@onready var scene_handler = space_quiz_node.get_parent()

# Fetching the two text labels
@onready var high_score_text_label = get_node('high_score_label')
@onready var current_score_text_label = get_node('current_score_label')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_score_text_label.text = 'Current Score : ' + str(space_quiz_node.current_score)
	high_score_text_label.text = 'High Score : ' + str(scene_handler.high_score)
	
