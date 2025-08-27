extends Node2D

@onready var tile_map : TileMap = $"../TileMap"
@onready var sprite_2d : Sprite2D = $Sprite2D
@onready var ray_cast_2d : RayCast2D = $RayCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var walkable_layers = [
	$"../TileMap/Ground",
	$"../TileMap/Bridge",
]

@onready var blocking_layers = [
	$"../TileMap/Obstacles",
]

var is_moving = false
var is_sliding = false
var slide_queue: bool = false
var slide_direction: Vector2 = Vector2.ZERO
var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var state : String = "idle"

const TILE_SIZE: int = 32
const MOVE_SPEED: float = 2.0

func _ready():
	sprite_2d.frame = 24

func _physics_process(delta):
	if is_moving == false:
		if slide_queue:
			slide_queue = false
			is_sliding = true
			move(slide_direction)
		else:
			is_sliding = false
		return
	
	if sprite_2d.global_position == global_position:
		is_moving = false
		var current_tile: Vector2i = tile_map.local_to_map(global_position)
		var tile_data: TileData = get_walkable_tile_data(current_tile)
		if tile_data and tile_data.get_custom_data("slide") == true:
			slide_queue = true
			
		elif tile_data.has_custom_data("arrow"):
			var arrow_dir: Vector2 = tile_data.get_custom_data("arrow")
			if arrow_dir != Vector2.ZERO:
				slide_queue = true
				slide_direction = arrow_dir
				is_sliding = true
			else:
				is_sliding = false
		
	sprite_2d.global_position = sprite_2d.global_position.move_toward(global_position, 2)

func _process(delta):
	if SetState():
		UpdateAnimation()
	
	if is_moving || is_sliding:
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
		
	if SetDirection():
		UpdateAnimation()
		
	move(direction)
	
func get_walkable_tile_data(target_tile: Vector2i) -> TileData:
	for layer in walkable_layers:
		var tile_data = layer.get_cell_tile_data(target_tile)
		if tile_data != null and tile_data.get_custom_data("walkable") == true:
			return tile_data
	return null

func is_blocked(target_tile: Vector2i) -> bool:
	for layer in blocking_layers:
		var tile_data = layer.get_cell_tile_data(target_tile)
		if tile_data != null: 
			return true
	return false

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
		
	if is_blocked(target_tile):
		return
		
	if tile_data == null or tile_data.get_custom_data("slide") == true:
		is_sliding = true
		slide_direction = cardinal_direction
	
	is_moving = true
	cardinal_direction = direction
	
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
	if !is_moving:
		state = "idle"
		return true
	var new_state : String = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	state = new_state
	return true
	
func UpdateAnimation() -> void:
	if is_sliding:
		animation_player.pause()
		if slide_direction == Vector2.UP:
			sprite_2d.frame = 32
		elif slide_direction == Vector2.RIGHT:
			sprite_2d.frame = 33
		elif slide_direction == Vector2.LEFT:
			sprite_2d.frame = 34
		elif slide_direction == Vector2.DOWN:
			sprite_2d.frame = 35
		return

	animation_player.play( state + "_" + AnimDirection())
		
	
func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"	
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "right"	
