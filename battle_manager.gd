extends Node
class_name BattleManager

#You most likely want to set this on the BattleBase scene.
@export var default_attack:Skill

var current_actor:Actor
var current_skill:Skill
var current_target:Actor
#Nodes
@export var battle_ui:BattleUI

#Arrays
var heroes:Array[Actor] #all dead = game over
var enemies:Array[Actor]#all dead = battle over

#All actors in scene, if they are "viable" or alive, they can act/be targeted
var viable_actors:Array[Actor]
var turn_order:Array[Actor]
func sort_agility(a:Actor,b:Actor) -> bool:
	if a.agi > b.agi:
		return true
	return false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_actors()
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _setup_actors()-> void:
	heroes.append_array($"../Heroes".get_children())
	for actor in heroes:
		actor.is_player = true #not necessary but prevents you needing to set it
							#yourself
	enemies.append_array($"../Enemies".get_children())
	
	viable_actors.append_array(enemies)
	viable_actors.append_array(heroes)
	for actor in viable_actors:
		actor.battle_manager = self
	await get_tree().process_frame
	_start_turn()

#Round = everyone has had a turn
#Turn = an individual person acting
func _start_turn() -> void:
	#calculate turn order, after an actor acts, they are removed from turn order
	if turn_order.is_empty():
		#restart the round
		turn_order.append_array(viable_actors)
		turn_order.sort_custom(sort_agility)
	
	current_actor = turn_order[0]
	print(current_actor.actor_name + "'s turn")
	if turn_order[0].is_player:
		_player_turn()
	else:#Run AI
		turn_order[0].ai_script._act()

func _player_turn()-> void:
	battle_ui._menu(current_actor)


#Actor has used skill, run skill then proceed to next person 
func _use_skill(skill:Skill, enemy: Actor)-> void:
	battle_ui.targets_container.hide()
	battle_ui._clear_lists()
	printt(current_actor.actor_name, "uses", skill.skill_name,"on",enemy.actor_name)
	current_skill = skill
	current_target = enemy
	
	#Run animation
	var animation:String = current_skill.user_animation
	if animation.is_empty():
		animation = Constants.ATTACK_ANIM
	current_actor.animation_player.play(animation)
	
func _skill_stats():
	#use skill cost
	current_actor.hp -= current_skill.hp_cost
	current_actor.mp -= current_skill.mp_cost
	if current_actor.is_player:
		current_actor.actor_box._change_stats(current_actor)
	#Run Skill
	print("Before attack, hp: ", current_target.hp)
	var modifier:int
	if current_skill.stat_modifier == Skill.STAT.STR:
		modifier = current_actor.str + current_actor.str_mod
	elif current_skill.stat_modifier == Skill.STAT.MAG:
		modifier = current_actor.mag + current_actor.mag_mod
	var difference = modifier * current_skill.attack_strength - (current_target.def + current_target.def_mod)
	current_target._show_damage(difference)
	current_target.hp -= difference
	current_target.hp = abs(current_target.hp)
	if current_target.is_player:
		current_target.actor_box._change_hp(current_target)
	print("After attack, hp: ", current_target.hp)

func _end_turn():
	#Progress to next person 
	turn_order.remove_at(0)
	await get_tree().create_timer(0.5).timeout
	_start_turn()


func _show_particle():
	var particle:Node3D = current_skill.target_particle.instantiate() as Node3D
	add_child(particle)
	particle.global_position = current_target.global_position
