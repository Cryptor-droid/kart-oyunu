# NetworkManager.gd (Singleton for sharing network data and logic)
extends Node
var players: Dictionary[int, Player] = {}  # e.g., {1: Player.new(1, "Host")}
var localPlayer : Player
# Shared variables (accessible from any scene)
var host_ip: String = "127.0.0.1"  # Default to localhost
var host_port: int = 3169  # Default port
var is_hosting: bool = false  # Track if this peer is the host

var player_name: String = "newPlayer"

# Multiplayer peer (from earlier examples)
var peer: ENetMultiplayerPeer = null

# Signals for connection events (optional but useful)
signal connected_to_server
signal connection_failed
signal server_disconnected
signal player_list_changed

func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	emit_signal("player_list_changed")
# Function to host a server
func host_server(port: int):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	if error != OK:
		print("Failed to host: ", error)
		return false
	multiplayer.multiplayer_peer = peer
	is_hosting = true
	host_port = port
	print("Hosting on port: ", port)
	var host_id = multiplayer.get_unique_id()  # This is now 1
	var host_player = Player.new(host_id, player_name, false, Color.WHITE)
	players[host_id] = host_player
	localPlayer = host_player
	print("Host registered locally: ", host_id, " -> ", host_player.name)
	emit_signal("player_list_changed")  # Update UI immediately (no clients yet)
	return true

# Function to join a server
func join_server(ip: String, port: int):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		print("Failed to join: ", error)
		return false
	multiplayer.multiplayer_peer = peer
	is_hosting = false
	host_ip = ip
	host_port = port
	print("Joining ", ip, ":", port)
	return true

# Connection callbacks (adapt to your needs)
func _on_connected_to_server():
	print("Connected to server!")
	# Client prepares their info as a Dictionary
	var my_info = {
		"name": player_name,  # Customize (e.g., from UI input)
		"is_ready": false,
		"color": Color.BLUE.to_html(),
		"hand": [] as Array[int]# Add others as needed
	}
	rpc_id(1, "register_player", my_info)  # Send Dictionary to server (no ID—server sets it)
	emit_signal("connected_to_server")

func _on_connection_failed():
	print("Connection failed!")
	emit_signal("connection_failed")
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	print("Server disconnected!")
	emit_signal("server_disconnected")
	multiplayer.multiplayer_peer = null

@rpc("any_peer","call_remote","reliable")
func setLocalPlayer(player: Dictionary = {}):
	localPlayer = Player.from_dict(player)

func player_readyup(ready : bool):
	rpc_id(1,"_player_readyup",!NetworkManager.localPlayer.is_ready)

@rpc("any_peer", "call_local", "reliable")
func _player_readyup(ready : bool):
	if is_multiplayer_authority():
		var sender_id = multiplayer.get_remote_sender_id()
		print(sender_id, " = ", ready)
		var player = players[sender_id]
		player.is_ready = ready
		rpc_id(sender_id,"setLocalPlayer",player.to_dict())
		rpc("update_player_list", _serialize_players())  # Serialize before sending
		emit_signal("player_list_changed")
	pass
	
@rpc("any_peer", "call_local", "reliable")
func register_player(info_dict: Dictionary = {}):
	var sender_id = multiplayer.get_remote_sender_id()
	# Only the server processes this
	if is_multiplayer_authority():
		 # Validate and create Player instance
		if players.has(sender_id):
			return  # Already registered
		info_dict["id"] = sender_id
		var player = Player.from_dict(info_dict)  # Deserialize from dict
		print(player.id)
		player.id = sender_id  # Securely set ID on server
		
		# Additional validation (e.g., unique name)
		if player.name == "":
			player.name = "Player" + str(sender_id)
		
		players[sender_id] = player
		print("Player registered: ", sender_id, " -> ", player.name)
		rpc_id(sender_id,"setLocalPlayer",player.to_dict())
		# Broadcast the updated list to all clients
		rpc("update_player_list", _serialize_players())  # Serialize before sending
		emit_signal("player_list_changed")
		
@rpc("authority", "call_local", "reliable")
func update_player_list(serialized_players: Dictionary):
	players.clear()
	for id_str in serialized_players.keys():
		var id = int(id_str)  # Dictionary keys are strings in RPCs, so convert
		var info_dict = serialized_players[id_str]
		var player = Player.from_dict(info_dict)
		player.id = id
		players[id] = player
	print("Player list updated: ", players.keys())
	emit_signal("player_list_changed")  # Notify UI to refresh
		
func _serialize_players() -> Dictionary:
	var serialized: Dictionary = {}
	for id in players.keys():
		serialized[str(id)] = players[id].to_dict()  # Use str(id) since RPC keys are strings
	return serialized
