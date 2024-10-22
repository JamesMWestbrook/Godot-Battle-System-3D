extends Node
class_name ActorAI

func _act() -> void:
	var battle_manager:BattleManager = get_parent().battle_manager
	battle_manager._use_skill(battle_manager.default_attack, battle_manager.heroes[0])
