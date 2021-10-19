 
# La condicion de salto se calcula en ID.
# Si se salta la operacion que habia entrada se elimina (clear del IF_ID_REG)?!
# En las diapositivas pone stall?????

.text 0
main:
  # carga num0 a num5 en los registros 9 a 14
  lw $t1, 0($zero)  # lw $r9,  0($r0)  -> r9  = 1
  lw $t2, 4($zero)  # lw $r10, 4($r0)  -> r10 = 2
  lw $t3, 8($zero)  # lw $r11, 8($r0)  -> r11 = 4 
  lw $t4, 12($zero) # lw $r12, 12($r0) -> r12 = 8 
  lw $t5, 16($zero) # lw $r13, 16($r0) -> r13 = 16
  lw $t6, 20($zero) # lw $r14, 20($r0) -> r14 = 32
  # copia num0 a num5 sobre num6 a num11
  sw $t1, 24($zero) # sw $r9,  24($r0) -> data[24] =  1
  sw $t2, 28($zero) # sw $r10, 28($r0) -> data[28] =  2
  sw $t3, 32($zero) # sw $r11, 32($r0) -> data[32] =  4 
  sw $t4, 36($zero) # sw $r12, 36($r0) -> data[36] =  8 
  sw $t5, 40($zero) # sw $r13, 40($r0) -> data[40] =  16
  sw $t6, 44($zero) # sw $r14, 44($r0) -> data[44] =  32
  # carga num6 a num11 en los registros 9 a 14, deberia ser lo mismo
  lw $t1, 24($zero) # lw $r9, 24($r0)  -> r9  no cambia
  lw $t2, 28($zero) # lw $r10, 28($r0) -> r10 no cambia
  lw $t3, 32($zero) # lw $r11, 32($r0) -> r11 no cambia
  lw $t4, 36($zero) # lw $r12, 36($r0) -> r12 no cambia
  lw $t5, 40($zero) # lw $r13, 40($r0) -> r13 no cambia
  lw $t6, 44($zero) # lw $r14, 44($r0) -> r14 no cambia
  
  nop 
  nop
  nop
  beq $zero, $zero , TARGET1 # should jump and not execute the next instructions
  addi $s1, $zero, 20 # r17 <- 20
  addi $s2, $zero, 20 #r18 <- 20
  addi $s3, $zero, 29 # r19 <- 29
  nop
  nop
TARGET1: addi $t2, $zero, 1 # r10 <-1
  addi $t4, $zero, 2 # r12 <- 2
  addi $t5, $zero, 0 # r13 <- 0
  nop
  nop
  addi $t3, $zero, 7 # r11 <-7
  addi $t3, $zero, 1 # r11 <-1
  addi $t4, $zero, 1 # r12 <-1
  beq $t3, $t4, TARGET2  # should jump. there is a dependency with the two previous instructions 
  addi $s1, $zero, 25 # r17 <- 25
  addi $s2, $zero, 26 #r18 <-26
  addi $s3, $zero, 27 # r19 <- 27
  nop
  nop

TARGET2:
  addi $t5, $zero, 1  #r13 <- 1
  beq $t5, $t4, TARGET3  # should jump. there is a dependency with the previous instruction 
  addi $s1, $zero, 25 # r17 <- 25
  addi $s2, $zero, 26 # r18 <- 26
  addi $s3, $zero, 27 # r19 <- 27
  nop
  nop

TARGET3:
  addi $t5, $zero, 4  #r13 <- 4
  nop
  nop
  nop
  addi $t5, $zero, 1  #r13 <- 1
  nop
  beq $t5, $t4, TARGET4  # should jump. there is a dependency with the 2nd previous instruction 
  addi $s1, $zero, 25 # r17 <- 25
  addi $s2, $zero, 26 # r18 <- 26
  addi $s3, $zero, 27 # r19 <- 27
  nop
  nop

TARGET4:
  addi $t5, $zero, 4  #r13 <- 4
  nop
  nop
  nop
  addi $t5, $zero, 1  #r13 <- 1
  nop
  nop
  beq $t5, $t4, TARGET5  # should jump. there is a dependency with the 3rd previous instruction 
  addi $s1, $zero, 25 # r17 <- 25
  addi $s2, $zero, 26 # r18 <- 26
  addi $s3, $zero, 27 # r19 <- 27
  nop
  nop

TARGET5:
  addi $t5, $zero, 12 # r13 <- 12
  lw $t5, 16($zero) # r13 <- 16
  lw $t6, 16($zero) # r14 <- 16
  beq $t5, $t6, TARGET6 # should jump, there is dependency with two lw instruction
  addi $s1, $zero, 33 # r17 <- 33
  addi $s2, $zero, 34 # r18 <- 34
  addi $s3, $zero, 35 # r19 <- 35
  nop
  nop

TARGET6:
  addi $t5, $zero, 15 # r13 <- 15
  addi $t5, $zero, 16 # r13 <- 16
  beq $t5, $t6, TARGET1_ # should jump
  lw $t2, 16($zero) # r10 <- 16 # this should be ignored
  addi $s1, $zero, 33 # r17 <- 33
  addi $s2, $zero, 34 # r18 <- 34
  addi $s3, $zero, 35 # r19 <- 35
  nop
  nop


TARGET1_: addi $t2, $zero, 2 # r10 <-2  # the pipeline MUST NOT STALL (the depency with the lw after the beq is not real)
  addi $t5, $zero, 0 # r13 <- 0
  nop
  nop
  addi $t3, $zero, 7 # r11 <-7
  addi $t3, $zero, 2 # r11 <-2
  addi $t4, $zero, 5 # r12 <-5
  beq $t3, $t4, TARGET2_  # should not jump. there is a dependency with the two previous instructions 
  addi $s1, $zero, 25 # r17 <- 25
  addi $s2, $zero, 26 #r18 <-26
  addi $s3, $zero, 27 # r19 <- 27
  nop
  nop

TARGET2_:
  addi $t5, $zero, 2  #r13 <- 2
  beq $t5, $t4, TARGET3_  # should not jump. there is a dependency with the previous instruction 
  addi $s1, $zero, 28 # r17 <- 28
  addi $s2, $zero, 29 # r18 <- 29
  addi $s3, $zero, 30 # r19 <- 30
  nop
  nop

TARGET3_:
  addi $t5, $zero, 4  #r13 <- 4
  nop
  nop
  nop
  addi $t5, $zero, 2  #r13 <- 2
  nop
  beq $t4, $t5, TARGET4_  # should not jump. there is a dependency with the second previous instruction 
  addi $s1, $zero, 31 # r17 <- 31
  addi $s2, $zero, 32 # r18 <- 32
  addi $s3, $zero, 33 # r19 <- 33
  nop
  nop

TARGET4_:
  addi $t5, $zero, 12 # r13 <- 12
  lw $t5, 16($zero) # r13 <- 16
  lw $t6, 20($zero) # r14 <- 32
  beq $t5, $t6, TARGET5_ # should not jump, there is dependency with two lw instruction
  addi $s1, $zero, 34 # r17 <- 34
  addi $s2, $zero, 35 # r18 <- 35
  addi $s3, $zero, 36 # r19 <- 36
  nop
  nop   

TARGET5_: addi $t2, $zero, 1 # r10 <-1
  addi $t4, $zero, 2 # r12 <- 2
  addi $t5, $zero, 0 # r13 <- 0
  j END  # should jump. inconditional
  addi $s1, $zero, 37 # r17 <- 37
  addi $s2, $zero, 38 #r18 <- 38
  addi $s3, $zero, 39 # r19 <- 39
  nop
  nop

END: addi $t0, $t0, 1
  j END