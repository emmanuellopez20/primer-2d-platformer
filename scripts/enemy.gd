## Componente Enemy - Enemigo que patrulla y daña al jugador
##
## Este script maneja la lógica de los enemigos del juego:
## - Patrulla horizontal dentro de una distancia definida
## - Detecta bordes de plataformas para no caer
## - Daña al jugador en colisión lateral
## - Puede ser derrotado saltando sobre él desde arriba
## - Emite partículas y sonido al ser derrotado
##
## El Enemy utiliza CharacterBody2D con gravedad y move_and_slide()

extends CharacterBody2D

# Constantes de movimiento
const PATROL_SPEED = 100.0  ## Velocidad de patrulla horizontal en píxeles/segundo
const GRAVITY = 980.0  ## Gravedad aplicada cuando no está en el suelo

# Variables exportadas para diseño de niveles
@export var patrol_distance: float = 200.0  ## Distancia de patrulla desde la posición inicial
@export var start_direction: int = 1  ## Dirección inicial: 1 = derecha, -1 = izquierda

# Estado interno
var start_position: Vector2  ## Posición inicial del enemigo (guardada en _ready)
var current_direction: int  ## Dirección actual de movimiento

# Señales emitidas por el Enemy
signal enemy_defeated  ## Se emite cuando el enemigo es derrotado (saltado desde arriba)

func _ready():
	# Validar e inicializar parámetros
	if patrol_distance <= 0:
		push_warning("Enemy patrol_distance debe ser > 0, estableciendo valor por defecto 200.0")
		patrol_distance = 200.0
	
	if start_direction != 1 and start_direction != -1:
		push_warning("Enemy start_direction debe ser 1 o -1, estableciendo valor por defecto 1")
		start_direction = 1
	
	# Guardar posición y dirección inicial
	start_position = position
	current_direction = start_direction
	
	# Configurar RayCast2D detector de bordes
	if has_node("EdgeDetector"):
		var edge_detector = $EdgeDetector as RayCast2D
		# Posicionar el raycast ligeramente adelante en la dirección de movimiento
		edge_detector.position.x = current_direction * 6.0
		edge_detector.enabled = true
	
	print("Enemy inicializado en posición %v con patrol_distance=%f, start_direction=%d" % [start_position, patrol_distance, start_direction])

func _physics_process(delta):
	# Aplicar gravedad cuando no está en el suelo
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		# Solo patrullar cuando está en el suelo
		_patrol()
	
	move_and_slide()

## Maneja la lógica de movimiento de patrulla
func _patrol():
	# Establecer velocidad horizontal basada en la dirección actual
	velocity.x = current_direction * PATROL_SPEED
	
	# Verificar detección de bordes usando RayCast2D
	var edge_detector = $EdgeDetector as RayCast2D
	if edge_detector and not edge_detector.is_colliding():
		# No hay suelo adelante, invertir dirección
		current_direction *= -1
		edge_detector.position.x = current_direction * 6.0
		print("Enemy detectó borde, invirtiendo dirección a %d" % current_direction)
		return
	
	# Verificar si alcanzó los límites de distancia de patrulla
	var distance_from_start = position.x - start_position.x
	
	# Usar un margen de tolerancia para evitar oscilaciones
	# Solo invertir si está REALMENTE fuera del límite Y moviéndose en la dirección incorrecta
	if abs(distance_from_start) > patrol_distance + 5.0:
		# Está fuera del límite, verificar si se está moviendo en la dirección incorrecta
		if (distance_from_start > 0 and current_direction > 0) or (distance_from_start < 0 and current_direction < 0):
			# Se está alejando más del centro, invertir dirección
			current_direction *= -1
			# Actualizar posición del detector de bordes para la nueva dirección
			if edge_detector:
				edge_detector.position.x = current_direction * 6.0
			print("Enemy alcanzó límite de patrulla en distancia %f, invirtiendo dirección a %d" % [distance_from_start, current_direction])

## Llamado cuando un cuerpo entra en el área de daño
func _on_damage_area_body_entered(body):
	# Verificar si el cuerpo es el jugador
	if body.name != "Player":
		print("Enemy: Cuerpo entró pero no es el jugador: %s" % body.name)
		return
	
	print("Enemy: Colisión con jugador detectada en pos enemigo %v, pos jugador %v" % [global_position, body.global_position])
	
	# Calcular distancia vertical entre jugador y enemigo
	var vertical_distance = global_position.y - body.global_position.y
	
	# Si el jugador está significativamente arriba del enemigo (al menos 2 píxeles), es un pisotón
	# Esto funciona incluso si velocity.y es 0 porque el jugador acaba de aterrizar
	var is_stomp = vertical_distance > 2.0
	
	print("Enemy: vertical_distance=%f, is_stomp=%s, player_velocity_y=%f" % [vertical_distance, is_stomp, body.velocity.y])
	
	if is_stomp:
		# Jugador saltó sobre el enemigo desde arriba - derrotar al enemigo
		print("Enemy: Golpeado desde arriba por el jugador, derrotando enemigo")
		
		# Dar al jugador un pequeño rebote
		body.velocity.y = -200.0  # Rebote pequeño
		
		defeat()
	else:
		# Colisión lateral - dañar al jugador
		print("Enemy: Colisión lateral con jugador, aplicando daño")
		
		if body.has_method("take_damage"):
			body.take_damage()
		else:
			print("Enemy: ¡El jugador no tiene el método take_damage!")

## Llamado cuando el enemigo es derrotado (saltado desde arriba)
func defeat():
	print("Enemy derrotado en posición %v" % position)
	
	# Deshabilitar colisión para prevenir interacciones adicionales
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	if has_node("DamageArea/CollisionShape2D"):
		$DamageArea/CollisionShape2D.set_deferred("disabled", true)
	
	# Ocultar el sprite
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.visible = false
	
	# Reproducir sonido de derrota si está disponible
	if has_node("DefeatSfx"):
		$DefeatSfx.play()
		print("Sonido de derrota del enemigo reproducido")
	
	# Activar partículas de derrota
	if has_node("DefeatParticles"):
		$DefeatParticles.emitting = true
		print("Partículas de derrota del enemigo activadas")
	
	# Emitir señal para seguimiento del nivel
	emit_signal("enemy_defeated")
	
	# Esperar a que terminen las partículas antes de eliminar
	await get_tree().create_timer(0.7).timeout
	queue_free()
	print("Enemy eliminado de la escena")
