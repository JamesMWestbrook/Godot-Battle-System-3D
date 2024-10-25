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

@export_group("Animations")
##Only for enemies. Leaving blank will result in it being attack.
@export var user_animation:String = "attack"
#Leaving empty means no animation will play on target/enemy
#skill is being used on
@export var target_animation:String

## Particles/nodes have to be in an individual scene file.
@export var target_particle:PackedScene
## Sound effect
@export var sound_effect: AudioStream
##For player skills, how long to delay until 
@export var timer:float = 1
## If you want the particle to auto spawn on top of 
@export var auto_spawn_particle:bool
enum TARGET_ANIM_SCOPE{
	SINGLE,
	ALL
}
@export var target_anim_scope:TARGET_ANIM_SCOPE
@export var particle_pos_offset:Vector3
