extends Area2D


@onready var goal_sound: AudioStreamPlayer2D = $"../Goal Sound"


# win the level if a ball exits the collider in the correct direction
func _on_body_exited(body: Node2D) -> void:
	if body.name.begins_with("Ball"):
		if Vector2.from_angle(global_rotation).dot(body.linear_velocity) > 0:
			body.queue_free()
			goal_sound.play()
			get_tree().call_group("Level Root", "win_level")
