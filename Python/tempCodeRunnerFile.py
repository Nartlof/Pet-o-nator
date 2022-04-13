x = log(r).real
    xx = 1
    eq = 0
    for j in range(4):
        eq += Coef[j]*xx
        xx *= x
    T2.append(eq)