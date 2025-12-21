from __future__ import annotations

from pathlib import Path
import numpy as np

# ===== debug helpers ===== #
def _matrix_to_hex_lines(mat: np.ndarray) -> list[str]:
    """
    Convert a real/complex matrix to a list of hex strings in row-major order.
    - Real numbers: one 16-hex-digit IEEE754 FP64 value per line.
    - Complex numbers: REAL_HEX_IMAG_HEX on one line.
    """
    # mat = mat[::-1]  # bottom row first
    # ---- Complex matrix case ----
    if np.iscomplexobj(mat):
        # Convert real part to a contiguous float64 array in row-major order.
        # reshape(-1) flattens the matrix into a 1-D array.
        arr_re = np.asarray(np.real(mat), dtype=np.float64, order="C").reshape(-1)
        arr_im = np.asarray(np.imag(mat), dtype=np.float64, order="C").reshape(-1)

        # view(np.uint64):
        #   Reinterpret each FP64 value as a raw 64-bit unsigned integer
        #   without changing the underlying bits (bit-cast).
        re_hex = arr_re.view(np.uint64)
        im_hex = arr_im.view(np.uint64)

        # Format each pair as:
        #   "REAL_IEEE754_HEX_IMAG_IEEE754_HEX"
        return [f"{r:016x}_{i:016x}" for r, i in zip(re_hex, im_hex)]

    # ---- Real matrix case ----
    # Flatten matrix to 1-D float64 array (row-major).
    flat = np.asarray(mat, dtype=np.float64, order="C").reshape(-1)

    # Bit-cast FP64 to uint64 to obtain IEEE754 bit pattern.
    flat_hex = flat.view(np.uint64)

    # Return list of 16-hex-digit strings (one per value).
    return [f"{v:016x}" for v in flat_hex]


def write_matrix_hex(mat: np.ndarray, path: Path) -> None:
    """
    Write the given matrix as a hex .dat file in row-major order.

    - Ensures directory exists.
    - Each line in the file contains one IEEE754 hex value.
    """
    # path.parent: the directory containing the file
    # mkdir(...): create all needed parent directories if not exist
    path.parent.mkdir(parents=True, exist_ok=True)

    # Convert matrix to list of hex-formatted strings.
    lines = _matrix_to_hex_lines(mat)

    # Write them to ASCII text file.
    with open(path, "w", encoding="ascii") as f:
        f.write("\n".join(lines))


def dump_iteration_mats(base_dir: Path, iter_idx: int, mats: dict[str, np.ndarray]) -> None:
    """
    Save multiple matrices for a single iteration into:

        base_dir / iter_xxx / <name>.dat

    where xxx = zero-padded iteration index, and each .dat file uses
    row-major IEEE754 hex formatting.
    """
    # Build directory: e.g., base_dir / "iter_005"
    iter_dir = base_dir / f"iter_{iter_idx:03d}"

    # Ensure that the iteration directory exists.
    iter_dir.mkdir(parents=True, exist_ok=True)

    # Save each matrix in a separate .dat file.
    for name, mat in mats.items():
        write_matrix_hex(mat, iter_dir / f"{name}.dat")
