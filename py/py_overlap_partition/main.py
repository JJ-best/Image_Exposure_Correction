from pathlib import Path
from PIL import Image
from lime import run_lime
from fusion import run_fusion 
import numpy as np


if __name__ == "__main__":
    # get absolute path of this file's directory (py_hardware)
    root = Path(__file__).resolve().parent
    img = root / "imgs" / "building.bmp"
    
    # output file path
    out_dir_lime1 = root / "imgs_lime1"
    out_dir_lime1.mkdir(parents=True, exist_ok=True)
    out_dir_lime2 = root / "imgs_lime2"
    out_dir_lime2.mkdir(parents=True, exist_ok=True)
    out_dir_fusion = root / "imgs_fusion"
    out_dir_fusion.mkdir(parents=True, exist_ok=True)

    # normalize to [0,1] in main, pass arr to run_lime
    arr = np.asarray(Image.open(img).convert("RGB"), dtype=np.float64) / 255.0
    figure_size = 680
    # static figure size
    arr = arr[0:figure_size, 0:figure_size, 0:3]
    # print(arr.shape)
    ori_img = out_dir_lime1/"original_image.bmp"
    Image.fromarray((arr * 255).astype(np.uint8), mode="RGB").save(ori_img)
    ''' 
    Original Image Size: 680x680x3 
    Output Image Size : 672x672x3 
    Patch Size: 32x32x3 Valid 
    Patch Size: 24x24x3(discard the boundary) 
    4 * 2(Discard Boundary) + 24 * Patch Number = 680 
    Patch Number = 28 
    '''
    # 32x32x3 patch size (0–255)
    patch_size = 32
    valid_size = 24
    border = (patch_size - valid_size) // 2
    patch_num = (figure_size - 2 * border) // valid_size
    patch_img = np.zeros((patch_size, patch_size), dtype=np.float64)
    # 672x672x3 matrix
    out_size = figure_size - 2 * border
    enhanced1_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    enhanced2_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    clip_orig_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    fused_full_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    iteration_cnt = 0
    
    print(f"Start processing... Patch Num: {patch_num}x{patch_num}")
    
    for i in range(patch_num):
        for j in range (patch_num):
            patch_img = arr[i*valid_size:i*valid_size + patch_size , j*valid_size: j*valid_size+patch_size, 0:3]
            patch_label = f"patch_{i:02d}_{j:02d}"
            
            # enhanced1_patch(32x32x3)
            enhanced1_patch = run_lime(
                out_dir=out_dir_lime1,
                img_in=patch_img,
                k0=20,
                gamma=0.7,
                save_label=f"{patch_label}_under",
                dump_alm=True, # if true, dump golden dat of alm
            )
            # enhanced1_img(24x24x3)
            enhanced1_img[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = enhanced1_patch[border:border+valid_size, border:border+valid_size, 0:3]
            
            arr_inv = 1 - patch_img

            # enhanced2_patch(32x32x3)
            enhanced2_patch = run_lime(
                out_dir=out_dir_lime2,
                img_in=arr_inv,
                k0=20,
                gamma=0.7,
                save_label=f"{patch_label}_over",
                dump_alm=True,
            )
            enhanced2_patch_inv = 1- enhanced2_patch
            # enhanced2_img(24x24x3)
            enhanced2_img[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = enhanced2_patch_inv[border:border+valid_size, border:border+valid_size, 0:3]
            
            # ========================================================= #
            # ### NEW: Fusion Logic Call ###
            # Input: enhanced1_patch (32x32), enhanced2_patch_inv (32x32), patch_img (32x32)
            # Output: fused_patch (24x24)
            # ========================================================= #
            fused_patch = run_fusion(
                enhanced1_patch, 
                enhanced2_patch_inv, 
                patch_img
            )
            fused_full_img[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = fused_patch
            
            print("iteration", i, "-", j, " complete")
            
            

    # --------------------------------------------------------- #
    # Save Images
    
    # 1. Under-exposure Fixed
    under_ex_img_path = out_dir_lime1 / "underexposure_enhanced_image.bmp"
    Image.fromarray((enhanced1_img * 255).astype(np.uint8), mode="RGB").save(under_ex_img_path)
    
    # 2. Over-exposure Fixed
    over_ex_img_path = out_dir_lime2 / "overexposure_enhanced_image.bmp"
    Image.fromarray((enhanced2_img * 255).astype(np.uint8), mode="RGB").save(over_ex_img_path)
    
    # ### NEW: Save Fusion Result ###
    fusion_img_path = out_dir_fusion / "final_fused_image.bmp"
    Image.fromarray((fused_full_img * 255).astype(np.uint8), mode="RGB").save(fusion_img_path)
    print(f"All done! Fusion result saved to: {fusion_img_path}")
    
    clip_orig_img = arr[0:out_size, 0:out_size, 0:3]
    '''
    enhanced1_img is underexposure fix image(672x672x3)
    enhanced2_img is overexposure fix image(672x672x3)
    clip_orig)img is cliped original image(672x672x3)
    '''
