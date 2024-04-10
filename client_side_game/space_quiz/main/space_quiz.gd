extends Node2D

############# TODO LIST #############
# Implement a system where missile fall from the sky and need to be picked up
# Finish ui for the ggame part
# Create a proper algorithm for calucalting how many meteors should be spawned
# Create another way to recieve question otherwise they will all come in the end. Mayb make the respawn timer restart or reduce by something

# Fetching the question pop_up_scene
@onready var pop_up_scene_window = get_node('question_pop_up')
@onready var pop_up_question = pop_up_scene_window.get_node('question_panel').get_node('question_label')
@onready var pop_up_answer_1 = pop_up_scene_window.get_node('answer_1')
@onready var pop_up_answer_2 = pop_up_scene_window.get_node('answer_2')
@onready var pop_up_answer_3 = pop_up_scene_window.get_node('answer_3')

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent()

# Fetching the spacestation for updating health on meteor impact
@export var space_station_health = 3
@export var lifelines = 10

# Variable  for saying if the game should be running
var game_running = true

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hiding the pop_up
	pop_up_scene_window.visible = false

func _change_game_status(game_running_status : bool):
	game_running =  game_running_status

func _show_question():
	
	if lifelines >= 1:
		# Checking if player has any lifelines left
		pop_up_scene_window.visible = true
		
		# Updating the pop up with the question
		pop_up_answer_1.text = scene_handler.generated_questions[0]['options'][0]
		pop_up_answer_2.text = scene_handler.generated_questions[0]['options'][1]
		pop_up_answer_3.text = scene_handler.generated_questions[0]['options'][2]
		pop_up_question.text = scene_handler.generated_questions[0]['question']
	else: 
		scene_handler._switch_scenes('lost_screen',true,self)
	
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
		
		# If spaceship has ran out of hp then stopping game and showing question
		if space_station_health < 1:
			_change_game_status(false)
			_show_question()
			
		meteor_obj.queue_free()
	
