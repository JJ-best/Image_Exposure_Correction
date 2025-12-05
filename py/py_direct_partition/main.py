from pathlib import Path
from PIL import Image
from lime import run_lime
import numpy as np

if __name__ == "__main__":
    # get absolute path of this file's directory (py_hardware)
    root = Path(__file__).resolve().parent
    img = root / "imgs" / "building.bmp"
    out_dir = root / "imgs_lime1"
    out_dir.mkdir(parents=True, exist_ok=True)

    # normalize to [0,1] in main, pass arr to run_lime
    arr = np.asarray(Image.open(img).convert("RGB"), dtype=np.float64) / 255.0
    figure_size = 680
    # static figure size
    arr = arr[0:figure_size, 0:figure_size, 0:3]
    ori_img = out_dir/"original_image.bmp"
    Image.fromarray((arr * 255).astype(np.uint8), mode="RGB").save(ori_img)
    
    # 32x32x3 patch size (0–255)
    patch_size = 32
    patch_img = np.zeros((patch_size, patch_size), dtype=np.float64)
    # 640x640x3 matrix
    enhanced1_img = np.zeros((figure_size, figure_size, 3), dtype=np.float64)
    enhanced2_img = np.zeros((figure_size, figure_size, 3), dtype=np.float64)
    enhanced2_inv = np.zeros((figure_size, figure_size, 3), dtype=np.float64)
    
    iter_time = figure_size // patch_size
    for i in range(iter_time):
        for j in range (iter_time):
            patch_img = arr[patch_size*i:patch_size*(i+1) , patch_size*j:patch_size*(j+1), 0:3]
            
            enhanced1_patch = run_lime(out_dir=out_dir, img_in=patch_img, k0=30)
            enhanced1_img[patch_size*i:patch_size*(i+1) , patch_size*j:patch_size*(j+1), 0:3] = enhanced1_patch 
            
            arr_inv = 1 - patch_img

            enhanced2_patch = run_lime(out_dir=out_dir, img_in=arr_inv, k0=30)
            enhanced2_img[patch_size*i:patch_size*(i+1) , patch_size*j:patch_size*(j+1), 0:3] = enhanced2_patch 
            
            enhanced2_patch_inv = 1- enhanced2_patch
            enhanced2_inv[patch_size*i:patch_size*(i+1) , patch_size*j:patch_size*(j+1), 0:3] = enhanced2_patch_inv

    # --------------------------------------------------------- #
    under_ex_img = out_dir/"underexposure_enhanced_image.bmp"
    Image.fromarray((enhanced1_img * 255).astype(np.uint8), mode="RGB").save(under_ex_img)
    
    out_dir = root / "imgs_lime2"
    out_dir.mkdir(parents=True, exist_ok=True)
    
    # img_inv = out_dir / "original_image_inverse.bmp"
    # Image.fromarray((arr_inv * 255).astype(np.uint8), mode="RGB").save(img_inv)
    over_ex_img = out_dir/"overexposure_enhanced_image.bmp"
    Image.fromarray((enhanced2_inv * 255).astype(np.uint8), mode="RGB").save(over_ex_img)

    
    
    

    
    # ---- add here ----- #
    # arr, enhance1, enhance2
    # matrix C, S, V
    
    
