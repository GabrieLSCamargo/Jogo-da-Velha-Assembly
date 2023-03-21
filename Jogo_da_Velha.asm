.data
	tabuleiro: 	.asciiz " 1 | 2 | 3\n---+---+---\n 4 | 5 | 6\n---+---+---\n 7 | 8 | 9\n"
						#índices das casas:
						#1 	5 	9		
						#24 	28 	32
						#47 	51 	55
	maquina: 	.byte 'O'
	jogador: 	.byte 'X'
	escolher: 	.asciiz "Escolha a casa: \n"
	msgOcupada:	.asciiz "A casa selecionada já está ocupada\n"
	vitoria_jog: 	.asciiz "Vitória de X\n"
	vitoria_maq: 	.asciiz "VItória de O\n"
	empate: 	.asciiz "Empate\n"
	turno: 		.word 1
	n_jogada:	.word 0
	array:		-1, -2, -3, -4, -5, -6, -7, -8, -9
	
	# v[0] = t[1]				0	4	8
	# v[4] = t[5]				12	16	20
	# v[8] = t[9]				24	28	32
	# v[12] = t[24]
	# v[16] = t[28]
	# v[20] = t[32]
	# v[24] = t[47]
	# v[28] = t[51]
	# v[32] = t[55]
	
	.eqv CASAS 36
	.eqv MAQ 0
	.eqv JOG 1
	.eqv HOR 1
	.eqv VER 2
	.eqv DP 3
	.eqv DS 4

.text
	
	
	entrada:
		jal imprimir
		la $s2, array #s2 = array
		li $s6, 36
		
		li $v0, 4
		la $a0, escolher
		syscall
		
		li $v0, 5 # recebe valor no terminal
		syscall
		
		move $s1, $v0 # move valor recebido de $v0 para $s1
		lw $s4, turno # $s4 le o numero alocado em turno
		subi $s1, $s1, 1 # subtraindo o valor da entrada em 1 para utilizar no vetor
		sll $s1, $s1, 2 # multiplica o valor de s1 por 4
		add $s2, $s2, $s1 # seleciona a posição do vetor s2 = *array[s1]
		jal posicao_livre
		sw $s4, ($s2) # vetor($s2) = $s4
		
		jal substituirTab
		jal confereVitoria
		
		lw $s4, n_jogada # ponteiro para n_jogadas
		jal cont_jogada  # aumenta o contador de jogadas
		beq $s4, 9, empatou # se ocorrem 9 jogadas e ninguém vencer, termina o jogo
		j IA_jogada
		
	IA_jogada:
		move $s0, $zero #variavel de busca
		j IA_busca
		return:
		li $s0, JOG	#s0 = 1
		j IA_busca
		IA_cont:
		sw $s4, ($s2) # vetor($s2) = $s4
		
		jal substituirTab
		jal confereVitoria
		
		lw $s4, n_jogada # ponteiro para n_jogadas
		jal cont_jogada  # aumenta o contador de jogadas
		beq $s4, 9, empatou # se ocorrem 9 jogadas e ninguém vencer, termina o jogo
		j entrada
	IA_busca:
		move $t0, $zero #inicia contador em 0
		move $t3, $zero #inicia indice em 0
	 
		IA_Horizontal:
			move $s2, $zero #contador para trinca
			li $s1, 69 #$s1 guarda a casa
			li $t1, 12 #carrega em t1 o inteiro 12
			mul $t5, $t0, $t1 # multiplica o contador por 12
			move $t3, $t5 #iguala indice ao contador*12
			addi $t5, $t5, 8 # soma o contador com 8
			li $s3, HOR #s3 = horizontal 
			j continue0.5

	
		IA_Vertical:
			move $s2, $zero #contador para trinca
			beq $s3, VER, aumenta_cont
			li $s1, 69 # $s1 guarda a casa
			move $t4, $zero	#contador de condições
			li $t1, 4 # carrega em t1 o inteiro 4
			mul $t5, $t0, $t1 # multiplica o contador por 4
			move $t3, $t5 # iguala o indice ao contador*4
			addi $t5, $t5, 24
			li $s3, VER # s3 = vertical
			j continue0.5
		
		Dia_prin:
			li $t3, 0 #indice igual a zero
			li $s1, 69 #s1 guarda casa
			move $t4, $zero	#contador de condições
			li $s3, DP #flag para diagonal principal
			j continue0.5
	
		Dia_sec:
			li $t3, 8 #indice igual a 8
			li $s1, 69 #s1 guarda casa
			move $t4, $zero	#contador de condições
			li $s3, DS # flag para diagonal secundaria
			move $s2, $zero #contador para trinca
			j continue0.5
		
		
		continue0.5:
			bgt $t3, $t5, IA_Vertical #sai do laço
			move $t4, $zero	#contador de condições
			
			continue1:
				lw $t2, array($t3) #guarda o valor de array(indice) em t2
				blt $t2, 0, GuardaCasa # se array(t3) < 0: guarda a casa livre
				beq $t2, $s0, TrincaMais # se array (indice) igual a busca: trinca++
				continue1.25:
				beq $s2, 2, condicao #se houver duas casas preenchidas com a busca
				continue1.5:
				beq $s3, HOR, continueH
				beq $s3, VER, continueV
				beq $s3, DP, continueDP
				beq $s3, DS, continueDS
					continueH:
						addi $t3, $t3, 4 #soma o indice com 4 para horizontal	
						j continue0.5
					continueV:
						addi $t3, $t3, 12 #soma o indice com 12 para vertical
						j continue0.5
					continueDP:
						beq $s2, 2, condicao #testa possibilidade de vitória
						continueDP1:
							beq $t3, 32, Dia_sec # vai para DS se t3 = 32
							addi $t3, $t3, 16 #soma o indice em 36 para a DP
						j continue1
					continueDS:
						beq $s2, 2, condicao #testa possibilidade de vitória
						continueDS1:
							beq $t3, 24, MaquinaVeCasaVazia # sai do laço quando t3 = 24
							addi $t3, $t3, 8 #soma indice em 8 para a DS 
						j continue1
		condicao:
			addi $t4, $t4, 1	# aumenta o contador de condições em 1
			beq $t4, 2, maquina_joga # se houver as duas condições atendidas, sai
			blt $s1, 69, condicao	# se a casa guardada for diferente de 69, vai voltar para o inicio da função
			move $t4, $zero	#contador de condições
			beq $s3, DP, continueDP1
			beq $s3, DS, continueDS1
			j continue1.5		#se uma condição não for atendida, segue o loop normalmente
	
		aumenta_cont:
			beq $t0, 2, Dia_prin #se o contador é dois vai para DP
			addi $t0, $t0, 1  #aumenta o contador
			j IA_Horizontal
		TrincaMais:
			addi $s2, $s2, 1 # adiciona no contador de trinca
			j continue1.25
		
	
		GuardaCasa:
			move $s1, $t3 #guarda o indice do vetor em s1
			j continue1.25
		
		maquina_joga:
			#$s1 guarda a casa
			
			la $s2, array #s2 = *array
			add $s2, $s2, $s1 #s2 = *array[s1]
			lw $s4, turno #s4 recebe turno
			sw $s4, ($s2) # altera array
			j IA_cont 
	
		MaquinaVeCasaVazia:
			beq $s0, MAQ, return
			move $s1, $zero
			loop_maquina:
				bgt $s1, 32, sair
				lw $t2, array($s1) #guarda o valor de array(indice) em t2
				blt $t2, 0, maquina_joga# se array(t3) < 0: guarda a casa livre
				addi $s1, $s1, 4 	
				j loop_maquina
		
	substituirTab:
		lw $t2, turno	# t2 = turno
		beq $t2, 0, TurnoDeBolinha
		beq $t2, 1, TurnoDeXis
	
	imprimir:
		li $v0, 4
		la $a0, tabuleiro
		syscall
		jr $ra
	
	cont_jogada:
		addi $s4, $s4, 1 # soma 1 no contador de jogadas
		sw $s4, n_jogada
		jr $ra
		
	posicao_livre:
		lw $t0, ($s2)	# t0 = array[s2]
		bge $t0, 0, ocupada # se t0 for >= 0, a posição está ocupada
		jr $ra	#se não, está livre e volta para a função
		
	ocupada:
		beq $s4, JOG, msg_ocupada
		j IA_busca
	msg_ocupada:
		li $v0, 4
		la $a0, msgOcupada
		syscall
		j entrada
		
			
	TurnoDeXis:
		lb $t0, jogador #$t0 = 'X'
		li $t3, MAQ	# muda o turno para 0 (bolinha)
		sw $t3, turno
		ble $s1, 8, subTab	# se a posição do vetor estiver na primeira linha do tabuleiro
		ble $s1, 20, subTab2	# se a posição do vetor estiver na segunda linha do tabuleiro
		j subTab3		# se a posição do vetor estiver na terceira linha do tabuleiro
		
	
	TurnoDeBolinha:
		lb $t0, maquina #$t0 = 'O'
		li $t3, JOG	# muda o turno para 1 (xis)
		sw $t3, turno
		ble $s1, 8, subTab	# se a posição do vetor estiver na primeira linha do tabuleiro
		ble $s1, 20, subTab2	# se a posição do vetor estiver na segunda linha do tabuleiro
		j subTab3		# se a posição do vetor estiver na terceira linha do tabuleiro
		
	subTab:
		addi $t4, $s1, 1 # t4 = s3(indice do vetor) + 1
		la $s0, tabuleiro #s0 = *tabuleiro[0]
		add $t1, $s0, $t4  #t1 = *tabuleiro[indice]
		sb $t0, ($t1)  #tabuleiro[indice] = caracter
		jr $ra
		
	subTab2:
		addi $t4, $s1, 12 # t4 = s3(indice do vetor) + 12
		la $s0, tabuleiro #s0 = *tabuleiro[0]
		add $t1, $s0, $t4  #t1 = *tabuleiro[indice]
		sb $t0, ($t1)  #tabuleiro[indice] = caracter
		jr $ra
	
	subTab3:
		addi $t4, $s1, 23 # t4 = s3(indice do vetor) + 23
		la $s0, tabuleiro #s0 = *tabuleiro[0]
		add $t1, $s0, $t4  #t1 = *tabuleiro[indice]
		sb $t0, ($t1)  #tabuleiro[indice] = caracter
		jr $ra
	
	confereVitoria:
		move $t0, $zero #indice do loop
		move $t4, $zero #contador
		la $s0, array	#ponteiro pro array
		li $s1, MAQ	#s1 = MAQ
		li $s2, JOG	#s2 = JOG
		li $s3, HOR	#s3 = 1 (horizontal)		
	vitoriaHoriz:
		beq $t0, 36, sairHor	# se o loop chegar na última casa, sai do loop
		add $t1, $s0, $t0	#t5 = array[indice]
		lw $t5, ($t1)
		addi $t2, $t1, 4	#t6 = array[indice+1]
		lw $t6 ($t2)
		addi $t3, $t2, 4	#t7 = array[indice+2]
		lw $t7, ($t3)
		beq $t5, $s1, aumentaCont # se array[indice] = bolinha
		beq $t5, $s2, aumentaCont # se array[indice] = xis
		return_Cont:
			beq $t5, $t6, aumentaCont2	# se array[indice] = array[indice +1]
		return_Cont2:
			beq $t6, $t7, aumentaCont3	# se array[indice+1] = array[indice+2]
		return_Cont3:
			beq $t4, 3, vencedor # se os três forem iguais, é vitória
			addi $t0, $t0, 12	# se não, passa para a próxima linha
			move $t4, $zero		# zera o contador
		j vitoriaHoriz
	sairHor:
		move $t0, $zero #indice
		move $t4, $zero #contador
		li $s3, VER	#s3 = 2 (vertical)
	vitoriaVer:
		beq $t0, 12, vitoriaDiagP
		add $t1, $s0, $t0	#t5 = array[indice]
		lw $t5, ($t1)
		addi $t2, $t1, 12	#t6 = array[indice+3]
		lw $t6 ($t2)
		addi $t3, $t2, 12	#t7 = array[indice+6]
		lw $t7, ($t3)
		beq $t5, $s1, aumentaCont	# se array[indice] = bolinha
		beq $t5, $s2, aumentaCont	# se array[indice] = xis
		return_ContV:
			beq $t5, $t6, aumentaCont2	# se array[indice] = array[indice+3]
		return_Cont2V:
			beq $t6, $t7, aumentaCont3	# se array[indice+3] = array[indice+6]
		return_Cont3V:
			beq $t4, 3, vencedor	# se os três forem iguais, é vitória
			addi $t0, $t0, 4
			move $t4, $zero
		j vitoriaVer
		
	vitoriaDiagP:
		li $s3, DP	#s3 = 3 (diagonal principal)
		lw $t5, ($s0)		#t5 = array[0]
		addi $t2, $s0, 16	#t6 = array[4]
		lw $t6 ($t2)
		addi $t3, $t2, 32	#t7 = array[8]
		beq $t5, $s1, aumentaCont	# se array[indice] = bolinha
		beq $t5, $s2, aumentaCont	# se array[indice] = xis
		return_ContDP:
			beq $t5, $t6, aumentaCont2
		return_Cont2DP:
			beq $t6, $t7, aumentaCont3
		return_Cont3DP:
			beq $t4, 3, vencedor	# se os três forem iguais, é vitória
			move $t4, $zero
	
	vitoriaDiagS:
		li $s3, DS	#s3 = 4 (diagonal secundaria)
		addi $t1, $s0, 8	#t5 = array[2]
		lw $t5, ($t1)		
		addi $t2, $t1, 8	#t6 = array[4]
		lw $t6 ($t2)
		addi $t3, $t2, 8	#t7 = array[6]
		lw $t7, ($t3)
		beq $t5, $s1, aumentaCont	# se array[indice] = bolinha
		beq $t5, $s2, aumentaCont	# se array[indice] = xis
		return_ContDS:
			beq $t5, $t6, aumentaCont2
		return_Cont2DS:
			beq $t6, $t7, aumentaCont3
		return_Cont3DS:
			beq $t4, 3, vencedor	# se os três forem iguais, é vitória
			move $t4, $zero
		jr $ra
		
	aumentaCont:
		addi $t4, $t4, 1
		beq $s3, HOR, return_Cont
		beq $s3, DP, return_ContDP
		beq $s3, DS, return_ContDS
		j return_ContV
	aumentaCont2:
		addi $t4, $t4, 1
		beq $s3, HOR, return_Cont2
		beq $s3, DP, return_Cont2DP
		beq $s3, DS, return_Cont2DS
		j return_Cont2V
	aumentaCont3:
		addi $t4, $t4, 1
		beq $s3, HOR, return_Cont3
		beq $s3, DP, return_Cont3DP
		beq $s3, DS, return_Cont3DS
		j return_Cont3V
				
	vencedor:
		jal imprimir
		lw $t0, turno
		beq $t0, JOG, vence_maq
		li $v0, 4
		la $a0, vitoria_jog
		syscall
		j sair
	vence_maq:
		li $v0, 4
		la $a0, vitoria_maq
		syscall
		j sair
	empatou:
		li $v0, 4
		la $a0, empate
		syscall					
	sair: 
		li $v0, 10
		syscall

