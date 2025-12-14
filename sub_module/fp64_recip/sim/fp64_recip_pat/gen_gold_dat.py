import random
import struct
import math

TOTAL_CASES = 2000 
FILENAME = "golden.dat"

# ==========================================
# 1. 核心模型 (Reciprocal Unit Model)
# ==========================================
class ReciprocalModel:
    def __init__(self):
        self.lut = [0] * 128
        for i in range(128):
            val = 1.0 + (i + 0.5)/128.0 
            recip = 1.0 / val
            self.lut[i] = int(round(recip * 256))
            if self.lut[i] > 255: self.lut[i] = 255 

    def calc_reciprocal_fixed_point(self, d_mant_53):
        # 轉 Q1.63
        D_reg = d_mant_53 << 11 
        lut_idx = (D_reg >> 56) & 0x7F
        F0_val = self.lut[lut_idx]
        F_reg = F0_val << (63 - 8) 
        
        round_bit = 1 << 62
        target_two = 1 << 64
        
        # Init
        N_reg = F_reg 
        D_reg = (D_reg * F_reg + round_bit) >> 63
        F_reg = target_two - D_reg
        
        # 3 Iterations
        for i in range(3): 
            N_reg = (N_reg * F_reg + round_bit) >> 63
            D_reg = (D_reg * F_reg + round_bit) >> 63
            if i < 2: F_reg = target_two - D_reg
            
        return N_reg 

# ==========================================
# 2. 輔助函數
# ==========================================
def float_to_bits(f):
    s = struct.pack('>d', f)
    return struct.unpack('>Q', s)[0]

def bits_to_float(b):
    s = struct.pack('>Q', b)
    return struct.unpack('>d', s)[0]

def unpack_float(f_val):
    bits = float_to_bits(f_val)
    sign = (bits >> 63) & 1
    exp  = (bits >> 52) & 0x7FF
    mant = (bits & 0xFFFFFFFFFFFFF) | (1 << 52)
    return sign, exp, mant

def pack_float(sign, exp, mant_52bit):
    if exp <= 0: exp = 0 
    if exp >= 2047: exp = 2047
    val = (sign << 63) | (exp << 52) | (mant_52bit & 0xFFFFFFFFFFFFF)
    return val

# ==========================================
# 3. 主程式
# ==========================================
def generate_high_precision_file():
    model = ReciprocalModel()
    cases = []
    
    print(f"正在產生 {FILENAME} (高精度註解版)...")

    # --- A. 邊角案例 ---
    corners = [
        1.0, 
        1.5, 
        1.9999999999999998, # 接近 2.0
        1.0000000000000002, # 接近 1.0
        1.4142135623730951, # sqrt(2)
        1.0 + 1.0/128.0, 
        3.141592653589793,  # Pi
        2.718281828459045   # e
    ]
    cases.extend(corners)

    # --- B. 特殊 Pattern ---
    patterns = [0xFFFFFFFFFFFFF, 0xAAAAAAAAAAAAA, 0x5555555555555, 0x0000000000001]
    for pat in patterns:
        cases.append(bits_to_float((1023 << 52) | pat))

    # --- C. 隨機填充 ---
    for _ in range(TOTAL_CASES - len(cases)):
        # 產生各種 Magnitude 的數值
        val = random.uniform(1.0, 2.0) * (2.0 ** random.randint(-100, 100))
        if random.random() > 0.5: val = -val
        cases.append(val)

    # --- 寫入檔案 ---
    with open(FILENAME, 'w') as f:
        f.write("// Format: Input_Hex Expected_Hex // Input_Full_Float, Expect_Full_Float\n")
        
        for b_val in cases:
            # 1. 硬體結果計算
            sb, eb, mb = unpack_float(b_val)
            res_sign = sb 
            raw_exp = 2046 - eb
            model_mant_64 = model.calc_reciprocal_fixed_point(mb)
            
            if (model_mant_64 & (1 << 63)) == 0:
                final_mant_64 = model_mant_64 << 1
                raw_exp -= 1  
            else:
                final_mant_64 = model_mant_64
            
            final_mant_52 = (final_mant_64 >> 11) & 0xFFFFFFFFFFFFF
            res_packed = pack_float(res_sign, raw_exp, final_mant_52)
            b_hex = float_to_bits(b_val)

            # 2. Python 浮點標準結果 (用於註解)
            try:
                expected_float = 1.0 / b_val
            except ZeroDivisionError:
                expected_float = float('inf')

            # 3. 格式化輸出
            # Hex 部分
            hex_part = f"{b_hex:016X}_{res_packed:016X}"
            
            # 註解部分：使用 .17g (17位有效數字，保證雙精度無損顯示)
            # 加寬欄位到 25 字元以保持對齊
            comment_part = f"// In={b_val:<25.17g} Expect={expected_float:<25.17g}"
            
            f.write(f"{hex_part}  {comment_part}\n")

    print(f"✅ 完成！{FILENAME} 已更新為高精度顯示。")
    print("範例輸出:")
    with open(FILENAME, 'r') as f:
        f.readline()
        print(f.readline().strip())
        print(f.readline().strip())
        print(f.readline().strip())

if __name__ == "__main__":
    generate_high_precision_file()