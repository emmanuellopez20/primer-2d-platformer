## Componente Trophy - Trofeo de victoria final
##
## Este script representa el objeto de victoria final que completa todo el juego:
## - Detecta cuando el jugador lo recolecta
## - Reproduce efectos de sonido y partículas
## - Emite señal para que el nivel maneje la victoria final
## - Se auto-elimina después de ser recolectado
##
## Utiliza Area2D para detección de colisión

extends Area2D

# Señales emitidas por el Trophy
signal trophy_collected  ## Se emite cuando el trofeo es recolectado por el jugador

func _ready():
	print("Trophy inicializado en posición %v" % global_position)

## Llamado cuando un cuerpo entra en el área del trofeo
func _on_body_entered(body):
	# Solo recolectar si es el jugador
	if body.name == "Player":
		print("¡Trofeo recolectado por el jugador!")
		collect()

## Llamado cuando el trofeo es recolectado
## Maneja todos los efectos y la eliminación del trofeo
func collect():
	# Deshabilitar colisión para prevenir recolecciones múltiples
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Reproducir sonido de recolección si está disponible
	if has_node("CollectSfx"):
		$CollectSfx.play()
		print("Sonido de recolección del trofeo reproducido")
	
	# Activar partículas de recolección
	if has_node("CollectParticles"):
		$CollectParticles.emitting = true
		print("Partículas de recolección del trofeo activadas")
	
	# Ocultar el sprite
	if has_node("Sprite2D"):
		$Sprite2D.visible = false
	
	# Emitir señal para que el nivel maneje la victoria
	emit_signal("trophy_collected")
	
	# Esperar un momento para los efectos, luego eliminar
	await get_tree().create_timer(0.5).timeout
	queue_free()
	print("Trophy eliminado de la escena")
