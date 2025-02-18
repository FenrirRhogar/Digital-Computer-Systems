.data
buffer:     .space 100      # δέσμευση χώρου για 100 bytes
input_msg:  .asciiz "\nPlease Enter your Character:\n"
output_msg: .asciiz "\nThe String is:\n"

.text
main:
    addi $t0, $0, 0	# αρχικοποίηση δείκτη $t0 για το loop της καταγραφής

input_loop:
    # Εκτύπωση του μηνύματος "Please Enter your Character:"
    li $v0, 4	# syscall για εκτύπωση
    la $a0, input_msg
    syscall

    li $v0, 12	# syscall για είσοδο χρήστη
    syscall

    beq $v0, '@', print_string	# αν $v0(είσοδος) == '@' τότε πήγαινε στη συνάρτηση print_string

    beq $t0, 99, print_string	# αν $t0 == 99 τότε πήγαινε στη συνάρτηση print_string (έλεγχος πληρότητας χώρου)

    # Αποθήκευση του χαρακτήρα στη μνήμη
    sb $v0, buffer($t0) # αποθήκευση χαρακτήρα από $v0 στη θέση $t0 του buffer

    addi $t0, $t0, 1	# αύξηση του δείκτη t0

    j input_loop	# jump στο input_loop (επανάληψη)

print_string:
    # Εκτύπωση του μηνύματος "The String is:"
    li $v0, 4	# syscall για εκτύπωση
    la $a0, output_msg
    syscall

    # Εκτύπωση της αποθηκευμένης συμβολοσειράς
    addi $t1, $0, 0	# αρχικοποίηση δείκτη t1 για το loop της εκτύπωσης

print_loop:
    lb $a0, buffer($t1)	# φόρτωση χαρακτήρα από τη θέση $t1 του buffer στο $a0
    beqz $a0, end_print	# αν $a0 == 0 τότε πήγαινε στη συνάρτηση end_print

    li $v0, 11	# syscall για εκτύπωση χαρακτήρα
    syscall

    addi $t1, $t1, 1	# αύξηση του δείκτη $t1

    j print_loop	# jump στο print_loop (επανάληψη)

end_print:
    li $v0, 10	# syscall για τερματισμό προγράμματος
    syscall
