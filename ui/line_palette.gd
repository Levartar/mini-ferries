extends Resource
class_name LinePalette

enum CityNames {
	TALLINN,
	HELSINKI,
	STOCKHOLM,
	RIGA,
	MARIENHAMN,
	ROSTOCK
}

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
	GameConstants.CityNames.TALLINN: Color("457b9d"),   # Red
	GameConstants.CityNames.HELSINKI: Color("a8dadc"),  # Green
	GameConstants.CityNames.STOCKHOLM: Color("ffb703"), # Yellow
	GameConstants.CityNames.RIGA: Color("e63946"),      # Blue
	GameConstants.CityNames.TURKU: Color("f1faee"),     # Orange
	GameConstants.CityNames.MARIENHAMN: Color("1d3557"), # Purple
	GameConstants.CityNames.ROSTOCK: Color("02c39a")    # Cyan
}

static var current_index = 0

static func get_next_color() -> Color:
	var color = COLORS[current_index]
	current_index = (current_index + 1) % COLORS.size()
	return color
