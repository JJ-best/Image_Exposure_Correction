from __future__ import annotations

import numpy as np


def initial_map(rgb: np.ndarray, eps: float = 1e-6) -> np.ndarray:
    """
    Compute initial illumination map: per-pixel max over RGB channels.
    Mirrors MATLAB initial_map.m but vectorized.
    
    reduce(arr[i][j][k], axis)
    axis=0->arr[all i][j][k]
    axis=1->arr[i][all j][k]
    axis=2->arr[i][j][all k] = arr[i][j][0],arr[i][j][1],arr[i][j][2] 
    """
    illum = np.maximum.reduce(rgb, axis=2)
    illum[illum == 0] = eps
    return np.clip(illum, 0.0, 1.0)
