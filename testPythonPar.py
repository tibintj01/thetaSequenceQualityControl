from multiprocessing import Pool

def f(x):
	return x*x


p = Pool(20)
print(p.map(f,[ 1, 3, 5, 9, 11, 15]))
