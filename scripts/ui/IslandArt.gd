extends Node3D

const GRASS := Color("#64aa7e")
const SAND := Color("#f6d497")
const ROCK := Color("#6c82a1")
const NAVY := Color("#213d68")
const CORAL := Color("#f05a66")
const TEAL := Color("#238f83")
const CREAM := Color("#fff0c0")
const TERRAIN := [Color("#64aa7e"), Color("#a3a2d9"), Color("#d9aa68"), Color("#66afb1")]
const SHORE := [Color("#f6d497"), Color("#cad1ef"), Color("#f6d999"), Color("#b3ede5")]
const WATER := [Color("#409bc2"), Color("#6c88cb"), Color("#cb947e"), Color("#377fb7")]
const NAMES := ["Les Jardins du Calcul", "Les Ruines aux Formes", "Le Désert des Mesures", "L’Archipel des Données"]
const BOUNDS := 31.0
const ROUTE := [
	Vector3(0, 0, -6), Vector3(9, 0, -12), Vector3(16, 0, -6),
	Vector3(23, 0, 0), Vector3(22, 0, 11), Vector3(13, 0, 21),
	Vector3(0, 0, 26), Vector3(-13, 0, 21), Vector3(-23, 0, 11),
	Vector3(-27, 0, -2)
]

var biome := 0
var preview_only := false
var avatar: CharacterBody3D
var flag: Node3D
var pennant: Node3D
var legs: Array[Node3D] = []
var arms: Array[Node3D] = []
var gear: Node3D
var shared_sky: Sky
var shipwalk: CharacterBody3D
var shipwalk_visual: MeshInstance3D
var ship_facing: Vector3 = Vector3(-1, 0, 0)
var shipwalk_path := 0
var ship_track: Array[Vector3] = []
var materials: Dictionary = {}

func target_at(index: int) -> Vector3:
	var location: Vector3 = ROUTE[index]
	if index > 0:
		location = location.rotated(Vector3.UP, [0.0, -0.51, 0.47, 1.1][biome])
		if biome == 2:
			location.x = -location.x
	return location


func _ready():
	if shared_sky == null:
		var sky_mat := ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = Color("#429ace")
		sky_mat.sky_horizon_color = Color("#c4eef7")
		sky_mat.ground_horizon_color = Color("#c4eef7")
		sky_mat.ground_bottom_color = Color("#83c9e4")
		shared_sky = Sky.new()
		shared_sky.sky_material = sky_mat
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = shared_sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#eef4ff")
	environment.ambient_light_energy = 0.42
	var world_env := WorldEnvironment.new()
	world_env.environment = environment
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-57, -30, 0)
	sun.light_color = Color("#fff1d2")
	sun.light_energy = 0.77
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 54
	add_child(sun)
	_solid_round(self, Vector3(0, -0.36, 0), 32.5, 0.72)
	var rng := RandomNumberGenerator.new()
	rng.seed = 347 + 59 * biome
	for i in range(32):
		var angle := TAU * float(i) / 32.0
		var r := rng.randf_range(36, 42)
		var wave := _box(self, Vector3(rng.randf_range(0.45, 2.1), 0.035, 0.11),
			Vector3(cos(angle) * r, -1.77, sin(angle) * r), Color("#a5e1ea"))
		wave.rotation.y = -angle + PI / 2
	for i in range(24):
		var angle := TAU * i / 24.0 + rng.randf_range(-0.13, 0.13)
		var r := rng.randf_range(8.0, 28.5)
		var place := Vector3(cos(angle) * r, 0, sin(angle) * r)
		var factor := rng.randf_range(0.82, 1.18)
		var clear := true
		for j in range(ROUTE.size()):
			if place.distance_to(target_at(j)) < 2.5:
				clear = false
				break
		if clear:
			_scenery(place, factor, i)
	for i in range(56):
		var angle := rng.randf_range(0, TAU)
		var r := rng.randf_range(6.5, 31.0)
		var p := Vector3(cos(angle) * r, 0.09, sin(angle) * r)
		if i % 2 == 0:
			_solid_round(self, p + Vector3(0, 0.1, 0), 0.22, 0.22)
		_boulder(self, Vector3(0.20, 0.11, 0.18), p, Color("#348577"))
		_boulder(self, Vector3(0.14, 0.12, 0.14), p + Vector3(0, 0.15, 0),
			[Color("#ffe193"), Color("#faf0cf"), Color("#efa5a0")][i % 3])
	for i in range(8):
		_disc(self, 0.48, 0.54, 0.09, Vector3(sin(i * 1.7) * 0.28, 0.045, 3 - i * 1.14),
			SHORE[biome], 7)
	for i in range(ROUTE.size() - 1):
		var from := target_at(i)
		var towards := target_at(i + 1)
		for j in range(1, 5):
			var place := from.lerp(towards, j / 5.0)
			_disc(self, 0.22, 0.29, 0.055, place + Vector3(0, 0.013, 0), SHORE[biome], 5)
	_landmarks()
	for i in range(9):
		var cloud := Node3D.new()
		add_child(cloud)
		cloud.position = Vector3(-37 + i * 9, 6 + (i % 3) * 1.4, -39 - (i % 2) * 12)
		for j in range(3):
			_boulder(cloud, Vector3(1.9, 0.8 + 0.25 * j, 1.1),
				Vector3(j * 1.3, sin(j) * 0.44, 0), Color("#f2f9fd"))
	_make_flag()
	_make_avatar()
	_make_ship()
	_make_shipwalk()


func _landmarks():
	match biome:
		0:
			_gate(Vector3(0, 0, -8))
			_tower(Vector3(-14, 0, -5))
			_tower(Vector3(8, 0, -18))
		1:
			for x in [-3.0, 3.0]:
				_disc(self, 0.15, 2.0, 2.9, Vector3(x, 1.45, -10), CREAM, 4).rotation.y = PI / 4
				_solid_box(Vector3(x, 1.45, -10), Vector3(2.40, 2.9, 2.40))
			for i in range(3):
				_box(self, Vector3(4.0 - i, 0.55, 3.3 - i), Vector3(0, 0.28 + i * 0.55, -13), SHORE[biome])
			_solid_box(Vector3(0, 0.85, -13), Vector3(4.0, 1.7, 3.3))
		2:
			for i in range(3):
				var y := i * 0.43
				_box(self, Vector3(5.8 - i, 0.44, 3.9 - i), Vector3(0, y, -9.6), SHORE[biome])
			_solid_box(Vector3(0, 0.55, -9.6), Vector3(5.8, 1.1, 3.9))
			for x in [-2.8, 2.8]:
				_disc(self, 0.28, 0.48, 3.4, Vector3(x, 1.7, -9.2), CREAM, 8)
				_solid_round(self, Vector3(x, 1.7, -9.2), 0.46, 3.4)
			_box(self, Vector3(6, 0.24, 0.42), Vector3(0, 3.25, -9.2), TEAL)
		3:
			for i in range(6):
				var height := 1.1 + float([1, 3, 5, 4, 2, 3][i]) * 0.52
				var place := Vector3((i - 2.5) * 1.1, height / 2, -10.5)
				var dimensions := Vector3(0.82, height, 0.82)
				_box(self, dimensions, place, [CORAL, CREAM, TEAL][i % 3])
				_solid_box(place, dimensions)
			for location in [Vector3(12, -0.92, -45), Vector3(-21, -0.92, -43), Vector3(42, -0.92, -18)]:
				_disc(self, 4.6, 3.8, 1.3, location, SHORE[biome], 12)
				_disc(self, 3.8, 4.0, 0.4, location + Vector3(0, 0.75, 0), TERRAIN[biome], 12)


func _scenery(place: Vector3, factor: float, variant: int):
	match biome:
		0:
			_tree(place, factor)
		1:
			_disc(self, 0.62, 0.79, 0.25, place + Vector3(0, 0.125, 0), ROCK, 4)
			_disc(self, 0.03, 0.72, 2.4 * factor, place + Vector3(0, 0.25 + 1.2 * factor, 0),
				[Color("#6766b9"), Color("#9176c3"), Color("#79b7cf")][variant % 3], variant % 3 + 3)
		2:
			_disc(self, 0.23, 0.34, 1.5 * factor, place + Vector3(0, 0.75 * factor, 0), TEAL, 7)
			for side in [-1, 1]:
				_boulder(self, Vector3(0.32, 0.16, 0.23), place + Vector3(side * 0.23, 0.70 * factor, 0), TEAL)
				_boulder(self, Vector3(0.15, 0.36, 0.15), place + Vector3(side * 0.50, 0.93 * factor, 0), TEAL)
			_boulder(self, Vector3(0.13, 0.11, 0.13), place + Vector3(0, 1.5 * factor, 0), CORAL)
		3:
			_disc(self, 0.42, 0.6, 1.55 * factor, place + Vector3(0, 0.78 * factor, 0), Color("#f3ead0"), 8)
			_disc(self, 0.12, 0.59, 0.65, place + Vector3(0, 1.55 * factor + 0.325, 0), [CORAL, TEAL, NAVY][variant % 3], 8)


func _tree(place: Vector3, factor: float):
	var root := Node3D.new()
	add_child(root)
	root.position = place
	root.scale *= factor
	_disc(root, 0.14, 0.29, 1.7, Vector3(0, 0.85, 0), Color("#967050"), 7)
	_solid_round(root, Vector3(0, 0.85, 0), 0.34, 1.7)
	_boulder(root, Vector3(1.02, 1.0, 0.94), Vector3(0, 2.08, 0), TEAL)
	_boulder(root, Vector3(0.83, 0.84, 0.76), Vector3(0.48, 2.68, 0), GRASS)
	_boulder(root, Vector3(0.62, 0.73, 0.74), Vector3(-0.51, 2.64, 0.07), Color("#80cf8a"))


func _gate(place: Vector3):
	for sign_value in [-1, 1]:
		var post_x: float = place.x + sign_value * 2.1
		_solid_box(Vector3(post_x, 1.6, place.z), Vector3(0.75, 3.2, 0.78))
		var x: float = place.x + sign_value * 2.1
		_box(self, Vector3(0.75, 3.2, 0.78), Vector3(x, 1.6, place.z), CREAM)
		for y in [0.24, 2.6, 3.1]:
			_box(self, Vector3(0.92, 0.22, 0.94), Vector3(x, y, place.z), ROCK)
	_box(self, Vector3(5.15, 0.5, 1.03), place + Vector3(0, 3.35, 0), NAVY)
	for i in range(7):
		var badge := _box(self, Vector3(0.52, 0.48, 0.12),
			place + Vector3((i - 3) * 0.62, 3.1 + 0.08 * abs(i - 3), 0.57),
			[CORAL, SAND, TEAL][i % 3])
		badge.rotation.z = PI / 4


func _tower(place: Vector3):
	_disc(self, 0.84, 1.08, 3.1, place + Vector3(0, 1.55, 0), CREAM, 8)
	_disc(self, 1, 1, 0.21, place + Vector3(0, 2.95, 0), ROCK, 8)
	_disc(self, 0.09, 1.17, 1.65, place + Vector3(0, 3.95, 0), Color("#4775ba"), 8)
	_boulder(self, Vector3(0.16, 0.20, 0.16), place + Vector3(0, 4.86, 0), SAND)
	_solid_round(self, place + Vector3(0, 1.55, 0), 0.96, 3.1)


func _make_flag():
	flag = Node3D.new()
	add_child(flag)
	flag.position = target_at(0)
	_disc(flag, 0.91, 1.01, 0.16, Vector3(0, 0.08, 0), NAVY, 12)
	_disc(flag, 0.79, 0.85, 0.09, Vector3(0, 0.2, 0), SAND, 12)
	_disc(flag, 0.055, 0.065, 2.7, Vector3(0, 1.47, 0), CREAM, 8)
	_boulder(flag, Vector3(0.12, 0.12, 0.12), Vector3(0, 2.87, 0), SAND)
	pennant = Node3D.new()
	flag.add_child(pennant)
	pennant.position.y = 2.64
	_box(pennant, Vector3(1.24, 0.65, 0.07), Vector3(0.64, -0.3, 0), CORAL)
	var diamond := _box(pennant, Vector3(0.28, 0.28, 0.09), Vector3(0.62, -0.3, 0), CREAM)
	diamond.rotation.z = PI / 4
	# Repère visuel simple : une bande flottante, sans Label3D (plus stable en GL Compatibility).
	_box(flag, Vector3(0.06, 0.9, 0.06), Vector3(0, 3.25, 0), CORAL)
	_boulder(flag, Vector3(0.18, 0.18, 0.18), Vector3(0, 3.78, 0), SAND)

func _make_avatar():
	avatar = CharacterBody3D.new()
	add_child(avatar)
	avatar.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	avatar.floor_snap_length = 0.18
	avatar.collision_layer = 2
	avatar.collision_mask = 1
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.80
	capsule.height = 2.12
	_attach_shape(avatar, Vector3(0, 1.06, 0), capsule)
	avatar.position = Vector3(0, 0, 3)
	var jacket := Color("#3565b4")
	var skin := Color("#e8a77d")
	var leather := Color("#513c53")
	for side in [-1, 1]:
		var x: float = side * 0.245
		var leg := Node3D.new()
		avatar.add_child(leg)
		leg.position = Vector3(x, 0.68, 0)
		legs.append(leg)
		_box(leg, Vector3(0.44, 0.51, 0.45), Vector3(0, -0.19, 0), NAVY)
		_box(leg, Vector3(0.44, 0.20, 0.56), Vector3(0, -0.51, -0.06), leather)
		_box(leg, Vector3(0.45, 0.08, 0.57), Vector3(0, -0.62, -0.06), CREAM)
		_box(leg, Vector3(0.24, 0.022, 0.05), Vector3(0, -0.40, -0.19), SAND)
		var arm := Node3D.new()
		avatar.add_child(arm)
		arm.position = Vector3(side * 0.61, 1.39, 0)
		arms.append(arm)
		_box(arm, Vector3(0.34, 0.33, 0.40), Vector3(0, -0.18, 0), jacket)
		_box(arm, Vector3(0.34, 0.32, 0.39), Vector3(0, -0.48, 0), skin)
		_box(arm, Vector3(0.35, 0.075, 0.40), Vector3(0, -0.34, 0), CREAM)
	_box(avatar, Vector3(0.91, 0.75, 0.55), Vector3(0, 1.055, 0), jacket)
	_box(avatar, Vector3(0.93, 0.13, 0.57), Vector3(0, 0.73, 0), leather)
	_box(avatar, Vector3(0.71, 0.61, 0.62), Vector3(0, 1.745, 0), skin)
	_box(avatar, Vector3(0.74, 0.13, 0.65), Vector3(0, 2.02, 0.02), leather)
	_box(avatar, Vector3(0.71, 0.30, 0.13), Vector3(0, 1.85, 0.27), leather)
	var fringe := _box(avatar, Vector3(0.33, 0.11, 0.055), Vector3(-0.17, 1.95, -0.32), leather)
	fringe.rotation.z = 0.16
	for side in [-1, 1]:
		_box(avatar, Vector3(0.10, 0.16, 0.18), Vector3(side * 0.38, 1.72, 0), skin)
		_box(avatar, Vector3(0.028, 0.036, 0.024), Vector3(side * 0.075, 1.659, -0.32), leather)
	_box(avatar, Vector3(0.14, 0.036, 0.024), Vector3(0, 1.64, -0.32), leather)
	gear = Node3D.new()
	avatar.add_child(gear)
	refresh_gear()

func _make_ship():
	var origin := Vector3(38, -0.05, -16)
	var base := _disc(self, 15.0, 18.0, 2.9, origin, Color("#2c3a46"), 32)
	base.rotation.y = -PI / 2
	for i in range(3):
		_box(self, Vector3(0.4, 0.55, 0.95), origin + Vector3(2.5, 0.275 + i * 0.03, -0.475), Color("#2e3a43"))
		_box(self, Vector3(0.4, 0.6, 0.95), origin + Vector3(-2.5, 0.305 + i * 0.03, -0.475), Color("#2e3a43"))
	var deck := _box(self, Vector3(8.4, 0.15, 11.2), origin, Color("#334652"))
	deck.rotation.y = -PI / 2
	_solid_round(deck, origin + Vector3(0, 0.08, 0), 13.5, 0.12)
	var pirogue := Node3D.new()
	add_child(pirogue)
	pirogue.position = origin + Vector3(0, 0.35, -10.6)
	_boulder(pirogue, Vector3(3.1, 0.13, 0.27), Vector3(0, 0.07, 0), Color("#557777"))
	_boulder(pirogue, Vector3(2.1, 0.05, 0.22), Vector3(0, 0.13, 0.04), Color("#6e9090"))
	for side in [-1, 1]:
		_disc(pirogue, 0.14, 0.31, 0.24, Vector3(side * 3.9, 0.22, 0.04), Color("#3c8d64"), 6).rotation.z = PI / 2
	_boulder(pirogue, Vector3(0.17, 0.07, 0.17), Vector3(0, 0.1, 0), Color("#2f5a4e"))


func _update_shipwalk():
	var sprite := shipwalk.get_node_or_null("Sprite")
	if sprite != null:
		sprite.position.y = 2.1 + sin(Time.get_ticks_msec() * 0.0004) * 0.3
		sprite.rotation.y = lerp_angle(sprite.rotation.y, -ship_facing.x * PI / 2, 0.05)


func _make_shipwalk():
	shipwalk = CharacterBody3D.new()
	add_child(shipwalk)
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.46
	capsule.height = 1.4
	_attach_shape(shipwalk, Vector3(0, 0.72, 0), capsule)
	shipwalk.position = Vector3(38, 2.2, -10)
	var form := Node3D.new()
	add_child(form)
	var sprite := MeshInstance3D.new()
	sprite.mesh = QuadMesh.new()
	sprite.mesh.size = Vector2(2.2, 3.6)
	sprite.rotation.x = -PI / 2
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#e6a231")
	mat.render_priority = 4
	sprite.material_override = mat
	form.add_child(sprite)


func refresh_gear():
	for part in gear.get_children():
		gear.remove_child(part)
		part.queue_free()
	var equipment: Dictionary = GameState.state.get("adventure_equipment", {})
	match equipment.get("head", ""):
		"cap":
			_disc(gear, 0.30, 0.40, 0.20, Vector3(0, 2.07, 0), TEAL, 10)
			_box(gear, Vector3(0.56, 0.075, 0.26), Vector3(0, 2.01, -0.34), TEAL)
		"crown":
			_disc(gear, 0.40, 0.36, 0.17, Vector3(0, 2.08, 0), SAND, 10)
			for mark in range(6):
				var angle := TAU * mark / 6
				_disc(gear, 0.025, 0.12, 0.23, Vector3(cos(angle) * 0.32, 2.25, sin(angle) * 0.32), SAND, 5)
	match equipment.get("back", ""):
		"cape":
			var cape := _box(gear, Vector3(0.95, 0.95, 0.075), Vector3(0, 0.96, 0.51), Color("#a53b82"))
			cape.rotation.x = -0.18
			_box(gear, Vector3(0.70, 0.10, 0.085), Vector3(0, 1.35, 0.46), SAND)
		"pack":
			_box(gear, Vector3(0.68, 0.66, 0.35), Vector3(0, 1.03, 0.44), TEAL)
			_box(gear, Vector3(0.58, 0.18, 0.11), Vector3(0, 1.22, 0.65), SAND)
			_box(gear, Vector3(0.32, 0.24, 0.10), Vector3(0, 0.95, 0.65), Color("#77c7a8"))
	match equipment.get("badge", ""):
		"compass", "crystal":
			var color := SAND if equipment["badge"] == "compass" else Color("#8bdfef")
			var badge := _box(gear, Vector3(0.24, 0.24, 0.055), Vector3(0.23, 1.15, -0.295), color)
			badge.rotation.z = PI / 4
			_box(gear, Vector3(0.06, 0.11, 0.03), Vector3(0.23, 1.15, -0.334), NAVY)


func _mesh(parent: Node3D, mesh: Mesh, place: Vector3, color: Color) -> MeshInstance3D:
	if not materials.has(color):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.92
		materials[color] = mat
	var instance := MeshInstance3D.new()
	if DisplayServer.get_name() != "headless":
		instance.mesh = mesh
		instance.material_override = materials[color]
	instance.position = place
	parent.add_child(instance)
	return instance


func _box(parent: Node3D, dimensions: Vector3, place: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	return _mesh(parent, mesh, place, color)


func _disc(parent: Node3D, top: float, bottom: float, height: float, place: Vector3, color: Color, sides: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = sides
	return _mesh(parent, mesh, place, color)


func _boulder(parent: Node3D, dimensions: Vector3, place: Vector3, color: Color):
	var mesh := SphereMesh.new()
	mesh.radial_segments = 7
	mesh.rings = 3
	var item := _mesh(parent, mesh, place, color)
	item.scale = dimensions * 2


func _solid_box(place: Vector3, dimensions: Vector3):
	var body := StaticBody3D.new()
	add_child(body)
	var shape := BoxShape3D.new()
	shape.size = dimensions
	_attach_shape(body, place, shape)


func _solid_round(parent: Node3D, place: Vector3, radius: float, height: float):
	var body := StaticBody3D.new()
	parent.add_child(body)
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	_attach_shape(body, place, shape)


func _attach_shape(body: CollisionObject3D, place: Vector3, shape: Shape3D):
	var collider := CollisionShape3D.new()
	collider.shape = shape
	collider.position = place
	body.add_child(collider)
