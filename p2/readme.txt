Authors: Pablo Cuestas Sierra, álvaro Zamanillo Sáez


# Some notes on the programs used to test the processor:

 - The provided program 'riesgos.asm' had some mistakes in the comments regarding the expected values of the registers. We have repplaced them by the correct values in the file './riesgos_copy.asm'

 - Our program './branch_test.s' tests the critiria that the processor has to meet after that exercise: effective and non-effective branches (and jumps) coming after modifying registers (with both R-type instructions and lw) in different contexts. The comments in the code include the values that the registers have to have after each instructions, as well as whether branches are effective or not. After compiling that code with the provided compiler, we have replaced the nop inserted after each jump or branch by an "addi $s6, $s6, 1", which should be executed only if the branch is not effective. The compiled instructions with these replacements are in './e2/sim/instrucciones'
