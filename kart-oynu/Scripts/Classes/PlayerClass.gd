# Player.gd (Custom class for player data)
class_name Player
extends RefCounted  # Use RefCounted for automatic memory management (like a struct)

# Properties (add more as needed for your card game)
var id: int = 0  # Peer ID (set on creation)
var name: String = "Unnamed"
var is_ready: bool = false
var color: Color = Color.WHITE  # Example: Player color for UI
# Add game-specific ones, e.g.:
var hand: Array[int] = []  # Card UIDs from your DeckController

# Constructor (optional, but useful for initialization)
func _init(_id: int = 0, _name: String = "Unnamed", _is_ready: bool = false, _color: Color = Color.WHITE, _hand : Array[int] = []):
	id = _id
	name = _name
	is_ready = _is_ready
	color = _color
	hand = _hand

# Example methods (add as needed)
func toggle_ready():
	is_ready = !is_ready
	# Could emit a signal here if you want

func get_display_name() -> String:
	return name + " (ID: " + str(id) + ")"

# Serialization: Convert to/from Dictionary for RPCs
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"is_ready": is_ready,
		"color": color.to_html(),  # Color isn't directly serializable, so convert to string
		"hand": hand
	}

static func from_dict(data: Dictionary) -> Player:
	var player = Player.new(
		data.get("id", 0),
		data.get("name", "Unnamed"),
		data.get("is_ready", false),
		Color.from_string(data.get("color", Color.WHITE.to_html()), Color.WHITE),
		data.get("hand", [] as Array[int])
	)
	# Restore others, e.g., player.hand = data.get("hand", [])
	return player
