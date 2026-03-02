extends Resource
class_name LinePalette

# Baltic-inspired colors: Deep Navy, Viking Red, Tallink Blue, Riga Gold, etc.
const COLORS = [
	Color("002f6c"), # Navy
	Color("c8102e"), # Red
	Color("00a9e0"), # Sky
	Color("ffcd00"), # Gold
	Color("007a33")  # Green
]

static var current_index = 0

static func get_next_color() -> Color:
	var color = COLORS[current_index]
	current_index = (current_index + 1) % COLORS.size()
	return color
