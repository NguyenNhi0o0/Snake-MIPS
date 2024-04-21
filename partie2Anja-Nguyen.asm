.data
.text
    .globl main
main:
    jal valeur$t0 # chute au programme de partie 2 (3.3)

    li $v0, 10       # code de l'appel système pour la fin du programme
    syscall
valeur$t0:

    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
    
    # corp 
    # Initialisation et configuration des périphériques d'entrée/sortie

    li $t0, 0             # Initialisation du registre $t0
    
    while_loop:

	    # Lecture de l'entrée clavier
	    lw $t3, 0xFFFF0004 # Lecture du registre de données du clavier
	    andi $t3, $t3, 0xFF # Masquage des 24 bits de poids fort pour ne garder que le caractère de l'entrée clavier

	    # Attente de 0.5 seconde
  	    li $v0, 32       # l'appel système pour la pause (en millisecondes)
	    li $a0, 500      # on attend 500ms (0.5s)
	    syscall

	    # Affichage de la valeur de $t0
	    move $a0, $t0      
	    li $v0, 1          
	    syscall            

	    # Traitement de l'entrée clavier
	    beq $t3, 0x70, increment_t0 # Si la touche 'p' est pressée, sauter à la fonction d'incrémentation
	    beq $t3, 0x6F, decrement_t0 # Si la touche 'o' est pressée, sauter à la fonction de décrémentation
	    beq $t3, 0x78, exit_program # Si la touche 'x' est pressée, sortir de la boucle while

	    j while_loop        # Saut au début de la boucle while

	increment_t0:
	    addi $t0, $t0, 1    # Incrémentation de $t0
	    j while_loop        # Saut au début de la boucle while

	decrement_t0:
	    addi $t0, $t0, -1   # Décrémentation de $t0
	    j while_loop        # Saut au début de la boucle while

	exit_program:
	    li $v0, 10          # Chargement du code de la fonction exit dans $v0
	    syscall             # Appel de la fonction exit

     # Epilogue
     end_program:
    	    jr $ra	
	    lw $ra 0($sp)
	    addi $sp $sp 4
 	    jr $ra 