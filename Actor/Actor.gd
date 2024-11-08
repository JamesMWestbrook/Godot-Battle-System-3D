extends Node
class_name Actor
#Heros/Enemies inherit from this.

@onready var animation_player:AnimationPlayer = $"AnimationPlayer"
#@onready var closeup_camera:PhantomCamera3D = $PhantomCamera3D
@onready var damage_label: Label3D = $DamageLabel
@onready var label_anim:AnimationPlayer = $DamageLabel/LabelAnimation
@onready var status_marker: Node3D = $StatusMarker
var hp_label #Just for enemies 


var battle_manager:BattleManager

@export_group("Info")
@export var actor_name:String
@export var nickname:String
@export var texture:Texture
var current_texture:Texture


@export_group("Stats")

var hp:int
##Player's health resource. Once it hits 0, actor cannot act. 
@export var max_hp:int
var hp_mod:int

var mp:int
##Resource used for skills that cost MP. 
@export var max_mp:int
var mp_mod:int

var tp:int

@export var max_tp:int = 100
var tp_mod:int

##Affects physical attacks.
@export var str:int
var str_mod:int
func get_str() -> int:
	return str + str_mod
	
##Affects magic skills.
@export var mag:int
var mag_mod:int
func get_mag() -> int:
	return mag + mag_mod
	
##Affects damage taken. 
@export var def:int
var def_mod:int
func get_def() -> int:
	return def + def_mod
	
##Affects turn order. Higher = faster to act.
@export var agi:int
var agi_mod:int
func get_agi() -> int:
	return agi + agi_mod

##Most likely not being used to keep things simple to start with
@export var eva:int
var eva_mod:int

@export_group("Skills")
@export var skills:Array[Skill]
##Where you set for Takeya if he's learned a skill, everyone else is learned by default
@export var skill_learned:Array[String]
@export var is_player:bool = false
var actor_box:ActorBox
var all_learned:bool
@export_group("AI")
@export var ai_script:ActorAI

var statuses:Array[Dictionary]
#for enemies only
var status_grid:GridContainer
func _ready() -> void:
	hp = max_hp
	mp = max_mp
	if !is_player:
		print(actor_name)
		$AnimationPlayer.play(Constants.IDLE_ANIM)
		hp_label = $"HP Label"
		hp_label.text = str(hp)
	current_texture = texture

func _hit() -> void:
	battle_manager._skill_stats()

func _show_damage(value:int) -> void:
	if is_player:
		var label:Label = Label.new()
		label.text ="-" + str(value)
		add_child(label)
		label.global_position = actor_box.statuses.global_position
		await get_tree().create_timer(0.3).timeout
		label.queue_free()
	else: #enemy
		damage_label.text = str(value)
		label_anim.play(Constants.DAMAGE_LABEL_ANIM)
		await get_tree().process_frame
		hp_label.text = str(hp)
	

func _show_particle_animation() -> void:
	battle_manager._show_particle()
	
func _finish_attack() -> void:
	battle_manager._end_turn()
	if !is_player:
		animation_player.play(Constants.IDLE_ANIM)

func is_stunned() -> bool:
	for status in statuses:
		if status.stun == true:
			return true
	return false
func has_status(type:String) -> bool:
	for status in statuses:
		if status.status_name == type:
			return true
	return false
func get_status(type:String) -> Dictionary:
	for status in statuses:
		if status.status_name == type:
			return status
	return {type:"Null"}
	
func _get_stun() -> Dictionary:
	for status in statuses:
		if status.stun == true:
			return status
	return {"Null":"Null"}
	
