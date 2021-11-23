LIBS = 
LIB_DIR =  
FLAGS = -g -lgomp -lm -Wall -D_GNU_SOURCE -fopenmp
MULT_PROGS=multiplication multiplication_loop1 multiplication_loop2 multiplication_loop3


.PHONY: clean all

all: omp1 omp2 pescalar_serie pescalar_par1 pescalar_par2 pescalar_par3 ${MULT_PROGS} edgeDetector clear

omp1: omp1.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

omp2: omp2.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_serie: pescalar_serie.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par1: pescalar_par1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par2: pescalar_par2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

pescalar_par3: pescalar_par3.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multiplication: multiplication.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multiplication_loop1: multiplication_loop1.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multiplication_loop2: multiplication_loop2.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multiplication_loop3: multiplication_loop3.c arqo4.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

edgeDetector: edgeDetector.c stb_image_write.h stb_image.h
	gcc $(FLAGS) -std=gnu99 $(LIB_DIR) -o $@ edgeDetector.c $(LIBS)

stb_image.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image.h

stb_image_write.h:
	@echo "Los ficheros de cabecera de stb se deberían descarga automáticamente"
	@echo "En caso de fallo, descargadlo de https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h"
	wget --no-check-certificate https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h

clean:
	rm -f *.o *~ omp1 omp2 pescalar_serie pescalar_par1 pescalar_par2 edgeDetector
	
clear:
	rm -f *.o *~