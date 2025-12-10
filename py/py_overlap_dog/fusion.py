import numpy as np
from pathlib import Path

# ==========================================
# 0. Algorithm Parameters and Core Kernels
# ==========================================
# Hardware Optimization: Replace division with multiplication (Shift in Fixed-point logic)
# 1/16 = 0.0625
# 1/256 = 0.00390625
_k1d = np.array([1, 4, 6, 4, 1], dtype=np.float64)
# In hardware, this corresponds to: (ConvResult * 1) >> 8
GAUSS_KERNEL_5x5 = np.outer(_k1d, _k1d) / 256

LAPLACE_KERNEL_3x3 = np.array([
    [0,  1, 0],
    [1, -4, 1],
    [0,  1, 0]
], dtype=np.float64)

# Pre-calculate constant for Exposure to avoid division
# sigma = 0.2, 2*sigma^2 = 0.08
# INV_TWO_SIGMA_SQ = 1 / 0.08 = 12.5
INV_TWO_SIGMA_SQ = 12.5

def save_debug_dat(data, name, save_dir):
    """
    Save numpy array as a .dat file.
    save_dir: The specific directory to save the file (created automatically).
    """
    if save_dir is None:
        return
    
    # Automatically create directories recursively
    save_dir.mkdir(parents=True, exist_ok=True)
    
    path = save_dir / f"{name}.dat"
    
    if data.ndim == 3:
        h, w, c = data.shape
        to_save = data.reshape(-1, c)
    else:
        to_save = data

    # Save as plain text float, space delimited
    np.savetxt(path, to_save, fmt='%.6f', delimiter=' ')

# ==========================================
# 1. Basic Operation Units (No Up/Down Sample)
# ==========================================
def float_pad_reflect(img, pad_size):
    if img.ndim == 2:
        return np.pad(img, ((pad_size, pad_size), (pad_size, pad_size)), mode='reflect')
    else:
        return np.pad(img, ((pad_size, pad_size), (pad_size, pad_size), (0, 0)), mode='reflect')

def float_conv2d(img, kernel):
    k_h, k_w = kernel.shape
    pad_h = k_h // 2
    padded = float_pad_reflect(img, pad_h)
    from numpy.lib.stride_tricks import sliding_window_view
    windows = sliding_window_view(padded, (k_h, k_w))
    # Here only multiplication and addition (MAC) remain
    return np.sum(windows * kernel, axis=(2, 3))

def float_rgb2gray(img_patch):
    # These coefficients are also constant multiplications
    return np.dot(img_patch[..., :3], [0.114, 0.587, 0.299])

def float_gaussian_blur(img):
    """Perform Gaussian blur only, keep size unchanged."""
    return float_conv2d(img, GAUSS_KERNEL_5x5)

# ==========================================
# 2. Weight Calculation Logic (Hardware Optimized)
# ==========================================
def compute_cse_weights_debug(img_patch):
    # 1. Contrast (Laplacian) - Pure addition/subtraction and shifting
    # Kernel: 1, -4 (shift left 2)
    gray = float_rgb2gray(img_patch)
    C = np.abs(float_conv2d(gray, LAPLACE_KERNEL_3x3))
    
    # 2. Saturation (No-Division Optimization)
    # Original Formula: S = sum( (x - mean)^2 )
    # Trick: To avoid the division in mean = (R+G+B)/3, we scale the entire equation by 9.
    # S_scaled = (3R - Sum)^2 + (3G - Sum)^2 + (3B - Sum)^2
    # In Hardware: 3*R can be implemented as (R<<1) + R, using no multipliers.
    
    R = img_patch[:, :, 0]
    G = img_patch[:, :, 1]
    B = img_patch[:, :, 2]
    
    Sum_RGB = R + G + B
    
    # Calculate (3*Ch - Sum)^2
    # The result here is 9 times the original variance, but it does not affect comparison results.
    diff_r = (3 * R) - Sum_RGB
    diff_g = (3 * G) - Sum_RGB
    diff_b = (3 * B) - Sum_RGB
    
    S = (diff_r ** 2) + (diff_g ** 2) + (diff_b ** 2)
    
    # 3. Exposure (Multiplication Optimization)
    # exp( -diff^2 / 0.08 ) -> exp( -diff^2 * 12.5 )
    diff = img_patch - 0.5
    sq_diff = diff ** 2
    # Use multiplication instead of division
    E_c = np.exp(-sq_diff * INV_TWO_SIGMA_SQ)
    E = E_c[:, :, 0] * E_c[:, :, 1] * E_c[:, :, 2]
    
    # Combine Weights
    CS = C * S
    CSE = C * S * E
    
    return CSE + 1e-12, C, CS, CSE

# ==========================================
# 3. Main Fusion & Storage (Undecimated DoG)
# ==========================================
def run_fusion(enhanced1_patch, enhanced2_patch_inv, arr_patch, save_dir=None, patch_label=""):
    """
    Directory Structure Update:
    Weights: Category -> SubCategory -> IMGx -> File
    Pyramid: Category -> SubCategory -> Level (L0,L1) -> IMGx -> File
    """
    inputs = [enhanced1_patch, enhanced2_patch_inv, arr_patch]
    img_names = ["IMG1", "IMG2", "IMG3"]
    
    # --- Define Root Directories ---
    if save_dir:
        dir_cse_root = save_dir / "CSE"
        dir_pyr_root = save_dir / "Pyramid"
        
        # Sub-categories
        dir_c   = dir_cse_root / "1_C"
        dir_cs  = dir_cse_root / "2_CS"
        dir_cse = dir_cse_root / "3_CSE"
        dir_wta = dir_cse_root / "4_WTA_Mask"
        
        dir_pyr_gauss = dir_pyr_root / "1_Source_Blur"
        dir_pyr_dog   = dir_pyr_root / "2_Source_DoG"
        dir_pyr_mask  = dir_pyr_root / "3_Mask_Gauss"
        dir_pyr_fused = dir_pyr_root / "4_Fused_Pyr"
        dir_pyr_recon = dir_pyr_root / "5_Recon"
    
    # --- Step 1: Weights & Mask ---
    weights_raw = []
    for idx, img in enumerate(inputs):
        w, c, cs, cse = compute_cse_weights_debug(img)
        weights_raw.append(w)
        if save_dir:
            img_folder = img_names[idx]
            # Path: CSE -> 1_C -> IMGx -> File
            save_debug_dat(c,   f"{patch_label}_Weights_C",   dir_c   / img_folder)
            save_debug_dat(cs,  f"{patch_label}_Weights_CS",  dir_cs  / img_folder)
            save_debug_dat(cse, f"{patch_label}_Weights_CSE", dir_cse / img_folder)

    weights_raw = np.array(weights_raw)
    
    # Here we only compare magnitude, scaling by 9 does not affect the result.
    best_indices = np.argmax(weights_raw, axis=0) 
    masks = []
    for k in range(3):
        m = (best_indices == k).astype(np.float64)
        masks.append(m)
        if save_dir:
            # Path: CSE -> 4_WTA_Mask -> IMGx -> File
            save_debug_dat(m, f"{patch_label}_Masks_WTA", dir_wta / img_names[k])

    # --- Step 2: Undecimated DoG Decomposition ---
    levels = 3
    pyr_imgs = [] 
    suffix_list = ["Und", "Ove", "Ori"]
    
    for idx, img in enumerate(inputs):
        img_folder = img_names[idx]
        suffix = suffix_list[idx]
        
        channels_pyr = [] 
        
        # Debug lists for storage
        blur_pyr_rgb_debug = [ [] for _ in range(levels) ]
        dog_pyr_rgb_debug = [ [] for _ in range(levels) ]
        
        for ch in range(3):
            current_img = img[:, :, ch]
            layer_list = [] 
            
            # --- Core Loop: Generate DoG ---
            temp_blur_list = [current_img] 
            
            # Generate Blur Sequence
            for l in range(1, levels):
                blurred = float_gaussian_blur(temp_blur_list[-1])
                temp_blur_list.append(blurred)
            
            # Subtract to generate DoG
            for l in range(levels - 1):
                dog = temp_blur_list[l] - temp_blur_list[l+1]
                layer_list.append(dog)
                
                # Collect debug info
                dog_pyr_rgb_debug[l].append(dog)
                blur_pyr_rgb_debug[l].append(temp_blur_list[l])

            # The last layer Base
            base = temp_blur_list[-1]
            layer_list.append(base)
            
            # Collect debug info
            dog_pyr_rgb_debug[levels-1].append(base)
            blur_pyr_rgb_debug[levels-1].append(base)
            
            channels_pyr.append(layer_list)

        pyr_imgs.append(channels_pyr)
        
        if save_dir:
            for l in range(levels):
                # Path: Pyramid -> 1_Source_Blur -> L{l} -> IMGx -> File
                save_debug_dat(np.stack(blur_pyr_rgb_debug[l], axis=2), 
                               f"{patch_label}_Img{idx+1}_{suffix}_Blur_L{l}", 
                               dir_pyr_gauss / f"L{l}" / img_folder)
                
                # Path: Pyramid -> 2_Source_DoG -> L{l} -> IMGx -> File
                save_debug_dat(np.stack(dog_pyr_rgb_debug[l], axis=2), 
                               f"{patch_label}_Img{idx+1}_{suffix}_DoG_L{l}", 
                               dir_pyr_dog / f"L{l}" / img_folder)

    # --- Step 3: Mask Smooth ---
    pyr_masks = []
    for k in range(3):
        m = masks[k]
        mask_layers = [m] # L0 Mask
        
        current_m = m
        for _ in range(levels - 1):
            current_m = float_gaussian_blur(current_m)
            mask_layers.append(current_m)
            
        pyr_masks.append(mask_layers)
        
        if save_dir:
            img_folder = img_names[k]
            for l in range(levels):
                # Path: Pyramid -> 3_Mask_Gauss -> L{l} -> IMGx -> File
                save_debug_dat(mask_layers[l], 
                               f"{patch_label}_Masks_Blur_L{l}", 
                               dir_pyr_mask / f"L{l}" / img_folder)

    # --- Step 4: Blending (Fusion) ---
    fused_pyr_channels = [[], [], []]
    for ch in range(3):
        for l in range(levels):
            h, w = 32, 32 
            fused_layer = np.zeros((h, w), dtype=np.float64)
            for k in range(3):
                # Only multiplication and addition (MAC)
                fused_layer += (pyr_masks[k][l] * pyr_imgs[k][ch][l])
            fused_pyr_channels[ch].append(fused_layer)
            
    if save_dir:
        for l in range(levels):
            layer_rgb = [fused_pyr_channels[c][l] for c in range(3)]
            # Path: Pyramid -> 4_Fused_Pyr -> L{l} -> File (No IMGx, No Patch Folder)
            save_debug_dat(np.stack(layer_rgb, axis=2), 
                           f"{patch_label}_Fused_DoG_L{l}", 
                           dir_pyr_fused / f"L{l}")

    # --- Step 5: Reconstruction (Direct Sum) ---
    final_channels = []
    for ch in range(3):
        layers = fused_pyr_channels[ch]
        # Direct summation (Adder Tree)
        img_recon = np.sum(layers, axis=0)
        final_channels.append(img_recon)
        
    final_img_32 = np.stack(final_channels, axis=2)
    
    if save_dir:
        # Path: Pyramid -> 5_Recon -> File
        save_debug_dat(final_img_32, f"{patch_label}_Recon_32x32", dir_pyr_recon)
    
    crop_s = 4
    crop_e = 28
    final_img_24 = np.clip(final_img_32[crop_s:crop_e, crop_s:crop_e, :], 0.0, 1.0)
    
    return final_img_24