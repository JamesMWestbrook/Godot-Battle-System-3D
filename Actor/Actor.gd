extends Node
class_name Actor
#Heros/Enemies inherit from this.

@onready var animation_player:AnimationPlayer = $"AnimationPlayer"
#@onready var closeup_camera:PhantomCamera3D = $PhantomCamera3D
@onready var damage_label: Label3D = $DamageLabel
@onready var label_anim:AnimationPlayer = $DamageLabel/LabelAnimation

var battle_manager:BattleManager

@export_group("Info")
@export var actor_name:String
@export var nickname:String
@export var texture:Texture


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

##Affects magic skills.
@export var mag:int
var mag_mod:int

##Affects damage taken. 
@export var def:int
var def_mod:int

##Affects turn order. Higher = faster to act.
@export var agi:int
var agi_mod:int

##Most likely not being used to keep things simple to start with
@export var eva:int
var eva_mod:int

@export_group("Skills")
@export var skills:Array[Skill]
##Where you set for Takeya if he's learned a skill, everyone else is learned by default
@export var skill_learned:Array[bool]
@export var is_player:bool = false
var actor_box:ActorBox
var all_learned:bool
@export_group("AI")
@export var ai_script:ActorAI

func _ready() -> void:
	hp = max_hp
	mp = max_mp
	if !is_player:
		print(actor_name)
		$AnimationPlayer.play(Constants.IDLE_ANIM)
		pass

func _hit() -> void:
	battle_manager._skill_stats()

func _show_damage(value:int):
	pass
	if !is_player:
		damage_label.text = str(value)
		label_anim.play(Constants.DAMAGE_LABEL_ANIM)

func _show_particle_animation():
	battle_manager._show_particle()
	
func _finish_attack():
	battle_manager._end_turn()
	#animation_player.play(Constants.IDLE_ANIM)
