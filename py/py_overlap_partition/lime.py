from pathlib import Path
import time

from PIL import Image
import numpy as np

# ----- import python function ----- #
from init_map import initial_map
from alm import lime_trial
from gamma_corr import gamma_corr
from typing import Optional


def run_lime(
    out_dir: Path,
    img_in: np.ndarray,
    alpha: float = 0.08,
    mu0: float = 0.01,
    rho: float = 1.2,
    gamma: float = 0.8,
    k0: int = 1,
    save_label: Optional[str] = None,
) -> np.ndarray:
    t0 = time.perf_counter()

    out_dir.mkdir(parents=True, exist_ok=True)
    label = save_label or "run"

    def stage_path(stage: str) -> Path:
        stage_dir = out_dir / stage
        stage_dir.mkdir(parents=True, exist_ok=True)
        return stage_dir / f"{label}.bmp"

    # also save the normalized input back (for reference)
    in_img = stage_path("input_image")
    Image.fromarray((np.clip(img_in, 0, 1) * 255).astype(np.uint8), mode="RGB").save(in_img)

    # print("image size: ", img_in.shape)

    # ----- initialize illumination map ----- #
    illum = initial_map(img_in)
    #print("initial illu map size: ", illum.shape)
    illum_out = stage_path("initial_illum_map")
    Image.fromarray((illum * 255).astype(np.uint8), mode="L").save(illum_out)

    # ----- Augmented Lagrange Multiplier (lime_trial) ----- #
    Tout = lime_trial(illum, alpha=alpha, mu0=mu0, rho=rho, k0=k0)

    # refine to [0,1], save
    Tout_clipped = np.clip(np.abs(Tout), 0, 1)
    illum_refined_out = stage_path("refined_illum_map")
    Image.fromarray((Tout_clipped * 255).astype(np.uint8), mode="L").save(illum_refined_out)

    # ----- Gamma Correction ----- #
    Tout_gamma = gamma_corr(Tout_clipped, gamma)
    illum_gamma_out = stage_path("gamma_illum_map")
    Image.fromarray((np.clip(Tout_gamma, 0, 1) * 255).astype(np.uint8), mode="L").save(illum_gamma_out)

    # ----- Enhance image by dividing input with gamma-corrected illumination ----- #
    T3 = np.stack([np.clip(Tout_gamma, 1e-6, 1.0)] * 3, axis=2)
    img_enhanced = np.clip(img_in / T3, 0, 1)  # dot division RGB channel image
    enhanced_out = stage_path("enhanced_image")
    Image.fromarray((img_enhanced * 255).astype(np.uint8), mode="RGB").save(enhanced_out)

    t1 = time.perf_counter()
    #print("execution time: {:.6f} s".format(t1 - t0))
    return img_enhanced
