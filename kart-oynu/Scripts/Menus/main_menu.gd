extends Node2D

@onready var titleText = $CanvasLayer/TitleText
@onready var nameText = $CanvasLayer/Panel/NameText
@onready var ipText = $CanvasLayer/Panel/IPText
@onready var portText = $CanvasLayer/Panel/PortText
@onready var hostButton = $CanvasLayer/Panel/HostButton
@onready var joinButton = $CanvasLayer/Panel/JoinButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hostButton.button_down.connect(_hostButtonPress)
	joinButton.button_down.connect(_joinButtonPress)
	NetworkManager.connected_to_server.connect(_connected)
	NetworkManager.connection_failed.connect(_connectionFailed)
	pass

func _hostButtonPress() -> void:
	NetworkManager.player_name = nameText.text
	if int(portText.text)==0:
		titleText.text = "Port must be a number!"
		return
	
	if NetworkManager.host_server(int(portText.text)):
		# Transition to lobby after successful host
		get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
	else:
		 # Handle error (e.g., show a popup)
		titleText.text = "Hosting failed!"
	pass

func _joinButtonPress() -> void:
	if int(portText.text)==0:
		titleText.text = "Port must be a number!"
		return
	NetworkManager.player_name = nameText.text
	NetworkManager.join_server(ipText.text,int(portText.text))
	pass

func _connected():
	if get_tree() != null:
		get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
	pass

func _connectionFailed():
	titleText.text = "Connection failed!"
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
