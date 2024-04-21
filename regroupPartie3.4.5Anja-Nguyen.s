######################################################################
# 			    Projet Snake                         #
######################################################################
#               Rasamoelina Anjaniaina
#		Phuong Truong Nhi Nguyen			##
######################################################################
#           
#								     #
#       Param�tres Bitmat Display                                    #
#	Unit Width: 8						     #
#	Unit Height: 8						     #
#	Display Width: 256					     #
#	Display Height: 256					     #
#	Base Address for Display: 0x10040000 (heap)		     #
######################################################################






.data

image_width:  .word 256      # largeur de l'image en pixels
image_height: .word 256      # hauteur de l'image en pixels
unit_width:   .word 8        # largeur d'une Unit en pixels
unit_height:  .word 8      # hauteur d'une Unit en pixel

couleur_obstacles: .word 0x0066cc	#bleue
couleur_serpent: .word 0x00ff00		#vert
couleur_fruit: .word 0xcc6611		#orange


.text

lw $s0 image_width
lw $s1 image_height
lw $s2 unit_width
lw $s3 unit_height






#########################################################################
# Repr�sentation Ar�ne et obstacles
########################################################################
creationObstacles:

jal I_creer
li $a0 12	#on met l'obstacle � 3
move $t6 $a0	#$t6 sera valeur du nombre d'obstacles
jal O_creer	#on cr�e les obstacles
move $s5 $v0	#$s5 repr�sentera par la suite la valeur de l'adresse du tableau d'obstacle
lw $v1 couleur_obstacles	#on met la couleur des obstacles
jal O_afficher	#on affiche les obstacles




###################################################################################
# Repr�sentation du fruit
#####################################################################################
Nourriture:


     jal I_largeur
     move $a1 $v0	#0<= abcisse al�atoire <$a1 
     li $v0 42    #appel pour g�n�rer un x al�atoirement
     syscall		#a0 va contenir x de la nourriture
     move $t6 $a0	#t6: x
     syscall  #on g�n�re cette fois y
     move $a1 $a0  #a1= y
     move $a0 $t6      #a0= x
     jal I_coordToAdresse   #adresse de l'abcisse et de l'ordonn�e de la nourriture g�n�r�e automatiquement => $v0: adresse
     
     #on va faire appel � la fonction O_contient pour v�rifier si la nourriture obtenue a le m�me emplacement que les obstacles:
     move $a0 $s5	#$a0: adresse du tableau d'obstacles qui �tait d�j� stock� dans $s5
     move $a1 $s7	#$a1: taille du tableau d'obstacles qui est d�j� stock� dans $s7 lors de la cr�ation de ce tableau
     move $a2 $v0	#adresse al�atoire obtenur grace � I_coordToAdresse
     
     jal O_contient
     beqz $v0 afficheNourriture		#si adresse n'est pas dans les obstacles alors on affiche la nourriture
     j Nourriture			#sinon on g�n�re � nouveau
     
      #on va faire appel � la fonction F_contient pour v�rifier si la nourriture obtenue a le m�me emplacement que l'obstacle
     move $a0 $s4	#adresse de la file dans $a0
     move $a1 $v0	#adresse g�n�r� al�atoirement dans a1
     move $a2 $t8	#taille du serpent
     
     jal F_contient
     beqz $v0 afficheNourriture		#si adresse n'est pas dans le serpent alors on affiche la nourriture
     
     
     afficheNourriture:
     lw $t2 couleur_fruit	#couleur de la nourriture
     sw $t2 ($a2)			#stocke cette couleur dans l'adresse al�atoire obtenue



j deplacementSerpent


#########################################################################
#Repr�sentation du serpent
##############################################################################
snake:

    # Prologue
    addi $sp $sp -8
    sw $ra 0($sp)

jal F_creer	#cr�e le tableau de pixel pour le serpent: $v0=> adresse du tableau
move $s6 $v0	#$s6: adresse du tableau du serpent pour toute la suite du programme
li $a0 16	#x initiale du serpent
li $a1 16	#y initiale du serpent
jal  I_coordToAdresse	#$v0:premier pixel
move $a0 $v0	#$a0: premier pixel pour pouvoir appeler F_enfiler
move $v0 $s6	#$v0: adresse du tableau
li $a1 0	#taille actuelle de la file
jal F_enfiler	#on enfile le premier pixel dans le tableau
move $a0 $a1	#la teille actuelle va �tre dans $a0 car on va appeler O_afficher
move $s4 $a1	#$s4 repr�sentera la taille pour toute la suite du programme
lw $v1 couleur_serpent		#$v1: pixel pour la couleur du serpent
jal O_afficher	#affiche le serpent sur la m�moire image

    lw $ra 0($sp)
    addi $sp $sp 8
    jr $ra

##################################################################################################################
#DEPLACEMENT SERPENT
#####################################################################################################################

deplacementSerpent:

    # Prologue
    addi $sp $sp -8
    sw $ra 0($sp)
    sw $s1 4($sp)
    sw $s2 8($sp)


  #Corps
  jal snake

  test_keyboard:
   li $t4 0xffff0000 	#adresse du RCR dans $t4
  li $t5 0xffff0004 	#adresse du RDR dans $t5
  
  li $v0 32
  la $a0 500
  syscall			#appel syst�me de la pause
  
  lw $t6 ($t4)  #$t6 va recevoir la valeur dans l'adresse 0xffff0000 (initialement 0 car on a pas touch� au clavier)
  andi $t6 $t6 0x0001
  beqz $t6 touche_clavier  # v�rifie si la valeur du RCR est revenue � 0 c�d si on a touch� � une autre touche
  lw $t7 ($t5)  #$t7 re�coit la valeur dans l'adresse 0xffff0004 (la valeur appuy� sur le keyboard)
  
  touche_clavier:
  beq $t7 122 directionHaut	#si touche appuy� vaut z
  beq $t7 113 directionGauche	#si touche appuy� vaut q
  beq $t7 100 directionDroite	#si touche appuy� vaut d
  beq $t7 115 directionBas	#si touche appuy� vaut s
  
  j test_keyboard	#autres touches: aucun effet (le serpent s'arr�te)
  
  directionHaut:
    #si on touche sur la direction haut
    lw $a0 ($s6)	#mettre l'adresse du serpent dans $a0 pour appeler la fonction I_adresseToCoo'rd
  jal I_adresseToCoord	#sortie: $v0=> abcisse     $v1: ordonn�e
  addiu $v1 $v1 -1		#on diminue y car on va � gauche
  move $a0 $v0		#on met x dans $a0 pour pouvoir appeler la fonction I_coordToAdresse
  move $a1 $v1		#de m�me pour y
  jal I_coordToAdresse	#nouveau pixel du serpent dans $v0
  
  
  move $a0 $v0	#on gardera cette nouvelle adresse dans $a0 pour pouvoir utiliser la fonction enfiler
  
  move $v0 $s6		#on va d�filer
  move $a1 $s4	#taille dans a1
  jal F_defiler	
  
  
  move $v0 $s6		#on va faire appel � la fonction O_afficher donc il faut que la nouvelle adresse de la file d�fil�e soit dans $v0
  jal F_enfiler
  
  move $a0 $s4		#$a0 taille du tableau
  lw $v1 couleur_serpent	#couleur du serpent
  jal O_afficher	#affiche le serpent dans sa nouvelle position
  
  j test_keyboard
  
  
   directionGauche:
  #si on touche sur la direction gauche
    lw $a0 ($s6)	#mettre l'adresse du serpent dans $a0 pour appeler la fonction I_adresseToCoo'rd
  jal I_adresseToCoord	#sortie: $v0=> abcisse     $v1: ordonn�e
  addiu $v0 $v0 -1		#on diminue x car on va � gauche
  move $a0 $v0		#on met x dans $a0 pour pouvoir appeler la fonction I_coordToAdresse
  move $a1 $v1		#de m�me pour y
  jal I_coordToAdresse	#nouveau pixel du serpent dans $v0
  
  
  move $a0 $v0	#on gardera cette nouvelle adresse dans $a0 pour pouvoir utiliser la fonction enfiler
  
  move $v0 $s6		#on va d�filer
  move $a1 $s4	#taille dans a1
  jal F_defiler	
  
  
  move $v0 $s6		#on va faire appel � la fonction O_afficher donc il faut que la nouvelle adresse de la file d�fil�e soit dans $v0
  jal F_enfiler
  
  move $a0 $s4		#$a0 taille du tableau
  lw $v1 couleur_serpent	#couleur du serpent
  jal O_afficher	#affiche le serpent dans sa nouvelle position
  
  j test_keyboard
  

  
  
  directionDroite:
  #si on touche sur la direction gauche
  lw $a0 ($s6)	#mettre l'adresse du serpent dans $a0 pour appeler la fonction I_adresseToCoo'rd
  jal I_adresseToCoord	#sortie: $v0=> abcisse     $v1: ordonn�e
  addiu $v0 $v0 1		#on augmente x car on va � droite
  move $a0 $v0		#on met x dans $a0 pour pouvoir appeler la fonction I_coordToAdresse
  move $a1 $v1		#de m�me pour y
  jal I_coordToAdresse	#nouveau pixel du serpent dans $v0
  
  
  move $a0 $v0	#on gardera cette nouvelle adresse dans $a0 pour pouvoir utiliser la fonction enfiler
  
  move $v0 $s6		#on va d�filer
  move $a1 $s4	#taille dans a1
  jal F_defiler	
  
  
  move $v0 $s6		#on va faire appel � la fonction O_afficher donc il faut que la nouvelle adresse de la file d�fil�e soit dans $v0
  jal F_enfiler
  
  move $a0 $s4		#$a0 taille du tableau
  lw $v1 couleur_serpent	#couleur du serpent
  jal O_afficher	#affiche le serpent dans sa nouvelle position
  
  j test_keyboard
  
  
  directionBas:
    #si on touche sur la direction bas
  lw $a0 ($s6)	#mettre l'adresse du serpent dans $a0 pour appeler la fonction I_adresseToCoo'rd
  jal I_adresseToCoord	#sortie: $v0=> abcisse     $v1: ordonn�e
  addiu $v1 $v1 1		#on augmente y car on va en bas
  move $a0 $v0		#on met x dans $a0 pour pouvoir appeler la fonction I_coordToAdresse
  move $a1 $v1		#de m�me pour y
  jal I_coordToAdresse	#nouveau pixel du serpent dans $v0
  
  
  move $a0 $v0	#on gardera cette nouvelle adresse dans $a0 pour pouvoir utiliser la fonction enfiler
  
  move $v0 $s6		#on va d�filer
  move $a1 $s4	#taille dans a1
  jal F_defiler	
  
  
  move $v0 $s6		#on va faire appel � la fonction O_afficher donc il faut que la nouvelle adresse de la file d�fil�e soit dans $v0
  jal F_enfiler
  
  move $a0 $s4		#$a0 taille du tableau
  lw $v1 couleur_serpent	#couleur du serpent
  jal O_afficher	#affiche le serpent dans sa nouvelle position
  
  j test_keyboard
  
   j exit
    # Epilogue	
    lw $ra 0($sp)
    lw $s0 4($sp)
    addi $sp $sp 8
    jr $ra



###############################################################################################################
#FONCTIONS
###################################################################################################################

I_largeur:
    # Prologue
    addi $sp $sp -8
    sw $ra 0($sp)
    sw $s0 4($sp)# largeur
    
    #corps
    div $s0 $s0, $s2              # Diviser la largeur de l'image par la largeur d'une Unit
    move $v0 $s0

    # Epilogue	
    lw $ra 0($sp)
    lw $s0 4($sp)
    addi $sp $sp 8
    jr $ra
    
    
I_hauteur:
    # Prologue
    addi $sp $sp -8
    sw $ra 0($sp)
    sw $s1 4($sp)# hauteur de l'image 

   
    div $s1 $s1, $s3              # Diviser la largeur de l'image par la largeur d'une Unit
   
   move $v0 $s1
    
                          
    
    # Epilogue	
    lw $ra 0($sp)
    lw $s1 4($sp)
    addi $sp $sp 8
    jr $ra


#fonction qui alloue la m�moire image 
#retour: $v0 => contient l'adresse de la m�moire allou�e

I_creer:


    # Prologue
    addi $sp $sp -20
    sw $ra 0($sp)
    sw $s0 4($sp) # image_width
    sw $s1 8($sp) # image_height
    sw $s2 12($sp) # unit_width
    sw $s3 16($sp) # unit_height
    
    #corps
    
    li $t4 4
    jal I_largeur
    move $t0 $v0 	#$t0: largeur de l'image
    jal I_hauteur
    move $t1 $v0 	#$t1: hauteur de l'image
    mul $a0 $t0 $t1 	#$a0: nombre total de pixel que l'on veut allouer
    mul $a0 $a0 $t4	#$a0: pixel * 4
    
    li $v0 9
    syscall	#une fois syscall appel�, $v0 contient automatiquement l'adresse de la m�moire allou�e
    		#cette adresse est le heap dans bitmat display
    		
    move $gp $v0  #l'adresse va �tre stock�e danq gp pour qu'on puisse la retrouver facilement
    		
    
    
    # Epilogue
    lw $ra 0($sp)
    lw $s0 4($sp)
    lw $s1 8($sp)
    lw $s2 12($sp)
    lw $s3 16($sp)	
    addi $sp $sp 20
    jr $ra  
    
    
    
    
 #fonction I_coordToAdresse
 # argument: $a0 => abcisse
 # 	     $a1 => ordonn�e
 # retour: $v0 => adresse de l'entier dans la m�moire image associ�e.
 
 I_coordToAdresse:
   

    # Prologue
    addi $sp $sp -20
    sw $ra 0($sp)
    sw $s0 4($sp) # image_width
    sw $s1 8($sp) # image_height
    sw $s2 12($sp) # unit_width
    sw $s3 16($sp) # unit_height
    
   
   #corps
 
    jal I_largeur	# on va d'abord calculer la valeur de la largeur qui va �tre retourn�e par $v0
    li $t4 4
    mul $v0 $v0 $a1 	#la valeur de la largeur va �tre multipli�e par l'ordonn�e pour avoir la position verticalement
    add $v0 $v0 $a0	#abcisse rajout�e
    mul $v0 $v0 $t4	#on multiplie par quatre pour que ce soit en octet
    add $v0 $gp	$v0	#on rajoute ici par le pointeur du d�but de la m�moire 
 
    
    # Epilogue
    lw $ra 0($sp)
    lw $s0 4($sp)
    lw $s1 8($sp)
    lw $s2 12($sp)
    lw $s3 16($sp)	
    addi $sp $sp 20
    jr $ra  
    
    
    
 # argument: $a0 => adresse d'un entier dans la m�moire image
 # retour: $v0 => abcisse
#	   $v1 => ordonn�e

 I_adresseToCoord:

    # Prologue
    addi $sp $sp -20
    sw $ra 0($sp)
    sw $s0 4($sp) # image_width
    sw $s1 8($sp) # image_height
    sw $s2 12($sp) # unit_width
    sw $s3 16($sp) # unit_height

    #corps
   jal I_largeur    #valeur de la largeur dans $v0
   sub $a0 $a0 $gp  #on va enlever le pointeur de l'adresse de la m�moire image pour pouvoir calculer correctement
   li $t0 4
   move $t2 $v0		# t2: largeur
   divu $a0 $a0 $t0    #on divise par 4 pour obtenir la valeur sans octet
   divu $v1 $a0 $t2 	#on fait la division enti�re de l'adresse par la largeur pour obtenir l"ordonn�e
   
   #on cherche ici le reste de la division pr�c�dente. ce qui nous permet d'obtenir l'abcisse
   mul $t1 $v1 $t2 	#$t1: ordonn�e * largeur	
   sub $v0 $a0 $t1     #$v0: reste
   
    # Epilogue
    lw $ra 0($sp)
    lw $s0 4($sp)
    lw $s1 8($sp)
    lw $s2 12($sp)
    lw $s3 16($sp)	
    addi $sp $sp 20
    jr $ra  
    
    
    
## Fonction I_Plot: $a0 abcisse
		    #a1 ordonn�e
		    #$a2 couleur
I_Plot:
    # Prologue
    addi $sp $sp -8
    sw $ra 0($sp)
    sw $s4 4($sp)
    	    
	jal I_coordToAdresse	#change les coordonn�es en adresse
	add $v0 $gp $v0		#l'adresse enregistr� apr�s I_creer ($gp) va �tre additionn� par l'adresse de x et y
	sw $a2 ($v0)		#on met la couleur dans l'adresse correspondante

     # Epilogue
    lw $ra 0($sp)
    lw $s4 4($sp)	
    addi $sp $sp 8
    jr $ra  




#arguments:   $a0: nombre d'obstacles isol�s qu'on souhaite avoir dans l'ar�ne
#retour:      $v0: adresse du tableau
     
O_creer:

    # Prologue
    addi $sp $sp -8
    sw $ra 0($sp)
    sw $s4 4($sp)
    
    
    #corps
 li $t4 4
 move $t1 $a0     #mettons le nombre d'obstacle dans t1 pour pouvoir la garder prochainement
 jal I_largeur 
 move $t0 $v0  #$t0: largeur
 mul $a0 $t0 $t4  #p�rim�tre
 add $a0 $a0 $t1  #$a0: taille totale du tableau en int
 move $s7 $a0	#stockons cette taille dans $s7 pour pouvoir l'utiliser tout au long du programme
 mul $a0 $a0 $t4    #$a0: taille totale en octet du tableau
 
 li $v0 9
 syscall
     
  move $t2 $v0  #$t2: adresse du tableau
  move $t3 $a0  #$t3: taille totale du tableau 
  div $t3 $t3 $t4	#$t3: taille en entier
  
   move $s4 $t2   #s4: position dans le tableau (initialement, c'est l'adresse du tableau)

 #stockons les obstacles dans le tableau:
     li $t5 1  #compteur
     loopObstacles:
     li $v0 42    #appel pour g�n�rer un x al�atoirement
     addi $a1 $t0 -2    #donc 0<=$a0<$a1. On a diminuer par deux la largeur pour que les obstacles ne touchent pas les bornes (ex: si x= 31)
     syscall		#a0 va contenir x
     addi $a0 $a0 1	#$a0 (nombre obtenu al�atoirement) qui est x va s'incr�menter afin de ne pas toucher aux bornes. Ex: si x=0 
     move $t6 $a0	#t6: x
     
     syscall  #on g�n�re cette fois y
     addi $a1 $a0 1   #a1= y
     move $a0 $t6      #a0= x
       
     jal I_coordToAdresse   #adresse de l'abcisse et de l'ordonn�e de l'obstacle g�n�r�e automatiquement
     sw $v0 0($s4)	#on stocke l'adresse du pixel concernant dans la postion actuelle du tableau
     
     addi $t5 $t5 1   #incr�mentation du compteur
     addi $s4 $s4 4   #passe � l'adresse du tableau suivant
     
     bge $t1 $t5 loopObstacles		#si compteur n'est pas �gale au nbre d'obstacles
     
     
     li $a1 0	#valeur initiale de y qui va s'incr�menter � chaque fois
     loopBordDroite:
     addi $a0 $t0 -1  #valeur intiale de x est la largeur (elle restera la m�me)
     jal I_coordToAdresse	#on convertit l'abcisse et l'ordonn�e en adresse (contenu dans $v0)
     sw $v0 0($s4)	#on stocke l'adresse du pixel concernant dans le tableau
     addi $s4 $s4 4	#incr�mente s4 � 4 pour passer � l'adresse du tableau suivant
     addi $a1 $a1 1  #on passe � la prochaine ligne => y+1
     bne $t0 $a1 loopBordDroite	#si x n'est pas �gale � la largeur, on refait la boucle
     
     
     li $a0 0  #valeur initiale de x qui va s'incr�menter � chaque fois
     loopBordBas:
     addi $a1 $t0 -1	#valeur initale de y est la hauteur du pixel car on se trouve en bas (elle restera la m�me)
     jal I_coordToAdresse	#on convertit l'abcisse et l'ordonn�e en adresse (contenu dans $v0)
     sw $v0 0($s4)	#on stocke l'adresse du pixel concernant dans le tableau
     addi $s4 $s4 4	#incr�mente s4 � 4 pour passer � l'adresse du tableau suivant
     addi $a0 $a0 1  #on passe � la prochaine colonne => x+1
     bne $t0 $a0 loopBordBas	#si x n'est pas �gale � la largeur, on refait la boucle
     
     
     li $a0 0	#valeur initiale de x qui va s'incr�menter � chaque fois
     loopBordHaut:
     li $a1 0  #valeur intiale de y est 0 (elle restera la m�me)
     jal I_coordToAdresse	#on convertit l'abcisse et l'ordonn�e en adresse (contenu dans $v0)
     sw $v0 0($s4)	#on stocke l'adresse du pixel concernant dans le tableau
     addi $s4 $s4 4	#incr�mente s4 � 4 pour passer � l'adresse du tableau suivant
     addi $a0 $a0 1  #on passe � la prochaine colonne => x+1
     bne $t0 $a0 loopBordHaut	#si x n'est pas �gale � la largeur, on refait la boucle
     
     
     li $a1 0   #valeur de d�part de y
    loopBordGauche:     
     li $a0 0   #valeur de d�part de x (reste la m�me)
     jal I_coordToAdresse	#on convertit l'abcisse et l'ordonn�e en adresse (contenu dans $v0)
     sw $v0 0($s4)	#on stocke l'adresse du pixel concernant dans le tableau
     addi $s4 $s4 4	#incr�mente s4 � 4 pour passer � l'adresse du tableau suivant
     addi $a1 $a1 1  #on passe � la prochaine ligne => y+1
     bne $s0 $a1 loopBordGauche	 #si y n'est pas �gale � la hauteur, on refait la boucle


     

     move $v0 $t2   #adresse du tableau retourn�e dans $v0
     move $a0 $t3   #taille du tableau dans $a0
       
     
    # Epilogue
    lw $ra 0($sp)
    lw $s4 4($sp)	
    addi $sp $sp 8
    jr $ra  
     

       
     
     
 #focntion: affiche les pixels dzns une couleur particuli�re
 #arguments: $v0 => adresse du tableau	
 #	     $v1 => couleur 
 #	     $a0 => taille du tableau
 O_afficher:
 
 
    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)


  
  
  # Corps

   move $t1 $v0     #t1: adresse du tableau 
   move $t2 $a0    #t2: taille du tableau
   li $t4 0     #compteur
   

   loopAffichage:
   lw $t3 0($t1)		#t3:  adresse du pixel � colorier
   sw $v1 ($t3)		#met la couleur dans l'adresse de pixel
   addi $t4 $t4 1   #on incr�mente le compteur par 4
   addi $t1 $t1 4 #on  passe � l'adresse suivante
   bne $t2 $t4 loopAffichage
   
   	
   
   
    # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra  
    
    
#0_contient: fonction qui d�termine si un pixel appartient au tableau
#arguments: $a0: adresse de tableau de pixel
#	    $a1: nombre d'�l�ments du tableau
#	    $a2: pixel en question

O_contient:

    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
	
#corps
  boucle:
  lw $t1 ($a0)	#t1: la valeur dans l'�l�ment i du tableau
  beq $a2 $t1 contient   #si  pixel == tab[i]
  addi $a0 $a0 4	#incr�mente 4 � l'adresse
  addi $a1 $a1 -1  #d�cr�menter le compteur (nombre d'�l�ments du tableau)
  bnez $a1 boucle #si != 0 alors on refait la boucle
  
  contient_pas:
  li $v0 0
  j finO_contient
  
  contient:
  li $v0 1
  j finO_contient


  finO_contient:
    # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra  
    
    
    
    
# F_creer: alloue l'espace m�moire pour le serpent
#retour: $v0=> adresse de l'espace allou�
    
F_creer:

# Prologue
    addi $sp $sp -4
    sw $ra 0($sp)

    li $t4 4
    jal I_largeur
    move $a0 $v0
    mul $a0 $a0 $a0
    mul $a0 $a0 $t4        #a0: taille d'un nouveau tableau qu'on alloue

    li $v0 9	#appel systeme
    syscall 	#$v0: adresse du tableau allou�
    
    li $s4 0	#la file a une taille 0

 # Epilogue
   
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra 
    
    
    
    
#F_enfiler: enfiler un �l�ment suppl�mentaire dans le tableau
#arguments: $v0=> adresse de la file
#	    $a0=> nouveau pixel � mettre dans la file
#	    $a1=> taille actuelle de la file
#retour: nouveau file avec �l�ment suppl�mentaire correspondant � la t�te

F_enfiler:

# Prologue
    addi $sp $sp -8
    sw $ra 0($sp)

    
    
    
#Corps
    li $t4 4
    mul $a1 $a1 $t4	#$a1: valeur de la taille en octet
    add $s4 $v0 $a1	#s4: adresse dans le tableau o� on veut ajouter notre pixel
    
    sw $a0 ($s4)	#on enfile le pixel en question dans l'adresse
    div $a1 $a1 $t4	#on retrouve la valeur initiale de $a1 
    addi $a1 $a1 1		#on ajoute un � la taille de la file car elle augmente
    move $s4 $a1		#variable globale repr�sentant la taille
    
    
 # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 8
    jr $ra 









#F_defiler: raccourcit la file en supprimant la queue du serpent
#arguments: $v0 => adresse de la file
#	    $a1 => taille de la file	   

F_defiler:

# Prologue
    addi $sp $sp -4
    sw $ra 0($sp)

#Corps
    addi $v0 $v0 4	#l'adresse du tableau sera celui de l'adresse du deuxi�me �l�ment au retour
    addi $a1 $a1 -1	#la taille diminuera au retour
    move $s4 $a1	#on met la valeur de la taille dans la varaible globale
    move $s6 $v0	#pareille pour la nouvelle adresse

 # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra 
    
    
    
    
    
    
    
 #F_contient: d"termine si un pixel appartient au serpent
#arguments: $a0 adresse de la file
#	    $a1: pixel en question
#	    $a2: taille du serpent

F_contient:

# Prologue
addi $sp $sp -4
sw $ra 0($sp)
	
#corps
  boucle1:
  lw $t1 ($a0)	#t1: la valeur dans l'�l�ment i du tableau
  beq $a1 $t1 appartient   #si  pixel == tab[i]
  addi $a0 $a0 4	#incr�mente 4 � l'adresse
  addi $a2 $a2 -1  #d�cr�menter le compteur (nombre d'�l�ments du tableau)
  bnez $a2 boucle1 #si != 0 alors on refait la boucle
  
  appartient_pas:
  li $v0 0
  j finF_contient
  
  appartient:
  li $v0 1
  j finF_contient


  finF_contient:
    # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra  





exit:
	li $v0 10
	syscall
