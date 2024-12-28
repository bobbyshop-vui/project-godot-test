extends Spatial

export(float) var rotation_speed: float = 0.1
export(float) var move_speed: float = 5.0
export(int) var cloud_count: int = 99
export(float) var cloud_size: float = 5.0

var last_mouse_position: Vector2
var time_held = 0.0 # Thời gian giữ chuột trái
var raycast: RayCast = null # Tham chiếu đến RayCast

func _ready():
	last_mouse_position = get_viewport().get_mouse_position()

	# Tạo ánh sáng
	var light = DirectionalLight.new()
	light.rotation_degrees = Vector3(-45, 0, 0)
	light.light_color = Color(1.0, 1.0, 0.8)
	light.light_energy = 1.5
	add_child(light)

	# Tạo bầu trời
	var sky_mesh = SphereMesh.new()
	sky_mesh.radius = 1000
	var sky_material = SpatialMaterial.new()
	sky_material.albedo_color = Color(0.5, 0.7, 1.0)
	sky_material.roughness = 0.5

	var sky_instance = MeshInstance.new()
	sky_instance.mesh = sky_mesh
	sky_instance.material_override = sky_material
	add_child(sky_instance)

	# Tạo mặt đất
	var plane = PlaneMesh.new()
	var plane_instance = MeshInstance.new()
	plane_instance.mesh = plane
	plane_instance.transform.origin = Vector3(0, -1, 0)
	plane_instance.rotation_degrees = Vector3(-90, 0, 0)

	var ground_material = SpatialMaterial.new()
	ground_material.albedo_color = Color(0.0, 0.5, 0.0)
	ground_material.roughness = 1.0
	plane_instance.material_override = ground_material
	add_child(plane_instance)

	# Tạo các đám mây với vị trí ngẫu nhiên
	for index in range(cloud_count): # Sử dụng 'index'
		var cloud = create_cloud()
		cloud.transform.origin = Vector3(rand_range(-1000, 1000), rand_range(100, 300), rand_range(-1000, 1000))
		add_child(cloud)

	# Tạo camera
	var camera = Camera.new()
	camera.transform.origin = Vector3(0, 5, 10)
	camera.look_at(Vector3(0, 0, 0), Vector3.UP) # Đảm bảo điểm đích không giống vị trí camera
	add_child(camera)

	# Thêm RayCast để phát hiện vị trí chạm
	raycast = RayCast.new()
	raycast.cast_to = Vector3(0, 0, -100) # Hướng của raycast
	raycast.enabled = true
	camera.add_child(raycast) # Gắn vào camera để raycast hướng theo góc camera

func create_cloud() -> MeshInstance:
	var cloud_instance = MeshInstance.new()
	var cloud_mesh = SphereMesh.new()
	cloud_mesh.radius = cloud_size

	var cloud_material = SpatialMaterial.new()
	cloud_material.albedo_color = Color(1, 1, 1, 0.5)
	cloud_material.roughness = 0.9
	cloud_material.flags_transparent = true

	cloud_instance.mesh = cloud_mesh
	cloud_instance.material_override = cloud_material
	cloud_instance.scale = Vector3(rand_range(0.5, 2.0), rand_range(0.5, 2.0), rand_range(0.5, 2.0))

	return cloud_instance

func _process(delta: float) -> void:
	var current_mouse_position = get_viewport().get_mouse_position()
	var mouse_delta = current_mouse_position - last_mouse_position

	rotation_degrees.x -= mouse_delta.y * rotation_speed
	rotation_degrees.y -= mouse_delta.x * rotation_speed
	rotation_degrees.x = clamp(rotation_degrees.x, -90, 90)
	last_mouse_position = current_mouse_position

	var direction = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var forward = -transform.basis.z.normalized()
		var right = transform.basis.x.normalized()
		var movement = (forward * direction.z + right * direction.x) * move_speed * delta
		translate(movement)

	# Loại bỏ phần kiểm tra nhấn chuột trái và tạo block
	# Nếu bạn không muốn tạo block, chỉ cần xóa các đoạn mã liên quan đến tạo block.
