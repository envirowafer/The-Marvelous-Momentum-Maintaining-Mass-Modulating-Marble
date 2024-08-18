extends Area2D


func _on_body_entered(body: Node2D):
	if body.name.begins_with("Ball"):
		get_tree().call_group("Level Root", "win_level")
