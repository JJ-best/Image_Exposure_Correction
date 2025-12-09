from pathlib import Path
from PIL import Image
from lime import run_lime
import numpy as np

# ### NEW: Import fusion module ###
from fusion import run_fusion 

if __name__ == "__main__":
    # get absolute path of this file's directory (py_hardware)
    root = Path(__file__).resolve().parent
    img = root / "imgs" / "road.bmp"
    
    # normalize to [0,1] in main, pass arr to run_lime
    arr = np.asarray(Image.open(img).convert("RGB"), dtype=np.float64) / 255.0
    figure_size = 680
    # static figure size
    arr = arr[0:figure_size, 0:figure_size, 0:3]
    
    # 建立輸出目錄
    out_dir_lime1 = root / "imgs_lime1"
    out_dir_lime1.mkdir(parents=True, exist_ok=True)
    out_dir_lime2 = root / "imgs_lime2"
    out_dir_lime2.mkdir(parents=True, exist_ok=True)
    
    # ### NEW: 建立 Fusion 輸出目錄 ###
    out_dir_fusion = root / "imgs_fusion"
    out_dir_fusion.mkdir(parents=True, exist_ok=True)

    ori_img = out_dir_lime1 / "original_image.bmp"
    Image.fromarray((arr * 255).astype(np.uint8), mode="RGB").save(ori_img)

    # 32x32x3 patch size (0–255)
    patch_size = 32
    valid_size = 24
    border = (patch_size - valid_size) // 2
    patch_num = (figure_size - 2 * border) // valid_size
    
    # 672x672x3 matrix
    out_size = figure_size - 2 * border
    enhanced1_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    enhanced2_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    enhanced2_inv = np.zeros((out_size, out_size, 3), dtype=np.float64)
    
    # ### NEW: 宣告 Fusion 結果的大圖陣列 ###
    fused_full_img = np.zeros((out_size, out_size, 3), dtype=np.float64)
    
    print(f"Start processing... Patch Num: {patch_num}x{patch_num}")

    for i in range(patch_num):
        for j in range (patch_num):
            # 取出原始 Patch (32x32)
            patch_img = arr[i*valid_size:i*valid_size + patch_size , j*valid_size: j*valid_size+patch_size, 0:3]
            patch_label = f"patch_{i:02d}_{j:02d}"
            
            # 1. LIME Underexposure Correction
            enhanced1_patch = run_lime(
                out_dir=out_dir_lime1,
                img_in=patch_img,
                k0=30,
                gamma=0.7,
                save_label=f"{patch_label}_under",
            )
            # 填回大圖 (取中央 24x24)
            enhanced1_img[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = \
                enhanced1_patch[border:border+valid_size, border:border+valid_size, 0:3]
            
            # 2. LIME Overexposure Correction (Inverted)
            arr_inv = 1 - patch_img
            enhanced2_patch = run_lime(
                out_dir=out_dir_lime2,
                img_in=arr_inv,
                k0=30,
                gamma=0.7,
                save_label=f"{patch_label}_over",
            )
            enhanced2_img[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = \
                enhanced2_patch[border:border+valid_size, border:border+valid_size, 0:3]
            
            # 反轉回正常域
            enhanced2_patch_inv = 1 - enhanced2_patch
            enhanced2_inv[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = \
                enhanced2_patch_inv[border:border+valid_size, border:border+valid_size, 0:3]
            
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
            
            # 將 24x24 的融合結果填回大圖
            fused_full_img[i*valid_size:(i+1)*valid_size, j*valid_size:(j+1)*valid_size, 0:3] = fused_patch

            print(f"Iteration {i}-{j} complete")
            

    # --------------------------------------------------------- #
    # Save Images
    
    # 1. Under-exposure Fixed
    under_ex_img_path = out_dir_lime1 / "underexposure_enhanced_image.bmp"
    Image.fromarray((enhanced1_img * 255).astype(np.uint8), mode="RGB").save(under_ex_img_path)
    
    # 2. Over-exposure Fixed
    over_ex_img_path = out_dir_lime2 / "overexposure_enhanced_image.bmp"
    Image.fromarray((enhanced2_inv * 255).astype(np.uint8), mode="RGB").save(over_ex_img_path)
    
    # ### NEW: Save Fusion Result ###
    fusion_img_path = out_dir_fusion / "final_fused_image.bmp"
    Image.fromarray((fused_full_img * 255).astype(np.uint8), mode="RGB").save(fusion_img_path)
    print(f"All done! Fusion result saved to: {fusion_img_path}")