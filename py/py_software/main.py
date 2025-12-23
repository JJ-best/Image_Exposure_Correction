from pathlib import Path
from PIL import Image
from lime import run_lime
import numpy as np

if __name__ == "__main__":
    # get absolute path of this file
    root = Path(__file__).resolve().parent
    img = root / "imgs" / "building.bmp"
    out_dir = root / "imgs_lime1"
    out_dir.mkdir(parents=True, exist_ok=True)

    # normalize to [0,1] in main, pass arr to run_lime
    arr = np.asarray(Image.open(img).convert("RGB"), dtype=np.float64) / 255.0

    enhanced1 = run_lime(out_dir=out_dir, img_in=arr, k0=50) 

    out_dir = root / "imgs_lime2"
    out_dir.mkdir(parents=True, exist_ok=True)
    arr_inv = 1 - arr
    img_inv = out_dir / "original_image_inverse.bmp"
    Image.fromarray((arr_inv * 255).astype(np.uint8), mode="RGB").save(img_inv)

    enhanced2 = run_lime(out_dir=out_dir, img_in=arr_inv, k0=50)
    enhanced2_inv = 1- enhanced2
    over_ex_img = out_dir/"overexposure_enhanced_image.bmp"
    Image.fromarray((enhanced2_inv * 255).astype(np.uint8), mode="RGB").save(over_ex_img)
    
    # ---- add here ----- #
    # arr, enhance1, enhance2
    # matrix C, S, V
    
    