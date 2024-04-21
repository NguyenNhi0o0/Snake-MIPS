#PARTIE 4 PROJET SNAKE MIPS

.data

image_width:  .word 256      # largeur de l'image en pixels
image_height: .word 256      # hauteur de l'image en pixels
unit_width:   .word 8        # largeur d'une Unit en pixels
unit_height:  .word 8      # hauteur d'une Unit en pixel

message_erreurIndice: .ascii "Erreur d'indice."

espace: .ascii "  "


.text

lw $s0 image_width
lw $s1 image_height
lw $s2 unit_width
lw $s3 unit_height



Fonction_test:
 jal I_creer	#alloue d'abord la m�moire image
 jal F_creer	#alloue le tableau
 li $a0 0x1004006	#exemple d'adresse de pixel  � enfiler
 li $a1 0 	#la taille est intialement � 0
 jal F_enfiler	#enfile le pixel
 
 li $a0 0x1004007	#autre exemple d'adresse de pixel � enfiler
 jal F_enfiler		#enfile le pixel
 
 li $a0 0x1004008	#adresse pixel � enfiler
 jal F_enfiler
 
 li $a0 0x1004009
 jal F_enfiler
 
 jal F_defiler	 #test d�filer => sortie: $v0: adresse;  $a1: taille de la file
 		
 
 jal F_lister
 

 
 j exit


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
    
    
 I_creer:


    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)

    
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
    addi $sp $sp -4
    sw $ra 0($sp)
    
    
    
#Corps
    li $t4 4
    mul $a1 $a1 $t4	#$a1: valeur de la taille en octet
    add $s4 $v0 $a1	#s4: adresse dans le tableau o� on veut ajouter notre pixel
    
    sw $a0 ($s4)	#on enfile le pixel en question dans l'adresse
    div $a1 $a1 $t4	#on retrouve la valeur initiale de $a1 
    addi $a1 $a1 1		#on ajoute un � la taille de la file car elle augmente
    
 # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
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

 # Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra 
    
    
   
   
#retourne la valeur du pixel indiqu� par l'indice: $v0
#arguments:  $a0=> adresse de la file
#	     $a1=> taille de la file 
#	     $a2 => entier repr�sentatn l'indice
#retour: $v0 => valeur du pixel
F_valeurIndice:

# Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
    
    
    
# Corps

    #preconditions
    bltz $a2 pre_valeurIndice		#si i== 0
    bge $a2 $a1 pre_valeurIndice	#si i est plus grand que la taille
    
    #on veut que le d�but du tableau correspond � la queue du sepent et que la fin repr�sente la t�te
    li $t4 4
    mul $a2 $a2 $t4	#multiplication par 4 de l'indice pour avoir en octet
    add $a0 $a0 $a2	#on est maintenant dans l'adresse o� l'on veut le pixel
    lw $v0 ($a0)	#met la valeur du pixel de $a0 dans $v0
    
    j fin_valeurIndice
    
    
    pre_valeurIndice:
    la $a0 message_erreurIndice
    li $v0 4
    syscall
    
        

 # Epilogue
 fin_valeurIndice:
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
    
    

#fonction F_lister: affiche la liste des pixels sur la sortie standard en commen�ant par la queue et en terminant par la t�te
#arguments: #v0: adresse du tableau
	    #a1: taille du serpent
F_lister:

# Prologue
   addi $sp $sp -4
   sw $ra 0($sp)
   
   
#Corps

   move $t0 $v0 	#on met l'adresse dans $t0 pour ne pas la perdre apr�s
   boucle_liste:
   
   lw $t1 ($t0)		#lit le pixel et le met dans t1
   move $a0 $t1
   li $v0 1	
   syscall
   
   la $a0 espace
   li $v0 4
   syscall
   
   addi $t0 $t0 4
   addi $a1 $a1 -1	#compteur 
   bnez $a1 boucle_liste
   
# Epilogue
    lw $ra 0($sp)	
    addi $sp $sp 4
    jr $ra  
   


exit:
	li $v0 10
	syscall
