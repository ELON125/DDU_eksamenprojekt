extends Node2D

# Fetching the question pop_up_scene
@onready var pop_up_scene_window = get_node('question_pop_up')
@onready var pop_up_question = pop_up_scene_window.get_node('question_panel').get_node('question_label')
@onready var pop_up_answer_1 = pop_up_scene_window.get_node('answer_1')
@onready var pop_up_answer_2 = pop_up_scene_window.get_node('answer_2')
@onready var pop_up_answer_3 = pop_up_scene_window.get_node('answer_3')

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent()

# Variables fr keeping track of game related stats
@export var space_station_health = 3
@export var lifelines = 10
var current_score = 0

# Variable  for saying if the game should be running
var game_running = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hiding the pop_up
	pop_up_scene_window.visible = false

func _change_game_status(game_running_status : bool):
	game_running =  game_running_status

func _show_question():
	
	# Updating saved score every time question are showed 
	scene_handler.current_score = current_score
	
	#Updating lifelines 
	lifelines -=1
	
	if lifelines >= 1:
		# Checking if player has any lifelines left
		pop_up_scene_window.visible = true
		
		# Updating the pop up with the question
		pop_up_answer_1.text = scene_handler.generated_questions[0]['options'][0]
		pop_up_answer_2.text = scene_handler.generated_questions[0]['options'][1]
		pop_up_answer_3.text = scene_handler.generated_questions[0]['options'][2]
		pop_up_question.text = scene_handler.generated_questions[0]['question']
	else: 

		scene_handler._switch_scenes('death_screen',true,self)
	
func _on_meteor_collision(collider_obj, meteor_obj):
	
	# Checking if it was the spaceship that collided with the meteor 
	if collider_obj.name == 'spaceship':
			
		# Stopping game and showing question
		_change_game_status(false)
		_show_question()
		
		meteor_obj.queue_free()
		
	if collider_obj.name == 'spacestation':
		#Updating health
		space_station_health -=1
		
		# If spaceship has ran out of hp showing lost screen
		if space_station_health < 1:
			scene_handler._switch_scenes('death_screen',true,self)
			
		meteor_obj.queue_free()
		
