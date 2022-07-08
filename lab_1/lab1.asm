	lui	s8, 0xFFFFF		# base address 

	addi	s0, x0, 0x0		# no op
	addi	s1, x0, 0x1		# add op
	addi	s2, x0, 0x2		# sub op
	addi	s3, x0, 0x3		# and op
	addi	s4, x0, 0x4		# or op
	addi	s5, x0, 0x5		# shift left op
	addi	s6, x0, 0x6		# shift right algorithm op
	addi	s7, x0, 0x7		# mul op
		
	# get the xori
	# using to transfer true to comple
	addi	s11, s11, -1
	addi	t0, x0, 1
	slli	t0, t0, 31
	xor	s11, s11, t0	
	
	




calculate:				# calculate
	lw 	s9, 0x70(s8)		# read switch        
	
	andi	t0, s9, 0xff	# get num A
       
        
	srli	t1, s9, 0x8		# get num B
	andi 	t1, t1, 0xff			
					
	srli	t2, s9, 21		# get the op    
	andi 	t2, t2, 7			

	add 	s10, x0, x0		# result

	
	# judge the op
	beq 	t2, s0, noop		
	
    beq 	t2, s7, mulop

	beq 	t2, s3, andop		
	beq 	t2, s4, orop		

	beq 	t2, s5, slop		
	beq 	t2, s6, srop		
		
	
	beq 	t2, s1, addop		
	beq 	t2, s2, subop				

	
	jal		calculate

        
noop:

 	add 	s10, x0, x0
 	jal		display
 	
addop:

	jal 	ra, true2comple 
	add 	s10, t0, t1
 	jal		transfer

subop:
	jal		ra, true2comple
	sub 	s10, t0, t1
	jal		transfer
	
andop:
	and 	s10, t0, t1
	jal		display 	 	 	 	
                      
orop:	
	or 		s10, t0, t1
	jal 	display

slop:
	sll 	s10, t0, t1
	jal 	display 
 
srop:
	andi	t4, t0, 0x80		# get the sign bit
	
	L:	
		beq t1, x0, E
		addi t1, t1, -1			
		srli t0, t0, 1
		add  t0, t0, t4			# add the sign bit 
		
	E:
		add s10, t0, x0
		jal display


  
mulop:
	andi	t4, t0, 0x80		# get the A's sign bit
	andi	t5, t1, 0x80		# get the B's sign bit
	
	andi	t0, t0, 0x7f		# remove A's sign bit
	slli	t0, t0, 7			# shift left 7 bits 
	andi	t1, t1, 0x7f		# remove B's sign bit
	
	addi	a0, x0, 7		# move 7 times
	add		t6, x0, x0		# init count
	LOOP:
		beq 	a0, t6, end	# calculate done?
		addi	t6, t6, 1	# t6++			
		andi	a1, t1, 1	# lowest bit of num b
		beq	a1, x0, zzero	# a1 == 0 ?
		add	s10, s10, t0
		zzero:
		srli	s10, s10, 1	# shift left 1 bit
		srli	t1, t1, 1	# shift left 1 bit
		jal 	LOOP
	end:
		
		xor	t4, t4, t5		# result sign bit
		andi	t4, t4, 0x80
		beq 	t4, x0, positive_mulop	# result positive ?
		addi	t4, x0, 1
		slli	t4, t4, 31
		add	s10, s10, t4
	
	positive_mulop:	
	
		jal 	display                                  

transfer:

	srli	t4, s10, 31 
	beq	t4, x0, positive_result		# result is positive ?
	
	xor	s10, s10, s11
	addi	s10, s10, 1
	
	positive_result:
	jal 	display
                        
true2comple:
	# true code --> complemental code
	
	srli	t5, t0, 7		# get num A the signed
	slli	t4, t5, 31		# to the highest bit
	andi	t0, t0, 0x7f	
	add	t0, t0, t4	
	
	beq 	t5, x0, positive_a	# A is positive ?

	xor	t0, t0, s11		# get the A's complemental code
	addi	t0, t0, 1
	
	positive_a:

	
	srli	t5, t1, 7		# get num B the signed
	slli	t4, t5, 31		# to the highest bit
	andi	t1, t1, 0x7f
	add	t1, t1, t4	
	
	beq 	t5, x0, positive_b	# B is positive ?
	
	xor	t1, t1, s11		# get the B's complemental code
	addi	t1, t1, 1
        
	positive_b:
	  
        jalr x0, 0(ra)          
                                                                      
                                                                                                                                          
display:                         # display
	sw	s10, 0x60(s8)		# write led	
	sw	s10, 0x00(s8)
	jal	calculate

	
	

