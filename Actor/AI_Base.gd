extends Node
class_name ActorAI

var battle_manager: BattleManager
	
func _act() -> void:
	battle_manager = _battle_manager()
	battle_manager._use_skill(battle_manager.default_attack, _random_hero())

func _random_hero() -> Actor:
	var max:int = battle_manager.heroes.size() - 1
	var index = randf_range(0, max)
	return battle_manager.heroes[index]

func _battle_manager()-> BattleManager:
	return get_parent().battle_manager
