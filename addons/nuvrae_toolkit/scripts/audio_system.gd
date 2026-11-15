extends Node

# ========= PROPERTIES =============
const MAX_MUSIC_CHANNELS: int = 2
const MAX_SFX_CHANNELS: int = 5
# ===================================

# ========= AUDIO GROUPS =============
# Objective: allows global playback for audio channels
var music_group = Node.new()
var sfx_group = Node.new()
# ====================================

# ========= GROUP CHANNELS =============
# Objective: a direct reference to specific audio channels
var music_channels: Dictionary = {}
var sfx_channels: Dictionary = {}
# ====================================

# ========= FUNCTIONS =============
# General Functions
func _ready():
	_initialize()

# INITIALIZATION:
## INITIALIZATION:
## Establishes the audio channels and groups for global audio playback
## (Main Function)
func _initialize():
	# ----------------
	# ADDING AUDIO GROUPS TO OUR SCENE TREE:
	add_child(music_group)
	add_child(sfx_group)
	
	# ----------------
	# CREATING AUDIO CHANNELS:
	
	# Music channels:
	for music_channel in range(MAX_MUSIC_CHANNELS):
		# Create a new channel
		var new_channel = AudioStreamPlayer.new()
		# Register the newly created audio channel into our list of music channels
		music_channels[music_channel] = new_channel
		# Adding the audio channel to its respective audio group
		music_group.add_child(new_channel)
	# SFX channels:
	for sfx_channel in range(MAX_SFX_CHANNELS):
		# Create a new channel
		var new_channel = AudioStreamPlayer.new()
		# Register the newly created audio channel into our list of sfx channels
		sfx_channels[sfx_channel] = new_channel
		# Adding the audio channel to its respective audio group
		sfx_group.add_child(new_channel)
	
	# ----------------
	# ASSIGNING AUDIO BUS CHANNEL:
	_set_bus(music_channels, "Music")
	_set_bus(sfx_channels, "SFX")

# GLOBAL AUDIO PLAYBACK:
## GLOBAL AUDIO PLAYBACK:
## Plays the provided audio stream through the requested audio channel
## (Core Function)
func play_on_channel(
	audio: AudioStream, # The audio stream we want to play
	audio_group: String, # The audio group the specified audio channel is in
	audio_channel: int, # The audio channel
	skip_busy: bool # Prevents the game from playing an audio if the specified channel is already busy
):
	
	# ------------------
	# GET THE AUDIO CHANNELS OF THE SPECIFIED AUDIO GROUP:
	var audio_channels = _get_channels_from_group(audio_group)
	
	# ------------------
	# VALIDATE THE EXISTENCE OF THE AUDIO CHANNEL FIRST:
	var result = _channel_exists(audio_channels, audio_channel)
	if result == false:
		return
	
	# ------------------
	# PLAYING THE AUDIO:
	# skip_busy functionality
	# the game returns if an audio is already being played in an audio channel
	if skip_busy and audio_channels[audio_channel].playing():
		return 
	
	# otherwise, play the audio normally regardless of override
	audio_channels[audio_channel].stream = audio
	audio_channels[audio_channel].play()
## GLOBAL AUDIO PLAYBACK:
## Stops the specified audio channel
## (Core Function)
func stop_channel(audio_group: String, audio_channel: int):
	# ------------------
	# GET THE AUDIO CHANNELS OF THE SPECIFIED AUDIO GROUP:
	var audio_channels = _get_channels_from_group(audio_group)
	
	# ------------------
	# VALIDATE THE EXISTENCE OF THE AUDIO CHANNEL FIRST:
	var result = _channel_exists(audio_channels, audio_channel)
	if result == false:
		return
	
	# ------------------
	# STOPPING CHANNEL:
	audio_channels[audio_channel].stop()
	audio_channels[audio_channel].stream = null
## GLOBAL AUDIO PLAYBACK:
## Toggles the playback of a specified audio channel
## (Core Function)
func toggle_channel_playback(audio_group: String, audio_channel: int) -> bool:
	# ------------------
	# GET THE AUDIO CHANNELS OF THE SPECIFIED AUDIO GROUP:
	var audio_channels = _get_channels_from_group(audio_group)
	
	# ------------------
	# VALIDATE THE EXISTENCE OF THE AUDIO CHANNEL FIRST:
	var result = _channel_exists(audio_channels, audio_channel)
	if result == false:
		return false
	
	# ------------------
	# TOGGLING CHANNEL'S PLAYBACK:
	audio_channels[audio_channel].stream_paused = !audio_channels[audio_channel].stream_paused
	
	# ------------------
	# RETURN PAUSED STATE:
	return audio_channels[audio_channel].stream_paused
# ====================================

# ========= UTILITIES =============
## UTILITIES:
## Validates the existence of a specified audio channel
## (Utility Function)
func _channel_exists(group_channels: Dictionary, audio_channel: int) -> bool:
	# ------------------
	# VALIDATING WHETHER THE SPECIFIED CHANNEL ACTUALLY EXISTS:
	if group_channels.has(audio_channel):
		return true
	else:
		return false
## UTILITIES:
## Connects the requested signal from an audio channel to a function callable
## (Utility Function)
func _connect_channel_signal(
	audio_group: String, # The audio group our audio channel is in
	audio_channel: int, # The audio channel that has the signal we want to connect
	signal_name: String,  # The name of the signal we want to connect
	callable: Callable # The callable were connecting the signal to
): # START
	
	# ------------------
	# GET THE AUDIO CHANNELS OF THE SPECIFIED AUDIO GROUP:
	var audio_channels = _get_channels_from_group(audio_group)
	
	# ------------------
	# VALIDATE THE EXISTENCE OF THE AUDIO CHANNEL FIRST:
	var result = _channel_exists(audio_channels, audio_channel)
	if result == false:
		return
	
	# ------------------
	# CONNECTING SIGNAL:
	audio_channels[audio_channel].connect(signal_name, callable)
## UTILITIES:
## Returns the channels belonging to the specified audio group
## (Utility Function)
func _get_channels_from_group(audio_group: String) -> Dictionary:
	match audio_group.to_lower():
		"music":
			return music_channels
		"sfx": 
			return sfx_channels
		_:
			return {}
## UTILITIES:
## Assigning an audio bus channel to a specific audio group
## (Utility Function)
func _set_bus(group_channels: Dictionary, bus_name: String):
	for channel in group_channels:
		group_channels[channel].bus = bus_name
## UTILITIES:
## Returns a requested effect instance from an audio bus channel
## (Utility Function)
func _get_bus_effect(bus_name: String, effect_idx: int) -> AudioEffectInstance:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_effect_instance(bus_idx, effect_idx)
# ====================================
