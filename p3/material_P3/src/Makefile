LIBS = 
LIB_DIR =  
FLAGS = -O3 -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: fast slow multiplication multiplication_t

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o ../$@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o ../$@ $^ $(LIBS)

multiplication: multiplication.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o ../$@ $^ $(LIBS)

multiplication_t: multiplication_t.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o ../$@ $^ $(LIBS)

clean:
	rm -f *.o *~ fast slow multiplication multiplication_t
