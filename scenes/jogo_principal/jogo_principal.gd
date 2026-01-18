extends Node2D


const ícone_pausa_normal: Resource = preload("res://assets/icons/pause/pause_normal.svg")
const ícone_pausa_pressed: Resource = preload("res://assets/icons/pause/pause_pressed.svg")

const suporte = preload("res://scenes/suporte/suporte.tscn")

const donut: Resource = preload("res://scenes/alvos/donut/donut.tscn")
const hambúrguer: Resource = preload("res://scenes/alvos/hambúrguer/hambúrguer.tscn")
const pizza: Resource = preload("res://scenes/alvos/pizza/pizza.tscn")
const ovo_frito: Resource = preload("res://scenes/alvos/ovo_frito/ovo_frito.tscn")
const maçã: Resource = preload("res://scenes/alvos/maçã/maçã.tscn")
const uva: Resource = preload("res://scenes/alvos/uva/uva.tscn")
const sorvete: Resource = preload("res://scenes/alvos/sorvete/sorvete.tscn")
const cupcake: Resource = preload("res://scenes/alvos/cupcake/cupcake.tscn")
const brócolis: Resource = preload("res://scenes/alvos/brócolis/brócolis.tscn")
const picolé: Resource = preload("res://scenes/alvos/picolé/picolé.tscn")

var current_target_box_hollow_default: Resource = preload("res://assets/current_target_box_hollow.png")
var current_target_box_hollow_red: Resource = preload("res://assets/current_target_box_hollow_red.png")

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var velocidade: float
var repetição: int
var certos_intermediários: int = 0
var instâncias_dos_alvos: Array[Array] = []
var alvos_no_jogo: Array[Array] = []
var toques_certos: Array[Array] = []
var posições_originais: Array[Vector2] = []
var indicadores_do_suporte: Array[TextureRect] = []
var vetores_de_movimento_dos_alvos: Array[Array] = []
var sprites_dos_alvos: Array[Sprite2D] = []
var sprite_do_alvo_atual: Sprite2D
var tamanho_da_janela: Vector2
var tempo_total: float = 0.0
var tempo_desde_toque_certo: float = 0.0

var toques: Array[Array] = [];

var tamanho_célula: Vector2
var offset_máximo: Vector2
const OFFSET_MÁXIMO_BASE: int = 50

const DISTÂNCIA_MÍNIMA_BASE_ENTRE_ALVOS: float = 125.0
const DISTÂNCIA_MÍNIMA_BASE_DA_POSIÇÃO_ORIGINAL: float = 200
const NÚMERO_MÁXIMO_DE_TENTATIVAS: int = 100
const TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_SUPERIOR: float = 100.0
const TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_INFERIOR: float = 32.0

const ÍNDICE_Z_ALVO_ATUAL: int = 1
const ÍNDICE_Z_OUTROS_ALVOS: int = 0

var grid_de_alvos: Array[Array] = []

const TAMANHO_BASE_DA_FONTE: int = 64
const TEMPO_ATÉ_AUMENTAR_O_SUPORTE: float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tamanho_da_janela = get_viewport_rect().size
	
	GameManager.alvo_atual = alvo_aleatório()
	repetição = repetição_aleatória()
	
	certos_intermediários = 0
	
	GameManager.vidas = GameManager.configuração_de_vidas

#region Velocidade
	match GameManager.velocidade:
		GameManager.Velocidades.ESTÁTICA:
			velocidade = 0.0
		GameManager.Velocidades.LENTA:
			velocidade = 50.0 * GameManager.escala
		GameManager.Velocidades.MÉDIA:
			velocidade = 150.0 * GameManager.escala
		GameManager.Velocidades.RÁPIDA:
			velocidade = 300.0 * GameManager.escala
		_:
			assert(false, "Velocidade inválida")
#endregion

#region Inicialização do ruído azul
	tamanho_célula.x = tamanho_da_janela.x / GameManager.colunas
	
	if GameManager.mostrar_barra_de_tempo:
		tamanho_célula.y = (tamanho_da_janela.y - TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_SUPERIOR * GameManager.escala - TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_INFERIOR * GameManager.escala) / GameManager.linhas
	else:
		tamanho_célula.y = (tamanho_da_janela.y - TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_SUPERIOR * GameManager.escala) / GameManager.linhas
	
	grid_de_alvos.resize(GameManager.colunas)
	
	var array_temporário: Array[Array]
	array_temporário.resize(GameManager.linhas)
	array_temporário.fill([-1, -1])
	
	for i: int in grid_de_alvos.size():
		grid_de_alvos[i] = array_temporário.duplicate()
	
	# A primeira célula é reservada para o indicador do alvo atual
	grid_de_alvos[0][0] = [GameManager.INT_MAX, GameManager.INT_MAX]
	grid_de_alvos[GameManager.colunas - 1][0] = [GameManager.INT_MAX, GameManager.INT_MAX]
	
	var aspect_ratio_célula: float = tamanho_célula.y / tamanho_célula.x
	offset_máximo = Vector2(OFFSET_MÁXIMO_BASE * GameManager.escala, OFFSET_MÁXIMO_BASE * GameManager.escala * aspect_ratio_célula)
#endregion
	
#region Inicialização dos alvos
	instâncias_dos_alvos.resize(GameManager.Alvos.size())
	
	var resources_alvos: Array[Resource]
	resources_alvos.resize(GameManager.Alvos.size())
	
	resources_alvos[GameManager.Alvos.DONUT] = donut
	resources_alvos[GameManager.Alvos.HAMBÚRGUER] = hambúrguer
	resources_alvos[GameManager.Alvos.PIZZA] = pizza
	resources_alvos[GameManager.Alvos.OVO_FRITO] = ovo_frito
	resources_alvos[GameManager.Alvos.MAÇÃ] = maçã
	resources_alvos[GameManager.Alvos.UVA] = uva
	resources_alvos[GameManager.Alvos.SORVETE] = sorvete
	resources_alvos[GameManager.Alvos.CUPCAKE] = cupcake
	resources_alvos[GameManager.Alvos.BRÓCOLIS] = brócolis
	resources_alvos[GameManager.Alvos.PICOLÉ] = picolé

	for i: int in GameManager.Alvos.values():
		instâncias_dos_alvos[i].resize(GameManager.repetição_máxima)
		
		for j: int in GameManager.repetição_máxima:
			var alvo: Area2D = resources_alvos[i].instantiate()
			
			instâncias_dos_alvos[i][j] = alvo
			add_child(alvo)
			
			alvo.visible = false
			setar_índice_z_de_alvo([i, j], ÍNDICE_Z_OUTROS_ALVOS)
	
	for alvos: Array in instâncias_dos_alvos:
		for i: int in alvos.size():
			alvos[i].tocado.connect(func(tipo: int):
				toques.append([tipo, i])
			)
#endregion
	
#region Inicialização dos indicadores do suporte
	indicadores_do_suporte.resize(GameManager.repetição_máxima)
	
	for i: int in GameManager.repetição_máxima:
		var instância_do_indicador_do_suporte = suporte.instantiate()
		
		$CanvasLayer/ControlSuporte.add_child(instância_do_indicador_do_suporte)
		
		instância_do_indicador_do_suporte.texture = current_target_box_hollow_default
		instância_do_indicador_do_suporte.scale = Vector2(GameManager.escala, GameManager.escala)
		
		instância_do_indicador_do_suporte.visible = false
		
		indicadores_do_suporte[i] = instância_do_indicador_do_suporte
#endregion
	
#region Inicialização dos vetores de movimento e sprites dos alvos
	vetores_de_movimento_dos_alvos.resize(instâncias_dos_alvos.size())
	sprites_dos_alvos.resize(instâncias_dos_alvos.size())
	
	for i: int in instâncias_dos_alvos.size():
		for j in instâncias_dos_alvos[i].size():
			instâncias_dos_alvos[i][j].scale = Vector2(GameManager.escala, GameManager.escala)
			
			vetores_de_movimento_dos_alvos[i].append(vetor_de_movimento_aleatório())
		
		for child: Node in instâncias_dos_alvos[i][0].get_children():
			if child is Sprite2D:
				sprites_dos_alvos[i] = child.duplicate()
				
				sprites_dos_alvos[i].scale *= GameManager.escala
				sprites_dos_alvos[i].position = Vector2(75 * GameManager.escala, 75 * GameManager.escala)
#endregion
	
#region Inicialização dos elementos da interface
	setar_sprite_alvo(GameManager.alvo_atual)
	$CanvasLayer/ControlAlvo/RectAlvo.scale = Vector2(GameManager.escala, GameManager.escala)
	
	$BarraDeTempo.scale = Vector2(0, GameManager.escala)
	$BarraDeTempo.global_position = Vector2(0.0, tamanho_da_janela.y - 16 * GameManager.escala)
	$BarraDeTempo.visible = GameManager.mostrar_barra_de_tempo
	
	$CanvasLayer/LabelPontos.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_DA_FONTE)
	$CanvasLayer/LabelVidas.add_theme_font_size_override("font_size", GameManager.escala * TAMANHO_BASE_DA_FONTE)
		
	$CanvasLayer/Heart.global_position *= GameManager.escala
	$CanvasLayer/HeartAnimation.global_position *= GameManager.escala
	$CanvasLayer/Star.global_position *= GameManager.escala
	
	$CanvasLayer/Heart.scale *= GameManager.escala
	$CanvasLayer/HeartAnimation.scale *= GameManager.escala
	$CanvasLayer/Star.scale *= GameManager.escala
	
	atualizar_placar(GameManager.pontos_display)
	GameManager.mudança_nos_pontos.connect(func(_pontos_real, pontos_display) -> void:
		atualizar_placar(pontos_display)
	)
	
	atualizar_vidas(GameManager.vidas)
	GameManager.mudança_nas_vidas.connect(atualizar_vidas)
#endregion

	spawnar_todos_os_alvos()
	
	setar_índice_z_de_alvos_de_tipo(GameManager.alvo_atual, ÍNDICE_Z_ALVO_ATUAL)
	
	if GameManager.velocidade != GameManager.Velocidades.ESTÁTICA:
		limpar_grid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#region Tempo
	tempo_total += delta
	tempo_desde_toque_certo += delta
	
	if tempo_total >= GameManager.duração:
		GameManager.finalizar_sessão()
		
	if GameManager.duração != INF:
		var progresso: float = tempo_total / GameManager.duração
		
		$BarraDeTempo.scale = Vector2(progresso * tamanho_da_janela.x / 32, GameManager.escala)
		$BarraDeTempo.global_position.x = progresso * tamanho_da_janela.x / 2
#endregion

#region Ruído azul
	if GameManager.mostrar_barra_de_tempo:
		tamanho_célula.y = (tamanho_da_janela.y - TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_SUPERIOR * GameManager.escala - TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_INFERIOR * GameManager.escala) / GameManager.linhas
	else:
		tamanho_célula.y = (tamanho_da_janela.y - TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_SUPERIOR * GameManager.escala) / GameManager.linhas
#endregion

#region Tratamento do toque
	if toques.size() != 0:
		var alvo_original: int = GameManager.alvo_atual
		var novos_toques_certos: Array[Array] = []
		
		for toque: Array[int] in toques:
			if toque[0] == GameManager.alvo_atual:
				toques_certos.append(toque)
				novos_toques_certos.append(toque)
		
		if novos_toques_certos.size() > 0:
			$TapRight.play()
			
			for toque_certo: Array[int] in novos_toques_certos:
				posições_originais.append(centro_de_alvo(toque_certo))
				
				if GameManager.política_de_reposicionamento != GameManager.PolíticasDeReposicionamento.NENHUM:
					remover_alvo(toque_certo)
				else:
					# Esconda os alvos tocados até o todos os toques certos sejam realizados, não os
					# remova pois a política de reposicionamento é nenhum.
					instâncias_dos_alvos[toque_certo[0]][toque_certo[1]].visible = false
					setar_índice_z_de_alvo(toque_certo, ÍNDICE_Z_OUTROS_ALVOS)
				
				certos_intermediários += 1
			
			if certos_intermediários >= repetição or GameManager.requisito == GameManager.Requisitos.APENAS_UM:
				GameManager.acerto_final()
				
				if GameManager.animar:
					$CanvasLayer/Star.play()
				
				alterar_suporte(0)
				tempo_desde_toque_certo = 0.0
				
				certos_intermediários = 0
				
				if GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.ALVO:
					for i: int in GameManager.número_de_alvos - alvos_no_jogo.size():
						var novo_alvo: Array[int] = adicionar_alvo(false)
						posicionar_alvo_com_ruído_azul(novo_alvo, GameManager.velocidade == GameManager.Velocidades.ESTÁTICA, posições_originais[i])
					
					GameManager.alvo_atual = alvo_aleatório_presente()

					while GameManager.alvo_atual == alvo_original:
						GameManager.alvo_atual = alvo_aleatório_presente()
					
					repetição = alvos_de_tipo(GameManager.alvo_atual)
					
					setar_índice_z_de_alvos_de_tipo(alvo_original, ÍNDICE_Z_OUTROS_ALVOS)
					setar_índice_z_de_alvos_de_tipo(GameManager.alvo_atual, ÍNDICE_Z_ALVO_ATUAL)
				
					setar_sprite_alvo(GameManager.alvo_atual)
				elif GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.TODOS:
					GameManager.alvo_atual = alvo_aleatório()
					
					while GameManager.alvo_atual == alvo_original:
						GameManager.alvo_atual = alvo_aleatório()
					
					repetição = repetição_aleatória()
					spawnar_todos_os_alvos()
					
					setar_índice_z_de_alvos_de_tipo(alvo_original, ÍNDICE_Z_OUTROS_ALVOS)
					setar_índice_z_de_alvos_de_tipo(GameManager.alvo_atual, ÍNDICE_Z_ALVO_ATUAL)
					
					setar_sprite_alvo(GameManager.alvo_atual)
					
					if GameManager.velocidade != GameManager.Velocidades.ESTÁTICA:
						limpar_grid()
				elif GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.NENHUM:
					GameManager.alvo_atual = alvo_aleatório_presente()
				
					while GameManager.alvo_atual == alvo_original and GameManager.número_de_alvos > 1:
						GameManager.alvo_atual = alvo_aleatório_presente()
					
					repetição = alvos_de_tipo(GameManager.alvo_atual)
					
					setar_índice_z_de_alvos_de_tipo(alvo_original, ÍNDICE_Z_OUTROS_ALVOS)
					setar_índice_z_de_alvos_de_tipo(GameManager.alvo_atual, ÍNDICE_Z_ALVO_ATUAL)
				
					setar_sprite_alvo(GameManager.alvo_atual)
				# Faça os alvos ocultos após toque certo serem visíveis novamente
				if GameManager.política_de_reposicionamento == GameManager.PolíticasDeReposicionamento.NENHUM:
					for toque_certo: Array in toques_certos:
						instâncias_dos_alvos[toque_certo[0]][toque_certo[1]].visible = true
				
				toques_certos.clear()
			else:
				GameManager.acerto_intermediário()
				
				tempo_desde_toque_certo = floor(tempo_desde_toque_certo / TEMPO_ATÉ_AUMENTAR_O_SUPORTE) * TEMPO_ATÉ_AUMENTAR_O_SUPORTE
		else:
			GameManager.erro()
			
			if GameManager.vidas > 0:
				$TapWrong.play()
			
			if GameManager.animar and GameManager.vidas > 0:
				$CanvasLayer/HeartAnimation.play()
	
		toques.clear()
#endregion
	
#region Movimento dos alvos
	for alvo: Array[int] in alvos_no_jogo:
		instâncias_dos_alvos[alvo[0]][alvo[1]].global_position += vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]] * delta
		
		if vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].x < 0 and instâncias_dos_alvos[alvo[0]][alvo[1]].global_position.x < 0:
			vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].x *= -1
		
		if vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].x > 0 and instâncias_dos_alvos[alvo[0]][alvo[1]].global_position.x + instâncias_dos_alvos[alvo[0]][alvo[1]].width * GameManager.escala > tamanho_da_janela.x:
			vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].x *= -1

		if vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].y < 0 and instâncias_dos_alvos[alvo[0]][alvo[1]].global_position.y < 0:
			vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].y *= -1

		if vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].y > 0 and instâncias_dos_alvos[alvo[0]][alvo[1]].global_position.y + instâncias_dos_alvos[alvo[0]][alvo[1]].height * GameManager.escala > tamanho_da_janela.y:
			vetores_de_movimento_dos_alvos[alvo[0]][alvo[1]].y *= -1
#endregion

#region Suporte
	var novo_suporte: int = min(3, floor(tempo_desde_toque_certo / TEMPO_ATÉ_AUMENTAR_O_SUPORTE))
	
	if novo_suporte != GameManager.suporte:
		alterar_suporte(novo_suporte)

	if (GameManager.suporte > 0):
		for i: int in repetição:
			var alvo: Area2D = instâncias_dos_alvos[GameManager.alvo_atual][i]
			
			if alvos_no_jogo.has([GameManager.alvo_atual, i]) and alvo.visible:
				indicadores_do_suporte[i]. visible = true
		
				var escala_suporte: float = abs(sin(tempo_total * GameManager.suporte) * (GameManager.suporte - 1) * 0.1)
				indicadores_do_suporte[i].scale = Vector2(GameManager.escala + GameManager.escala * escala_suporte, GameManager.escala + GameManager.escala * escala_suporte)
			
				indicadores_do_suporte[i].global_position = Vector2(alvo.global_position.x + (alvo.width / 2 - 75 * (1 + escala_suporte)) * GameManager.escala,
																	alvo.global_position.y + (alvo.height / 2 - 75 * (1 + escala_suporte)) * GameManager.escala)
			
			else:
				indicadores_do_suporte[i]. visible = false
	
	else:
		for i: int in GameManager.repetição_máxima:
			indicadores_do_suporte[i].visible = false
#endregion


func _input(event: InputEvent) -> void:
	if event.is_action_released("pausar"):
		$CanvasLayer/MenuPausa.visible = true
		get_tree().paused = true


func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		pausar()


func alterar_suporte(novo_suporte: int) -> void:
	if (novo_suporte != GameManager.suporte):
		GameManager.suporte = novo_suporte
		GameManager.mudança_no_suporte()
		
		for i: int in repetição:
			if novo_suporte == 3:
				indicadores_do_suporte[i].texture = current_target_box_hollow_red
			else:
				indicadores_do_suporte[i].texture = current_target_box_hollow_default

func setar_sprite_alvo(tipo: int) -> void:
	if sprite_do_alvo_atual != null:
		$CanvasLayer/ControlAlvo.remove_child(sprite_do_alvo_atual)
	
	$CanvasLayer/ControlAlvo.add_child(sprites_dos_alvos[tipo])
	sprite_do_alvo_atual = sprites_dos_alvos[tipo]
	
func atualizar_placar(pontos: int) -> void:
	$CanvasLayer/LabelPontos.text = str(pontos)


func atualizar_vidas(vidas: int) -> void:
	if vidas != GameManager.INT_MAX:
		$CanvasLayer/LabelVidas.visible = true
		$CanvasLayer/Heart.visible = true
		$CanvasLayer/HeartAnimation.visible = true
		$CanvasLayer/LabelVidas.text = str(vidas)
	else:
		$CanvasLayer/LabelVidas.visible = false
		$CanvasLayer/Heart.visible = false
		$CanvasLayer/HeartAnimation.visible = false


func alvo_aleatório_presente() -> int:
	var alvos_presentes: Array[int] = []
	
	for alvo: Array[int] in alvos_no_jogo:
		if not alvos_presentes.has(alvo[0]):
			alvos_presentes.append(alvo[0])
	
	return alvos_presentes.pick_random()


func alvo_aleatório() -> int:
	return GameManager.Alvos.values().pick_random()


func repetição_aleatória() -> int:
	return rng.randi_range(1, GameManager.repetição_máxima)


func vetor_de_movimento_aleatório() -> Vector2:
	var vetor_de_movimento: Vector2 = Vector2(rng.randi_range(0, 1), rng.randi_range(0, 1))
		
	if vetor_de_movimento.x == 0:
		vetor_de_movimento.x = -1.0
	
	if vetor_de_movimento.y == 0:
		vetor_de_movimento.y = -1.0
		
	vetor_de_movimento = vetor_de_movimento.normalized() * velocidade
		
	return vetor_de_movimento
   
	
func posicionar_alvo_com_ruído_azul(alvo: Array, ocupar_célula: bool, posição_original: Vector2 = Vector2(NAN, NAN)) -> Array:
	var coluna: int
	var linha: int
	var x: float
	var y: float
	var tentativas: int = 0
	
	# Cria uma lista de células não ocupadas
	var células_vazias: Array[Array] = []
	for i: int in GameManager.colunas:
		for j: int in GameManager.linhas:
			if grid_de_alvos[i][j][0] < 0:
				células_vazias.append([i, j])
	
	# Escolhe uma célula aleatória da lista
	assert(células_vazias.size() > 0, "Não há células vazias.")
	while tentativas < NÚMERO_MÁXIMO_DE_TENTATIVAS:
		var célula_escolhida: Array = células_vazias[rng.randi_range(0, células_vazias.size() - 1)]
		coluna = célula_escolhida[0]
		linha = célula_escolhida[1]
			
		x = coluna * tamanho_célula.x + tamanho_célula.x / 2 + rng.randf_range(-offset_máximo.x, offset_máximo.x)
		y = linha * tamanho_célula.y + tamanho_célula.y / 2 + rng.randf_range(-offset_máximo.y, offset_máximo.y) + TAMANHO_BASE_DA_ZONA_DE_EXCLUSÃO_SUPERIOR * GameManager.escala
		
		if !is_nan(posição_original.x):
			if distância_entre_alvos([-1, -1], [-1, -1], posição_original, Vector2(x, y)) < DISTÂNCIA_MÍNIMA_BASE_DA_POSIÇÃO_ORIGINAL * GameManager.escala:
				tentativas =+ 1
				continue
		
		tentativas = GameManager.INT_MAX
	
		if ocupar_célula:
			grid_de_alvos[coluna][linha] = [alvo[0], alvo[1]]
		
		instâncias_dos_alvos[alvo[0]][alvo[1]].global_position = Vector2(x - instâncias_dos_alvos[alvo[0]][alvo[1]].width * GameManager.escala / 2,\
																		 y - instâncias_dos_alvos[alvo[0]][alvo[1]].height * GameManager.escala / 2)
	
	return [Vector2(x, y), coluna, linha]


func spawnar_todos_os_alvos() -> void:
	limpar_grid()
	limpar_alvos_do_jogo()
	
	var alvos: int = 0
	
	# Spawna primeiro os alvos certos
	for i: int in repetição:
		if alvos == repetição:
			break
		
		var alvo = [GameManager.alvo_atual, i]
		
		instâncias_dos_alvos[alvo[0]][alvo[1]].visible = true
		
		alvos_no_jogo.append(alvo)
		
		alvos += 1
	
	while alvos_no_jogo.size() < GameManager.número_de_alvos:
		adicionar_alvo()
		alvos += 1
	
	for alvo: Array[int] in alvos_no_jogo:
		posicionar_alvo_com_ruído_azul(alvo, true)


func adicionar_alvo(proibir_alvo_atual: bool = true) -> Array[int]:
	while true:
		var alvo_para_adicionar = alvo_aleatório()
		
		if alvo_para_adicionar == GameManager.alvo_atual and proibir_alvo_atual:
			continue
		
		var alvos_presentes = alvos_de_tipo(alvo_para_adicionar)
		
		if alvos_presentes >= GameManager.repetição_máxima:
			continue
		
		var índice_livre: int = 0
		
		var índices_usados: Array[int] = []
		for alvo: Array[int] in alvos_no_jogo:
			if alvo[0] == alvo_para_adicionar:
				índices_usados.append(alvo[1])

		for i: int in GameManager.repetição_máxima:
			if not índices_usados.has(i):
				índice_livre = i
				break
		
		instâncias_dos_alvos[alvo_para_adicionar][índice_livre].visible = true
		
		alvos_no_jogo.append([alvo_para_adicionar, índice_livre])
		
		return [alvo_para_adicionar, índice_livre]
	
	return [-1, -1]


func alvos_de_tipo(tipo: int):
	var alvos_presentes = 0
	
	for i in alvos_no_jogo.size():
		if alvos_no_jogo[i][0] == tipo:
			alvos_presentes += 1
	
	return alvos_presentes


func remover_alvo(alvo: Array) -> void:
	var índice: int = alvos_no_jogo.find(alvo)
	
	if índice != -1:
		alvos_no_jogo.remove_at(índice)
	
	instâncias_dos_alvos[alvo[0]][alvo[1]].visible = false
	
	for i: int in GameManager.colunas:
		for j: int in GameManager.linhas:
			if grid_de_alvos[i][j] == alvo:
				grid_de_alvos[i][j] = [-1, -1]
				return

	assert(GameManager.velocidade != GameManager.Velocidades.ESTÁTICA, "Alvo não encontrado")


func limpar_grid() -> void:
	for i: int in grid_de_alvos.size():
		for j: int in grid_de_alvos[i].size():
			grid_de_alvos[i][j] = [-1, -1]

	grid_de_alvos[0][0] = [GameManager.INT_MAX, GameManager.INT_MAX]


func limpar_alvos_do_jogo() -> void:
	for alvo: Array[int] in alvos_no_jogo:
		instâncias_dos_alvos[alvo[0]][alvo[1]].visible = false
	
	alvos_no_jogo.clear()


func centro_de_alvo(alvo: Array) -> Vector2:
	return instâncias_dos_alvos[alvo[0]][alvo[1]].global_position + Vector2(instâncias_dos_alvos[alvo[0]][alvo[1]].width / 2 * GameManager.escala,
																			instâncias_dos_alvos[alvo[0]][alvo[1]].height / 2 * GameManager.escala)


# Calcula a distância entre o centro de dois alvos. Use [-1, -1] em um dos alvos para especificar um
# ponto arbitrário no terceiro argumento ou [-1, -1] nos dois alvos para especificar dois pontos
# arbitrários no terceiro e quarto argumento e calcular a distância entre eles.
func distância_entre_alvos(a: Array, b: Array, pos_1: Vector2 = Vector2(0, 0), pos_2: Vector2 = Vector2(0, 0)) -> float:
	var centro_a: Vector2
	var centro_b: Vector2
	
	if a == [-1, -1] and b == [-1, -1]:
		centro_a = pos_1
		centro_b = pos_2
	elif a == [-1, -1]:
		centro_a = pos_1
		centro_b = centro_de_alvo(b)
	elif b == [-1, -1]:
		centro_a = centro_de_alvo(a)
		centro_b = pos_1
	else:
		centro_a = centro_de_alvo(a)
		centro_b = centro_de_alvo(b)
	
	return sqrt(pow(centro_a.x - centro_b.x, 2) + pow(centro_a.y - centro_b.y, 2))


func setar_índice_z_de_alvo(alvo: Array, índice_z: int) -> void:
	instâncias_dos_alvos[alvo[0]][alvo[1]].z_index = índice_z


func setar_índice_z_de_alvos_de_tipo(tipo: int, índice_z: int) -> void:
	for i: int in GameManager.repetição_máxima:
		setar_índice_z_de_alvo([tipo, i], índice_z)


func pausar():
	$CanvasLayer/MenuPausa.visible = true
	get_tree().paused = true


func _on_botão_pausa_button_down() -> void:
	$"CanvasLayer/ContainerBotãoPausa/BotãoPausa".icon = ícone_pausa_pressed


func _on_botão_pausa_button_up() -> void:
	$"CanvasLayer/ContainerBotãoPausa/BotãoPausa".icon = ícone_pausa_normal


func _on_botão_pausa_pressed() -> void:
	pausar()


func _on_menu_pausa_barra_de_tempo_oculta(oculta: bool) -> void:
	$BarraDeTempo.visible = not oculta
