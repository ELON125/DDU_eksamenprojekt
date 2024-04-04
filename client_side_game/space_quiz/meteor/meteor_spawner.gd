extends Node2D

# Fetching the meteor scene
@onready var meteor_scene = preload("res://space_quiz/meteor/meteor.tscn")

# Fetching meteor spawn_timer
@onready var spawn_timer = get_node('meteor_spawn_timer')

# Variables to store the start time and spawn rates
var start_time: int
var initial_spawn_rate = 3
var min_spawn_rate = 1.5

# Time after which the game increases in difficulty, in seconds
var difficulty_increase_interval = 15

# Amount by which the spawn rate is adjusted
var spawn_rate_decrement = 0.2

func _ready():
	# Setting the initial spawn rate
	spawn_timer.wait_time = initial_spawn_rate
	# Capturing the start time in milliseconds
	start_time = Time.get_ticks_msec()

func get_seconds_elapsed() -> float:
	# Calculate the difference in time from game start to now in milliseconds
	var elapsed_time = Time.get_ticks_msec() - start_time
	# Convert milliseconds to seconds
	return elapsed_time / 1000.0

func _on_meteor_spawn_timer_timeout():
	# Generates a random float between 0 and 1
	var rand_value = randf()
	
	#Variable for how many meteors should be spawned
	var meteors_to_spawn : int
	
	# Checking the random float to see how many meteors should be spawned
	if rand_value < 0.7: 
		meteors_to_spawn = 1
	elif rand_value < 0.9:
		meteors_to_spawn = 2
	else:
		meteors_to_spawn = 3
	
	for x in range(meteors_to_spawn):
		# Checking if the game should be running
		if get_parent().game_running == false:
			return
		
		# Adding the meteor to the scene
		add_child(meteor_scene.instantiate())
	
	# Adding missiles to the spaceship based on amount of meteors spawned 
	get_parent().get_node('spaceship').ammunition = meteors_to_spawn + 1
	
	# Adjust the spawn rate based on time elapsed
	adjust_spawn_rate_based_on_time()

func adjust_spawn_rate_based_on_time():
	# Calculating how many time intervals have passed
	var time_intervals_passed = int(get_seconds_elapsed()/ difficulty_increase_interval)
	
	# Calculating the new spawn rate
	var new_spawn_rate = initial_spawn_rate - (spawn_rate_decrement * time_intervals_passed)
	
	# Check to be sure spawn rate does not fall under the minmum spawn rate
	var spawn_rate = max(min_spawn_rate, new_spawn_rate)
	
	#Updating the spawn rate time
	spawn_timer.wait_time = spawn_rate
	print(spawn_rate)
