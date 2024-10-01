extends Resource
class_name Skill


@export var icon:Texture
@export var skill_name:String

@export var mp_cost:int
@export var hp_cost:int

enum TARGET{
	HOSTILE,
	FRIENDLY
}
@export var target:TARGET
enum SCOPE{
	SINGLE,
	ALL
}
@export var scope:SCOPE

enum STAT{
	STR,
	MAG
}
@export var stat_modifier:STAT
@export_range(0.2, 2) var attack_strength:float = 1

#leaving empty will result in default "attack" being used
@export var animation_name:String = "attack"
