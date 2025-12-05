from __future__ import annotations

import numpy as np


def maked_alt(m: int) -> np.ndarray:
    """Create forward-difference matrix D of shape (m, m+1)."""
    A = np.zeros((m, m + 1), dtype=np.float64)
    idx = np.arange(m)
    A[idx, idx] = -1.0
    A[idx, idx + 1] = 1.0
    # print("matrix D: ")
    # print(A)
    return A


def multiplyd(T: np.ndarray) -> np.ndarray:
    """
    Multiply D with T to get gradient.
    Returns shape (2*m, n) stacked [Dx; Dy] in column-major order.
    """
    m, n = T.shape
    Dy = maked_alt(m)
    Dxt = maked_alt(n)
    Dx = Dxt.T

    # vertical gradient with wrap
    altTy = np.zeros((m + 1, n), dtype=np.float64)
    altTy[:m, :n] = T
    altTy[m, : n - 1] = T[0, 1:]
    altTy[m, n - 1] = T[0, 0]
    delTy = Dy @ altTy

    # horizontal gradient with wrap
    altTx = np.zeros((m, n + 1), dtype=np.float64)
    altTx[:, :n] = T
    altTx[:, n] = T[:, 0]
    delTx = altTx @ Dx

    dtx = delTx.reshape(m * n, order="F")
    dty = delTy.reshape(m * n, order="F")
    dt = np.concatenate((dtx, dty))
    return dt.reshape((2 * m, n), order="F")


def multiplydtrans(G: np.ndarray) -> np.ndarray:
    """
    Multiply D^T with G.
    G shape is (2*m, n); returns (m, n).
    """
    # (2m, n) = (p, n)
    p, n = G.shape
    m = p // 2

    # flatten matrix G to a 2m by n vector(column major)
    g = G.reshape(p * n, order="F")
    # first m*n element is Gx, last m*n element is Gy
    Gx = g[: m * n].reshape((m, n), order="F")
    Gy = g[m * n :].reshape((m, n), order="F")

    Dyi = maked_alt(m)
    Dy = -Dyi
    Dxi = maked_alt(n)
    Dx = Dxi[:n, :n]
    Dx[:, 0] += Dxi[:n, n]  # wrap column

    altGy = np.zeros((m + 1, n), dtype=np.float64)
    altGy[1:, :] = Gy
    altGy[0, 1:] = Gy[m - 1, : n - 1]
    altGy[0, 0] = Gy[m - 1, n - 1]

    delGy = Dy @ altGy
    delGx = Gx @ Dx
    
    # ---- matrix size ----- #
    # print("G   size: ", G.shape)
    # print("Dyi size: ", Dyi.shape)
    # print("Dy  size: ", Dy.shape)
    # print("Dxi size: ", Dxi.shape)
    # print("Dx  size: ", Dx.shape)
    # print("altGy  size: ", altGy.shape)
    # print("delGy  size: ", delGy.shape)
    # print("delGx  size: ", delGx.shape)
    
    return delGx + delGy


def Tdenom(m: int, n: int, mu: float) -> np.ndarray:
    """Denominator used in updateT."""
    dxe = np.zeros((m, n), dtype=np.float64)
    dye = np.zeros((m, n), dtype=np.float64)
    dxe[1, 1] = -1.0
    dxe[1, 2 % n] = 1.0
    dye[1, 1] = -1.0
    dye[2 % m, 1] = 1.0

    dxf = np.fft.fftshift(np.fft.fft2(dxe))
    dxc = np.conj(dxf)
    dx_mod = dxc * dxf

    dyf = np.fft.fftshift(np.fft.fft2(dye))
    dyc = np.conj(dyf)
    dy_mod = dyc * dyf

    return 2.0 + mu * (dx_mod + dy_mod)


def shrinkage(A: np.ndarray, X: np.ndarray) -> np.ndarray:
    """Soft thresholding."""
    return np.sign(X) * np.maximum(np.abs(X) - A, 0.0)


def gaussian_kernel(size: int, sigma: float = 2.0) -> np.ndarray:
    """1D Gaussian kernel similar to fspecial('gaussian', [size,1], sigma)."""
    half = size // 2
    x = np.arange(-half, half + 1) if size % 2 else np.arange(-half, half)
    g = np.exp(-(x**2) / (2 * sigma * sigma))
    g /= g.sum()
    return g.reshape(-1, 1)


def make_weight_matrix(Ti: np.ndarray, ker_size: int = 5) -> np.ndarray:
    """Weight matrix using gradients of Ti."""
    m, n = Ti.shape
    p = m * n
    delTi = multiplyd(Ti)
    dtvec = delTi.reshape(2 * p, order="F")

    dtx = dtvec[:p]
    dty = dtvec[p:]

    w_gauss = gaussian_kernel(ker_size, sigma=2.0).flatten()
    convl_x = np.convolve(dtx, w_gauss, mode="same")
    convl_y = np.convolve(dty, w_gauss, mode="same")
    W_x = 1.0 / (np.abs(convl_x) + 1e-4)
    W_y = 1.0 / (np.abs(convl_y) + 1e-4)

    W_vec = np.concatenate((W_x, W_y))
    return W_vec.reshape((2 * m, n), order="F")


def updateT(Ti: np.ndarray, mu: float, G: np.ndarray, U: np.ndarray) -> np.ndarray:
    """Update T sub-problem."""
    X = G - U # (G - Z/μ) -> matrix size = (2m,n) 
    delX = multiplydtrans(X)
    Tnum = 2 * Ti + mu * delX
    Tn = np.fft.fftshift(np.fft.fft2(Tnum))

    m, n = Ti.shape
    Td = Tdenom(m, n, mu)
    Tnd = Tn / Td
    return np.real(np.fft.ifft2(np.fft.ifftshift(Tnd)))


def lime_trial(Ti: np.ndarray, alpha: float, mu0: float, rho: float, k0: int = 50) -> np.ndarray:
    """
    ADMM/ALM solver.
    Ti: initial illumination map (2D)
    alpha, mu0, rho: solver hyperparameters
    k0: iterations
    """
    m, n = Ti.shape
    k = 0
    mu = mu0
    Z = np.zeros((2 * m, n), dtype=np.float64) # 2m by n matrix
    G = np.zeros((2 * m, n), dtype=np.float64) # 2m by n matrix
    W = make_weight_matrix(Ti, ker_size=5)

    while k < k0:
        U = Z / mu  # Z / μ
        A = alpha * W / mu
        T = updateT(Ti, mu, G, U)
        delT = multiplyd(T)
        G = shrinkage(A, delT + U)
        B = delT - G
        Z = mu * (B + U)
        mu *= rho
        k += 1

    return T
