extends Control

# Hora da última apertada do botão, inicializado com o epoch do UNIX time (00:00 UTC 01/01/1970).
var hora_da_última_apertada_de_um_botão_secreto: float = 0.0
var sequência: Array[int] = []
const TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS: float = 2.0

var ícone_configurações_normal: Resource = preload("res://assets/icons/settings/settings_normal.svg")
var ícone_configurações_pressed: Resource = preload("res://assets/icons/settings/settings_pressed.svg")

var ícone_música_normal: Resource = preload("res://assets/icons/music_note/music_note_normal.svg")
var ícone_música_pressionado: Resource = preload("res://assets/icons/music_note/music_note_pressed.svg")
var ícone_música_desligada_normal: Resource = preload("res://assets/icons/music_note/music_note_off_normal.svg")
var ícone_música_desligada_pressionado: Resource = preload("res://assets/icons/music_note/music_note_off_pressed.svg")

var ícone_sons_normal: Resource = preload("res://assets/icons/speaker/speaker_normal.svg")
var ícone_sons_pressionado: Resource = preload("res://assets/icons/speaker/speaker_pressed.svg")
var ícone_sons_mudo_normal: Resource = preload("res://assets/icons/speaker/speaker_mute_normal.svg")
var ícone_sons_mudo_pressionado: Resource = preload("res://assets/icons/speaker/speaker_mute_pressed.svg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal if GameManager.música_desligada else ícone_música_normal
	$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal if GameManager.sons_mutados else ícone_sons_normal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_botão_configurações_button_down() -> void:
	$"AspectRatioContainerBotãoConfigurações/BotãoConfigurações".icon = ícone_configurações_pressed


func _on_botão_configurações_button_up() -> void:
	$"AspectRatioContainerBotãoConfigurações/BotãoConfigurações".icon = ícone_configurações_normal


func _on_botão_configurações_pressed() -> void:
	$"ConfiguraçõesDaTelaInicialTeste".visible = true


func _on_configurações_da_tela_inicial_teste_música_desligada(desligada: bool) -> void:
	$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal if desligada else ícone_música_normal


func _on_configurações_da_tela_inicial_teste_sons_mutados(mutados: bool) -> void:
	$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal if mutados else ícone_sons_normal


func _on_botão_música_button_down() -> void:
	if GameManager.música_desligada:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_pressionado
	else:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_pressionado


func _on_botão_música_button_up() -> void:
	if GameManager.música_desligada:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
	

func _on_botão_música_pressed() -> void:
	var index_bus_música: int = AudioServer.get_bus_index("Música")
	
	GameManager.música_desligada = !GameManager.música_desligada
	
	if GameManager.música_desligada:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		$"ConfiguraçõesDaTelaInicialTeste/Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		AudioServer.set_bus_mute(index_bus_música, true)
	else:
		$"ContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		$"ConfiguraçõesDaTelaInicialTeste/Background/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		AudioServer.set_bus_mute(index_bus_música, false)


func _on_botão_sons_button_down() -> void:
	if GameManager.sons_mutados:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_pressionado
	else:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_pressionado


func _on_botão_sons_button_up() -> void:
	if GameManager.sons_mutados:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
	else:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_normal


func _on_botão_sons_pressed() -> void:
	var index_bust_sons: int = AudioServer.get_bus_index("SFX")
	
	GameManager.sons_mutados = !GameManager.sons_mutados
	
	if GameManager.sons_mutados:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_mudo_normal
		$"ConfiguraçõesDaTelaInicialTeste/Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
		AudioServer.set_bus_mute(index_bust_sons, true)
	else:
		$"ContainerBotãoSons/BotãoSons".icon = ícone_sons_normal
		$"ConfiguraçõesDaTelaInicialTeste/Background/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
		AudioServer.set_bus_mute(index_bust_sons, false)


func _on_botão_secreto_1_pressed() -> void:
	if (Time.get_unix_time_from_system() - hora_da_última_apertada_de_um_botão_secreto <= TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS):
		sequência.append(1)
	else:
		sequência = [1]
	
	hora_da_última_apertada_de_um_botão_secreto = Time.get_unix_time_from_system()


func _on_botão_secreto_2_pressed() -> void:
	if (Time.get_unix_time_from_system() - hora_da_última_apertada_de_um_botão_secreto <= TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS):
		sequência.append(2)
	else:
		sequência = [2]
		
	hora_da_última_apertada_de_um_botão_secreto = Time.get_unix_time_from_system()


func _on_botão_secreto_3_pressed() -> void:
	if (Time.get_unix_time_from_system() - hora_da_última_apertada_de_um_botão_secreto <= TEMPO_MÁXIMO_ENTRE_APERTADAS_DE_BOTÕES_SECRETOS):
		sequência.append(3)
		
		# Sequência secreta: 3, 1, 2, 3
		if sequência == [3, 1, 2, 3]:
			sequência = []
			
			get_tree().change_scene_to_file("res://UI/tela_pré_teste.tscn")
	else:
		sequência = [3]
		
	hora_da_última_apertada_de_um_botão_secreto = Time.get_unix_time_from_system()


func _on_botão_jogar_pressed() -> void:
	GameManager.iniciar_jogo()
