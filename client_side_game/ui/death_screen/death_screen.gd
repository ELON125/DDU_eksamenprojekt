extends Control

# Fetching level select scene 
@onready var scene_handler = get_parent()

# Fetching the 2 text score fields
@onready var game_score = get_node('game_score_panel/game_score')
@onready var high_score = get_node('hight_score_panel/high_score')

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
	
	scene_handler._switch_scenes('question_generator', true, self)
	
	
