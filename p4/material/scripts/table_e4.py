import sys
from tabulate import tabulate

'''
file with data to latex table
'''

file = sys.argv[1]

A=[]
f=open(file)
for line in f:
	A+=[line.split("\t")]

print(tabulate(A, headers='firstrow', tablefmt='latex'))
