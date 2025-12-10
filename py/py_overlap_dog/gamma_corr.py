import numpy as np


def gamma_corr(a: np.ndarray, gamma: float) -> np.ndarray:
    """Element-wise gamma correction, matches MATLAB gamma_corr.m."""
    return a ** gamma
