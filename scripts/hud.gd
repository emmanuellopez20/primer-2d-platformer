## Componente HUD - Interfaz de usuario en pantalla
##
## Este script maneja toda la interfaz de usuario visible durante el juego:
## - Muestra el nivel actual
## - Muestra el contador de monedas recolectadas
## - Muestra el contador de vidas del jugador
## - Muestra mensajes de victoria y derrota
## - Gestiona la visibilidad y duración de los mensajes
##
## Utiliza CanvasLayer para renderizar sobre el juego

extends CanvasLayer

# Temporizador para duración de mensajes
var message_timer: Timer = null  ## Controla cuánto tiempo se muestran los mensajes de victoria/derrota

func _ready() -> void:
	# Crear y configurar temporizador de mensajes
	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.timeout.connect(_on_message_timer_timeout)
	add_child(message_timer)

## Actualiza la etiqueta del nivel actual
## @param num: Número del nivel a mostrar
func level(num):
	$CurrentLevel.text = "Level: " + str(num)

## Actualiza la etiqueta del contador de monedas
## @param num: Número de monedas a mostrar
func coins(num):
	$CoinsLabel.text = "Coins: " + str(num)

## Actualiza el display del contador de vidas
## @param count: Número de vidas a mostrar
func update_lives(count: int) -> void:
	if has_node("LivesContainer/LivesLabel"):
		$LivesContainer/LivesLabel.text = "Lives: " + str(count)
		print("HUD: Vidas actualizadas a %d" % count)
	else:
		print("HUD: Advertencia - LivesLabel no encontrado")

## Muestra la pantalla de victoria con un mensaje
func show_victory_screen() -> void:
	if has_node("MessageContainer"):
		# Establecer mensaje de victoria
		$MessageContainer/MessageLabel.text = "¡VICTORIA!"
		$MessageContainer/MessageLabel.add_theme_color_override("font_color", Color.GREEN)
		
		# Mostrar el contenedor de mensaje
		$MessageContainer.visible = true
		
		# Asegurar que los contadores de monedas y vidas permanezcan visibles
		$CurrentLevel.visible = true
		$CoinsLabel.visible = true
		if has_node("LivesContainer"):
			$LivesContainer.visible = true
		
		print("HUD: Pantalla de victoria mostrada")
		
		# Iniciar temporizador para duración del mensaje (3 segundos)
		if message_timer:
			message_timer.start(3.0)
	else:
		print("HUD: Advertencia - MessageContainer no encontrado")

## Muestra la pantalla de derrota con un mensaje
func show_defeat_screen() -> void:
	if has_node("MessageContainer"):
		# Establecer mensaje de derrota
		$MessageContainer/MessageLabel.text = "GAME OVER"
		$MessageContainer/MessageLabel.add_theme_color_override("font_color", Color.RED)
		
		# Mostrar el contenedor de mensaje
		$MessageContainer.visible = true
		
		# Asegurar que los contadores de monedas y vidas permanezcan visibles
		$CurrentLevel.visible = true
		$CoinsLabel.visible = true
		if has_node("LivesContainer"):
			$LivesContainer.visible = true
		
		print("HUD: Pantalla de derrota mostrada")
		
		# Iniciar temporizador para duración del mensaje (3 segundos)
		if message_timer:
			message_timer.start(3.0)
	else:
		print("HUD: Advertencia - MessageContainer no encontrado")

## Llamado cuando expira el temporizador de mensaje
## Oculta el mensaje después del tiempo especificado
func _on_message_timer_timeout() -> void:
	if has_node("MessageContainer"):
		$MessageContainer.visible = false
		print("HUD: Mensaje ocultado después del timeout")
