extends Node2D


signal mudança_nas_vidas(vidas: int)
signal mudança_nos_pontos(pontos_real: int, pontos_display: int)

const INT_MIN: int = -9223372036854775808
const INT_MAX: int = 9223372036854775807

enum PolíticasDeReposicionamento {
	NENHUM,
	ALVO,
	TODOS
}

enum Alvos {
	DONUT,
	HAMBÚRGUER,
	PIZZA,
	OVO_FRITO,
	MAÇÃ,
	UVA,
	SORVETE,
	CUPCAKE,
	BRÓCOLIS,
	PICOLÉ
}

enum Velocidades {
	ESTÁTICA,
	LENTA,
	MÉDIA,
	RÁPIDA
}

enum Requisitos {
	TODOS,
	APENAS_UM
}

@onready var escala: float = get_viewport_rect().size.x / 1152

var tema_menus_do_teste: Theme = preload("res://UI/menus_do_teste.tres")

# Parâmetros do sistema
const colunas: int = 5
var linhas
var música_desligada: bool = false;
var sons_mutados: bool = false;
var número_máximo_de_alvos: int
@onready var tamanho_da_janela: Vector2 = get_viewport_rect().size

# Parâmetros do jogo
var velocidade: int = Velocidades.MÉDIA
var número_de_alvos: int
var repetição_máxima: int = 3
var requisito: int = Requisitos.TODOS
var política_de_reposicionamento: int = PolíticasDeReposicionamento.TODOS
var alvo_atual: int = 0
var pontos_real: int = 0
var pontos_display: int = 0
var configuração_de_vidas: int = 10
var vidas: int = configuração_de_vidas
var suporte: int = 0
var duração: float = 120.0
var mostrar_barra_de_tempo: bool = true
var animar: bool = true

# Variáveis para o log
var log_data: Array = []  # Armazena os dados do log
var id_sessão: String = gerar_id_único()  # ID único para a sessão
var data_sessão: String = obter_data_hora_atual()  # Data da sessão
var tempo_resposta: float = 0.0
var timestamp_atual_sessão: float = 0.0  # Duração da sessão em segundos
var profissional_responsável: String = "Profissional Padrão"  # Nome do profissional responsável
var nome_jogo: String = "Toque Certo"  # Nome do jogo
var id_profissional: String = ""
var caminho: String = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS) + "/game_logs.csv"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	linhas = round(tamanho_da_janela.y / tamanho_da_janela.x * colunas)
	número_máximo_de_alvos = min(Alvos.size() * repetição_máxima, colunas * linhas - 1)
	número_de_alvos = min(10, número_máximo_de_alvos)

	iniciar_música()
	
	var stylebox_slider: StyleBox = tema_menus_do_teste.get_stylebox("slider", "HSlider")
	stylebox_slider.border_width_left *= escala
	stylebox_slider.border_width_top *= escala
	stylebox_slider.border_width_right *= escala
	stylebox_slider.border_width_bottom *= escala
	stylebox_slider.corner_radius_top_left *= escala
	stylebox_slider.corner_radius_top_right *= escala
	stylebox_slider.corner_radius_bottom_right *= escala
	stylebox_slider.corner_radius_bottom_left *= escala
	
	var stylebox_grabber_area: StyleBox = tema_menus_do_teste.get_stylebox("grabber_area", "HSlider")
	stylebox_grabber_area.border_width_left *= escala
	stylebox_grabber_area.border_width_top *= escala
	stylebox_grabber_area.border_width_right *= escala
	stylebox_grabber_area.border_width_bottom *= escala
	stylebox_grabber_area.corner_radius_top_left *= escala
	stylebox_grabber_area.corner_radius_top_right *= escala
	stylebox_grabber_area.corner_radius_bottom_right *= escala
	stylebox_grabber_area.corner_radius_bottom_left *= escala
	
	var stylebox_grabber_area_highlight: StyleBox = tema_menus_do_teste.get_stylebox("grabber_area_highlight", "HSlider")
	stylebox_grabber_area_highlight.border_width_left *= escala
	stylebox_grabber_area_highlight.border_width_top *= escala
	stylebox_grabber_area_highlight.border_width_right *= escala
	stylebox_grabber_area_highlight.border_width_bottom *= escala
	stylebox_grabber_area_highlight.corner_radius_top_left *= escala
	stylebox_grabber_area_highlight.corner_radius_top_right *= escala
	stylebox_grabber_area_highlight.corner_radius_bottom_right *= escala
	stylebox_grabber_area_highlight.corner_radius_bottom_left *= escala
	
	var grabber_slider: CompressedTexture2D = tema_menus_do_teste.get_icon("grabber", "HSlider")
	var grabber_slider_image: Image = grabber_slider.get_image()
	grabber_slider_image.resize(int(grabber_slider.get_size().x * escala), int(grabber_slider.get_size().y * escala))
	var grabber_slider_texture: ImageTexture = ImageTexture.create_from_image(grabber_slider_image)
	tema_menus_do_teste.set_icon("grabber", "HSlider", grabber_slider_texture)
	
	var grabber_disabled: CompressedTexture2D = tema_menus_do_teste.get_icon("grabber_disabled", "HSlider")
	var grabber_disabled_image: Image = grabber_disabled.get_image()
	grabber_disabled_image.resize(int(grabber_disabled.get_size().x * escala), int(grabber_disabled.get_size().y * escala))
	var grabber_disabled_texture: ImageTexture = ImageTexture.create_from_image(grabber_disabled_image)
	tema_menus_do_teste.set_icon("grabber_disabled", "HSlider", grabber_disabled_texture)
	
	var grabber_highlight: CompressedTexture2D = tema_menus_do_teste.get_icon("grabber_highlight", "HSlider")
	var grabber_highlight_image: Image = grabber_highlight.get_image()
	grabber_highlight_image.resize(int(grabber_highlight.get_size().x * escala), int(grabber_highlight.get_size().y * escala))
	var grabber_highlight_texture: ImageTexture = ImageTexture.create_from_image(grabber_highlight_image)
	tema_menus_do_teste.set_icon("grabber_highlight", "HSlider", grabber_highlight_texture)
	
	var radio_unchecked: CompressedTexture2D = tema_menus_do_teste.get_icon("radio_unchecked", "PopupMenu")
	var radio_unchecked_image: Image = radio_unchecked.get_image()
	radio_unchecked_image.resize(int(radio_unchecked.get_size().x * escala), int(radio_unchecked.get_size().y * escala))
	var radio_unchecked_texture: ImageTexture = ImageTexture.create_from_image(radio_unchecked_image)
	tema_menus_do_teste.set_icon("radio_unchecked", "PopupMenu", radio_unchecked_texture)
	
	var radio_checked: CompressedTexture2D = tema_menus_do_teste.get_icon("radio_checked", "PopupMenu")
	var radio_checked_image: Image = radio_checked.get_image()
	radio_checked_image.resize(int(radio_checked.get_size().x * escala), int(radio_checked.get_size().y * escala))
	var radio_checked_texture: ImageTexture = ImageTexture.create_from_image(radio_checked_image)
	tema_menus_do_teste.set_icon("radio_checked", "PopupMenu", radio_checked_texture)

# Chamado a cada frame
func _process(delta: float) -> void:
	# Atualizar a duração da sessão
	timestamp_atual_sessão += delta
	tempo_resposta += delta

# Função para gerar um ID único para a sessão
func gerar_id_único() -> String:
	return str(randi()) + str(Time.get_ticks_msec())  # Combina um número aleatório com o tempo atual em milissegundos


# Função para obter a data e hora atuais
func obter_data_hora_atual() -> String:
	var data_hora: String = Time.get_datetime_string_from_system()  # Formato: "YYYY-MM-DDTHH:MM:SS"
	return data_hora


func iniciar_música() -> void:
	$"MúsicaDeFundo".play()


func parar_música() -> void:
	$"MúsicaDeFundo".stop()


func iniciar_jogo() -> void:
	pontos_real = 0
	pontos_display = 0
	suporte = 0
	timestamp_atual_sessão = 0.0
	tempo_resposta = 0.0
	log_data = []
	
	mudança_nos_pontos.emit(pontos_real, pontos_display)
	mudança_nas_vidas.emit(vidas)

	# Gerar ID único e data da sessão
	id_sessão = gerar_id_único()
	data_sessão = obter_data_hora_atual()
	print("ID da Sessão: ", id_sessão)
	print("Data da Sessão: ", data_sessão)
	
	get_tree().change_scene_to_file("res://scenes/jogo_principal/jogo_principal.tscn")


func iniciar_jogo_com_parâmetros(número_alvos: int = número_máximo_de_alvos, tempo_de_duração: float = 120.0, política_de_reposicionamento_do_jogo: int = PolíticasDeReposicionamento.TODOS, repetição: int = 3, requisito_para_pontuar: int = Requisitos.TODOS, velocidade_dos_alvos: int = Velocidades.MÉDIA, id_prof: String = "", mostrar_tempo: bool = true, número_de_vidas: int = INT_MAX, animar_ícones: bool = true) -> void:
	número_de_alvos = min(número_alvos, número_máximo_de_alvos)
	duração = tempo_de_duração
	política_de_reposicionamento = política_de_reposicionamento_do_jogo
	repetição_máxima = repetição
	requisito = requisito_para_pontuar
	velocidade = velocidade_dos_alvos
	id_profissional = id_prof
	mostrar_barra_de_tempo = mostrar_tempo
	vidas = número_de_vidas
	animar = animar_ícones
	
	iniciar_jogo()


func acerto_intermediário() -> void:
	log_data.append([id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, "INTERMEDIÁRIO", suporte, Velocidades.find_key(velocidade), vidas])
	salvar_logs_csv()


func acerto_final() -> void:
	pontos_real += 1
	pontos_display += 1
	
	mudança_nos_pontos.emit(pontos_real, pontos_display)
	
	# Adiciona os dados ao log
	log_data.append([id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, "FINAL", suporte, Velocidades.find_key(velocidade), vidas])
	salvar_logs_csv()
	
	tempo_resposta = 0.0


func erro() -> void:
	if pontos_display >= 1:
		pontos_display -= 1
	
	pontos_real -= 1
	
	mudança_nos_pontos.emit(pontos_real, pontos_display)
	
	if vidas != INT_MAX:
		vidas -= 1
		mudança_nas_vidas.emit(vidas)
	
	if vidas == 0:
		finalizar_sessão()
	
	log_data.append([id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, tempo_resposta, pontos_real, alvo_atual, "ERRO", suporte, Velocidades.find_key(velocidade), vidas])
	salvar_logs_csv()


func alterar_número_de_vidas(número_de_vidas: int) -> void:
	vidas = número_de_vidas
	mudança_nas_vidas.emit(vidas)


func mudança_no_suporte() -> void:
	# Adiciona uma linha indicando o novo suporte
	var file: FileAccess = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	file.seek_end()  # Vai para o final do arquivo
	file.store_line("%s,%s,%s,%f,%s,%s,%d,%d,%s,%s,%s,%d" % [id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, "MUDANÇA NO SUPORTE", pontos_real, alvo_atual, "N/A", suporte, Velocidades.find_key(velocidade), vidas])
	
	file.close()


# Função para salvar os logs em um arquivo CSV
func salvar_logs_csv(limpar: bool = true) -> void:
	var file: FileAccess
	
	if !FileAccess.file_exists(caminho):
		# Se o arquivo não existir, cria um novo e adiciona o cabeçalho
		file = FileAccess.open(caminho, FileAccess.WRITE)
		if file == null:
			print("❌ Erro ao criar o arquivo de log!")
			return
		
		# Escreve o cabeçalho apenas uma vez
		file.store_line("ID_Sessao,ID_Profissional,Data_Sessao,Duracao_Sessao,Nome_Jogo,Tempo_Resposta,Pontos,Alvo_Atual,Acerto,Suporte,Velocidade,Vidas")
		
		file.close()
	
	file = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	# Quando a cena do jogo principal for iniciada diretamente no editor
	if id_profissional == "":
		id_profissional = "DEBUG"

	# Vai para o final do arquivo
	file.seek_end()

	# Armazena os logs
	for log_entry in log_data:
		file.store_line("%s,%s,%s,%f,%s,%f,%d,%s,%s,%s,%s,%d" % [
			log_entry[0], log_entry[1], log_entry[2], log_entry[3], log_entry[4],
			log_entry[5], log_entry[6], str(log_entry[7]), str(log_entry[8]), str(log_entry[9]),
			log_entry[10], log_entry[11]
		])
		
	if limpar:
		log_data = []

	file.close()
	print("✅ Logs salvos em: ", file.get_path_absolute())


# Função para finalizar a sessão e registrar o término
func finalizar_sessão(mudar_para_cena_final: bool = true) -> void:
	# Adiciona uma linha indicando o término da sessão
	var file: FileAccess = FileAccess.open(caminho, FileAccess.READ_WRITE)
	
	file.seek_end()  # Vai para o final do arquivo
	file.store_line("%s,%s,%s,%f,%s,%s,%d,%s,%s,%d,%s,%d" % [id_sessão, id_profissional, data_sessão, timestamp_atual_sessão, nome_jogo, "FIM DA SESSÃO", pontos_real, "N/A", "N/A", suporte, Velocidades.find_key(velocidade), vidas])
	
	file.close()
	print("✅ Término da sessão registrado no log.")
	
	if mudar_para_cena_final:
		get_tree().change_scene_to_file("res://UI/tela_final.tscn")


# Função para verificar se o arquivo foi salvo
func verificar_logs() -> void:
	if FileAccess.file_exists(caminho):
		print("📂 Arquivo encontrado!")
		
		var file: FileAccess = FileAccess.open(caminho, FileAccess.READ)
		while not file.eof_reached():
			print(file.get_line())  # Exibe cada linha do CSV no console
		file.close()
	else:
		print("❌ Arquivo NÃO encontrado!")


# Função para sair do jogo
func sair_do_jogo() -> void:
	print("Saindo do jogo...")  # Exibe uma mensagem de saída
	get_tree().quit()  # Encerra o jogo
