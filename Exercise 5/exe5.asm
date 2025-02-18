.data     # Data declaration section
# Strings to be printed: 
choice_message: .asciiz "\n###################################################################
\nPlease determine operation, entry (E), inquiry (I) or quit (Q): "
wrongChoice_message: .asciiz "\nSorry, no such operation exists. Please try again!\n"
entryNumber_message: .asciiz "\n\nPlease enter the entry number you wish to retrieve (from 0-9): "
entryNumber2_message: .asciiz "\n\nPlease enter entry number (0-9): "
wrongEntry_message: .asciiz "\nEntry should be an one-digit number! Please try again: "
emptyEntry_message: .asciiz "\nThere is no such entry in the phonebook "
lastName_message: .asciiz "\n\nPlease enter last name: "
firstName_message: .asciiz "\nPlease enter first name: "
phoneNumber_message: .asciiz "\nPlease enter phone number: "
finishedEntry_message: .asciiz "\nThank you, the new entry is the following: \n\n         "
printingEntry_message: .asciiz "\n\nThe number is: \n\n         "     
terminating_message: .asciiz "\n\n!program terminated! "

entries_buffer: .align 2             # aligns the next instruction on a byte that is a multiple of 4
               .space 600           # buffer for phonebook

.text                               # Assembly language instructions go in text segment
main:                               # Start of code section 

la $s0, entries_buffer               # $s0 = address of the start of input_space
li $s4, 4                           # copy the number 4 to $s4    

# initialization of entries_buffer to 0

    move $t0, $s0                   # $t0= start of address of entries_buffer
    addi $t1,$t0,599                # $t1= end of address of entries_buffer
    li $t2, 0                      # $t2= 0000

    initSpace:                      # loop for initialization 

          sw   $t2, 0($t0)          # store 0000 in address 0 + $t0 
          addi $t0, $t0, 4          # pointer of entries_buffer ($t0) points to the start of the next word 
          blt $t0, $t1, initSpace   # if pointer $t0 has not exceeded $t1 go to loop 'initSpace'

main_loop:                          
    jal Prompt_User                 # make $ra=PC+4 and then jump to subroutine 'Prompt_User' 
    beq $v0, 81, Quit 			    # if ($v0==Q) go to label 'Quit'
    beq $v0, 69, Entry 			    # else if ($v0==E) go to label 'Entry'
    b Print     		            # else go to label Print
        
    Entry:
        jal Get_Entry               # make $ra=PC+4 and then jump to subroutine 'Get_Entry' 
        j main_loop                 # jump to 'main_loop'

    Print:
        la $a2,entryNumber_message  # pass address of entryNumber_message as an argument for 'Check_EntryNumber'
        jal Check_EntryNumber       # make $ra=PC+4 and then jump to subroutine 'Check_EntryNumber'
        
        la $a1,printingEntry_message# argument for 'Print_Entry': $a1 = address of printingEntry_message
        move $a2, $v0               # pass the entry_number that 'Check_EntryNumber' returned as an arg for 'Print_Entry' 
        jal Print_Entry             # make $ra=PC+4 and then jump to subroutine 'Print_Entry' 
        
        j main_loop                 # jump to 'main_loop'

    Quit:
        li $v0,4                    # system call code for printing string = 4 
        la $a0, terminating_message # load address of string to be printed into $a0
        syscall                     # call operating system to perform operation specified in $v0

        li $v0, 10                  # system call code to terminate the program         
        syscall                     # call operating system to perform operation specified in $v0

Prompt_User:

    prompt_loop:
        li $v0, 4                   # system call code for printing string = 4 
        la $a0,choice_message       # load address of string to be printed into $a0
        syscall                     # call operating system to perform operation specified in $v0

        li $v0, 12                  # system call code for reading character = 12 
        syscall                     # call operating system to perform operation specified in $v0

        beq $v0,69, return          # if ($v0==E)by ASCII 69=E go to label 'return'
        beq $v0,73, return          # else if ($v0==I)by ASCII 73=I go to label 'return'
        beq $v0,81, return          # else if ($v0==Q)by ASCII 81=Q go to label 'return'

        li $v0, 4                   # system call code for printing string = 4 
        la $a0,wrongChoice_message  # load address of string to be printed into $a0
        syscall                     # call operating system to perform operation specified in $v0
        j  prompt_loop              # else jump to label 'prompt_loop'

    return: jr $ra                  # jump to the address that is contained in register $ra

Get_Entry:

    addi $sp, $sp, -16              # adjust stack for 4 items
    sw $ra, 0($sp)                  # push return address in stack
    
    la $a2,entryNumber2_message     # pass address of entryNumber2_message as an argument for 'Check_EntryNumber'
    jal Check_EntryNumber           # make $ra=PC+4 and then jump to subroutine 'Check_EntryNumber' 
    move $t0,$v0                    # $t0=entry number

    sw $t0, 4($sp)                  # push entry number in stack

    #Entry_address = Telephone_base_address + 60 X entry_number
    li $t1, 60                      # $t1=60
    mul $t1,$t1,$t0                 # $t1= 60 X entry_number
    add $t1, $s0, $t1               # $t1 = entry address
    
    sw $t1, 8($sp)                  # push entry address in stack

    lw $a0, 8($sp)                  # load entry address as an argument for subroutine: Check_if_entryExists
    jal Check_if_entryExists        # make $ra=PC+4 and then jump to subroutine 'Check_if_entryExists' 
    # return value of 'Check_if_entryExists':
    # v0=-1 if there isn't a previous entry in this entry address 
    # else v0=1

    sw $v0, 12($sp)                 # push value of $v0 in stack

    lw $a2, 8($sp)                  # load into $a2 the entry address as an argument for subroutine: Get_Last_Name
    jal Get_Last_Name               # make $ra=PC+4 and then jump to subroutine 'Get_Last_Name'

    lw $t1, 8($sp)                  # load into $t1 the entry address 
    add $a2,$t1,20                  # pass $a2=entry_address+20 as an argument for subroutine: Get_First_Name
    jal Get_First_Name              # make $ra=PC+4 and then jump to subroutine 'Get_First_Name'

    lw $t1, 8($sp)                  # load into $t1 the entry address 
    add $a2,$t1,40                  # pass $a2=entry_address+40 as an argument for subroutine: Get_Number
    jal Get_Number                  # make $ra=PC+4 and then jump to subroutine 'Get_Number'

    lw $a0, 8($sp)                  # load into $a0 the entry address as an argument for subroutine: Edit_Entry
    lw $a1, 12($sp)                 # load into $a1 the number 1 if there IS a previous entry, else load number -1
    li $a2,3                        # load into $a2 how many fields of 20 bytes to edit
                                    # in this case the fields are : First_Name, Last_name, Number
    jal Edit_Entry                  # make $ra=PC+4 and then jump to subroutine 'Edit_Entry'

    la $a1,finishedEntry_message    # $a1 = address of printingEntry_message  
    lw $a2, 4($sp)                  # load into $a2 the entry number as an argument for subroutine: Print_Entry
    jal Print_Entry                 # make $ra=PC+4 and then jump to subroutine 'Print_Entry'
    
    lw $ra, 0($sp)                  # pop return address from stack
    addi $sp, $sp, 16               # removing unused space

jr $ra                              # return to main programm

Get_Last_Name:
    li $v0, 4                   # system call code for printing string = 4 
    la $a0,lastName_message     # load address of string to be printed into $a0
    syscall                     # call operating system to perform operation specified in $v0

    li $v0, 8                   # system call code for reading string = 8 
    move $a0,$a2                # copy to $a0 the starting address in memory to store the string for last_name
    li $a1,20                   # $a1 = (max string's length) = 20 bytes
    syscall                     # call operating system to perform operation specified in $v0
jr $ra                          # jump to the address that is contained in register $ra

Get_First_Name: 
    li $v0, 4                   # system call code for printing string = 4 
    la $a0,firstName_message    # load address of string to be printed into $a0
    syscall                     # call operating system to perform operation specified in $v0

    li $v0, 8                   # system call code for reading string = 8 
    move $a0,$a2                # copy to $a0 the starting address in memory to store the string for first_name
    li $a1,20                   # $a1 = (max string's length) = 20 bytes
    syscall                     # call operating system to perform operation specified in $v0
jr $ra                          # jump to the address that is contained in register $ra

Get_Number:
    li $v0, 4                   # system call code for printing string = 4 
    la $a0,phoneNumber_message  # load address of string to be printed into $a0
    syscall                     # call operating system to perform operation specified in $v0

    li $v0, 8                   # system call code for reading string = 8 
    move $a0,$a2                # copy to $a0 the starting address in memory to store the string for phone_number
    li $a1,20                   # $a1 = (max string's length) = 20 bytes
    syscall                     # call operating system to perform operation specified in $v0
jr $ra                          # jump to the address that is contained in register $ra

Edit_Entry:

    big_loop:
        beq $a2,0,exit_bigloop              # if we have edited every field go to 'exit_bigloop'. Else do the follownig:
        li $t0, 0                           # $t0 is a counter for the number of chars of each field's string
        li $t5, 4                           # $t5 is a counter for how many bits we shift right
        move $t6,$a0                        # $t6 is a pointer for each field 
        loop2:

            bne $t5,4,getLastByte           # if ($t5==4) do the following. Else go to 'getLastByte'
            lw $t1, 0($t6)                  # load word from address 0 + $t6 into $t1
            addi $t6,$t6,4                  # $t6 = $t6 + 4 -> pointer for field's string points to the start of the next word
            li $t5,0                        # reinitialise srl_counter to 0 
            
            getLastByte: 
                andi $t2, $t1, 0x0000FF	    # last byte of word goes to $t2
                srl $t1,$t1,8               # shifts the word right 8 bits ( one byte )
                addi $t5,$t5,1              # srl_counter++

            beq $t2, 10, out2               # if ( $t2==<newline> ) go to 'out2'. Else do the following: 

            # Following code is to check whether we will keep or not the character from $t2.
            # Remember our edited string is identical to the initial one except for the char <\n> that will be replaced with <space>

            bne $t2,10,keepByte             # if (char != <newline>) go to label 'keepByte'.Else do the following:
            j loop2                         # jump to label 'loop2'

            keepByte:
                rem $t4,$t0,$s4             # $t4= reminder of (numOfChars_counter/4)
                bne $t4,0,keepNext3Bytes    # if ($t4==0) do the following. Else go to keepNext3Bytes
                move $t3, $t2               # copy char from $t2 to $t3 
                addi $t0, $t0, 1            # numOfChars_counter ++
                j loop2                     # jump to label 'loop2'

                keepNext3Bytes:
                    addi $t0, $t0, 1        # numOfChars_counter ++
                    sll $t4,$t4,3           # $t4 = $t4 * 2^3 = $t4 * 8 
                    sllv $t2,$t2,$t4        # shift $t3 left for ($t4/8) bytes
                    or $t3, $t3, $t2        # copy character from $t2 to $t3

                    rem $t4, $t0,$s4        # $t4= remainder of (numOfChars_counter/4)
                    beq $t4, 0, storeWord2  # if ($t4==0) go to storeWord2. Else do the following:
                    j loop2                 # jump to label 'loop2'

            storeWord2:
                sw $t3, -4($t6)             # store the word from $t3 to the address: -4 + $t6 
                j loop2                     # jump to label 'loop2'

        out2:
            li $t2,32                       # $t2=000<space>
            rem $t4, $t0,$s4                # $t4= remainder of (numOfChars_counter/4)
            beq $t4,0,finalStore            # if ($t4==0) go to 'finalStore'. Else do the following:
            sll $t4,$t4,3                   # $t4 = $t4 * 2^3 = $t4 * 8 
            sllv $t2,$t2,$t4                # shift $t2 left for ($t4/8) bytes
            or $t2, $t3, $t2                # copy character from $t3 to $t2 

            finalStore:
                sw $t2,-4($t6)              # store the word from $t2 to the address: -4 + $t6

        add $a0,$a0,20                      # $a0 points at the start of the NEXT field
        beq $a1,-1,editNextField            # if a1=-1 go to 'editNextField'. Else do the following:

        # after the char <space> in the string, we fill the field with zeros 
        # to ensure that the string of our entry isn't mixed with characters of the previous entry in memory
        zero_padding:
            beq $t6,$a0,editNextField       # if the pointer of field's string reaches the start of the next field (=starting address of previous field + 20)
                                            # go to label 'editNextField'. Else do the following:
            sw $zero, 0($t6)                # store '0000' to the address 0 + $t6 
            add $t6,$t6,4                   # $t6 = $t6 + 4 -> pointer of field's string points to the start of the next word
            j zero_padding                  # jump to label 'zero_padding'

        editNextField:
            add $a2,$a2,-1                  # we just adited one field out of $a2. So, $a2--
    j big_loop                              # jump to label 'big_loop'

exit_bigloop:
jr $ra                                      # jump to the address that is contained in register $ra        

Check_EntryNumber:

    outOfBounds:
        li $v0, 4                     # system call code for printing string = 4 
        move $a0,$a2                  # copy the address of the string to be printed from $a2 to $a0
        syscall                       # call operating system to perform operation specified in $v0

        li $v0, 12                    # system call code for reading character = 12 
        syscall                       # call operating system to perform operation specified in $v0
        move $t0,$v0                  # $t0= the entry the user just gave

        blt $t0,48,wrong              # if ($t0<48) jump to label 'wrong'. Else do the following:
        bgt $t0,57,wrong              # else if ($t0>57) jump to label 'wrong'. Else do the following: 

        addi $t0,$t0,-48              # changes the entry from ascii character to number
        move $v0,$t0                  # returns entry number via $v0
        jr $ra                        # jump to the address that is contained in register $ra

        wrong:
            li $v0, 4                 # system call code for printing string = 4 
            la $a0,wrongEntry_message # load address of string to be printed into $a0
            syscall                   # call operating system to perform operation specified in $v0

        j outOfBounds                 # jump to label 'outOfBounds'

Print_Entry:

    addi $sp, $sp, -16          # adjust stack for 4 items
    sw $ra, 0($sp)              # push return address in stack

    move $t0,$a2                # copy entry number to $t0
    
    #Entry_address = Telephone_base_address + 60 X entry_number
    li $t1, 60                  # $t1=60
    mul $t1,$t1,$t0             # $t1= 60 X entry_number
    add $t1, $s0, $t1           # $t1 = entry address

    sw $t0, 4($sp)              # push entry_number in stack
    sw $t1, 8($sp)              # push entry_address in stack
    sw $a1, 12($sp)             # push address of message to be printed in stack

    move $a0, $t1               # pass $a0(=entry_address) as an argument for subroutine: Check_if_entryExists
    jal Check_if_entryExists    # make $ra=PC+4 and then jump to subroutine 'Check_if_entryExists'
    move $t2,$v0                # copy the returned value of 'Check_if_entryExists' to $t2

    lw $a1, 12($sp)             # pop from stack
    lw $t1, 8($sp)              # pop from stack
    lw $t0, 4($sp)              # pop from stack

    beq $t2,-1,noEntry_print    # if there ISN'T an entry in the given address go to 'noEntry_print'. Else do the following:
    
    li $v0,4                    # system call code for printing string = 4 
    move $a0,$a1                # copy the address of the string to be printed from $a1 to $a0
    syscall                     # call operating system to perform operation specified in $v0

    li $v0,1                    # system call code for printing an integer = 1 
    move $a0,$t0                # copy the entry_number to $a0
    syscall                     # call operating system to perform operation specified in $v0

    li $v0,11                   # system call code for printing a character = 11
    li $a0,32                   # $a0 = <space>
    syscall                     # call operating system to perform operation specified in $v0

    # print last name
    li $v0,4
    move $a0, $t1               # copy entry_address from $t1, to $a0
    syscall
    
    # print first name
    add $a0, $t1,20             # $a0 = entry_address + 20
    syscall
    
    # print number
    add $a0, $t1,40             # $a0 = entry_address + 40
    syscall

    j exit_printEntry           # jump to label 'exit_printEntry'

    noEntry_print:
        li $v0,4
        la $a0,emptyEntry_message
        syscall
        
        exit_printEntry:
        lw $ra, 0($sp)          # pop return address from stack
        addi $sp, $sp, 16       # removing unused space

jr $ra                          # jump to the address that is contained in register $ra

Check_if_entryExists:

    lw $t0,0($a0)               # load the first word from the entry_address into $t0
    bne $t0,0x00000000,exists   # if ($t0!=0000) go to label 'exists'. Else do the following:
 
    li $v0,-1                   # no existing entry in the given address, so return: $v0=-1
    jr $ra                      # jump to the address that is contained in register $ra

    exists:
    li $v0,1                    # entry exists in this given address, so return: $v0=1
jr $ra                          # jump to the address that is contained in register $ra