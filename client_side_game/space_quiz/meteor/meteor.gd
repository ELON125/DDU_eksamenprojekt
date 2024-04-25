extends CharacterBody2D

# Speed of the movement
@export var speed = randi_range(230,345)

# Fetching the game controller node 
@onready var space_quiz_controller_node = get_parent().get_parent()

func _ready():
	print('######## METEOR SPEED ########')
	print(speed)
	self.position = Vector2(randi_range(50,830),0)

func _physics_process(delta):
	# Checking if the game is running
	if space_quiz_controller_node.game_running == false:
		# Deleting meteors when game is paused
		self.queue_free()
	
	# Creating Vector2 containing the direction the asteroid is moving
	var motion = Vector2(0,1)
	
	# Moving the meteor
	var collision = move_and_collide(motion * speed * delta)

	# Checking if there vase a collision
	if collision:
		
		# Calling controller node that a collision happened 
		space_quiz_controller_node._on_meteor_collision(collision.get_collider(), self)
	
