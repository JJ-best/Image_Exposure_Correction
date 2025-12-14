import random
import struct
import math

# ==========================================
# 1. 倒數單元模型 (Init + 3 Iterations)
# ==========================================
class ReciprocalSimulator:
    def __init__(self):
        self.lut = [0] * 128
        # 建立 LUT
        for i in range(128):
            val = 1.0 + (i + 0.5)/128.0 
            recip = 1.0 / val
            self.lut[i] = int(round(recip * 256))
            if self.lut[i] > 255: self.lut[i] = 255 

    def calc_reciprocal(self, d_mant_53):
        # 輸入 d_mant_53 是 1.xxxxx
        D_reg = d_mant_53 << 11
        
        # LUT
        lut_idx = (D_reg >> 56) & 0x7F
        F0_val = self.lut[lut_idx]
        F_reg = F0_val << (63 - 8) 
        
        round_bit = 1 << 62
        target_two = 1 << 64
        
        # Init: N = F0 (因為被除數是 1.0)
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
def get_mantissa_int(f_val):
    s = struct.pack('>d', f_val)
    bits = struct.unpack('>Q', s)[0]
    mant = (bits & 0xFFFFFFFFFFFFF) | (1 << 52)
    return mant

def check_one_case(name, d_val, sim):
    true_res = 1.0 / d_val
    t_mant = get_mantissa_int(true_res)
    
    d_mant = get_mantissa_int(d_val)
    model_res_64 = sim.calc_reciprocal(d_mant)
    
    # 輸出正規化: 若結果為 0.1xxxxx (Bit 63=0)，左移一位
    if (model_res_64 & (1 << 63)) == 0:
        model_res_64 <<= 1
        
    model_mant_53 = model_res_64 >> 11
    diff = abs(t_mant - model_mant_53)
    return diff

# ==========================================
# 3. 測試場景
# ==========================================

def test_bit_patterns(sim):
    print("\n[測試 1] 硬體殺手：特殊位元模式 (Bit Patterns)")
    print("-" * 60)
    # 構造特殊的 52-bit 尾數 (不含隱藏位)
    patterns = [
        (0x0000000000000, "All Zeros (D=1.0)"),
        (0xFFFFFFFFFFFFF, "All Ones (Max Mantissa)"),
        (0xAAAAAAAAAAAAA, "Alternating 1010..."),
        (0x5555555555555, "Alternating 0101..."),
        (0x0000000000001, "Min Normalized (+1 LSB)"),
        (0x8000000000000, "Single High Bit"),
        (0x0000000000003, "Two LSBs Set")
    ]
    
    max_err = 0
    for pat, name in patterns:
        # 構造浮點數: 1.Pattern
        d_bits = (0x3FF << 52) | pat # 0x3FF is exp for 1.0-2.0 range
        d_val = struct.unpack('>d', struct.pack('>Q', d_bits))[0]
        
        err = check_one_case(name, d_val, sim)
        max_err = max(max_err, err)
        
        if err > 2:
            print(f"❌ 失敗: {name} (D={d_val:.10f}) | Err: {err} ULP")
        else:
            # 只印出誤差 > 0 的，保持版面乾淨
            if err > 0: print(f"ℹ️  {name:<25} | Err: {err} ULP")

    print(f">> 位元模式測試最大誤差: {max_err} ULP")
    return max_err

def test_lut_sweep(sim):
    print("\n[測試 2] LUT 全域掃描 (Coverage Sweep)")
    print("-" * 60)
    # 掃描全部 128 個 Bin
    max_err = 0
    worst_bin = -1
    
    for i in range(128):
        # 測試每個 Bin 的三個關鍵點
        start = 1.0 + (i / 128.0)
        mid   = 1.0 + ((i + 0.5) / 128.0)
        end   = 1.0 + ((i + 0.9999) / 128.0)
        
        e1 = check_one_case("start", start, sim)
        e2 = check_one_case("mid", mid, sim)
        e3 = check_one_case("end", end, sim)
        
        local_max = max(e1, e2, e3)
        if local_max > max_err:
            max_err = local_max
            worst_bin = i
            
    print(f">> LUT 掃描最大誤差: {max_err} ULP (發生在 Bin #{worst_bin})")
    return max_err

def test_extreme_random(sim, count=50000):
    print(f"\n[測試 3] 大規模隨機測試 ({count} 筆)")
    print("-" * 60)
    max_err = 0
    err_dist = {0:0, 1:0, 2:0, "Over":0}
    
    for i in range(count):
        d_val = random.uniform(1.0, 2.0)
        err = check_one_case("rnd", d_val, sim)
        
        max_err = max(max_err, err)
        if err <= 2:
            err_dist[err] += 1
        else:
            err_dist["Over"] += 1
            if err_dist["Over"] < 5:
                print(f"❌ 隨機失敗: D={d_val} | Err={err}")

    print(f">> 隨機測試最大誤差: {max_err} ULP")
    print(f"   分佈: 0:{err_dist[0]}, 1:{err_dist[1]}, 2:{err_dist[2]}")
    return max_err

# ==========================================
# 主程式
# ==========================================
if __name__ == "__main__":
    sim = ReciprocalSimulator()
    total_err = 0
    
    total_err = max(total_err, test_bit_patterns(sim))
    total_err = max(total_err, test_lut_sweep(sim))
    total_err = max(total_err, test_extreme_random(sim))
    
    print("\n" + "="*40)
    if total_err <= 2:
        print(f"🏆 恭喜！倒數模型通過所有壓力測試。")
        print(f"   最大誤差: {total_err} ULP")
        print("   建議：您可以將這些 Pattern 用於 Verilog 模擬。")
    else:
        print(f"⚠️ 警告：模型存在精度問題，最大誤差 {total_err} ULP。")