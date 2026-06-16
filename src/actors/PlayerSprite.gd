extends AnimatedSprite2D

func set_skin(skin: String) -> void:
	sprite_frames = sprite_frames.duplicate()
	
	for anim in sprite_frames.get_animation_names():
		for i in range(sprite_frames.get_frame_count(anim)):
			var old_texture = sprite_frames.get_frame_texture(anim, i)
			
			if old_texture and old_texture.resource_path != "":
				var old_path = old_texture.resource_path
				var new_path = old_path.replace("green", skin)
				
				if ResourceLoader.exists(new_path):
					var new_texture = load(new_path)
					var duration = sprite_frames.get_frame_duration(anim, i)
					sprite_frames.set_frame(anim, i, new_texture, duration)
				else:
					push_warning("Could not find skin texture: " + new_path)
