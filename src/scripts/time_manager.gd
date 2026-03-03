extends Node

signal week_ended(new_week_number)
signal new_ship_granted

# Game Settings
const DAY_DURATION_SECONDS = 30.0 # Each game day is 30 seconds
const DAYS_PER_WEEK = 7

var current_day: int = 1
var day_timer: Timer

func _ready():
	day_timer = Timer.new()
	add_child(day_timer)
	day_timer.wait_time = DAY_DURATION_SECONDS
	day_timer.autostart = true
	day_timer.timeout.connect(_on_day_ended)
	day_timer.start()

func _on_day_ended():
	current_day += 1
	print("Day ", current_day, " has begun!")
	
	# Check for "Monday"
	if current_day % DAYS_PER_WEEK == 0:
		var current_week = current_day / DAYS_PER_WEEK
		week_ended.emit(current_week)
		new_ship_granted.emit() # Game Manager listens to this and adds a ship token
