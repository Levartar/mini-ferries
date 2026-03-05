extends Node

var ports_in_play: Dictionary = {} # Key: CityName (enum), Value: PortNode

# Timing
var day_timer: Timer
var spawn_timer: Timer

# Game State
var game_over: bool = false

func _ready():
	setup_timers()

func setup_timers():
	# Passenger Spawner
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = 4.0 # Base spawn rate
	spawn_timer.timeout.connect(_generate_global_passenger)
	spawn_timer.start()

func register_port(port: Port):
	ports_in_play[port.city_name] = port
	# Connect the overcrowded signal
	port.overcrowded.connect(_on_port_overcrowded)

func _on_port_overcrowded(port: Port):
	print("GAME OVER! Port ", GameConstants.CityNames.keys()[port.city_name], " is overcrowded!")
	game_over = true
	# Stop spawning passengers
	spawn_timer.stop()
	# TODO: Show game over screen

func _generate_global_passenger():
	if game_over: return
	
	print("generate passenger", ports_in_play.keys())
	if ports_in_play.size() < 2: return
	
	# 1. Pick a random starting city
	var start_city = ports_in_play.keys().pick_random()
	# 2. Pick a destination (not the same as start)
	var possible_destinations = ports_in_play.keys().duplicate()
	possible_destinations.erase(start_city)
	var dest_city = possible_destinations.pick_random()
	
	# 3. Tell the specific Port to add the passenger
	if ports_in_play.has(start_city):
		ports_in_play.get(start_city).add_passenger(dest_city)
