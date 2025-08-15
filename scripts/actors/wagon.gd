@icon("res://assets/icons/node_2D/cart.png")
extends Node2D
class_name Wagon

enum ContentType {BOX, ROCK, EMPTY = -1}

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var crash_particle: CPUParticles2D = $CrashParticle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var despawn_particle: CPUParticles2D = $DespawnParticle

var dir : int = 1
var content_type : ContentType = ContentType.EMPTY
var gem_type : Gem.Type = Gem.Type.NO_GEM

var tween_pos : Tween

var start_dir : int
var start_pos : Vector2

var need_to_teleport : bool = false
var needed_to_teleport : bool = false

var pos_target : Vector2 # The actual position use for calculation
						# the global_pos is behind as it is currently in a animation

func _ready() -> void:
	start_dir = dir
	start_pos = global_position
	pos_target = global_position
	visible = false

func spawn() -> void:
	animation_player.play("spawn")
	
func reset() -> void:
	crash_particle.emitting = false
	dir = start_dir
	if tween_pos:
		tween_pos.kill()
	animation_player.play("despawn")
	await animation_player.animation_finished
	global_position = start_pos
	pos_target = start_pos
	gem_type = Gem.Type.NO_GEM
	content_type = ContentType.EMPTY
	_set_sprite()
	animation_player.play("spawn")

func move(target_pos: Vector2, target_dir: int, delay: float) -> void:
	if tween_pos:
		tween_pos.kill()
	
	if needed_to_teleport:
		needed_to_teleport = false
		
	pos_target = target_pos
	dir = target_dir
	
	if need_to_teleport:
		tween_pos = create_tween()
		despawn_particle.emitting = true
		AudioManager.play_sound("teleport")
		tween_pos.tween_property(self, "scale", Vector2.ZERO, delay / 2)
		tween_pos.tween_callback(func() : global_position = target_pos)
		tween_pos.tween_property(self, "scale", Vector2.ONE, delay / 2)
		
		need_to_teleport = false
		needed_to_teleport = true
	else:
		tween_pos = create_tween()
		tween_pos.tween_property(self, "global_position", pos_target, delay)
	
		
	
	_set_sprite()
	
func crashed() -> void:
	crash_particle.emitting = true

func clear() -> void:
	content_type = ContentType.EMPTY
	gem_type = -1
	_set_sprite()

func take_box(gem: Gem.Type) -> void:
	gem_type = gem
	content_type = ContentType.BOX
	_set_sprite()
		
func contains(gem: Gem.Type) -> bool:
	if is_empty(): return false
	return gem_type == gem

func is_empty() -> bool:
	return content_type == ContentType.EMPTY

func _set_sprite() -> void:
	var dir_y : bool = dir == 0 or dir == 2
	match content_type:
		ContentType.ROCK:
			if dir_y:
				sprite_2d.frame = 3
			else:
				sprite_2d.frame = 1
		ContentType.BOX:
			if dir_y:
				sprite_2d.frame = 4
			else:
				sprite_2d.frame = 2
		_:
			if dir_y:
				sprite_2d.frame = 5
			else:
				sprite_2d.frame = 0
