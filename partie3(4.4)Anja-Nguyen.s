.data

image_width:  .word 256      # largeur de l'image en pixels
image_height: .word 256      # hauteur de l'image en pixels
unit_width:   .word 8        # largeur d'une Unit en pixels
unit_height:  .word 8      # hauteur d'une Unit en pixel

.text
.text
.globl main
main:

lw $s0 image_width
lw $s1 image_height
lw $s2 unit_width
lw $s3 unit_height

    # unit width in Pixels : 8
    # unit Height in Pixel : 8
    # Display width in Pixels : 212
    # Display Height in Pixel : 256
    # Base address for display : 0x10040000 (heap
fonction_test:
jal I_creer
li $a0 6
jal O_creer
jal O_afficher
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




#arguments:   $a0: nombre d'obstacles isol�s qu'on souhaite avoir dans l'ar�ne
#retour:      $v0: adresse du tableau
     
O_creer:

    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
    
    
    #corps
 li $t4 4
 move $t1 $a0     #mettons le nombre d'obstacle dans t1 pour pouvoir la garder prochainement
 jal I_largeur 
 move $t0 $v0  #$t0: largeur
 mul $a0 $t0 $t4  #p�rim�tre
 add $a0 $a0 $t1  #$a0: taille totale du tableau en int
 mul $a0 $a0 $t4    #$a0: taille totale en octet
 
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
    addi $sp $sp 4
    jr $ra  
     

       
     
     
 #focntion: affiche les pixels dzns une couleur particuli�re
 #arguments: $v0 => adresse du tableau	
 #	     $a0 => taille du tableau
 O_afficher:
 
 
    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)


  
  
  # Corps

   li $t0 0x0066cc #s0: couleur bleue
   move $t1 $v0     #t1: adresse du tableau 
   move $t2 $a0    #t2: taille du tableau
   li $t4 0     #compteur
   

   loopAffichage:
   lw $t3 0($t1)		#t3:  adresse du pixel � colorier
   sw $t0 ($t3)
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
    

exit:
	li $v0 10
	syscall
