extends Node2D

# A client id for when handeling webrequest 
var client_id = 'b1bd93c2dc9207d2'
var hash_security_token = 'd1b3a5bece9cb101'
var player_account_id : String
var saved_notes : Array

# Program state variables
var current_scene : String
var high_score : int
var current_score : int

# Instatiating all the scenes 
@onready var level_selection_scene = preload("res://ui/level_selection/level_selection_scene.tscn")
@onready var login_scene = preload("res://ui/login_screen/login_screen_scene.tscn")
@onready var question_generator_scene = preload("res://ui/question_generator/question_generation_scene.tscn")
@onready var space_quiz_scene = preload("res://space_quiz/main/space_quiz.tscn")
@onready var death_screen = preload("res://ui/death_screen/death_screen.tscn")

@onready var scene_dict = {
	'level_selection' : level_selection_scene,
	'login' : login_scene,
	'question_generator' : question_generator_scene,
	'space_quiz' : space_quiz_scene,
	'death_screen' : death_screen
}

# A signal being emitted when request data has been recieved
signal request_data_received(json_data)

# Variable keeping all the questions fetched for server
var generated_questions = null

func _ready():
	# Intiating login scene 
	_switch_scenes('login', false)

############## SCENE HANDLING ################

func _switch_scenes(next_scene : String, delete_last : bool, previous_scene = null):
	
	# Instantiateing the next scene here otherwise kernel error will happen when re calling a scene
	var scene_for_switch = scene_dict[next_scene].instantiate()
	
	# Deleting current scene and playing next one
	self.add_child(scene_for_switch)
	
	# Checking if the node needs webrequests by check if it has the _handle_request_data function
	if scene_for_switch.has_method('_handle_request_data'):
		
		# Connecting the data_recieved signal to the _handle_request_data function in the new scene
		request_data_received.connect(scene_for_switch._handle_request_data)
	
	# If deeete last scene true deleting previous scene 
	if delete_last:
		previous_scene.queue_free()
		
	# Updating the current scene variable
	current_scene = next_scene
		
		
############## ERROR POP UP's ####### #########

func _error_pop_up(error_message):
	# Setting the error pop up text
	get_node("error_pop_up/error_text_panel/error_text_label").text = error_message
	
	# Showing pop up
	get_node("error_pop_up").visible = true

func _on_error_close_button_pressed():
	# Hiding error pop up
	get_node("error_pop_up").visible = false
	
############## NODE HIGHLIGHT HANDLER ############

func _highlight_node(node):
	
	# Fetching the stylebox form the given node
	var styleBox = node.get_theme_stylebox("panel")

	# Highlighting the node with white 
	if styleBox != null:
		styleBox.shadow_color = Color(1, 1, 1)

func _end_highlight_node(node):
	
	# Fetching the stylebox form the given node
	var styleBox = node.get_theme_stylebox("panel")
	
	# Highlighting the node with white 
	if styleBox != null:
		styleBox.shadow_color = Color(0, 0, 0)
	
	
############### WEBREQUEST's ##################

# Variables holding the data and destination while the nonce is generated
var data_storage = null 
var dest_storage = null
var encrypt_outgoing_data_storage = null 

var server_url = 'http://172.104.132.48:40490/'
#var server_url = 'http://192.168.0.198:40490/'

func _create_data_hash(data):

	# Returning the hashed str
	return str(data).sha256_text()
	
# Function to call the Python script and get the encrypted mezssage
func encrypt_data(data):
	var new_dict = {}
	var debug_dict = {}
	for key in data:

		# Ensure the correct path to your Python script and adjust the python command as needed (e.g., python3)
		var pystdout = []
		var output = []
		# Get the directory path of the current game executable
		var game_dir = OS.get_executable_path()
		print('############# Using the following path to python encryption #############')
		print(game_dir+'/'+'client_side_encryption.exe')
		# Execute the executable
		OS.execute("client_side_encryption.exe",[data[key]], pystdout, true)
		OS.execute("client_side_encryption.exe",[key],pystdout, true)
		print('############# Encryption ouput #############')
		print(pystdout)
		# Adding the new encrypted key to thge dictionary
		new_dict[pystdout[1]] = pystdout[0]
			
		debug_dict[key] = pystdout[1]
		
	# Returning encrypted dict
	return new_dict
	
func _send_request(data : Dictionary, dest : String, encrypt_outgoing_data = true):
	# Updating the data and dest variables for when the nonce has been generated
	data_storage = data
	dest_storage = dest
	encrypt_outgoing_data_storage = encrypt_outgoing_data
	
	# Preparing data for webrequest
	var encrypted_json = JSON.stringify(encrypt_data({'client_id' : client_id}))
	var request_destination = server_url + 'create_nonce'
	
	# Sending the request
	$HTTPRequest.request(request_destination, ["Content-Type: application/json"], HTTPClient.METHOD_POST, encrypted_json)
	
func _on_request_completed(result, response_code, headers, body):
	# Parsing the json response
	var json_response = JSON.parse_string(body.get_string_from_utf8())
	print('############# Reponse from server #############')
	print(json_response)
	# Checking if request was successful
	if 'error' in str(json_response):
		
		# Displaying an error pop up with the error message 
		_error_pop_up('An error happened : ' + str(json_response['error']))
	
	# Checking if response is null
	elif json_response == null:
		
		# Displaying an error pop up with the error message 
		_error_pop_up('An error happened : '  + 'No response recieved from server ')
	
	# Checking if this was a normal server response or the one after nonce was generated
	elif 'nonce' in json_response:
		
		# Checking if the data should be encrypted
		if encrypt_outgoing_data_storage:
			# Encrypting the data 
			data_storage = encrypt_data(data_storage)
			
		# Preparing data for webrequest
		var json = JSON.stringify(data_storage)
		var request_destination = server_url + dest_storage
		
		# Creating a hash from the data, nonce, hash_security_token and client_id to prevent replay attacks, Im using the serialized json string to create the hash because the dictionary item order changes when serializing to dict
		var data_hash = _create_data_hash(str(json).replace(" ","") + client_id + hash_security_token + json_response['nonce'])

		# Encrypting request hash
		var data_hash_dict = encrypt_data({"request_hash":data_hash, 'client_id':client_id})

		# Now i can create a list the data storage which will get serialized the same way as when it was hashed, and then add the second element which is the data has, The reason im doing this as a list is so the json serialization doesnt change the order if request_hash is added to the dict
		var encrypted_json = JSON.stringify([json, data_hash_dict])
		# Canceling previous request othervise error will be caused
		$HTTPRequest.cancel_request()
		
		# Sending the request
		$HTTPRequest.request(request_destination, ["Content-Type: application/json"], HTTPClient.METHOD_POST, encrypted_json)
		
	# Emitting signal with data if error checks were passed  and its not a response containing the nonce
	else:
		
		# Emitting the signal that data hase been returned
		emit_signal("request_data_received", json_response) 
		
	

