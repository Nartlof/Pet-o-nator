from cmath import log
import numpy as np

from posixpath import split


data = open("TemperatureData.txt", "r")
temp = []
resist = []
for x in data:
    if "#" in x:
        continue
    l = x.split(sep=",")
    temp.append(eval(l[0]))
    resist.append(eval(l[1]))
data.close()
InvTemp = []
for t in temp:
    InvTemp.append(1/(t+273))


A = []
for r in resist:
    x = log(r).real
    xx = 1
    eq = []
    for j in range(4):
        eq.append(xx)
        xx *= x
    A.append(eq)
A = np.array(A)
Alpha = np.matmul(A.transpose(), A)
Beta = np.matmul(A.transpose(), InvTemp)
Coef = np.linalg.solve(Alpha, Beta)

print(Coef)

T2 = []
for r in resist:
    x = log(r).real
    xx = 1
    eq = 0
    for j in range(4):
        eq += Coef[j]*xx
        xx *= x
    T2.append(1/eq-273)

for j in range(len(temp)):
    print(resist[j], temp[j], T2[j])
