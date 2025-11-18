## Componente Checkpoint - Punto de reaparición del jugador
##
## Este script maneja la lógica de los checkpoints en el nivel:
## - Detecta cuando el jugador entra en el área
## - Se activa solo una vez
## - Cambia su apariencia visual al activarse
## - Emite señal con su posición para que el nivel la guarde
## - Reproduce sonido de activación
##
## Utiliza Area2D para detección de colisión

extends Area2D

# Estado del checkpoint
var is_activated: bool = false  ## Indica si el checkpoint ya fue activado

# Señales emitidas por el Checkpoint
signal checkpoint_activated(checkpoint_position: Vector2)  ## Se emite al activarse, incluye la posición

func _ready():
	# Conectar señal de entrada de cuerpo
	body_entered.connect(_on_body_entered)
	print("Checkpoint inicializado en posición: %v" % position)

## Detecta cuando el jugador entra en el área del checkpoint
func _on_body_entered(body: Node2D) -> void:
	# Solo activar si es el jugador y no está ya activado
	if body.name == "Player" and not is_activated:
		activate()

## Activa el checkpoint y cambia su estado visual
func activate() -> void:
	is_activated = true
	print("Checkpoint activado en posición: %v" % global_position)
	
	# Cambiar apariencia visual para mostrar activación
	if has_node("Sprite2D"):
		# Cambiar color para indicar activación (tinte verde)
		$Sprite2D.modulate = Color(0.5, 1.0, 0.5, 1.0)
	
	# Reproducir sonido de activación si está disponible
	if has_node("ActivationSfx"):
		$ActivationSfx.play()
	
	# Emitir señal con la posición del checkpoint
	emit_signal("checkpoint_activated", global_position)
