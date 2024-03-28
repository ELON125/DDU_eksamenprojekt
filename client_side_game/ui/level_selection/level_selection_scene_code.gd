extends Control

@onready var panel_list = [$level_1_card_panel, $level_2_card_panel, $level_3_card_panel]
@onready var level_progress_bar = $level_progress_bar
var index = 0 

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent()

func _on_next_button_pressed():
	
	# Checking if the next index would be more than the amount of level card panels
	if index +1 > 2:
		return 
		
	# Updating the current index 
	index +=1
	
	# Hiding the previous panel  and showing the next panel
	panel_list[index -1].visible = false 
	panel_list[index].visible = true
		
	# Update progress bar 
	level_progress_bar.value = index + 1
		

func _on_previous_button_pressed():
	# Checking if the next index would be more than the amount of level card panels
	if index -1 < 0:
		return 
		
	# Updating the current index 
	index -=1
	
	# Hiding the previous panel  and showing the next panel
	panel_list[index + 1].visible = false
	panel_list[index].visible = true
	
	# Updating progressbar
	level_progress_bar.value = index + 1
	

func _on_play_buttn_pressed():
	# Makeing sure that question have been uploaded and saved in var
	if scene_handler.generated_questions != null:

		# Switching to game
		scene_handler._switch_scenes('space_quiz', true, self)
	
	else:
		
		# Raising error that question variable was empty
		scene_handler._error_pop_up('An error happened : ' + 'Generated questions not found try again')
		
		# Returning user to question generator 
		scene_handler._switch_scenes('question_generator', true, self)
		
