## Componente Goal - Meta del nivel
##
## Este script representa la condición de victoria para un nivel:
## - Detecta cuando el jugador alcanza la meta
## - Puede requerir un número específico de monedas para completar
## - Emite señal con la ruta del siguiente nivel
## - Valida que se cumplan las condiciones antes de permitir completar
##
## Utiliza Area2D para detección de colisión

extends Area2D

# Variables exportadas para configuración del nivel
@export var next_level: String = ""  ## Ruta a la escena del siguiente nivel a cargar
@export var required_coins: int = 0  ## Número de monedas requeridas para completar (0 = sin requisito)

# Señales emitidas por el Goal
signal goal_reached(next_level_path: String)  ## Se emite cuando el jugador alcanza la meta y puede completar el nivel

func _ready():
	# Validar variables exportadas
	if required_coins < 0:
		push_warning("Goal: required_coins no puede ser negativo, estableciendo a 0")
		required_coins = 0

## Llamado cuando un cuerpo entra en el área de la meta
func _on_body_entered(body):
	# Solo procesar si es el jugador
	if body.name == "Player":
		# Verificar si se cumplen las condiciones de victoria
		if can_complete():
			goal_reached.emit(next_level)

## Verifica si se cumplen las condiciones de victoria
## Retorna true si el jugador ha recolectado suficientes monedas (o no se requieren monedas)
func can_complete() -> bool:
	# Si no se requieren monedas, siempre se puede completar
	if required_coins == 0:
		return true
	# Verificar si se alcanzó el número requerido de monedas
	return Global.coins_collected >= required_coins
