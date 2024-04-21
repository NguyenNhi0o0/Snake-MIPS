.data
.text
    .globl main
main:
    jal laPausse # chute au programme de partie 1
    
    li $v0, 10       # code de l'appel système pour la fin du programme
    syscall
laPausse: 

    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
    
    # Corp 
    # Initialisation
    li $t0, 1        # $t0 contient le premier entier à sortir
    li $t1, 10       # $t1 contient le numéro 10 pour conssidérer la condition à sortir 
     
	loop1:
  	    # Affichage de l'entier courant
 	   li $v0, 1        # l'appel système pour l'affichage d'un entier
 	   move $a0, $t0    # on place l'entier courant dans $a0
 	   syscall

	    # Attente de 0.5s
 	   li $v0, 32       # l'appel système pour la pause (en millisecondes)
 	   li $a0, 500      # on attend 500ms (0.5s)
 	   syscall

	    # Incrémentation de l'entier courant
	   addi $t0, $t0, 1 # on incrémente l'entier courant

 	    # Test si l'on doit sortir le prochain entier ou terminer le programme
 	   bgt $t0, $t1, exitPartie1 # si l'entier courant est supérieur au dernier, on sort de la boucle
  	   j loop1           # sinon on continue la boucle
    
	exitPartie1:
    #epilogue
	    lw $ra 0($sp)
	    addi $sp $sp 4
	    jr $ra  #je retourne à l'appel de ma fonction
