.data 		#Data segment

enter_string : .asciiz "\nPlease enter a character\n"	#String to be printed
output_string : .asciiz "\nThe final string is:\n"	#String to be printed

result: .space 100
space: .space 100

.text		#Text segment

main:		#Start of code section

la $s0, result			#loading result address to register s0
la $s1, space			#loading space address to register s1
addi $t0,$0, 0 			#value useful for loop

#jal init
jal get_string
jal process_string
jal out_string

li $v0, 10		#exit syscall
syscall			#do the syscall
###############################################################
#init:
#
#	la $a0, enter_string	#load the address of message into a0
#	la $a1, output_string	#load address of output_string in a0
#	la $a2, space		#loading address of space in a0
################################################################
################################################################
get_string:
	la $a0, enter_string	#load the address of message into a0
	li $v0, 4
	syscall

	li $v0, 12		#read_character syscall 
	syscall			#do the syscall
				
	beq $v0,'@', exit	#if input=@ goes to exit
	
	sb $v0, result($t0)	#else stores 0 in the next byte
	addi $t0, $t0, 1	#increases t0, to point to the next byte
	beq $t0,99,exit		#if it surpasses the limit goes to exit
	j get_string		#jump to get_string 

exit:
	addi $t9, $0, 10 	
	sb $t9, result($t0)
	jr $ra
################################################################
process_string:


checkingLoop:			#ascii for exit function
	addi $t9,$0,10

	lb $t1, 0($s0)		
	addi $s0,$s0,1		

	beq $t1, $t9, end_process
	
	beq $t1,' ',store
	
case1:				#searching if byte is a number (ascii code between 47 and 58)
	addi $t4, $s0,58
	slt $t2, $t1, $t4	#searching if byte<58
	bne $t2, $0, number	#if yes, goes to number

number:				#searching if byte>47 so we can consider it number
	addi $t7,$0,47	
	slt $t3, $t7,$t1	#searching if byte>47
	bne $t3,$0, store	#if yes, goes to store
	
	j case2  		#else goes to the next case

case2:				#searching if byte is a capital letter (ascii code between 64 and 91)
	addi $t5,$0,91
	slt $t2, $t1,$t5	#searching if byte<91
	bne $t2,$0, uppercase	#if yes, goes to uppercase 

uppercase:			#searching if byte>64 so we can consider it uppercase letter
	addi $t7,$0,64	
	slt $t3, $t7,$t1	#searching if byte>64
	bne $t3,$0, store	#if yes, goes to store

	j case3			#else goes to the next case

case3:				#searching if byte is a lowercase letter (ascii code between 96 and 123)
	addi $t6,$0,123
	slt $t2,$t1,$t6		#searching if byte<123
	bne $t2,$0, lowercase	#If yes, goes to lowercase

lowercase:			#searching if byte>96 so we can consider it lowercase letter
	addi $t7,$0,96	
	slt $t3, $t7,$t1	#searching if byte>96
	bne $t3,$0, store	#if yes, goes to store

	j end			#else goes to the next case

end:				#if the byte is neither a number nor a letter we repeat the previous process 	
	j checkingLoop		#jumps to checkingLoop
store:				#else we store the byte into space
	sb $t1, 0($s1)
	addi $s1,$s1,1
	j checkingLoop		#jumps to checkingLoop
end_process:
	jr $ra
###############################################################################################
out_string:

	la $a0, output_string	#load address of output_string in a0
	li $v0,4		#print_string syscall
	syscall			#do the syscall

	la $a0, space		#loading address of space in a0
	li $v0,4		#print_string syscall
	syscall			#do the syscall
	jr $ra
