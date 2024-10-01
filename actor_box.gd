extends HBoxContainer
class_name ActorBox

@onready var name_label: Label = $Stats/NameLabel
@onready var hp_value: Label = $Stats/HPBox/HPValue
@onready var mp_value: Label = $Stats/MPBox/MPValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _init_box(actor:Actor) -> void:
	name_label.text = actor.actor_name
	_change_hp(actor)
	_change_mp(actor)

func _change_hp(actor:Actor) -> void:
	hp_value.text = str(actor.hp) + "/" + str(actor.max_hp)
func _change_mp(actor:Actor) -> void:
	mp_value.text = str(actor.mp) + "/" + str(actor.max_mp)
	
