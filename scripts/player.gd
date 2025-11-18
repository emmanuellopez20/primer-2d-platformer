## Componente Player - Personaje controlado por el jugador
##
## Este script maneja toda la lógica del personaje jugador incluyendo:
## - Movimiento horizontal y salto
## - Sistema de vidas y daño
## - Detección de caída fuera de límites
## - Animaciones y efectos visuales
## - Comunicación con el nivel mediante señales
##
## El Player utiliza CharacterBody2D para física de plataformas con move_and_slide()

extends CharacterBody2D

# Constantes de movimiento
const SPEED = 250.0  ## Velocidad de movimiento horizontal en píxeles/segundo
const JUMP_VELOCITY = -400.0  ## Velocidad inicial del salto (negativa = hacia arriba)
const MAX_LIVES = 3  ## Número máximo de vidas al iniciar

# Física
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")  ## Gravedad del proyecto

# Sistema de vidas
var lives: int = MAX_LIVES  ## Vidas actuales del jugador
var is_invulnerable: bool = false  ## Estado de invulnerabilidad temporal tras recibir daño
var is_dead: bool = false  ## Previene múltiples activaciones de muerte
var level_bottom_boundary: float = 1000.0  ## Límite inferior del nivel (debe ser configurado por el nivel)

# Detección de aterrizaje para partículas
var was_on_floor: bool = false  ## Estado del suelo en el frame anterior

# Señales emitidas por el Player
signal player_died  ## Se emite cuando el jugador muere (por daño o caída)
signal player_hurt(lives_remaining: int)  ## Se emite cuando el jugador recibe daño (incluye vidas restantes)

func _ready():
	# Validar estado inicial
	assert(lives == MAX_LIVES, "El jugador debe iniciar con MAX_LIVES")
	print("Player inicializado con %d vidas" % lives)

func _physics_process(delta):
	# Verificar si el jugador cayó fuera de los límites del nivel
	if position.y > level_bottom_boundary and not is_dead:
		print("Player cayó fuera de límites en y=%f (límite=%f)" % [position.y, level_bottom_boundary])
		# Aplicar daño por caída PRIMERO (esto maneja la reducción de vidas y establece is_dead si es necesario)
		take_damage()
		# Detener procesamiento de física para prevenir llamadas adicionales
		set_physics_process(false)
		return
	
	# No procesar si está muerto
	if is_dead:
		return
	
	# Aplicar gravedad cuando está en el aire
	if not is_on_floor():
		velocity.y += gravity * delta

	# Manejar input de salto (solo cuando está en el suelo)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSfx.play()

	# Manejar movimiento horizontal
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("run")
		# Voltear sprite según dirección
		if direction == -1:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		# Sin input: reproducir animación idle y desacelerar
		$AnimatedSprite2D.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED / 2)

	# Sobrescribir animación con jump si está en el aire
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")

	# Aplicar movimiento con detección de colisiones
	move_and_slide()
	
	# Detectar aterrizaje (transición de aire a suelo)
	if is_on_floor() and not was_on_floor:
		_emit_landing_particles()
	
	# Actualizar estado del suelo para el siguiente frame
	was_on_floor = is_on_floor()

## Aplica daño al jugador y reduce las vidas en 1
## Activa período de invulnerabilidad para prevenir múltiples golpes
func take_damage() -> void:
	# Solo verificar invulnerabilidad para daño regular (no para caídas)
	if is_invulnerable:
		print("Player es invulnerable, ignorando daño")
		return
	
	lives -= 1
	# Sincronizar con estado Global
	var game_over = Global.lose_life()
	print("Player recibió daño! Vidas restantes: %d (Global: %d)" % [lives, Global.player_lives])
	
	# Emitir señal para actualización del HUD
	emit_signal("player_hurt", lives)
	
	# Reproducir sonido de daño si está disponible
	if has_node("HurtSfx"):
		$HurtSfx.play()
	
	# Siempre emitir señal player_died - dejar que el nivel decida qué hacer
	print("Player emitiendo señal player_died (vidas: %d)" % lives)
	emit_signal("player_died")
	
	# Si no quedan vidas, marcar como permanentemente muerto
	if lives <= 0 or game_over:
		is_dead = true
		print("Player no tiene vidas restantes - muerte permanente")
		return
	
	# Si quedan vidas, activar invulnerabilidad para respawn
	is_invulnerable = true
	_start_invulnerability_timer()

## Inicia el temporizador de invulnerabilidad
func _start_invulnerability_timer() -> void:
	if has_node("InvulnerabilityTimer"):
		$InvulnerabilityTimer.start()
		print("Invulnerabilidad activada por %f segundos" % $InvulnerabilityTimer.wait_time)

## Llamado cuando expira el temporizador de invulnerabilidad
func _on_invulnerability_timer_timeout() -> void:
	is_invulnerable = false
	print("Invulnerabilidad terminada")

## Reinicia la posición del jugador (llamado por el nivel al reaparecer)
## @param new_position: Nueva posición donde reaparecerá el jugador
func reset_position(new_position: Vector2) -> void:
	print("reset_position llamado - Antes: is_dead=%s, physics_process=%s" % [is_dead, is_physics_processing()])
	position = new_position
	velocity = Vector2.ZERO
	is_dead = false
	was_on_floor = false  # Reiniciar detección de aterrizaje
	is_invulnerable = false  # Reiniciar estado de invulnerabilidad
	set_physics_process(true)  # Re-habilitar procesamiento de física
	print("reset_position completado - Después: is_dead=%s, physics_process=%s, position=%v" % [is_dead, is_physics_processing(), new_position])

## Emite partículas de aterrizaje cuando el jugador toca el suelo
func _emit_landing_particles() -> void:
	if has_node("LandingParticles"):
		$LandingParticles.emitting = true
		print("Partículas de aterrizaje emitidas en posición: %v" % position)
