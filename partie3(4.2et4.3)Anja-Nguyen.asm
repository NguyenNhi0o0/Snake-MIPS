.data
.text
.globl main
main:
    # 4.2
    # unit width in Pixels : 1
    # unit Height in Pixel : 1
    # Display width in Pixels : 512
    # Display Height in Pixel : 256
    # Base address for display : 0x10010000 (static data)
#    jal bitmapDisplay # chute au programme de partie 3 (4.2)
    
    # 4.3
    # unit width in Pixels : 8
    # unit Height in Pixel : 8
    # Display width in Pixels : 256
    # Display Height in Pixel : 256
    # Base address for display : 0x10010000 (static data)
    jal grosPixels # chute au programme de partie 3 (4.3)

    li $v0, 10       # code de l'appel système pour la fin du programme
    syscall
    bitmapDisplay:

    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
    
    # Corp 
    # Adresse de début de la mémoire image
    li $t0, 0x10010000
    
    # Entier représentant la couleur rouge
    li $t1, 0x00ff0000
    
    # Nombre d'entiers à écrire (première moitié)
    # Remarquons que cela représente 131072 pixels, donc 131072 entiers 
    # donc pour colorer moitié image, c'est 131072/2 = 65536 entiers à comter dans le boucle
    li $t2, 65536
    
    loop3de4.2:
    	# Stocker la couleur à l'adresse du pixel
    	sw $t1, ($t0)
    
    	# Incrémenter l'adresse
    	addi $t0, $t0, 4
    
   	# Décrémenter le compteur
   	addi $t2, $t2, -1
    
  	# Si le compteur n'est pas nul, retourner au début de la boucle pour colorer encore
  	bne $t2, $zero, loop3de4.2
        
    # Epilogue	
    lw $ra 0($sp)
    addi $sp $sp 4
    jr $ra  

grosPixels:
    # Prologue
    addi $sp $sp -4
    sw $ra 0($sp)
    
    # Corp 
    # Adresse de début de la mémoire image
    li $t0, 0x10010000
    
    # Entier représentant la couleur rouge
    li $t1, 0x00ff0000
    
    # Nombre d'entiers à écrire (première moitié)
    # Il en résulte que chaque ligne sera représentée non plus par 512 enties, mais par 512/8 = 64 entiers. 
    # L’image carré a été obtenue avec une image de 256 × 256 = 65536 pixels et des Units de 8 × 8 pixels.
    # donc c'est 256/8 = 32 entiers de ligne, c'est aussi 32 entiers de colonne, alors 32*32 = 1024 entiers
    # le nombre à compter pour le boucle de coloration moitié l'image est 1024/2 = 512
    
    li $t2, 512
    
    loop3de4.3:
    	# Stocker la couleur à l'adresse du pixel
    	sw $t1, ($t0)
    
    	# Incrémenter l'adresse
    	addi $t0, $t0, 4
    
   	# Décrémenter le compteur
   	addi $t2, $t2, -1
    
  	# Si le compteur n'est pas nul, retourner au début de la boucle pour colorer encore
  	bne $t2, $zero, loop3de4.3
        
    # Epilogue	
    lw $ra 0($sp)
    addi $sp $sp 4
    jr $ra
