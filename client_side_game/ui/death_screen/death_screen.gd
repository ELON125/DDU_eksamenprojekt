extends Control

# Fetching level select scene 
@onready var scene_handler = get_parent()

# Fetching the 2 text score fields
@onready var game_score = get_node('game_score_panel/game_score')
@onready var high_score = get_node('hight_score_panel/high_score')

# A variable to check that the data has been updated before continueing other wise this will mess up godot
var data_handled = false

# Fetching the return to menu button
@onready var return_to_menu_button = get_node("return_to_menu_button_panel/return_to_menu_button")

# Handling incommming data
func _handle_request_data(json_data):	
	data_handled = true
	
	# Switching scenes
	scene_handler._switch_scenes('question_generator', true, self)
	
func _ready():
	# Checking if the new score was a high score
	if scene_handler.current_score > scene_handler.high_score:
		scene_handler.high_score = scene_handler.current_score
	
	# Updating the scores
	game_score.text = str(scene_handler.current_score)
	high_score.text = str(scene_handler.high_score)
	
	# Updating the database with the new scores
	scene_handler._send_request({'new_high_score':str(scene_handler.high_score),'user_id':str(scene_handler.player_account_id)}, 'update_high_score')
	

func _on_return_to_menu_button_pressed():
	if data_handled == true:
		# Switching scenes
		scene_handler._switch_scenes('question_generator', true, self)
	else:
		
		# If data has not yet been handled by database updating button text
		return_to_menu_button.text = 'Loading...'
		
	
	
