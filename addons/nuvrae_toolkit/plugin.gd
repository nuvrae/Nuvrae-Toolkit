@tool
extends EditorPlugin

# ========== PROPERTIES ==============
const AUTOLOADS: Dictionary = {
	"Helpers": "res://addons/nuvrae_toolkit/scripts/helpers.gd",
	"AudioSystem": "res://addons/nuvrae_toolkit/scripts/audio_system.gd",
	"AnimationSystem": "res://addons/nuvrae_toolkit/scripts/animation_system.gd"
}
# ====================================

# =========== FUNCTIONS ==============
# General Functions
func _enter_tree():
	# REGISTER THE TOOLKIT'S SCRIPTS AS AUTOLOAD SINGLETONS WHEN THE PLUGIN IS ENABLED
	for autoload_name in AUTOLOADS:
		var script_path = AUTOLOADS[autoload_name]
		var setting_path: String = "autoload/" + autoload_name
		
		# Registering autoloads
		if not ProjectSettings.has_setting(setting_path):
			add_autoload_singleton(autoload_name, script_path)
func _exit_tree():
	# REMOVE THE TOOLKIT'S SCRIPTS WHEN THE PLUGIN IS DISABLED
	for autoload_name in AUTOLOADS:
		var script_path = AUTOLOADS[autoload_name]
		var setting_path: String = "autoload/" + autoload_name
		
		# Removing autoloads
		if ProjectSettings.has_setting(setting_path):
			var registered_path: String = ProjectSettings.get_setting(setting_path)
			if registered_path == "*" + script_path:
				remove_autoload_singleton(autoload_name)
# ====================================
