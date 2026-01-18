extends Control

enum ModoEnter {
	NENHUM,
	MENU,
	JOGO
}

var ícone_música_normal: Resource = preload("res://assets/icons/music_note/music_note_normal.svg")
var ícone_música_pressionado: Resource = preload("res://assets/icons/music_note/music_note_pressed.svg")
var ícone_música_desligada_normal: Resource = preload("res://assets/icons/music_note/music_note_off_normal.svg")
var ícone_música_desligada_pressionado: Resource = preload("res://assets/icons/music_note/music_note_off_pressed.svg")

var ícone_sons_normal: Resource = preload("res://assets/icons/speaker/speaker_normal.svg")
var ícone_sons_pressionado: Resource = preload("res://assets/icons/speaker/speaker_pressed.svg")
var ícone_sons_mudo_normal: Resource = preload("res://assets/icons/speaker/speaker_mute_normal.svg")
var ícone_sons_mudo_pressionado: Resource = preload("res://assets/icons/speaker/speaker_mute_pressed.svg")

const TAMANHO_BASE_DA_FONTE_SUBTÍTULO: int = 64
const TAMANHO_BASE_DA_FONTE: int = 48
const TAMANHO_BASE_DA_BARRA_DE_SCROLL: int = 12

var modo_enter: int = ModoEnter.NENHUM


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScrollContainer.horizontal_scroll_mode = ScrollContainer.ScrollMode.SCROLL_MODE_DISABLED
	
	var barra_de_scroll: VScrollBar = $ScrollContainer.get_v_scroll_bar()
	var stylebox_da_barra_de_scroll: StyleBox = barra_de_scroll.get_theme_stylebox("scroll").duplicate()
	stylebox_da_barra_de_scroll.border_width_left *= GameManager.escala
	barra_de_scroll.add_theme_stylebox_override("scroll", stylebox_da_barra_de_scroll)
	
	$ScrollContainer/Control.custom_minimum_size.x = GameManager.tamanho_da_janela.x
	$ScrollContainer/Control.custom_minimum_size.y *= GameManager.escala
	
	$"ScrollContainer/Control/LabelConfiguração".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE_SUBTÍTULO * GameManager.escala)
	
	$ScrollContainer/Control/LabelProfissional.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/LineEditProfissional.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/LineEditProfissional.text = GameManager.id_profissional
	
	$"ScrollContainer/Control/LabelNúmeroDeAlvos".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/LineEditNúmeroDeAlvos".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/LineEditNúmeroDeAlvos".text = str(GameManager.número_de_alvos)
	
	$"ScrollContainer/Control/LabelRepetição".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/LineEditRepetição".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/LineEditRepetição".text = str(GameManager.repetição_máxima)
	
	$ScrollContainer/Control/LabelRequisito.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonRequisito.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonRequisito.get_popup().add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonRequisito.get_popup().transparent_bg = true
	
	if GameManager.requisito == GameManager.Requisitos.APENAS_UM:
		$ScrollContainer/Control/OptionButtonRequisito.select(0)
	elif GameManager.requisito == GameManager.Requisitos.TODOS:
		$ScrollContainer/Control/OptionButtonRequisito.select(1)
	
	$ScrollContainer/Control/LabelVelocidade.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonVelocidade.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonVelocidade.get_popup().add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonVelocidade.get_popup().transparent_bg = true
	
	match GameManager.velocidade:
		GameManager.Velocidades.ESTÁTICA:
			$ScrollContainer/Control/OptionButtonVelocidade.select(0)
		GameManager.Velocidades.LENTA:
			$ScrollContainer/Control/OptionButtonVelocidade.select(1)
		GameManager.Velocidades.MÉDIA:
			$ScrollContainer/Control/OptionButtonVelocidade.select(2)
		GameManager.Velocidades.RÁPIDA:
			$ScrollContainer/Control/OptionButtonVelocidade.select(3)
	
	$ScrollContainer/Control/LabelVidas.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/LineEditVidas.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	
	atualizar_valor_das_vidas(GameManager.configuração_de_vidas)
	
	$"ScrollContainer/Control/LabelDuração".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/LineEditDuração".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	
	if GameManager.duração == INF:
		$"ScrollContainer/Control/LineEditDuração".text = "Ilimitada"
	else:
		$"ScrollContainer/Control/LineEditDuração".text = str(GameManager.duração)
	
	$ScrollContainer/Control/LabelReposicionamento.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonReposicionamento.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonReposicionamento.get_popup().add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonReposicionamento.get_popup().transparent_bg = true
	
	match GameManager.política_de_reposicionamento:
		GameManager.PolíticasDeReposicionamento.NENHUM:
			$ScrollContainer/Control/OptionButtonReposicionamento.select(0)
		GameManager.PolíticasDeReposicionamento.ALVO:
			$ScrollContainer/Control/OptionButtonReposicionamento.select(1)
		GameManager.PolíticasDeReposicionamento.TODOS:
			$ScrollContainer/Control/OptionButtonReposicionamento.select(2)
	
	$"ScrollContainer/Control/LabelAnimações".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/OptionButtonAnimações".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/OptionButtonAnimações".get_popup().add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/OptionButtonAnimações".get_popup().transparent_bg = true
	
	if GameManager.animar:
		$"ScrollContainer/Control/OptionButtonAnimações".select(0)
	else:
		$"ScrollContainer/Control/OptionButtonAnimações".select(1)
	
	$ScrollContainer/Control/LabelExibirTempo.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonExibirTempo.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonExibirTempo.get_popup().add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$ScrollContainer/Control/OptionButtonExibirTempo.get_popup().transparent_bg = true
	
	if GameManager.mostrar_barra_de_tempo:
		$ScrollContainer/Control/OptionButtonExibirTempo.select(0)
	else:
		$ScrollContainer/Control/OptionButtonExibirTempo.select(1)
	
	$"ScrollContainer/Control/LabelMúsica".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	
	if GameManager.música_desligada:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
	
	$"ScrollContainer/Control/HSliderMúsica".set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Música"))) * 100)
	
	$ScrollContainer/Control/LabelEfeitosSonoros.add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	
	if GameManager.sons_mutados:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
	
	$ScrollContainer/Control/HSliderEfeitosSonoros.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100)
	
	$"ScrollContainer/Control/BotãoIniciarMenu".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)
	$"ScrollContainer/Control/BotãoIniciarJogo".add_theme_font_size_override("font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala)

	modo_enter = ModoEnter.NENHUM


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func atualizar_id_profissional(new_text: String) -> void:
	new_text = new_text.replace("\n\r", "_")
	new_text = new_text.replace("\r\n", "_")
	new_text = new_text.replace("\n", "_")
	new_text = new_text.replace("\r", "_")
	new_text = new_text.replace(",", "_")
	
	$ScrollContainer/Control/LineEditProfissional.text = new_text
	GameManager.id_profissional = new_text


func atualizar_número_de_alvos(new_text: String):
	var número_de_alvos: int = int(new_text)
	
	if número_de_alvos < GameManager.repetição_máxima:
		número_de_alvos = GameManager.repetição_máxima
	
	if número_de_alvos > GameManager.número_máximo_de_alvos:
		número_de_alvos = GameManager.número_máximo_de_alvos
	
	if número_de_alvos > GameManager.Alvos.size() * GameManager.repetição_máxima:
		número_de_alvos = GameManager.Alvos.size() * GameManager.repetição_máxima
	
	$"ScrollContainer/Control/LineEditNúmeroDeAlvos".text = str(número_de_alvos)
	GameManager.número_de_alvos = número_de_alvos


func atualizar_repetição(new_text: String) -> void:
	var repetição: int = int(new_text)
	
	if repetição <= 0:
		repetição = 1
	
	if repetição > GameManager.número_de_alvos:
		repetição = GameManager.número_de_alvos
	
	if repetição * GameManager.Alvos.size() < GameManager.número_de_alvos:
		repetição = ceil(float(GameManager.número_de_alvos) / GameManager.Alvos.size())
	
	$"ScrollContainer/Control/LineEditRepetição".text = str(repetição)
	GameManager.repetição_máxima = repetição


func atualizar_vidas(new_text: String) -> void:
	atualizar_valor_das_vidas(int(new_text))
	

func atualizar_valor_das_vidas(vidas: int) -> void:
	if vidas <= 0:
		vidas = GameManager.INT_MAX
	
	GameManager.configuração_de_vidas = vidas
	GameManager.vidas = GameManager.configuração_de_vidas
	
	if vidas == GameManager.INT_MAX:
		$ScrollContainer/Control/LineEditVidas.text = "Ilimitadas"
	else:
		$ScrollContainer/Control/LineEditVidas.text = str(vidas)


func atualizar_duração(new_text: String) -> void:
	var duração: float = float(new_text)
	
	if duração <= 0.0:
		duração = INF
	
	GameManager.duração = duração
	
	if duração == INF:
		$"ScrollContainer/Control/LineEditDuração".text = "Ilimitada"
	else:
		$"ScrollContainer/Control/LineEditDuração".text = str(duração)


func id_profissional_inválido() -> void:
	$ScrollContainer/Control/LineEditProfissional.grab_focus()
	
	var início_do_scroll: int = $ScrollContainer.scroll_vertical
	var fim_do_scroll: int = $ScrollContainer/Control/LineEditProfissional.position.y - 16 * GameManager.escala
	var tween: Tween = create_tween()
	
	tween.tween_property($ScrollContainer, "scroll_vertical", fim_do_scroll, 0.1).from(início_do_scroll)
	tween.tween_property($ScrollContainer/Control/LineEditProfissional, "theme_override_font_sizes/font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala, 0.1)
	tween.tween_property($ScrollContainer/Control/LineEditProfissional, "theme_override_font_sizes/font_size", (TAMANHO_BASE_DA_FONTE + 2) * GameManager.escala, 0.1)
	tween.tween_property($ScrollContainer/Control/LineEditProfissional, "theme_override_font_sizes/font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala, 0.1)
	tween.tween_property($ScrollContainer/Control/LineEditProfissional, "theme_override_font_sizes/font_size", (TAMANHO_BASE_DA_FONTE + 2) * GameManager.escala, 0.1)
	tween.tween_property($ScrollContainer/Control/LineEditProfissional, "theme_override_font_sizes/font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala, 0.1)


func iniciar_menu() -> void:
	if GameManager.id_profissional == "":
		modo_enter = ModoEnter.MENU
		id_profissional_inválido()
	else:
		get_tree().change_scene_to_file("res://UI/tela_inicial_teste.tscn")


func iniciar_jogo() -> void:
	if GameManager.id_profissional == "":
		modo_enter = ModoEnter.JOGO
		id_profissional_inválido()
	else:
		GameManager.iniciar_jogo()


func mostrar_botões_de_iniciar() -> void:
	var tween: Tween = create_tween()
	var início_do_scroll: int = $ScrollContainer.scroll_vertical
	var fim_do_scroll: int = $"ScrollContainer/Control/BotãoIniciarJogo".position.y - 16 * GameManager.escala
	tween.tween_property($ScrollContainer, "scroll_vertical", fim_do_scroll, 0.1).from(início_do_scroll)
	tween.tween_property($"ScrollContainer/Control/BotãoIniciarMenu", "theme_override_font_sizes/font_size", (TAMANHO_BASE_DA_FONTE + 2) * GameManager.escala, 0.05).set_ease(Tween.EASE_IN)
	tween.tween_property($"ScrollContainer/Control/BotãoIniciarJogo", "theme_override_font_sizes/font_size", (TAMANHO_BASE_DA_FONTE + 2) * GameManager.escala, 0.05).set_ease(Tween.EASE_IN)
	tween.tween_property($"ScrollContainer/Control/BotãoIniciarMenu", "theme_override_font_sizes/font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala, 0.05).set_ease(Tween.EASE_OUT)
	tween.tween_property($"ScrollContainer/Control/BotãoIniciarJogo", "theme_override_font_sizes/font_size", TAMANHO_BASE_DA_FONTE * GameManager.escala, 0.05).set_ease(Tween.EASE_OUT)


func _on_line_edit_profissional_text_submitted(new_text: String) -> void:
	atualizar_id_profissional(new_text)
	
	if GameManager.id_profissional == "":
		id_profissional_inválido()
	else:
		match modo_enter:
			ModoEnter.NENHUM:
				mostrar_botões_de_iniciar()
			ModoEnter.MENU:
				iniciar_menu()
			ModoEnter.JOGO:
				iniciar_jogo()


func _on_line_edit_profissional_focus_exited() -> void:
	modo_enter = ModoEnter.NENHUM
	atualizar_id_profissional($ScrollContainer/Control/LineEditProfissional.text)


func _on_line_edit_número_de_alvos_text_submitted(new_text: String) -> void:
	atualizar_número_de_alvos(new_text)
	mostrar_botões_de_iniciar()


func _on_line_edit_número_de_alvos_focus_exited() -> void:
	atualizar_número_de_alvos($"ScrollContainer/Control/LineEditNúmeroDeAlvos".text)


func _on_line_edit_repetição_text_submitted(new_text: String) -> void:
	atualizar_repetição(new_text)
	mostrar_botões_de_iniciar()


func _on_line_edit_repetição_focus_exited() -> void:
	atualizar_repetição($"ScrollContainer/Control/LineEditRepetição".text)


func _on_option_button_requisito_item_selected(index: int) -> void:
	if index == 0:
		GameManager.requisito = GameManager.Requisitos.APENAS_UM
	elif index == 1:
		GameManager.requisito = GameManager.Requisitos.TODOS


func _on_option_button_velocidade_item_selected(index: int) -> void:
	match index:
		0:
			GameManager.velocidade = GameManager.Velocidades.ESTÁTICA
		1:
			GameManager.velocidade = GameManager.Velocidades.LENTA
		2:
			GameManager.velocidade = GameManager.Velocidades.MÉDIA
		3:
			GameManager.velocidade = GameManager.Velocidades.RÁPIDA


func _on_line_edit_vidas_text_submitted(new_text: String) -> void:
	atualizar_vidas(new_text)
	mostrar_botões_de_iniciar()


func _on_line_edit_vidas_focus_exited() -> void:
	atualizar_vidas($ScrollContainer/Control/LineEditVidas.text)


func _on_line_edit_duração_text_submitted(new_text: String) -> void:
	atualizar_duração(new_text)
	mostrar_botões_de_iniciar()


func _on_line_edit_duração_focus_exited() -> void:
	atualizar_duração($"ScrollContainer/Control/LineEditDuração".text)


func _on_option_button_reposicionamento_item_selected(index: int) -> void:
	match index:
		0:
			GameManager.política_de_reposicionamento = GameManager.PolíticasDeReposicionamento.NENHUM
		1:
			GameManager.política_de_reposicionamento = GameManager.PolíticasDeReposicionamento.ALVO
		2:
			GameManager.política_de_reposicionamento = GameManager.PolíticasDeReposicionamento.TODOS


func _on_option_button_animações_item_selected(index: int) -> void:
	if index == 0:
		GameManager.animar = true
	else:
		GameManager.animar = false


func _on_option_button_exibir_tempo_item_selected(index: int) -> void:
	if index == 0:
		GameManager.mostrar_barra_de_tempo = true
	else:
		GameManager.mostrar_barra_de_tempo = false


func _on_botão_música_button_down() -> void:
	if GameManager.música_desligada:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_pressionado
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_pressionado


func _on_botão_música_button_up() -> void:
	if GameManager.música_desligada:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal


func _on_botão_música_pressed() -> void:
	var index_bus_música: int = AudioServer.get_bus_index("Música")
	
	GameManager.música_desligada = !GameManager.música_desligada
	
	if GameManager.música_desligada:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		AudioServer.set_bus_mute(index_bus_música, true)
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		AudioServer.set_bus_mute(index_bus_música, false)


func _on_h_slider_música_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Música"), linear_to_db(value / 100.0))
	
	if value == 0:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_desligada_normal
		GameManager.música_desligada = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Música"), true)
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoMúsica/BotãoMúsica".icon = ícone_música_normal
		GameManager.música_desligada = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Música"), false)


func _on_botão_efeitos_sonoros_button_down() -> void:
	if GameManager.sons_mutados:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_pressionado
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_pressionado


func _on_botão_efeitos_sonoros_button_up() -> void:
	if GameManager.sons_mutados:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal


func _on_botão_efeitos_sonoros_pressed() -> void:
	var index_bust_sons: int = AudioServer.get_bus_index("SFX")
	
	GameManager.sons_mutados = !GameManager.sons_mutados
	
	if GameManager.sons_mutados:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
		AudioServer.set_bus_mute(index_bust_sons, true)
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
		AudioServer.set_bus_mute(index_bust_sons, false)


func _on_h_slider_efeitos_sonoros_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value / 100.0))
	
	if value == 0:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_mudo_normal
		GameManager.sons_mutados = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		$"ScrollContainer/Control/AspectRatioContainerBotãoEfeitosSonoros/BotãoEfeitosSonoros".icon = ícone_sons_normal
		GameManager.sons_mutados = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)


func _on_botão_iniciar_menu_pressed() -> void:
	iniciar_menu()


func _on_botão_iniciar_jogo_pressed() -> void:
	iniciar_jogo()
