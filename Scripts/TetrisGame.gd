extends Node2D
class_name TetrisGame

const WIDTH: int = 10
const HEIGHT: int = 20
const CELL_SIZE: int = 32

var animation_speed = Options.get_animation_speed()
var game_speed = Options.get_game_speed()
var tick_length = 0.05/game_speed
var tick_progress = 0.0

const cell_prefab: PackedScene = preload("res://Prefabs/Cell.tscn")
const tetriminos_prefab: PackedScene = preload("res://Prefabs/Tetriminos.tscn")
const selector_prefab: PackedScene = preload("res://Scenes/Run Menus/Selector.tscn")
const cell_collider:PackedScene = preload("res://Prefabs/CellCollider.tscn")

@onready var run_state:RunState = CurrentRun
@onready var remaining_time_label:RichTextLabel = $"Remaining Time"
@onready var status_label:RichTextLabel = $"Status Wiggler/Status Label"
@onready var current_level_text:RichTextLabel = $"CurrentLevel"
@onready var score_counter:ScoreCounter = $"ScoreCounter"
@onready var background:FillableBackground = $"background"
@onready var held = $"Held"
@onready var next = $"Next"
@onready var next_tetriminos:Tetriminos = $"Next/Wiggler/NextTetriminos"
@onready var held_tetriminos:Tetriminos = $"Held/Wiggler/HeldTetriminos"
@onready var continue_button = $"ContinueButton"
@onready var reward_label:RichTextLabel = $"Reward"
@onready var reward_indicator:RewardIndicator = $"RewardIndicator"

@onready var move_sound:AudioStreamPlayer = $"Sounds/Move"
@onready var spin_sound:AudioStreamPlayer = $"Sounds/Spin"
@onready var smash_sound:AudioStreamPlayer = $"Sounds/Smash"
@onready var clear_sound:AudioStreamPlayer = $"Sounds/Clear"
@onready var hold_sound:AudioStreamPlayer = $"Sounds/Hold"
@onready var win_sound:AudioStreamPlayer = $"Sounds/NextLevel"
@onready var dead_sound:AudioStreamPlayer = $"Sounds/Dead"
@onready var timer_beep:AudioStreamPlayer = $"Sounds/TimerBeep"
@onready var flatline_sound:AudioStreamPlayer = $"Sounds/Flatline"
@onready var background_music:AudioStreamPlayer = $"Tetrogue-Main"


@export var remaining_time: float = 50
@export var max_time: float = 50
@export var score_goal: int = 100
var tick_number: int = 0 # The current tick count
@export var move_interval_ticks: int = 14
@export var move_fast_interval_ticks: int = 2
@export var move_sideways_interval: float = 0.1 # Time between moves in seconds
@export var row_clear_modulation: Color = Color(1.2, 1.2, 1.2)

var pause: bool = false
var died: bool = false

var smash_next: bool = false
var hold_next: bool = false
var hold_locked:bool = false
var clearing: bool = false

var grid: Array = []
var falling_tetriminos: Tetriminos = null
var ticks_since_last_down_move: int = 0
var time_since_last_sideways_move: float = 0
var tetriminos_just_landed = false     # The flag is used to prevent feel-bad of accidentally slamming a newly spawned tetriminos when you were trying to slam the one that just landed

var queued_line_clears = []
var queued_shift_above_cells_down:Array[Vector2i] = []

var move_int 

var root

func _ready() -> void:
	root = get_tree().get_root()
	status_label.text = ""
	current_level_text.text = str(run_state.level)
	for row in range(HEIGHT):
		var r = []
		for col in range(WIDTH):
			r.append(null)
		grid.append(r)
	
	load_map()
	
	run_state.new_game()
	score_goal = run_state.next_score_goal
	remaining_time = run_state.next_time_limit
	if run_state.next_reward == LevelOption.RewardType.Nothing:
		reward_label.visible = false
		reward_indicator.visible = false
	reward_indicator.set_reward_type(run_state.next_reward)
	reward_indicator.set_wiggle(false)
	max_time = remaining_time
	remaining_time_label.set_max_time(max_time)
	
	if run_state.previously_held != null and !run_state.previously_held.is_empty():
		held_tetriminos.setup(run_state.previously_held)
		run_state.remove_from_curent_stash(run_state.previously_held)

func out_of_bounds(x: int, y: int) -> bool:
	# NOTE: There is no lower bound on y axis (upwards)
	return x < 0 || x >= WIDTH || y >= HEIGHT

func get_at(x: int, y: int) -> Cell:
	if out_of_bounds(x, y) || y < 0:
		return null
	return grid[y][x]


func set_at(x: int, y: int, type: Cell.Type) -> Cell:
	var cur = get_at(x, y)
	if cur != null:
		return cur  # TODO: Replace?
	var cell = cell_prefab.instantiate()
	add_child(cell)
	cell.position = Vector2i(x * CELL_SIZE, y * CELL_SIZE)
	cell.grid_pos = Vector2i(x, y)
	cell.type = type
	grid[y][x] = cell
	return cell


# See also destroy_at
func remove_at(x: int, y: int):
	var c = get_at(x, y)
	if c != null:
		grid[y][x] = null
		c.queue_free()


# Similar to remove_at but triggers the cell's on_destory effect (possibly preventing destruction)
func destroy_at(x: int, y: int):
	var c = get_at(x, y)
	if c != null:
		# Pass self in case destruction has side effects (e.g. bomb)
		c.destroy(self)


# See also try_move_cell.
# Destination must be empty.
func move_cell(from_x: int, from_y: int, to_x: int, to_y: int):
	var c: Cell = get_at(from_x, from_y)
	if c == null:
		return
	assert(get_at(to_x, to_y) == null, "Destination must be empty")
	grid[from_y][from_x] = null
	c.grid_pos = Vector2i(to_x, to_y)
	c.position = c.grid_pos * CELL_SIZE
	grid[to_y][to_x] = c


# Similar to move_cell but triggers the cell's on_move effect (possibly preventing the move).
func try_move_cell(from_x: int, from_y: int, to_x: int, to_y: int) -> bool:
	var c = get_at(from_x, from_y)
	if c == null || not get_at(to_x, to_y) == null || out_of_bounds(to_x, to_y):
		return false
	# Pass self in case movement has side effects
	if c.on_move(self, to_x, to_y):
		move_cell(from_x, from_y, to_x, to_y)
		return true
	return false


func shift_above_cells_down(x: int, y: int):
	var c = get_at(x, y)
	if c != null:
		return
	for from_y in range(y - 1, -1, -1):
		var to_y = from_y + 1
		if get_at(x, from_y) != null && not try_move_cell(x, from_y, x, to_y):
			# A cell refused to move, skip the rest
			return


func shift_cells_down_range(x: int, min_y: int, max_y: int):
	var c = get_at(x, max_y)
	if c != null:
		return
	for from_y in range(max_y - 1, max(-1, min_y - 1), -1):
		var to_y = from_y + 1
		move_cell(x, from_y, x, to_y)


func swap(x1: int, y1: int, x2: int, y2: int):
	var fst = get_at(x1, y1)
	var snd = get_at(x2, y2)
	if fst == null:
		move_cell(x2, y2, x1, y1)
		return
	if snd == null:
		move_cell(x1, y1, x2, y2)
		return
	grid[y1][x1] = snd
	snd.grid_pos = Vector2i(x1, y1)
	snd.position = snd.grid_pos * CELL_SIZE
	grid[y2][x2] = fst
	fst.grid_pos = Vector2i(x2, y2)
	fst.position = fst.grid_pos * CELL_SIZE


func queue_line_clear(y: int):
	if y < 0 || y >= HEIGHT:
		return
	queued_line_clears.append(y)

func queue_shift_above_cells_down(x:int, y:int):
	queued_shift_above_cells_down.append(Vector2i(x, y))

func set_remaining_time(new_time):
	remaining_time = new_time
	remaining_time_label.set_time(remaining_time)


func _draw() -> void:
	# Background
	if falling_tetriminos != null:
		var min_y_cells: Dictionary = {}
		for cell in falling_tetriminos.cells:
			if min_y_cells.has(cell.grid_pos.x):
				min_y_cells[cell.grid_pos.x] = min(cell.grid_pos.y, min_y_cells[cell.grid_pos.x])
			else:
				min_y_cells[cell.grid_pos.x] = cell.grid_pos.y
				
		for x in min_y_cells:
			var grid_pos = falling_tetriminos.grid_pos + Vector2i(x, min_y_cells[x])
			var r = Rect2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE, CELL_SIZE, (HEIGHT - grid_pos.y) * CELL_SIZE)
			draw_rect(r, Color.BLACK * 0.3)
		
		var height = 0
		while try_move_falling_tetriminos_down(false):
			height += 1
		for cell in falling_tetriminos.cells:
			var grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
			var r = Rect2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
			var sprite_coords = Cell.SpriteCoords[cell.type]
			draw_texture_rect_region(cell.silhouettes, r, Rect2(sprite_coords.x, sprite_coords.y, Cell.SPRITE_SIZE, Cell.SPRITE_SIZE), Color.WHITE * 0.5)
		try_move_falling_tetriminos_up(height)


func get_next_tetriminos_from_deck() -> TetriminosTemplate:
	var next = run_state.pop_from_stash()
	var next_next = run_state.peek_next()
	next_tetriminos.setup(next_next)
	return next

func _process(delta):
	queue_redraw()
	if pause:
		if died:
			background_music.pitch_scale -= delta/2
		else:
			background_music.volume_linear -= delta*0.5
		return
	
	if clearing:
		return
	
	if Input.is_action_just_pressed("slam_down"):
		if falling_tetriminos != null and !smash_next and !tetriminos_just_landed:
			smash_sound.pitch_scale = 1.
			smash_sound.play()
			smash_next = true
		else:
			move_sound.pitch_scale = 0.7
			move_sound.play()
	
	if Input.is_action_just_pressed("hold") and !hold_next and !hold_locked:
		hold_sound.pitch_scale = 1
		hold_sound.play()
		hold_next = true
	elif Input.is_action_just_pressed("hold") and hold_locked:
		hold_sound.pitch_scale = 0.7
		hold_sound.play()
	
	if Input.is_action_just_pressed("ui_right"):
		tetriminos_just_landed = false
		if try_move_falling_tetriminos_x(1):
			move_sound.pitch_scale = 1
			move_sound.play()
			time_since_last_sideways_move = -move_sideways_interval # Wait an extra beat before it keeps moving
		else:
			move_sound.pitch_scale = 0.7
			move_sound.play()
	elif Input.is_action_just_pressed("ui_left"):
		tetriminos_just_landed = false
		if try_move_falling_tetriminos_x(-1):
			move_sound.pitch_scale = 1
			move_sound.play()
			time_since_last_sideways_move = -move_sideways_interval # Wait an extra beat before it keeps moving
		else:
			move_sound.pitch_scale = 0.7
			move_sound.play()
	elif Input.is_action_just_pressed("ui_down"):
		tetriminos_just_landed = false
		if try_move_falling_tetriminos_down():
			ticks_since_last_down_move = 0
	elif Input.is_action_just_pressed("rotate_clockwise"):
		tetriminos_just_landed = false 
		if try_rotate_falling_tetriminos(false):
			spin_sound.pitch_scale = 1
			spin_sound.play()
		else:
			spin_sound.pitch_scale = 0.6
			spin_sound.play()
	elif Input.is_action_just_pressed("rotate_counter_clockwise"):
		tetriminos_just_landed = false 
		if try_rotate_falling_tetriminos(true):
			spin_sound.pitch_scale = 1
			spin_sound.play()
		else:
			spin_sound.pitch_scale = 0.6
			spin_sound.play()
	
	# Move sideways if key is held.
	time_since_last_sideways_move += delta
	if falling_tetriminos != null && time_since_last_sideways_move >= move_sideways_interval:
		if Input.is_action_pressed("ui_right"):
			if try_move_falling_tetriminos_x(1):
				time_since_last_sideways_move = 0
		elif Input.is_action_pressed("ui_left"):
			if try_move_falling_tetriminos_x(-1):
				time_since_last_sideways_move = 0
	
	
	if remaining_time - floor(remaining_time) < delta and remaining_time < 7 and remaining_time > 1:
		if remaining_time > 2:
			timer_beep.play()
		else:
			flatline_sound.play()
		
	
	if remaining_time > 1:
		remaining_time -= delta
	else:
		remaining_time -= delta / 3 # Artificially extend the last second
	remaining_time_label.set_time(remaining_time)
	
	if score_counter.current_score >= score_goal:
		win()
	
	if remaining_time < 0:
		dead()
	
	tick_progress += delta
	if tick_progress > tick_length:
		tick_progress = 0.0
		_on_tick()


func _on_tick() -> void:
	if pause or clearing:
		return
	tick_number += 1
	
	background.set_filled(remaining_time / max_time)
	
	clear_full_rows()
	clear_queued_columns()

	# Call on_tick for all cells in order of their type
	var cell_type_to_cells: Dictionary[Cell.Type, Array] = {}
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var cell = get_at(x, y)
			if cell != null:
				if not cell.type in cell_type_to_cells:
					cell_type_to_cells[cell.type] = []
				cell_type_to_cells[cell.type].append(cell)
	
	for cell_type in Cell.Type.values():
		if cell_type in cell_type_to_cells:
			for cell in cell_type_to_cells[cell_type]:
				cell.on_tick(self, tick_number)
	
	if Input.is_physical_key_pressed(KEY_PAGEUP):
		win()
	
	if smash_next:
		smash_next = false
		# Hard drop
		if falling_tetriminos != null:
			while try_move_falling_tetriminos_down():
				pass
			ticks_since_last_down_move = 0
			return
	elif hold_next:
		hold_next = false
		if falling_tetriminos == null: # Address race condition where player can press "hold" before a tetriminos is spawned in
			return
		hold_locked = true
		var previously_held:TetriminosTemplate = held_tetriminos.template
		held_tetriminos.setup(falling_tetriminos.template)
		falling_tetriminos.queue_free()
		spawn_new_tetriminos(previously_held)	# previously_held might be null, which is fine.
		return
	else:
		# Move downwards regularly, but faster if key is held
		ticks_since_last_down_move += 1
		var interval = move_fast_interval_ticks if Input.is_action_pressed("ui_down") else move_interval_ticks
		if ticks_since_last_down_move < interval:
			return
		
		ticks_since_last_down_move = 0
			
		if falling_tetriminos != null:
			# Move down
			if try_move_falling_tetriminos_down():
				tetriminos_just_landed = false
			else:
				tetriminos_just_landed = true
			return
	
	# Fallback: If we do not have a falling tetriminos, spawn one instead
	spawn_new_tetriminos()

func spawn_new_tetriminos(template:TetriminosTemplate=null):
	if template == null:
		template = get_next_tetriminos_from_deck()
	falling_tetriminos = tetriminos_prefab.instantiate()
	add_child(falling_tetriminos)
	falling_tetriminos.setup(template)
	@warning_ignore("integer_division") var grid_pos = Vector2i(WIDTH / 2, 0)
	falling_tetriminos.position = grid_pos * CELL_SIZE
	falling_tetriminos.grid_pos = grid_pos


	# If we immediately collide with existing cells -> game over
	if does_falling_tetriminos_collide():
		dead()


func try_move_falling_tetriminos_x(delta: int) -> bool:
	if falling_tetriminos == null:
		return false
	falling_tetriminos.grid_pos.x += delta
	falling_tetriminos.position.x += delta * CELL_SIZE
	if does_falling_tetriminos_collide():
		# Undo move
		falling_tetriminos.grid_pos.x -= delta
		falling_tetriminos.position.x -= delta * CELL_SIZE
		return false
	return true


# Returns true if it moved; false if landed OR if null
func try_move_falling_tetriminos_down(land: bool=true) -> bool:
	if falling_tetriminos == null:
		return false
	falling_tetriminos.grid_pos.y += 1
	falling_tetriminos.position.y += CELL_SIZE
	if does_falling_tetriminos_collide():
		# Undo move and place instead
		falling_tetriminos.grid_pos.y -= 1
		falling_tetriminos.position.y -= CELL_SIZE
		if land:
			place_falling_tetriminos()
		return false
	return true


func try_move_falling_tetriminos_up(steps: int=1) -> bool:
	if falling_tetriminos == null:
		return false
	falling_tetriminos.grid_pos.y -= steps
	falling_tetriminos.position.y -= steps * CELL_SIZE
	if does_falling_tetriminos_collide():
		# Undo move and place instead
		falling_tetriminos.grid_pos.y += steps
		falling_tetriminos.position.y += steps * CELL_SIZE
		return false
	return true


func try_rotate_falling_tetriminos(counter_clockwise:bool) -> bool:
	if falling_tetriminos == null:
		return false
	rotate_falling_tetriminos(counter_clockwise)
	if not does_falling_tetriminos_collide():
		return true
	
	# Colliding! Try to avoid collision by moving left or right
	try_move_falling_tetriminos_x(1)
	if not does_falling_tetriminos_collide():
		return true
	try_move_falling_tetriminos_x(-1)
	if not does_falling_tetriminos_collide():
		return true
	
	# Rotation failed, undo
	rotate_falling_tetriminos(false)
	return false


func rotate_falling_tetriminos(counter_clockwise: bool) -> void:
	if counter_clockwise:
		for cell in falling_tetriminos.cells:
			cell.grid_pos = Vector2i(cell.grid_pos.y, -cell.grid_pos.x)
			cell.position = cell.grid_pos * CELL_SIZE
	else:
		for cell in falling_tetriminos.cells:
			cell.grid_pos = Vector2i(-cell.grid_pos.y, cell.grid_pos.x)
			cell.position = cell.grid_pos * CELL_SIZE


func does_falling_tetriminos_collide() -> bool:
	for cell in falling_tetriminos.cells:
		var res_grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
		if out_of_bounds(res_grid_pos.x, res_grid_pos.y):
			return true
		if get_at(res_grid_pos.x, res_grid_pos.y) != null:
			return true
	
	return false


func place_falling_tetriminos() -> void:
	for cell in falling_tetriminos.cells:
		var res_grid_pos = falling_tetriminos.grid_pos + cell.grid_pos
		set_at(res_grid_pos.x, res_grid_pos.y, cell.type)
		if get_at(res_grid_pos.x, res_grid_pos.y) == null:
			dead()
		else:
			get_at(res_grid_pos.x, res_grid_pos.y).on_place(self)
	falling_tetriminos.queue_free()
	falling_tetriminos = null
	hold_locked = false
	
	spawn_new_tetriminos()


func clear_full_rows():
	for y in range(HEIGHT):
		var do_clear = true
		for x in range(WIDTH):
			if get_at(x, y) == null:
				do_clear = false
				continue
		if do_clear:
			queued_line_clears.append(y)
	
	if len(queued_line_clears) > 0:
		score_counter.bump_streak()
		clearing = true
		
		for y in queued_line_clears:
			for x in WIDTH:
				var cell = get_at(x, y)
				if cell != null:
					cell.modulate += Color(0.2, 0.2, 0.2)
		
		var l = len(queued_line_clears)
		var mult =  0 if l == 1 else l - 1 if l < 4 else l
		
		if mult > 0:
			var pos = get_at(WIDTH - 1, queued_line_clears.min()).position
			pos.x += 50
			clear_sound.pitch_scale = 0.5
			clear_sound.play()
			score_counter.add_mult(mult, pos)
			await get_tree().create_timer(0.8/animation_speed).timeout
	
	var cleared_lines = []
	
	# Destroy all tiles in the cleared rows, applying mult
	var first = true
	var pitch = 1.0
	while len(queued_line_clears) > 0:
		# NOTE: More lines may be queued by cells during this loop, e.g. by bombs
		var y = queued_line_clears.pop_front()
		if y in cleared_lines:
			continue  # Do not double clear
		cleared_lines.append(y)
		first = false
		for x in range(WIDTH):
			var c: Cell = get_at(x, y)
			if c == null:
				pass
			clear_sound.pitch_scale = pitch
			clear_sound.play()
			pitch += 0.1
			destroy_at(x, y)
			await get_tree().create_timer(0.1/animation_speed).timeout
		
	# Then shift cells down (affects resolution order)
	cleared_lines.sort()
	for y in cleared_lines:
		for x in range(WIDTH):
			shift_above_cells_down(x, y)
	
	clearing = false
	queued_line_clears.clear()
	return len(cleared_lines) > 0

func clear_queued_columns():
	for pos in queued_shift_above_cells_down:
		shift_above_cells_down(pos.x, pos.y)
	queued_shift_above_cells_down = []

func win():
	run_state.register_score(score_counter.current_score)
	run_state.previously_held = held_tetriminos.template
	run_state.previously_held_position = held_tetriminos.global_position
	run_state.previously_next = next_tetriminos.template
	run_state.previously_next_position = next_tetriminos.global_position
	run_state.previously_falling = falling_tetriminos.template
	run_state.previously_falling_position = falling_tetriminos.global_position
	if run_state.level == run_state.game_mode.win_level:
		go_to_win_screen()
	run_state.increment_level()
	status_label.text = "[color=green]Winner! :-)[/color]"
	pause = true
	win_sound.play()
	reward_indicator.set_wiggle(true)
	continue_button.visible = true
	continue_button.grab_focus()

func dead():
	run_state.register_score(score_counter.current_score)
	status_label.text = "[color=red]DIED :'([/color]"
	dead_sound.play()
	pause = true
	died = true
	continue_button.visible = true
	continue_button.grab_focus()
	
	for row in grid:
		for cell:Cell in row:
			make_floppy(cell)
	
	for cell:Cell in held_tetriminos.cells:
		make_floppy(cell)
		
	for cell:Cell in next_tetriminos.cells:
		make_floppy(cell)
	
	for cell:Cell in falling_tetriminos.cells:
		make_floppy(cell)

func make_floppy(cell:Cell) -> void:
	if cell == null:
		return
	cell.reparent(self)
	var collider:RigidBody2D = cell_collider.instantiate()
	collider.position = cell.position
	collider.scale = cell.scale
	var angle = randf_range(-3*PI/4, -PI/4) # I only want it to be on upwards trajectories
	var magnitude = randf_range(100., 200.)
	collider.linear_velocity = (Vector2(cos(angle)*magnitude, sin(angle)*magnitude))
	cell.get_parent().add_child(collider)
	cell.reparent(collider)

func _on_continue_button_pressed() -> void:
	if died:
		get_tree().change_scene_to_file("res://Scenes/Run Menus/EndScreen.tscn")
	else:
		match run_state.next_reward:
			LevelOption.RewardType.Create:
				get_tree().change_scene_to_file("res://Scenes/Run Menus/Selector.tscn")
			LevelOption.RewardType.Destroy:
				get_tree().change_scene_to_file("res://Scenes/Run Menus/Destroy.tscn")
			#LevelOption.RewardType.Modify:
			LevelOption.RewardType.Nothing:
				get_tree().change_scene_to_file("res://Scenes/Run Menus/NextLevelSelect.tscn")
			_:
				assert(false, "Not supported")
				get_tree().change_scene_to_file("res://Scenes/Run Menus/NextLevelSelect.tscn")
	
func load_map():
	var map = run_state.get_map()
	
	for row in WIDTH:
		for col in HEIGHT:
			var cell = map[row][col]
			if cell == null:
				continue
			set_at(row, col, cell)

func go_to_win_screen():
	for row in range(HEIGHT):
		var r = []
		for col in range(WIDTH):
			var c = get_at(col, row)
			if c != null:
				r.append(c.type)
			else:
				r.append(c)
		run_state.game_grid.append(r)
	
	run_state.game_background_filledness = background.get_filled()
	run_state.game_animated_background = $"../AnimatedBackground"
	run_state.game_animated_background.get_parent().remove_child(run_state.game_animated_background)
	
	run_state.previously_held = held_tetriminos.template
	run_state.previously_held_position = held_tetriminos.global_position
	run_state.previously_next = next_tetriminos.template
	run_state.previously_next_position = next_tetriminos.global_position
	run_state.previously_falling = falling_tetriminos.template
	run_state.previously_falling_position = falling_tetriminos.global_position
	
	get_tree().change_scene_to_file("res://Scenes/Run Menus/WinScreen.tscn")
