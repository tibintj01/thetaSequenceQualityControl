
def perform_bubble_sort(blist):
    cmpcount, swapcount = 0, 0
    for j in range(len(blist)):
        print('********')
        print(j)
        print('********')
        for i in range(1, len(blist)-j):
            print(i)
            cmpcount += 1
            if blist[i-1] > blist[i]:
                swapcount += 1
                blist[i-1], blist[i] = blist[i], blist[i-1]
    return cmpcount, swapcount


#testList=[ 1, 2, 3, 4, 5]
#testList=[ 1, 2, 3, 5, 4]
#testList=[5,4,3,2,1]
testList=[5,4,3,1,2]
_,DI=perform_bubble_sort(testList)

print(DI)
