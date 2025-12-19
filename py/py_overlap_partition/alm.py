from __future__ import annotations

import numpy as np
from pathlib import Path
from typing import Optional, Tuple

from fft import fft2_iterative_radix2, ifft2_iterative_radix2
from tdenom import tdenom_mat
from helper import dump_iteration_mats

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
    
    # golden data sramX_1.dat
    delG = np.vstack((delGx, delGy))
    
    # ---- matrix size ----- #
    # print("G   size: ", G.shape)
    # print("Dyi size: ", Dyi.shape)
    # print("Dy  size: ", Dy.shape)
    # print("Dxi size: ", Dxi.shape)
    # print("Dx  size: ", Dx.shape)
    # print("altGy  size: ", altGy.shape)
    # print("delGy  size: ", delGy.shape)
    # print("delGx  size: ", delGx.shape)
    
    return delGx + delGy, delG

# 2025.12.16 hw friendly multiplytrans
def selfdefined_multiplydtrans(G: np.ndarray) -> np.ndarray:
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
    Gy = g[m * n :].reshape((2*m, n//2), order="F") # 64x16 matrix
    
    Dxi = maked_alt(n)
    Dx = Dxi[:n, :n]
    Dx[:, 0] += Dxi[:n, n]  # wrap column
    delGx = Gx @ Dx
    
    # implement hw delGy
    delGy = np.zeros((32,32), dtype=np.float64)
    for i in range((n//2)//4): # column
        for j in range(1,32): # row(1-31)
            # lower row = upper row - lower row
            delGy[j, 2*(i*4+0)] = Gy[j-1, i*4] - Gy[j, i*4]
            delGy[j, 2*(i*4+1)] = Gy[j-1, i*4+1] - Gy[j, i*4+1]
            delGy[j, 2*(i*4+2)] = Gy[j-1, i*4+2] - Gy[j, i*4+2]
            delGy[j, 2*(i*4+3)] = Gy[j-1, i*4+3] - Gy[j, i*4+3]
            
    for i in range((n//2)//4): 
        for j in range(33,64): #row(32-63) 
            delGy[j-32, 2*(i*4+0)+1] = Gy[j-1, i*4] - Gy[j, i*4]
            delGy[j-32, 2*(i*4+1)+1] = Gy[j-1, i*4+1] - Gy[j, i*4+1]
            delGy[j-32, 2*(i*4+2)+1] = Gy[j-1, i*4+2] - Gy[j, i*4+2]
            delGy[j-32, 2*(i*4+3)+1] = Gy[j-1, i*4+3] - Gy[j, i*4+3]
    
    
    # golden data sramX_1.dat
    delG = np.vstack((delGx, delGy))
    
    return delGx + delGy, delG

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

# ===== strategy II ===== #
def make_weight_matrix_2(Ti: np.ndarray, ker_size: int = 5) -> np.ndarray:
    """
    Weight matrix using gradients of Ti.
    With strategy 2 from lime paper
    """
    m, n = Ti.shape
    p = m * n
    delTi = multiplyd(Ti)
    dtvec = delTi.reshape(2 * p, order="F")

    dtx = dtvec[:p]
    dty = dtvec[p:]
    
    W_x = 1.0 / (np.abs(dtx) + 1e-4)
    W_y = 1.0 / (np.abs(dty) + 1e-4)

    W_vec = np.concatenate((W_x, W_y))
    return W_vec.reshape((2 * m, n), order="F")
# ===== strategy II ===== #

# ===== strategy III ===== #
def make_weight_matrix(Ti: np.ndarray, ker_size: int = 5) -> np.ndarray:
    """
    Weight matrix using gradients of Ti.
    With strategy 3 from lime paper
    """
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
# ===== strategy III ===== #

# ===== 1. shift fft ===== #
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
# ===== 1. shift fft ===== #

# ===== 2. unshift fft ===== #
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
# ===== 2. unshift fft ===== #

# ===== 3. selfdefined fft ===== #
def updateT_selfdefined(Ti: np.ndarray, mu: float, G: np.ndarray, U: np.ndarray) -> np.ndarray:
    """
    Update T using the self-defined radix-2 iterative FFT/ifft (unshifted spectrum).
    Matrix dimensions must be powers of two (e.g., 32x32).
    """
    X = G - U
    delX = multiplydtrans(X)
    Tnum = 2 * Ti + mu * delX
    Tn = fft2_iterative_radix2(Tnum)

    m, n = Ti.shape
    Td = Tdenom_selfdefined(m, n, mu)  # unshifted denominator to match unshifted spectrum
    Tnd = Tn / Td
    Tout = ifft2_iterative_radix2(Tnd)
    return np.real(Tout)

def Tdenom_selfdefined(m: int, n: int, mu: float) -> np.ndarray:
    """
    Denominator using self-defined radix-2 FFT (unshifted spectrum, power-of-two dims).
    """
    dxe = np.zeros((m, n), dtype=np.float64)
    dye = np.zeros((m, n), dtype=np.float64)
    dxe[1, 1] = -1.0
    dxe[1, 2 % n] = 1.0
    dye[1, 1] = -1.0
    dye[2 % m, 1] = 1.0

    dxf = fft2_iterative_radix2(dxe)
    dyf = fft2_iterative_radix2(dye)
    return 2.0 + mu * (np.conj(dxf) * dxf + np.conj(dyf) * dyf)
# ===== 3. selfdefined fft ===== #

# ===== 4. fft with parameterized denominator ===== #
def updateT_param(Ti: np.ndarray, mu: float, G: np.ndarray, U: np.ndarray) -> np.ndarray:
    """
    Update T using the self-defined radix-2 iterative FFT/ifft (unshifted spectrum).
    Matrix dimensions must be powers of two (e.g., 32x32).
    """
    X = G - U
    delX = multiplydtrans(X)
    Tnum = 2 * Ti + mu * delX
    Tn = fft2_iterative_radix2(Tnum)

    m, n = Ti.shape
    Td = Tdenom_param(m, n, mu)  # unshifted denominator to match unshifted spectrum
    Tnd = Tn / Td
    Tout = ifft2_iterative_radix2(Tnd)
    return np.real(Tout)

def Tdenom_param(m: int, n: int, mu: float) -> np.ndarray:
    """
    Denominator using self-defined radix-2 FFT (unshifted spectrum, power-of-two dims).
    """
    T_mat = tdenom_mat(m, n)
    # tdenom_mat will reture a 32x32 matrix
    # each element is complex number
    return 2.0 + mu * T_mat
# ===== 4. fft with parameterized denominator ===== #

# ===== 5. fft with data file ===== # 
def updateT_dat(
    Ti: np.ndarray, mu: float, G: np.ndarray, U: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    Update T using the self-defined radix-2 iterative FFT/ifft (unshifted spectrum).
    Matrix dimensions must be powers of two (e.g., 32x32).
    """
    X = G - U
    delX, delG = selfdefined_multiplydtrans(X) # sramX_1.dat
    Tnum = 2 * Ti + mu * delX # sramE_1.dat
    Tn = fft2_iterative_radix2(Tnum) # sramT_1.dat

    m, n = Ti.shape
    # load precomputed denominator from file
    Td = Tdenom_dat(m, n, mu) # sramE_2.dat
    Tnd = Tn / Td # sramC.dat
    Tout = ifft2_iterative_radix2(Tnd) # sramT_2.dat
    Tout_real = np.real(Tout)
    return Tout_real, delX, Tnum, Tn, Td, Tnd, Tout, delG, Ti

def load_tdenom_hex(path: str, m: int, n: int) -> np.ndarray:
    """
    Load precomputed T denominator (row-major) from hex file: REAL_IMAG per line.
    """
    re_list, im_list = [], []
    with open(path, "r", encoding="ascii") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            r_hex, i_hex = line.split("_")
            re_list.append(int(r_hex, 16))
            im_list.append(int(i_hex, 16))

    arr_re = np.array(re_list, dtype=np.uint64).view(np.float64)
    arr_im = np.array(im_list, dtype=np.uint64).view(np.float64)
    return (arr_re + 1j * arr_im).reshape((m, n), order="C")

def Tdenom_dat(m: int, n: int, mu: float) -> np.ndarray:
    """
    Denominator using self-defined radix-2 FFT, loaded from precomputed hex file.
    Expects file at ./dat/tdenom_{m}x{n}_hex.txt with REAL_IMAG per line (row-major).
    """
    root = Path(__file__).resolve().parent
    dat_dir = root / "dat"
    fname = dat_dir / f"tdenom_{m}x{n}_hex.txt"
    T_mat = load_tdenom_hex(fname, m, n)
    # each element is complex number
    return 2.0 + mu * T_mat
# ===== 5. fft with data file ===== # 


def lime_trial(
    Ti: np.ndarray, 
    alpha: float, 
    mu0: float, 
    rho: float, 
    k0: int = 50,
    save_label: Optional[str] = None,
    dump_alm: bool = False,
    debug_dir: Optional[Path] = None,
    ) -> np.ndarray:
    """
    ADMM/ALM solver.
    Ti: initial illumination map (2D)
    alpha, mu0, rho: solver hyperparameters
    k0: iterations
    """
    m, n = Ti.shape
    label = save_label or "run"
    if dump_alm:
        if debug_dir is None:
            root = Path(__file__).resolve().parent
            debug_dir = root / "alm" / label
        debug_dir.mkdir(parents=True, exist_ok=True)
    k = 0
    mu = mu0
    Z = np.zeros((2 * m, n), dtype=np.float64) # 2m by n matrix
    # print(f"matrix Z: {2 * m} by {n}")
    # print(Z)
    G = np.zeros((2 * m, n), dtype=np.float64) # 2m by n matrix
    # print(f"matrix G: {2 * m} by {n}")
    # print(G)
    W = make_weight_matrix_2(Ti, ker_size=5)
    # print("matrix W:")
    # print(W)
    
    while k < k0:
        U = Z / mu                     # sramU_1.dat, Z / μ
        A = alpha * W / mu             # sramW.dat, Threshold matrix of each element
        T, delX, Tnum, Tn, Td, Tnd, Tout, delG, Ti = updateT_dat(Ti, mu, G, U) # T(t+1) = ...
        delT = multiplyd(T)            # sramX_2.dat, ∇T
        G = shrinkage(A, delT + U)     # sramG.dat, G(t+1) = Shrinkage(∇T + Z / μ)
        B = delT - G                   # ∇T - G
        Q = mu * (B ) + Z              # sramU_2.dat, previos ver: Z(t+1) = μ(t) * (∇T - G + Z(t)/μ(t))
        Z = Q                          # sramZ.dat, Z(t+1) = μ(t) * (∇T - G) + Z(t)
        mu *= rho                      # μ(t+1) = μ(t)
        
        if dump_alm and debug_dir is not None:
            dump_iteration_mats(
                debug_dir,
                k,
                {
                    "sramU_1": U,
                    "sramW_1": A,
                    "sramX_1": delG,
                    "sramE_1": Tnum,
                    "sramT_1": Tn,
                    "sramE_2": Td,
                    "sramC_1": Tnd,
                    "sramT_2": Tout,
                    "sramX_2": delT,
                    "sramG_1": G,
                    "sramU_2": Q,
                    "sramZ_1": Z,
                    "sramB_1": Ti
                },
            )
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
