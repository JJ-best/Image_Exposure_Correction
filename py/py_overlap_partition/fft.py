import numpy as np


def _is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0


def _bit_reverse_indices(n: int) -> np.ndarray:
    """Return indices for bit-reversal permutation (n must be power of two)."""
    bits = n.bit_length() - 1
    idx = np.arange(n, dtype=np.uint32)
    rev = np.zeros(n, dtype=np.uint32)
    for i in range(bits):
        rev |= ((idx >> i) & 1) << (bits - 1 - i)
    return rev


def fft_iterative_radix2(x: np.ndarray) -> np.ndarray:
    """
    In-place- style iterative radix-2 DIT FFT (forward, matches numpy.fft.fft sign).
    x length must be power of two. Returns complex128.
    """
    n = x.shape[0]
    if not _is_power_of_two(n):
        raise ValueError("fft_iterative_radix2 expects power-of-two length.")

    out = np.asarray(x, dtype=np.complex128).copy()
    rev = _bit_reverse_indices(n)
    out[:] = out[rev]  # bit-reversal permutation

    m = 2
    while m <= n:
        half = m // 2
        w_m = np.exp(-2j * np.pi * np.arange(half) / m)
        for k in range(0, n, m):
            u = out[k : k + half].copy()          # copy to avoid in-place overwrite
            v = w_m * out[k + half : k + m].copy()
            out[k : k + half] = u + v
            out[k + half : k + m] = u - v
        m *= 2
    return out


def ifft_iterative_radix2(x: np.ndarray) -> np.ndarray:
    """
    Inverse FFT implemented using the conjugate trick.

    The mathematical definition of the IFFT is:
        x[n] = (1/N) * sum_{k=0}^{N-1} X[k] * exp(+j*2π*k*n/N)

    However, our FFT implementation is defined as:
        FFT(x) = sum_{n=0}^{N-1} x[n] * exp(-j*2π*k*n/N)

    Using the following identity (conjugate trick):
        IFFT(X) = (1/N) * conj( FFT( conj(X) ) )

    This identity is derived from these properties:
        1. exp(+jθ) = conj( exp(-jθ) )
        2. conj(a * b) = conj(a) * conj(b)
        3. conj( sum a_k ) = sum conj(a_k)

    Therefore:
    - Instead of conjugating the exponential kernel exp(+jθ),
      we conjugate the input sequence X.
    - We then reuse the same forward FFT implementation.
    - Finally, we conjugate the FFT result and divide by N.

    This approach allows the IFFT to be implemented without
    writing a separate inverse butterfly network, which is
    especially important for hardware and high-performance designs.
    """
    n = x.shape[0]
    tmp = fft_iterative_radix2(np.conjugate(x))
    return np.conjugate(tmp) / n


def fft2_iterative_radix2(mat: np.ndarray) -> np.ndarray:
    """2D FFT via row FFT then column FFT; both dimensions must be powers of two."""
    m, n = mat.shape
    if not _is_power_of_two(m) or not _is_power_of_two(n):
        raise ValueError("fft2_iterative_radix2 expects power-of-two dimensions.")

    out = np.asarray(mat, dtype=np.complex128).copy()
    for i in range(m):
        # do fft row by row
        out[i, :] = fft_iterative_radix2(out[i, :])
    for j in range(n):
        # do fft col by col
        out[:, j] = fft_iterative_radix2(out[:, j])
    return out


def ifft2_iterative_radix2(mat: np.ndarray) -> np.ndarray:
    """2D inverse FFT matching numpy's ifft2 scale/phase."""
    m, n = mat.shape
    if not _is_power_of_two(m) or not _is_power_of_two(n):
        raise ValueError("ifft2_iterative_radix2 expects power-of-two dimensions.")

    out = np.asarray(mat, dtype=np.complex128).copy()
    for i in range(m):
        out[i, :] = ifft_iterative_radix2(out[i, :])
    for j in range(n):
        out[:, j] = ifft_iterative_radix2(out[:, j])
    return out


def demo_compare_32x32():
    """Run a quick 32x32 complex test and compare to numpy.fft as golden data."""
    rng = np.random.default_rng(0)
    mat = rng.standard_normal((32, 32)) + 1j * rng.standard_normal((32, 32))

    print("Input matrix real part (32x32):")
    print(np.real(mat))
    print("Input matrix imag part (32x32):")
    print(np.imag(mat))

    ours = fft2_iterative_radix2(mat)
    golden = np.fft.fft2(mat)
    max_err = np.max(np.abs(ours - golden))
    print(f"max abs error vs numpy.fft: {max_err:.3e}")

    print("Our FFT output (real part):")
    print(np.real(ours))
    print("Our FFT output (imag part):")
    print(np.imag(ours))
    print("Golden FFT output (real part):")
    print(np.real(golden))
    print("Golden FFT output (imag part):")
    print(np.imag(golden))

    # Check inverse path too
    recon = ifft2_iterative_radix2(ours)
    max_recon_err = np.max(np.abs(recon - mat))
    abs_err = np.abs(recon - mat)
    max_pos = np.unravel_index(np.argmax(abs_err), abs_err.shape)
    print(f"max abs reconstruction error (ifft∘fft): {max_recon_err:.3e} at {max_pos}")
    print("Abs reconstruction error matrix (32x32):")
    print(abs_err)


if __name__ == "__main__":
    demo_compare_32x32()
