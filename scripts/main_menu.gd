## Componente MainMenu - Menú principal del juego
##
## Este script maneja la lógica del menú principal:
## - Botón de inicio que comienza un nuevo juego
## - Botón de pantalla completa (solo en PC)
## - Botón de salir (solo en PC)
## - Reinicia el estado global al iniciar un nuevo juego
##
## Se muestra al iniciar el juego y al regresar desde los niveles

extends Node2D

## Llamado cuando el nodo entra en el árbol de escena por primera vez
func _ready():
	print("MainMenu listo!")
	# Dar foco al botón de inicio para navegación con teclado
	$Options/StartButton.grab_focus()
	
	# Ocultar botones de PC en plataformas móviles/web
	if !OS.has_feature("pc"):
		$Options/FullscreenButton.hide()
		$Options/QuitButton.hide()

## Llamado cuando se presiona el botón de inicio
## Reinicia el estado global e inicia el primer nivel
func _on_start_button_pressed():
	# Reiniciar estado Global al iniciar un nuevo juego
	Global.reset_game()
	get_tree().change_scene_to_file("res://levels/level_1.tscn")

## Llamado cuando se presiona el botón de pantalla completa
## Alterna entre modo ventana y pantalla completa
func _on_fullscreen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

## Llamado cuando se presiona el botón de salir
## Cierra la aplicación
func _on_quit_button_pressed():
	get_tree().quit()
