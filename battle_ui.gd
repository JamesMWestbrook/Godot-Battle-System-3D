extends Control
class_name BattleUI

##Battle actor stat info that spawns in UI in battle.
@export var actor_box:PackedScene
@export var battle_manager:BattleManager

@onready var actor_container:VBoxContainer = $ActorContainer
@onready var actions_container:VBoxContainer = $Actions
#Skills container also being used for items as well 
#depending on which you select
@onready var skills_container: GridContainer = $ScrollContainer/SkillsItems
@onready var targets_container: VBoxContainer = $Targets

@onready var actor_texture: TextureRect = $ActorTexture
@onready var texture_anim: AnimationPlayer = $ActorTexture/AnimationPlayer

#BUttons
@onready var actions_grid: VBoxContainer = $Actions



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	actor_container.hide()
	actions_container.hide()
	skills_container.hide()
	targets_container.hide()
	
	

func _init_boxes() -> void:
	#spawn the actor's hp and mp bars
	for actor in battle_manager.heroes:
		var box = actor_box.instantiate() as ActorBox
		actor_container.add_child(box)
		actor.actor_box = box
		box.name = actor.actor_name
		
		actor_container.show()
		box._init_box(actor)
		
	
	for enemy in battle_manager.enemies:
		var grid = GridContainer.new()
		grid.columns = 6
		grid.scale = Vector2(0.5,0.5)
		add_child(grid)
		grid.position = battle_manager.camera_3d.unproject_position(enemy.status_marker.global_position)
		enemy.status_grid = grid
		

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _menu(actor:Actor) -> void:
	_actions()
	actions_container.show()
	actor_texture.texture = battle_manager.current_actor.current_texture
	texture_anim.play("FadeIn")
	
func _actions() -> void:
	var attack_button = Button.new()
	attack_button.button_down.connect(_select_skill.bind(battle_manager.default_attack))
	attack_button.text = "Attack"
	
	var skills_button = Button.new()
	skills_button.button_down.connect(_on_skills_button_down)
	skills_button.text = "Skills"
	
	actions_container.add_child(attack_button)
	actions_container.add_child(skills_button)
	attack_button.grab_focus()
	
#Skills button selected
func _on_skills_button_down() -> void:
	skills_container.show()
	var actor:Actor = battle_manager.current_actor
	
	#populate all skills actor has 
	for skill:Skill in actor.skills:
		if actor.skill_learned.has(skill.skill_name):
			_skill_button(skill)
			
	#Grab first skill
	if skills_container.get_children().size() > 0:
		skills_container.get_child(0).grab_focus()

	
#Player has chosen a skill to use, now they need to specify an enemy.
func _select_skill(skill:Skill)-> void:
	actions_container.hide()
	skills_container.hide()
	var index:int = 0
	if skill.scope == Skill.SCOPE.SINGLE:
		for enemy in battle_manager.enemies:
			#spawn button per enemy
			var button:Button = Button.new()
			button.name = enemy.actor_name
			button.text = enemy.actor_name
			targets_container.add_child(button)
			button.grab_focus()
			index += 1
			
			button.button_down.connect(battle_manager._use_skill.bind(skill, enemy))
			button.button_down.connect(_fade_out)
	elif skill.scope == Skill.SCOPE.ALL:
		#spawn button per enemy
		var button:Button = Button.new()
		button.name = "All Enemies"
		button.text = "All Enemies"
		targets_container.add_child(button)
		button.grab_focus()
		index += 1
		
		#current target is just placeholder bc it needs second argument
		button.button_down.connect(battle_manager._use_skill.bind(skill, battle_manager.current_target))
		button.button_down.connect(_fade_out)
	elif skill.scope == Skill.SCOPE.RANDOM:
		#spawn button per enemy
		var button:Button = Button.new()
		button.name = "All"
		button.text = str(skill.times)
		button.text += " Random Enemies"
		targets_container.add_child(button)
		button.grab_focus()
		index += 1
			
		#current target is just placeholder bc it needs second argument
		button.button_down.connect(battle_manager._use_skill.bind(skill, battle_manager.current_target))
		button.button_down.connect(_fade_out)
	targets_container.show()
	
func _fade_out():
	texture_anim.play("FadeOut")
	for child in actions_container.get_children():
		child.queue_free()
	
func _clear_lists() -> void:
	for i in targets_container.get_children():
		i.queue_free()
	for i in skills_container.get_children():
		i.queue_free()

func _skill_button(skill:Skill):
	var button:Button = Button.new()
	button.text = skill.skill_name
	if skill.hp_cost > 0:
		button.text += " " + str(skill.hp_cost) + " hp"
		if battle_manager.current_actor.hp < skill.hp_cost:
			button.disabled = true
	elif skill.mp_cost > 0:
		button.text += " " + str(skill.mp_cost) + " mp"
		if battle_manager.current_actor.mp < skill.mp_cost:
			button.disabled = true
	elif skill.tp_cost > 0:
		if battle_manager.current_actor.tp < skill.tp_cost:
			button.disabled = true
		button.text += " " + str(skill.tp_cost) + " tp"

	button.button_down.connect(_select_skill.bind(skill))
	skills_container.add_child(button)
