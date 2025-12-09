# fusion.py
import numpy as np

# ==========================================
# 0. 演算法參數與核心 Kernel
# ==========================================
_k1d = np.array([1, 4, 6, 4, 1], dtype=np.float64)
GAUSS_KERNEL_5x5 = np.outer(_k1d, _k1d) / 256.0

LAPLACE_KERNEL_3x3 = np.array([
    [0,  1, 0],
    [1, -4, 1],
    [0,  1, 0]
], dtype=np.float64)

# ==========================================
# 1. 基礎運算單元
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
    output = np.sum(windows * kernel, axis=(2, 3))
    return output

def float_rgb2gray(img_patch):
    return np.dot(img_patch[..., :3], [0.114, 0.587, 0.299])

# ==========================================
# 2. 金字塔工具
# ==========================================
def float_pyr_down(img):
    blurred = float_conv2d(img, GAUSS_KERNEL_5x5)
    return blurred[::2, ::2]

def float_pyr_up(img, dst_shape):
    dst_h, dst_w = dst_shape
    upsampled_buffer = np.zeros((dst_h, dst_w), dtype=np.float64)
    upsampled_buffer[0::2, 0::2] = img
    interpolated = float_conv2d(upsampled_buffer, GAUSS_KERNEL_5x5 * 4.0)
    return interpolated

# ==========================================
# 3. 權重與融合邏輯
# ==========================================
def compute_cse_weights(img_patch):
    # 1. Contrast
    gray = float_rgb2gray(img_patch)
    C = np.abs(float_conv2d(gray, LAPLACE_KERNEL_3x3))
    # 2. Saturation
    S = np.std(img_patch, axis=2)
    # 3. Exposure
    sigma = 0.2
    E_c = np.exp(-((img_patch - 0.5) ** 2) / (2 * sigma ** 2))
    E = np.prod(E_c, axis=2)
    return (C * S * E) + 1e-12

def run_fusion(enhanced1_patch, enhanced2_patch_inv, arr_patch):
    """
    Inputs: All (32, 32, 3) float64 [0, 1]
    Output: (24, 24, 3) float64 [0, 1]
    """
    inputs = [enhanced1_patch, enhanced2_patch_inv, arr_patch]
    
    # --- Step 1: Compute Weights & Winner-Takes-All ---
    weights_raw = np.array([compute_cse_weights(img) for img in inputs])
    best_indices = np.argmax(weights_raw, axis=0) # (32, 32)
    
    masks = []
    for k in range(3):
        masks.append((best_indices == k).astype(np.float64))

    # --- Step 2: Pyramid Fusion ---
    levels = 3
    
    # Image Laplacian Pyramid
    pyr_imgs = []
    for img in inputs:
        channels_pyr = []
        for ch in range(3):
            single_ch = img[:, :, ch]
            g_pyr = [single_ch]
            for _ in range(levels - 1):
                g_pyr.append(float_pyr_down(g_pyr[-1]))
            
            l_pyr = []
            for i in range(levels - 1):
                h, w = g_pyr[i].shape
                up = float_pyr_up(g_pyr[i+1], (h, w))
                l_pyr.append(g_pyr[i] - up)
            l_pyr.append(g_pyr[-1])
            channels_pyr.append(l_pyr)
        pyr_imgs.append(channels_pyr)

    # Mask Gaussian Pyramid
    pyr_masks = []
    for m in masks:
        g_pyr = [m]
        for _ in range(levels - 1):
            g_pyr.append(float_pyr_down(g_pyr[-1]))
        pyr_masks.append(g_pyr)

    # Blending
    fused_pyr_channels = [[], [], []]
    for ch in range(3):
        for l in range(levels):
            h, w = pyr_imgs[0][ch][l].shape
            fused_layer = np.zeros((h, w), dtype=np.float64)
            for k in range(3):
                fused_layer += (pyr_masks[k][l] * pyr_imgs[k][ch][l])
            fused_pyr_channels[ch].append(fused_layer)

    # Reconstruction
    final_channels = []
    for ch in range(3):
        pyr = fused_pyr_channels[ch]
        img_recon = pyr[-1]
        for i in range(len(pyr) - 2, -1, -1):
            h, w = pyr[i].shape
            up = float_pyr_up(img_recon, (h, w))
            img_recon = up + pyr[i]
        final_channels.append(img_recon)
        
    final_img_32 = np.stack(final_channels, axis=2)
    
    # --- Step 3: Crop to 24x24 ---
    crop_s = 4
    crop_e = 28
    return np.clip(final_img_32[crop_s:crop_e, crop_s:crop_e, :], 0.0, 1.0)