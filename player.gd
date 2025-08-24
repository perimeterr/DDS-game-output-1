extends Node2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var walkable_layers = [
	$"../TileMap/Ground",
	$"../TileMap/Bridge",
]
var is_moving = false


func _physics_process(delta):
	if is_moving == false:
		return
	
	if global_position == sprite_2d.global_position:
		is_moving = false
		return
		
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 2)

func _process(delta):
	if is_moving:
		return
		
	if Input.is_action_pressed("up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT)
		
func get_walkable_tile_data(target_tile: Vector2i) -> TileData:
	for layer in walkable_layers:
		var tile_data = layer.get_cell_tile_data(target_tile)
		if tile_data != null and tile_data.get_custom_data("walkable") == true:
			return tile_data
	return null

func move(direction: Vector2):
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
