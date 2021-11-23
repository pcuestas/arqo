file = "../outputs/out3/table.dat"

A=[]
f=open(file)
for line in f:
	A+=line.split("\t\t\t\t")
print(A)

rows=len(A)
cols=len(A[0])
B=[([0]*rows) for j in range(cols)]

for i in range(rows):
	for j in range(cols):
		B[j][i]=A[i][j]

print((B))
