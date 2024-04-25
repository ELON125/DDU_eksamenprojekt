extends Control

# Declaring vars for file upload
@onready var file_upload_response_text = $file_upload_panel/file_upload_response_label
@onready var file_upload_name = $file_upload_panel/file_upload_name
@onready var uploaded_file = null

# Fetching the scroll contained
@onready var scroll_container = get_node('saved_notes_selection_panel/notes_scroll_container')

# Fetching the two different secetions
@onready var upload_file_section = get_node('file_upload_panel')
@onready var saved_notes_section = get_node('saved_notes_selection_panel')

# Variable for scenehanlder that hold all general functions for the differnt scenes
@onready var scene_handler = get_parent()

# Binding the viewport and files_dropped signal to the on_files_dropped function
func _ready():
	# Fetching the saved notes
	scene_handler._send_request({'user_id':scene_handler.player_account_id},'get_saved_notes',false)
	
	# Connecting files dropped to view port
	get_viewport().files_dropped.connect(on_files_dropped)

# Function for handling all webrequest
func _handle_request_data(json_data):

	# Checking if the return is fetching saved notes or the question list
	if 'saved_notes' in str(json_data):
		scene_handler.saved_notes = json_data['saved_notes']
		scroll_container._update()
	elif 'question_list' in str(json_data):
		# Checking if enough questions were generated
		if len(json_data['question_list']) != 10:
			scene_handler._error_pop_up('Please try again something went wrong while generating questions, not enought questions generated. Developers have been notified')
			return 
			
		# Setting the questions variable in the scene handler
		scene_handler.generated_questions = json_data['question_list']
		
		# Switching screen since this signal will only be recieved if message was success
		scene_handler._switch_scenes('level_selection', true, self)

# Function that will be called when files are dropped
func on_files_dropped(files):
	#Updating the file_upload_name with the name of the file that was upladed
	var file_name = files[0].split('/')[-1].split("\\")[-1]
	file_upload_name.text = file_name
	
	# Checking how many files have been dropped
	if len(files) > 1: 
		file_upload_response_text.text = 'Only 1 file can be upload at a time'
		return 
	
	# Checking the file type of the file dropped in the area
	var file_type = files[0].split('.')[-1]
	if file_type != 'pdf':
		file_upload_response_text.text = 'Only pdf files can be uploaded'
		return
		
	# Reading bytes from pdf file
	uploaded_file = FileAccess.get_file_as_bytes(files[0])
	
	# Converting PackedByteArray to a list 
	uploaded_file = Array(uploaded_file)
	
	# Checking if the file was read properly if fill is null means an error happened
	if uploaded_file == null:
		file_upload_response_text.text = 'An error happened while opening pdf file'
	else:
		file_upload_response_text.text = 'You notes have been successfully uploaded'
	

func _on_generate_questions_button_pressed():
	# Checking if if a file has been uploaded
	if uploaded_file != null:
		scene_handler._send_request({'uploaded_file_bytes':uploaded_file, 'amount':10, 'user_id':scene_handler.player_account_id, 'notes_title':file_upload_name.text.replace(".pdf","")},'gen_questions',false)
		
		file_upload_response_text.text = 'Generating questions this might take a minute'
	else:
		file_upload_response_text.text = 'Upload a file first!'


# Functions for highlighting nodes when mouse is hovering
func _on_mouse_entered(hover_element_name):
	scene_handler._highlight_node(get_node(str(hover_element_name)))

func _on_mouse_exited(hover_element_name):
	scene_handler._end_highlight_node(get_node(str(hover_element_name)))


func _on_previous_notes_section_pressed():
	upload_file_section.visible = false
	saved_notes_section.visible = true 
	
func _on_upload_file_section_pressed():
	saved_notes_section.visible = false 
	upload_file_section.visible = true
