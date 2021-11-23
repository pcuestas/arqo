file = "../outputs/out3/table.dat"

A=[]
f=open(file)
for line in f:
	A+=line.split("\t")
	A[-1]=[j for j in A[-1] if j!='']
print(A)

B=[[k] for k in A[0]]
rows=len(A)
cols=len(A[0])
for i in range(1,rows):
	for j in range(cols):
		B[j]+=[A[i][j]]

print((B))
