extends Node

# ======== HELPER FUNCTIONS =============
## HELPER FUNCTIONS:
## Scans through a directory and returns an array of all the files it finds
## (Helper Function)
func scan_dir(path: String) -> Array:
	# PROPERTIES:
	var contents: Array = [] # A collection of file paths the function scanned in this directory
	
	# SCANNING DIR:
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Construct the full path leading to this iteration file
			var full_path: String = path.path_join(file_name)
			
			# If it's a file and not a subfolder
			if not dir.current_is_dir():
				# Add to collection
				contents.append(full_path)
			
			# Go to the next file
			file_name = dir.get_next()
	
	return contents
## HELPER FUNCTIONS:
## Scans through a directory recursively for subfolders
## and returns an array of all the files it finds
## (Helper Function)
func scan_dir_recursive(path: String) -> Array:
	# PROPERTIES:
	var contents: Array = [] # A collection of file paths the function scanned in this directory
	
	# SCANNING DIR:
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Construct the full path leading to this iteration file
			var full_path: String = path.path_join(file_name)
			
			# If we find a subfolder:
			if dir.current_is_dir():
				var subfolder_contents: Array = scan_dir_recursive(full_path)
				
				# Add the contents of the subfolder to the collection
				contents.append_array(subfolder_contents)
			else:
				# Add the file path to the collection
				contents.append(full_path)
			
			# Go to the next file
			file_name = dir.get_next()
	
	return contents
## HELPER FUNCTIONS:
## Recursively creates a directory with its subfolders if it doesn't exist
## (Helper Function)
func ensure_dir_exists(path: String):
	# Globalize the path
	var globalized_path = ProjectSettings.globalize_path(path)
	
	# Check if the directory exists
	if DirAccess.dir_exists_absolute(globalized_path):
		return
	else: # Create the recursive path to it
		DirAccess.make_dir_recursive_absolute(globalized_path)
## HELPER FUNCTIONS:
## Loads a JSON file from a valid path
## then returns it as a usable data structure (Dictionary/Array)
## (Helper Function)
func load_json(path: String, collection_type: String) -> Variant:
	# Reading file
	var file = FileAccess.open(path, FileAccess.READ)
	
	# Load file
	if file:
		var string = file.get_as_text()
		var parsed_json = JSON.parse_string(string) # Parse JSON file
		file.close()
		
		# Return if the parsed output doesn't match what the game expects
		if collection_type == "dictionary" and not parsed_json is Dictionary:
			return null
		if collection_type == "array" and not parsed_json is Array:
			return null
		
		return parsed_json
	else:
		return null
## HELPER FUNCTIONS:
## Writes the contents of a provided data into a provided path leading to a JSON file
## (Utiity Function)
func save_json(
	data: Variant, # The provided data (dictionary, array, etc)
	path: String # The provided path leading to a JSON file
): # START OF FUNCTION
	
	# Create new JSON file or rewrite existing one
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data, "\t") # Turns data into a usable JSON string
		file.store_string(json_string)
		file.close()
## HELPER FUNCTIONS:
## Checks whether a node has a specified property
## (Utility Function)
func has_property(target_node: Variant, property_name: StringName) -> bool:
	# Get the lists of all the property the node has
	for property in target_node.get_property_list():
		# Check whether one of them is property the function is looking for
		if property["name"] == property_name:
			return true
	
	return false
# END
# ===================================
