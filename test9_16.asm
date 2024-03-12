.text

main:
	lw $a0, 0xfffffc00 
	j test1
	j test2
	j test3
	j test4
	j test5
	j test6
	

	test1:
	li $v0,5
	syscall
	move $t0,$v0
	blt $t0,0,NegativeCalculateSum
	calculateSum:
		add $t1,$t0,$t1
		subi $t0,$t0,1
		bne $t0,0,calculateSum
	j test1
	NegativeCalculateSum:
		add $t1,$t0,$t1
		addi $t0,$t0,1
		bne $t0,0,NegativeCalculateSum
	j test1
	
	
	################
	
	test2:
	li $v0,5
	syscall
	move $t0,$v0
	calculateSum2:
		addu $t1,$t0,$t1
		subiu $t0,$t0,1
		bne $t0,0,calculateSum2
	j test2	
	
	###############
	
	test3:
	li $v0,5
	syscall
	move $t0,$v0
	calculateSum3:
		addu $t1,$t0,$t1
		subiu $t0,$t0,1
		bne $t0,0,calculateSum2
	j test3	
	
	
	test4:
	li $v0,5
	syscall
	move $t0,$v0
	calculateSum4:
		addu $t1,$t0,$t1
		subiu $t0,$t0,1
		bne $t0,0,calculateSum4
	j test4	
	
	

	test5:
	li $v0,5
	syscall
	move $t0,$v0
	li $v0,5
	syscall
	move $t1,$v0
	add $t2,$t1,$t0
	and $t3,$t2,511
	and $s0,$t0,256
	and $s1,$t1,256
	and $s2,$t2,256
	beq $s0,$s1,overFlowDeter
	j end5
	overFlowDeter:
	bne $s2,$s1,overFlow
	j end5
	overFlow:
	li $s7,1
	j end5
	end5:
	j test5
	
	
	
	
	test6:
	li $v0,5
	syscall
	move $t0,$v0
	li $v0,5
	syscall
	move $t1,$v0
	li $s5,511
	sub $s6,$s5,$t1
	addi $t1,$s6,1
	add $t2,$t1,$t0
	and $t3,$t2,511
	and $s0,$t0,256
	and $s1,$t1,256
	and $s2,$t2,256
	beq $s0,$s1,overFlowDeter2
	j end6
	overFlowDeter2:
	bne $s2,$s1,overFlow2
	j end6
	overFlow2:
	li $s7,1
	j end6
	end6:
	j test6
	
			
	
	
			
				
		
		
				
		
		
		
	
		
	
		
	
				
		
			
	
	
