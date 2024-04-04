extends Control

# Declaring username and password input field variables
@onready var username_input_field = $username_panel/username_inputfield
@onready var password_input_field = $password_panel/password_input_field

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent()
	
func _ready():
	scene_handler._highlight_node(get_node('username_panel'))

func _handle_request_data(json_data):
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
	scene_handler._send_request({'email':username, 'password':password}, 'user_signup')


func _on_username_panel_mouse_entered():
	pass # Replace with function body.
