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
	if a.get_agi() > b.get_agi():
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
		_status_ticks()
		
		turn_order.append_array(viable_actors)
		#restart the round
		turn_order.sort_custom(sort_agility)
	
	if _is_party_dead():
		battle_lost.emit()
	
	current_actor = turn_order[0]
	print(current_actor.actor_name + "'s turn")
	var is_stunned:bool = current_actor.is_stunned()
	if !is_stunned and current_actor.hp > 0:
		if current_actor.is_player:
			_player_turn()
		else:#Run AI
			current_actor.ai_script._act()
	else: #Is stunned
		print(current_actor.actor_name + " is stunned")
		var status = current_actor._get_stun()
		status.turns -= 1
		if status.turns <= 0:
			current_actor.statuses.erase(status)
			if current_actor.is_player:
				current_actor.actor_box.statuses.get_node(status.status_name).queue_free()
			else:#Is enemy
				current_actor.status_grid.get_node(status.status_name).queue_free()
		_end_turn()

func _player_turn()-> void:
	battle_ui._menu(current_actor)
	
func _is_party_dead():
	var all_dead:bool = true
	for hero in heroes:
		if hero.hp > 0:
			all_dead = false
	return all_dead
	
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
		
		if is_instance_valid(skill.user_status):
			_add_status(current_actor, skill.user_status)
		
		await current_skill.timer
		for i in current_skill.times:
			if current_skill.sound_effect:
				audio_stream_player.stream = current_skill.sound_effect
				audio_stream_player.play()
				
			if current_skill.scope == Skill.SCOPE.RANDOM:
				var index = randi_range(0,enemies.size() - 1)
				current_target = enemies[index]	#buff/debuff
				if is_instance_valid(skill.enemy_status):
					if randi_range(0,100) <= skill.likliehood:
						_add_status(current_target, skill.enemy_status)
			elif current_skill.scope == Skill.SCOPE.ALL:
				printt(current_actor.actor_name, "uses", skill.skill_name,"on","All")
				for e in enemies:
					current_target = e
					e._hit()
						#buff/debuff
					if is_instance_valid(skill.enemy_status):
						if randi_range(0,100) <= skill.likliehood:
							_add_status(current_target, skill.enemy_status)
			
			else: #Not ALL
				printt(current_actor.actor_name, "uses", skill.skill_name,"on",current_target.actor_name)
				current_target._hit()
					#buff/debuff
				if is_instance_valid(skill.enemy_status):
					if randi_range(0,100) <= skill.likliehood:
						_add_status(current_target, skill.enemy_status)
		current_target._finish_attack()
		return
	printt(current_actor.actor_name, "uses", skill.skill_name,"on",enemy.actor_name)
	
	var animation:String = current_skill.user_animation

	if animation.is_empty():
		animation = Constants.ATTACK_ANIM
	current_actor.animation_player.play(animation)
	await current_actor.animation_player.animation_finished
	if is_instance_valid(skill.enemy_status):
		if randi_range(0,100) <= skill.likliehood:
			_add_status(current_target, skill.enemy_status)

	
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
		
func _add_status(actor:Actor ,status_res:Status):
	var new_status:Dictionary
	new_status.turns = status_res.turns
	new_status.status_name = status_res.status_name
	
	if new_status.status_name == "":
		printerr("NEEDS A STATUS NAME")
	
	new_status.hp_tick = status_res.hp_tick_per_round
	new_status.mp_tick = status_res.mp_tick_per_round
	new_status.tp_tick = status_res.tp_tick_per_round
	new_status.blind = status_res.blind
	new_status.stun = status_res.stun
	
	new_status.str = status_res.str_boost
	new_status.mag = status_res.mag_boost
	new_status.def = status_res.def_boost
	new_status.agi = status_res.agi_boost
	
	new_status.status_icon = status_res.status_icon
	
	if actor.has_status(new_status.status_name):
		return
	else:
		_apply_status_stats(actor, new_status)
		actor.statuses.append(new_status)
	
	if actor.is_player:
		var texture := TextureRect.new()
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		texture.custom_minimum_size = Vector2(36,36)
		
		texture.texture = new_status.status_icon
		texture.name = new_status.status_name
		if !is_instance_valid(status_res.status_icon):
			printerr("No texture for status " + status_res.status_name)
		actor.actor_box.statuses.add_child(texture)
		
		if is_instance_valid(status_res.texture_change):
			actor.current_texture = status_res.texture_change
			new_status.changed_texture = true
	else:#Is enemy
		var test_child:TextureRect = TextureRect.new()
		test_child.name = new_status.status_name
		test_child.texture = new_status.status_icon
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

func _status_ticks() -> void:
	for actor in viable_actors:
		for status in actor.statuses:
			#apply stat
			pass
			#lower tick
			if status.stun == false: #down at else statement for is_stunned()
				status.turns -= 1
			#if tick 0 then remove it
			if status.turns == -1:
				actor.statuses.erase(status)
				if status.has("changed_texture"):
					actor.current_texture = actor.texture
				_remove_status_stats(actor,status)
				if actor.is_player:
					actor.actor_box.statuses.get_node(status.status_name).queue_free()
				else:#Is enemy
					actor.status_grid.get_child(status.status_name).queue_free()

func _run_status(status:Dictionary) -> void:
	#Status is being run
	pass
