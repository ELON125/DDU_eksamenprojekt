extends ScrollContainer

# Notes container 
@onready var notes_container = get_node('notes_container')

# Fetching the scenhandler
@onready var scene_handler = get_parent().get_parent().get_parent()

# Fetching the saved notes label
@onready var saved_notes_help_label = get_parent().get_node('saved_notes_help_label')

# Binding the viewport and files_dropped signal to the on_files_dropped function
func _update():
		
	# Updating the size of the scroll bars
	self.get_v_scroll_bar().custom_minimum_size.x = 15
	self.get_h_scroll_bar().custom_minimum_size.y = 15
	
	# Editing the saved notes help label
	saved_notes_help_label.text = 'Select a file to start generate questions'
	# Spawning the buttons for each saved note
	for title in scene_handler.saved_notes:
		_add_label(title.replace(".pdf",""))
	
func _add_label(label_text):
	# Dupplicating the node 
	var new_button = get_node('notes_container/label_button').duplicate()
	
	# Editing text
	new_button.text = label_text
	
	# Editing visibily
	new_button.visible = true
	
	# Connect self to the pressed signal
	new_button.connect("pressed", _on_label_button_pressed.bind(new_button))
	
	# Adding the new node to the container
	notes_container.add_child(new_button)


func _on_label_button_pressed(button):
	# Editing the saved notes help label
	saved_notes_help_label.text = 'Generation questions this might take a minute'
	
	# Sending request after questions
	scene_handler._send_request({'amount':10, 'user_id':scene_handler.player_account_id, 'notes_title':button.text },'gen_questions',false)
