extends RefCounted

const INK := Color("#14294a")

static func surface(color: Color, radius: int = 16, padding: int = 12,
		opacity: float = 1.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	for side in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
		box.set_content_margin(side, padding)
	return box

static func card(color: Color = Color.WHITE, padding: int = 14, radius: int = 18) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", surface(color, radius, padding))
	return panel

static func label(copy: String, font_size: int = 16, color: Color = INK) -> Label:
	var result := Label.new()
	result.text = copy
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_color_override("font_color", color)
	result.add_theme_font_size_override("font_size", font_size)
	return result

static func button(copy: String, primary: bool = false, radius: int = 14) -> Button:
	var result := Button.new()
	result.text = copy
	result.custom_minimum_size.y = 48
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for state in ["normal", "hover", "pressed", "disabled", "hover_pressed"]:
		var base := surface(Color("#e0f1f4"), radius, 10)
		if state == "hover":
			base = surface(Color("#c4e6ea"), radius, 10)
		elif state == "pressed":
			base = surface(Color("#81a1a9"), radius, 10)
		elif state == "hover_pressed":
			base = surface(Color("#7c98a0"), radius, 10)
		elif state == "disabled":
			base = surface(Color("#e3e6e8"), radius, 10)
		result.add_theme_stylebox_override(state, base)
	for key in ["font_color", "font_hover_color", "font_pressed_color",
			"font_hover_pressed_color", "font_focus_color"]:
		result.add_theme_color_override(key, MINT if not primary else Color.WHITE)
	result.add_theme_color_override("font_disabled_color", MUTED)
	return result

static func style_button(result: Button, primary: bool = false) -> Button:
	for key in ["font_color", "font_hover_color", "font_pressed_color",
			"font_hover_pressed_color", "font_focus_color"]:
		result.add_theme_color_override(key, MINT if not primary else Color.WHITE)
	result.add_theme_color_override("font_disabled_color", MUTED)
	return result

static func theme_setup() -> Theme:
	var theme := Theme.new()
	var green := StyleBoxFlat.new()
	green.bg_color = Color("#e3f2e6")
	green.set_corner_radius_all(11)
	for side in [SIDE_TOP, SIDE_BOTTOM, SIDE_LEFT, SIDE_RIGHT]:
		green.set_content_margin(side, 11)
	theme.set_default_stylebox("Button", "normal", green)
	theme.set_default_stylebox("Button", "hover", surface(Color("#d1ead7")))
	theme.set_default_stylebox("Button", "pressed", surface(Color("#a4c2a4")))
	theme.set_default_color("Button", "font_color", Color.WHITE)
	theme.set_default_color("Button", "font_hover_color", Color.WHITE)
	theme.set_default_color("Button", "font_pressed_color", Color.WHITE)
	theme.set_default_color("Button", "font_focus_color", Color.WHITE)
	theme.set_default_color("Button", "font_disabled_color", MUTED)
	theme.set_default_color("PanelContainer", "background", Color.WHITE)
	theme.set_default_color("ProgressBar", "font_color", INK)
	theme.set_default_color("ProgressBar", "fill_color", Color.WHITE)
	theme.set_default_color("Label", "font_color", INK)
	return theme

static func column(spacing: int = 14) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	return box

static func row(spacing: int = 12) -> HBoxContainer:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", spacing)
	return box

static func flow(spacing: int = 10) -> HFlowContainer:
	var box := HFlowContainer.new()
	box.add_theme_constant_override("h_separation", spacing)
	box.add_theme_constant_override("v_separation", spacing)
	return box

static func grid(spacing: int = 12) -> GridContainer:
	var box := GridContainer.new()
	box.add_theme_constant_override("h_separation", spacing)
	box.add_theme_constant_override("v_separation", spacing)
	return box

static func xp_track(value: float, target: float) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.max_value = target
	bar.value = value
	bar.show_percentage = false
	bar.custom_minimum_size.y = 10
	bar.add_theme_stylebox_override("background", surface(Color("#edf0f5"), 5, 0))
	bar.add_theme_stylebox_override("fill", surface(Color("#3e9a7e"), 5, 0))
	return bar

static func primary_button(copy: String) -> Button:
	var result := button(copy, true)
	result.add_theme_stylebox_override("normal", surface(Color("#e2dffb"), 16, 12))
	result.add_theme_stylebox_override("hover", surface(Color("#3b5fa8"), 16, 12))
	result.add_theme_stylebox_override("pressed", surface(Color("#b8c4f0"), 16, 12))
	result.add_theme_stylebox_override("disabled", surface(Color("#e7e7e7"), 16, 12))
	return result

static func card_str(color: String, padding: int = 14, radius: int = 18) -> PanelContainer:
	return card(Color(color), padding, radius)

static var MUTED: Color
static var GOLD := Color("#fff3b0")
static var CYAN := Color("#b3e2ff")
static var WHITE := Color("#ffffff")
static var CORAL := Color("#f47c69")
static var MINT := Color("#d6f5eb")
static var PAPER := Color("#fffdf8")
static var ROSE := Color("#f5d8e4")
static var BLUE := Color("#254bba")
static var ORCHARD := Color("#7b5fd6")
static var CRIMSON := Color("#d62c4f")
static var FOREST := Color("#2e8a5c")
static var MINT_GREEN := Color("#5ec3a0")
static var NAPLES := Color("#f6d497")
static var HONEY := Color("#f1c060")
static var CREAM := Color("#fff0b8")
static var TEAL := Color("#0e8f7c")
static var CORAL_LIGHT := Color("#eab5a4")
static var MIDNIGHT := Color("#14294a")
static var STORM := Color("#8fd0e6")
