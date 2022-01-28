

#innerProduct([1,2,3], [1,2,3])
def innerProduct(v1=[1,2,3], v2=[1,2,3]):
    return sum([a*b for a, b in zip(v1, v2)])

def showMatrixMult():
    # 2x3 matrix
    X = [
        [1 ,2,3],
        [4 ,5,6]
    ]

    # 3x2 matrix
    Y = [
        [1, 4],
        [2, 5],
        [3, 6]
    ]

    # result is 3x4
    result = [
        [0,0],
        [0,0]
    ]

    # iterate through rows of X
    for i in range(len(X)):
       # iterate through columns of Y
       for j in range(len(Y[0])):
           # iterate through rows of Y
           for k in range(len(Y)):
               result[i][j] += X[i][k] * Y[k][j]
    print(result)

# Returns a dict where d[non-zero value] = index in v
def representSparseVector(v = [1, 0, 0, 3]):
    vToIndexDict = {n: index for index, n in enumerate(v) if n}
    return vToIndexDict
