extends CharacterBody2D

# Speed of the movement
@export var speed = 1000

# Fetching spaceship node
@onready var spaceship = get_parent().get_node('spaceship')

# Fecthing game controller node
@onready var space_quiz_controller_node = get_parent()

func _ready():
	self.position = Vector2(spaceship.position.x,spaceship.position.y - 175)

func _physics_process(delta):

	# Checking if the game is running
	if space_quiz_controller_node.game_running == false:
		return
		
	# Creating Vector2 containing the direction the missile is moving
	var motion= Vector2(0,-1)
	
	# Moving the meteor
	var collision = move_and_collide(motion * speed * delta)
	
	# Checking if there vase a collision
	if collision:
		
		# Variable containing collided node
		var collider = collision.get_collider()
		
		# Making sure collider was not spaceship or space station
		if collider.name != 'spaceship' and collider.name != 'spacestation':
			# Deleting collided meteor
			collider.queue_free()
			
			#Deleting the missile after it has hit something
			self.queue_free()
			
			# Updating the score 
			space_quiz_controller_node.current_score +=1
