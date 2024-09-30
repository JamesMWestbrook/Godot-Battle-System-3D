extends Node
class_name BattleManager

#You most likely want to set this on the BattleBase scene.
@export var default_attack:Skill

var current_actor:Actor

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
	#needs to give Battle_UI a chance to have its child nodes enter the tree
	await get_tree().process_frame
	
	_setup_actors()
	battle_ui.attack_button.button_down.connect(battle_ui._select_skill.bind(default_attack))
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _setup_actors()-> void:
	heroes.append_array($"../Heroes".get_children())
	for actor in heroes:
		actor.is_actor = true #not necessary but prevents you needing to set it
							#yourself
	enemies.append_array($"../Enemies".get_children())
	
	viable_actors.append_array(enemies)
	viable_actors.append_array(heroes)
	
	
	
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
	if turn_order[0].is_actor:
		_player_turn()
	else:
		pass

func _player_turn()-> void:
	battle_ui._menu(current_actor)


	
func _use_skill(skill:Skill, enemy: Actor)-> void:
	printt(current_actor.actor_name, "uses", skill.skill_name,"on",enemy.actor_name)
	
