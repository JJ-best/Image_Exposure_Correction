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
    
    # print("Dy: \n", Dy)
    # print("Dxt: \n", Dxt)
    # print("Dx: \n", Dx)

    # vertical gradient with wrap
    altTy = np.zeros((m + 1, n), dtype=np.float64)
    # print("altTy: \n", altTy)
    altTy[:m, :n] = T
    # print("altTy: \n", altTy)
    altTy[m, : n - 1] = T[0, 1:]
    # print("altTy: \n", altTy)
    altTy[m, n - 1] = T[0, 0]
    # print("altTy: \n", altTy)
    delTy = Dy @ altTy
    # print("detTy: \n", delTy)

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

def Tdenom_no_shift(m: int, n: int, mu: float) -> np.ndarray:
    """Denominator without fftshift; for use with unshifted spectra."""
    dxe = np.zeros((m, n), dtype=np.float64)
    dye = np.zeros((m, n), dtype=np.float64)
    dxe[1, 1] = -1.0
    dxe[1, 2 % n] = 1.0
    dye[1, 1] = -1.0
    dye[2 % m, 1] = 1.0

    dxf = np.fft.fft2(dxe)
    dyf = np.fft.fft2(dye)
    return 2.0 + mu * (np.conj(dxf) * dxf + np.conj(dyf) * dyf)


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


def updateT_no_shift(Ti: np.ndarray, mu: float, G: np.ndarray, U: np.ndarray) -> np.ndarray:
    """Update T sub-problem without fftshift/ifftshift (Td is unshifted to match)."""
    X = G - U                 # (G - Z/μ)
    delX = multiplydtrans(X)  # D^T * (G - Z/μ)
    Tnum = 2 * Ti + mu * delX # w * T + μ * D^T * (G - Z/μ)
    Tn = np.fft.fft2(Tnum)    # F{w * T + μ * D^T * (G - Z/μ)}

    m, n = Ti.shape
    Td = Tdenom_no_shift(m, n, mu)
    Tnd = Tn / Td
    return np.real(np.fft.ifft2(Tnd))


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
    # print(f"matrix Z: {2 * m} by {n}")
    # print(Z)
    G = np.zeros((2 * m, n), dtype=np.float64) # 2m by n matrix
    # print(f"matrix G: {2 * m} by {n}")
    # print(G)
    W = make_weight_matrix(Ti, ker_size=5)
    # print("matrix W:")
    # print(W)
    
    while k < k0:
        U = Z / mu                  # Z / μ
        A = alpha * W / mu          # Threshold matrix of each element
        T = updateT_no_shift(Ti, mu, G, U)   # T(t+1) = ...
        delT = multiplyd(T)         # ∇T
        G = shrinkage(A, delT + U)  # G(t+1) = Shrinkage(∇T + Z / μ)
        B = delT - G                # ∇T - G
        Z = mu * (B + U)            # Z(t+1) = μ(t) * (∇T - G)
        mu *= rho                   # μ(t+1) = μ(t)
        # print(f"===== iteration {k} ===== ")
        # print("Matrix U: \n", U)
        # print("Matrix A: \n", A)
        # print("Matrix T: \n", T)
        # print("Matrix W: \n", W)
        # print("delT: \n", delT)
        # print("Matrix G: \n", G)
        # print("Matrix B: \n", B)
        # print("Matrix Z: \n", Z)
        # print("mu = ", mu)        
        k += 1

    return T
