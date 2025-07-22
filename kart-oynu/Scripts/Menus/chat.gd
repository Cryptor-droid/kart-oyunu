extends Panel

@onready var chatBox = $ChatBox
@onready var messageBox = $MessageBox
@onready var sendButton = $SendButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sendButton.button_down.connect(_sendPressed)
	pass # Replace with function body.

func _sendPressed():
	rpc("_addNewMessage",NetworkManager.localPlayer.get_display_name(),messageBox.text)
	messageBox.text = ""
	pass

@rpc("any_peer","call_local","reliable")
func _addNewMessage(player:String,message:String):
	chatBox.text+= player + ": " + message + "\n"
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
