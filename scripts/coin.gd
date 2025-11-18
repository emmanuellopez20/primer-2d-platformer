## Componente Coin - Moneda coleccionable
##
## Este script maneja la lógica de las monedas que el jugador puede recolectar:
## - Detecta colisión con el jugador
## - Incrementa el contador global de monedas
## - Reproduce efectos de sonido y partículas
## - Se auto-elimina después de ser recolectada
##
## Utiliza Area2D para detección de colisión sin física

extends Area2D

# Señales emitidas por la Coin
signal coin_collected  ## Se emite cuando la moneda es recolectada por el jugador

## Llamado cuando un cuerpo entra en el área de la moneda
func _on_body_entered(body):
	# Solo recolectar si es el jugador
	if body.name == "Player":
		collect()

## Maneja la recolección de la moneda
## Incrementa contador, emite señal, reproduce efectos y se oculta
func collect():
	# Incrementar contador global de monedas
	Global.coins_collected += 1
	
	# Emitir señal para que el nivel actualice el HUD
	coin_collected.emit()
	
	# Reproducir sonido de recolección
	$CollectedSfx.play()
	
	# Activar partículas de recolección
	$CollectionParticles.emitting = true
	
	# Ocultar la moneda visualmente
	hide()

## Llamado cuando termina el sonido de recolección
## Elimina la moneda de la escena
func _on_collected_sfx_finished():
	queue_free()
