import sys
from tabulate import tabulate

'''
file with times to latex table of fps (1/time)
'''

file = sys.argv[1]#"../outputs/out3/table.dat"

A=[]
f=open(file)
for line in f:
	A+=[line.split("\t")]

for line in A:
	for i in range(len(line)):
		try:
			line[i]=str(1/float(line[i]))
		except:
			line[i]=line[i]

print(tabulate(A, headers='firstrow', tablefmt='latex'))
