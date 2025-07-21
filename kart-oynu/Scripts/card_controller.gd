@tool
extends Node

## An array of all loaded card scenes from res://cards/. This updates in real-time in the editor.
@export var card_scenes: Array[PackedScene] = []

## Timer to control how often we check for folder changes (in seconds).
@export var refresh_interval: float = 1.0

# Internal variables for efficient real-time checking.
var _last_refresh_time: float = 0.0
var _last_folder_hash: String = ""  # Tracks if the folder contents changed.

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_last_refresh_time += delta
		if _last_refresh_time >= refresh_interval:
			_last_refresh_time = 0.0
			refresh_cards_if_changed()

## Refreshes the card_scenes array only if the folder contents have changed.
func refresh_cards_if_changed() -> void:
	var current_hash = _get_folder_hash()
	if current_hash != _last_folder_hash:
		_last_folder_hash = current_hash
		refresh_cards()
		# Optional: Print to console for debugging.
		print("Card scenes refreshed: ", card_scenes.size(), " cards found.")

## Scans res://cards/ and loads all .tscn files into card_scenes.
func refresh_cards() -> void:
	card_scenes.clear()
	
	var dir = DirAccess.open("res://objects/Cards/")
	if not dir:
		printerr("Failed to open cards folder: res://objects/Cards/")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		# Skip directories, hidden files, and non-.tscn files.
		if not dir.current_is_dir() and file_name.ends_with(".tscn") and not file_name.begins_with("."):
			var scene_path = "res://objects/Cards/" + file_name
			var scene = load(scene_path) as PackedScene
			if scene:
				card_scenes.append(scene)
			else:
				printerr("Failed to load scene: ", scene_path)
		file_name = dir.get_next()
	dir.list_dir_end()

## Returns a simple "hash" of the folder's file list to detect changes.
func _get_folder_hash() -> String:
	var dir = DirAccess.open("res://objects/Cards/")
	if not dir:
		return ""
	
	var files: Array[String] = []
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn") and not file_name.begins_with("."):
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# Simple hash: sort and join file names.
	files.sort()
	return ",".join(files)

func _getCardScene(id: int) -> PackedScene:
	for card in card_scenes:
		var instance : Card = card.instantiate()
		if instance.card_id == id:
			instance.queue_free()
			return card
		instance.queue_free()
	return null
