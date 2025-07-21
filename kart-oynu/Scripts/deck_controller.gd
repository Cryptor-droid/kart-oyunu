@tool
extends Node
@export var updateDecks: bool
@export var GameDeck: Array[int]
@export var DropDeck: Array[int]
@onready var controller = $"../CardController"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_Decks()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if updateDecks:
		updateDecks = false
		_init_Decks()
		
func shuffle_array(arr: Array) -> Array:
	var shuffled = arr.duplicate()  # Create a copy of the original array
	var n = shuffled.size()
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)  # Generate a random index
		var temp = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = temp
	return shuffled

func _refill_GameDeck():
	GameDeck.append_array(DropDeck)
	GameDeck = shuffle_array(GameDeck)
	DropDeck.clear()
	
func _draw_Card(amount : int) -> Array[int]:
	var remaining = GameDeck.size()
	if remaining < amount:
		_refill_GameDeck()
	var returnArray : Array[int]
	for i in range(amount):
		returnArray.append(GameDeck.pop_back())
	return returnArray

func _drop_Card(cards : Array[int]):
	DropDeck.append_array(cards)

func _init_Decks():
	DropDeck.clear()
	GameDeck.clear()
	var cardsScenes = controller.card_scenes
	for card in cardsScenes:
		var instance : Card = card.instantiate()
		var id = instance.card_id
		for i in range(instance.card_amount):
			GameDeck.append(id)
		instance.queue_free()
	GameDeck = shuffle_array(GameDeck)
