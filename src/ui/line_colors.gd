extends Resource
class_name LinePalette

#Deep Navy, Viking Red, Tallink Blue, Riga Gold, etc.
const COLORS = [
	Color("002f6c"), # Navy
	Color("c8102e"), # Red
	Color("00a9e0"), # Sky
	Color("ffcd00"), # Gold
	Color("007a33")  # Green
]

# City Identity Data
const CITY_COLORS = {
	"TALLINN": Color("e6194b"),   # Red
	"HELSINKI": Color("3cb44b"),  # Green
	"STOCKHOLM": Color("ffe119"), # Yellow
	"RIGA": Color("4363d8"),      # Blue
	"TURKU": Color("f58231"),     # Orange
	"MARIEHAMM": Color("911eb4"), # Purple
	"ROSTOCK": Color("42d4f4")    # Cyan
}

static var current_index = 0

static func get_next_color() -> Color:
	var color = COLORS[current_index]
	current_index = (current_index + 1) % COLORS.size()
	return color
