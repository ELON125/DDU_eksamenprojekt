extends Window

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent().get_parent()

# Fetching the space quiz controller node 
@onready var space_quiz_controller_node = get_parent()

func _on_answer_pressed(extra_arg_0):
	# Fetching the button that was pressed
	var pressed_button = get_node(str(extra_arg_0))

	# Fetching the pressed button text
	var pressed_button_text = pressed_button.text 
	print(pressed_button_text)
	print(scene_handler.generated_questions[0]['answer'])
	# Checking if answer was correct
	if str(pressed_button_text) == scene_handler.generated_questions[0]['answer']:
		
		# Resuing game
		space_quiz_controller_node._change_game_status(true)
		
		# Removing the question used from the question list 
		scene_handler.generated_questions.pop_front()
	else: 
		
		scene_handler._switch_scenes('lost_screen',true,space_quiz_controller_node)
		
	#Hiding pop up window again
	self.visible = false
	

# Functions for highlighting nodes when mouse is hovering
func _on_mouse_entered(hover_element_name):
	scene_handler._highlight_node(get_node(str(hover_element_name)))

func _on_mouse_exited(hover_element_name):
	scene_handler._end_highlight_node(get_node(str(hover_element_name)))
