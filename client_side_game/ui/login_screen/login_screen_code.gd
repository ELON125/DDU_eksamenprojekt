extends Control

# Declaring username and password input field variables
@onready var username_input_field = $username_panel/username_inputfield
@onready var password_input_field = $password_panel/password_input

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent()

func _handle_request_data(json_data):
	# Checking if the request was a login request
	scene_handler.high_score = str(json_data['user_data']['high_score'])
	scene_handler.player_account_id = str(json_data['user_data']['player_id'])
	
	# Switching screen since this signal will only be recieved if message was success
	scene_handler._switch_scenes('question_generator', true, self)

func _on_login_button_pressed():
	# Fetching username and password from the input fields
	var username = username_input_field.text
	var password = password_input_field.text
	
	# Sending login request to server 
	scene_handler._send_request({'email':username, 'password':password}, 'user_login')


func _on_signup_button_pressed():
	# Fetching username and password from the input fields
	var username = username_input_field.text
	var password = password_input_field.text
	
	# Sending signup request to server
	scene_handler._send_request({'email':username,'password':password}, 'user_signup')

# Functions for highlighting nodes when mouse is hovering
func _on_mouse_entered(hover_element_name):
	scene_handler._highlight_node(get_node(str(hover_element_name)))

func _on_mouse_exited(hover_element_name):
	scene_handler._end_highlight_node(get_node(str(hover_element_name)))
