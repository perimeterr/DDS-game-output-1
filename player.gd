extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var walkable_layers = [
	$"../TileMap/Ground",
	$"../TileMap/Bridge",
	# $"../TileMap/DirtPath",
]
var is_moving = false
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var state : String = "idle"


func _physics_process(delta):
	if is_moving == false:
		return
	
	if global_position == sprite_2d.global_position:
		is_moving = false
		return
		
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 2)

func _process(delta):
	if SetState() || SetDirection():
		UpdateAnimation()
	
	if is_moving:
		return
		
	if Input.is_action_pressed("up"):
		direction = Vector2.UP
	elif Input.is_action_pressed("down"):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("left"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("right"):
		direction = Vector2.RIGHT
	else:
		direction = Vector2.ZERO
		
	move(direction)
	
	
func get_walkable_tile_data(target_tile: Vector2i) -> TileData:
	for layer in walkable_layers:
		var tile_data = layer.get_cell_tile_data(target_tile)
		if tile_data != null and tile_data.get_custom_data("walkable") == true:
			return tile_data
	return null

func move(direction: Vector2):
	if direction == Vector2.ZERO:
		return
		
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	
	var target_tile: Vector2i = Vector2i(
		current_tile.x + direction.x,
		current_tile.y + direction.y,
	)
	
	var tile_data: TileData = get_walkable_tile_data(target_tile)
	
	if tile_data == null or tile_data.get_custom_data("walkable") == false:
		return
		
	ray_cast_2d.target_position = direction * 32
	ray_cast_2d.force_raycast_update()
	
	if ray_cast_2d.is_colliding():
		return
	
	is_moving = true
	
	global_position = tile_map.map_to_local(target_tile)
	
	sprite_2d.global_position = tile_map.map_to_local(current_tile)
	
func SetDirection() -> bool:
	var new_dir : Vector2 = direction
	if new_dir == Vector2.ZERO:
		return false
		
	if new_dir == cardinal_direction:
		return false
		
	cardinal_direction = new_dir
	
	return true
	
func SetState() -> bool:
	var new_state : String = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	state = new_state
	return true
	
func UpdateAnimation() -> void:
	animation_player.play( state + "_" + AnimDirection())
	pass
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"	
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "right"	
