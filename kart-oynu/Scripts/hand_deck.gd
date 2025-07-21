extends Node2D

@export var handDeck : Array[Card]:
	set (value):
		_handDeck = value
		_drawDeck()
	get:
		return _handDeck
var _handDeck : Array[Card]
@onready var deckController = $"../DeckController"
@onready var cardController = $"../CardController"
@onready var panel = $Canvas/HandDeckPanel
# Called when the node enters the scene tree for the first time.
func _drawDeck() -> void:
	var Size = handDeck.size()
	if Size == 0:
		return
	var width : int = 0
	if panel != null:
		width = panel.size.x-100
	var tick = (width) / Size
	if tick < 10:
		tick = 10
	for i in range(Size):
		handDeck[i].position.x=i*tick
		handDeck[i].z_index = i
		handDeck[i].default_z = i
		if not handDeck[i].card_clicked.is_connected(_onCardInput):
			handDeck[i].card_clicked.connect(_onCardInput)
		if not handDeck[i].card_hover.is_connected(_onCardHover):
			handDeck[i].card_hover.connect(_onCardHover)

func _onCardInput(card: Card, event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Card clicked: ", card.card_name)
	
func _onCardHover(card: Card, mouse: bool):
	if mouse:
		card.position.y = -100
		card.z_index = 999
		card.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		card.position.y = 0
		card.z_index = card.default_z
		card.mouse_filter = Control.MOUSE_FILTER_PASS

func _ready() -> void:
	var drawn = deckController._draw_Card(4)
	for id in drawn:
		var cardScene = cardController._getCardScene(id)
		var instance = cardScene.instantiate()
		panel.add_child(instance)
		handDeck.append(instance)
	_drawDeck()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hand_deck_panel_resized() -> void:
	_drawDeck()
