extends Node3D

@export_range(0.1,3) var timer:float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GPUParticles3D.restart()
	#await get_tree().create_timer(timer).timeout
	#queue_free()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
