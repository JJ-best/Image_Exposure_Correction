from pathlib import Path
import numpy as np
from fft import fft2_iterative_radix2

"""
since T denominator is a constant matrix, we dont 
need to calculate the fft in the hw, we use this
py to generate the parameter matrix.
"""

def tdenom_mat(m: int, n: int):
    """Generate the parameter matrix of T denominator."""
    dxe = np.zeros((m, n), dtype=np.float64)
    dye = np.zeros((m, n), dtype=np.float64)
    dxe[1, 1] = -1.0
    dxe[1, 2 % n] = 1.0
    dye[1, 1] = -1.0
    dye[2 % m, 1] = 1.0
    dxf = fft2_iterative_radix2(dxe)
    dyf = fft2_iterative_radix2(dye)
    return (np.conj(dxf) * dxf + np.conj(dyf) * dyf)


def save_tdenom_hex(path: str, m: int, n: int) -> None:
    """
    Dump tdenom_mat as hex: 64'hREAL 64'hIMAG per element, row-major flatten.
    """
    mat = tdenom_mat(m, n).astype(np.complex128)
    real_hex = mat.real.ravel(order="C").view(np.uint64)
    imag_hex = mat.imag.ravel(order="C").view(np.uint64)

    with open(path, "w", encoding="ascii") as f:
        for r, i in zip(real_hex, imag_hex):
            f.write(f"{r:016X}_{i:016X}\n")


def save_tdenom_fp(path: str, m: int, n: int) -> None:
    """
    Dump tdenom_mat as fp: REAL IMAG per element, row-major flatten.
    """
    mat = tdenom_mat(m, n).astype(np.complex128)
    real_vals = mat.real.ravel(order="C")
    imag_vals = mat.imag.ravel(order="C")

    with open(path, "w", encoding="ascii") as f:
        for r, i in zip(real_vals, imag_vals):
            f.write(f"{r:.17e} {i:.17e}\n")


if __name__ == "__main__":
    m = 32
    n = 32
    Tmat = tdenom_mat(m, n)
    print("Tmat: \n", Tmat)
    root = Path(__file__).resolve().parent
    dat_dir = root.parent.parent / "sim" / "tdenom_pat"
    dat_dir.mkdir(parents=True, exist_ok=True)
    save_tdenom_hex(dat_dir / "tdenom_32x32_hex.txt", m, n)
    save_tdenom_fp(dat_dir / "tdenom_32x32_fp.txt", m, n)
