## Componente Level - Gestor principal del nivel
##
## Este script coordina todos los elementos de un nivel:
## - Gestiona el sistema de respawn y checkpoints
## - Conecta señales de todos los componentes (Player, Enemies, Coins, etc.)
## - Maneja condiciones de victoria y derrota
## - Actualiza el HUD con información del juego
## - Sincroniza estado con Global autoload
## - Controla transiciones entre niveles
##
## Cada nivel debe tener este script adjunto al nodo raíz

extends Node2D

# Variables exportadas
@export var level_num = 0  ## Número del nivel actual (usado para identificación y HUD)

# Variables del sistema de respawn
var current_checkpoint: Vector2 = Vector2.ZERO  ## Posición del último checkpoint activado
var player_start_position: Vector2 = Vector2.ZERO  ## Posición inicial del jugador (respawn por defecto)

# Banderas de estado del juego
var game_ended: bool = false  ## Previene múltiples activaciones de victoria/derrota

func _ready():
	# Inicializar HUD con número de nivel
	$HUD.level(level_num)
	set_coins_label()
	
	# Guardar posición inicial del jugador como punto de respawn por defecto
	if has_node("Player"):
		player_start_position = $Player.position
		
		# Verificar si hay un checkpoint guardado para este nivel en el estado Global
		var saved_checkpoint = Global.get_checkpoint(level_num)
		if saved_checkpoint != Vector2.ZERO:
			current_checkpoint = saved_checkpoint
			print("Level %d: Checkpoint restaurado desde estado Global en %v" % [level_num, saved_checkpoint])
		else:
			current_checkpoint = player_start_position
			print("Level %d: Usando posición inicial del jugador como checkpoint en %v" % [level_num, player_start_position])
		
		# Sincronizar vidas del jugador con estado Global
		$Player.lives = Global.player_lives
		print("Level %d: Vidas del jugador sincronizadas con estado Global: %d" % [level_num, $Player.lives])
		
		# Inicializar display de vidas
		if has_node("HUD"):
			$HUD.update_lives($Player.lives)
		
		# Conectar señales del jugador
		$Player.player_died.connect(_on_player_died)
		$Player.player_hurt.connect(_on_player_hurt)
	else:
		push_warning("Level %d: ¡No se encontró nodo Player!" % level_num)
	
	# Conectar señales de checkpoint
	if has_node("Checkpoint"):
		$Checkpoint.checkpoint_activated.connect(_on_checkpoint_activated)
		print("Level %d: Checkpoint conectado" % level_num)
	
	# Conectar señal de trofeo si existe (solo en nivel final)
	if has_node("Trophy"):
		$Trophy.trophy_collected.connect(_on_trophy_collected)
		print("Level %d: Trophy conectado" % level_num)
	
	# Nota: la señal goal_reached ya está conectada en el archivo de escena
	# No conectarla de nuevo aquí para evitar errores de conexión duplicada
	
	# Conectar señales de recolección de monedas
	var total_coins = 0
	for coin in $Coins.get_children():
		coin.coin_collected.connect(_on_coin_collected)
		total_coins += 1
	
	# También verificar nodo Coins2 si existe (algunos niveles tienen múltiples contenedores de monedas)
	if has_node("Coins2"):
		for coin in $Coins2.get_children():
			coin.coin_collected.connect(_on_coin_collected)
			total_coins += 1
	
	# Validar conteo mínimo de monedas
	assert(total_coins >= 10, "Level %d debe tener al menos 10 monedas, se encontraron %d" % [level_num, total_coins])
	print("Level %d: Total de monedas en el nivel: %d" % [level_num, total_coins])

## Llamado cuando se recolecta una moneda
## Usa gestión de estado Global y actualiza el HUD
func _on_coin_collected():
	# Usar gestión de estado Global
	Global.add_coin()
	set_coins_label()

## Actualiza la etiqueta de monedas en el HUD
## Muestra el total de monedas desde el estado Global
func set_coins_label():
	# Mostrar total de monedas desde estado Global
	$HUD.coins(Global.total_coins)

## Called when a checkpoint is activated
## Saves the checkpoint position as the new respawn point
func _on_checkpoint_activated(checkpoint_position: Vector2) -> void:
	current_checkpoint = checkpoint_position
	# Save checkpoint to Global state for persistence across levels
	Global.save_checkpoint(level_num, checkpoint_position)
	print("Level %d: Checkpoint activated at %v" % [level_num, checkpoint_position])

## Called when the player dies
## Checks if player has lives remaining, respawns or triggers defeat
func _on_player_died() -> void:
	if game_ended:
		return
	
	# Check if player has lives remaining
	if has_node("Player") and $Player.lives <= 0:
		print("Level %d: Player died with no lives remaining - GAME OVER" % level_num)
		_show_defeat()
	else:
		print("Level %d: Player died, respawning at %v" % [level_num, current_checkpoint])
		# Use call_deferred to respawn after the current frame completes
		_respawn_player.call_deferred()

## Called when the player takes damage
## Updates the HUD with remaining lives
func _on_player_hurt(lives_remaining: int) -> void:
	print("Level %d: Player hurt, %d lives remaining (Global: %d)" % [level_num, lives_remaining, Global.player_lives])
	# Ensure Global state is synchronized
	if has_node("Player"):
		Global.player_lives = $Player.lives
	if has_node("HUD"):
		$HUD.update_lives(lives_remaining)

## Respawns the player at the current checkpoint position
func _respawn_player() -> void:
	if has_node("Player"):
		# Reset game_ended flag to allow respawn
		game_ended = false
		
		# Reset player position and state
		$Player.reset_position(current_checkpoint)
		print("Level %d: Player respawned at %v" % [level_num, current_checkpoint])
	else:
		push_error("Level %d: Cannot respawn - Player node not found!" % level_num)

## Called when the player reaches the goal
## Verifies victory conditions and shows victory screen or transitions to next level
func _on_goal_reached(next_level_path: String) -> void:
	if game_ended:
		return
	
	# Verify that the goal can be completed (checks coin requirements)
	if has_node("Goal") and $Goal.can_complete():
		print("Level %d: Goal reached and conditions met!" % level_num)
		_show_victory()
		
		# Disable player movement during transition
		if has_node("Player"):
			$Player.set_physics_process(false)
		
		# Transition to next level immediately (no delay)
		if next_level_path != "":
			get_tree().change_scene_to_file(next_level_path)
		else:
			print("Level %d: No next level specified, staying in current level" % level_num)
	else:
		print("Level %d: Goal reached but conditions not met (need more coins?)" % level_num)

## Called when the trophy is collected (final victory)
## Shows victory message and returns to main menu
func _on_trophy_collected() -> void:
	if game_ended:
		return
	
	game_ended = true
	print("Level %d: TROPHY COLLECTED! Final Victory!" % level_num)
	
	# Disable player movement
	if has_node("Player"):
		$Player.set_physics_process(false)
	
	# Show victory message on HUD
	if has_node("HUD"):
		$HUD.show_victory_screen()
	
	# Wait 3 seconds then return to main menu and reset game state
	await get_tree().create_timer(3.0).timeout
	print("Level %d: Returning to main menu after final victory" % level_num)
	Global.reset_game()  # Reset coins, lives, checkpoints for next playthrough
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

## Shows the victory screen and disables player input
func _show_victory() -> void:
	if game_ended:
		return
	
	game_ended = true
	print("Level %d: VICTORY! Transitioning to next level" % level_num)
	
	# Show victory message on HUD
	if has_node("HUD"):
		$HUD.show_victory_screen()

## Shows the defeat screen and disables player input
func _show_defeat() -> void:
	if game_ended:
		return
	
	game_ended = true
	print("Level %d: DEFEAT! Game Over" % level_num)
	
	# Disable player input
	if has_node("Player"):
		$Player.set_physics_process(false)
	
	# Show defeat message on HUD
	if has_node("HUD"):
		$HUD.show_defeat_screen()
	
	# Wait 3 seconds then return to main menu and reset game state
	await get_tree().create_timer(3.0).timeout
	print("Level %d: Returning to main menu after Game Over" % level_num)
	Global.reset_game()  # Reset coins, lives, checkpoints
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

## Maneja input del jugador para reiniciar el nivel
func _input(event):
	if event.is_action_pressed("reset_level"):
		# Reiniciar estado Global al reiniciar el nivel
		Global.reset_game()
		get_tree().reload_current_scene.call_deferred()
