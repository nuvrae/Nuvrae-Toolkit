extends Node

# ========= CONSTRUCTORS =============
var PRESET_CALLABLES: Dictionary = {
	"move": _preset_move,
	"slide": _preset_slide,
	"orbit": _preset_orbit,
	"scale": _preset_scale,
	"rotate": _preset_rotate,
	"fade": _preset_fade,
	"change_property": _preset_change_property,
	"shake": _preset_shake,
}
# ========================================

# ========= CACHE ===============
## Responsible for registering and tracking active animations, storing their tween instances,
## and preserving the original property values of modified nodes for loop restoration
var animation_cache: Dictionary = {}
# ===============================

# ========= PRESETS ============
## PRESET: MOVE
## Moves the target node into a specified position.
## 
## PARAMETERS:
## - target_node: The node that will be animated.
## - target_position: The destination position (Vector2).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
## 
## (Helper Function)
func _preset_move(tween: Tween, params: Dictionary):
	tween.tween_property(
		params["target_node"], 
		"position", 
		params["target_position"], 
		params["duration"]
	).set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: SLIDE
## Slides the target node from its original position to a specified distance.
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - distance: The positional offset applied to the target node (float).
## - direction: The direction which the node slides out to (Vector2 Directions).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
##
## (Helper Function)
func _preset_slide(tween: Tween, params: Dictionary):
	# Determines the position where the target node is gonna slide out to
	var slide_offset: Vector2 = (params["direction"] * params["distance"])
	
	# Animate the target node to the calculated slide position
	tween.tween_property(
		params["target_node"],
		"position",
		slide_offset,
		params["duration"]
	).as_relative().set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: ORBIT
## Makes the target node revolve around a specified center point.
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - center_point: The center position of the orbit (Vector2).
## - radius: The distance between the target node and the orbit center (float).
## - orbit_angle: The initial angle of the orbit in degrees (float).
## - rotation_speed_deg: The angular rotation speed in degrees per second (float).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
##
## (Helper Function)
func _preset_orbit(tween: Tween, params: Dictionary):
	# Calculate the total angular distance the target node will travel based on its rotation speed and animation duration
	var rotation_distance = params["rotation_speed_deg"] * params["duration"]
	
	# Create a lambda function responsible for calculating and updating the target node's position throughout the orbit
	var update_orbit = func(angle_degrees: float):
		# Convert the current orbit angle from degrees into radians
		var angle_radians = deg_to_rad(angle_degrees)
		
		# Calculate the target node's positional offset relative to the orbit's center point
		var orbit_offset = Vector2(
			cos(angle_radians),
			sin(angle_radians)
		) * params["radius"]
		
		# Apply the calculated orbit position to the target node
		params["target_node"].position = params["center_point"] + orbit_offset
	
	# Animate the orbit angle from its initial value to the calculated final angle
	# This continuously updates the target node's position through the lambda function
	tween.tween_method(
		update_orbit,
		params["orbit_angle"],
		params["orbit_angle"] + rotation_distance,
		params["duration"]
	).set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: SCALE
## Scales the target node towards a specified scale value.
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - target_scale: The destination scale (Vector2).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
##
## (Helper Function)
func _preset_scale(tween: Tween, params: Dictionary):
	tween.tween_property(
		params["target_node"], 
		"scale", 
		params["target_scale"], 
		params["duration"]
	).set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: ROTATE
## Rotates the target node towards a specified angle.
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - target_angle: The destination rotation angle in degrees (float).
## - rotation_direction: The direction of rotation (clockwise or counterclockwise).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
##
## (Helper Function)
func _preset_rotate(tween: Tween, params: Dictionary):
	# Determine the final rotation angle based on the specified rotational direction
	var final_angle: float
	match params["rotation_direction"]:
		"clockwise":
			final_angle = params["target_angle"]
		"counterclockwise":
			final_angle = -params["target_angle"]
	
	# Animate the target node's rotation towards the calculated final angle
	tween.tween_property(
		params["target_node"],
		"rotation_degrees",
		final_angle,
		params["duration"]
	).set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: FADE
## Gradually fade the target node's opacity into a specified opacity
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - target_opacity: The target opacity value (float, 0.0–1.0).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
##
## (Helper Function)
func _preset_fade(tween: Tween, params: Dictionary):
	# Animate the target node's opacity towards full visibility
	tween.tween_property(
		params["target_node"],
		"modulate:a",
		params["target_opacity"],
		params["duration"]
	).set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: CHANGE PROPERTY
## Gradually change the target node's specific property's value into a specified value.
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - target_property: The property that will be modified (String).
## - target_value: The target value (Variant).
## - duration: The animation duration in seconds.
## - trans: The transition type used by the tween.
## - ease: The easing mode used by the tween.
##
## (Helper Function)
func _preset_change_property(tween: Tween, params: Dictionary):
	# Validate whether the target node actually has the target property
	if not Helpers.has_property(params["target_node"], params["target_property"]):
		push_error("Target node doesn't have '%s', check if there's any typo's. Skipping step for now." % [params["target_property"]])
		return
	
	# Animate the target property to the specified value
	tween.tween_property(
		params["target_node"],
		params["target_property"],
		params["target_value"],
		params["duration"]
	).set_trans(params["trans"]).set_ease(params["ease"])
## PRESET: SHAKE
## Applies a shaking animation by repeatedly offsetting the target node's position.
##
## PARAMETERS:
## - target_node: The node that will be animated.
## - intensity: The maximum positional offset applied during the shake (float).
## - frequency: How frequent the shake actually happens (float, Hz).
## - shake_direction: The axis along which the shake is applied (x_axis, y_axis, or both).
## - duration: The animation duration in seconds.
## - decay_trans: The transition type applied to the decay.
## - decay_ease: The ease type applied to the decay.
##
## (Helper Function)
func _preset_shake(tween: Tween, params: Dictionary):
	## INTIALIZATION:
	# Store the target node's original position for later reference
	var original_pos = {"value": Vector2.ZERO}
	# Store the previous shake frequency index to determine when a new shake should occur
	var previous_shake_index = {"value": -1}
	# Store the current decay progress to dynamically adjust the shake intensity
	var decay_progress = {"value": 0.0}
	# NOTE: Dictionaries allow their stored values to be modified inside lambda functions
	
	# Capture the target node's position when the shake operation actually begins
	tween.tween_callback(
		func():
			original_pos["value"] = params["target_node"].position
	)
	
	## LOGIC:
	# Create a lambda function responsible for generating and applying randomized shake offsets
	# at the specified frequency intervals
	var do_shake = func(time):
		# Calculate the current shake index
		var shake_index = floori(time * params["frequency"])
		
		# Calculate the remaining shake intensity based on the decay progress
		var current_intensity: float = lerp(
			params["intensity"],
			0.0,
			decay_progress["value"]
		)
		
		# Compare whether we reached a new shake threshold
		if shake_index != previous_shake_index["value"]:
			previous_shake_index["value"] = shake_index
			
			# Generate a randomized offset based on the specified shake intensity
			var shake_offset: float = randf_range(-1.0, 1.0) * current_intensity
			
			# Apply randomized positional offsets according to the specified direction
			match params["shake_direction"]:
				"x_axis":
					params["target_node"].position.x = original_pos["value"].x + shake_offset
				"y_axis":
					params["target_node"].position.y = original_pos["value"].y + shake_offset
				"both":
					params["target_node"].position = original_pos["value"] + Vector2(shake_offset, shake_offset)
				# NOTE: "Both" essentially shakes it at a diagonal, this is an intentional design.
	
	# Create another lambda function responsible for updating the shared decay progress
	var do_decay = func(progress):
		decay_progress["value"] = progress
	
	# Animate the decay progress alongside the shake animation using the specified transition and easing
	tween.parallel().tween_method(
		do_decay,
		0.0,
		1.0,
		params["duration"]
	).set_trans(params["decay_trans"]).set_ease(params["decay_ease"])
	
	# Animate the shake function alongside the decay animation over the specified duration
	tween.parallel().tween_method(
		do_shake,
		0.0,
		params["duration"],
		params["duration"]
	)
	
	# Restore to the node's original position with zero shake offset
	tween.tween_callback(
		func():
			params["target_node"].position = original_pos["value"]
	)
# ==============================

# ========= ANIMATION ===========
## ANIMATION:
## Acts as the execution layer for animations, translating an animation timeline into an actual tween animation
## (Core Function)
func play_animation(
	animation: Array, 
	id: String = "", 
	looped: bool = false, 
	default_target: Variant = null
):
	## INITIALIZATION:
	# Create a tween object that will be responsible for playing the animation
	var tween = create_tween()
	
	## ANIMATION REGISTRATION:
	# Check whether an animation ID is actually provided, otherwise create it automatically
	var animation_id: String
	if id.is_empty():
		# Generate a new ID
		animation_id = _generate_animation_id()
		
		# Generate a new ID until there's no match for guaranteed uniqueness
		while animation_cache.has(animation_id):
			animation_id = _generate_animation_id()
		# NOTE: Animations with automatic ID's can't be managed! This is an intentional design.
	else:
		# Use the provided ID instead
		if not animation_cache.has(animation_id):
			animation_id = id
		else:
			push_error("Cannot play animation with ID '%s', there's already an existing animation with that ID!" % [animation_id])
			return
	
	# Register the newly created tween and initialize a container for caching
	# the original property values of affected nodes
	animation_cache[animation_id] = {
		"tween": tween,
		"original_states": {}
	}
	
	# Loop the animation if looped is true
	if looped:
		tween.set_loops()
	
	## TIMELINE EXECUTION:
	# Go through each step inside the received animation's timeline
	for step in animation:
		## STEP DATA RETRIEVAL:
		# Retrieve the properties of this step
		var type: String = step["type"]
		var preset: String = step["preset"]
		var params: Dictionary = step["params"]
		
		## TARGET RESOLUTION:
		# Check if the parameters contain a target node, otherwise use the received default target node
		var target_node: Variant
		if params.has("target_node"): # If it has a specified target node
			target_node = params["target_node"]
		elif default_target != null: # If it doesn't have a specified target node and has a default one
			target_node = default_target
		else: # If it doesn't have either
			push_error("No target nodes found! Returning Early")
			# Cleanup: Kill the existing tween and release the animation from cache
			tween.kill()
			_release_animation(animation_id)
			# Return
			return
		
		## RUNTIME PARAMETER PREPARATION:
		# Create a duplicate of the original parameters to serve as the runtime parameters.
		# This allows the system to inject or modify values, such as the target node,
		# without altering the original animation definition, preserving its reusability.
		var runtime_params = params.duplicate()
		runtime_params["target_node"] = target_node
		
		## PROPERTY CACHE INITIALIZATION:
		# Initialize the target node's property cache if it hasn't been registered yet
		if not animation_cache[animation_id]["original_states"].has(target_node):
			animation_cache[animation_id]["original_states"][target_node] = {}
		
		## PROPERTY RETRIEVAL:
		# Retrieve the property that the current preset is going to modify
		var target_property = _get_preset_binded_property(preset, runtime_params)
		if target_property == null:
			push_error("Failed to retrieve the property associated with preset '%s'!" % [preset])
			continue
		
		## PROPERTY STATE PRESERVATION:
		# Capture and cache the property's original value before any modifications are applied
		# Only cache each property once to prevent subsequent presets from overwriting its original value
		if not animation_cache[animation_id]["original_states"][target_node].has(target_property):
			animation_cache[animation_id]["original_states"][target_node][target_property] = target_node.get_indexed(target_property)
		
		## PRESET RETRIEVAL:
		# Retrieve the callable associated with the requested preset operation
		var preset_callable = _get_preset_callable(preset)
		if preset_callable.is_null():
			push_error("Failed to get the callable of the preset! Is there a typo in the preset field?")
			continue
		
		## TWEEN METHOD SELECTION:
		# Select the appropriate tween method based on the step's execution type
		var tween_method = tween.chain if type == "sequential" else tween.parallel
		
		## PRESET EXECUTION:
		# Execute the preset operation using the selected tween method and its parameters
		preset_callable.call(tween_method.call(), runtime_params)
	
	## ANIMATION LIFECYCLE:
	# Run this code block only if the animation is still active
	while animation_cache.has(animation_id):
		## LOOP RESTORATION:
		# If the animation is looping, restore all affected nodes to their original states
		if looped:
			await tween.loop_finished
			
			## PROPERTY RESTORATION:
			for node in animation_cache[animation_id]["original_states"]:
				# Iterate through every property modified by the animation and restore its cached original value
				for property in animation_cache[animation_id]["original_states"][node]:
					# Restore the property's initial value to reset the node's state before the next loop iteration
					node.set_indexed(property, animation_cache[animation_id]["original_states"][node][property])
		
		## ANIMATION CLEANUP:
		# Wait for the tween animation to finish before actually releasing it from cache
		else:
			await tween.finished
			_release_animation(animation_id)
## ANIMATION:
## Stops an active tween and kills it
## (Core Function)
func stop_animation(animation_id):
	# Check whether the animation is actually active and running by checking the animation cache
	if animation_cache.has(animation_id):
		animation_cache[animation_id]["tween"].kill()
		_release_animation(animation_id) # Release from cache
	else:
		push_error("Game failed to find the animation '%s', either there's a typo or the animation has finished!" % [animation_id])
## ANIMATION:
## Pauses or resumes an active tween
## (Core Function)
func toggle_animation_pause(animation_id):
	# Check whether the animation is actually active and running by checking the animation cache
	if animation_cache.has(animation_id):
		if animation_cache[animation_id]["tween"].is_running(): # PAUSING
			animation_cache[animation_id]["tween"].pause()
		else: # RESUMING
			animation_cache[animation_id]["tween"].play()
	else:
		push_error("Game failed to find the animation '%s', either there's a typo or the animation has finished!" % [animation_id])
# ===============================

# ======== UTILITIES =============
## UTILITY:
## Generates a random unqieu ID for identifying animations
## (Utility Function)
func _generate_animation_id() -> String:
	# Define the number of random bytes used to generate the ID
	var length: int = 20
	
	# Generate cryptographically secure random bytes using Crypto
	var crypto: Crypto = Crypto.new()
	var random_bytes: PackedByteArray = crypto.generate_random_bytes(length)
	
	# Convert the random bytes into a Base64 string
	return Marshalls.raw_to_base64(random_bytes)\
		.replace("/", "_")\
		.replace("+", "-")\
		.replace("=", "")
## UTILITY:
## Removes the cache associated with an animation
## (Utility Function)
func _release_animation(id):
	# Remove cache
	if animation_cache.has(id):
		animation_cache.erase(id)
## UTILITY:
## Get the requested callable for a preset operation and returns it.
## (Utility Function)
func _get_preset_callable(preset) -> Variant:
	# Validate whether this preset operation actually exists before returning its callable
	if not PRESET_CALLABLES.has(preset):
		return Callable() # Return an empty callable
	return PRESET_CALLABLES[preset]
## UTILITY:
## Return the name of the property a preset is actually modifying
## (Utility Function)
func _get_preset_binded_property(preset, params: Dictionary = {}) -> Variant:
	match preset:
		"move":
			return "position"
		"slide":
			return "position"
		"orbit":
			return "position"
		"scale":
			return "scale"
		"rotate": 
			return "rotation_degrees"
		"fade":
			return "modulate:a"
		"change_property":
			if not params.is_empty():
				return params["target_property"]
			else:
				return null
		"shake":
			return "position"
		_:
			return null
# ================================
