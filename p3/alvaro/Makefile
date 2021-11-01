LIBS = 
LIB_DIR =  
FLAGS = -O3 -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: fast slow multiplication transposed_multiplication

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

multiplication: multiplication.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

transposed_multiplication: transposed_multiplication.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)


clean:
	rm -f *.o *~ fast slow multiplication transposed_multiplication

clean_plot:
	rm -f *.png
