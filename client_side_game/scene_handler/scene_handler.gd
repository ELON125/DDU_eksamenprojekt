extends Node2D

# Instatiating all the scenes 
@onready var death_screen_scene = preload("res://ui/death_screen/death_screen.tscn")
@onready var level_selection_scene = preload("res://ui/level_selection/level_selection_scene.tscn")
@onready var login_scene = preload("res://ui/login_screen/login_screen_scene.tscn")
@onready var question_generator_scene = preload("res://ui/question_generator/question_generation_scene.tscn")
@onready var space_quiz_scene = preload("res://space_quiz/main/space_quiz.tscn")
@onready var lost_screen = preload("res://ui/death_screen/death_screen.tscn")

@onready var scene_dict = {
	'death_screen' : death_screen_scene,
	'level_selection' : level_selection_scene,
	'login' : login_scene,
	'question_generator' : question_generator_scene,
	'space_quiz' : space_quiz_scene,
	'lost_screen' : lost_screen
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
		
############## ERROR POP UP's ################
func _error_pop_up(error_message):
	# Setting the error pop up text
	get_node("error_pop_up/error_text_panel/error_text_label").text = error_message
	
	# Showing pop up
	get_node("error_pop_up").visible = true

func _on_error_close_button_pressed():
	# Hiding error pop up
	get_node("error_pop_up").visible = false
	
	
############### WEBREQUEST's ##################
func _send_request(data : Dictionary, dest : String):
	# Preparing data for webrequest
	var url = 'http://127.0.0.1:5000/' + dest
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	# Sending the request
	$HTTPRequest.request(url, headers, HTTPClient.METHOD_POST, json)

func _on_request_completed(result, response_code, headers, body):
	# Parsing the json response
	var json = JSON.parse_string(body.get_string_from_utf8())
	# Emitting the signal that data hase been returned
	emit_signal("request_data_received", json)
	
	# Checking if request was successful
	if 'error' in str(json):
		
		# Displaying an error pop up with the error message 
		_error_pop_up('An error happened : ' + str(json['error']))
	
	# Checking if response is null
	elif json == null:
		
		# Displaying an error pop up with the error message 
		_error_pop_up('An error happened : '  + 'No response recieved from server ')
	
	# Emitting signal with data if error checks were passed 
	else:
		
		# Emitting the signal that data hase been returned
		#emit_signal("request_data_received", json)
		return
