import sys
from tabulate import tabulate

file = sys.argv[1]#"../outputs/out3/table.dat"

try:
	t1=(sys.argv[2]=="1")
	t2=(sys.argv[2]=="2")
except:
	t1=1
	t2=1

A=[]
f=open(file)
for line in f:
	A+=[line.split("\t\t\t\t")]

rows=len(A)
cols=len(A[0])

B=[ 
		[A[i][j].replace("\n","") for i in range(rows)] 
			for j in range(cols)
	]
if t1:
	print(tabulate(B, headers='firstrow', tablefmt='latex'))

x = float(B[1][1])
for j in B[1:]:
	for i in range(len(j)):
		try:
			j[i]=str(float(j[i])/x)
		except:
			j[i]=j[i]

if t2:
	print(tabulate(B, headers='firstrow', tablefmt='latex'))
