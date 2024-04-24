extends Window

# Fetching the scenehandler
@onready var scene_handler = get_parent()

# Fetching the things related to the game guide pop up
@onready var game_guide_pop_up = get_parent().get_node('game_guide_pop_up')
@onready var game_guide_text_label = get_parent().get_node('game_guide_pop_up').get_node('guide_text_panel').get_node('guide_text_label')

# All the text for the help pop up
var help_text_dict = {
	'death_screen' : 'You have now lost the game, here you can see your high score and press play again to play once again',
	'level_selection' : 'Use the arrow buttons to choose what difficulty you would like to play on and press play when you are ready',
	'login' : 'Type in your username and password, and choose whether to login or signup',
	'question_generator' : 'You are now ready to start uploading your notes, on the bar belo  the game title choose whether you would like to upload new notes or use previous ones',
	'space_quiz' : 'Ready? You will now have to defend your spacestation, user the spaceship to shoot down incomming astroids. In the middle of the spacestation at the bottom you can see the amount of hp your spacestation has left shown as shields. Down there you can also see a green bar with a number next to it, this displays the amount of hp your spaceship has. When you get hit you will get a question generated from your notes, answer correct to survive!',
}

# Function called when the help button is pressed 
func _help_button_pressed():

	# Updating the text to the one related to the current scene
	game_guide_text_label.text = help_text_dict[str(scene_handler.current_scene)]
	
	# Showing the game guide
	game_guide_pop_up.visible = true
	
	# Checking if the current scene is space quiz because then game has to be pasued on help pressed
	if scene_handler.current_scene == 'space_quiz':
		scene_handler.get_node('space_quiz')._change_game_status(false)


func _on_guide_close_button_pressed():
	
	# Hiding the game guide
	game_guide_pop_up.visible = false
	
	# Checking if the current scene is space quiz because then game has to be pasued on help pressed
	if scene_handler.current_scene == 'space_quiz':
		scene_handler.get_node('space_quiz')._change_game_status(true)
