## Autoload Global - Gestor de estado global del juego
##
## Este script es un singleton (autoload) que mantiene el estado del juego
## persistente entre niveles:
## - Contador total de monedas recolectadas
## - Vidas actuales del jugador
## - Nivel actual
## - Posiciones de checkpoints activados por nivel
##
## Se inicializa automáticamente al arrancar el juego y persiste entre escenas

extends Node

# Variables de estado global del juego
var total_coins: int = 0  ## Total de monedas recolectadas en todos los niveles
var player_lives: int = 3  ## Vidas actuales del jugador
var current_level: int = 1  ## Número del nivel actual
var checkpoints_activated: Dictionary = {}  ## Diccionario que mapea level_num -> Vector2 posición

# Variable legacy para compatibilidad hacia atrás
var coins_collected: int = 0  ## Alias de total_coins para compatibilidad

func _ready():
	print("Global autoload inicializado")
	print("Estado inicial - Vidas: %d, Monedas: %d, Nivel: %d" % [player_lives, total_coins, current_level])

## Reinicia todo el estado del juego a valores iniciales
## Se llama al iniciar un nuevo juego o al regresar al menú principal
func reset_game() -> void:
	total_coins = 0
	coins_collected = 0
	player_lives = 3
	current_level = 1
	checkpoints_activated.clear()
	print("Estado del juego reiniciado - Vidas: %d, Monedas: %d, Nivel: %d" % [player_lives, total_coins, current_level])

## Guarda la posición de un checkpoint para un nivel específico
## @param level: El número del nivel
## @param position: La posición del checkpoint en coordenadas del mundo
func save_checkpoint(level: int, position: Vector2) -> void:
	checkpoints_activated[level] = position
	print("Checkpoint guardado para nivel %d en posición %v" % [level, position])

## Recupera la posición guardada del checkpoint para un nivel específico
## @param level: El número del nivel
## @return: La posición del checkpoint, o Vector2.ZERO si no hay checkpoint guardado
func get_checkpoint(level: int) -> Vector2:
	if checkpoints_activated.has(level):
		var checkpoint_pos = checkpoints_activated[level]
		print("Checkpoint recuperado para nivel %d: %v" % [level, checkpoint_pos])
		return checkpoint_pos
	else:
		print("No se encontró checkpoint para nivel %d, retornando Vector2.ZERO" % level)
		return Vector2.ZERO

## Incrementa el contador de monedas en 1
## Se llama cuando se recolecta una moneda
func add_coin() -> void:
	total_coins += 1
	coins_collected = total_coins  # Mantener variable legacy sincronizada
	print("¡Moneda recolectada! Total de monedas: %d" % total_coins)

## Decrementa las vidas del jugador en 1
## @return: true si es game over (vidas <= 0), false en caso contrario
func lose_life() -> bool:
	player_lives -= 1
	print("¡Vida perdida! Vidas restantes: %d" % player_lives)
	
	if player_lives <= 0:
		print("Game Over - no quedan vidas")
		return true
	return false

## Maneja input global para regresar al menú principal
func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		reset_game()  # Reiniciar estado al regresar al menú principal
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
