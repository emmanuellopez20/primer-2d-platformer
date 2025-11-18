# Platformer 2D en Godot 4

![Godot 2D Platformer](https://user-images.githubusercontent.com/928367/235163759-a4006cf2-a6b9-48d0-86c8-0efcaab9b9b1.gif)

Un juego de plataformas 2D completo desarrollado en Godot 4 con tres niveles, sistema de vidas, enemigos, checkpoints, música, efectos de sonido y menú principal. Este proyecto está diseñado como base para crear tu propio juego de plataformas.

## Descripción del Proyecto

Este es un juego de plataformas 2D clásico donde controlas a un personaje que debe navegar por niveles llenos de obstáculos, enemigos y monedas coleccionables. El objetivo es llegar a la meta de cada nivel mientras recolectas monedas y evitas perder todas tus vidas.

### Características Principales

- **3 Niveles Completos** con diseño progresivo de dificultad
- **Sistema de Vidas** con 3 vidas iniciales
- **Enemigos Patrulladores** que pueden ser derrotados saltando sobre ellos
- **Sistema de Checkpoints** para reaparecer sin perder progreso
- **Monedas Coleccionables** (mínimo 10 por nivel)
- **Efectos de Partículas** para aterrizajes, recolección y derrotas
- **Música de Fondo** y efectos de sonido
- **HUD Informativo** con contador de monedas, vidas y nivel
- **Menú Principal** con opciones de inicio y pantalla completa
- **Arquitectura Modular** con componentes reutilizables

## Controles del Juego

### Teclado

- **Flechas Izquierda/Derecha** o **A / D**: Mover izquierda/derecha
- **Espacio** o **W**: Saltar
- **R**: Reiniciar nivel (durante el juego)
- **Esc**: Regresar al menú principal (durante el juego)

### Gamepad

- **D-Pad / Stick Izquierdo**: Mover
- **Botón A / Cruz**: Saltar

## Instrucciones de Ejecución

### Requisitos Previos

- **Godot 4.x** o superior
- Sistema operativo: Windows, macOS, Linux, o navegador web

### Ejecutar el Proyecto

1. **Descargar Godot 4**
   - Visita [godotengine.org](https://godotengine.org/download)
   - Descarga la versión estable más reciente de Godot 4

2. **Abrir el Proyecto**
   - Abre Godot Engine
   - Haz clic en "Importar"
   - Navega a la carpeta del proyecto
   - Selecciona el archivo `project.godot`
   - Haz clic en "Importar y Editar"

3. **Ejecutar el Juego**
   - Presiona **F5** o haz clic en el botón "Ejecutar Proyecto"
   - El juego iniciará en el menú principal

### Ejecutar Niveles Individuales

Para probar un nivel específico:
- Abre la escena del nivel (ej: `levels/level_1.tscn`)
- Presiona **F6** o haz clic en "Ejecutar Escena Actual"

## Estructura del Proyecto

```
res://
├── scripts/              # Scripts GDScript de todos los componentes
│   ├── player.gd        # Lógica del jugador (movimiento, vidas, daño)
│   ├── enemy.gd         # Lógica de enemigos (patrulla, colisiones)
│   ├── coin.gd          # Lógica de monedas coleccionables
│   ├── checkpoint.gd    # Sistema de puntos de reaparición
│   ├── goal.gd          # Meta del nivel
│   ├── trophy.gd        # Trofeo de victoria final
│   ├── level.gd         # Gestor principal del nivel
│   ├── hud.gd           # Interfaz de usuario
│   ├── global.gd        # Estado global del juego (autoload)
│   └── main_menu.gd     # Menú principal
│
├── scenes/              # Escenas reutilizables de componentes
│   ├── player.tscn      # Escena del jugador
│   ├── enemy.tscn       # Escena del enemigo
│   ├── coin.tscn        # Escena de la moneda
│   ├── checkpoint.tscn  # Escena del checkpoint
│   ├── goal.tscn        # Escena de la meta
│   ├── trophy.tscn      # Escena del trofeo
│   ├── hud.tscn         # Escena del HUD
│   └── main_menu.tscn   # Escena del menú principal
│
├── levels/              # Niveles del juego
│   ├── level_1.tscn     # Nivel 1 (Tutorial)
│   ├── level_2.tscn     # Nivel 2 (Intermedio)
│   └── level_3.tscn     # Nivel 3 (Avanzado)
│
├── assets/              # Recursos del juego
│   ├── audio/
│   │   ├── music/       # Música de fondo
│   │   └── sfx/         # Efectos de sonido
│   └── sprites/         # Imágenes y tilesets
│
├── project.godot        # Configuración del proyecto
├── export_presets.cfg   # Configuración de exportación
└── README.md            # Este archivo
```

## Mecánicas del Juego

### Sistema de Vidas

- El jugador comienza con **3 vidas**
- Pierde una vida al:
  - Colisionar lateralmente con un enemigo
  - Caer fuera de los límites del nivel
- Al perder todas las vidas: **Game Over** (regresa al menú principal)
- Las vidas persisten entre niveles

### Sistema de Checkpoints

- Activa un checkpoint al pasar por él (cambia a color verde)
- Al morir, reapareces en el último checkpoint activado
- Si no hay checkpoint activado, reapareces al inicio del nivel
- Los checkpoints se guardan por nivel

### Enemigos

- Patrullan horizontalmente en un área definida
- Detectan bordes de plataformas y no caen
- **Colisión lateral**: Daña al jugador (pierde 1 vida)
- **Saltar sobre ellos**: Derrota al enemigo y da un pequeño rebote

### Monedas

- Cada nivel tiene mínimo **10 monedas**
- Se recolectan al tocarlas
- El contador es acumulativo entre niveles
- Reproducen sonido y partículas al recolectarse

### Condiciones de Victoria

- Alcanzar la **meta** (bandera) del nivel
- Algunos niveles pueden requerir un número mínimo de monedas
- El nivel 3 tiene un **trofeo** que completa el juego

## Exportación del Juego

### Exportar para HTML5 (Web)

1. Ve a **Proyecto > Exportar**
2. Haz clic en "Agregar..." y selecciona "HTML5"
3. Configura las opciones:
   - Nombre del archivo: `index.html`
   - Resolución: 1280x720 (o tu preferencia)
4. Haz clic en "Exportar Proyecto"
5. Sube los archivos generados a itch.io, GitHub Pages, o tu servidor web

### Exportar para Desktop (Windows/Linux/Mac)

1. Ve a **Proyecto > Exportar**
2. Haz clic en "Agregar..." y selecciona tu plataforma:
   - Windows Desktop
   - Linux/X11
   - macOS
3. Configura las opciones:
   - Nombre del ejecutable
   - Icono de la aplicación (opcional)
4. Haz clic en "Exportar Proyecto"
5. Distribuye el ejecutable generado

### Notas de Exportación

- Asegúrate de que todos los assets estén en las carpetas correctas
- Prueba la exportación antes de distribuir
- Para HTML5, algunos navegadores requieren HTTPS para audio
- Para desktop, incluye las DLLs necesarias (Godot las incluye automáticamente)

## Arquitectura del Código

### Patrón de Señales

El proyecto usa el sistema de señales de Godot para comunicación desacoplada:

```gdscript
# Player emite señales
signal player_died
signal player_hurt(lives_remaining: int)

# Level escucha las señales
$Player.player_died.connect(_on_player_died)
$Player.player_hurt.connect(_on_player_hurt)
```

### Estado Global (Autoload)

El script `global.gd` mantiene estado persistente entre niveles:
- Total de monedas recolectadas
- Vidas actuales del jugador
- Checkpoints activados por nivel

### Componentes Modulares

Cada elemento del juego es una escena reutilizable:
- `player.tscn`: Puede instanciarse en cualquier nivel
- `enemy.tscn`: Configurable con variables exportadas
- `coin.tscn`: Funciona independientemente

## Solución de Problemas

### El jugador no se mueve

- Verifica que las acciones de input estén configuradas en **Proyecto > Configuración del Proyecto > Mapa de Entrada**
- Acciones necesarias: `move_left`, `move_right`, `jump`

### Los enemigos caen de las plataformas

- Asegúrate de que el nodo `EdgeDetector` (RayCast2D) esté configurado
- Verifica que apunte hacia abajo y tenga longitud suficiente

### Las monedas no se recolectan

- Verifica que el nodo `Player` se llame exactamente "Player"
- Asegúrate de que la señal `coin_collected` esté conectada en el nivel

### El audio no se reproduce

- Verifica que los archivos de audio estén en las carpetas correctas
- Asegúrate de que los nodos `AudioStreamPlayer` tengan el stream asignado
- Revisa que el volumen no esté en -80 dB (silenciado)

### Errores de exportación

- Verifica que todos los assets estén incluidos en el proyecto
- Asegúrate de tener los templates de exportación instalados
- Revisa la consola de Godot para mensajes de error específicos

## Recursos Adicionales

### Documentación de Godot

- [Documentación Oficial de Godot 4](https://docs.godotengine.org/es/stable/)
- [Tutorial de Platformer 2D](https://docs.godotengine.org/es/stable/tutorials/2d/2d_movement.html)
- [Sistema de Señales](https://docs.godotengine.org/es/stable/getting_started/step_by_step/signals.html)

### Comunidad

- [Foro de Godot](https://forum.godotengine.org/)
- [Discord de Godot](https://discord.gg/godotengine)
- [Reddit r/godot](https://www.reddit.com/r/godot/)

### Assets Gratuitos

- [Kenney Assets](https://kenney.nl/assets) - Sprites, sonidos, UI
- [OpenGameArt](https://opengameart.org/) - Arte y música
- [itch.io Game Assets](https://itch.io/game-assets/free) - Variedad de assets

## Guía de Reemplazo de Assets

Para una guía detallada sobre cómo reemplazar los assets visuales y de audio del juego, consulta el archivo **ASSETS_REPLACEMENT_GUIDE.md** en la raíz del proyecto.

La guía incluye instrucciones paso a paso para:
- Reemplazar el tileset (terreno y plataformas)
- Reemplazar sprites del jugador
- Reemplazar efectos de sonido
- Reemplazar música de fondo
- Mantener coherencia visual y sonora

## Créditos

### Desarrollador

- **[TU NOMBRE AQUÍ]**
- **Matrícula**: [TU MATRÍCULA]
- **Universidad**: [TU UNIVERSIDAD]
- **Curso**: [NOMBRE DEL CURSO]
- **Profesor**: [NOMBRE DEL PROFESOR]
- **Fecha**: [FECHA DE ENTREGA]

### Código Base

- **Brett Chalupa** - [brettchalupa.com](https://www.brettchalupa.com)
- Licencia: CC0 (Dominio Público)

### Assets Visuales

- **Sprites y Tileset**: [Coolpunk Puzzle Platformer Asset Pack by Roupiks](https://roupiks.itch.io/coolpunk-puzzle-platformer-asset)
- **Fondo**: Windrise Background (incluido en el pack)
- Licencia: Consultar en itch.io

### Música

- **Ted Kerr (Wolfgang)** - [OpenGameArt Profile](https://opengameart.org/users/wolfgang)
- Tracks: [8-Bit Theme](https://opengameart.org/content/8-bit-theme) & [8-Bit Quirky Waltz](https://opengameart.org/content/8-bit-quirky-waltz)
- Licencia: CC-BY 4.0

### Efectos de Sonido

- Generados con [jsfxr](https://sfxr.me/)
- Licencia: CC0 (Dominio Público)

### Implementación y Mejoras

- Reorganización de estructura de archivos
- Sistema de vidas y checkpoints
- Sistema de enemigos con patrulla
- Efectos de partículas
- Documentación en español
- Integración de assets de Coolpunk
- Menú principal en español
- Sistema de fondos en todos los niveles

## Licencia

Este proyecto está dedicado al dominio público bajo la licencia CC0. Puedes usarlo, modificarlo y distribuirlo libremente sin restricciones.

---

**Diviértete creando tu propio juego de plataformas!**

Si tienes preguntas o encuentras problemas, consulta la sección de Solución de Problemas o busca ayuda en la comunidad de Godot.
