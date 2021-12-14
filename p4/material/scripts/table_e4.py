import sys
from tabulate import tabulate

'''
file with data to latex table
'''

file = sys.argv[1]#"../outputs/out3/table.dat"

A=[]
f=open(file)
for line in f:
	A+=[line.split("\t")]

print(tabulate(A, headers='firstrow', tablefmt='latex'))
