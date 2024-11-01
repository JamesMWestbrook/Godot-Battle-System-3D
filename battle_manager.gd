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


signal battle_won()
signal battle_lost()
@onready var HeroesParent:Node3D = $"../Heroes"
@onready var EnemiesParent: Node3D = $"../Enemies"

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var camera_3d: Camera3D = $"../Camera3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	
	
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
	battle_ui._init_boxes()
	_start_turn()

#Round = everyone has had a turn
#Turn = an individual person acting
func _start_turn() -> void:
	#calculate turn order, after an actor acts, they are removed from turn order
	if turn_order.is_empty():
		#check stats, apply stats, lower tick
		for actor in viable_actors:
			for status in actor.statuses:
				#apply stat
				pass
				#lower tick
				if status.type != "stun": #down at else statement for is_stunned()
					status.turns -= 1
				#if tick 0 then remove it
				if status.turns == 0:
					actor.statuses.erase(status)
		turn_order.append_array(viable_actors)
		#restart the round
		turn_order.sort_custom(sort_agility)
		
		_run_statuses()
	
	current_actor = turn_order[0]
	print(current_actor.actor_name + "'s turn")
	if !turn_order[0].is_stunned():
		if turn_order[0].is_player:
			_player_turn()
		else:#Run AI
			turn_order[0].ai_script._act()
	else: #Is stunned
		print(turn_order[0].actor_name + " is stunned")
		turn_order[0].get_status("stun").turns -= 1
		if turn_order[0].get_status("stun").turns <= 0:
			turn_order[0].statuses.erase(turn_order[0].get_status("stun"))
		_end_turn()

func _player_turn()-> void:
	battle_ui._menu(current_actor)


#Actor has used skill, run skill then proceed to next person 
func _use_skill(skill:Skill, enemy: Actor)-> void:
	battle_ui.targets_container.hide() 
	battle_ui._clear_lists()
	current_skill = skill
	current_target = enemy
	

		
	
	#Run animation if enemy
	if current_actor.is_player:
		_show_particle()
		#use skill cost
		current_actor.hp -= current_skill.hp_cost
		current_actor.mp -= current_skill.mp_cost
		current_actor.tp -= current_skill.tp_cost
		
		current_actor.mp += current_skill.mp_gain
		current_actor.tp += current_skill.tp_gain
		
		if skill.user_status:
			_add_status(current_actor, skill)
		
		await current_skill.timer
		for i in current_skill.times:
			if current_skill.sound_effect:
				audio_stream_player.stream = current_skill.sound_effect
				audio_stream_player.play()
				
			if current_skill.scope == Skill.SCOPE.RANDOM:
				var index = randi_range(0,enemies.size() - 1)
				current_target = enemies[index]	#buff/debuff
				if skill.use_special and !skill.user_status:
					if randi_range(0,100) <= skill.likliehood:
						_add_status(current_target, skill)
			elif current_skill.scope == Skill.SCOPE.ALL:
				printt(current_actor.actor_name, "uses", skill.skill_name,"on","All")
				for e in enemies:
					current_target = e
					e._hit()
						#buff/debuff
					if skill.use_special and !skill.user_status:
						if randi_range(0,100) <= skill.likliehood:
							_add_status(current_target, skill)
			
			else: #Not ALL
				printt(current_actor.actor_name, "uses", skill.skill_name,"on",current_target.actor_name)
				current_target._hit()
					#buff/debuff
				if skill.use_special and !skill.user_status:
					if randi_range(0,100) <= skill.likliehood:
						_add_status(current_target, skill)
		current_target._finish_attack()
		return
	var animation:String = current_skill.user_animation
	if animation.is_empty():
		animation = Constants.ATTACK_ANIM
	current_actor.animation_player.play(animation)
	
func _skill_stats():
	if current_actor.is_player:
		current_actor.actor_box._change_stats(current_actor)
	#Run Skill
	print("Before attack, hp: ", current_target.hp)
	var modifier:int
	if current_skill.stat_modifier == Skill.STAT.STR:
		modifier = current_actor.get_str()
	elif current_skill.stat_modifier == Skill.STAT.MAG:
		modifier = current_actor.get_mag()
	var attack_strength = modifier * current_skill.attack_strength
	var difference =  attack_strength - (current_target.get_def())
	current_target._show_damage(difference)
	current_target.hp -= abs(difference)
	current_target.hp = abs(current_target.hp)
	if current_target.is_player:
		current_target.actor_box._change_hp(current_target)
	print("After attack, hp: ", current_target.hp)

func _end_turn():
	#is the player dead
	var players_alive:int = heroes.size()
	for p in heroes:
		if p.hp <= 0:
			players_alive -= 1
	if players_alive <= 0:
		battle_lost.emit() #start fight over
		return
		
	#are enemies all dead
	var enemies_alive:bool = true
	for enemy in enemies:
		if enemy.hp <= 0:
			enemies.erase(enemy)
	if enemies.size() <= 0:
		enemies_alive = false
		battle_won.emit()
		return
	
	#Progress to next person 
	turn_order.remove_at(0)
	await get_tree().create_timer(0.5).timeout
	_start_turn()


func _show_particle():
	if !is_instance_valid(current_skill.target_particle):
		return
	var particle:Node3D = current_skill.target_particle.instantiate() as Node3D
	add_child(particle)
	if !current_target.is_player:
		particle.global_position = current_target.global_position
		
func _add_status(actor:Actor ,skill:Skill):
	var status:Dictionary
	status.turns = 2
	
	if skill.poison:
		status.type = "poison"
		status.tick = skill.poison_per_round
	elif skill.blind:
		status.type = "blind"
	elif skill.stun:
		status.type = "stun"
	else:
		status.type = "Buff"
	status.hp = skill.hp_regen
	status.mp = skill.mp_regen
	status.tp = skill.tp_regen
	status.str = skill.str_boost
	status.mag = skill.mag_boost
	status.def = skill.def_boost
	status.agi = skill.agi_boost
	
	if actor.has_status(status.type):
		pass
	else:
		_apply_status_stats(actor, status)
		actor.statuses.append(status)
	
	if actor.is_player:
		var texture = TextureRect.new()
		texture.texture = skill.status_icon
		texture.name = skill.skill_name
		actor.actor_box.statuses.add_child(texture)
	else:
		var test_child:TextureRect = TextureRect.new()
		test_child.texture = load("res://Godot-Turn-Based-Battle-System-3D/debuff.svg")
		actor.status_grid.add_child(test_child)
		
func _apply_status_stats(actor:Actor ,status:Dictionary) -> void:
	actor.str_mod += status.str
	actor.mag_mod += status.mag
	actor.def_mod += status.def
	actor.agi_mod += status.agi
	
func _remove_status_stats(actor:Actor ,status:Dictionary) -> void:
	actor.str_mod -= status.str
	actor.mag_mod -= status.mag
	actor.def_mod -= status.def
	actor.agi_mod -= status.agi

func _run_statuses() -> void:
	#Status is being run
	pass
