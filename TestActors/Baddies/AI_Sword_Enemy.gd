extends ActorAI



func _act() -> void:
	super()
	
	var battle_manager = get_parent().battle_manager
	battle_manager._use_skill(battle_manager.default_attack, battle_manager.heroes[0])
