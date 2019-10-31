
import numpy as np
#from weldnumpy import weldarray
import time


def are_same_matrix(y1, y2):
    return (y1.shape == y2.shape) and all(y1.flatten() == y2.flatten())


def print_elapsed(func):
    def wrapper(*args, **kwargs):
        begin = time.time()
        ret = func(*args, **kwargs)
        end = time.time()
        print(func.__name__, kwargs)
        print("{:.5f} sec".format(end - begin))
        return ret
    return wrapper


@print_elapsed
def matmul_simple(x1, x2, use_weld=False):
    if use_weld:
        x1 = weldarray(x1)
        x2 = weldarray(x2)
    y = np.matmul(x1, x2)

    if use_weld:
        y.evaluate()
    return y


@print_elapsed
def kernel_matrix(x, sigma, use_weld=False):
    """ Something like below,

    dK = euclidean_distances(d, squared=True)
    K *= -1.0 / (2*sigma*sigma)
    gramian = np.exp(K, K)
    """

    raise NotImplementedError()


def eval_matmul_simple(n, m, k, dtype=np.float64):
    x1 = np.arange(n * m, dtype=dtype).reshape(n, m)
    x2 = np.arange(m * k, dtype=dtype).reshape(m, k) + 1

    y_numpy = matmul_simple(x1, x2, use_weld=False)
    
    """
    y_weld =  matmul_simple(x1, x2, use_weld=True)
    assert are_same_matrix(y_numpy, y_weld)
    """


def eval_kernel_matrix(n, d, sigma, dtype=np.float64):
    np.random.seed(10)
    x = np.random.random((n, d)).reshape(n, d)

    y_numpy = kernel_matrix(x, sigma, use_weld=False)

    """
    y_weld = kernel_matrix(x, sigma, use_weld=True)
    assert are_same_matrix(y_numpy, y_weld)
    """

    
if __name__ == "__main__":
    
    eval_matmul_simple(1000,1000,1000)
    eval_kernel_matrix(1 << 20, 3, 0,1)

