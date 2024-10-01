extends Node3D
class_name Actor
#Heros/Enemies inherit from this.

#Mod is short for modifier. For used when buffing/debuffing an actor's stats.
@onready var animation_player:AnimationPlayer = $"AnimationPlayer"
@onready var closeup_camera:PhantomCamera3D = $PhantomCamera3D
var battle_manager:BattleManager

@export_group("Info")
@export var actor_name:String
@export var nickname:String



@export_group("Stats")

var hp:int
##Player's health resource. Once it hits 0, actor cannot act. 
@export var max_hp:int:
	get:
		return max_hp + hp_mod
var hp_mod:int


var mp:int
##Resource used for skills that cost MP. 
@export var max_mp:int:
	get:
		return max_mp + mp_mod
var mp_mod:int

var tp:int

@export var max_tp:int = 100:
	get:
		return max_tp + tp_mod
var tp_mod:int

##Affects physical attacks.
@export var str:int:
	get:
		return str + str_mod
var str_mod:int

##Affects magic skills.
@export var mag:int:
	get:
		return mag + mag_mod
var mag_mod:int

##Affects damage taken. 
@export var def:int:
	get:
		return def + def_mod
var def_mod:int

##Affects turn order. Higher = faster to act.
@export var agi:int: 
	get:
		return agi + agi_mod
var agi_mod:int

##Most likely not being used to keep things simple to start with
@export var eva:int:
	get:
		return eva + eva_mod
var eva_mod:int

@export_group("Skills")
@export var skills:Array[Skill]

var is_actor:bool = false
var actor_box:ActorBox
@export_group("AI")
@export var ai_script:ActorAI

func _ready() -> void:
	hp = max_hp
	mp = max_mp
