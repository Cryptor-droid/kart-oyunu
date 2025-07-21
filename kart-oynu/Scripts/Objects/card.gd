@tool
extends Control

class_name Card

@onready var nameLabel : Label = $CardPanel/nameLabel
@onready var propertiesLabel : Label = $CardPanel/propertiesLabel
@onready var cardGraphics : TextureRect= $CardPanel/TextureRect

@export var card_id: int
@export var card_amount: int
@export var default_z: int
@export var visual_only: bool
@export var card_name: String:
	set(value):
		_card_name = value
		_updateCard()  # It's OK if this only updates UI labels!
	get:
		return _card_name

var _card_name: String = ""

@export var card_description: String:
	set(value):
		_card_description = value
		_updateCard()  # It's OK if this only updates UI labels!
	get:
		return _card_description

var _card_description: String = ""

@export var card_graphics: CompressedTexture2D:
	set(value):
		_card_graphics = value
		_updateCard()  # It's OK if this only updates UI labels!
	get:
		return _card_graphics

var _card_graphics: CompressedTexture2D

func _updateCard() -> void:
	if nameLabel != null:
		nameLabel.text = _card_name
	if propertiesLabel != null:
		propertiesLabel.text = _card_description
	if cardGraphics != null:
		cardGraphics.texture = _card_graphics

signal card_clicked(card: Card, event: InputEvent)

signal card_hover(card: Card, mouseIn: bool)

func _on_gui_input(event: InputEvent) -> void:
	if not visual_only:
		card_clicked.emit(self, event)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_updateCard()
	if visual_only:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_mouse_entered() -> void:
	if not visual_only:
		card_hover.emit(self,true)


func _on_mouse_exited() -> void:
	if not visual_only:
		card_hover.emit(self,false)
