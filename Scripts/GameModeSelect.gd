extends Node2D

var game_modes:Array[GameMode] = [ 
	Cement.new(),
	Gardener.new(),
	Homogeneity.new(),
	Unhurried.new(),
	Easy.new(),
	GameMode.new(),
	Challenge.new(),
	Unreasonable.new(),
	Urgent.new(),
]

var game_mode_index = Options.get_last_game_mode()

@onready var ScrollingTetriminos:EndScreenTetriminos = $"ScrollingTetriminos"
@onready var Name:RichTextLabel = $"Name"
@onready var Description:RichTextLabel = $"Description"
@onready var CarouselIndicator = $"CarouselIndicator"
@onready var CycleSFX:AudioStreamPlayer = $"Cycle"

func _ready() -> void:
	set_game_mode(game_mode_index)
	CarouselIndicator.set_length(len(game_modes))
	for i in len(game_modes):
		CarouselIndicator.set_color(i, game_modes[i].name_color)
		
	CarouselIndicator.set_current(game_mode_index)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		previous_game_mode()
	if Input.is_action_just_pressed("ui_right"):
		next_game_mode()
	

func previous_game_mode():
	CycleSFX.play()
	game_mode_index -= 1
	if game_mode_index < 0:
		game_mode_index = len(game_modes) - 1
	
	set_game_mode(game_mode_index)

func next_game_mode():
	CycleSFX.play()
	game_mode_index += 1
	if game_mode_index >= len(game_modes):
		game_mode_index = 0
	
	set_game_mode(game_mode_index)

func set_game_mode(game_mode_index) -> void:
	CurrentRun.set_game_mode(game_modes[game_mode_index])
	ScrollingTetriminos.reset()
	var m = CurrentRun.game_mode.name
	var c = CurrentRun.game_mode.name_color
	Name.text = "[color=" + c.to_html(false) + "]" + m + "[/color]"
	Description.text = CurrentRun.game_mode.description
	CarouselIndicator.set_current(game_mode_index)
	Options.set_last_game_mode(game_mode_index)
