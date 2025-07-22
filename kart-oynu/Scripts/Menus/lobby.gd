extends Node2D
@export var playerDisplays: Array[TextEdit]
@onready var ReadyButton = $CanvasLayer/Players/ReadyButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ReadyButton.button_down.connect(_readyButtonPressed)
	NetworkManager.player_list_changed.connect(_updatePlayerList)
	await get_tree().create_timer(1.0).timeout
	pass # Replace with function body.

func _updatePlayerList():
	var size = NetworkManager.players.size()
#	for i in range(0,playerDisplays.size()-1):
#		if NetworkManager.players.has(i+1):
#			playerDisplays[i].text = NetworkManager.players[i+1].get_display_name()
	while NetworkManager.localPlayer == null:
		await get_tree().create_timer(1.0).timeout
		
	var k = 0
	for id in NetworkManager.players:
		var player = NetworkManager.players[id]
		playerDisplays[k].text = ""
		if player.is_ready:
			playerDisplays[k].text = "# "
		playerDisplays[k].text += player.get_display_name()
		
			
		if player.id == NetworkManager.localPlayer.id:
			playerDisplays[k].add_theme_color_override("font_color",Color.YELLOW)
		k+=1
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.

func _readyButtonPressed():
	NetworkManager.player_readyup(!NetworkManager.localPlayer.is_ready)
	pass

func _process(delta: float) -> void:
	pass
