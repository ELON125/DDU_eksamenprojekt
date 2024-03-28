extends CharacterBody2D

# Speed of the movement
@export var speed = 400
@export var health = 1

# Fetching missile scene 
@onready var missile_scene = preload("res://space_quiz/spaceship_missile/missile.tscn")

func _physics_process(delta):
	# Checking if game is running
	if get_parent().game_running == false:
		return
	
	# Creating Vector2 the direction the spaceship is moving 
	var motion = Vector2()
	
	# Checking user input 
	if Input.is_action_pressed("ui_right"):
		motion.x += 1
	if Input.is_action_pressed("ui_left"):
		motion.x -= 1
	if Input.is_action_pressed("ui_down"):
		motion.y += 1
	if Input.is_action_pressed("ui_up"):
		motion.y -= 1
	
	# Checking if space is pressed for shooting missile
	if Input.is_action_just_pressed("space"):
		
		# Adding missile to space_quiz node as parent
		get_parent().add_child(missile_scene.instantiate())
	
	# Calculating the motion and moving
	move_and_collide(motion * speed * delta)
	
	# Checking if the spaceship should be telported to the other size if its touching the walls
	if self.position.x < 0: 
		
		#Moving spaceship to other side of screen minus 5 pixel so it doesnt enter a tp loop
		self.position.x = 880 - 5
	
	if self.position.x > 880:
	
		self.position.x = 0 + 5
	
	
