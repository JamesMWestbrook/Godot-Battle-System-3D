extends Control
class_name BattleUI

##Battle actor stat info that spawns in UI in battle.
@export var actor_box:PackedScene
@export var battle_manager:BattleManager

@onready var actor_container:VBoxContainer = $ActorContainer
@onready var actions_container:VBoxContainer = $Actions
#Skills container also being used for items as well 
#depending on which you select
@onready var skills_container: VBoxContainer = $SkillsItems
@onready var attack_button: Button = $Actions/Attack
@onready var targets_container: VBoxContainer = $Targets

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor_container.hide()
	actions_container.hide()
	skills_container.hide()
	targets_container.hide()
	
	#spawn the actor's hp and mp bars
	for actor in battle_manager.heroes:
		var box = actor_box.instantiate()
		actor.actor_box = box
		box.name = actor.actor_name
		
		targets_container.add_child(box)
		actor_container.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _menu(actor:Actor) -> void:
	actions_container.show()
	
	
#Player has chosen a skill to use, now they need to specify an enemy.
func _select_skill(skill:Skill)-> void:
	
	if skill.scope == Skill.SCOPE.SINGLE:
		for enemy in battle_manager.enemies:
			#spawn button per enemy
			var button:Button = Button.new()
			button.name = enemy.actor_name
			button.text = enemy.actor_name
			targets_container.add_child(button)
			
			button.button_down.connect(battle_manager._use_skill.bind(skill, enemy))
	targets_container.show()
	#choose enemy
