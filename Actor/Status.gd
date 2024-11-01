extends Resource
class_name Status

@export var status_name:String
@export var status_icon: Texture

#percentage out of 100, 100 being 100%
@export_range(1,99) var turns:int = 2

@export var hp_tick_per_round:int
@export var mp_tick_per_round:int
@export var tp_tick_per_round:int

@export var blind:bool
@export var stun:bool
@export_range(0,100) var accuracy_debuff:int = 100

@export var hp_regen:int
@export var mp_regen:int
@export var tp_regen:int

@export var str_boost:int
@export var mag_boost:int
@export var def_boost:int
@export var agi_boost:int

@export_group("Special")
@export var texture_change:Texture
@export var alternate_attack:Skill
@export var enable_skills:Array[Skill]
